# coding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')


describe Rack::JSONP do

  describe "closing application's response" do
    let(:test_body) { ['test_body'] }
    let(:params) { "foo=bar" }
    let(:content_type) { "text/html" }
    let(:app_params) {{}}
    after do
      request = Rack::MockRequest.env_for("/", :params => params)
      app = lambda { |env| [200, {'Content-Type' => content_type}, test_body] }
      Rack::JSONP.new(app, app_params).call(request).last
    end

    describe "when app response is closeable" do
      let(:test_body) { ['test_body'].stub(:close => true) }

      describe "and it is json" do
        let(:content_type) { "application/json" }

        describe "and callback was given" do
          let(:params) { "foo=bar&callback=foo" }

          it "closes the original body" do
            test_body.should_receive(:close)
          end
        end

        describe "and carriage return was requested" do
          let(:app_params) {{ :carriage_return => true }}

          it "closes the original body" do
            test_body.should_receive(:close)
          end
        end
      end

      describe "and it is not json" do
        let(:content_type) { "text/html"}
        let(:params) { "foo=bar&callback=foo" }
        it "does not close original body" do
          test_body.should_not_receive(:close)
        end
      end
    end

    describe "when app response is not closeable" do
        let(:params) { "foo=bar&callback=foo" }
        it "does not close original body" do
          test_body.should_not_receive(:close)
        end
    end
  end

  describe "when a callback parameter is provided" do
    it "should wrap the response body in the Javascript callback [default callback param]" do
      test_body = '{"bar":"foo"}'
      callback = 'foo'
      app = lambda { |env| [200, {'Content-Type' => 'application/json'}, [test_body]] }
      request = Rack::MockRequest.env_for("/", :params => "foo=bar&callback=#{callback}")
      body = Rack::JSONP.new(app).call(request).last
      body.should == ["#{callback}(#{test_body})"]
    end

    it "should wrap the response body in the Javascript callback [custom callback param]" do
      test_body = '{"bar":"foo"}'
      callback = 'foo'
      app = lambda { |env| [200, {'Content-Type' => 'application/json'}, [test_body]] }
      request = Rack::MockRequest.env_for("/", :params => "foo=bar&whatever=#{callback}")
      body = Rack::JSONP.new(app, :callback_param => 'whatever').call(request).last
      body.should == ["#{callback}(#{test_body})"]
    end

    it "removes the underscore parameter" do
      test_body = '{"bar":"foo"}'
      app_querystring = nil
      app = lambda do |env|
        app_querystring = env['QUERY_STRING']
        [200, {'Content-Type' => 'application/json'}, [test_body]]
      end
      request = Rack::MockRequest.env_for("/", :params => "a=b&_=timestamp")
      Rack::JSONP.new(app).call(request)
      app_querystring.should == "a=b"
    end

    it "does not remove parameters that start with an underscore" do
      test_body = '{"bar":"foo"}'
      app_querystring = nil
      app = lambda do |env|
        app_querystring = env['QUERY_STRING']
        [200, {'Content-Type' => 'application/json'}, [test_body]]
      end
      request = Rack::MockRequest.env_for("/", :params => "a=b&_=timestamp&_c=saveme")
      Rack::JSONP.new(app).call(request)
      app_querystring.should == "a=b&_c=saveme"
    end

    describe "content length" do
      let(:callback) {'foo'}
      let(:app) { lambda { |env| [200, {'Content-Type' => 'application/json'}, [test_body]] } }
      let(:request) { Rack::MockRequest.env_for("/", :params => "foo=bar&callback=#{callback}") }
      subject {Rack::JSONP.new(app).call(request)[1]['Content-Length']}
      context "with all single byte chars" do
        let(:test_body) {'{"bar":"foo"}'}
        it { should == "18" }
      end
      context "when the body contains an umlaut" do
        let(:test_body) {'{"bär":"foo"}'}
        it { should == "19" }
      end
    end

    it "should change the response Content-Type to application/javascript" do
      test_body = '{"bar":"foo"}'
      callback = 'foo'
      app = lambda { |env| [200, {'Content-Type' => 'application/json'}, [test_body]] }
      request = Rack::MockRequest.env_for("/", :params => "foo=bar&callback=#{callback}")
      headers = Rack::JSONP.new(app).call(request)[1]
      headers['Content-Type'].should == "application/javascript"
    end

    it "should not wrap content unless response is json" do
      test_body = '<html><body>Hello, World!</body></html>'
      callback = 'foo'
      app = lambda { |env| [200, {'Content-Type' => 'text/html'}, [test_body]] }
      request = Rack::MockRequest.env_for("/", :params => "foo=bar&callback=#{callback}")
      body = Rack::JSONP.new(app).call(request).last
      body.should == [test_body]
    end
  end

  describe "when json content is returned" do
    it "should do nothing if no carriage return has been requested" do
      test_body = '{"bar":"foo"}'
      app = lambda { |env| [200, {'Content-Type' => 'application/vnd.com.example.Object+json'}, [test_body]] }
      request = Rack::MockRequest.env_for("/", :params => "foo=bar")
      body = Rack::JSONP.new(app).call(request).last
      body.should == ['{"bar":"foo"}']
    end
    it "should add a carriage return if requested" do
      test_body = '{"bar":"foo"}'
      app = lambda { |env| [200, {'Content-Type' => 'application/vnd.com.example.Object+json'}, [test_body]] }
      request = Rack::MockRequest.env_for("/", :params => "foo=bar")
      body = Rack::JSONP.new(app, :carriage_return => true).call(request).last
      body.should == ["{\"bar\":\"foo\"}\n"]
    end
    it "should not add a carriage return for jsonp content" do
      test_body = '{"bar":"foo"}'
      callback = 'foo'
      app = lambda { |env| [200, {'Content-Type' => 'application/vnd.com.example.Object+json'}, [test_body]] }
      request = Rack::MockRequest.env_for("/", :params => "foo=bar&callback=#{callback}")
      body = Rack::JSONP.new(app, :carriage_return => true).call(request).last
      body.should == ["#{callback}(#{test_body})"]
    end
  end

  it "should not change anything if no callback param is provided" do
    app = lambda { |env| [200, {'Content-Type' => 'application/json'}, ['{"bar":"foo"}']] }
    request = Rack::MockRequest.env_for("/", :params => "foo=bar")
    body = Rack::JSONP.new(app).call(request).last
    body.join.should == '{"bar":"foo"}'
  end
end
