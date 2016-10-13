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
    @api.add_subnet_element(@subnet1, DhcpsApi::DHCP_SUBNET_ELEMENT_DATA_V4.build_for_subnet_range('192.168.242.20', '192.168.242.29'))
    @api.add_subnet_element(@subnet1, DhcpsApi::DHCP_SUBNET_ELEMENT_DATA_V4.build_for_subnet_range('192.168.242.30', '192.168.242.39'))
    @api.add_subnet_element(@subnet1, DhcpsApi::DHCP_SUBNET_ELEMENT_DATA_V4.build_for_subnet_range('192.168.242.40', '192.168.242.49'))
    @api.add_subnet_element(@subnet1, DhcpsApi::DHCP_SUBNET_ELEMENT_DATA_V4.build_for_subnet_range('192.168.242.50', '192.168.242.59'))
    @api.add_subnet_element(@subnet1, DhcpsApi::DHCP_SUBNET_ELEMENT_DATA_V4.build_for_subnet_range('192.168.242.60', '192.168.242.69'))
    @api.add_subnet_element(@subnet1, DhcpsApi::DHCP_SUBNET_ELEMENT_DATA_V4.build_for_subnet_range('192.168.242.70', '192.168.242.79'))

    reservations = @api.list_subnet_elements(@subnet1, DhcpsApi::DHCP_SUBNET_ELEMENT_TYPE::DhcpReservedIps)
    assert_equal Set.new(['192.168.242.100', '192.168.242.101', '192.168.242.102', '192.168.242.103', '192.168.242.104', '192.168.242.105']),
                 Set.new(reservations.map {|r| r[:element][:reserved_ip_address]})
    assert_equal Set.new(['00:01:02:03:04:01', '00:01:02:03:04:02', '00:01:02:03:04:03', '00:01:02:03:04:04', '00:01:02:03:04:05', '00:01:02:03:04:06', ]),
                 Set.new(reservations.map {|r| r[:element][:reserved_for_client]})

    ranges = @api.list_subnet_elements(@subnet1, DhcpsApi::DHCP_SUBNET_ELEMENT_TYPE::DhcpIpRanges)
    assert_equal Set.new([{:start_address => '192.168.242.10', :end_address => '192.168.242.19'},
                          {:start_address => '192.168.242.20', :end_address => '192.168.242.29'},
                          {:start_address => '192.168.242.30', :end_address => '192.168.242.39'},
                          {:start_address => '192.168.242.40', :end_address => '192.168.242.49'},
                          {:start_address => '192.168.242.50', :end_address => '192.168.242.59'},
                          {:start_address => '192.168.242.60', :end_address => '192.168.242.69'},
                          {:start_address => '192.168.242.70', :end_address => '192.168.242.79'}]), Set.new(ranges)

    @api.delete_subnet_element(@subnet1, DhcpsApi::DHCP_SUBNET_ELEMENT_DATA_V4.build_for_reservation('192.168.242.100', '00:01:02:03:04:01', DhcpsApi::ClientType::CLIENT_TYPE_DHCP))
    @api.delete_subnet_element(@subnet1, DhcpsApi::DHCP_SUBNET_ELEMENT_DATA_V4.build_for_reservation('192.168.242.101', '00:01:02:03:04:02', DhcpsApi::ClientType::CLIENT_TYPE_DHCP))
    @api.delete_subnet_element(@subnet1, DhcpsApi::DHCP_SUBNET_ELEMENT_DATA_V4.build_for_reservation('192.168.242.102', '00:01:02:03:04:03', DhcpsApi::ClientType::CLIENT_TYPE_DHCP))
    @api.delete_subnet_element(@subnet1, DhcpsApi::DHCP_SUBNET_ELEMENT_DATA_V4.build_for_reservation('192.168.242.103', '00:01:02:03:04:04', DhcpsApi::ClientType::CLIENT_TYPE_DHCP))
    @api.delete_subnet_element(@subnet1, DhcpsApi::DHCP_SUBNET_ELEMENT_DATA_V4.build_for_reservation('192.168.242.104', '00:01:02:03:04:05', DhcpsApi::ClientType::CLIENT_TYPE_DHCP))
    @api.delete_subnet_element(@subnet1, DhcpsApi::DHCP_SUBNET_ELEMENT_DATA_V4.build_for_reservation('192.168.242.105', '00:01:02:03:04:06', DhcpsApi::ClientType::CLIENT_TYPE_DHCP))

    @api.delete_subnet_element(@subnet1, DhcpsApi::DHCP_SUBNET_ELEMENT_DATA_V4.build_for_subnet_range('192.168.242.10', '192.168.242.19'))
    @api.delete_subnet_element(@subnet1, DhcpsApi::DHCP_SUBNET_ELEMENT_DATA_V4.build_for_subnet_range('192.168.242.20', '192.168.242.29'))
    @api.delete_subnet_element(@subnet1, DhcpsApi::DHCP_SUBNET_ELEMENT_DATA_V4.build_for_subnet_range('192.168.242.30', '192.168.242.39'))
    @api.delete_subnet_element(@subnet1, DhcpsApi::DHCP_SUBNET_ELEMENT_DATA_V4.build_for_subnet_range('192.168.242.40', '192.168.242.49'))
    @api.delete_subnet_element(@subnet1, DhcpsApi::DHCP_SUBNET_ELEMENT_DATA_V4.build_for_subnet_range('192.168.242.50', '192.168.242.59'))
    @api.delete_subnet_element(@subnet1, DhcpsApi::DHCP_SUBNET_ELEMENT_DATA_V4.build_for_subnet_range('192.168.242.60', '192.168.242.69'))
    @api.delete_subnet_element(@subnet1, DhcpsApi::DHCP_SUBNET_ELEMENT_DATA_V4.build_for_subnet_range('192.168.242.70', '192.168.242.79'))

    assert_equal 0, @api.list_subnet_elements(@subnet1, DhcpsApi::DHCP_SUBNET_ELEMENT_TYPE::DhcpReservedIps).size
    assert_equal 0, @api.list_subnet_elements(@subnet1, DhcpsApi::DHCP_SUBNET_ELEMENT_TYPE::DhcpIpRanges).size
  ensure
    ignore_exceptions { @api.delete_subnet(@subnet1, DhcpsApi::DHCP_FORCE_FLAG::DhcpFullForce) }
  end
end
