module DhcpsApi::Win2008
  module Subnet
    extend FFI::Library
    ffi_lib 'dhcpsapi'
    ffi_convention :stdcall

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
  end
end
