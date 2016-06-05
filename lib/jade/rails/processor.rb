module Jade
  module Rails
    class Processor

      def initialize(filename, &block)
        @filename = filename
        @source   = block.call
      end

      def render(variable, empty_hash)
        self.class.run(@filename, @source)
      end

      def self.run(filename, source)
        options  = { :filename => filename }
        compiled = Compiler.compile(source, options)
        return { :data => compiled }
      end

      def self.call(input)
        filename = input[:filename]
        source   = input[:data]
        self.run(filename, source)
      end

    end
  end
end
