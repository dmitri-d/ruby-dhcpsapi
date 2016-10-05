require 'set'

module DhcpsApi
  # @private
  module RubyStructAttrHelpers
    def to_string(a_ptr)
      return "" if a_ptr.null?
      a_ptr.get_bytes(0, wchar_string_length(a_ptr)*2).force_encoding('utf-16LE').encode('utf-8')
    end

    def wchar_string_length(a_ptr)
      str = FFI::Pointer.new(:uint16, a_ptr)
      (0..511).each do |i|
        return i if str[i].read_uint16 == 0
      end
      511
    end

    def ip_to_uint32(ip_address)
      ip_address.strip.split(".").inject(0) do |all_octets, current_octet|
        all_octets = all_octets << 8
        all_octets |= current_octet.to_i
        all_octets
      end
    end

    def uint32_to_ip(encoded_ip)
      (0..3).inject([]) {|all_octets, current_octet| all_octets << ((encoded_ip >> 8*current_octet) & 0xFF)}.reverse.join(".")
    end

    def dhcp_client_uid_to_mac(dhcp_client_uid)
      dhcp_client_uid[:data].read_array_of_type(:uint8, :read_uint8, dhcp_client_uid[:data_length]).map {|w| "%02X" % w}.join(":")
    end

    def mac_address_to_array_of_uint8(mac_address)
      mac_address.split(":").map {|part| part.to_i(16)}
    end

    def to_wchar_string(a_string)
      (a_string + "\x00").encode('utf-16LE')
    end
  end

  class DHCPS_Struct < ::FFI::Struct
    include RubyStructAttrHelpers

    def self.ruby_struct_attr(func_name, *attr_names)
      attr_names.each do |attr_name|
        define_method("#{attr_name}_as_ruby_struct_attr") { send(func_name, self[attr_name])}
      end
    end

    def as_ruby_struct
      members.inject({}) do |all, current|
        all[current] =
            if respond_to?("#{current}_as_ruby_struct_attr")
              send("#{current}_as_ruby_struct_attr")
            elsif self[current].is_a?(DHCPS_Struct)
              self[current].as_ruby_struct
            else
              self[current]
            end
        all
      end
    end
  end

# @private
  module CommonMethods
    def free_memory(a_struct)
      DhcpsApi::Win2008::Common.DhcpRpcFreeMemory(a_struct.pointer)
    end

    def retrieve_items(method_to_call, *args)
      to_return = []
      resume_handle = 0

      loop do
        items, resume_handle, elements_read, elements_total = send(method_to_call, *args)
        to_return += items
        args.pop
        args.push(resume_handle)
        break if elements_read == elements_total
      end

      [to_return, resume_handle]
    end

    def empty_response
      [[], 0, 0, 0]
    end

    def is_error?(exit_code)
      !Set.new([
                 0, # no error
                 234 # more data
             # 259 no more items
               ]).include?(exit_code)
    end
  end
end
