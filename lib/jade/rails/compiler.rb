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

        # Get the compilation options from the application's config.jade.
        # See lib/jade/rails/engine.rb for details.
        options = ::Rails.application.config.jade.merge(options)
        # For one of the options keys, we need to manually camel-case before
        # passing to the Jade compiler.
        options[:compileDebug] = options.delete(:compile_debug) { false }

        source = source.read if source.respond_to?(:read)
        compiled = @@context.eval("jade.compileClient(#{source.to_json}, #{options.to_json})")
      end
    end
  end
end
