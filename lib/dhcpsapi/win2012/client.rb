module DhcpsApi::Win2012
  module Client
    extend FFI::Library
    ffi_lib 'dhcpsapi'
    ffi_convention :stdcall

=begin
  DWORD DHCP_API_FUNCTION DhcpV4EnumSubnetClients(
  _In_opt_ DHCP_CONST WCHAR            *ServerIpAddress,
  _In_     DHCP_IP_ADDRESS             SubnetAddress,
  _Inout_  DHCP_RESUME_HANDLE          *ResumeHandle,
  _In_     DWORD                       PreferredMaximum,
  _Out_    LPDHCP_CLIENT_INFO_PB_ARRAY *ClientInfo,
  _Out_    DWORD                       *ClientsRead,
  _Out_    DWORD                       *ClientsTotal
  );
=end
    attach_function :DhcpV4EnumSubnetClients, [:pointer, :uint32, :pointer, :uint32, :pointer, :pointer, :pointer], :uint32
  end
end

