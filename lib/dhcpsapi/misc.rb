module DhcpsApi
=begin
  DWORD DHCP_API_FUNCTION DhcpV4GetFreeIPAddress(
    _In_opt_ LPWSTR          ServerIpAddress,
    _In_     DHCP_IP_ADDRESS ScopeId,
    _In_     DHCP_IP_ADDRESS startIP,
    _In_     DHCP_IP_ADDRESS endIP,
    _In_     DWORD           numFreeAddrReq,
    _Out_    LPDHCP_IP_ARRAY *IPAddrList
  );
=end
  attach_function :DhcpV4GetFreeIPAddress, [:pointer, :uint32, :uint32, :uint32, :uint32, :pointer], :uint32

  module Misc
    include CommonMethods
    def get_free_ip_address(subnet_address, start_address = nil, end_address = nil, num_of_addresses = 1)
      dhcp_ip_array_ptr_ptr = FFI::MemoryPointer.new(:pointer)
      error = DhcpsApi.DhcpV4GetFreeIPAddress(to_wchar_string(server_ip_address),
                                      ip_to_uint32(subnet_address),
                                      start_address.nil? ? 0 : ip_to_uint32(start_address),
                                      end_address.nil? ? 0 : ip_to_uint32(end_address),
                                      num_of_addresses,
                                      dhcp_ip_array_ptr_ptr)

      return [] if (error == 2 || error == 20126)
      if is_error?(error)
        unless (dhcp_ip_array_ptr_ptr.null? || (to_free = dhcp_ip_array_ptr_ptr.read_pointer).null?)
          free_memory(DhcpsApi::DHCP_IP_ARRAY.new(to_free))
        end
        raise DhcpsApi::Error.new("Error looking up a free ip address in subnet %s." % [subnet_address], error)
      end

      dhcp_ip_array = DhcpsApi::DHCP_IP_ARRAY.new(dhcp_ip_array_ptr_ptr.read_pointer)
      free_ips = dhcp_ip_array[:elements].read_array_of_type(:uint32, :read_uint32, dhcp_ip_array[:num_elements])
      free_memory(dhcp_ip_array)

      free_ips.map {|ip| uint32_to_ip(ip)}
    end
  end
end
