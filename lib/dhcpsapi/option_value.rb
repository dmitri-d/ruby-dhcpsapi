module DhcpsApi
  module OptionValue
    # Sets an option value for a subnet.
    #
    # @example Set a subnet option value
    #
    # api.set_subnet_option_value(3, '192.168.42.0', DhcpsApi::DHCP_OPTION_DATA_TYPE::DhcpIpAddressOption, ['192.168.42.1', '192.168.42.2'])
    #
    # @param option_id [Fixnum] Option id
    # @param subnet_ip_address [String] Subnet ip address
    # @param option_type [DHCP_OPTION_DATA_TYPE] Option type
    # @param values [Array] Array of values (or an array of one element if option supports one value only)
    # @param vendor_name [String, nil] The name of the vendor class (for vendor options)
    #
    # @return [void]
    #
    # @see DHCP_OPTION_DATA_TYPE DHCP_OPTION_DATA_TYPE documentation for the list of available option types.
    #
    def set_subnet_option_value(option_id, subnet_ip_address, option_type, values, vendor_name = nil)
      dhcp_set_option_value_v5(
          option_id,
          vendor_name,
          DhcpsApi::DHCP_OPTION_SCOPE_INFO.build_for_subnet_scope(subnet_ip_address),
          option_type,
          values.is_a?(Array) ? values : [values]
      )
    end

    # Sets an option value for a reservation.
    #
    # @example Set a reservation option value
    #
    # api.set_reservationt_option_value(3, '192.168.42.100', '192.168.42.0', DhcpsApi::DHCP_OPTION_DATA_TYPE::DhcpIpAddressOption, ['192.168.42.1', '192.168.42.2'])
    #
    # @param option_id [Fixnum] Option id
    # @param subnet_ip_address [String] Reservation ip address
    # @param subnet_ip_address [String] Subnet ip address
    # @param option_type [DHCP_OPTION_DATA_TYPE] Option type
    # @param values [Array] array of values (or an array of one element if option supports one value only)
    # @param vendor_name [String, nil] The name of the vendor class (for vendor options)
    #
    # @return [void]
    #
    # @see DHCP_OPTION_DATA_TYPE DHCP_OPTION_DATA_TYPE documentation for the list of available option types.
    #
    def set_reserved_option_value(option_id, reserved_ip_address, subnet_ip_address, option_type, values, vendor_name = nil)
      dhcp_set_option_value_v5(
          option_id,
          vendor_name,
          DhcpsApi::DHCP_OPTION_SCOPE_INFO.build_for_reserved_scope(reserved_ip_address, subnet_ip_address),
          option_type,
          values.is_a?(Array) ? values : [values]
      )
    end

    # Sets an option value for a multicast scope.
    #
    # @example Set a multicast scope option value
    #
    # api.set_multicast_option_value(26, '224.0.0.0', DhcpsApi::DHCP_OPTION_DATA_TYPE::DhcpWordOption, [1500])
    #
    # @param option_id [Fixnum] Option id
    # @param multicast_scope_name [String] Multicast scope ip address
    # @param option_type [DHCP_OPTION_DATA_TYPE] Option type
    # @param values [Array] array of values (or an array of one element if option supports one value only)
    # @param vendor_name [String, nil] The name of the vendor class (for vendor options)
    #
    # @return [void]
    #
    # @see DHCP_OPTION_DATA_TYPE DHCP_OPTION_DATA_TYPE documentation for the list of available option types.
    #
    def set_multicast_option_value(option_id, multicast_scope_name, option_type, values, vendor_name = nil)
      dhcp_set_option_value_v5(
          option_id,
          vendor_name,
          DhcpsApi::DHCP_OPTION_SCOPE_INFO.build_for_multicast_scope(multicast_scope_name),
          option_type,
          values.is_a?(Array) ? values : [values]
      )
    end

    # Sets an option value for a default scope.
    #
    # @example Set an option value
    #
    # api.set_option_value(26, DhcpsApi::DHCP_OPTION_DATA_TYPE::DhcpWordOption, [1500])
    #
    # @param option_id [Fixnum] Option id
    # @param option_type [DHCP_OPTION_DATA_TYPE] Option type
    # @param values [Array] array of values (or an array of one element if option supports one value only)
    # @param vendor_name [String, nil] The name of the vendor class (for vendor options)
    #
    # @return [void]
    #
    # @see DHCP_OPTION_DATA_TYPE DHCP_OPTION_DATA_TYPE documentation for the list of available option types.
    #
    def set_option_value(option_id, option_type, values, vendor_name = nil)
      dhcp_set_option_value_v5(
          option_id,
          vendor_name,
          DhcpsApi::DHCP_OPTION_SCOPE_INFO.build_for_default_scope,
          option_type,
          values.is_a?(Array) ? values : [values]
      )
    end

    # Retrieves an option value for a subnet.
    #
    # @example Retrieve a subnet option value
    #
    # api.get_subnet_option_value(3, '192.168.42.0')
    #
    # @param option_id [Fixnum] Option id
    # @param subnet_ip_address [String] Subnet ip address
    # @param vendor_name [String, nil] The name of the vendor class (for vendor options)
    #
    # @return [Hash]
    #
    # @see DHCP_OPTION_VALUE DHCP_OPTION_VALUE documentation for the list of available fields.
    #
    def get_subnet_option_value(option_id, subnet_ip_address, vendor_name = nil)
      dhcp_get_option_value_v5(
          option_id,
          vendor_name,
          DhcpsApi::DHCP_OPTION_SCOPE_INFO.build_for_subnet_scope(subnet_ip_address)
      )
    end

    # Retrieves an option value for a reservation.
    #
    # @example Retrieve a reservation option value
    #
    # api.get_reserved_option_value(3, '192.168.42.100', 192.168.42.0')
    #
    # @param option_id [Fixnum] Option id
    # @param reserved_ip_address [String] Reservation ip address
    # @param subnet_ip_address [String] Subnet ip address
    # @param vendor_name [String, nil] The name of the vendor class (for vendor options)
    #
    # @return [Hash]
    #
    # @see DHCP_OPTION_VALUE DHCP_OPTION_VALUE documentation for the list of available fields.
    #
    def get_reserved_option_value(option_id, reserved_ip_address, subnet_ip_address, vendor_name = nil)
      dhcp_get_option_value_v5(
          option_id,
          vendor_name,
          DhcpsApi::DHCP_OPTION_SCOPE_INFO.build_for_reserved_scope(reserved_ip_address, subnet_ip_address)
      )
    end


    # Retrieves an option value for a multicast scope.
    #
    # @example Retrieve a multicast scope option value
    #
    # api.get_multicast_option_value(3, '224.0.0.0')
    #
    # @param option_id [Fixnum] Option id
    # @param multicast_scope_name [String] Multicast scope ip address
    # @param vendor_name [String, nil] The name of the vendor class (for vendor options)
    #
    # @return [Hash]
    #
    # @see DHCP_OPTION_VALUE DHCP_OPTION_VALUE documentation for the list of available fields.
    #
    def get_multicast_option_value(option_id, multicast_scope_name, vendor_name = nil)
      dhcp_get_option_value_v5(
          option_id,
          vendor_name,
          DhcpsApi::DHCP_OPTION_SCOPE_INFO.build_for_multicast_scope(multicast_scope_name)
      )
    end

    # Retrieves an option value for a default scope.
    #
    # @example Retrieve an option value
    #
    # api.get_option_value(3)
    #
    # @param option_id [Fixnum] Option id
    # @param vendor_name [String, nil] The name of the vendor class (for vendor options)
    #
    # @return [Hash]
    #
    # @see DHCP_OPTION_VALUE DHCP_OPTION_VALUE documentation for the list of available fields.
    #
    def get_option_value(option_id, vendor_name = nil)
      dhcp_get_option_value_v5(
          option_id,
          vendor_name,
          DhcpsApi::DHCP_OPTION_SCOPE_INFO.build_for_default_scope
      )
    end

    # Removes an option value for a subnet.
    #
    # @example Remove a subnet option value
    #
    # api.remove_subnet_option_value(3, '192.168.42.0')
    #
    # @param option_id [Fixnum] Option id
    # @param subnet_ip_address [String] Subnet ip address
    # @param vendor_name [String, nil] The name of the vendor class (for vendor options)
    #
    # @return [void]
    #
    def remove_subnet_option_value(option_id, subnet_ip_address, vendor_name = nil)
      dhcp_remove_option_value_v5(
          option_id,
          vendor_name,
          DhcpsApi::DHCP_OPTION_SCOPE_INFO.build_for_subnet_scope(subnet_ip_address)
      )
    end

    # Removes an option value for a reservation.
    #
    # @example Remove a reservation option value
    #
    # api.remove_reserved_option_value(3, '192.168.42.100', 192.168.42.0')
    #
    # @param option_id [Fixnum] Option id
    # @param reserved_ip_address [String] Reservation ip address
    # @param subnet_ip_address [String] Subnet ip address
    # @param vendor_name [String, nil] The name of the vendor class (for vendor options)
    #
    # @return [void]
    #
    def remove_reserved_option_value(option_id, reserved_ip_address, subnet_ip_address, vendor_name = nil)
      dhcp_remove_option_value_v5(
          option_id,
          vendor_name,
          DhcpsApi::DHCP_OPTION_SCOPE_INFO.build_for_reserved_scope(reserved_ip_address, subnet_ip_address)
      )
    end

    # Removes an option value for a multicast scope.
    #
    # @example Remove a multicast scope option value
    #
    # api.remove_multicast_option_value(3, '224.0.0.0')
    #
    # @param option_id [Fixnum] Option id
    # @param multicast_scope_name [String] Multicast scope ip address
    # @param vendor_name [String, nil] The name of the vendor class (for vendor options)
    #
    # @return [void]
    #
    def remove_multicast_option_value(option_id, multicast_scope_name, vendor_name = nil)
      dhcp_remove_option_value_v5(
          option_id,
          vendor_name,
          DhcpsApi::DHCP_OPTION_SCOPE_INFO.build_for_multicast_scope(multicast_scope_name)
      )
    end

    # Removes a default scope option value.
    #
    # @example Remove a default scope option value
    #
    # api.remove_option_value(3)
    #
    # @param option_id [Fixnum] Option id
    # @param vendor_name [String, nil] The name of the vendor class (for vendor options)
    #
    # @return [void]
    #
    def remove_option_value(option_id, vendor_name = nil)
      dhcp_remove_option_value_v5(
          option_id,
          vendor_name,
          DhcpsApi::DHCP_OPTION_SCOPE_INFO.build_for_default_scope
      )
    end

    # List option values for a subnet.
    #
    # @example Retrieve all subnet option values
    #
    # api.list_subnet_option_values('192.168.42.0')
    #
    # @param subnet_ip_address [String] Subnet ip address
    # @param vendor_name [String, nil] The name of the vendor class (for vendor options)
    #
    # @return [Array<Hash>]
    #
    # @see DHCP_OPTION_VALUE DHCP_OPTION_VALUE documentation for the list of available fields.
    #
    def list_subnet_option_values(subnet_ip_address, vendor_name = nil)
      items, _ = retrieve_items(:dhcp_enum_option_values_v5,
                                vendor_name,
                                DhcpsApi::DHCP_OPTION_SCOPE_INFO.build_for_subnet_scope(subnet_ip_address),
                                1024, 0)
      items
    end

    # List option values for a reservation.
    #
    # @example Retrieve all option values for a reservation
    #
    # api.list_reserved_option_values('192.168.42.100', '192.168.42.0')
    #
    # @param reserved_ip_address [String] Reservation ip address
    # @param subnet_ip_address [String] Subnet ip address
    # @param vendor_name [String, nil] The name of the vendor class (for vendor options)
    #
    # @return [Array<Hash>]
    #
    # @see DHCP_OPTION_VALUE DHCP_OPTION_VALUE documentation for the list of available fields.
    #
    def list_reserved_option_values(reserved_ip_address, subnet_ip_address, vendor_name = nil)
      items, _ = retrieve_items(:dhcp_enum_option_values_v5,
                                vendor_name,
                                DhcpsApi::DHCP_OPTION_SCOPE_INFO.build_for_reserved_scope(reserved_ip_address, subnet_ip_address),
                                1024, 0)
      items
    end

    # List option values for a multicast scope.
    #
    # @example Retrieve all option values for a multicast scope
    #
    # api.list_multicast_option_values('224.0.0.0')
    #
    # @param multicast_scope_name [String] Multicast scope ip address
    # @param vendor_name [String, nil] The name of the vendor class (for vendor options)
    #
    # @return [Array<Hash>]
    #
    # @see DHCP_OPTION_VALUE DHCP_OPTION_VALUE documentation for the list of available fields.
    #
    def list_multicast_option_values(multicast_scope_name, vendor_name = nil)
      items, _ = retrieve_items(:dhcp_enum_option_values_v5,
                                vendor_name,
                                DhcpsApi::DHCP_OPTION_SCOPE_INFO.build_for_multicast_scope(multicast_scope_name),
                                1024, 0)
      items
    end

    # List option values for a default scope.
    #
    # @example Retrieve all option values for a default scope
    #
    # api.list_multicast_option_values
    #
    # @param vendor_name [String, nil] The name of the vendor class (for vendor options)
    #
    # @return [Array<Hash>]
    #
    # @see DHCP_OPTION_VALUE DHCP_OPTION_VALUE documentation for the list of available fields.
    #
    def list_values(vendor_name = nil)
      items, _ = retrieve_items(:dhcp_enum_option_values_v5,
                                vendor_name,
                                DhcpsApi::DHCP_OPTION_SCOPE_INFO.build_for_default_scope,
                                1024, 0)
      items
    end

    private
    def dhcp_set_option_value_v5(option_id, vendor_name, scope_info, option_type, values)
      is_vendor = vendor_name.nil? ? 0 : DhcpsApi::DHCP_FLAGS_OPTION_IS_VENDOR
      option_data = DhcpsApi::DHCP_OPTION_DATA.from_array(option_type, values)
      error = DhcpsApi::Win2008::OptionValue.DhcpSetOptionValueV5(to_wchar_string(server_ip_address),
                                            is_vendor,
                                            option_id,
                                            nil,
                                            vendor_name.nil? ? nil : FFI::MemoryPointer.from_string(to_wchar_string(vendor_name)),
                                            scope_info.pointer,
                                            option_data.pointer)
      raise DhcpsApi::Error.new("Error setting option value.", error) if error != 0
    end

    def dhcp_get_option_value_v5(option_id, vendor_name, scope_info)
      is_vendor = vendor_name.nil? ? 0 : DhcpsApi::DHCP_FLAGS_OPTION_IS_VENDOR
      option_value_ptr_ptr = FFI::MemoryPointer.new(:pointer)

      error = DhcpsApi::Win2008::OptionValue.DhcpGetOptionValueV5(to_wchar_string(server_ip_address),
                                            is_vendor,
                                            option_id,
                                            nil,
                                            vendor_name.nil? ? nil : FFI::MemoryPointer.from_string(to_wchar_string(vendor_name)),
                                            scope_info,
                                            option_value_ptr_ptr)

      if is_error?(error)
        unless (option_value_ptr_ptr.null? || (to_free = option_value_ptr_ptr.read_pointer).null?)
          free_memory(DhcpsApi::DHCP_OPTION_VALUE.new(to_free))
        end
        raise DhcpsApi::Error.new("Error retrieving option value.", error)
      end

      option_value = DhcpsApi::DHCP_OPTION_VALUE.new(option_value_ptr_ptr.read_pointer)
      to_return = option_value.as_ruby_struct

      free_memory(option_value)
      to_return
    end

    def dhcp_remove_option_value_v5(option_id, vendor_name, scope_info)
      is_vendor = vendor_name.nil? ? 0 : DhcpsApi::DHCP_FLAGS_OPTION_IS_VENDOR

      error = DhcpsApi::Win2008::OptionValue.DhcpRemoveOptionValueV5(to_wchar_string(server_ip_address),
                                               is_vendor,
                                               option_id,
                                               nil,
                                               vendor_name.nil? ? nil : FFI::MemoryPointer.from_string(to_wchar_string(vendor_name)),
                                               scope_info)

      raise DhcpsApi::Error.new("Error deleting option value.", error) if error != 0
    end

    def dhcp_enum_option_values_v5(vendor_name, scope_info, preferred_maximum, resume_handle)
      resume_handle_ptr = FFI::MemoryPointer.new(:uint32).put_uint32(0, resume_handle)
      option_values_ptr_ptr = FFI::MemoryPointer.new(:pointer)
      options_read_ptr = FFI::MemoryPointer.new(:uint32).put_uint32(0, 0)
      options_total_ptr = FFI::MemoryPointer.new(:uint32).put_uint32(0, 0)
      is_vendor = vendor_name.nil? ? 0 : DhcpsApi::DHCP_FLAGS_OPTION_IS_VENDOR

      error = DhcpsApi::Win2008::OptionValue.DhcpEnumOptionValuesV5(to_wchar_string(server_ip_address),
                                              is_vendor,
                                              nil,
                                              vendor_name.nil? ? nil : FFI::MemoryPointer.from_string(to_wchar_string(vendor_name)),
                                              scope_info.pointer,
                                              resume_handle_ptr,
                                              preferred_maximum,
                                              option_values_ptr_ptr,
                                              options_read_ptr,
                                              options_total_ptr)
      return empty_response if error == 259
      if is_error?(error)
        unless (option_values_ptr_ptr.null? || (to_free = option_values_ptr_ptr.read_pointer).null?)
          free_memory(DhcpsApi::DHCP_OPTION_VALUE_ARRAY.new(to_free))
        end
        raise DhcpsApi::Error.new("Error retrieving option values.", error)
      end

      option_values_array = DhcpsApi::DHCP_OPTION_VALUE_ARRAY.new(option_values_ptr_ptr.read_pointer)
      to_return = option_values_array.as_ruby_struct

      free_memory(option_values_array)
      [to_return, resume_handle_ptr.get_uint32(0), options_read_ptr.get_uint32(0), options_total_ptr.get_uint32(0)]
    end
  end
end
