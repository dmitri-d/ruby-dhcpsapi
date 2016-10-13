require 'test_helper'
require 'dhcpsapi'

class SubnetElementTest < Test::Unit::TestCase
  def setup
    @subnet1 = "192.168.242.0"
    @api = new_server
  end

  def test_create_list_delete_subnet_elements
    @api.create_subnet(@subnet1, '255.255.255.0', 'subnet one', 'subnet one comment')

    @api.add_subnet_element(@subnet1, DhcpsApi::DHCP_SUBNET_ELEMENT_DATA_V4.build_for_reservation('192.168.242.100', '00:01:02:03:04:01', DhcpsApi::ClientType::CLIENT_TYPE_DHCP))
    @api.add_subnet_element(@subnet1, DhcpsApi::DHCP_SUBNET_ELEMENT_DATA_V4.build_for_reservation('192.168.242.101', '00:01:02:03:04:02', DhcpsApi::ClientType::CLIENT_TYPE_DHCP))
    @api.add_subnet_element(@subnet1, DhcpsApi::DHCP_SUBNET_ELEMENT_DATA_V4.build_for_reservation('192.168.242.102', '00:01:02:03:04:03', DhcpsApi::ClientType::CLIENT_TYPE_DHCP))
    @api.add_subnet_element(@subnet1, DhcpsApi::DHCP_SUBNET_ELEMENT_DATA_V4.build_for_reservation('192.168.242.103', '00:01:02:03:04:04', DhcpsApi::ClientType::CLIENT_TYPE_DHCP))
    @api.add_subnet_element(@subnet1, DhcpsApi::DHCP_SUBNET_ELEMENT_DATA_V4.build_for_reservation('192.168.242.104', '00:01:02:03:04:05', DhcpsApi::ClientType::CLIENT_TYPE_DHCP))
    @api.add_subnet_element(@subnet1, DhcpsApi::DHCP_SUBNET_ELEMENT_DATA_V4.build_for_reservation('192.168.242.105', '00:01:02:03:04:06', DhcpsApi::ClientType::CLIENT_TYPE_DHCP))

    @api.add_subnet_element(@subnet1, DhcpsApi::DHCP_SUBNET_ELEMENT_DATA_V4.build_for_subnet_range('192.168.242.10', '192.168.242.19'))

    reservations = @api.list_subnet_elements(@subnet1, DhcpsApi::DHCP_SUBNET_ELEMENT_TYPE::DhcpReservedIps)
    assert_equal Set.new(['192.168.242.100', '192.168.242.101', '192.168.242.102', '192.168.242.103', '192.168.242.104', '192.168.242.105']),
                 Set.new(reservations.map {|r| r[:element][:reserved_ip_address]})
    # mac addresses come back prefixed with subnet ip
    assert_equal Set.new(['00:F2:A8:C0:01:00:01:02:03:04:01', '00:F2:A8:C0:01:00:01:02:03:04:02',
                          '00:F2:A8:C0:01:00:01:02:03:04:03', '00:F2:A8:C0:01:00:01:02:03:04:04',
                          '00:F2:A8:C0:01:00:01:02:03:04:05', '00:F2:A8:C0:01:00:01:02:03:04:06']),
                 Set.new(reservations.map {|r| r[:element][:reserved_for_client][:data]})

    ranges = @api.list_subnet_elements(@subnet1, DhcpsApi::DHCP_SUBNET_ELEMENT_TYPE::DhcpIpRanges)
    assert_equal Set.new([{:start_address => '192.168.242.10', :end_address => '192.168.242.19'}]), Set.new(ranges)

    @api.delete_subnet_element(@subnet1, DhcpsApi::DHCP_SUBNET_ELEMENT_DATA_V4.build_for_reservation('192.168.242.100', '00:01:02:03:04:01', DhcpsApi::ClientType::CLIENT_TYPE_DHCP))
    @api.delete_subnet_element(@subnet1, DhcpsApi::DHCP_SUBNET_ELEMENT_DATA_V4.build_for_reservation('192.168.242.101', '00:01:02:03:04:02', DhcpsApi::ClientType::CLIENT_TYPE_DHCP))
    @api.delete_subnet_element(@subnet1, DhcpsApi::DHCP_SUBNET_ELEMENT_DATA_V4.build_for_reservation('192.168.242.102', '00:01:02:03:04:03', DhcpsApi::ClientType::CLIENT_TYPE_DHCP))
    @api.delete_subnet_element(@subnet1, DhcpsApi::DHCP_SUBNET_ELEMENT_DATA_V4.build_for_reservation('192.168.242.103', '00:01:02:03:04:04', DhcpsApi::ClientType::CLIENT_TYPE_DHCP))
    @api.delete_subnet_element(@subnet1, DhcpsApi::DHCP_SUBNET_ELEMENT_DATA_V4.build_for_reservation('192.168.242.104', '00:01:02:03:04:05', DhcpsApi::ClientType::CLIENT_TYPE_DHCP))
    @api.delete_subnet_element(@subnet1, DhcpsApi::DHCP_SUBNET_ELEMENT_DATA_V4.build_for_reservation('192.168.242.105', '00:01:02:03:04:06', DhcpsApi::ClientType::CLIENT_TYPE_DHCP))

    @api.delete_subnet_element(@subnet1, DhcpsApi::DHCP_SUBNET_ELEMENT_DATA_V4.build_for_subnet_range('192.168.242.10', '192.168.242.19'))

    assert_equal 0, @api.list_subnet_elements(@subnet1, DhcpsApi::DHCP_SUBNET_ELEMENT_TYPE::DhcpReservedIps).size
    assert_equal 0, @api.list_subnet_elements(@subnet1, DhcpsApi::DHCP_SUBNET_ELEMENT_TYPE::DhcpIpRanges).size
  ensure
    ignore_exceptions { @api.delete_subnet(@subnet1, DhcpsApi::DHCP_FORCE_FLAG::DhcpFullForce) }
  end
end
