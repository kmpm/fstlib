require "test/unit"
require "libfst"
class Easy < Test::Unit::TestCase
  COUNTER_START = 20
  
  def test_basics
    
    a = EasyIP::Header.new
    a.flags=EasyIP::Flags::RESP
    a.counter = COUNTER_START
    a.send_type=EasyIP::Operand::STRING
    a.send_offset=10
    
    # puts EasyIP::Header.describe
    # puts a.inspect
    
    assert_equal 20*8, EasyIP::Header.bit_length
    assert_equal 128, a.flags
    assert_equal COUNTER_START, a.counter
    
    puts a.unpack("H*") #.first.scan(/\d{8,8}/)

  
  end
end
