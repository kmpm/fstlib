#!/usr/bin/ruby
$:.unshift File.dirname(__FILE__) 
require "fstlib"
require "eventmachine"
require "mq"
require "dbhelper"

# Shutdown AMQP gracefully so messages are published
Signal.trap('INT') { AMQP.stop{ EM.stop } }
Signal.trap('TERM'){ AMQP.stop{ EM.stop } }


class EasyIPHandler < EventMachine::Connection
  
  attr_accessor :topic
  attr_accessor :dbhelper
  
  
  
  def receive_data data
    puts 'receive_data'
    req=EasyIP::Packet.new(data)
    @topic.publish(Marshal.dump(req), :key=>'packet.incomming')
    resp = EasyIP::Packet.new
    resp.counter=req.counter
    resp.flags = EasyIP::Flags::RESP  
    
    if req.req_type != EasyIP::Operand::EMPTY
      resp.req_type = req.req_type
      resp.req_offset_server = req.req_offset_server
      resp.req_offset_client = req.req_offset_client
      resp.req_size = req.req_size
      table = get_table(req.req_type)
   
      
      payload = @dbhelper.get_payload(table, req.req_offset_server, req.req_offset_server+req.req_size)
        
   
      resp.payload = payload
      puts resp.inspect
    end
    #puts req.inspect    
    #puts resp.unpack("H*")
    
    send_data resp
    
    
  end
  
  
end


if __FILE__ == $0
  # TODO Generated stub
  host = ''
  port = 995
 
  dbhelper = DbHelper.new
  dbhelper.init_db
  EventMachine::run do
    amqp = AMQP.connect(:user=>'someuser', :pass=>'somepass', :host=>'10.100.0.9', :port=>5672)
    
    amq = MQ.new(amqp)
    topic = amq.topic('festo')
    puts 'got topic'
    EventMachine::open_datagram_socket host, port, EasyIPHandler do | handler |
        handler.topic = topic
        handler.dbhelper=dbhelper
        puts 'running'
    end
  end
 
end




