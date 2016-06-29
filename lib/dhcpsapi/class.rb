module DhcpsApi
=begin
  typedef struct _DHCP_CLASS_INFO {
    LPWSTR ClassName;
    LPWSTR ClassComment;
    DWORD  ClassDataLength;
    BOOL   IsVendor;
    DWORD  Flags;
    LPBYTE ClassData;
  } DHCP_CLASS_INFO, *LPDHCP_CLASS_INFO;
=end
  class DHCP_CLASS_INFO < DHCPS_Struct
    layout :class_name, :pointer,
           :class_comment, :pointer,
           :class_data_length, :uint32,
           :is_vendor, :bool,
           :flags, :uint32,
           :class_data, :pointer

    ruby_struct_attr :to_string, :class_name, :class_comment, :policy_name
    ruby_struct_attr :class_data_as_string, :class_data

    def class_data_as_string(unused)
      self[:class_data].read_array_of_type(:uint8, :read_uint8, self[:class_data_length])
    end
  end

=begin
  typedef struct _DHCP_CLASS_INFO_ARRAY {
    DWORD             NumElements;
    LPDHCP_CLASS_INFO Classes;
  } DHCP_CLASS_INFO_ARRAY, *LPDHCP_CLASS_INFO_ARRAY;
=end
  class DHCP_CLASS_INFO_ARRAY < DHCPS_Struct
    layout :num_elements, :uint32,
           :classes, :pointer
  end

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

  module Class
    def list_classes
      items, _ = retrieve_items(:dhcp_enum_classes, 1024, 0)
      items
    end

    def create_class(class_name, comment, is_vendor, data)
      to_create = DhcpsApi::DHCP_CLASS_INFO.new
      to_create[:class_name] = FFI::MemoryPointer.from_string(to_wchar_string(class_name))
      to_create[:class_comment] = FFI::MemoryPointer.from_string(to_wchar_string(comment))
      to_create[:is_vendor] = is_vendor
      to_create[:class_data] = FFI::MemoryPointer.from_string(to_wchar_string(data))
      to_create[:class_data_length] = to_wchar_string(data).bytes.size

      error = DhcpsApi.DhcpCreateClass(to_wchar_string(server_ip_address), 0, to_create.pointer)
      raise DhcpsApi::Error.new("Error creating class.", error) if error != 0

      to_create.as_ruby_struct
    end

    def delete_class(class_name)
      error = DhcpsApi.DhcpDeleteClass(to_wchar_string(server_ip_address), 0, to_wchar_string(class_name))
      raise DhcpsApi::Error.new("Error deleting class.", error) if error != 0
    end

    def dhcp_enum_classes(preferred_maximum, resume_handle)
      resume_handle_ptr = FFI::MemoryPointer.new(:uint32).put_uint32(0, resume_handle)
      class_info_ptr_ptr = FFI::MemoryPointer.new(:pointer)
      elements_read_ptr = FFI::MemoryPointer.new(:uint32).put_uint32(0, 0)
      elements_total_ptr = FFI::MemoryPointer.new(:uint32).put_uint32(0, 0)

      error = DhcpsApi.DhcpEnumClasses(
          to_wchar_string(server_ip_address), 0, resume_handle_ptr, preferred_maximum,
          class_info_ptr_ptr, elements_read_ptr, elements_total_ptr)

      return empty_response if error == 259
      if is_error?(error)
        unless (class_info_ptr_ptr.null? || (to_free = class_info_ptr_ptr.read_pointer).null?)
          free_memory(DhcpsApi::DHCP_CLASS_INFO_ARRAY.new(to_free))
        end
        raise DhcpsApi::Error.new("Error retrieving classes.", error)
      end

      return empty_response if class_info_ptr_ptr.read_pointer.null?
      class_info_array = DhcpsApi::DHCP_CLASS_INFO_ARRAY.new(class_info_ptr_ptr.read_pointer)
      class_infos = (0..(class_info_array[:num_elements]-1)).inject([]) do |all, offset|
        all << DhcpsApi::DHCP_CLASS_INFO.new(class_info_array[:classes] + offset*DhcpsApi::DHCP_CLASS_INFO.size)
      end

      classes = class_infos.map {|class_info| class_info.as_ruby_struct}
      free_memory(class_info_array)

      [classes, resume_handle_ptr.get_uint32(0), elements_read_ptr.get_uint32(0), elements_total_ptr.get_uint32(0)]
    end
  end
end
