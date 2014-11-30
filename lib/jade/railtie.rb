require 'jade/template'

module Jade
  class Railtie < Rails::Engine
    # Register the engine on the Sprockets::Environment instance for the Rails app.
    initializer :register_jade_engine, group: :all do |app|
      app.assets.register_engine '.jade', ::Jade::Template
    end
  end
end
