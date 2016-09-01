module DhcpsApi
  module Client
    def list_clients(subnet_address)
      items, _ = retrieve_items(:dhcp_v4_enum_subnet_clients, subnet_address, 1024, 0)
      items
    end

    # TODO: parse lease time and owner_host
    def create_client(client_ip_address, client_subnet_mask, client_mac_address,
                      client_name, client_comment, lease_expires, client_type = DhcpsApi::ClientType::CLIENT_TYPE_BOTH)
      to_create = DhcpsApi::DHCP_CLIENT_INFO_V4.new
      to_create[:client_ip_address] = ip_to_uint32(client_ip_address)
      to_create[:subnet_mask] = ip_to_uint32(client_subnet_mask)
      to_create[:client_hardware_address].intialize_with_mac_address(client_mac_address)

      to_create[:client_name] = FFI::MemoryPointer.from_string(to_wchar_string(client_name))
      to_create[:client_comment] = FFI::MemoryPointer.from_string(to_wchar_string(client_comment))

      to_create[:client_lease_expires][:dw_low_date_time] = 0
      to_create[:client_lease_expires][:dw_high_date_time] = 0
      to_create[:client_type] = client_type

      error = DhcpsApi::Win2008::Client.DhcpCreateClientInfoV4(to_wchar_string(server_ip_address), to_create.pointer)
      raise DhcpsApi::Error.new("Error creating client.", error) if error != 0

      to_create.as_ruby_struct
    end

    # TODO: parse lease time and owner_host
    def modify_client(client_ip_address, client_subnet_mask, client_mac_address,
                      client_name, client_comment, lease_expires, client_type = DhcpsApi::ClientType::CLIENT_TYPE_BOTH)
      to_modify = DhcpsApi::DHCP_CLIENT_INFO_V4.new
      to_modify[:client_ip_address] = ip_to_uint32(client_ip_address)
      to_modify[:subnet_mask] = ip_to_uint32(client_subnet_mask)
      to_modify[:client_hardware_address].intialize_with_mac_address(client_mac_address)

      to_modify[:client_name] = FFI::MemoryPointer.from_string(to_wchar_string(client_name))
      to_modify[:client_comment] = FFI::MemoryPointer.from_string(to_wchar_string(client_comment))

      to_modify[:client_lease_expires][:dw_low_date_time] = 0
      to_modify[:client_lease_expires][:dw_high_date_time] = 0
      to_modify[:client_type] = client_type

      error = DhcpsApi::Win2008::Client.DhcpSetClientInfoV4(to_wchar_string(server_ip_address), to_modify.pointer)
      raise DhcpsApi::Error.new("Error modifying client.", error) if error != 0

      to_modify.as_ruby_struct
    end

    def get_client_subnet(client)
      uint32_to_ip(ip_to_uint32(client[:client_ip_address]) & ip_to_uint32(client[:subnet_mask]))
    end

    def get_client_by_mac_address(subnet_address, client_mac_address)
      search_info = DhcpsApi::DHCP_SEARCH_INFO.new
      search_info[:search_type] = DhcpsApi::DHCP_SEARCH_INFO_TYPE::DhcpClientHardwareAddress
      search_info[:search_info][:client_hardware_address].initialize_with_subnet_and_mac_addresses(subnet_address, client_mac_address)

      get_client(search_info, client_mac_address)
    end

    def get_client_by_ip_address(client_ip_address)
      search_info = DhcpsApi::DHCP_SEARCH_INFO.new
      search_info[:search_type] = DhcpsApi::DHCP_SEARCH_INFO_TYPE::DhcpClientIpAddress
      search_info[:search_info][:client_ip_address] = ip_to_uint32(client_ip_address)

      get_client(search_info, client_ip_address)
    end

    def get_client_by_name(client_name)
      search_info = DhcpsApi::DHCP_SEARCH_INFO.new
      search_info[:search_type] = DhcpsApi::DHCP_SEARCH_INFO_TYPE::DhcpClientName
      search_info[:search_info][:client_name] = FFI::MemoryPointer.from_string(to_wchar_string(client_name))

      get_client(search_info, client_name)
    end

    def delete_client_by_mac_address(subnet_address, client_mac_address)
      search_info = DhcpsApi::DHCP_SEARCH_INFO.new
      search_info[:search_type] = DhcpsApi::DHCP_SEARCH_INFO_TYPE::DhcpClientHardwareAddress
      search_info[:search_info][:client_hardware_address].initialize_with_subnet_and_mac_addresses(subnet_address, client_mac_address)

      error = DhcpsApi::Win2008::Client.DhcpDeleteClientInfo(to_wchar_string(server_ip_address), search_info.pointer)
      raise DhcpsApi::Error.new("Error deleting client.", error) if error != 0
    end

    def delete_client_by_ip_address(client_ip_address)
      search_info = DhcpsApi::DHCP_SEARCH_INFO.new
      search_info[:search_type] = DhcpsApi::DHCP_SEARCH_INFO_TYPE::DhcpClientIpAddress
      search_info[:search_info][:client_ip_address] = ip_to_uint32(client_ip_address)

      error = DhcpsApi::Win2008::Client.DhcpDeleteClientInfo(to_wchar_string(server_ip_address), search_info.pointer)
      raise DhcpsApi::Error.new("Error deleting client.", error) if error != 0
    end

    def delete_client_by_name(client_name)
      search_info = DhcpsApi::DHCP_SEARCH_INFO.new
      search_info[:search_type] = DhcpsApi::DHCP_SEARCH_INFO_TYPE::DhcpClientName
      search_info[:search_info][:client_name] = FFI::MemoryPointer.from_string(to_wchar_string(client_name))

      error = DhcpsApi::Win2008::Client.DhcpDeleteClientInfo(to_wchar_string(server_ip_address), search_info.pointer)
      raise DhcpsApi::Error.new("Error deleting client.", error) if error != 0
    end

    private
    def get_client(search_info, client_id)
      client_info_ptr_ptr = FFI::MemoryPointer.new(:pointer)

      error = DhcpsApi::Win2008::Client.DhcpGetClientInfoV4(to_wchar_string(server_ip_address), search_info.pointer, client_info_ptr_ptr)
      if is_error?(error)
        unless (client_info_ptr_ptr.null? || (to_free = client_info_ptr_ptr.read_pointer).null?)
          free_memory(DhcpsApi::DHCP_CLIENT_INFO_V4.new(to_free))
        end
        raise DhcpsApi::Error.new("Error retrieving client '%s'." % [client_id], error)
      end

      client_info = DhcpsApi::DHCP_CLIENT_INFO_V4.new(client_info_ptr_ptr.read_pointer)
      to_return = client_info.as_ruby_struct

      free_memory(client_info)
      to_return
    end

    def dhcp_v4_enum_subnet_clients(subnet_address, preferred_maximum, resume_handle)
      resume_handle_ptr = FFI::MemoryPointer.new(:uint32).put_uint32(0, resume_handle)
      client_info_ptr_ptr = FFI::MemoryPointer.new(:pointer)
      elements_read_ptr = FFI::MemoryPointer.new(:uint32).put_uint32(0, 0)
      elements_total_ptr = FFI::MemoryPointer.new(:uint32).put_uint32(0, 0)

      error = DhcpsApi::Win2012::Client.DhcpV4EnumSubnetClients(
          to_wchar_string(server_ip_address), ip_to_uint32(subnet_address), resume_handle_ptr, preferred_maximum,
          client_info_ptr_ptr, elements_read_ptr, elements_total_ptr)
      return empty_response if error == 259
      if is_error?(error)
        unless (client_info_ptr_ptr.null? || (to_free = client_info_ptr_ptr.read_pointer).null?)
          free_memory(DhcpsApi::DHCP_CLIENT_INFO_PB_ARRAY.new(to_free))
        end
        raise DhcpsApi::Error.new("Error retrieving clients from subnet '%s'." % [subnet_address], error)
      end

      leases_array = DhcpsApi::DHCP_CLIENT_INFO_PB_ARRAY.new(client_info_ptr_ptr.read_pointer)
      lease_infos = (0..(leases_array[:num_elements]-1)).inject([]) do |all, offset|
        all << DhcpsApi::DHCP_CLIENT_INFO_PB.new((leases_array[:clients] + offset*FFI::Pointer.size).read_pointer)
      end

      leases = lease_infos.map {|lease_info| lease_info.as_ruby_struct}
      free_memory(leases_array)

      [leases, resume_handle_ptr.get_uint32(0), elements_read_ptr.get_uint32(0), elements_total_ptr.get_uint32(0)]
    end
  end
end
