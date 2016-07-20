module DhcpsApi
  class DHCP_SUBNET_STATE
    DhcpsApiubnetEnabled = 0
    DhcpsApiubnetDisabled = 1
    DhcpsApiubnetEnabledSwitched = 2
    DhcpsApiubnetDisabledSwitched = 3
    DhcpsApiubnetInvalidState = 4
  end

=begin
  typedef struct _DHCP_SUBNET_INFO {
    DHCP_IP_ADDRESS   SubnetAddress;
    DHCP_IP_MASK      SubnetMask;
    LPWSTR            SubnetName;
    LPWSTR            SubnetComment;
    DHCP_HOST_INFO    PrimaryHost;
    DHCP_SUBNET_STATE SubnetState;
  } DHCP_SUBNET_INFO, *LPDHCP_SUBNET_INFO;
=end
  class DHCP_SUBNET_INFO < DHCPS_Struct
    layout :subnet_address, :uint32,
           :subnet_mask, :uint32,
           :subnet_name, :pointer,
           :subnet_comment, :pointer,
           :primary_host, DHCP_HOST_INFO,
           :subnet_state, :uint32

    ruby_struct_attr :uint32_to_ip, :subnet_address, :subnet_mask
    ruby_struct_attr :to_string, :subnet_name, :subnet_comment
  end

=begin
  DWORD DHCP_API_FUNCTION DhcpEnumSubnets(
    _In_    DHCP_CONST WCHAR   *ServerIpAddress,
    _Inout_ DHCP_RESUME_HANDLE *ResumeHandle,
    _In_    DWORD              PreferredMaximum,
    _Out_   LPDHCP_IP_ARRAY    *EnumInfo,
    _Out_   DWORD              *ElementsRead,
    _Out_   DWORD              *ElementsTotal
  );
=end
  attach_function :DhcpEnumSubnets, [:pointer, :pointer, :uint32, :pointer, :pointer, :pointer], :uint32

=begin
  DWORD DHCP_API_FUNCTION DhcpCreateSubnet(
    _In_ DHCP_CONST WCHAR            *ServerIpAddress,
    _In_ DHCP_IP_ADDRESS             SubnetAddress,
    _In_ DHCP_CONST DHCP_SUBNET_INFO *SubnetInfo
  );
=end
  attach_function :DhcpCreateSubnet, [:pointer, :uint32, :pointer], :uint32

=begin
  DWORD DHCP_API_FUNCTION DhcpDeleteSubnet(
    _In_ DHCP_CONST WCHAR *ServerIpAddress,
    _In_ DHCP_IP_ADDRESS  SubnetAddress,
    _In_ DHCP_FORCE_FLAG  ForceFlag
  );
=end
  attach_function :DhcpDeleteSubnet, [:pointer, :uint32, :uint32], :uint32

=begin
  DWORD DHCP_API_FUNCTION DhcpGetSubnetInfo(
    _In_  DHCP_CONST WCHAR   *ServerIpAddress,
    _In_  DHCP_IP_ADDRESS    SubnetAddress,
    _Out_ LPDHCP_SUBNET_INFO *SubnetInfo
  );
=end
  attach_function :DhcpGetSubnetInfo, [:pointer, :uint32, :pointer], :uint32

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

      error = DhcpsApi.DhcpCreateSubnet(to_wchar_string(server_ip_address), ip_to_uint32(subnet_address), subnet_info.pointer)
      raise DhcpsApi::Error.new("Error creating subnet.", error) if error != 0

      subnet_info.as_ruby_struct
    end

    def delete_subnet(subnet_address, force_flag = DhcpsApi::DHCP_FORCE_FLAG::DhcpNoForce)
      error = DhcpsApi.DhcpDeleteSubnet(to_wchar_string(server_ip_address), ip_to_uint32(subnet_address), force_flag)
      raise DhcpsApi::Error.new("Error deleting subnet.", error) if error != 0
    end

    def enum_subnets
      items, _ = retrieve_items(:dhcp_enum_subnets, 1024, 0)
      items
    end

    # expects subnet_address is DHCP_IP_ADDRESS
    def dhcp_get_subnet_info(subnet_address)
      subnet_info_ptr_ptr = FFI::MemoryPointer.new(:pointer)

      error = DhcpsApi.DhcpGetSubnetInfo(to_wchar_string(server_ip_address), subnet_address, subnet_info_ptr_ptr)
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

      error = DhcpsApi.DhcpEnumSubnets(to_wchar_string(server_ip_address), resume_handle_ptr, preferred_maximium, dhcp_ip_array_ptr_ptr, elements_read_ptr, elements_total_ptr)
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
