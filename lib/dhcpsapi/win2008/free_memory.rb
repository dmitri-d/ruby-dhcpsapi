module DhcpsApi::Win2008
  module Common
    extend FFI::Library
    ffi_lib 'dhcpsapi'
    ffi_convention :stdcall

=begin
VOID DHCP_API_FUNCTION DhcpRpcFreeMemory(
   PVOID BufferPointer
);
=end
    attach_function :DhcpRpcFreeMemory, [:pointer], :void
  end
end
