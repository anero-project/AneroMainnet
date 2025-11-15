#!/bin/bash
cd "$(dirname "$0")"
./lighthouse/target/release/lighthouse vc \
  --datadir ./lighthouse-data \
  --network mainnet \
  --suggested-fee-recipient 0xYOUR_WALLET_HERE \
  --beacon-nodes http://localhost:5052 \
  --debug-level debug
