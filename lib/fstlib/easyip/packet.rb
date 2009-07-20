require 'rubygems'
require 'bit-struct'
module EasyIP
  
  class Header < BitStruct
    unsigned  :flags,               8 #EasyIP::Flags
    unsigned  :error,               8
    unsigned  :counter,             16, :endian => :little
    unsigned  :index,               16
    unsigned  :spare1,              8,  :endian => :little
    unsigned  :send_type,           8 #EasyIP::Operand
    unsigned  :send_size,           16, :endian => :little
    unsigned  :send_offset,         16, :endian => :little
    unsigned  :spare2,              8
    unsigned  :req_type,            8 #EasyIP::Operand
    unsigned  :req_size,            16, :endian => :little
    unsigned  :req_offset_server,   16, :endian => :little
    unsigned  :req_offset_client,   16, :endian => :little
    rest :data
  end
  
end
