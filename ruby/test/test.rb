require "test/unit"
require "fstlib"
class Easy < Test::Unit::TestCase
  COUNTER_START = 5
  SINGLE_A =    [0x00, 0x00, 0xf7, 0xb2, 0x01, 0x00, 0x00, 0x0b, 0x01, 0x00, 0x0b, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x41, 0x00, 0x64, 0x00, 0x00, 0x00]
  DOUBLE_A =    [0x00, 0x00, 0xf8, 0xb2, 0x01, 0x00, 0x00, 0x0b, 0x01, 0x00, 0x0b, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x41, 0x41, 0x00, 0x6c, 0x00, 0x00, 0x00, 0x00]
  LONG_STRING = [0x00, 0x00, 0xf4, 0xb2, 0x01, 0x00, 0x00, 0x0b, 0x01, 0x00, 0x0b, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x41, 0x41, 0x41, 0x41, 0x41, 0x41, 0x41, 0x41, 0x41, 0x41, 0x61, 0x61, 0x61, 0x61, 0x61, 0x61, 0x61, 0x61, 0x61, 0x61, 0x42, 0x42, 0x42, 0x00, 0x41, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
  TWO_WORDS=    [0x00,0x00,0x0A,0x00,0x00,0x00,0x00,0x01,0x02,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xFF,0x00,0xFE,0x00]
  
  def dump_packet(packet)
    puts packet.unpack("H*")#.first.scan(/\d{8,8}/)
  end
  
  def pack_packet(byte_array)
    byte_array.pack("C" * byte_array.length)
  end
  
  def test_header_format
    
    header = EasyIP::Header.new
    header.flags=EasyIP::Flags::RESP
    header.error=3
    header.counter = 0xABC
    header.index=0xDEF
    header.send_type=EasyIP::Operand::INPUT_WORD
    header.send_size=0xBBCC
    header.send_offset=0xAAEE
    
    #dump_packet header 
    
    assert_equal 20*8, EasyIP::Header.bit_length
    assert_equal EasyIP::Flags::RESP, header[0]
    assert_equal 3, header[1], 'wrong error value'
    assert_equal 0xBC, header[2], 'wrong counter LSB'
    assert_equal 0xA, header[3], 'wrong counter MSB'
    assert_equal 0xEF, header[4], 'index LSB'
    assert_equal 0xD, header[5], 'index MSB'
    assert_equal 0 , header[6], 'spare1'
    assert_equal 2, header[7], 'send_type'
    assert_equal 0xCC, header[8], 'send_size LSB'
    assert_equal 0xBB, header[9], 'send_size MSB'
    assert_equal 0xEE, header[10], 'send_offset LSB'
    assert_equal 0xAA, header[11], 'send_offset MSB'
    
    header2 = EasyIP::Header.new(header)
  
    assert_equal header.send_size, header2.send_size
  end
  
  def test_parse_string
    s = LONG_STRING.pack("C" * LONG_STRING.length)
    header = EasyIP::Header.new(s)
    #dump_packet header
    assert_equal EasyIP::Operand::STRING, header.send_type
    assert_equal 1, header.send_size
    assert_equal 1, header.index
    assert_equal 11, header.send_offset
    assert_equal ["AAAAAAAAAAaaaaaaaaaaBBB"], header.payload
  end
  
  def test_create_string
    header = EasyIP::Header.new
    header.flags=EasyIP::Flags::EMPTY
    header.error=0
    header.counter = 0xB2F4
    header.index = 1
    header.send_type=EasyIP::Operand::STRING
    header.send_size=1
    header.send_offset=11
    header.payload =  ["AAAAAAAAAAaaaaaaaaaaBBB"].pack("Z*")
    dump_packet header
    
    s = LONG_STRING.pack("C" * LONG_STRING.length)
    #header = EasyIP::Header.new(s)
    dump_packet s
    
  end
  
  def test_two_words
    header = EasyIP::Header.new(TWO_WORDS.pack("C" * TWO_WORDS.length))
    
    assert_equal EasyIP::Operand::FLAG_WORD, header.send_type
    assert_equal 2, header.send_size
    assert_equal 0, header.send_offset
    assert_equal 255, header.payload[0]
    assert_equal 254, header.payload[1]
    
  end
  
  # Test that a decoded payload can be inserted as a new payload
  # and still come out as the same stuff
  def test_payload_roundtrip
    # Test with values
    header = EasyIP::Header.new(pack_packet(TWO_WORDS))
    payload1 = header.payload
    header.payload=  payload1
    assert_equal payload1, header.payload
    
    # Test with string array
    header = EasyIP::Header.new(pack_packet(LONG_STRING))
    payload1 = header.payload
    header.payload = payload1
    assert_equal payload1, header.payload
    
    # Test with single string
    header.payload = "test"
    assert_equal ["test"], header.payload
  end
  
end
