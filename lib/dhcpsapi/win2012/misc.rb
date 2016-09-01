module DhcpsApi::Win2012
  module Misc
    extend FFI::Library
    ffi_lib 'dhcpsapi'
    ffi_convention :stdcall

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
  end
end
