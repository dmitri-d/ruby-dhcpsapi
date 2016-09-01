module DhcpsApi
  module Class
    # Returns option classes available on the server as a List of DHCP_CLASS_INFOs represented as Hashmaps.
    #
    # @example Return available classes
    #
    # api.list_classes
    #
    # @return [Array<Hash>]
    #
    # @see DHCP_CLASS_INFO DHCP_CLASS_INFO documentation for the list of available fields.
    #
    def list_classes
      items, _ = retrieve_items(:dhcp_enum_classes, 1024, 0)
      items
    end

    # Creates a custom option class.
    #
    # @example Create a custom option class
    #
    # api.create_class('my_class', 'This is an example', false, 'my class')
    #
    # @param class_name [String] Name of the class
    # @param comment [String] Comments
    # @param is_vendor [Boolean] Specifies if the class is vendor-defined option class
    # @param data [String] Class data
    #
    # @return [Hash]
    #
    # @see DHCP_CLASS_INFO DHCP_CLASS_INFO documentation for the list of available fields.
    def create_class(class_name, comment, is_vendor, data)
      to_create = DhcpsApi::DHCP_CLASS_INFO.new
      to_create[:class_name] = FFI::MemoryPointer.from_string(to_wchar_string(class_name))
      to_create[:class_comment] = FFI::MemoryPointer.from_string(to_wchar_string(comment))
      to_create[:is_vendor] = is_vendor
      to_create[:class_data] = FFI::MemoryPointer.from_string(to_wchar_string(data))
      to_create[:class_data_length] = to_wchar_string(data).bytes.size

      error = DhcpsApi::Win2008::Class.DhcpCreateClass(to_wchar_string(server_ip_address), 0, to_create.pointer)
      raise DhcpsApi::Error.new("Error creating class.", error) if error != 0

      to_create.as_ruby_struct
    end

    # Deletes a custom option class.
    #
    # @example Delete a custom option class
    #
    # api.delete_class('my_class')
    #
    # @param class_name [String] Name of the class
    #
    # @return [void]
    #
    def delete_class(class_name)
      error = DhcpsApi::Win2008::Class.DhcpDeleteClass(to_wchar_string(server_ip_address), 0, to_wchar_string(class_name))
      raise DhcpsApi::Error.new("Error deleting class.", error) if error != 0
    end

    private
    def dhcp_enum_classes(preferred_maximum, resume_handle)
      resume_handle_ptr = FFI::MemoryPointer.new(:uint32).put_uint32(0, resume_handle)
      class_info_ptr_ptr = FFI::MemoryPointer.new(:pointer)
      elements_read_ptr = FFI::MemoryPointer.new(:uint32).put_uint32(0, 0)
      elements_total_ptr = FFI::MemoryPointer.new(:uint32).put_uint32(0, 0)

      error = DhcpsApi::Win2008::Class.DhcpEnumClasses(
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
