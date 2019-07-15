#!/usr/bin/env python

import time

from dashvend.logger import info  # stdout and file logging
from dashvend.addresses import Bip32Chain  # purchase addresses
from dashvend.dashrpc import DashRPC  # local daemon - balances/refunds
from dashvend.dash_zmq import DashZMQ # dash network monitor (transactions)
from dashvend.vend import Vend  # main app and hardware interface

from dashvend.config import MAINNET  # dash network to use
from dashvend.config import VENDING_COST  # dash amount required for purchase


if __name__ == "__main__":
    dashrpc = DashRPC(mainnet=MAINNET)
    dashzmq = DashZMQ(mainnet=MAINNET,dashrpc=dashrpc)

    vend = Vend()
    dashzmq.connect()
    dashzmq.set_vend(vend)
    
    
    info("connecting to dashd, waiting for masternode and budget sync")
    dashrpc.connect()
    while(not dashrpc.ready()):
        time.sleep(10)

    bip32 = Bip32Chain(mainnet=MAINNET, dashrpc=dashrpc)

    vend.set_address_chain(bip32)  # attach address chain
    vend.set_product_cost(VENDING_COST)  # set product cost in dash
    vend.set_dashrpc(dashrpc)  # attach local wallet for refunds

    while True:
        dashrpc.connect()
        info("waiting for dashd to finish synchronizing")
        while(not dashrpc.ready()):
            time.sleep(10)
        vend.set_state(Vend.READY)
        info("*" * 80)
        info(" --> ready. listening to dash %s network." % (MAINNET and 'mainnet' or 'testnet'))
        dashzmq.listen()
        time.sleep(1)
