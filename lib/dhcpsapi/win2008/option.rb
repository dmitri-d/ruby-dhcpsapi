module DhcpsApi::Win2008
  module Option
    extend FFI::Library
    ffi_lib 'dhcpsapi'
    ffi_convention :stdcall

=begin
  DWORD DhcpCreateOptionV5(
    _In_     LPWSTR         ServerIpAddress,
    _In_     DWORD          Flags,
    _In_     DHCP_OPTION_ID OptionId,
    _In_opt_ LPWSTR         ClassName,
    _In_opt_ LPWSTR         VendorName,
    _In_     LPDHCP_OPTION  OptionInfo
  );
=end
    attach_function :DhcpCreateOptionV5, [:pointer, :uint32, :uint32, :pointer, :pointer, :pointer], :uint32

=begin
  DWORD DhcpGetOptionInfoV5(
    _In_  LPWSTR         ServerIpAddress,
    _In_  DWORD          Flags,
    _In_  DHCP_OPTION_ID OptionID,
    _In_  LPWSTR         ClassName,
    _In_  LPWSTR         VendorName,
    _Out_ LPDHCP_OPTION  *OptionInfo
  );
=end
    attach_function :DhcpGetOptionInfoV5, [:pointer, :uint32, :uint32, :pointer, :pointer, :pointer], :uint32

=begin
  DWORD DhcpRemoveOptionV5(
    _In_ LPWSTR         ServerIpAddress,
    _In_ DWORD          Flags,
    _In_ DHCP_OPTION_ID OptionID,
    _In_ LPWSTR         ClassName,
    _In_ LPWSTR         VendorName
  );
=end
    attach_function :DhcpRemoveOptionV5, [:pointer, :uint32, :uint32, :pointer, :pointer], :uint32

=begin
  DWORD DhcpEnumOptionsV5(
    _In_    LPWSTR              ServerIpAddress,
    _In_    DWORD               Flags,
    _In_    LPWSTR              ClassName,
    _In_    LPWSTR              VendorName,
    _Inout_ DHCP_RESUME_HANDLE  *ResumeHandle,
    _In_    DWORD               PreferredMaximum,
    _Out_   LPDHCP_OPTION_ARRAY *Options,
    _Out_   DWORD               *OptionsRead,
    _Out_   DWORD               *OptionsTotal
  );
=end
    attach_function :DhcpEnumOptionsV5, [:pointer, :uint32, :pointer, :pointer, :pointer, :uint32, :pointer, :pointer, :pointer], :uint32
  end
end
