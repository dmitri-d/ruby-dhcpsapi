module DhcpsApi
  extend FFI::Library

  ffi_lib 'dhcpsapi'
  ffi_convention :stdcall
end
