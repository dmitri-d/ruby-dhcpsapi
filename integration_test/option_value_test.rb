require 'test_helper'
require 'dhcpsapi'
require 'set'

class OptionValueTest < Test::Unit::TestCase
  def setup
    @subnet_1 = "192.168.242.0"
    @api = DhcpsApi::Server.new('127.0.0.1')

    @api.create_subnet(@subnet_1, '255.255.255.0', 'subnet one', 'subnet one comment')
    @api.create_class('test_vendor', 'test class two comment', true, 'test_vendor')

    @api.create_option(223, 'test_option_1', 'test option 1 comment', DhcpsApi::DHCP_OPTION_DATA_TYPE::DhcpStringDataOption, true)
    @api.create_option(224, 'test_option_2', 'test option 2 comment', DhcpsApi::DHCP_OPTION_DATA_TYPE::DhcpStringDataOption, false, 'test_vendor')
    @api.create_option(225, 'test_option_3', 'test option 3 comment', DhcpsApi::DHCP_OPTION_DATA_TYPE::DhcpStringDataOption, false)
    @api.create_option(226, 'test_option_4', 'test option 4 comment', DhcpsApi::DHCP_OPTION_DATA_TYPE::DhcpStringDataOption, false)
    @api.create_option(227, 'test_option_5', 'test option 5 comment', DhcpsApi::DHCP_OPTION_DATA_TYPE::DhcpStringDataOption, false)
    @api.create_option(228, 'test_option_6', 'test option 6 comment', DhcpsApi::DHCP_OPTION_DATA_TYPE::DhcpStringDataOption, false)
  end

  def teardown
    ignore_exceptions { @api.delete_option(223) }
    ignore_exceptions { @api.delete_option(224, 'test_vendor') }
    ignore_exceptions { @api.delete_option(225) }
    ignore_exceptions { @api.delete_option(226) }
    ignore_exceptions { @api.delete_option(227) }
    ignore_exceptions { @api.delete_option(228) }

    ignore_exceptions { @api.delete_class('test_vendor') }
    ignore_exceptions { @api.delete_subnet(@subnet_1, DhcpsApi::DHCP_FORCE_FLAG::DhcpFullForce) }
  end

  def test_create_list_delete_subnet_option_value
    original_option_values = @api.list_subnet_option_values(@subnet_1)
    original_vendor_option_values = @api.list_subnet_option_values(@subnet_1, 'test_vendor')

    @api.set_subnet_option_value(223, @subnet_1, DhcpsApi::DHCP_OPTION_DATA_TYPE::DhcpStringDataOption, ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10'])
    @api.set_subnet_option_value(224, @subnet_1, DhcpsApi::DHCP_OPTION_DATA_TYPE::DhcpStringDataOption, 'another test value', 'test_vendor')
    @api.set_subnet_option_value(225, @subnet_1, DhcpsApi::DHCP_OPTION_DATA_TYPE::DhcpStringDataOption, 'test value')
    @api.set_subnet_option_value(226, @subnet_1, DhcpsApi::DHCP_OPTION_DATA_TYPE::DhcpStringDataOption, 'test_value')
    @api.set_subnet_option_value(227, @subnet_1, DhcpsApi::DHCP_OPTION_DATA_TYPE::DhcpStringDataOption, 'test_value')
    @api.set_subnet_option_value(228, @subnet_1, DhcpsApi::DHCP_OPTION_DATA_TYPE::DhcpStringDataOption, 'test_value')

    option_values = @api.list_subnet_option_values(@subnet_1).map {|o_v| o_v[:option_id]}
    assert_equal Set.new([223, 225, 226, 227, 228]), Set.new(option_values - original_option_values.map {|o_v| o_v[:option_id]})
    vendor_option_values = @api.list_subnet_option_values(@subnet_1, 'test_vendor').map {|o_v| o_v[:option_id]}
    assert_equal [224], (vendor_option_values - original_vendor_option_values.map {|o_v| o_v[:option_id]})

    assert_equal({:option_id => 223, :value => [
        {:option_type => 5, :element => '1'},
        {:option_type => 5, :element => '2'},
        {:option_type => 5, :element => '3'},
        {:option_type => 5, :element => '4'},
        {:option_type => 5, :element => '5'},
        {:option_type => 5, :element => '6'},
        {:option_type => 5, :element => '7'},
        {:option_type => 5, :element => '8'},
        {:option_type => 5, :element => '9'},
        {:option_type => 5, :element => '10'}]}, @api.get_subnet_option_value(223, @subnet_1))
    # for some reason vendor options ids come back with 8th bit set to 1
    assert_equal({:option_id => 224 + 256, :value => [{:option_type => 5, :element => 'another test value'}]}, @api.get_subnet_option_value(224, @subnet_1, 'test_vendor'))
    assert_equal({:option_id => 225, :value => [{:option_type => 5, :element => 'test value'}]}, @api.get_subnet_option_value(225, @subnet_1))

    @api.remove_subnet_option_value(223, @subnet_1)
    @api.remove_subnet_option_value(224, @subnet_1, 'test_vendor')
    @api.remove_subnet_option_value(225, @subnet_1)
    @api.remove_subnet_option_value(226, @subnet_1)
    @api.remove_subnet_option_value(227, @subnet_1)
    @api.remove_subnet_option_value(228, @subnet_1)

    assert_equal original_option_values, @api.list_subnet_option_values(@subnet_1)
    assert_equal original_vendor_option_values, @api.list_subnet_option_values(@subnet_1, 'test_vendor')
  end

  def test_create_list_delete_reserved_option_value
    client_ip = '192.168.242.254'
    @api.create_reservation(client_ip, '255.255.255.0', '00:01:02:03:04:05', 'test_reservation_1', 'test client 1 comment')

    original_option_values = @api.list_reserved_option_values(client_ip, @subnet_1)
    original_vendor_option_values = @api.list_reserved_option_values(client_ip, @subnet_1, 'test_vendor')

    @api.set_reserved_option_value(223, client_ip, @subnet_1, DhcpsApi::DHCP_OPTION_DATA_TYPE::DhcpStringDataOption, ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10'])
    @api.set_reserved_option_value(224, client_ip, @subnet_1, DhcpsApi::DHCP_OPTION_DATA_TYPE::DhcpStringDataOption, 'another test value', 'test_vendor')
    @api.set_reserved_option_value(225, client_ip, @subnet_1, DhcpsApi::DHCP_OPTION_DATA_TYPE::DhcpStringDataOption, 'test value')

    option_values = @api.list_reserved_option_values(client_ip, @subnet_1).map {|o_v| o_v[:option_id]}
    assert_equal Set.new([223, 225]), Set.new(option_values - original_option_values.map {|o_v| o_v[:option_id]})
    vendor_option_values = @api.list_reserved_option_values(client_ip, @subnet_1, 'test_vendor').map {|o_v| o_v[:option_id]}
    assert_equal [224], (vendor_option_values - original_vendor_option_values.map {|o_v| o_v[:option_id]})

    assert_equal({:option_id => 224 + 256, :value => [{:option_type => 5, :element => 'another test value'}]}, @api.get_reserved_option_value(224, client_ip, @subnet_1, 'test_vendor'))
    assert_equal({:option_id => 225, :value => [{:option_type => 5, :element => 'test value'}]}, @api.get_reserved_option_value(225, client_ip, @subnet_1))

    @api.remove_reserved_option_value(223, client_ip, @subnet_1)
    @api.remove_reserved_option_value(224, client_ip, @subnet_1, 'test_vendor')
    @api.remove_reserved_option_value(225, client_ip, @subnet_1)

    assert_equal original_option_values, @api.list_reserved_option_values(client_ip, @subnet_1)
    assert_equal original_vendor_option_values, @api.list_reserved_option_values(client_ip, @subnet_1, 'test_vendor')
  end

  def test_create_list_delete_multicast_option_value
  end

  def test_create_list_delete_default_scope_option_value
  end
end
