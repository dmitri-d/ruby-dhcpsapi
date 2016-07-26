module DhcpsApi
  class QuarantineStatus
    #The DHCP client is compliant with the health policies defined by the administrator and has normal access to the network.
    NOQUARANTINE = 0
    #The DHCP client is not compliant with the health policies defined by the administrator and is being quarantined with restricted access to the network.
    RESTRICTEDACCESS = 1
    #The DHCP client is not compliant with the health policies defined by the administrator and is being denied access to the network.
    # The DHCP server does not grant an IP address lease to this client.
    DROPPACKET = 2
    #The DHCP client is not compliant with the health policies defined by the administrator and is being granted normal access to the network for a limited time.
    PROBATION = 3
    #The DHCP client is exempt from compliance with the health policies defined by the administrator and is granted normal access to the network.
    EXEMPT = 4
    #The DHCP client is put into the default quarantine state configured on the DHCP NAP server. When a network policy server (NPS) is unavailable,
    # the DHCP client can be put in any of the states NOQUARANTINE, RESTRICTEDACCESS, or DROPPACKET, depending on the default setting on the DHCP NAP server.
    DEFAULTQUARSETTING = 5
    #No quarantine.
    NOQUARINFO = 6
  end

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
  class DHCP_CLIENT_INFO_PB < DHCPS_Struct
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
typedef struct _DHCP_CLIENT_INFO_PB_ARRAY {
  DWORD                 NumElements;
  LPDHCP_CLIENT_INFO_PB *Clients;
} DHCP_CLIENT_INFO_PB_ARRAY, *LPDHCP_CLIENT_INFO_PB_ARRAY;
=end
  class DHCP_CLIENT_INFO_PB_ARRAY < DHCPS_Struct
    layout :num_elements, :uint32,
           :clients, :pointer
  end

=begin
  DWORD DhcpCreateClientInfoV4(
    _In_ DHCP_CONST WCHAR                 *ServerIpAddress,
    _In_ LPDHCP_CONST DHCP_CLIENT_INFO_V4 ClientInfo
  );
=end
  attach_function :DhcpCreateClientInfoV4, [:pointer, :pointer], :uint32

=begin
  DWORD DhcpSetClientInfoV4(
    _In_ DHCP_CONST WCHAR               *ServerIpAddress,
    _In_ DHCP_CONST DHCP_CLIENT_INFO_V4 *ClientInfo
  );
=end
  attach_function :DhcpSetClientInfoV4, [:pointer, :pointer], :uint32

=begin
  DWORD DHCP_API_FUNCTION DhcpGetClientInfoV4(
    _In_  DHCP_CONST WCHAR            ServerIpAddress,
    _In_  DHCP_CONST DHCP_SEARCH_INFO SearchInfo,
    _Out_ LPDHCP_CLIENT_INFO_V4       *ClientInfo
  );
=end
  attach_function :DhcpGetClientInfoV4, [:pointer, DHCP_SEARCH_INFO.by_value, :pointer], :uint32

=begin
  DWORD DHCP_API_FUNCTION DhcpV4EnumSubnetClients(
    _In_opt_ DHCP_CONST WCHAR            *ServerIpAddress,
    _In_     DHCP_IP_ADDRESS             SubnetAddress,
    _Inout_  DHCP_RESUME_HANDLE          *ResumeHandle,
    _In_     DWORD                       PreferredMaximum,
    _Out_    LPDHCP_CLIENT_INFO_PB_ARRAY *ClientInfo,
    _Out_    DWORD                       *ClientsRead,
    _Out_    DWORD                       *ClientsTotal
  );
=end
  attach_function :DhcpV4EnumSubnetClients, [:pointer, :uint32, :pointer, :uint32, :pointer, :pointer, :pointer], :uint32

=begin
  DWORD DHCP_API_FUNCTION DhcpDeleteClientInfo(
    _In_ DHCP_CONST WCHAR            *ServerIpAddress,
    _In_ DHCP_CONST DHCP_SEARCH_INFO *ClientInfo
  );
