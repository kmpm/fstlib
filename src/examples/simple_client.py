#!/usr/bin/env python
# coding=utf-8
#Copyright (c) 2009-2010 Peter Magnusson.
from socket import *
from fstlib import easyip

# Set the socket parameters
host = "localhost"
port = 1000 + easyip.EASYIP_PORT
buf = 1024
addr = (host,port)


class SimpleClient(object):
    def __init__(self, host):
        self.UDPSock = socket(AF_INET,SOCK_DGRAM)
        self.UDPSock.bind(('0.0.0.0', 0))
        self.counter = 0
        self.addr = (host,easyip.EASYIP_PORT)
        
    def request_fw(self):
        print "Flagwords to get"
        while 1:
            count = raw_input('Count:>> ')
            
            if not count or int(count)==0:
                break
            else:
                count=int(count)
                offset = int(raw_input('Offset:>> '))
                self.counter += 1
                packet = easyip.Factory.req_flagword(self.counter, count, offset)
                resp = self.send_packet(packet)
                values = resp.decode_payload(easyip.Packet.DIRECTION_REQ)
                i =0 
                for v in values:
                    print "Value %d=%s" % (i, v)
                    i += 1
    
    def send_fw(self):
        print "Flagword(s) to send"
        datas = []
        while 1:
            data = raw_input('[%s]>> ' % len(datas))
            if not data:
                break
            else:
                datas.append(int(data))
        
        if len(datas)>0:
            offset = int(raw_input('Offset:>> '))
            self.counter += 1
            packet = easyip.Factory.send_flagword(self.counter, datas, offset)
            resp = self.send_packet(packet)

        
    def request_string(self):
        print "String to get"
        while 1:
            offset = raw_input('Offset:>> ')
            
            if not offset:
                break
            else:
                offset=int(offset)
                self.counter += 1
                packet = easyip.Factory.req_string(self.counter, offset)
                resp = self.send_packet(packet)
                values = resp.decode_payload(easyip.Packet.DIRECTION_REQ)
                i =0 
                for v in values:
                    print "Value %d=%s" % (i, v)
                    i += 1
                    
        
    def send_packet(self, packet):
        data = packet.pack()
        if(self.UDPSock.sendto(data,self.addr)):
                print "Sending message '",packet,"'....."
        data,srvaddr = self.UDPSock.recvfrom(buf)
        resp = easyip.Packet(data)
        print "%s as response" % resp
        print "errors=%r" % packet.response_errors(resp)
        return resp
        
        
    def send(self):
        # Send message
        print "What to send"
        while 1:
            data = raw_input('>> ')
            if not data:
                #UDPSock.sendto(data, addr)
                break
            else:
                string_no = int(raw_input('string number>> '))
                self.counter += 1
                packet = easyip.Factory.send_string(self.counter, data, string_no)
                self.send_packet(packet)
    
    def close(self):
        # Close socket
        self.UDPSock.close()       

if __name__=="__main__":
    import sys
    if len(sys.argv)<2:
        sys.exit('Usage: %s <host>' % sys.argv[0])
    host = sys.argv[1]
    sc = SimpleClient(host)
    while 1:
        print """Select option and press enter
            1: Request Flagword(s)
            2: Request String
            3: Send Flagword(s)
            4: Send String
        empty: Exit
        """
        data = raw_input('>> ')
        if not data:
            break
        elif data=="1":
            sc.request_fw()
        elif data=="2":
            sc.request_string()
        elif data=="3":
            sc.send_fw()
        elif data=="4":
            sc.send()
        else:
            break;
    sc.close()
   
    