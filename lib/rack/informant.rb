module Rack
  # Middleware that "informs on" an application, reporting everything it does
  # to its secret employer.  Other middlewares may become hostile if they find
  # out.
  #
  # After each request is processed, calls the provided block with a hash
  # containing:
  #  * :method - HTTP request method, e.g. 'GET', 'POST'
  #  * :path - path segment of the request (no host, port or querystring),
  #            e.g. '/info'
  #  * :status - HTTP response status code, e.g. 200, 404
  #  * :runtime - total request processing time (by the server's reckoning) in
  #               *seconds*, as a float.  e.g. 0.1 == 100 ms.
  #
  # This middleware is async-safe (i.e. should work correctly for both
  # synchronous requests and asynchronous requests).
  #
  # Example usage:
  #
  #     require 'rack/informant'
  #     use Rack::Informant do |request|
  #       # poor man's request logging (use Rack::CommonLogger instead)
  #       puts "#{request[:method]} #{request[:path]}: #{request[:status]} #{request[:runtime]}"
  #     end

  class Informant
    def initialize(app, &block)
      @app = app
      @callback = block || lambda {|*_|}
    end

    def call(env)
      start = Time.now

      if original_callback = env['async.callback']
        env['async.callback'] = proc do |response|
          status, headers, body = response

          inform!(env, start, status, headers, body)

          original_callback.call(response)
        end
      end

      catch :async do
        status, headers, body = @app.call(env)

        # if we got this far, then @app.call didn't throw :async
        return [status, headers, body] if status == -1 # alternative async API

        # if we got *this* far, @app.call is definitely synchronous
        inform!(env, start, status, headers, body)

        return [status, headers, body]
      end

      # we only end up here if @app.call threw :async, so just throw it on.
      throw :async
    end

    private
    def inform!(env, start, status, headers, body)
      runtime = Time.now - start

      event = {
        method: env['REQUEST_METHOD'],
        path: env['PATH_INFO'],
        status: status,
        runtime: runtime,
      }

      @callback.call(event)
    end
  end
end
