require 'fstlib/easyip/packet'

module EasyIP
  class Operand
    EMPTY=0
    FLAG_WORD=1
    INPUT_WORD=2
    OUTPUT_WORD=3
    RESITERS=4
    STRING=11
  end
  
  class Flags
    EMPTY=0
    BIT_OR=2
    BIT_AND=4
    NO_ACK=0x40
    RESP=0x80
  end
  
end
