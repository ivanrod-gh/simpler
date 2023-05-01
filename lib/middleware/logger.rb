require 'logger'

class AppLogger
  def initialize(app)
    @logger = Logger.new(Simpler.root.join('log/app.log'))
    @app = app
  end
  
  def call(env)
    response = @app.call(env)

    log_to_file(env, response)

    response
  end

  private

  def log_to_file(env, response)
    log_request = "\n  Request: #{env['REQUEST_METHOD']} #{env['REQUEST_URI']}"
    log_handler = "\n  Handler: #{env['simpler.controller'].class}##{env['simpler.action']}"
    log_parameters = "\n  Parameters: #{env['rack.request.query_hash']}"
    log_response = "\n  Response: #{response[0]} [#{response[1]['Content-Type']}] #{env['simpler.used_template']}"

    @logger.info("#{log_request}#{log_handler}#{log_parameters}#{log_response}")
  end
end
