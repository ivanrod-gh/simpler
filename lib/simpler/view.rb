require 'erb'

module Simpler
  class View

    VIEW_BASE_PATH = 'app/views'.freeze

    def initialize(env)
      @env = env
    end

    def render(binding)
      response_type = @env['simpler.response_type']
      if response_type == 'plain'
        plain_text_render
      elsif response_type == 'html'
        html_render
      else
        file_render(binding)
      end
    end

    def error_page(status)
      File.read(Simpler.root.join('public', "#{status.to_s}.html"))
    end

    private

    def plain_text_render
      @env['simpler.plain']
    end

    def html_render
      @env['simpler.html']
    end

    def file_render(binding)
      template = File.read(template_path)
      ERB.new(template).result(binding)
    end

    def controller
      @env['simpler.controller']
    end

    def action
      @env['simpler.action']
    end

    def template
      @env['simpler.template']
    end

    def template_path
      path = template || "#{[controller.name, action].join('/')}.html"
      @env['simpler.used_template'] = "#{path}.erb"

      Simpler.root.join(VIEW_BASE_PATH, @env['simpler.used_template'])
    end

  end
end
