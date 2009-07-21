#!/usr/bin/ruby 
require "fstlib"
if __FILE__ == $0
  header = EasyIP::Packet.new
  puts EasyIP::Packet.describe
  puts header.inspect
  puts header.unpack("H*") #.first.scan(/\d{8,8}/)
end