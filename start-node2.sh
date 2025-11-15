#!/bin/bash
cd "$(dirname "$0")"
JWT=$(cat jwt.hex)
geth \
  --datadir ./node2 \
  --networkid 1337 \
  --http \
  --http.addr 0.0.0.0 \
  --http.port 8548 \
  --http.api admin,debug,eth,miner,net,personal,txpool,web3 \
  --http.corsdomain "*" \
  --ws \
  --ws.addr 0.0.0.0 \
  --ws.port 8547 \
  --ws.api admin,debug,eth,miner,net,personal,txpool,web3 \
  --authrpc.addr localhost \
  --authrpc.port 8552 \
  --authrpc.vhosts localhost,127.0.0.1 \
  --authrpc.jwtsecret ./jwt.hex \
  --nodiscover \
  --syncmode full \
  --port 30302 \
  --verbosity 3
