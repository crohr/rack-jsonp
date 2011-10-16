require 'rack'

module Rack
  # A Rack middleware for providing JSON-P support.
  #
  # Adapted from Flinn Mueller (http://actsasflinn.com/).
  #
  class JSONP

    def initialize(app, options = {})
      @app = app
      @carriage_return = options[:carriage_return] || false
      @callback_param = options[:callback_param] || 'callback'
    end

    # Proxies the request to the application, stripping out the JSON-P callback
    # method and padding the response with the appropriate callback format.
    #
    # Changes nothing if no <tt>callback</tt> param is specified.
    #
    def call(env)
      # remove the callback and _ parameters BEFORE calling the backend,
      # so that caching middleware does not store a copy for each value of the callback parameter
      request = Rack::Request.new(env)
      callback = request.params.delete(@callback_param)
      env['QUERY_STRING'] = env['QUERY_STRING'].split("&").delete_if{|param| param =~ /^(_|#{@callback_param})=/}.join("&")

      status, headers, app_response = @app.call(env)
      response = if callback && headers['Content-Type'] =~ /json/i
        json = pad(callback, app_response)
        headers['Content-Length'] = json.first.bytesize.to_s
        headers['Content-Type'] = 'application/javascript'
        json
      elsif @carriage_return && headers['Content-Type'] =~ /json/i
        # add a \n after the response if this is a json (not JSONP) response
        json = carriage_return(app_response)
        headers['Content-Length'] = json.first.bytesize.to_s
        json
      else
        nil
      end

      # Close original response if it was Rack::BodyProxy (or anything else responding to close,
      # as we're going to lose it anyway), or it will cause thread failures with newer Rack
      if app_response.respond_to?(:close) && response
        app_response.close
      end

      [status, headers, response || app_response]
    end

    # Pads the response with the appropriate callback format according to the
    # JSON-P spec/requirements.
    #
    # The Rack response spec indicates that it should be enumerable. The method
    # of combining all of the data into a single string makes sense since JSON
    # is returned as a full string.
    #
    def pad(callback, response, body = "")
      response.each{ |s| body << s.to_s }
      ["#{callback}(#{body})"]
    end

    def carriage_return(response, body = "")
      response.each{ |s| body << s.to_s }
      ["#{body}\n"]
    end
  end

end
