#!/bin/bash

echo "Generating mainnet seed"
ku -n DASH -s 0p/0 P:$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 100 | head -n 1 ) > ku-mainnet.txt
MAINNET_SEED=$(awk '/public version/ {print $4}' ku-mainnet.txt )$(sed -n -e 9p ku-mainnet.txt)
MAINNET_SEED=$(echo $MAINNET_SEED | sed 's/[^a-zA-Z0-9]//g')

echo $MAINNET_SEED > ./bin/dashvend/BIP32_MAINNET_SEED
echo "Done."

echo "Generating testnet seed"
ku -n TDASH -s 0p/0 P:$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 100 | head -n 1 ) > ku-testnet.txt
TESTNET_SEED=$(awk '/public version/ {print $4}' ku-testnet.txt )$(sed -n -e 9p ku-testnet.txt)
TESTNET_SEED=$(echo $TESTNET_SEED | sed 's/[^a-zA-Z0-9]//g')

echo $TESTNET_SEED > ./bin/dashvend/BIP32_TESTNET_SEED
echo "Done."
