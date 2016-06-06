module Jade
  module Rails
    class Engine < ::Rails::Engine

      config.jade = ActiveSupport::OrderedOptions.new

      # Set default values. See README for details.
      config.jade.pretty        = ::Rails.env.development?
      config.jade.self          = false
      config.jade.compile_debug = ::Rails.env.development?
      config.jade.globals       = []

      initializer 'jade.assets.register', :group => :all do |app|
        config.assets.configure do |env|
          env.register_mime_type   'text/x-jade-template', :extensions => ['.jade', '.jst.jade']
          if env.respond_to?(:register_transformer)
            # Sprockets 3 introduces the idea of "transformers," which is
            # exactly what we want here.  Note that this transformer class
            # should also be compatible with Sprockets 4. For details, see:
            # https://github.com/rails/sprockets/blob/master/guides/extending_sprockets.md
            env.register_transformer 'text/x-jade-template', 'application/javascript', Jade::Rails::Processor
          else
            # If it's not possible to register a transformer, we must be in
            # Sprockets 2.  In this case, we'll continue with the old way of
            # using a Tilt template.  Later, when we decide to drop support for
            # Sprockets 2, it should be a simple matter of just deleting this
            # clause and the lib/jade/rails/template.rb file.
            app.assets.register_engine '.jade', ::Jade::Rails::Template
          end
        end
      end

    end
  end
end
