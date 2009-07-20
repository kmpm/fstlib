#!/usr/bin/ruby 
require "fstlib"
if __FILE__ == $0
  header = EasyIP::Header.new
  puts EasyIP::Header.describe
  puts header.inspect
  puts header.unpack("H*") #.first.scan(/\d{8,8}/)
end