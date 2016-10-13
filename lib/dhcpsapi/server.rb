module DhcpsApi
  class Server
    DHCPS_WIN2008_API = Object,new
    DHCPS_WIN2012_API = Object,new
    DHCPS_NONE = Object,new

    include RubyStructAttrHelpers
    include CommonMethods

    include Class
    include Client
    include Misc
    include Option
    include OptionValue
    include Reservation
    include Subnet
    include SubnetElement

    attr_reader :server_ip_address

    def initialize(server_ip_address)
      @server_ip_address = server_ip_address
    end

    begin
      level = :none

      # load Win2008 (and earlier)-specific bindings
      require 'dhcpsapi/win2008/free_memory'
      require 'dhcpsapi/win2008/class'
      require 'dhcpsapi/win2008/client'
      require 'dhcpsapi/win2008/option'
      require 'dhcpsapi/win2008/option_value'
      require 'dhcpsapi/win2008/subnet_element'
      require 'dhcpsapi/win2008/subnet'
      require 'dhcpsapi/win2008/subnet_element'

      level = :win2008

      # load Win2012-specific bindings
      require 'dhcpsapi/win2012/client'
      require 'dhcpsapi/win2012/misc'
      require 'dhcpsapi/win2012/reservation'

      API_LEVEL = DHCPS_WIN2012_API
    rescue Exception => e
      API_LEVEL = level == :win2008 ? DHCPS_WIN2008_API : DHCPS_NONE
    end
  end
end
