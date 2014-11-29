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

    def evaluate(scope, locals, &block)
      Jade.compile(data)
    end

  end
end
