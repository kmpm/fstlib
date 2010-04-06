# coding=utf-8
#Copyright (c) 2009 Peter Magnusson.

from struct import *
import logging

EASYIP_PORT=995

class Flags():
    EMPTY = 0
    BIT_OR=0x2
    BIT_AND=0x4
    NO_ACK=0x40
    RESPONSE=0x80

class Operands():
    EMPTY=0
    FLAG_WORD=1
    INPUT_WORD=2
    OUTPUT_WORD=3
    REGISTERS=4
    STRINGS=11

class Factory():
    
    @classmethod
    def send_string(cls, counter, string, string_no):
        packet = Packet()
        packet.counter = counter
        packet.error=0
        packet.senddata_type = Operands.STRINGS
        
        packet.senddata_offset = string_no
        count = packet.encode_payload(string, packet.DIRECTION_SEND)
        packet.senddata_size = count
        assert count
        return packet
    
    @classmethod
    def req_flagword(cls, counter, count, offset=0):
        packet = Packet()
        packet.counter=counter
        packet.error=0
        packet.reqdata_type=Operands.FLAG_WORD
        packet.reqdata_size=count
        packet.reqdata_offset_server = offset
        return packet
    
    @classmethod
    def req_string(cls, counter, offset=0):
        packet = Packet()
        packet.counter=counter
        packet.error=0
        packet.reqdata_type=Operands.STRINGS
        packet.reqdata_size=1
        packet.reqdata_offset_server = offset
        return packet
    
    @classmethod
    def response(cls, in_packet, error=0):
        packet = Packet()
        packet.counter = in_packet.counter
        packet.error=error
        packet.flags = Flags.RESPONSE
        return packet

class PayloadEncodingException(Exception):
    pass

class Packet(object):
    #L/H
    HEADER_FORMAT='<B B H H B B H H B B H H H'
    _FIELDS=['flags', 'error', 'counter', 'index1', 'spare1', 
        'senddata_type', 'senddata_size', 'senddata_offset', 
        'spare2', 'reqdata_type', 'reqdata_size', 'reqdata_offset_server',
        'reqdata_offset_client']
    DIRECTION_SEND=1
    DIRECTION_REQ=2
   
    def __init__(self, data=None):
        self.logger = logging.getLogger('fstlib.easyip')
        self.payload = None
        for f in self._FIELDS:
            setattr(self, f, 0)
        
        if data:
            self.logger.debug("len(data)=%d" % len(data))
            self.unpack(data);
            self.payload=data[calcsize(self.HEADER_FORMAT):]

    def unpack(self, data):
        self.logger.debug("Unpacking data")
        data = unpack(self.HEADER_FORMAT, data[0:calcsize(self.HEADER_FORMAT)])
        header=list(data)
        index = 0
        for f in self._FIELDS:
            setattr(self, f, header[index])
            index +=1
            
        self.logger.debug(self.__str__())
        return header
    
    def pack(self):
        header = []
        for f in self._FIELDS:
            header.append(getattr(self, f, 0))
            
        packed_header = pack(self.HEADER_FORMAT, *header)
        if self.payload and len(self.payload)>0:
            return packed_header + self.payload
        else:
            return packed_header
    
    
    def __str__(self):
        return "Packet(flags=%i error=%i counter=%i send_type=%i send_size=%i)" %  (
            self.flags, self.error, self.counter,
            self.senddata_type, self.senddata_size)

    def encode_payload(self, data, direction):
        count = None
        if direction==self.DIRECTION_SEND:
            type = self.senddata_type
        
        if type == Operands.STRINGS:
            if isinstance(data, list):
                #self.payload="\x00".join(data)
                #count = len(data)
                raise PayloadEncodingException("Payload can not be a list object!")
            elif isinstance(data, str) or isinstance(data, unicode):
                self.payload = str(data) + "\x00"
                count = 1
            else:
                self.payload = None
        else:
            self.payload = None
        return count
    
    def decode_payload(self, direction):
        count = 0
        type = Operands.EMPTY
        if direction==self.DIRECTION_SEND:
            count = self.senddata_size
            type = self.senddata_type
        else:
            count = self.reqdata_size
            type = self.reqdata_type
        
        if type == Operands.STRINGS:
            strings = self.payload.split("\0",count)
            strings.pop()
            return strings
        else:
            payload_format = '<' + "H "*count
            print "payload_format=%s" % payload_format
            return unpack(payload_format, self.payload)
    
    
    def response_errors(self, response):
        errors = []
        if response.flags != Flags.RESPONSE:
            errors.append('not a response packet')
            
        if response.counter != self.counter:
            errors.append('bad counter')
            
        if len(errors)>0:
            return errors
        else:
            return None