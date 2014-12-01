require 'tilt'

module Jade
  class Template < Tilt::Template

    def self.engine_initialized?
      defined? ::Jade
    end

    def initialize_engine
      require_template_library 'jade'
    end

    def prepare
    end

    def evaluate(context, locals, &block)
      options = { }
      # options[:filename] = eval_file

      jade_config = context.environment.context_class.jade_config.merge(options)
      # Manually camelize the one option key that needs to be camelized.
      jade_config[:compileDebug] = jade_config.delete(:compile_debug) { false }

      Jade.compile(data, jade_config)
    end

  end
end
