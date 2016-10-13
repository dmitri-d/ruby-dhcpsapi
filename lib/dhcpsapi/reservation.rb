module DhcpsApi
  module Reservation
    include CommonMethods

    # Lists subnet reservations.
    #
    # @example List subnet reservations
    #
    # api.list_reservations('192.168.42.0')
    #
    # @param reservation_ip [String] Reservation ip address
    #
    # @return [Array<Hash>]
    #
    # @see DHCP_IP_RESERVATION_INFO DHCP_IP_RESERVATION_INFO documentation for the list of available fields.
    #
    def list_reservations(subnet_address)
      items, _ = retrieve_items(:dhcp_v4_enum_subnet_reservations, subnet_address, 1024, 0)
      items
    end

    # Creates a new reservation.
    #
    # @example Create a new reservation
    #
    # api.create_reservation('192.168.42.100', '255.255.255.0', '00:01:02:03:04:05', 'test_reservation', 'test reservation comment')
    #
    # @param reservation_ip [String] Reservation ip address
    # @param reservation_subnet_mask [String] Reservation subnet mask
    # @param reservation_mac [String] Reservation mac address
    # @param reservation_name [String] Reservation name
    # @param reservation_comment [String] Reservation comment
    # @param client_type [String] Client type
    #
    # @return [Hash]
    #
    # @see DHCP_IP_RESERVATION_INFO DHCP_IP_RESERVATION_INFO documentation for the list of available fields.
    # @see ClientType ClientType documentation for the list of available client types.
    #
    def create_reservation(reservation_ip, reservation_subnet_mask, reservation_mac, reservation_name, reservation_comment = '', client_type = DhcpsApi::ClientType::CLIENT_TYPE_DHCP)
      ip_as_octets = reservation_ip.split('.').map {|octet| octet.to_i}
      mask_as_octets = reservation_subnet_mask.split('.').map {|octet| octet.to_i}
      subnet_address = (0..3).inject([]) {|all, i| all << (ip_as_octets[i] & mask_as_octets[i])}.join('.')

      subnet_element = create_reservation_subnet_element(subnet_address, reservation_ip, reservation_mac, client_type)
      modify_client(reservation_ip, reservation_subnet_mask, reservation_mac, reservation_name, reservation_comment, 0, client_type)

      subnet_element.as_ruby_struct
    end

    # Deletes subnet reservations.
    #
    # @example Delete subnet reservations
    #
    # api.delete_reservations('192.168.42.42', '192.168.42.0', '00:01:02:03:04:05')
    #
    # @param reservation_ip [String] Reservation ip address
    # @param subnet_address [String] Subnet ip address
    # @param reservation_mac [String] Reservation mac address
    #
    # @return [void]
    #
    def delete_reservation(reservation_ip, subnet_address, reservation_mac, client_type = DhcpsApi::ClientType::CLIENT_TYPE_DHCP)
      delete_subnet_element(subnet_address, DhcpsApi::DHCP_SUBNET_ELEMENT_DATA_V4.build_for_reservation(
          reservation_ip, reservation_mac, client_type))
    end

    # Sets dns configuration for a reservation.
    #
    # @example Enable dynamic dns updates when requested by DHCP client
    #
    # api.set_reservation_dns_config('192.168.42.100', '192.168.42.0', true, false, false, false, false)
    #
    # @param reservation_ip [String] Reservation ip address
    # @param subnet_ip_address [String] Subnet ip address
    # @param enable [Boolean] enable dynamic updates of DNS client information
    # @param update [Boolean] always dynamically update DNS and PTR records
    # @param lookup [Boolean] Discard A and PTR records when lease is deleted
    # @param non_dyn [Boolean] Dynamically update DNS A and PTR records for DHCP clients that do not request updates
    # @param disable_ddns_updates_for_ptr [Boolean] Disable dynamic updates for DNS PTR records
    #
    # @return [void]
    #
    # @see https://technet.microsoft.com/en-gb/library/bb490941.aspx, set dnsconfig section
    #
    def set_reservation_dns_config(reservation_ip, subnet_address, enable, update, lookup, non_dyn, disable_ddns_updates_for_ptr)
      value = enable ? 1 : 0
      value = value | 0x10 if update
      value = value | 4 if lookup
      value = value | 2 if non_dyn
      value = value | 0x40 if disable_ddns_updates_for_ptr

      set_reserved_option_value(81, reservation_ip, subnet_address, DhcpsApi::DHCP_OPTION_DATA_TYPE::DhcpDWordOption, [value])
    end

    def create_reservation_subnet_element(subnet_address, reservation_ip_address, reservation_mac_address, client_type = DhcpsApi::ClientType::CLIENT_TYPE_DHCP)
      add_subnet_element(subnet_address,
                         DhcpsApi::DHCP_SUBNET_ELEMENT_DATA_V4.build_for_reservation(
                             reservation_ip_address, reservation_mac_address, client_type)
      )
    end

    def dhcp_v4_enum_subnet_reservations(subnet_address, preferred_maximum, resume_handle)
      resume_handle_ptr = FFI::MemoryPointer.new(:uint32).put_uint32(0, resume_handle)
      enum_element_info_ptr_ptr = FFI::MemoryPointer.new(:pointer)
      elements_read_ptr = FFI::MemoryPointer.new(:uint32).put_uint32(0, 0)
      elements_total_ptr = FFI::MemoryPointer.new(:uint32).put_uint32(0, 0)

      error = DhcpsApi::Win2012::Reservation.DhcpV4EnumSubnetReservations(
          to_wchar_string(server_ip_address), ip_to_uint32(subnet_address), resume_handle_ptr, preferred_maximum,
          enum_element_info_ptr_ptr, elements_read_ptr, elements_total_ptr)
      return empty_response if error == 259
      if is_error?(error)
        unless (enum_element_info_ptr_ptr.null? || (to_free = enum_element_info_ptr_ptr.read_pointer).null?)
          free_memory(DhcpsApi::DHCP_RESERVATION_INFO_ARRAY.new(to_free))
        end
        raise DhcpsApi::Error.new("Error retrieving reservations from subnet '%s' on '%s'." % [subnet_address, server_ip_address], error)
      end

      reservations_array = DhcpsApi::DHCP_RESERVATION_INFO_ARRAY.new(enum_element_info_ptr_ptr.read_pointer)
      reservation_infos = (0..(reservations_array[:num_elements]-1)).inject([]) do |all, offset|
        all << DhcpsApi::DHCP_IP_RESERVATION_INFO.new((reservations_array[:elements] + offset*FFI::Pointer.size).read_pointer)
      end

      reservations = reservation_infos.map {|reservation_info| reservation_info.as_ruby_struct}
      free_memory(reservations_array)

      [reservations, resume_handle_ptr.get_uint32(0), elements_read_ptr.get_uint32(0), elements_total_ptr.get_uint32(0)]
    end
  end
end
