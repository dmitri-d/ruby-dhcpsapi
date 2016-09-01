require "minitest/autorun"
require "test/unit"
require 'fileutils'

$: << File.join(File.dirname(__FILE__), '..', 'lib')

module Test
  module Unit
    class TestCase
      def ignore_exceptions
        yield
      rescue Exception
        # nothing
      end
    end
  end
end
