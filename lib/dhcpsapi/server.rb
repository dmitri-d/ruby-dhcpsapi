module DhcpsApi
  class Server
    include RubyStructAttrHelpers
    include CommonMethods
    include Class
    include Client
    include Option
    include OptionValue
    include Reservation
    include Subnet

    attr_reader :server_ip_address

    def initialize(server_ip_address)
      @server_ip_address = server_ip_address
    end
  end
end
