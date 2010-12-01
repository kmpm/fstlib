#!/usr/bin/python
# -*- coding: utf-8 -*-
"""Tests for EasyIP"""
__autor__ = "Peter Magnusson"
__copyright__ = "Copyright 2009-2010, Peter Magnusson <peter@birchroad.net>"
__version__ = "1.0.0"

#Copyright (c) 2009-2010 Peter Magnusson.
#All rights reserved.
#
#Redistribution and use in source and binary forms, with or without modification,
#are permitted provided that the following conditions are met:
#
#    1. Redistributions of source code must retain the above copyright notice, 
#       this list of conditions and the following disclaimer.
#    
#    2. Redistributions in binary form must reproduce the above copyright 
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#
#    3. Neither the name of Peter Magnusson nor the names of its contributors may be used
#       to endorse or promote products derived from this software without
#       specific prior written permission.
#
#THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
#ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
#WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
#DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
#ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
#(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
#LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
#ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
#SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


    
from fstlib.easyip import *

import unittest
import binascii
import logging 
import logging.config



#various test strings
request = "000085000100000b01000a000000000000000000"
r2 = "\x00\x00\x85\x00\x01\x00\x00\x0b\x01\x00\n\x00\x00\x00\x00\x00\x00\x00\x00\x00"
r3 = "'|SMS|APA|Nu har fredrik skitit i det bl\xe5 sk\xe5pet;'"
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
        

    def test_pack_and_unpack(self):
        packet = Packet(self.fixRequest())
        original = self.fixRequest()
        wanted = packet.pack()
        for index in range(len(original)):
            self.assertEqual(original[index], wanted[index], "Byte %s differs. %r != %r" % (index, original[index], wanted[index]))

    def test_recreate(self):
        packet = Packet()
        packet.counter = 133
        packet.senddata_type = Operands.STRINGS
        packet.senddata_offset = 10
        packet.senddata_size=1
        packet.index1=1
        original = self.fixRequest()[:20]
        wanted = packet.pack()
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
