#!/bin/bash
cd "$(dirname "$0")"
JWT=$(cat jwt.hex)
./lighthouse/target/release/lighthouse bn \
  --datadir ./lighthouse-data/beacon \
  --network mainnet \
  --http \
  --http-address 0.0.0.0 \
  --http-port 5052 \
  --execution-endpoint http://localhost:8551 \
  --execution-jwt-secret-key "$JWT" \
  --enr-address 3.128.66.2 \
  --enr-udp-port 9000 \
  --enr-tcp-port 9001 \
  --disable-enr-auto-update
