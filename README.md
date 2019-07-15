# dashvend

Example system for processing Dash InstantSend payments

This repo contains everything needed to recreate the Miami "dash'n'drink" soda
machine InstantSend tech demo.

# overview

Dashvend is a network-driven python script which:
 - generates payment addresses
 - masquerades as a local dashd peer (port 9999 communication)
 - watches for transactions on the dash network
 - refunds over/underpaid transactions
 - triggers two relays (sign light, product release) when a wallet transaction
 is found

## processing overview

    network traffic -> dashd -> dash_zmq.py -> vend.py -> screen/relay


The dashd publish every incoming 'hashtxlock' message on the ZMQ interface. The
dash_zmq.py script is subscribed to the ZMQ interface and waits for messages.
When a message is published the dash_zmq checks if the transaction belongs to
the wallet and if it is true then the transaction ID is forwarded to vend.py which
process the transaction.

# component overview
## dashvend

    bin/dashvend.py          - top-level script
    bin/dashvend/config.py   - system configuration variables
    bin/dashvend/dashrpc.py  - dashd rpc communication (refunds, balances)
    bin/dashvend/dash_zmq.py - listens for wallet transactions
    bin/dashvend/display.py  - display controller (setuid bash wrapper)
    bin/dashvend/trigger.py  - relay controller (setuid bash wrapper)
    bin/dashvend/vend.py     - main application

## helpers
    bin/_install_dashd.sh         - fresh install - Makefile utility
    /etc/init.d/dashvend          - starts dashd/dashvend on boot/shutdown
    bin/_dashvend_control.sh      - called by above, starts/stops screen processes
    bin/dashvend_screens.screenrc - gnu screen config file for above
    bin/trigger_relay             - setuid script, calls .sh file below
    bin/trigger_relay.sh          - run as root, triggers gpio pins
    display/show_image            - setuid script, calls .sh file below
    display/show_image.sh         - run as root, invokes fbi to display image
    display/show_screen_number.sh - screen image builder, uses imagemagic
    display/source_images/        - source images for above


# boot sequence

After running 'make init', on boot, /etc/init.d/dashvend will (through
bin/_dashvend_control.sh) start a screen session named 'dashvend_screens' with
two screens running:
- dashd (printtoconsole=1) (no debug.log writing to sd card)
- bin/dashvend.py (the main application)

Once the cpu load settles to under 50%, the vending app indicates it is ready to
process payments.

# install

For relay and 480x800 lcd display support, you'll need to build or download the
raspberry pi 3 image shown below.

Once you have a base image, run the following to install all the dashvend dependencies:

    git clone https://github.com/moocowmoo/dashvend.git
    cd dashvend
    make
    # after entering your sudo password, allow several hours/overnight for
    # dashd to finish bootstrapping the blockchain

# dedicated raspberry pi 3 install

## hardware

To build your own dash'n'drink implementation you'll need:
- a raspberry pi 3 model B+
- an hdmi monitor and attached keyboard (to build the image)
- a 800x480 pixel [lcd screen](https://images-na.ssl-images-amazon.com/images/I/61DkEsboSpL._SX425_.jpg)
- any 5v dual relay board attached to (gpio 5 (sign light) and 6 (soda release), pins 29 and 31)

A 2 amp power supply is recommended for stability.

## building the base image

Write image 'raspbian buster lite' found on https://www.raspberrypi.org/downloads/raspbian/ to an sd card.

 - attach keyboard, hdmi monitor, ethernet, sd card
 - boot
 - login as pi, password raspberry
 - change pi password
 - resize partition with 'raspi-config'
 - reboot
 - configure /boot/config.txt and /boot/cmdline.txt for 480x800 screen
 - connect lcd
 - reboot
 - sudo apt-get update
 - sudo apt-get upgrade
 - sudo apt-get install git
 - configure wifi - https://www.raspberrypi.org/documentation/configuration/wireless/wireless-cli.md
 - ssh in through wifi
 - disconnect ethernet
 - reboot
 - ssh in through wifi
 - install dashvend

## 480x800 hdmi lcd screen configuration
### /boot/config.txt

    disable_overscan=1
    hdmi_force_hotplug=1
    hdmi_group=2
    hdmi_mode=87
    hdmi_cvt 800 480 60 6 0 0 0
    display_rotate=3
    gpu_mem=16
    dtparam=spi=off

### /boot/cmdline.txt
    add consoleblank=0
    for example:
    dwc_otg.lpm_enable=0 console=ttyAMA0,115200 console=tty1 consoleblank=0 root=/dev/mmcblk0p2 rootfstype=ext4 elevator=deadline fsck.repair=yes rootwait

### /etc/kbd/config
    BLANK_TIME=0
    POWERDOWN_TIME=0
    BLANK_DPMS=on

## post-install setup

### refunds
You will need to fund the local wallet to process refunds. do:

    dash-cli getnewaddress

and send some dash to it.

If the local wallet has insufficient funds to process a refund/bounce, it will
write an error in the log file until funded.
