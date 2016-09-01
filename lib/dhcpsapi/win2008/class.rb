module DhcpsApi::Win2008
  module Class
    extend FFI::Library
    ffi_lib 'dhcpsapi'
    ffi_convention :stdcall

=begin
  DWORD DhcpEnumClasses(
    _In_    LPWSTR                  ServerIpAddress,
    _In_    DWORD                   ReservedMustBeZero,
    _Inout_  DHCP_RESUME_HANDLE     *ResumeHandle,
    _In_    DWORD                   PreferredMaximum,
    _Out_   LPDHCP_CLASS_INFO_ARRAY *ClassInfoArray,
    _Out_   DWORD                   *nRead,
    _Out_   DWORD                   *nTotal
  );
=end
    attach_function :DhcpEnumClasses, [:pointer, :uint32, :pointer, :uint32, :pointer, :pointer, :pointer], :uint32

=begin
  DWORD DhcpCreateClass(
    _In_ LPWSTR            ServerIpAddress,
    _In_ DWORD             ReservedMustBeZero,
    _In_ LPDHCP_CLASS_INFO ClassInfo
  );
=end
    attach_function :DhcpCreateClass, [:pointer, :uint32, :pointer], :uint32

=begin
  DWORD DhcpDeleteClass(
    _In_ LPWSTR ServerIpAddress,
    _In_ DWORD  ReservedMustBeZero,
    _In_ LPWSTR ClassName
  );
=end
    attach_function :DhcpDeleteClass, [:pointer, :uint32, :pointer], :uint32
  end
end
