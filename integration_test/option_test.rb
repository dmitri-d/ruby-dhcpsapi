require 'test_helper'
require 'dhcpsapi'

class OptionTest < Test::Unit::TestCase
  def setup
    @subnet_1 = "192.168.242.0"
    @subnet_2 = "192.168.243.0"
    @api = DhcpsApi::Server.new('127.0.0.1')
  end


  def test_create_list_delete_option
    @api.create_class('test_vendor_class', 'test vendor class', true, 'test class two data')

    @api.create_option(223, 'test_option_3', 'test option 4 comment', DhcpsApi::DHCP_OPTION_DATA_TYPE::DhcpStringDataOption, false)
    @api.create_option(225, 'test_vendor_option_3', 'test vendor option 3 comment', DhcpsApi::DHCP_OPTION_DATA_TYPE::DhcpStringDataOption, false, 'test_vendor_class')
    @api.create_option(226, 'test_option_with_default_value_6', 'test option 4 comment', DhcpsApi::DHCP_OPTION_DATA_TYPE::DhcpByteOption, false, nil, 2)
    @api.create_option(227, 'test_option_with_array_default_value_8', 'test option 5 comment', DhcpsApi::DHCP_OPTION_DATA_TYPE::DhcpStringDataOption, true, nil,
                       'default_value', 'default_value_2')

    options = @api.list_options
    assert options.any? {|o| o[:option_id] == 223}
    assert options.any? {|o| o[:option_id] == 226}
    assert options.any? {|o| o[:option_id] == 227}

    vendor_options = @api.list_options(nil, 'test_vendor_class')
    assert vendor_options.any? {|o| o[:option_id] == 225}

    @api.delete_option(223)
    @api.delete_option(225, 'test_vendor_class')
    @api.delete_option(226)
    @api.delete_option(227)
  ensure
    ignore_exceptions { @api.delete_class('test_vendor_class') }
  end
end
