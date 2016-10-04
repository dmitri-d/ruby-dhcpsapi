require 'test_helper'
require 'dhcpsapi'

class MiscTest < Test::Unit::TestCase
  def setup
    @subnet_1 = "192.168.242.0"
    @api = new_server
    @api.create_subnet(@subnet_1, '255.255.255.0', 'subnet one', 'subnet one comment')
    @api.add_subnet_ip_range(@subnet_1, '192.168.242.10', '192.168.242.20')
  end

  def teardown
    @api.delete_subnet(@subnet_1, DhcpsApi::DHCP_FORCE_FLAG::DhcpFullForce)
  end

  def test_get_free_ips
    assert_equal ['192.168.242.10', '192.168.242.11', '192.168.242.12', '192.168.242.13', '192.168.242.14'],
                 @api.get_free_ip_address(@subnet_1, '192.168.242.10', '192.168.242.20', 5)
  end
end
