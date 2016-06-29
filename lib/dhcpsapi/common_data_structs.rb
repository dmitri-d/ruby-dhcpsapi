module DhcpsApi
  DHCP_FLAGS_OPTION_IS_VENDOR = 3

  class ClientType
    # The client's dynamic IP address protocol is unknown.
    CLIENT_TYPE_UNSPECIFIED = 0x0
    # The client uses DHCP for dynamic IP address service.
    CLIENT_TYPE_DHCP = 0x1
    # The client uses BOOTP for dynamic IP address service.
    CLIENT_TYPE_BOOTP = 0x2
    # The client can use either DHCP or BOOTP for dynamic IP address service.
    CLIENT_TYPE_BOTH =( CLIENT_TYPE_DHCP | CLIENT_TYPE_BOOTP )
    # The client does not use a supported dynamic IP address service.
    CLIENT_TYPE_NONE = 0x64
    CLIENT_TYPE_RESERVATION_FLAG = 0x4
  end

  class DHCP_FORCE_FLAG
    # The operation deletes all client records affected by the element, and then deletes the element.
    DhcpFullForce = 0
    # The operation only deletes the subnet element, leaving intact any client records impacted by the change.
    DhcpNoForce = 1
    # The operation deletes all client records affected by the element, and then deletes the element from the DHCP server.
    # But it does not delete any registered DNS records associated with the deleted client records from the DNS server.
    # This flag is only valid when passed to DhcpDeleteSubnet.
    # Note that the minimum server OS requirement for this value is Windows Server 2012 R2 with KB 3100473 installed.
    DhcpFailoverForce = 2
  end

=begin
  typedef struct _DHCP_IP_ARRAY {
    DWORD             NumElements;
    LPDHCP_IP_ADDRESS Elements;
  } DHCP_IP_ARRAY, *LPDHCP_IP_ARRAY;
=end
  class DHCP_IP_ARRAY < DHCPS_Struct
    layout :num_elements, :uint32,
           :elements, :pointer
  end

=begin
  typedef struct _DHCP_HOST_INFO {
    DHCP_IP_ADDRESS IpAddress;
    LPWSTR          NetBiosName;
    LPWSTR          HostName;
  } DHCP_HOST_INFO, *LPDHCP_HOST_INFO;
=end
  class DHCP_HOST_INFO < DHCPS_Struct
    layout :ip_address, :uint32,
           :net_bios_name, :pointer,
           :host_name, :pointer

    ruby_struct_attr :uint32_to_ip, :ip_address
    ruby_struct_attr :to_string, :net_bios_name, :host_name
  end

=begin
  typedef struct _DHCP_BINARY_DATA {
    DWORD DataLength;
    BYTE  *Data;
  } DHCP_BINARY_DATA, *LPDHCP_BINARY_DATA, DHCP_CLIENT_UID;
=end
  class DHCP_CLIENT_UID < DHCPS_Struct
    layout :data_length, :uint32,
           :data, :pointer

    def self.from_mac_address(mac_address)
      to_return = new
      mac_as_uint8s = to_return.mac_address_to_array_of_uint8(mac_address)
      to_return[:data_length] = mac_as_uint8s.size
      to_return[:data] = FFI::MemoryPointer.new(:uint8, mac_as_uint8s.size)
      to_return[:data].write_array_of_uint8(mac_as_uint8s)
      to_return
    end

    def intialize_with_mac_address(mac_address)
      mac_as_uint8s = mac_address_to_array_of_uint8(mac_address)
      self[:data_length] = mac_as_uint8s.size
      self[:data] = FFI::MemoryPointer.new(:uint8, mac_as_uint8s.size)
      self[:data].write_array_of_uint8(mac_as_uint8s)
      self
    end

    def initialize_with_subnet_and_mac_addresses(subnet_address, mac_address)
      mac_as_uint8s = mac_address_to_array_of_uint8(mac_address)
      subnet_as_uint8s = subnet_address.split('.').reverse.map {|octet| octet.to_i}
      self[:data_length] = 11
      self[:data] = FFI::MemoryPointer.new(:uint8, 11)
      self[:data].write_array_of_uint8(subnet_as_uint8s + [0x1] + mac_as_uint8s)
    end

    def data_as_ruby_struct_attr
      self[:data].read_array_of_type(:uint8, :read_uint8, self[:data_length]).map {|w| "%02X" % w}.join(":")
    end
  end

  class DHCP_BINARY_DATA < DHCPS_Struct
    layout :data_length, :uint32,
           :data, :pointer

    def self.from_data(data)
      to_return = new
      to_return[:data_length] = data.size
      to_return[:data] = FFI::MemoryPointer.new(:uint8, data.size)
      to_return[:data].write_array_of_uint8(data)
      to_return
    end

    def data_as_ruby_struct_attr
      self[:data].read_array_of_type(:uint8, :read_uint8, self[:data_length])
    end
  end

