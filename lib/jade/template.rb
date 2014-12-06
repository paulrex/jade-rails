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

    # Compile template data using Jade compiler.
    #
    # This returns a String containing a JS function, which is intended
    # to be used with the Sprockets JST engine. Name your file so that
    # it is processed by both of these engines, and then the template
    # will be available on the JST global on the front end.
    #
    # For example, `my_template.jst.jade` will be available on the front
    # end as JST['my_template'], which is a function that takes a single
    # argument containing the locals to use in rendering the template:
    #
    #   # => function template(locals) { ... }
    #
    def evaluate(context, locals, &block)
      options = { }
      options[:filename] = eval_file

      jade_config = context.environment.context_class.jade_config.merge(options)
      # Manually camelize the one option key that needs to be camelized.
      jade_config[:compileDebug] = jade_config.delete(:compile_debug) { false }

      Jade.compile(data, jade_config)
    end

  end
end
