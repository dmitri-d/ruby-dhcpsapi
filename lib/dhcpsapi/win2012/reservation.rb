module DhcpsApi::Win2012
  module Reservation
    extend FFI::Library
    ffi_lib 'dhcpsapi'
    ffi_convention :stdcall

=begin
  DWORD DHCP_API_FUNCTION DhcpV4EnumSubnetReservations(
    _In_opt_ DHCP_CONST WCHAR              *ServerIpAddress,
    _In_     DHCP_IP_ADDRESS               SubnetAddress,
    _Inout_  DHCP_RESUME_HANDLE            *ResumeHandle,
    _In_     DWORD                         PreferredMaximum,
    _Out_    LPDHCP_RESERVATION_INFO_ARRAY *EnumElementInfo,
    _Out_    DWORD                         *ElementsRead,
    _Out_    DWORD                         *ElementsTotal
  );
=end
    attach_function :DhcpV4EnumSubnetReservations, [:pointer, :uint32, :pointer, :uint32, :pointer, :pointer, :pointer], :uint32
  end
end
