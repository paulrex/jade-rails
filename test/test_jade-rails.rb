require 'jade-rails'
require 'test/unit'

class JadeTest < Test::Unit::TestCase
  JADE_TEMPLATE_FUNCTION_PATTERN = /^function\s+template\s*\(locals\)\s*\{.*\}$/m

  def test_compile
    template = File.read(File.expand_path('../../vendor/assets/javascripts/jade/sample_template.jade', __FILE__))
    result = Jade.compile(template)
    assert_match(JADE_TEMPLATE_FUNCTION_PATTERN, result)
    assert_no_match(/^\s*<!DOCTYPE html>/, result)
  end

  def test_compile_with_io
    io = StringIO.new('string of jade')
    assert_equal Jade.compile('string of jade'), Jade.compile(io)
  end

  def test_compilation_error
    assert_raise ExecJS::ProgramError do
      Jade.compile <<-JADE
        else
          .foo
      JADE
    end
  end

end
