require 'jade/template'

module Jade
  class Railtie < Rails::Engine
    module JadeContext
      attr_accessor :jade_config
    end

    config.jade = ActiveSupport::OrderedOptions.new

    config.jade.pretty        = Rails.env.development?
    config.jade.self          = false
    config.jade.compile_debug = Rails.env.development?
    config.jade.globals       = []

    initializer :setup_jade, after: 'sprockets.environment', group: :all do |app|
      if app.assets
        app.assets.register_engine '.jade', ::Jade::Template

        app.assets.context_class.extend(JadeContext)
        app.assets.context_class.jade_config = app.config.jade
      end
    end
  end
end
