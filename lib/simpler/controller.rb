require_relative 'view'

module Simpler
  class Controller

    attr_reader :name, :request, :response

    def initialize(env)
      @name = extract_name
      @request = Rack::Request.new(env)
      @response = Rack::Response.new

      extract_params(env) if env['simpler.params']
    end

    def make_response(action)
      @request.env['simpler.controller'] = self
      @request.env['simpler.action'] = action

      set_default_headers
      send(action)
      write_response

      @response.finish
    end

    def request_error(status)
      set_response_status(status)
      @response.write(View.new(@request.env).error_page(status))
      @response.finish
    end

    private

    def extract_name
      self.class.name.match('(?<name>.+)Controller')[:name].downcase
    end

    def set_default_headers
      @response['Content-Type'] = 'text/html'
    end

    def write_response
      body = render_body

      @response.write(body)
    end

    def render_body
      View.new(@request.env).render(binding)
    end

    def params
      @request.params
    end

    def extract_params(env)
      env['simpler.params'].each do |key, value|
        @request.update_param(key, value)
      end
    end

    def render(request_object)
      if request_object.is_a?(Hash)
        handle_hash_request(request_object)
      elsif request_object.is_a?(String)
        handle_template_request(request_object)
      end
    end

    def handle_hash_request(request_object)
      if request_object.key?(:plain)
        set_plain_text(request_object[:plain])
      elsif request_object.key?(:html)
        set_html(request_object[:html])
      elsif request_object.key?(:template)
        handle_template_request(request_object[:template])
      end
      set_response_status(request_object[:status]) if request_object.key?(:status)
    end

    def handle_template_request(template)
      extension = template.split('.')[1]
      if extension == 'html'
        set_template(template)
      elsif extension.nil?
        set_html_template(template)
      elsif extension == 'text'
        set_text_template(template)
      end
    end

    def set_plain_text(data)
      set_response_content_type('text/plain')
      set_env_response_type('plain')
      set_env_response_data('plain', data)
    end

    def set_html(data)
      set_env_response_type('html')
      set_env_response_data('html', data)
    end

    def set_env_response_type(type)
      @request.env['simpler.response_type'] = type
    end

    def set_response_content_type(type)
      @response['Content-Type'] = type
    end

    def set_env_response_data(data_type, data)
      @request.env["simpler.#{data_type}"] = data
    end

    def set_html_template(template)
      set_template("#{template}.html")
    end

    def set_text_template(template)
      set_response_content_type('text/plain')
      set_template(template)
    end

    def set_template(template)
      @request.env['simpler.template'] = template
    end

    def set_response_status(status)
      @response.status = status
    end

  end
end