=end
  attach_function :DhcpDeleteClientInfo, [:pointer, :pointer], :uint32

  module Client
    def list_clients(subnet_address)
      items, _ = retrieve_items(:dhcp_v4_enum_subnet_clients, subnet_address, 1024, 0)
      items
    end

    # TODO: parse lease time and owner_host
    def create_client(client_ip_address, client_subnet_mask, client_mac_address,
                      client_name, client_comment, lease_expires, client_type = DhcpsApi::ClientType::CLIENT_TYPE_BOTH)
      to_create = DhcpsApi::DHCP_CLIENT_INFO_V4.new
      to_create[:client_ip_address] = ip_to_uint32(client_ip_address)
      to_create[:subnet_mask] = ip_to_uint32(client_subnet_mask)
      to_create[:client_hardware_address].intialize_with_mac_address(client_mac_address)

      to_create[:client_name] = FFI::MemoryPointer.from_string(to_wchar_string(client_name))
      to_create[:client_comment] = FFI::MemoryPointer.from_string(to_wchar_string(client_comment))

      to_create[:client_lease_expires][:dw_low_date_time] = 0
      to_create[:client_lease_expires][:dw_high_date_time] = 0
      to_create[:client_type] = client_type

      error = DhcpsApi.DhcpCreateClientInfoV4(to_wchar_string(server_ip_address), to_create.pointer)
      raise DhcpsApi::Error.new("Error creating client.", error) if error != 0

      to_create.as_ruby_struct
    end

    # TODO: parse lease time and owner_host
    def modify_client(client_ip_address, client_subnet_mask, client_mac_address,
                      client_name, client_comment, lease_expires, client_type = DhcpsApi::ClientType::CLIENT_TYPE_BOTH)
      to_modify = DhcpsApi::DHCP_CLIENT_INFO_V4.new
      to_modify[:client_ip_address] = ip_to_uint32(client_ip_address)
      to_modify[:subnet_mask] = ip_to_uint32(client_subnet_mask)
      to_modify[:client_hardware_address].intialize_with_mac_address(client_mac_address)

      to_modify[:client_name] = FFI::MemoryPointer.from_string(to_wchar_string(client_name))
      to_modify[:client_comment] = FFI::MemoryPointer.from_string(to_wchar_string(client_comment))

      to_modify[:client_lease_expires][:dw_low_date_time] = 0
      to_modify[:client_lease_expires][:dw_high_date_time] = 0
      to_modify[:client_type] = client_type

      error = DhcpsApi.DhcpSetClientInfoV4(to_wchar_string(server_ip_address), to_modify.pointer)
      raise DhcpsApi::Error.new("Error modifying client.", error) if error != 0

      to_modify.as_ruby_struct
    end

    def get_client_subnet(client)
      uint32_to_ip(ip_to_uint32(client[:client_ip_address]) & ip_to_uint32(client[:subnet_mask]))
    end

    def get_client_by_mac_address(subnet_address, client_mac_address)
      search_info = DhcpsApi::DHCP_SEARCH_INFO.new
      search_info[:search_type] = DhcpsApi::DHCP_SEARCH_INFO_TYPE::DhcpClientHardwareAddress
      search_info[:search_info][:client_hardware_address].initialize_with_subnet_and_mac_addresses(subnet_address, client_mac_address)

      get_client(search_info, client_mac_address)
    end

    def get_client_by_ip_address(client_ip_address)
      search_info = DhcpsApi::DHCP_SEARCH_INFO.new
      search_info[:search_type] = DhcpsApi::DHCP_SEARCH_INFO_TYPE::DhcpClientIpAddress
      search_info[:search_info][:client_ip_address] = ip_to_uint32(client_ip_address)

      get_client(search_info, client_ip_address)
    end

    def get_client_by_name(client_name)
      search_info = DhcpsApi::DHCP_SEARCH_INFO.new
      search_info[:search_type] = DhcpsApi::DHCP_SEARCH_INFO_TYPE::DhcpClientName
      search_info[:search_info][:client_name] = FFI::MemoryPointer.from_string(to_wchar_string(client_name))

      get_client(search_info, client_name)
    end

    def delete_client_by_mac_address(subnet_address, client_mac_address)
      search_info = DhcpsApi::DHCP_SEARCH_INFO.new
      search_info[:search_type] = DhcpsApi::DHCP_SEARCH_INFO_TYPE::DhcpClientHardwareAddress
      search_info[:search_info][:client_hardware_address].initialize_with_subnet_and_mac_addresses(subnet_address, client_mac_address)

      error = DhcpsApi.DhcpDeleteClientInfo(to_wchar_string(server_ip_address), search_info.pointer)
      raise DhcpsApi::Error.new("Error deleting client.", error) if error != 0
    end

    def delete_client_by_ip_address(client_ip_address)
      search_info = DhcpsApi::DHCP_SEARCH_INFO.new
      search_info[:search_type] = DhcpsApi::DHCP_SEARCH_INFO_TYPE::DhcpClientIpAddress
      search_info[:search_info][:client_ip_address] = ip_to_uint32(client_ip_address)

      error = DhcpsApi.DhcpDeleteClientInfo(to_wchar_string(server_ip_address), search_info.pointer)
      raise DhcpsApi::Error.new("Error deleting client.", error) if error != 0
    end

    def delete_client_by_name(client_name)
      search_info = DhcpsApi::DHCP_SEARCH_INFO.new
      search_info[:search_type] = DhcpsApi::DHCP_SEARCH_INFO_TYPE::DhcpClientName
      search_info[:search_info][:client_name] = FFI::MemoryPointer.from_string(to_wchar_string(client_name))

      error = DhcpsApi.DhcpDeleteClientInfo(to_wchar_string(server_ip_address), search_info.pointer)
      raise DhcpsApi::Error.new("Error deleting client.", error) if error != 0
    end

    private
    def get_client(search_info, client_id)
      client_info_ptr_ptr = FFI::MemoryPointer.new(:pointer)

      error = DhcpsApi.DhcpGetClientInfoV4(to_wchar_string(server_ip_address), search_info.pointer, client_info_ptr_ptr)
      if is_error?(error)
        unless (client_info_ptr_ptr.null? || (to_free = client_info_ptr_ptr.read_pointer).null?)
          free_memory(DhcpsApi::DHCP_CLIENT_INFO_V4.new(to_free))
        end
        raise DhcpsApi::Error.new("Error retrieving client '%s'." % [client_id], error)
      end

      client_info = DhcpsApi::DHCP_CLIENT_INFO_V4.new(client_info_ptr_ptr.read_pointer)
      to_return = client_info.as_ruby_struct

      free_memory(client_info)
      to_return
    end

    def dhcp_v4_enum_subnet_clients(subnet_address, preferred_maximum, resume_handle)
      resume_handle_ptr = FFI::MemoryPointer.new(:uint32).put_uint32(0, resume_handle)
      client_info_ptr_ptr = FFI::MemoryPointer.new(:pointer)
      elements_read_ptr = FFI::MemoryPointer.new(:uint32).put_uint32(0, 0)
      elements_total_ptr = FFI::MemoryPointer.new(:uint32).put_uint32(0, 0)

      error = DhcpsApi.DhcpV4EnumSubnetClients(
          to_wchar_string(server_ip_address), ip_to_uint32(subnet_address), resume_handle_ptr, preferred_maximum,
          client_info_ptr_ptr, elements_read_ptr, elements_total_ptr)
      return empty_response if error == 259
      if is_error?(error)
        unless (client_info_ptr_ptr.null? || (to_free = client_info_ptr_ptr.read_pointer).null?)
          free_memory(DhcpsApi::DHCP_CLIENT_INFO_PB_ARRAY.new(to_free))
        end
        raise DhcpsApi::Error.new("Error retrieving clients from subnet '%s'." % [subnet_address], error)
      end

      leases_array = DhcpsApi::DHCP_CLIENT_INFO_PB_ARRAY.new(client_info_ptr_ptr.read_pointer)
      lease_infos = (0..(leases_array[:num_elements]-1)).inject([]) do |all, offset|
        all << DhcpsApi::DHCP_CLIENT_INFO_PB.new((leases_array[:clients] + offset*FFI::Pointer.size).read_pointer)
      end

      leases = lease_infos.map {|lease_info| lease_info.as_ruby_struct}
      free_memory(leases_array)

      [leases, resume_handle_ptr.get_uint32(0), elements_read_ptr.get_uint32(0), elements_total_ptr.get_uint32(0)]
    end
  end
end
