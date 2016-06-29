module DhcpsApi
=begin
  typedef struct _DHCP_OPTION_SCOPE_INFO {
    DHCP_OPTION_SCOPE_TYPE ScopeType;
    union {
      DHCP_IP_ADDRESS     SubnetScopeInfo;
      DHCP_RESERVED_SCOPE ReservedScopeInfo;
      LPWSTR              MScopeInfo;
      PVOID               DefaultScopeInfo;
      PVOID               GlobalScopeInfo; //Pointer to a DHCP_OPTION_ARRAY structure that contains the global DHCP server options.
    } ScopeInfo;
  } DHCP_OPTION_SCOPE_INFO, *LPDHCP_OPTION_SCOPE_INFO;
=end
  class DHCP_OPTION_SCOPE_INFO_UNION < FFI::Union
    layout :subnet_scope_info, :uint32,
           :reserved_scope_info, DHCP_RESERVED_SCOPE,
           :m_scope_info, :pointer,
           :default_scope_info, :pointer, # unused
           :global_scope_info, :pointer
  end

  class DHCP_OPTION_SCOPE_INFO < DHCPS_Struct
    layout :scope_type, :uint32,
           :scope_info, DHCP_OPTION_SCOPE_INFO_UNION

    def self.build_for_subnet_scope(subnet_ip_address)
      to_return = new
      to_return[:scope_type] = DHCP_OPTION_SCOPE_TYPE::DhcpSubnetOptions
      to_return[:scope_info][:subnet_scope_info] = ip_to_uint32(subnet_ip_address)
      to_return
    end

    def self.build_for_reserved_scope(reserved_ip_address, subnet_ip_address)
      to_return = new
      to_return[:scope_type] = DHCP_OPTION_SCOPE_TYPE::DhcpReservedOptions
      to_return[:scope_info][:reserved_ip_address] = ip_to_uint32(reserved_ip_address)
      to_return[:scope_info][:reserved_ip_subnet_address] = ip_to_uint32(subnet_ip_address)
      to_return
    end

    def self.build_for_multicast_scope(multicast_scope_name)
      to_return = new
      to_return[:scope_type] = DHCP_OPTION_SCOPE_TYPE::DhcpMScopeOptions
      to_return[:scope_info][:m_scope_info] = to_wchar_string(multicast_scope_name)
      to_return
    end

    def self.build_for_default_scope
      to_return = new
      to_return[:scope_type] = DHCP_OPTION_SCOPE_TYPE::DhcpDefaultOptions
      to_return
    end

    # TODO
    def self.build_for_global_scope
      raise "Not implemented yet"
    end
  end

=begin
typedef struct _DHCP_OPTION_VALUE {
  DHCP_OPTION_ID   OptionID;
  DHCP_OPTION_DATA Value;
} DHCP_OPTION_VALUE, *LPDHCP_OPTION_VALUE;
=end
  class DHCP_OPTION_VALUE < DHCPS_Struct
    layout :option_id, :uint32,
           :value, DHCP_OPTION_DATA
  end

=begin
  typedef struct _DHCP_OPTION_VALUE_ARRAY {
    DWORD               NumElements;
    LPDHCP_OPTION_VALUE Values;
  } DHCP_OPTION_VALUE_ARRAY, *LPDHCP_OPTION_VALUE_ARRAY;
=end
  class DHCP_OPTION_VALUE_ARRAY < DHCPS_Struct
    layout :num_elements, :uint32,
           :values, :pointer

    def as_ruby_struct
      0.upto(self[:num_elements]-1).inject([]) do |all, offset|
        all << DhcpsApi::DHCP_OPTION_VALUE.new(self[:values] + offset*DHCP_OPTION_VALUE.size).as_ruby_struct
      end
    end
  end

=begin
  DWORD DhcpEnumOptionValuesV5(
    _In_    LPWSTR                    ServerIpAddress,
    _In_    DWORD                     Flags,
    _In_    LPWSTR                    ClassName,
    _In_    LPWSTR                    VendorName,
    _In_    LPDHCP_OPTION_SCOPE_INFO  ScopeInfo,
    _Inout_ DHCP_RESUME_HANDLE        *ResumeHandle,
    _In_    DWORD                     PreferredMaximum,
    _Out_   LPDHCP_OPTION_VALUE_ARRAY *OptionValues,
    _Out_   DWORD                     *OptionsRead,
    _Out_   DWORD                     *OptionsTotal
  );
=end
  attach_function :DhcpEnumOptionValuesV5, [:pointer, :uint32, :pointer, :pointer, :pointer, :pointer, :uint32, :pointer, :pointer, :pointer], :uint32

=begin
  DWORD DhcpGetOptionValueV5(
    _In_  LPWSTR                            ServerIpAddress,
    _In_  DWORD                             Flags,
    _In_  DHCP_OPTION_ID                    OptionID,
    _In_  LPWSTR                            ClassName,
    _In_  LPWSTR                            VendorName,
    _In_  DHCP_CONST DHCP_OPTION_SCOPE_INFO ScopeInfo,
    _Out_ LPDHCP_OPTION_VALUE               *OptionValue
  );
=end
  attach_function :DhcpGetOptionValueV5, [:pointer, :uint32, :uint32, :pointer, :pointer, DHCP_OPTION_SCOPE_INFO.by_value, :pointer], :uint32

=begin
  DWORD DhcpRemoveOptionValueV5(
    _In_ LPWSTR                            ServerIpAddress,
    _In_ DWORD                             Flags,
    _In_ DHCP_OPTION_ID                    OptionID,
    _In_ LPWSTR                            ClassName,
    _In_ LPWSTR                            VendorName,
    _In_ DHCP_CONST DHCP_OPTION_SCOPE_INFO ScopeInfo
  );
