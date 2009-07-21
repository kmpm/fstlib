# Easy-IP Protocol stuff
require 'rubygems'
require 'bit-struct'


module EasyIP
  # Operands enum for the send and req types
  class Operand
    EMPTY=0
    FLAG_WORD=1
    INPUT_WORD=2
    OUTPUT_WORD=3
    REGISTERS=4
    STRING=11
  end
  
  # Flags enum for the packet flag 
  class Flags
    EMPTY=0
    INFO=1
    BIT_OR=2
    BIT_AND=4
    NO_ACK=0x40
    RESP=0x80
  end
  
  # Header of a Easy-IP Packet
  # All word (2 byte) values is in little endian
  # 
  # Values for flags, send_type and req_type comes from
  # FSTLib::EasyIP::Flags and FSTLib::EasyIP::Operand
  #
  class Header < BitStruct
    default_options :endian => :little

    # Defines the flags for the packet
    # OR:ed values from EasyIP::Flags
    unsigned  :flags,               8 #EasyIP::Flags
    unsigned  :error,               8
    unsigned  :counter,             16
    unsigned  :index,               16
    unsigned  :spare1,              8
    unsigned  :send_type,           8 #EasyIP::Operand
    unsigned  :send_size,           16
    unsigned  :send_offset,         16
    unsigned  :spare2,              8
    unsigned  :req_type,            8 #EasyIP::Operand
    unsigned  :req_size,            16
    unsigned  :req_offset_server,   16
    unsigned  :req_offset_client,   16
    rest :data
    
    # Sets data field to whatever payload is wanted
    # Inputs can be arrays of either strings, unsigned 16-bit values
    # or a single string
    def payload=(new_payload)
      case new_payload
        when Array
          case new_payload[0]
            when String
              self.data = new_payload.pack("Z*")
            else
              self.data = new_payload.pack("v" * new_payload.length)
          end
        else
          self.data = [new_payload].pack("Z*")
      end
      #self.data = new_payload
    end
    
    # Returns the correct payload depending on send_type and it will always be a Array
    # EasyIP::Operand::STRING will be give you an array of strings
    # Every one else will return a array of unsigned 16-bit values.
    def payload
      if self.send_type == EasyIP::Operand::STRING
        self.data.unpack("Z*")
      else
        values = self.data.unpack("v" * self.send_size)
      end
    end  
  end    
  
  
  
end
  
