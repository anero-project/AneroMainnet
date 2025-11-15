#!/bin/bash
cd "$(dirname "$0")"
JWT=$(cat jwt.hex)
geth --datadir ./node1 \
  --networkid 1889 \
  --http \
  --http.addr 0.0.0.0 \
  --http.port 8545 \
  --http.vhosts "localhost,127.0.0.1,node.getanero.org" \
  --http.api eth,net,web3,admin,debug,txpool,personal \
  --http.corsdomain "*" \
  --ws \
  --ws.addr 0.0.0.0 \
  --ws.port 8546 \
  --ws.api eth,net,web3,admin,debug,txpool,personal \
  --authrpc.addr 0.0.0.0 \
  --authrpc.port 8551 \
  --authrpc.vhosts "*" \
  --authrpc.jwtsecret ./jwt.hex \
  --nat extip:3.128.66.2 \
  --syncmode full \
  --port 30301 \
  --verbosity 3
