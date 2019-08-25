#!/bin/bash

DASHDIR=/home/pi/.dashcore
VENDDIR=/home/pi/dashvend

cd $VENDDIR/bin

case "$1" in
  start)
    echo "starting"
    # rm $DASHDIR/{budget,fee_estimates,mncache,mnpayments,peers}.dat 2>/dev/null
    # launch testnet OR mainnet dashd depending on config.py
    MAINNET=$(grep -w MAINNET $VENDDIR/bin/dashvend/config.py | grep -i True | wc -l)
    SCREENRC=$VENDDIR/bin/dashvend_screens-testnet.screenrc
    if [ $MAINNET -gt 0 ]; then
        SCREENRC=$VENDDIR/bin/dashvend_screens-mainnet.screenrc
    fi;
    /usr/bin/screen -dmS dashvend_screens -c $SCREENRC
    exit 0
    ;;
  restart|reload|force-reload)
#    $DASHDIR/dash-cli stop &
#    $DASHDIR/dash-cli -datadir=$DASHDIR/testnet stop &
#    sleep 45
#    # FIXME need to tear down the vend engine too
#    screen -dmS vend_engine -c vend_screens.screenrc
    echo "not implemented"
    exit 1
    ;;
  stop)
    $VENDDIR/display/show_screen_number.sh 4
    killall dashvend.py
    $DASHDIR/dash-cli stop &
    $DASHDIR/dash-cli -datadir=$DASHDIR/testnet stop &
    sleep 60
    exit 0
    ;;
  status)
    exit 0
    ;;
  *)
    echo "Usage: $0 start|stop" >&2
    exit 3
    ;;
esac
