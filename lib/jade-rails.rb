# Jade Template Compiler for Ruby

require 'json'
require 'execjs'

module Jade
  class << self

    def compile(source, options = {})
      jade_js = File.read(File.expand_path('../../vendor/assets/javascripts/jade/jade.js', __FILE__))
      context = ExecJS.compile <<-JS
        var window = {};
        #{jade_js}
        var jade = window.jade;
      JS
      source = source.read if source.respond_to?(:read)
      context.eval("jade.compileClient(#{source.to_json}, #{options.to_json})")
    end

  end
end
