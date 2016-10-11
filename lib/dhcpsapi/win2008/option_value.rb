module DhcpsApi::Win2008
  module OptionValue
    extend FFI::Library
    ffi_lib 'dhcpsapi'
    ffi_convention :stdcall

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
    attach_function :DhcpGetOptionValueV5, [:pointer, :uint32, :uint32, :pointer, :pointer, :pointer, :pointer], :uint32

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
   attach_function :DhcpRemoveOptionValueV5, [:pointer, :uint32, :uint32, :pointer, :pointer,  :pointer], :uint32

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
  end
end