=begin
  typedef struct _DATE_TIME {
    DWORD dwLowDateTime;
    DWORD dwHighDateTime;
  } DATE_TIME, *LPDATE_TIME;
=end
  class DATE_TIME < DHCPS_Struct
    layout :dw_low_date_time, :uint32,
           :dw_high_date_time, :uint32

    def as_ruby_struct
      tmp = self[:dw_high_date_time]
      tmp = (tmp << 32) + self[:dw_low_date_time]
      tmp == 0 ? nil : Time.at(tmp/10000000 - 11644473600)
    end
  end

=begin
  typedef enum _DHCP_CLIENT_SEARCH_TYPE {
    DhcpClientIpAddress,
        DhcpClientHardwareAddress,
        DhcpClientName
  } DHCP_SEARCH_INFO_TYPE, *LPDHCP_SEARCH_INFO_TYPE;
=end
  class DHCP_SEARCH_INFO_TYPE
    DhcpClientIpAddress = 0
    DhcpClientHardwareAddress = 1
    DhcpClientName = 2
  end

=begin
  typedef struct _DHCP_CLIENT_SEARCH_INFO {
    DHCP_SEARCH_INFO_TYPE SearchType;
    union {
      DHCP_IP_ADDRESS ClientIpAddress;
      DHCP_CLIENT_UID ClientHardwareAddress;
      LPWSTR          ClientName;
    } SearchInfo;
  } DHCP_SEARCH_INFO, *LPDHCP_SEARCH_INFO;
=end
  class SEARCH_INFO_UNION < FFI::Union
    layout :client_ip_address, :uint32,
           :client_hardware_address, DHCP_CLIENT_UID,
           :client_name, :pointer
  end
  class DHCP_SEARCH_INFO < DHCPS_Struct
    layout :search_type, :uint32, # see DHCP_SEARCH_INFO_TYPE
           :search_info, SEARCH_INFO_UNION
  end

=begin
  typedef enum _DHCP_OPTION_DATA_TYPE {
    DhcpByteOption,
    DhcpWordOption,
    DhcpDWordOption,
    DhcpDWordDWordOption,
    DhcpIpAddressOption,
    DhcpStringDataOption,
    DhcpBinaryDataOption,
    DhcpEncapsulatedDataOption,
    DhcpIpv6AddressOption
  } DHCP_OPTION_DATA_TYPE, *LPDHCP_OPTION_DATA_TYPE;
=end
  class DHCP_OPTION_DATA_TYPE
    DhcpByteOption = 0
    DhcpWordOption = 1
    DhcpDWordOption = 2
    # The option data is stored as a DWORD_DWORD value.
    DhcpDWordDWordOption = 3
    # The option data is an IP address, stored as a DHCP_IP_ADDRESS value (DWORD).
    DhcpIpAddressOption = 4
    # The option data is stored as a Unicode string.
    DhcpStringDataOption = 5
    # The option data is stored as a DHCP_BINARY_DATA structure.
    DhcpBinaryDataOption = 6
    # The option data is encapsulated and stored as a DHCP_BINARY_DATA structure.
    DhcpEncapsulatedDataOption = 7
    # The option data is stored as a Unicode string.
    DhcpIpv6AddressOption = 8
  end

  class DWORD_DWORD < DHCPS_Struct
    layout :dword1, :uint32,
           :dword2, :uint32

    def self.from_int(an_int)
      to_return = new
      to_return[:dword1] = ((an_int >> 32) & 0xffffffff)
      to_return[:dword2] = (an_int & 0xffffffff)
      to_return
    end

    def as_ruby_struct
      (self[:dword1] << 32) | self[:dword2]
    end
  end

=begin
  typedef struct _DHCP_OPTION_DATA_ELEMENT {
    DHCP_OPTION_DATA_TYPE OptionType;
    union {
      BYTE             ByteOption;
      WORD             WordOption;
      DWORD            DWordOption;
      DWORD_DWORD      DWordDWordOption;
      DHCP_IP_ADDRESS  IpAddressOption;
      LPWSTR           StringDataOption;
      DHCP_BINARY_DATA BinaryDataOption;
      DHCP_BINARY_DATA EncapsulatedDataOption;
      LPWSTR           Ipv6AddressDataOption;
    } Element;
  } DHCP_OPTION_DATA_ELEMENT, *LPDHCP_OPTION_DATA_ELEMENT;
