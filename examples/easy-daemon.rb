#!/usr/bin/ruby
require "fstlib"
require "eventmachine"


module EasyIPServer
  
  
  
  def receive_data data
    req=EasyIP::Packet.new(data)
    
    resp = EasyIP::Packet.new
    resp.counter=req.counter
    resp.flags = EasyIP::Flags::RESP  
    
    if req.req_type != EasyIP::Operand::EMPTY
      resp.req_type = req.req_type
      resp.req_offset_server = req.req_offset_server
      resp.req_offset_client = req.req_offset_client
      resp.req_size = req.req_size
      resp.payload = [1,2,3,4,5,6,7,8,9,10]
    end
    puts req.inspect    
    puts resp.unpack("H*")
    
    send_data resp
    
  end
  
  
end


if __FILE__ == $0
  # TODO Generated stub
  host = ''
  port = 995
 
  EventMachine::run {
        
    EventMachine::open_datagram_socket host, port, EasyIPServer
  }
 
end