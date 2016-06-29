module DhcpsApi
  class Error < RuntimeError
    attr_reader :error_code

    def initialize(message, error_code)
      @error_code = error_code
      super(message + " #{Error.description(error_code)}")
    end

    def self.description(code)
      case code
        when 20000
          "The DHCP server registry initialization parameters are incorrect." #ERROR_DHCP_REGISTRY_INIT_FAILED
        when 20001
          "The DHCP server was unable to open the database of DHCP clients." #ERROR_DHCP_DATABASE_INIT_FAILED
        when 20002
          "The DHCP server was unable to start as a Remote Procedure Call (RPC) server." #ERROR_DHCP_RPC_INIT_FAILED
        when 20003
          "The DHCP server was unable to establish a socket connection." #ERROR_DHCP_NETWORK_INIT_FAILED
        when 20004
          "The specified subnet already exists on the DHCP server." #ERROR_DHCP_SUBNET_EXISTS
        when 20005
          "The specified subnet does not exist on the DHCP server." #ERROR_DHCP_SUBNET_NOT_PRESENT
        when 20006
          "The primary host information for the specified subnet was not found on the DHCP server." #ERROR_DHCP_PRIMARY_NOT_FOUND
        when 20007
          "The specified DHCP element has been used by a client and cannot be removed."#ERROR_DHCP_ELEMENT_CANT_REMOVE
        when 20009
          "The specified option already exists on the DHCP server." #ERROR_DHCP_OPTION_EXISTS
        when 20010
          "The specified option does not exist on the DHCP server." #ERROR_DHCP_OPTION_NOT_PRESENT
        when 20011
          "The specified IP address is not available." #ERROR_DHCP_ADDRESS_NOT_AVAILABLE
        when 20012
          "The specified IP address range has all of its member addresses leased." #ERROR_DHCP_RANGE_FULL
        when 20013
          "An error occurred while accessing the DHCP JET database. For more information about this error, please look at the DHCP server event log. " #ERROR_DHCP_JET_ERROR
        when 20014
          "The specified client already exists in the database." #ERROR_DHCP_CLIENT_EXISTS
        when 20015
          "The DHCP server received an invalid message." #ERROR_DHCP_INVALID_DHCP_MESSAGE
        when 20016
          "The DHCP server received an invalid message from the client." #ERROR_DHCP_INVALID_DHCP_CLIENT
        when 20017
          "The DHCP server is currently paused." #ERROR_DHCP_SERVICE_PAUSED
        when 20018
          "The specified DHCP client is not a reserved client." #ERROR_DHCP_NOT_RESERVED_CLIENT
        when 20019
          "The specified DHCP client is a reserved client." #ERROR_DHCP_RESERVED_CLIENT
        when 20020
          "The specified IP address range is too small." #ERROR_DHCP_RANGE_TOO_SMALL
        when 20021
          "The specified IP address range is already defined on the DHCP server." #ERROR_DHCP_IPRANGE_EXISTS
        when 20022
          "The specified IP address is currently taken by another client." #ERROR_DHCP_RESERVEDIP_EXISTS
        when 20023
          "The specified IP address range either overlaps with an existing range or is invalid." #ERROR_DHCP_INVALID_RANGE
        when 20024
          "The specified IP address range is an extension of an existing range." #ERROR_DHCP_RANGE_EXTENDED
        when 20025
          "The specified IP address range extension is too small. The number of addresses in the extension must be a multiple of 32." #ERROR_DHCP_RANGE_EXTENSION_TOO_SMALL
        when 20026
          "An attempt was made to extend the IP address range to a value less than the specified backward extension. The number of addresses in the extension must be a multiple of 32." #ERROR_DHCP_WARNING_RANGE_EXTENDED_LESS
        when 20027
          "The DHCP database needs to be upgraded to a newer format. For more information, refer to the DHCP server event log." #ERROR_DHCP_JET_CONV_REQUIRED
        when 20028
          "The format of the bootstrap protocol file table is incorrect. The correct format is:" #ERROR_DHCP_SERVER_INVALID_BOOT_FILE_TABLE
        when 20029
          "A boot file name specified in the bootstrap protocol file table is unrecognized or invalid." #ERROR_DHCP_SERVER_UNKNOWN_BOOT_FILE_NAME
        when 20030
          "The specified superscope name is too long." #ERROR_DHCP_SUPER_SCOPE_NAME_TOO_LONG
        when 20032
          "The specified IP address is already in use." #ERROR_DHCP_IP_ADDRESS_IN_USE
        when 20033
          "The specified path to the DHCP audit log file is too long." #ERROR_DHCP_LOG_FILE_PATH_TOO_LONG
        when 20034
          "The DHCP server received a request for a valid IP address not administered by the server." #ERROR_DHCP_UNSUPPORTED_CLIENT
        when 20035
          "The DHCP server failed to receive a notification when the interface list changed, therefore some of the interfaces will not be enabled on the server." #ERROR_DHCP_SERVER_INTERFACE_NOTIFICATION_EVENT
        when 20036
          "The DHCP database needs to be upgraded to a newer format (JET97). For more information, refer to the DHCP server event log." #ERROR_DHCP_JET97_CONV_REQUIRED
        when 20037
          "The DHCP server cannot determine if it has the authority to run, and is not servicing clients on the network." #ERROR_DHCP_ROGUE_INIT_FAILED
        when 20038
          "The DHCP service is shutting down because another DHCP server is active on the network." #ERROR_DHCP_ROGUE_SAMSHUTDOWN
        when 20039
          "The DHCP server does not have the authority to run, and is not servicing clients on the network." #ERROR_DHCP_ROGUE_NOT_AUTHORIZED
        when 20040
          "The DHCP server is unable to contact the directory service for this domain. " #ERROR_DHCP_ROGUE_DS_UNREACHABLE
        when 20041
          "The DHCP server's authorization information conflicts with that of another DHCP server on the network." #ERROR_DHCP_ROGUE_DS_CONFLICT
        when 20042
          "The DHCP server is ignoring a request from another DHCP server because the second server is a member of a different directory service enterprise." #ERROR_DHCP_ROGUE_NOT_OUR_ENTERPRISE
        when 20043
          "The DHCP server has detected a directory service environment on the network." #ERROR_DHCP_STANDALONE_IN_DS
        when 20044
          "The specified DHCP class name is unknown or invalid." #ERROR_DHCP_CLASS_NOT_FOUND
        when 20045
          "The specified DHCP class name (or information) is already in use." #ERROR_DHCP_CLASS_ALREADY_EXISTS
        when 20046
          "The specified DHCP scope name is too long; the scope name must not exceed 256 characters." #ERROR_DHCP_SCOPE_NAME_TOO_LONG
        when 20047
          "The default scope is already configured on the server." #ERROR_DHCP_DEFAULT_SCOPE_EXISTS
        when 20048
          "The Dynamic BOOTP attribute cannot be turned on or off." #ERROR_DHCP_CANT_CHANGE_ATTRIBUTE
        when 20049
          "Conversion of a scope to a 'DHCP Only' scope or to a 'BOOTP Only' scope is not allowed when the scope contains other DHCP and BOOTP clients." #ERROR_DHCP_IPRANGE_CONV_ILLEGAL
        when 20050
          "The network has changed. Retry this operation after checking for network changes" #ERROR_DHCP_NETWORK_CHANGED
        when 20051
          "The bindings to internal IP addresses cannot be modified." #ERROR_DHCP_CANNOT_MODIFY_BINDINGS
        when 20052
          "The DHCP scope parameters are incorrect." #ERROR_DHCP_SUBNET_EXISTS
        when 20053
          "The DHCP multicast scope parameters are incorrect." #ERROR_DHCP_MSCOPE_EXISTS
        when 20054
          "The multicast scope range must have at least 256 IP addresses." #ERROR_DHCP_MSCOPE_RANGE_TOO_SMALL
        when 20070
          "The DHCP server could not contact Active Directory." #ERROR_DDS_NO_DS_AVAILABLE
        when 20071
          "The DHCP service root could not be found in Active Directory." #ERROR_DDS_NO_DHCP_ROOT
        when 20074
          "A DHCP service could not be found." #ERROR_DDS_DHCP_SERVER_NOT_FOUND
        when 20075
          "The specified DHCP options are already present in Active Directory." #ERROR_DDS_OPTION_ALREADY_EXISTS
        when 20076
          "The specified DHCP options are not present in Active Directory." #ERROR_DDS_OPTION_ALREADY_EXISTS
        when 20077
          "The specified DHCP classes are already present in Active Directory." #ERROR_DDS_CLASS_EXISTS
        when 20078
          "The specified DHCP classes are not present in Active Directory." #ERROR_DDS_CLASS_DOES_NOT_EXIST
        when 20079
          "The specified DHCP servers are already present in Active Directory." #ERROR_DDS_SERVER_ALREADY_EXISTS
        when 20080
          "The specified DHCP servers are not present in Active Directory." #ERROR_DDS_SERVER_DOES_NOT_EXIST
        when 20081
          "The specified DHCP server address does not correspond to the identified DHCP server name." #ERROR_DDS_SERVER_ADDRESS_MISMATCH
        when 20082
          "The specified subnets are already present in Active Directory." #ERROR_DDS_SUBNET_EXISTS
        when 20083
          "The specified subnet belongs to a different superscope." #ERROR_DDS_SUBNET_HAS_DIFF_SUPER_SCOPE
        when 20084
          "The specified subnet is not present in Active Directory." #ERROR_DDS_SUBNET_NOT_PRESENT
        when 20085
          "The specified reservation is not present in Active Directory." #ERROR_DDS_RESERVATION_NOT_PRESENT
        when 20086
          "The specified reservation conflicts with another reservation present in Active Directory." #ERROR_DDS_RESERVATION_CONFLICT
        when 20087
          "The specified IP address range conflicts with another IP range present in Active Directory." #ERROR_DDS_POSSIBLE_RANGE_CONFLICT
        when 20088
          "The specified IP address range is not present in Active Directory." #ERROR_DDS_RANGE_DOES_NOT_EXIST
        else
          "Unknown error '#{code}'"
      end
    end
  end
end
