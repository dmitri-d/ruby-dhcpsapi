require "minitest/autorun"
require "test/unit"
require 'fileutils'

$: << File.join(File.dirname(__FILE__), '..', 'lib')

module ServerSetup
  def new_server
    DhcpsApi::Server.new('127.0.0.1')
  end
end

module Test
  module Unit
    class TestCase
      include ServerSetup

      def ignore_exceptions
        yield
      rescue Exception
        # nothing
      end
    end
  end
end
