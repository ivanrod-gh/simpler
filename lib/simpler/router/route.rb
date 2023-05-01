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
        path, @path = delete_first_and_last_slash([path, @path])
        if @path.include?(':')
          method == @method && compare_paths(path, @path, env)
        else
          method == @method && path == @path
        end
      end

      private

      def delete_first_and_last_slash(paths)
        paths.map! do |path|
          path = path.start_with?('/') ? path.sub('/','') : path
          path = path.reverse.start_with?('/') ? path.reverse.sub('/','').reverse : path
        end
        return paths
      end

      def compare_paths(path, route, env)
        return false if different_slash_count(path, route)

        params, equal = extract_params_and_compare_arrays(path.split('/'), route.split('/'))
        env['simpler.params'] = params if equal
      end

      def different_slash_count(path, route)
        path.count('/') != route.count('/')
      end

      def extract_params_and_compare_arrays(paths, routes)
        params, equal_count, count = {}, 0, paths.size
        count.times do |i|
          if paths[i].to_i == 0
            equal_count += 1 if paths[i] == routes[i]
          elsif routes[i].include?(':') && paths[i].to_i.to_s.size == paths[i].to_s.size
            equal_count += 1
            params[routes[i].sub(':','').to_sym] = paths[i].to_i
          end
        end
        return params, equal_count == count
      end

    end
  end
end


