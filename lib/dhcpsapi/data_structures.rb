module DhcpsApi
 #
 #  Data Streuctures available in Windows2008 and earlier versions of Windows
 #

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
        all << DHCP_OPTION_DATA_ELEMENT.new(self[:elements] + DHCP_OPTION_DATA_ELEMENT.size*offset).as_ruby_struct
      end
    end
  end

  #
  # DHCP_CLASS_INFO data structure describes an option class.
  #
  # Available fields:
  # :class_name [String],
  # :class_comment [String],
  # :is_vendor [Boolean],
  # :flags [Fixnum],
  # :class_data [String]
  #
  # @see https://msdn.microsoft.com/en-us/library/windows/desktop/dd897569(v=vs.85).aspx
  #
  class DHCP_CLASS_INFO < DHCPS_Struct
    layout :class_name, :pointer,
           :class_comment, :pointer,
           :class_data_length, :uint32,
           :is_vendor, :bool,
           :flags, :uint32,
           :class_data, :pointer

    ruby_struct_attr :to_string, :class_name, :class_comment, :policy_name
    ruby_struct_attr :class_data_as_string, :class_data

    private
    def class_data_as_string(unused)
      self[:class_data].read_array_of_type(:uint8, :read_uint8, self[:class_data_length])
    end
  end

  #
  # DHCP_CLASS_INFO data structure describes an array of option classes.
  #
  # Available fields:
  # :num_elements [Fixnum],
  # :classes [Array<Hash>]
  #
  # @see https://msdn.microsoft.com/en-us/library/windows/desktop/dd897570(v=vs.85).aspx
  #
  class DHCP_CLASS_INFO_ARRAY < DHCPS_Struct
    layout :num_elements, :uint32,
           :classes, :pointer
  end

=begin
  typedef struct _DHCP_CLIENT_INFO_V4 {
    DHCP_IP_ADDRESS ClientIpAddress;
    DHCP_IP_MASK    SubnetMask;
    DHCP_CLIENT_UID ClientHardwareAddress;
    LPWSTR          ClientName;
    LPWSTR          ClientComment;
    DATE_TIME       ClientLeaseExpires;
    DHCP_HOST_INFO  OwnerHost;
    BYTE            bClientType;
  } DHCP_CLIENT_INFO_V4, *LPDHCP_CLIENT_INFO_V4;
=end
  class DHCP_CLIENT_INFO_V4 < DHCPS_Struct
    layout :client_ip_address, :uint32,
           :subnet_mask, :uint32,
           :client_hardware_address, DHCP_CLIENT_UID,
           :client_name, :pointer,
           :client_comment, :pointer,
           :client_lease_expires, DATE_TIME,
           :owner_host, DHCP_HOST_INFO,
           :client_type, :uint8 # see ClientType

    ruby_struct_attr :uint32_to_ip, :client_ip_address, :subnet_mask
    ruby_struct_attr :dhcp_client_uid_to_mac, :client_hardware_address
    ruby_struct_attr :to_string, :client_name, :client_comment
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
  typedef struct _DHCP_OPTION {
    DHCP_OPTION_ID   OptionID;
    LPWSTR           OptionName;
    LPWSTR           OptionComment;
    DHCP_OPTION_DATA DefaultValue;
    DHCP_OPTION_TYPE OptionType;
  } DHCP_OPTION, *LPDHCP_OPTION;
=end
  class DHCP_OPTION < DHCPS_Struct
    layout :option_id, :uint32,
           :option_name, :pointer,
           :option_comment, :pointer,
           :default_value, DHCP_OPTION_DATA,
           :option_type, :uint32 # see DHCP_OPTION_TYPE

    ruby_struct_attr :to_string, :option_name, :option_comment
  end

