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
typedef enum _DHCP_OPTION_TYPE {
  DhcpUnaryElementTypeOption,
      DhcpArrayTypeOption
} DHCP_OPTION_TYPE, *LPDHCP_OPTION_TYPE;
=end
  class DHCP_OPTION_TYPE
    DhcpUnaryElementTypeOption = 0
    DhcpArrayTypeOption = 1
  end

  #
  # DHCP_OPTION_SCOPE_TYPE enumeration defines the set of possible DHCP option scopes.
  #
  # @see https://msdn.microsoft.com/en-us/library/windows/desktop/aa363363(v=vs.85).aspx
  #
  class DHCP_OPTION_SCOPE_TYPE
    # The DHCP options correspond to the default scope.
    DhcpDefaultOptions = 0
    # The DHCP options correspond to the global scope.
    DhcpGlobalOptions = 1
    # The DHCP options correspond to a specific subnet scope.
    DhcpSubnetOptions = 2
    # The DHCP options correspond to a reserved IP address.
    DhcpReservedOptions = 3
    # The DHCP options correspond to a multicast scope.
    DhcpMScopeOptions = 4
  end

  class DHCP_SUBNET_STATE
    DhcpsApiubnetEnabled = 0
    DhcpsApiubnetDisabled = 1
    DhcpsApiubnetEnabledSwitched = 2
    DhcpsApiubnetDisabledSwitched = 3
    DhcpsApiubnetInvalidState = 4
  end

=begin
  typedef enum _DHCP_SUBNET_ELEMENT_TYPE_V5 {
    DhcpIpRanges,
    DhcpSecondaryHosts,
    DhcpReservedIps,
    DhcpExcludedIpRanges,
    DhcpIpRangesDhcpOnly,
    DhcpIpRangesDhcpBootp,
    DhcpIpRangesBootpOnly
  } DHCP_SUBNET_ELEMENT_TYPE, *LPDHCP_SUBNET_ELEMENT_TYPE;
=end
  class DHCP_SUBNET_ELEMENT_TYPE
    DhcpIpRanges = 0
    DhcpSecondaryHosts = 1
    DhcpReservedIps = 2
    DhcpExcludedIpRanges = 3
    DhcpIpRangesDhcpOnly = 4
    DhcpIpRangesDhcpBootp = 5
    DhcpIpRangesBootpOnly = 6
  end
end
