require 'test_helper'
require 'dhcpsapi'

class MiscTest < Test::Unit::TestCase
  def setup
    @subnet_1 = "192.168.242.0"
    @api = DhcpsApi::Server.new('127.0.0.1')
    @api.create_subnet(@subnet_1, '255.255.255.0', 'subnet one', 'subnet one comment')
  end

  def teardown
    @api.delete_subnet(@subnet_1, DhcpsApi::DHCP_FORCE_FLAG::DhcpFullForce)
  end

  # Need to extend the api to create 'ip range' subnet element before this test can be executed
  def _test_get_free_ips
    assert_equal ['192.168.242.1', '192.168.242.2', '192.168.242.3', '192.168.242.4', '192.168.242.5'],
                 @api.get_free_ip_address(@subnet_1, '192.168.242.0', '192.168.242.10', 5)
  end
end
