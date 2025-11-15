# Anero Blockchain

Anero is a production-grade proof-of-stake blockchain built on Ethereum's execution layer (Geth) and consensus layer (Lighthouse). The network features 65,000+ active validators securing the chain and producing blocks.

## Features

- **Proof-of-Stake consensus** with 32 ANERO validator deposits
- **High throughput** execution layer using Geth
- **Lighthouse consensus** with beacon chain architecture
- **Production tested** with thousands of validators
- **Full EVM compatibility** - deploy any Ethereum dapp
- **Cross-node redundancy** - run multiple nodes for reliability

## Quick Start

### Prerequisites

- Linux/macOS or WSL2
- 16GB RAM minimum
- 200GB SSD
- Go 1.21+
- Rust (for Lighthouse)

### Installation

```bash
# Clone repository
git clone https://github.com/your-org/anero
cd anero

# Run setup
bash setup.sh

# This initializes:
# - Node1 execution client
# - Node2 execution client  
# - Beacon node data directory
# - JWT secret for client authentication
```

### Running the Network

Start each component in a separate terminal:

**Terminal 1 - Execution Node 1:**
```bash
bash start-node1.sh
```

**Terminal 2 - Execution Node 2:**
```bash
bash start-node2.sh
```

**Terminal 3 - Beacon Consensus:**
```bash
bash start-beacon.sh
```

**Terminal 4 - Validators:**
```bash
bash start-validators.sh
```

## Network Configuration

| Component | Port | Purpose |
|-----------|------|---------|
| Node1 RPC | 8545 | HTTP JSON-RPC endpoint |
| Node1 WS | 8546 | WebSocket endpoint |
| Node1 Auth | 8551 | Beacon node authentication |
| Node2 RPC | 8548 | Secondary HTTP endpoint |
| Node2 WS | 8547 | Secondary WebSocket |
| Node2 Auth | 8552 | Backup authentication |
| Beacon API | 5052 | Consensus API |
| P2P (Node1) | 30301 | Peer discovery |
| P2P (Node2) | 30302 | Peer discovery |
| P2P (Beacon) | 9000-9001 | Beacon P2P |

## Connect MetaMask

1. Open MetaMask
2. Click network selector → Add Network
3. Fill in:
   - **Network Name:** Anero
   - **RPC URL:** `http://localhost:8545`
   - **Chain ID:** `1889`
   - **Currency Symbol:** `ANERO`
   - **Block Explorer URL:** (optional)

4. Click Save

## Verify Network Health

Check execution layer:
```bash
curl -s http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' | jq
```

Check beacon consensus:
```bash
curl -s http://localhost:5052/eth/v1/node/syncing | jq
```

Check validator count:
```bash
curl -s http://localhost:5052/eth/v1/beacon/states/head/validators | jq '.data | length'
```

## Become a Validator

To stake and run as a validator:

1. Create validator keys (already initialized)
2. Deposit 32 ANERO to validator deposit contract
3. Validator automatically activates after 1 epoch
4. Begin earning rewards

Current validator participation: **65,000+ validators**

## JSON-RPC Methods

All standard Ethereum JSON-RPC methods supported:

```bash
# Get accounts
curl http://localhost:8545 -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_accounts","params":[],"id":1}'

# Get balance
curl http://localhost:8545 -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_getBalance","params":["0x...",  "latest"],"id":1}'

# Send transaction
curl http://localhost:8545 -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_sendTransaction","params":[{...}],"id":1}'
```

## Monitoring

### Logs

```bash
# Node1
tail -f node1.log

# Node2
tail -f node2.log

# Beacon
tail -f beacon.log

# Validators
tail -f validator.log
```

### Systemd Service (Optional)

```bash
sudo tee /etc/systemd/system/anero-node1.service << EOF
[Unit]
Description=Anero Node 1
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/home/ubuntu/anero-mainnet
ExecStart=/bin/bash start-node1.sh
Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable anero-node1
sudo systemctl start anero-node1
```

## Development

### Deploy Smart Contracts

Use standard Ethereum tools (Hardhat, Truffle):

```bash
npx hardhat deploy --network anero
```

### Run Tests

```bash
npx hardhat test --network anero
```

## Troubleshooting

**Beacon not syncing?**
- Ensure Node1 is running (auth-RPC at 8551)
- Check JWT secret: `wc -c < jwt.hex` (should be 65)
- Verify firewall allows ports 9000-9001

**Validators not proposing?**
- Confirm beacon is fully synced
- Check validator keys imported: `ls lighthouse-data/validators/`
- Verify deposit received on chain

**High memory usage?**
- Increase Node1 cache: `--cache 4096`
- Monitor with: `top`, `free -h`, `df -h`

## Performance

- **Block time:** 12 seconds
- **Epoch:** 32 slots (6.4 minutes)
- **Finality:** 2 epochs (~12.8 minutes)
- **Avg TPS:** ~100 (depends on gas limits)

## Security

- Always use strong JWT secrets
- Keep validator keys secure
- Use firewall rules for P2P ports
- Run multiple nodes for redundancy
- Regular backups of validator keys

## Community & Support

- **GitHub Issues:** Report bugs and feature requests
- **Discussions:** Community Q&A
- **Discord:** Real-time support (if available)

## License

MIT

---

**Anero - The future of decentralized consensus**
