#!/usr/bin/env python

from carrot.messaging import Consumer
from carrot.connection import BrokerConnection

conn=BrokerConnection(hostname='localhost', port=5672,
            userid='test', password='test',
            virtual_host='test')

consumer = Consumer(connection=conn, queue="feed",
                    exchange_type='topic',
                     exchange="fst", routing_key="easyip.*")
#publisher = Publisher(connection=conn, exchange="fst", exchange_type='topic',
#        routing_key="easyip.incomming", serializer="json")


def get_using_callback(message_data, message):
    print "%s" % message_data
    message.ack()
    
    
consumer.register_callback(get_using_callback)
consumer.wait()