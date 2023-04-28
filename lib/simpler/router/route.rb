module Simpler
  class Router
    class Route

      attr_reader :controller, :action

      def initialize(method, path, controller, action)
        @method = method
        @path = path
        @controller = controller
        @action = action
      end

      def match?(method, path, env)
        if @path.include?(':')
          method == @method && compare_paths(path, @path, env)
        else
          method == @method && path == @path
        end
      end

      private

      def compare_paths(path, route, env)
        params, equal = compare_arrays(path.split('/'), route.split('/'), {}, 0)
        env['simpler.params'] = params if equal
      end

      def compare_arrays(paths, routes, params, equal_count)
        count = paths.size > routes.size ? paths.size : routes.size
        for i in (0..count - 1)
          if paths[i].to_i == 0
            equal_count += 1 if paths[i] == routes[i]
          elsif routes[i].include?(':')
            equal_count += 1
            params[routes[i].sub(':','').to_sym] = paths[i].to_i
          end
        end
        return params, equal_count == count
      end

    end
  end
end