=begin
typedef struct _DHCP_OPTION_ARRAY {
  DWORD         NumElements;
  LPDHCP_OPTION Options;
} DHCP_OPTION_ARRAY, *LPDHCP_OPTION_ARRAY;
=end
  class DHCP_OPTION_ARRAY < DHCPS_Struct
    layout :num_elements, :uint32,
           :options, :pointer

    def as_ruby_struct
      0.upto(self[:num_elements]-1).inject([]) do |all, offset|
        all << DHCP_OPTION.new(self[:options] + offset*DHCP_OPTION.size).as_ruby_struct
      end
    end
  end

  #
  # DHCP_RESERVED_SCOPE data structure describes an reserved DHCP scope.
  #
  # Available fields:
  # :reserved_ip_address [String],
  # :reserved_ip_subnet_address [String]
  #
  # @see https://msdn.microsoft.com/en-us/library/windows/desktop/aa363369(v=vs.85).aspx
  #
  class DHCP_RESERVED_SCOPE < DHCPS_Struct
    layout :reserved_ip_address, :uint32,
           :reserved_ip_subnet_address, :uint32
  end

  #
  # DHCP_RESERVED_SCOPE_UNION describes a DHCP scope.
  #
  # Available fields:
  # :subnet_scope_info [String],
  # :reserved_scope_info [DHCP_RESERVED_SCOPE],
  # :m_scope_info [String],
  # :default_scope_info, unused
  # :global_scope_info
  #
  # @see https://msdn.microsoft.com/en-us/library/windows/desktop/aa363361(v=vs.85).aspx
  #
  class DHCP_OPTION_SCOPE_INFO_UNION < FFI::Union
    layout :subnet_scope_info, :uint32,
           :reserved_scope_info, DHCP_RESERVED_SCOPE,
           :m_scope_info, :pointer,
           :default_scope_info, :pointer, # unused
           :global_scope_info, :pointer
  end

  #
  # DHCP_OPTION_SCOPE_INFO defines information about the options provided for a certain DHCP scope.
  #
  # Available fields:
  # :scope_type [Fixnum], see DHCP_OPTION_SCOPE_TYPE
  # :scope_info [DHCP_OPTION_SCOPE_INFO_UNION],
  #
  # @see https://msdn.microsoft.com/en-us/library/windows/desktop/aa363361(v=vs.85).aspx
  #
  class DHCP_OPTION_SCOPE_INFO < DHCPS_Struct
    layout :scope_type, :uint32,
           :scope_info, DHCP_OPTION_SCOPE_INFO_UNION

    def self.build_for_subnet_scope(subnet_ip_address)
      to_return = new
      to_return[:scope_type] = DHCP_OPTION_SCOPE_TYPE::DhcpSubnetOptions
      to_return[:scope_info][:subnet_scope_info] = to_return.ip_to_uint32(subnet_ip_address)
      to_return
    end

    def self.build_for_reserved_scope(reserved_ip_address, subnet_ip_address)
      to_return = new
      to_return[:scope_type] = DHCP_OPTION_SCOPE_TYPE::DhcpReservedOptions
      to_return[:scope_info][:reserved_scope_info][:reserved_ip_address] = to_return.ip_to_uint32(reserved_ip_address)
      to_return[:scope_info][:reserved_scope_info][:reserved_ip_subnet_address] = to_return.ip_to_uint32(subnet_ip_address)
      to_return
    end

    def self.build_for_multicast_scope(multicast_scope_name)
      to_return = new
      to_return[:scope_type] = DHCP_OPTION_SCOPE_TYPE::DhcpMScopeOptions
      to_return[:scope_info][:m_scope_info] = FFI::MemoryPointer.from_string(to_return.to_wchar_string(multicast_scope_name))
      to_return
    end

    def self.build_for_default_scope
      to_return = new
      to_return[:scope_type] = DHCP_OPTION_SCOPE_TYPE::DhcpDefaultOptions
      to_return[:scope_info][:default_scope_info] = DHCP_OPTION_ARRAY.new.pointer
      to_return
    end

    # TODO
    def self.build_for_global_scope
      raise "Not implemented yet"
    end
  end

  #
  # DHCP_OPTION_VALUE defines a DHCP option value.
  #
  # Available fields:
  # :option_id [Fixnum], Option id
  # :value [DHCP_OPTION_DATA], option value
  #
  # @see https://msdn.microsoft.com/en-us/library/windows/desktop/aa363367(v=vs.85).aspx
  #
  class DHCP_OPTION_VALUE < DHCPS_Struct
    layout :option_id, :uint32,
           :value, DHCP_OPTION_DATA
  end

  #
  # DHCP_OPTION_VALUE_ARRAY defines a list of DHCP option values.
  #
  # Available fields:
  # :bum_elements [Fixnum], The number of option values in the list
  # :values [Array<DHCP_OPTION_DATA>], Array of option values
  #
  # @see https://msdn.microsoft.com/en-us/library/windows/desktop/bb891963(v=vs.85).aspx
  #
  class DHCP_OPTION_VALUE_ARRAY < DHCPS_Struct
    layout :num_elements, :uint32,
           :values, :pointer

    def as_ruby_struct
      0.upto(self[:num_elements]-1).inject([]) do |all, offset|
        all << DhcpsApi::DHCP_OPTION_VALUE.new(self[:values] + offset*DHCP_OPTION_VALUE.size).as_ruby_struct
      end
    end
  end

