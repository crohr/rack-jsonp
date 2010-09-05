require File.expand_path(File.dirname(__FILE__) + '/spec_helper')


describe Rack::JSONP do

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
 
    it "should modify the content length to the correct value" do
      test_body = '{"bar":"foo"}'
      callback = 'foo'
      app = lambda { |env| [200, {'Content-Type' => 'application/json'}, [test_body]] }
      request = Rack::MockRequest.env_for("/", :params => "foo=bar&callback=#{callback}")
      headers = Rack::JSONP.new(app).call(request)[1]
      headers['Content-Length'].should == ((test_body.length + callback.length + 2).to_s) # 2 parentheses
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