=end
  attach_function :DhcpRemoveOptionValueV5, [:pointer, :uint32, :uint32, :pointer, :pointer,  DHCP_OPTION_SCOPE_INFO.by_value], :uint32

=begin
  DWORD DhcpSetOptionValueV5(
    _In_     LPWSTR                             ServerIpAddress,
    _In_     DWORD                              Flags,
    _In_     DHCP_OPTION_ID                     OptionId,
    _In_opt_ LPWSTR                             ClassName,
    _In_opt_ LPWSTR                             VendorName,
    _In_     LDHCP_CONST DHCP_OPTION_SCOPE_INFO ScopeInfo,
    _In_     LDHCP_CONST DHCP_OPTION_DATA       OptionValue
  );
=end
  attach_function :DhcpSetOptionValueV5, [:pointer, :uint32, :uint32, :pointer, :pointer, :pointer, :pointer], :uint32

  module OptionValue
    def dhcp_set_option_value_v5(option_id, class_name, vendor_name, scope_info, option_type, *values)
      is_vendor = vendor_name.nil? ? 0 : DhcpsApi::DHCP_FLAGS_OPTION_IS_VENDOR
      option_data = DhcpsApi::DHCP_OPTION_DATA.from_array(option_type, values)
      error = DhcpsApi.DhcpGetOptionValueV5(to_wchar_string(server_ip_address),
                                                is_vendor,
                                                option_id,
                                                class_name.nil? ? nil : FFI::MemoryPointer.from_string(to_wchar_string(class_name)) ,
                                                vendor_name.nil? ? nil : FFI::MemoryPointer.from_string(to_wchar_string(vendor_name)),
                                                scope_info.pointer,
                                                option_data.pointer)
      raise DhcpsApi::Error.new("Error setting option value.", error) if error != 0
    end

    def dhcp_get_option_value_v5(option_id, class_name, vendor_name, scope_info)
      is_vendor = vendor_name.nil? ? 0 : DhcpsApi::DHCP_FLAGS_OPTION_IS_VENDOR
      option_value_ptr_ptr = FFI::MemoryPointer.new(:pointer)

      error = DhcpsApi.DhcpGetOptionValueV5(to_wchar_string(server_ip_address),
                                                is_vendor,
                                                option_id,
                                                class_name.nil? ? nil : FFI::MemoryPointer.from_string(to_wchar_string(class_name)) ,
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

    def dhcp_remove_option_value_v5(option_id, class_name, vendor_name, scope_info)
      is_vendor = vendor_name.nil? ? 0 : DhcpsApi::DHCP_FLAGS_OPTION_IS_VENDOR

      error = DhcpsApi.DhcpRemoveOptionValueV5(to_wchar_string(server_ip_address),
                                                   is_vendor,
                                                   option_id,
                                                   class_name.nil? ? nil : FFI::MemoryPointer.from_string(to_wchar_string(class_name)) ,
                                                   vendor_name.nil? ? nil : FFI::MemoryPointer.from_string(to_wchar_string(vendor_name)),
                                                   scope_info)

      raise DhcpsApi::Error.new("Error deleting option value.", error) if error != 0
    end

    def list_subnet_option_values(subnet_ip_address, class_name, vendor_name)
      items, _ = retrieve_items(:dhcp_enum_option_values_v5,
                                class_name,
                                vendor_name,
                                DhcpsApi::DHCP_OPTION_SCOPE_INFO.build_for_subnet_scope(subnet_ip_address),
                                1024, 0)
      items
    end

    def list_reserved_option_valuess(reserved_ip_address, subnet_ip_address, class_name, vendor_name)
      items, _ = retrieve_items(:dhcp_enum_option_values_v5,
                                class_name,
                                vendor_name,
                                DhcpsApi::DHCP_OPTION_SCOPE_INFO.build_for_reserved_scope(reserved_ip_address, subnet_ip_address),
                                1024, 0)
      items
    end

    def list_multicast_option_valuess(multicast_scope_name, class_name, vendor_name)
      items, _ = retrieve_items(:dhcp_enum_option_values_v5,
                                class_name,
                                vendor_name,
                                DhcpsApi::DHCP_OPTION_SCOPE_INFO.build_for_multicast_scope(multicast_scope_name),
                                1024, 0)
      items
    end

    def list_default_option_valuess(class_name, vendor_name)
      items, _ = retrieve_items(:dhcp_enum_option_values_v5,
                                class_name,
                                vendor_name,
                                DhcpsApi::DHCP_OPTION_SCOPE_INFO.build_for_default_scope,
                                1024, 0)
      items
    end

    def dhcp_enum_option_values_v5(class_name, vendor_name, scope_info, preferred_maximum, resume_handle)
      resume_handle_ptr = FFI::MemoryPointer.new(:uint32).put_uint32(0, resume_handle)
      option_values_ptr_ptr = FFI::MemoryPointer.new(:pointer)
      options_read_ptr = FFI::MemoryPointer.new(:uint32).put_uint32(0, 0)
      options_total_ptr = FFI::MemoryPointer.new(:uint32).put_uint32(0, 0)
      is_vendor = vendor_name.nil? ? 0 : DhcpsApi::DHCP_FLAGS_OPTION_IS_VENDOR

      error = DhcpsApi.DhcpEnumOptionValuesV5(to_wchar_string(server_ip_address),
                                                  is_vendor,
                                                  class_name.nil? ? nil : FFI::MemoryPointer.from_string(to_wchar_string(class_name)) ,
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
