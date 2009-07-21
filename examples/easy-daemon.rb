#!/usr/bin/ruby
require "fstlib"

require "socket"



if __FILE__ == $0
  # TODO Generated stub
  host = ''
  port = 995
  
  s = UDPSocket.new
  s.bind(host,port)
  
  while 1
   
        message, address = s.recvfrom(8192)
        request = EasyIP::Header.new(message)
        puts "Got data from", address[3]
        resp = EasyIP::Header.new
        resp.counter=request.counter
        resp.flags = EasyIP::Flags::RESP
          
        if request.req_type != EasyIP::Operand::EMPTY
          resp.req_type = request.req_type
          resp.req_offset_server = request.req_offset_server
          resp.req_offset_client = request.req_offset_client
          resp.req_size = request.req_size
          resp.payload = [1,2,3,4,5,6,7,8,9,10]
        end
        puts request.inspect
        puts resp.unpack("H*")
        
        s.send(resp, 0, address[3], address[1])
        
   
  end
end