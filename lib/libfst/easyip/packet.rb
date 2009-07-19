require 'rubygems'
require 'bit-struct'
module EasyIP
  
  class Header < BitStruct
    unsigned  :flags, 8
    unsigned  :error, 8
    unsigned  :counter, 16
    unsigned  :index, 16
    unsigned  :spare1, 8
    unsigned  :send_type, 8
    unsigned  :send_size, 16
    unsigned  :send_offset, 16
    unsigned  :spare2, 8
    unsigned  :req_type, 8
    unsigned  :req_size, 16
    unsigned  :req_offset_server, 16
    unsigned  :req_offset_client, 16
    rest :data
  end
  
end