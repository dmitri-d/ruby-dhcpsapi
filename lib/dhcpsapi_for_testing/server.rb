module DhcpsApi
  class Server
    attr_reader :server_ip_address

    def initialize(server_ip_address)
      @server_ip_address = server_ip_address
    end
  end
end
