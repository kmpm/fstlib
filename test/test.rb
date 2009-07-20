require "test/unit"
require "fstlib"
class Easy < Test::Unit::TestCase
  COUNTER_START = 5
  
  def test_header
    
    header = EasyIP::Header.new
    header.flags=EasyIP::Flags::RESP
    header.error=3
    header.counter = 5
    header.send_type=EasyIP::Operand::INPUT_WORD
    header.send_size=0xBBCC
    header.send_offset=0xAAEE
    
    # puts EasyIP::Header.describe
    # puts a.inspect
    
    assert_equal 20*8, EasyIP::Header.bit_length
    
    assert_equal EasyIP::Flags::RESP, header[0]
    assert_equal 3, header[1]
    assert_equal 5, header[2], 'wrong counter LSB'
    assert_equal 0, header[3], 'wrong counter MSB'
    
    puts header.unpack("H*") #.first.scan(/\d{8,8}/)

  
  end
end
