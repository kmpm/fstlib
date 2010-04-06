#!/usr/bin/env python
# coding=utf-8
from socket import *
from fstlib import easyip
from carrot.messaging import Publisher
from carrot.connection import BrokerConnection



conn=BrokerConnection(hostname='localhost', port=5672,
            userid='test', password='test',
            virtual_host='test')

publisher = Publisher(connection=conn, exchange="fst", exchange_type='topic',
        routing_key="easyip.incomming", serializer="json")
        




# Set the socket parameters
host = "localhost"
port = 1000 + easyip.EASYIP_PORT
buf = 1024
addr = (host,port)

# Create socket and bind to address
UDPSock = socket(AF_INET,SOCK_DGRAM)
UDPSock.bind(addr)

print "waiting"

# Receive messages
while 1:
    data,addr = UDPSock.recvfrom(buf)
    if not data:
        
        print "Client has exited!"
        break
    else:
        packet = easyip.Packet(data)
        print "\nReceived message '", packet,"' with %s" % (packet.payload,)
        response = easyip.Factory.response(packet)
        UDPSock.sendto(response.pack(), addr)
        print "Responded to %s, %s" % addr
        print "Putting incomming on queue"
        publisher.send({'address':addr, 
                'payload':packet.payload})
        
print "Closing"
# Close socket
UDPSock.close()
publisher.close()
