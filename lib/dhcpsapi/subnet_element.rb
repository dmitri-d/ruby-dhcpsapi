module DhcpsApi
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
  DWORD DhcpAddSubnetElementV4(
    _In_ DHCP_CONST WCHAR                       *ServerIpAddress,
    _In_ DHCP_IP_ADDRESS                        SubnetAddress,
    _In_ DHCP_CONST DHCP_SUBNET_ELEMENT_DATA_V4 *AddElementInfo
  );
=end
  attach_function :DhcpAddSubnetElementV4, [:pointer, :uint32, :pointer], :uint32

=begin
  DWORD DHCP_API_FUNCTION DhcpRemoveSubnetElementV4(
    _In_ DHCP_CONST WCHAR                       *ServerIpAddress,
    _In_ DHCP_IP_ADDRESS                        SubnetAddress,
    _In_ DHCP_CONST DHCP_SUBNET_ELEMENT_DATA_V4 *RemoveElementInfo,
    _In_ DHCP_FORCE_FLAG                        ForceFlag
  );
=end
  attach_function :DhcpRemoveSubnetElementV4, [:pointer, :uint32, :pointer, :uint32], :uint32
end