=end
  class DHCP_OPTION_DATA_ELEMENT_UNION < FFI::Union
    layout :byte_option, :uint8,
           :word_opition, :uint16,
           :dword_option, :uint32,
           :dword_dword_option, DWORD_DWORD,
           :ip_address_option, :uint32,
           :string_data_option, :pointer,
           :binary_data_option, DHCP_BINARY_DATA, # expects an array of uint8s
           :encapsulated_data_option, DHCP_BINARY_DATA,
           :ipv6_address_data_option, :pointer
  end

  class DHCP_OPTION_DATA_ELEMENT < DHCPS_Struct
    layout :option_type, :uint32, # see DHCP_OPTION_DATA_TYPE
           :element, DHCP_OPTION_DATA_ELEMENT_UNION

    def element_as_ruby_struct_attr
      case self[:option_type]
        when DHCP_OPTION_DATA_TYPE::DhcpByteOption
          self[:element][:byte_option]
        when DHCP_OPTION_DATA_TYPE::DhcpWordOption
          self[:element][:word_opition]
        when DHCP_OPTION_DATA_TYPE::DhcpDWordOption
          self[:element][:dword_option]
        when DHCP_OPTION_DATA_TYPE::DhcpDWordDWordOption
          self[:element][:dword_dword_option].as_ruby_struct
        when DHCP_OPTION_DATA_TYPE::DhcpIpAddressOption
          uint32_to_ip(self[:element][:ip_address_option])
        when DHCP_OPTION_DATA_TYPE::DhcpStringDataOption
          to_string(self[:element][:string_data_option])
        when DHCP_OPTION_DATA_TYPE::DhcpBinaryDataOption
          self[:element][:binary_data_option].as_ruby_struct
        when DHCP_OPTION_DATA_TYPE::DhcpEncapsulatedDataOption
          self[:element][:encapsulated_data_option].as_ruby_struct
        when DHCP_OPTION_DATA_TYPE::DhcpIpv6AddressOption
          to_string(self[:element][:ipv6_address_data_option])
      end
    end

    def initialize_from_data(type, data)
      self[:option_type] = type
      case type
        when DHCP_OPTION_DATA_TYPE::DhcpByteOption
          self[:element][:byte_option] = data.nil? ? 0 : data & 0xff
        when DHCP_OPTION_DATA_TYPE::DhcpWordOption
          self[:element][:word_opition] = data.nil? ? 0 : data & 0xffff
        when DHCP_OPTION_DATA_TYPE::DhcpDWordOption
          self[:element][:dword_option] = data.nil? ? 0 : data & 0xffffffff
        when DHCP_OPTION_DATA_TYPE::DhcpDWordDWordOption
          self[:element][:dword_dword_option] = DWORD_DWORD.from_int(data.nil? ? 0 : data)
        when DHCP_OPTION_DATA_TYPE::DhcpIpAddressOption
          self[:element][:ip_address_option] = data.nil? ? 0 : ip_to_uint32(data)
        when DHCP_OPTION_DATA_TYPE::DhcpStringDataOption
          self[:element][:string_data_option] = FFI::MemoryPointer.from_string(to_wchar_string(data.nil? ? '' : data))
        when DHCP_OPTION_DATA_TYPE::DhcpBinaryDataOption
          self[:element][:binary_data_option] = DHCP_BINARY_DATA.from_data(data.nil? ? [0] : data)
        when DHCP_OPTION_DATA_TYPE::DhcpEncapsulatedDataOption
          self[:element][:encapsulated_data_option] = DHCP_BINARY_DATA.from_data(data.nil? ? [0] : data)
        when DHCP_OPTION_DATA_TYPE::DhcpIpv6AddressOption
          self[:element][:ipv6_address_data_option] = FFI::MemoryPointer.from_string(to_wchar_string(data.nil? ? '' : data))
        else
          raise DhcpError, "Unknown dhcp option data type: #{type}"
      end

      self
    end

    def self.initialize_from_data(type, data)
      DHCP_OPTION_DATA_ELEMENT.new.initialize_from_data(type, data)
    end
  end

=begin
  typedef struct _DHCP_OPTION_DATA {
    DWORD                      NumElements;
    LPDHCP_OPTION_DATA_ELEMENT Elements;
  } DHCP_OPTION_DATA, *LPDHCP_OPTION_DATA;
=end
  class DHCP_OPTION_DATA < DHCPS_Struct
    layout :num_elements, :uint32,
           :elements, :pointer

    def self.from_array(type, array_of_data)
      to_return = new
      to_return.from_array(type, array_of_data)
      to_return
    end

    def from_array(type, array_of_data)
      if array_of_data.size == 0
        self[:num_elements] = 1
        self[:elements] = FFI::MemoryPointer.new(DHCP_OPTION_DATA_ELEMENT, 1)
        DHCP_OPTION_DATA_ELEMENT.new(self[:elements]).initialize_from_data(type, nil)
        return self
      end

      self[:num_elements] = array_of_data.size
      self[:elements] = FFI::MemoryPointer.new(DHCP_OPTION_DATA_ELEMENT, array_of_data.size)
      0.upto(array_of_data.size-1) do |i|
        element = DHCP_OPTION_DATA_ELEMENT.new(self[:elements] + DHCP_OPTION_DATA_ELEMENT.size*i)
        element.initialize_from_data(type, array_of_data[i])
      end

      self
    end

    def as_ruby_struct
      0.upto(self[:num_elements]-1).inject([]) do |all, offset|
        all << DHCP_OPTION_DATA_ELEMENT.new(self[:elements][offset]).as_ruby_struct
      end
    end
  end
end
