module DhcpsApi
  module SubnetElement
    # Returns a a list of subnet elements.
    #
    # @example List subnet elements
    #
    # api.list_subnet_elements('192.168.42.0', DhcpsApi::DHCP_SUBNET_ELEMENT_TYPE::DhcpReservedIps)
    #
    # @param subnet_address [String] Subnet ip address
    # @param element_type [DHCP_SUBNET_ELEMENT_TYPE] Subnet element type
    #
    # @return [Array<Hash>]
    #
    # @see DHCP_SUBNET_ELEMENT_DATA_V4 DHCP_SUBNET_ELEMENT_DATA_V4 documentation for the list of available fields.
    #
    def list_subnet_elements(subnet_address, element_type)
      items, _ = retrieve_items(:dhcp_enum_subnet_elements_v4, subnet_address, element_type, 1024, 0)
      items
    end

    # Creates a new subnet element.
    #
    # @example Create a new subnet element
    #
    # api.add_subnet_element('192.168.42.0', a_subnet_element)
    #
    # @param subnet_ip_address [String] Subnet ip address
    # @param subnet_element [DHCP_SUBNET_ELEMENT_DATA_V4] Subnet element
    #
    # @return [Hash]
    #
    # @see DHCP_SUBNET_ELEMENT_DATA_V4 DHCP_SUBNET_ELEMENT_DATA_V4 documentation for the list of available fields.
    #
    def add_subnet_element(subnet_address, subnet_element)
      error = DhcpsApi::Win2008::SubnetElement.DhcpAddSubnetElementV4(to_wchar_string(server_ip_address), ip_to_uint32(subnet_address), subnet_element.pointer)
      raise DhcpsApi::Error.new("Error creating subnet element.", error) if error != 0
      subnet_element.as_ruby_struct
    end

    # Deletes subnet element.
    #
    # @example Delete a subnet element
    #
    # api.delete_subnet_element('192.168.42.0', an_existing_subnet_element)
    #
    # @param subnet_ip_address [String] Subnet ip address
    # @param subnet_element [DHCP_SUBNET_ELEMENT_DATA_V4] Subnet element
    #
    # @return [void]
    #
    def delete_subnet_element(subnet_address, subnet_element)
      error = DhcpsApi::Win2008::SubnetElement.DhcpRemoveSubnetElementV4(
          to_wchar_string(server_ip_address),
          ip_to_uint32(subnet_address),
          subnet_element.pointer,
          DhcpsApi::DHCP_FORCE_FLAG::DhcpNoForce)
      raise DhcpsApi::Error.new("Error deleting subnet element.", error) if error != 0
    end

    def dhcp_enum_subnet_elements_v4(subnet_address, element_type, preferred_maximum, resume_handle)
      resume_handle_ptr = FFI::MemoryPointer.new(:uint32).put_uint32(0, resume_handle)
      subnet_element_info_ptr_ptr = FFI::MemoryPointer.new(:pointer)
      elements_read_ptr = FFI::MemoryPointer.new(:uint32).put_uint32(0, 0)
      elements_total_ptr = FFI::MemoryPointer.new(:uint32).put_uint32(0, 0)

      error = DhcpsApi::Win2008::SubnetElement.DhcpEnumSubnetElementsV4(
          to_wchar_string(server_ip_address), ip_to_uint32(subnet_address), element_type, resume_handle_ptr, preferred_maximum,
          subnet_element_info_ptr_ptr, elements_read_ptr, elements_total_ptr)
      return empty_response if error == 259
      if is_error?(error)
        unless (subnet_element_info_ptr_ptr.null? || (to_free = subnet_element_info_ptr_ptr.read_pointer).null?)
          free_memory(DhcpsApi::DHCP_SUBNET_ELEMENT_INFO_ARRAY_V4.new(to_free))
        end
        raise DhcpsApi::Error.new("Error retrieving subnet elements for subnet '%s'." % [subnet_address], error)
      end

      subnet_elements_array = DhcpsApi::DHCP_SUBNET_ELEMENT_INFO_ARRAY_V4.new(subnet_element_info_ptr_ptr.read_pointer)
      subnet_elements = subnet_elements_array.as_ruby_struct
      free_memory(subnet_elements_array)

      [subnet_elements, resume_handle_ptr.get_uint32(0), elements_read_ptr.get_uint32(0), elements_total_ptr.get_uint32(0)]
    end
  end
end

