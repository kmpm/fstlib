# coding=utf-8
#Copyright (c) 2009 Peter Magnusson.
import unittest
import binascii
import logging 
import logging.config

from fstlib.easyip import *

request = "000085000100000b01000a000000000000000000"
r2 = "\x00\x00\x85\x00\x01\x00\x00\x0b\x01\x00\n\x00\x00\x00\x00\x00\x00\x00\x00\x00"
r3 = "'|SMS|APA|Nu har fredrik skitit i det bl\xe5 sk\xe5pet;'"
#r4="\x00"
r4 = "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"

class TestPacket(unittest.TestCase):
    logging.config.fileConfig('log.ini')
    logging.debug('Testing started')
    def fixRequest(self):
        return binascii.a2b_hex(binascii.b2a_hex(r2)) + eval(r3) + binascii.a2b_hex(binascii.b2a_hex(r4))
    
    def setUp(self):
        logging.debug('test running')
    
    def tearDown(self):
        logging.debug('test ended')

    
    def testdata(self):
        packet = Packet(self.fixRequest())
        
        self.assertEqual(packet.flags, 0)
        self.assertEqual(packet.counter, 133)
        self.assertEqual(packet.index1, 1)
        self.assertEqual(packet.senddata_type, Operands.STRINGS)
        self.assertEqual(packet.senddata_offset, 10)
        self.assertEqual(packet.senddata_size,1) 
        
        #print "%r" % packet.payload

    def test_pack_and_unpack(self):
        packet = Packet(self.fixRequest())
        original = self.fixRequest()
        wanted = packet.pack()
        #print 
        #print repr(original)
        #print repr(wanted)
        for index in range(len(original)):
            self.assertEqual(original[index], wanted[index], "Byte %s differs. %r != %r" % (index, original[index], wanted[index]))

    def test_recreate(self):
        packet = Packet()
        packet.counter = 133
        packet.senddata_type = Operands.STRINGS
        packet.senddata_offset = 10
        packet.senddata_size=1
        packet.index1=1
        #packet.payload="|SMS|APA|Nu har Fredrik Skitit i det blå skåpet;"
        #packet.senddata_size=len(packet.payload)
        original = self.fixRequest()[:20]
        wanted = packet.pack()
        #print
        #print repr(original)
        #print repr(wanted)
        for index in range(len(original)):
            self.assertEqual(original[index], wanted[index], "Byte %s differs. %r != %r" % (index, original[index], wanted[index]))
    
    def test_packet_factory(self):
        packet = Factory.send_string(1, "apa", 10)
        self.assertEqual(1, packet.counter )
        self.assertEqual(10, packet.senddata_offset)
        self.assertEqual(Operands.STRINGS, packet.senddata_type)
        self.assertEqual(0, packet.error)
        
        packet2 = Factory.response(packet)
        self.assertEqual(packet.counter, packet2.counter)
        self.assertEqual(Flags.RESPONSE, packet2.flags)
        
    def test_payload_decoding(self):
        packet = Packet(self.fixRequest())
        decoded= packet.decode_payload(Packet.DIRECTION_SEND)
        self.assertTrue(isinstance(decoded, list))
        self.assertEqual(1, len(decoded))
        
    def test_payload_encoding(self):
        packet = Packet(self.fixRequest())
        packet.encode_payload("Hej", Packet.DIRECTION_SEND)
        self.assertTrue(isinstance(packet.payload, str))
        self.assertEqual(4, len(packet.payload))

if __name__ == '__main__':
	unittest.main()
