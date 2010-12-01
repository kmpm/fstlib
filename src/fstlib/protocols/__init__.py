# coding=utf-8
#Copyright (c) 2009-2010 Peter Magnusson.
from twisted.internet import protocol #reactor, defer
from twisted.python import log
from fstlib import easyip
import logging

__all__=('TwistedEasyS')

class LogProxy(object):
    def debug(self, msg):
        log.msg(msg, logLevel=logging.DEBUG)

class TwistedEasyS(protocol.DatagramProtocol):
    """
    Warning!!!
    This class is experimental and not tested
    """
    def __init__(self):
        #self.log = logging.getLogger('easyip.EasyS')
        self.log=LogProxy()
            
    def startProtocol(self):
        pass
    
    def sendMsg(self, packet, (host, port)):
        self.log.debug('Sending data')
        self.transport.write(packet.pack(), (host, port))
            
    def datagramReceived(self, datagram, (host,port)):
        packet = easyip.Packet(datagram)
        response = self.react(packet)
        if response:
            self.sendMsg(response, (host, port))

    def react(self, packet):
        response = easyip.Packet();
        response.counter = packet.counter
        response.flags = 128
        return response
        