require 'test_helper'
require 'dhcpsapi'

class SubnetTest < Test::Unit::TestCase
  def setup
    @subnet_1 = "192.168.242.0"
    @subnet_2 = "192.168.243.0"
    @api = DhcpsApi::Server.new('127.0.0.1')
  end

  def test_create_list_delete_subnet
    original_subnet_number = @api.list_subnets.size

    @api.create_subnet(@subnet_1, '255.255.255.0', 'subnet one', 'subnet one comment')
    @api.create_subnet(@subnet_2, '255.255.255.0', 'subnet two', 'subnet two comment')

    subnets = @api.list_subnets
    assert_equal original_subnet_number + 2, subnets.size
    assert subnets.any? {|s| s[:subnet_name] == 'subnet one'}
    assert subnets.any? {|s| s[:subnet_name] == 'subnet two'}

    @api.add_subnet_ip_range(@subnet_1, '192.168.242.10', '192.168.242.20')
    @api.delete_subnet_ip_range(@subnet_1, '192.168.242.10', '192.168.242.20')

    @api.delete_subnet(@subnet_1)
    @api.delete_subnet(@subnet_2)
    assert_equal original_subnet_number, @api.list_subnets.size
  ensure
    ignore_exceptions { @api.delete_subnet(@subnet_1, DhcpsApi::DHCP_FORCE_FLAG::DhcpFullForce) }
    ignore_exceptions { @api.delete_subnet(@subnet_2, DhcpsApi::DHCP_FORCE_FLAG::DhcpFullForce) }
  end

  def test_delete_non_existent_subnet
    assert_raises(DhcpsApi::Error) { @api.delete_subnet('192.168.254.0') }
  end
end
