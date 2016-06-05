module Jade
  module Rails
    class Compiler
      def self.compile(source, options = {})
        @@context ||= begin
          jade_js = File.read(File.expand_path('../../../../vendor/assets/javascripts/jade/jade.js', __FILE__))
          ExecJS.compile <<-JS
            var window = {};
            #{jade_js}
            var jade = window.jade;
          JS
        end

        # TODO: Get options from config.jade.

        source = source.read if source.respond_to?(:read)
        compiled = @@context.eval("jade.compileClient(#{source.to_json}, #{options.to_json})")
      end
    end
  end
end