=begin
  typedef struct _DHCP_IP_RESERVATION_V4 {
    DHCP_IP_ADDRESS ReservedIpAddress;
    DHCP_CLIENT_UID *ReservedForClient;
    BYTE            bAllowedClientTypes;
  } DHCP_IP_RESERVATION_V4, *LPDHCP_IP_RESERVATION_V4;
=end
  class DHCP_IP_RESERVATION_V4 < DHCPS_Struct
    layout :reserved_ip_address, :uint32,
           :reserved_for_client, :pointer,
           :b_allowed_client_types, :uint8 # see ClientType
  end

=begin
  typedef struct _DHCP_SUBNET_ELEMENT_DATA_V4 {
    DHCP_SUBNET_ELEMENT_TYPE ElementType;
    union {
      DHCP_IP_RANGE          *IpRange;
      DHCP_HOST_INFO         *SecondaryHost;
      DHCP_IP_RESERVATION_V4 *ReservedIp;
      DHCP_IP_RANGE          *ExcludeIpRange;
      DHCP_IP_CLUSTER        *IpUsedCluster;
    } Element;
  } DHCP_SUBNET_ELEMENT_DATA_V4, *LPDHCP_SUBNET_ELEMENT_DATA_V4;
=end
  class DHCP_SUBNET_ELEMENT < FFI::Union
    layout :ip_range, :pointer,
           :secondary_host, :pointer,
           :reserved_ip, :pointer,
           :exclude_ip_range, :pointer,
           :ip_used_cluster, :pointer
  end

  class DHCP_SUBNET_ELEMENT_DATA_V4 < DHCPS_Struct
    layout :element_type, :uint32,
           :element, DHCP_SUBNET_ELEMENT
  end

=begin
  typedef struct _DHCP_SUBNET_INFO {
    DHCP_IP_ADDRESS   SubnetAddress;
    DHCP_IP_MASK      SubnetMask;
    LPWSTR            SubnetName;
    LPWSTR            SubnetComment;
    DHCP_HOST_INFO    PrimaryHost;
    DHCP_SUBNET_STATE SubnetState;
  } DHCP_SUBNET_INFO, *LPDHCP_SUBNET_INFO;
=end
  class DHCP_SUBNET_INFO < DHCPS_Struct
    layout :subnet_address, :uint32,
           :subnet_mask, :uint32,
           :subnet_name, :pointer,
           :subnet_comment, :pointer,
           :primary_host, DHCP_HOST_INFO,
           :subnet_state, :uint32

    ruby_struct_attr :uint32_to_ip, :subnet_address, :subnet_mask
    ruby_struct_attr :to_string, :subnet_name, :subnet_comment
  end

=begin
  typedef struct _DHCP_IP_RANGE {
    DHCP_IP_ADDRESS StartAddress;
    DHCP_IP_ADDRESS EndAddress;
  } DHCP_IP_RANGE, *LPDHCP_IP_RANGE;
