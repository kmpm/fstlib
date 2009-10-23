from twisted.internet import reactor, defer, protocol
from twisted.python import log
import logging

class EasyS(protocol.DatagramProtocol):
    def __init__(self):
        self.log = logging.getLogger('easyip.EasyS')
            
    def startProtovol(self):
        pass
    
    def sendMsg(self, packet, (host, port)):
        self.log.debug('Sending data')
        self.transport.write(packet.pack(), (host, port))
            
    def datagramReceived(self, datagram, (host,port)):
        packet = EasyIPPacket(datagram)
        response = self.react(packet)
        if response:
            self.sendMsg(response, (host, port))

    def react(self, packet):
        response = EasyIPPacket();
        response.counter = packet.counter
        response.flags = 128
        return response
        