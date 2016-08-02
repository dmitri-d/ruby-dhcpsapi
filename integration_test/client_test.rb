require 'test_helper'
require 'dhcpsapi'

class ClientTest < Test::Unit::TestCase
  def setup
    @subnet_1 = "192.168.242.0"
    @subnet_2 = "192.168.243.0"
    @api = DhcpsApi::Server.new('127.0.0.1')
  end

  def test_create_list_delete_clients
    @api.create_subnet(@subnet_1, '255.255.255.0', 'subnet one', 'subnet one comment')

    @api.create_client('192.168.242.254', '255.255.255.0', '01:01:02:03:04:05', 'test_client_1',
                       'test client 1 comment', 0)
    @api.create_client('192.168.242.253', '255.255.255.0', '01:01:02:03:04:06', 'test_client_2',
                       'test client 2 comment', 0)
    @api.create_client('192.168.242.252', '255.255.255.0', '01:01:02:03:04:07', 'test_client_3',
                       'test client 3 comment', 0)

    clients = @api.list_clients(@subnet_1)
#    assert clients.any? {|s| s == {:client_ip_address => '192.168.242.254',
#                                   :subnet_mask => '255.255.255.0',
#                                   :client_hardware_address => '01:01:02:03:04:05',
#                                   :client_name => 'test_client_1',
#                                   :client_comment => 'test client 1 comment',
#                                   :client_lease_expires => nil,
#                                   :owner_host => {:ip_address => '127.0.0.1', :netbios_name => '', :host_name => ''},
#                                   :b_client_type => 100,
#                                   :address_state => 1,
#                                   :status => 0,
#                                   :probation_ends => nil,
#                                   :quarantine_capable => false,
#                                   :filter_status => 1,
#                                   :policy_name => ''} }
    assert clients.any? {|s| s[:client_name] == 'test_client_1'}
    assert clients.any? {|s| s[:client_name] == 'test_client_2'}
    assert clients.any? {|s| s[:client_name] == 'test_client_3'}

    assert_equal 'test_client_1', @api.get_client_by_mac_address('192.168.242.0', '01:01:02:03:04:05')[:client_name]
    assert_equal 'test_client_2', @api.get_client_by_ip_address('192.168.242.253')[:client_name]
    assert_equal 'test_client_3', @api.get_client_by_name('test_client_3')[:client_name]

    @api.delete_client_by_ip_address('192.168.242.253')
    @api.delete_client_by_name('test_client_3')
    @api.delete_client_by_mac_address(@subnet_1, '01:01:02:03:04:05')

    assert_equal 0, @api.list_clients(@subnet_1).size
  ensure
    ignore_exceptions { @api.delete_subnet(@subnet_1, DhcpsApi::DHCP_FORCE_FLAG::DhcpFullForce) }
  end
end
