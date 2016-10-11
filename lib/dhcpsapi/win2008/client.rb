module DhcpsApi::Win2008
  module Client
    extend FFI::Library
    ffi_lib 'dhcpsapi'
    ffi_convention :stdcall

=begin
  DWORD DHCP_API_FUNCTION DhcpEnumSubnetClientsV4(
    _In_    DHCP_CONST WCHAR            *ServerIpAddress,
    _In_    DHCP_IP_ADDRESS             SubnetAddress,
    _Inout_ DHCP_RESUME_HANDLE          *ResumeHandle,
    _In_    DWORD                       PreferredMaximum,
    _Out_   LPDHCP_CLIENT_INFO_ARRAY_V4 *ClientInfo,
    _Out_   DWORD                       *ClientsRead,
    _Out_   DWORD                       *ClientsTotal
  );
=end
    attach_function :DhcpEnumSubnetClientsV4, [:pointer, :uint32, :pointer, :uint32, :pointer, :pointer, :pointer], :uint32

=begin
  DWORD DhcpCreateClientInfoV4(
    _In_ DHCP_CONST WCHAR                 *ServerIpAddress,
    _In_ LPDHCP_CONST DHCP_CLIENT_INFO_V4 ClientInfo
  );
=end
    attach_function :DhcpCreateClientInfoV4, [:pointer, :pointer], :uint32

=begin
  DWORD DhcpSetClientInfoV4(
    _In_ DHCP_CONST WCHAR               *ServerIpAddress,
    _In_ DHCP_CONST DHCP_CLIENT_INFO_V4 *ClientInfo
  );
=end
    attach_function :DhcpSetClientInfoV4, [:pointer, :pointer], :uint32

=begin
  DWORD DHCP_API_FUNCTION DhcpGetClientInfoV4(
    _In_  DHCP_CONST WCHAR            ServerIpAddress,
    _In_  DHCP_CONST DHCP_SEARCH_INFO SearchInfo,
    _Out_ LPDHCP_CLIENT_INFO_V4       *ClientInfo
  );
=end
    attach_function :DhcpGetClientInfoV4, [:pointer, :pointer, :pointer], :uint32


=begin
  DWORD DHCP_API_FUNCTION DhcpDeleteClientInfo(
    _In_ DHCP_CONST WCHAR            *ServerIpAddress,
    _In_ DHCP_CONST DHCP_SEARCH_INFO *ClientInfo
  );
=end
    attach_function :DhcpDeleteClientInfo, [:pointer, :pointer], :uint32
  end
end
