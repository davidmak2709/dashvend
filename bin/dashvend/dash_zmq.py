import zmq
import binascii
import struct

from bitcoinrpc.authproxy import JSONRPCException

class DashZMQ(object):

    def __init__(self, mainnet=False, host="tcp://127.0.0.1", port=10001,dashrpc=None):
        self.host = host
        self.port = port
        self.txs = []
        
        self.dashrpc = dashrpc
        if self.dashrpc is None:
            # TODO: set new dashRPC connection 
            print("DashRPC not set")
            
        
    def connect(self):
        self.zmqContext = zmq.Context()
        self.zmqSubSocket = self.zmqContext.socket(zmq.SUB)
        
        self.zmqSubSocket.setsockopt(zmq.SUBSCRIBE, b"hashtx")
        self.zmqSubSocket.setsockopt(zmq.SUBSCRIBE, b"hashtxlock")
        self.zmqSubSocket.connect("{}:{}".format(self.host, self.port))
    
    def set_vend(self,vend):
        self.vend = vend
    
    def listen(self):
        while True:
            msg = self.zmqSubSocket.recv_multipart()
            topic = str(msg[0].decode("utf-8"))
            body = msg[1]
            sequence = "Unknown"

            if len(msg[-1]) == 4:
                msgSequence = struct.unpack('<I', msg[-1])[-1]
                sequence = str(msgSequence)
                
            if topic == "hashtx":
                h = binascii.hexlify(body).decode("utf-8")
                try: 
                    transaction = self.dashrpc._proxy.gettransaction(h, True)
                    self.txs.append(h)
                except JSONRPCException as e:
                    pass
            elif topic == "hashtxlock":
                h = binascii.hexlify(body).decode("utf-8")
                try:
                    transaction = self.dashrpc._proxy.gettransaction(h, True)
                    if transaction["instantlock"]:
                        self.vend.process_IS_transaction(tx=transaction)
                            
                except JSONRPCException as e:
                    pass
            