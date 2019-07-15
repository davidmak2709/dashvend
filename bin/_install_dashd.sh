#!/bin/bash

if [ -e ~/dash/dash.conf ]; then
    exit 0
fi

echo "installing dashd"

mkdir -p ~/dash/testnet/testnet3
cp -f bin/.dash.conf.template ~/dash
cd ~/dash
touch dashd.pid testnet/testnet3/dashd.pid
if [ ! -e dashcore-0.14.0 ]; then
    wget https://github.com/dashpay/dash/releases/download/v0.14.0.2/dashcore-0.14.0.2-x86_64-linux-gnu.tar.gz
fi
tar zxvf dashcore-0.14.0.2-x86_64-linux-gnu.tar.gz
rm dashcore-0.14.0.2-x86_64-linux-gnu.tar.gz
ln -s dashcore-0.14.0/bin/dash-cli .
ln -s dashcore-0.14.0/bin/dashd .

export PATH=~/dash:$PATH
echo 'export PATH=~/dash:$PATH' >> ~/.bashrc

if [ ! -e bootstrap.dat ]; then
    wget https://raw.githubusercontent.com/UdjinM6/dash-bootstrap/master/links-mainnet.md -O links-mainnet.md
    MAINNET_BOOTSTRAP_FILE=$(head -1 links-mainnet.md | awk '{print $9}' | sed 's/.*\(http.*\.zip\).*/\1/')
    wget $MAINNET_BOOTSTRAP_FILE
    unzip ${MAINNET_BOOTSTRAP_FILE##*/}
    rm links-mainnet.md bootstrap.dat*.zip
fi

cd testnet/testnet3
#if [ ! -e bootstrap.dat ]; then
#    wget https://raw.githubusercontent.com/UdjinM6/dash-bootstrap/master/links-testnet.md -O links-testnet.md
#    TESTNET_BOOTSTRAP_FILE=$(head -1 links-testnet.md | awk '{print $9}' | sed 's/.*\(http.*\.zip\).*/\1/')
#    wget $TESTNET_BOOTSTRAP_FILE
#    unzip ${TESTNET_BOOTSTRAP_FILE##*/}
#    rm links-testnet.md bootstrap.dat*.zip
#fi

# build confs
function render_conf() {
    RPCUSER=`echo $(dd if=/dev/urandom bs=128 count=1 2>/dev/null) | sha256sum | awk '{print $1}'`
    RPCPASS=`echo $(dd if=/dev/urandom bs=128 count=1 2>/dev/null) | sha256sum | awk '{print $1}'`
    while read; do
        eval echo "$REPLY"
    done < .dash.conf.template > $1
}
cd ../..
render_conf dash.conf
render_conf testnet/dash.conf
echo "testnet=1" >> testnet/dash.conf
