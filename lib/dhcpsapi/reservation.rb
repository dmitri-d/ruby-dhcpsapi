module DhcpsApiApi
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
  class DHCP_IP_RESERVATION_INFO < DhcpsApi_Struct
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
  class DHCP_RESERVATION_INFO_ARRAY < DhcpsApi_Struct
    layout :num_elements, :uint32,
           :elements, :pointer
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
  DWORD DHCP_API_FUNCTION DhcpV4EnumSubnetReservations(
    _In_opt_ DHCP_CONST WCHAR              *ServerIpAddress,
    _In_     DHCP_IP_ADDRESS               SubnetAddress,
    _Inout_  DHCP_RESUME_HANDLE            *ResumeHandle,
    _In_     DWORD                         PreferredMaximum,
    _Out_    LPDHCP_RESERVATION_INFO_ARRAY *EnumElementInfo,
    _Out_    DWORD                         *ElementsRead,
    _Out_    DWORD                         *ElementsTotal
  );
=end
  attach_function :DhcpV4EnumSubnetReservations, [:pointer, :uint32, :pointer, :uint32, :pointer, :pointer, :pointer], :uint32

  module Reservation
    include CommonMethods

    def list_reservations(subnet_address)
      items, _ = retrieve_items(:dhcp_v4_enum_subnet_reservations, subnet_address, 1024, 0)
      items
    end

    def create_reservation(reservation_ip, reservation_subnet_mask, reservation_mac, reservation_name, reservation_comment = '')
      subnet_element = DhcpsApi::DHCP_SUBNET_ELEMENT_DATA_V4.new
      subnet_element[:element_type] = DhcpsApi::DHCP_SUBNET_ELEMENT_TYPE::DhcpReservedIps
      subnet_element[:element][:reserved_ip] = (reserved_ip = DhcpsApi::DHCP_IP_RESERVATION_V4.new).pointer

      reserved_ip[:reserved_ip_address] = ip_to_uint32(reservation_ip)
      reserved_ip[:reserved_for_client] = DhcpsApi::DHCP_CLIENT_UID.from_mac_address(reservation_mac).pointer
      reserved_ip[:b_allowed_client_types] = DhcpsApi::ClientType::CLIENT_TYPE_NONE

      ip_as_octets = reservation_ip.split('.').map {|octet| octet.to_i}
      mask_as_octets = reservation_subnet_mask.split('.').map {|octet| octet.to_i}
      subnet_address = (0..3).inject([]) {|all, i| all << (ip_as_octets[i] & mask_as_octets[i])}.join('.')

      error = DhcpsApi.DhcpAddSubnetElementV4(to_wchar_string(server_ip_address), ip_to_uint32(subnet_address), subnet_element.pointer)
      raise DhcpsApi::Error.new("Error creating reservation.", error) if error != 0

      modify_client(server_ip_address, reservation_ip, reservation_subnet_mask, reservation_mac, reservation_name, reservation_comment, 0, DhcpsApi::ClientType::CLIENT_TYPE_NONE)

      subnet_element.as_ruby_struct
    end

    def delete_reservation(subnet_address, reservation_ip, reservation_mac)
      to_delete = DhcpsApi::DHCP_SUBNET_ELEMENT_DATA_V4.new
      to_delete[:element_type] = DhcpsApi::DHCP_SUBNET_ELEMENT_TYPE::DhcpReservedIps
      to_delete[:element][:reserved_ip] = (reserved_ip = DhcpsApi::DHCP_IP_RESERVATION_V4.new).pointer

      reserved_ip[:reserved_ip_address] = ip_to_uint32(reservation_ip)
      reserved_ip[:reserved_for_client] = DhcpsApi::DHCP_CLIENT_UID.from_mac_address(reservation_mac).pointer
      reserved_ip[:b_allowed_client_types] = DhcpsApi::ClientType::CLIENT_TYPE_NONE

      error = DhcpsApi.DhcpRemoveSubnetElementV4(
          to_wchar_string(server_ip_address),
          ip_to_uint32(subnet_address),
          to_delete.pointer,
          DhcpsApi::DHCP_FORCE_FLAG::DhcpNoForce)
      raise DhcpsApi::Error.new("Error creating reservation.", error) if error != 0
    end

    def dhcp_v4_enum_subnet_reservations(subnet_address, preferred_maximum, resume_handle)
      resume_handle_ptr = FFI::MemoryPointer.new(:uint32).put_uint32(0, resume_handle)
      enum_element_info_ptr_ptr = FFI::MemoryPointer.new(:pointer)
      elements_read_ptr = FFI::MemoryPointer.new(:uint32).put_uint32(0, 0)
      elements_total_ptr = FFI::MemoryPointer.new(:uint32).put_uint32(0, 0)

      error = DhcpsApi.DhcpV4EnumSubnetReservations(
          to_wchar_string(server_ip_address), ip_to_uint32(subnet_address), resume_handle_ptr, preferred_maximum,
          enum_element_info_ptr_ptr, elements_read_ptr, elements_total_ptr)
      return empty_response if error == 259
      if is_error?(error)
        unless (enum_element_info_ptr_ptr.null? || (to_free = enum_element_info_ptr_ptr.read_pointer).null?)
          free_memory(DhcpsApi::DHCP_RESERVATION_INFO_ARRAY.new(to_free))
        end
        raise DhcpsApi::Error.new("Error retrieving reservations from subnet '%s' on '%s'." % [subnet_address, server_ip_address], error)
      end

      reservations_array = DhcpsApi::DHCP_RESERVATION_INFO_ARRAY.new(enum_element_info_ptr_ptr.read_pointer)
      reservation_infos = (0..(reservations_array[:num_elements]-1)).inject([]) do |all, offset|
        all << DhcpsApi::DHCP_IP_RESERVATION_INFO.new((reservations_array[:elements] + offset*FFI::Pointer.size).read_pointer)
      end

      reservations = reservation_infos.map {|reservation_info| reservation_info.as_ruby_struct}
      free_memory(reservations_array)

      [reservations, resume_handle_ptr.get_uint32(0), elements_read_ptr.get_uint32(0), elements_total_ptr.get_uint32(0)]
    end
  end
end
