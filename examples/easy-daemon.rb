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
        puts "Got data from", address
        s.send(message, address)
   
  end
end