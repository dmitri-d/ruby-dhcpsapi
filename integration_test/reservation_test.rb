require 'test_helper'
require 'dhcpsapi'

class ReservationTest < Test::Unit::TestCase
  def setup
    @subnet_1 = "192.168.242.0"
    @subnet_2 = "192.168.243.0"
    @api = DhcpsApi::Server.new('127.0.0.1')
  end

  def test_create_list_delete_reservations
    @api.create_subnet(@subnet_1, '255.255.255.0', 'subnet one', 'subnet one comment')

    @api.create_reservation('192.168.242.254', '255.255.255.0', '00:01:02:03:04:05', 'test_reservation_1', 'test client 1 comment')
    @api.create_reservation('192.168.242.253', '255.255.255.0', '00:01:02:03:04:06', 'test_reservation_2', 'test client 2 comment')
    @api.create_reservation('192.168.242.252', '255.255.255.0', '00:01:02:03:04:07', 'test_reservation_3', 'test client 3 comment')

    clients = @api.list_reservations(@subnet_1)
    assert clients.any? {|s| s[:reserved_for_client] == '00:01:02:03:04:05'}
    assert clients.any? {|s| s[:reserved_for_client] == '00:01:02:03:04:06'}
    assert clients.any? {|s| s[:reserved_for_client] == '00:01:02:03:04:07'}

    @api.delete_reservation('192.168.242.0', '192.168.242.254', '00:01:02:03:04:05')
    @api.delete_reservation('192.168.242.0', '192.168.242.253', '00:01:02:03:04:06')
    @api.delete_reservation('192.168.242.0', '192.168.242.252', '00:01:02:03:04:07')

    assert_equal 0, @api.list_reservations(@subnet_1).size
  ensure
    ignore_exceptions { @api.delete_subnet(@subnet_1, DhcpsApi::DHCP_FORCE_FLAG::DhcpFullForce) }
  end
end
