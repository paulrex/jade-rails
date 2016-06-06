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

      def self.call(input)
        # Compile the Jade template into a JS template function.
        source   = input[:data]
        filename = input[:filename]
        compiled = Compiler.compile(source, { :filename => filename })

        # Then use the JST processor to add the template to the window.JST object.
        input[:data] = compiled
        return ::Sprockets::JstProcessor.call(input)
      end

    end
  end
end
