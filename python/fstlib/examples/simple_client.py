#!/usr/bin/env python
# coding=utf-8
from socket import *
from fstlib import easyip

# Set the socket parameters
host = "localhost"
port = 1000 + easyip.EASYIP_PORT
buf = 1024
addr = (host,port)


UDPSock = socket(AF_INET,SOCK_DGRAM)

UDPSock.bind((host, 0))

print "What to send"

counter = 0

# Send message
while 1:
    data = raw_input('>> ')
    if not data:
        UDPSock.sendto(data, addr)
        break
    else:
        counter += 1
        packet = easyip.Factory.send_string(counter, data, 10)
        data = packet.pack()
        if(UDPSock.sendto(data,addr)):
            print "Sending message '",packet,"'....."
        data,srvaddr = UDPSock.recvfrom(buf)
        resp = easyip.Packet(data)
        print "%s as response" % resp
        print "errors=%r" % packet.response_errors(resp)


# Close socket
UDPSock.close()
