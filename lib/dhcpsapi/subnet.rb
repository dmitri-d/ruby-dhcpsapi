module DhcpsApi
  module Subnet
    include CommonMethods

    def list_subnets
      subnets = enum_subnets
      subnets.map {|subnet| dhcp_get_subnet_info(subnet)}
    end

    def get_subnet(subnet_address)
      dhcp_get_subnet_info(ip_to_uint32(subnet_address))
    end

    def create_subnet(subnet_address, subnet_mask, subnet_name, subnet_comment)
      subnet_info = DhcpsApi::DHCP_SUBNET_INFO.new
      subnet_info[:subnet_address] = ip_to_uint32(subnet_address)
      subnet_info[:subnet_mask] = ip_to_uint32(subnet_mask)
      subnet_info[:subnet_name] = FFI::MemoryPointer.from_string(to_wchar_string(subnet_name))
      subnet_info[:subnet_comment] = FFI::MemoryPointer.from_string(to_wchar_string(subnet_comment))

      error = DhcpsApi::Win2008::Subnet.DhcpCreateSubnet(to_wchar_string(server_ip_address), ip_to_uint32(subnet_address), subnet_info.pointer)
      raise DhcpsApi::Error.new("Error creating subnet.", error) if error != 0

      subnet_info.as_ruby_struct
    end

    def delete_subnet(subnet_address, force_flag = DhcpsApi::DHCP_FORCE_FLAG::DhcpNoForce)
      error = DhcpsApi::Win2008::Subnet.DhcpDeleteSubnet(to_wchar_string(server_ip_address), ip_to_uint32(subnet_address), force_flag)
      raise DhcpsApi::Error.new("Error deleting subnet.", error) if error != 0
    end

    def add_subnet_ip_range(subnet_address, start_address, end_address)
      subnet_element = DhcpsApi::DHCP_SUBNET_ELEMENT_DATA_V4.new
      subnet_element[:element_type] = DhcpsApi::DHCP_SUBNET_ELEMENT_TYPE::DhcpIpRanges
      subnet_element[:element][:ip_range] = (ip_range = DhcpsApi::DHCP_IP_RANGE.new).pointer
      ip_range[:start_address] = ip_to_uint32(start_address)
      ip_range[:end_address] = ip_to_uint32(end_address)

      error = DhcpsApi::Win2008::SubnetElement.DhcpAddSubnetElementV4(to_wchar_string(server_ip_address), ip_to_uint32(subnet_address), subnet_element.pointer)
      raise DhcpsApi::Error.new("Error adding a subnet range to '%s'." % [subnet_address], error) if error != 0

      subnet_element.as_ruby_struct
    end

    def delete_subnet_ip_range(subnet_address, start_address, end_address)
      to_delete = DhcpsApi::DHCP_SUBNET_ELEMENT_DATA_V4.new
      to_delete[:element_type] = DhcpsApi::DHCP_SUBNET_ELEMENT_TYPE::DhcpIpRanges
      to_delete[:element][:ip_range] = (ip_range = DhcpsApi::DHCP_IP_RANGE.new).pointer
      ip_range[:start_address] = ip_to_uint32(start_address)
      ip_range[:end_address] = ip_to_uint32(end_address)

      error = DhcpsApi::Win2008::SubnetElement.DhcpRemoveSubnetElementV4(
          to_wchar_string(server_ip_address),
          ip_to_uint32(subnet_address),
          to_delete.pointer,
          DhcpsApi::DHCP_FORCE_FLAG::DhcpNoForce)
      raise DhcpsApi::Error.new("Error deleting reservation.", error) if error != 0
    end

    def enum_subnets
      items, _ = retrieve_items(:dhcp_enum_subnets, 1024, 0)
      items
    end

    # expects subnet_address is DHCP_IP_ADDRESS
    def dhcp_get_subnet_info(subnet_address)
      subnet_info_ptr_ptr = FFI::MemoryPointer.new(:pointer)

      error = DhcpsApi::Win2008::Subnet.DhcpGetSubnetInfo(to_wchar_string(server_ip_address), subnet_address, subnet_info_ptr_ptr)
      if is_error?(error)
        unless (subnet_info_ptr_ptr.null? || (to_free = subnet_info_ptr_ptr.read_pointer).null?)
          free_memory(DhcpsApi::DHCP_SUBNET_INFO.new(to_free))
        end
        raise DhcpsApi::Error.new("Error retrieving subnet '%s' information from '%s'." % [uint32_to_ip(subnet_address), server_ip_address], error)
      end

      subnet_info = DhcpsApi::DHCP_SUBNET_INFO.new(subnet_info_ptr_ptr.read_pointer)
      to_return = subnet_info.as_ruby_struct
      free_memory(subnet_info)

      to_return
    end

    def dhcp_enum_subnets(preferred_maximium, old_resume_handle)
      resume_handle_ptr = FFI::MemoryPointer.new(:uint32).put_uint32(0, old_resume_handle)
      dhcp_ip_array_ptr_ptr = FFI::MemoryPointer.new(:pointer)
      elements_read_ptr = FFI::MemoryPointer.new(:uint32).put_uint32(0, 0)
      elements_total_ptr = FFI::MemoryPointer.new(:uint32).put_uint32(0, 0)

      error = DhcpsApi::Win2008::Subnet.DhcpEnumSubnets(to_wchar_string(server_ip_address), resume_handle_ptr, preferred_maximium, dhcp_ip_array_ptr_ptr, elements_read_ptr, elements_total_ptr)
      return empty_response if error == 259
      if is_error?(error)
        unless (dhcp_ip_array_ptr_ptr.null? || (to_free = dhcp_ip_array_ptr_ptr.read_pointer).null?)
          free_memory(DhcpsApi::DHCP_IP_ARRAY.new(to_free))
        end
        raise DhcpsApi::Error.new("Error when enumerating subnets on %s." % [server_ip_address], error)
      end

      dhcp_ip_array = DhcpsApi::DHCP_IP_ARRAY.new(dhcp_ip_array_ptr_ptr.read_pointer)
      subnet_ips = dhcp_ip_array[:elements].read_array_of_type(:uint32, :read_uint32, dhcp_ip_array[:num_elements])
      free_memory(dhcp_ip_array)

      [subnet_ips, resume_handle_ptr.get_uint32(0), elements_read_ptr.get_uint32(0), elements_total_ptr.get_uint32(0)]
    end
  end
end