=end
  class DHCP_IP_RANGE < DHCPS_Struct
    layout :start_address, :uint32,
           :end_address, :uint32

    ruby_struct_attr :uint32_to_ip, :subnet_address, :subnet_mask
  end

#
# Data structures available in Win2012
#

=begin
  typedef struct _DHCP_CLIENT_INFO_PB {
    DHCP_IP_ADDRESS  ClientIpAddress;
    DHCP_IP_MASK     SubnetMask;
    DHCP_CLIENT_UID  ClientHardwareAddress;
    LPWSTR           ClientName;
    LPWSTR           ClientComment;
    DATE_TIME        ClientLeaseExpires;
    DHCP_HOST_INFO   OwnerHost;
    BYTE             bClientType;
    BYTE             AddressState;
    QuarantineStatus Status;
    DATE_TIME        ProbationEnds;
    BOOL             QuarantineCapable;
    DWORD            FilterStatus;
    LPWSTR           PolicyName;
  } DHCP_CLIENT_INFO_PB, *LPDHCP_CLIENT_INFO_PB;
=end
  class DHCP_CLIENT_INFO_PB < DhcpsApi::DHCPS_Struct
    layout  :client_ip_address, :uint32,
            :subnet_mask, :uint32,
            :client_hardware_address, DHCP_CLIENT_UID,
            :client_name, :pointer,
            :client_comment, :pointer,
            :client_lease_expires, DATE_TIME,
            :owner_host, DHCP_HOST_INFO,
            :b_client_type, :uint8, # see ClientType
            :address_state, :uint8,
            :status, :uint32,
            :probation_ends, DATE_TIME,
            :quarantine_capable, :bool,
            :filter_status, :uint32,
            :policy_name, :pointer

    ruby_struct_attr :uint32_to_ip, :client_ip_address, :subnet_mask
    ruby_struct_attr :dhcp_client_uid_to_mac, :client_hardware_address
    ruby_struct_attr :to_string, :client_name, :client_comment, :policy_name
  end

=begin
  typedef struct _DHCP_CLIENT_INFO_PB_ARRAY {
    DWORD                 NumElements;
    LPDHCP_CLIENT_INFO_PB *Clients;
  } DHCP_CLIENT_INFO_PB_ARRAY, *LPDHCP_CLIENT_INFO_PB_ARRAY;
=end
  class DHCP_CLIENT_INFO_PB_ARRAY < DhcpsApi::DHCPS_Struct
    layout :num_elements, :uint32,
           :clients, :pointer
  end

=begin
  typedef struct _DHCP_IP_RESERVATION_INFO {
    DHCP_IP_ADDRESS ReservedIpAddress;
    DHCP_CLIENT_UID ReservedForClient;
    LPWSTR          ReservedClientName;
    LPWSTR          ReservedClientDesc;
    BYTE            bAllowedClientTypes;
    BYTE            fOptionsPresent;
  } DHCP_IP_RESERVATION_INFO, *LPDHCP_IP_RESERVATION_INFO;
=end
  class DHCP_IP_RESERVATION_INFO < DHCPS_Struct
    layout :reserved_ip_address, :uint32,
           :reserved_for_client, DHCP_CLIENT_UID,
           :reserved_client_name, :pointer,
           :reserved_client_desc, :pointer,
           :b_allowed_client_types, :uint8, # see ClientType
           :f_options_present, :uint8

    ruby_struct_attr :uint32_to_ip, :reserved_ip_address
    ruby_struct_attr :dhcp_client_uid_to_mac, :reserved_for_client
    ruby_struct_attr :to_string, :reserved_client_name, :reserved_client_desc
  end

=begin
  typedef struct _DHCP_RESERVATION_INFO_ARRAY {
    DWORD                      NumElements;
    LPDHCP_IP_RESERVATION_INFO *Elements;
  } DHCP_RESERVATION_INFO_ARRAY, *LPDHCP_RESERVATION_INFO_ARRAY;
=end
  class DHCP_RESERVATION_INFO_ARRAY < DHCPS_Struct
    layout :num_elements, :uint32,
           :elements, :pointer
  end
end
