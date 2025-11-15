# Anero Blockchain - Installation Guide

## System Requirements

- **OS:** Linux (Ubuntu 20.04+), macOS, or WSL2 on Windows
- **CPU:** 4+ cores recommended
- **RAM:** 16GB minimum, 32GB recommended
- **Storage:** 200GB SSD (grows with network)
- **Network:** 10Mbps+ internet connection
- **Go:** v1.21 or higher
- **Rust:** Latest stable (for Lighthouse compilation)

## Step 1: Prerequisites Installation

### Ubuntu/Debian

```bash
sudo apt update && sudo apt upgrade -y

# Install Go
wget https://go.dev/dl/go1.21.5.linux-amd64.tar.gz
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go1.21.5.linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
source ~/.bashrc
go version

# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source $HOME/.cargo/env
rustc --version

# Install dependencies
sudo apt install -y build-essential pkg-config libssl-dev jq curl
```

### macOS

```bash
# Install Homebrew if needed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Go
brew install go@1.21
brew link go@1.21 --force

# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source $HOME/.cargo/env
```

## Step 2: Clone & Setup

```bash
# Create working directory
mkdir -p ~/blockchain && cd ~/blockchain

# Clone Anero
git clone https://github.com/your-org/anero
cd anero

# Make scripts executable
chmod +x setup.sh start-*.sh

# Run initialization
bash setup.sh
```

## Step 3: Start the Network

Open 4 terminal windows. In each, navigate to the Anero directory and run:

```bash
cd ~/blockchain/anero
```

**Terminal 1: Node 1 (Execution)**
```bash
bash start-node1.sh
```
Expected output: `Started P2P networking`, block sync messages

**Terminal 2: Node 2 (Execution)**
```bash
bash start-node2.sh
```
Expected output: Similar to Node 1

**Terminal 3: Beacon Consensus**
```bash
bash start-beacon.sh
```
Expected output: `Syncing beacon chain`, slot information

**Terminal 4: Validators**

⚠️ **IMPORTANT: Configure your fee recipient address before running:**

```bash
# Edit start-validators.sh and add your wallet address
nano start-validators.sh

# Find this line:
# ./lighthouse/target/release/lighthouse vc \

# Add the --suggested-fee-recipient flag with YOUR address:
# ./lighthouse/target/release/lighthouse vc \
#   --datadir ./lighthouse-data \
#   --network mainnet \
#   --beacon-nodes http://localhost:5052 \
#   --suggested-fee-recipient 0xYOUR_WALLET_ADDRESS \
#   --debug-level debug

# Save and exit, then run:
bash start-validators.sh
```

Or run directly with your address:

```bash
./lighthouse/target/release/lighthouse vc \
  --datadir ./lighthouse-data \
  --network mainnet \
  --beacon-nodes http://localhost:5052 \
  --suggested-fee-recipient 0xYOUR_WALLET_ADDRESS \
  --debug-level debug
```

Replace `0xYOUR_WALLET_ADDRESS` with your Ethereum-compatible wallet address (starts with 0x followed by 40 hex characters).

## Step 4: Verify Installation

```bash
# Check Node 1 is responding
curl -s http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' | jq

# Check Node 2
curl -s http://localhost:8548 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' | jq

# Check beacon sync
curl -s http://localhost:5052/eth/v1/node/syncing | jq '.data'

# Count active validators
curl -s http://localhost:5052/eth/v1/beacon/states/head/validators | jq '.data | length'
```

All should return data without errors.

## Step 5: Connect to MetaMask

1. Open MetaMask browser extension
2. Click network dropdown
3. Select "Add custom network" or "Add Network"
4. Enter:
   - **Network Name:** Anero
   - **New RPC URL:** `http://localhost:8545`
   - **Chain ID:** `1889`
   - **Currency Symbol:** `ANERO`
   - **Block Explorer URL:** (leave blank or add custom explorer)
5. Click "Save"

## Step 6: Test Transaction

```bash
# Get account balance
curl -s http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_accounts","params":[],"id":1}' | jq

# Should return your configured accounts
```

## Validator Configuration

### Earning Transaction Fees

When you set `--suggested-fee-recipient`, transaction fees earned by your validator are sent to that address. You'll receive:
- Block proposal rewards
- Transaction fees from blocks you propose
- MEV rewards (if applicable)

### Optional Validator Settings

If you want to customize validator behavior, add flags to `start-validators.sh`:

```bash
./lighthouse/target/release/lighthouse vc \
  --datadir ./lighthouse-data \
  --network mainnet \
  --beacon-nodes http://localhost:5052 \
  --suggested-fee-recipient 0xYOUR_ADDRESS \
  --graffiti "My Validator" \
  --debug-level debug
```

## Troubleshooting

### Port Already in Use

```bash
# Find process using port 8545
lsof -i :8545

# Kill process
kill -9 <PID>
```

### Beacon not syncing

```bash
# Check Node1 auth-RPC is running
curl -v http://localhost:8551/engine_exchangeTransitionConfig

# Check JWT secret exists
cat jwt.hex | wc -c  # Should be 65
```

### Out of Memory

```bash
# Increase Node1 cache (GiB)
# Add to start-node1.sh:
--cache 4096

# Monitor memory
watch -n 1 'free -h'
```

### Slow sync

```bash
# Check peer connections
curl -s http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"net_peerCount","params":[],"id":1}' | jq
```

### Validators not proposing

```bash
# Check validator status
curl -s http://localhost:5052/eth/v1/beacon/states/head/validators | jq '.data[] | select(.status=="active") | .status' | wc -l

# Ensure validator keys are imported
ls lighthouse-data/validators/
```

## Performance Tuning

### Increase Block Gas Limit (for faster transactions)

Edit Node1/Node2 start scripts:
```bash
--miner.gasprice 0
--miner.gaslimit 30000000
```

### Enable Pprof Profiling

Add to start-node1.sh:
```bash
--pprof \
--pprof.addr 0.0.0.0 \
--pprof.port 6060
```

Then access: `http://localhost:6060/debug/pprof`

## Backup & Recovery

### Backup Validator Keys

```bash
# CRITICAL: Backup validator keys securely
tar -czf validator-backup-$(date +%s).tar.gz lighthouse-data/validators/

# Store in secure location (offline backup recommended)
```

### Restore Validator Keys

```bash
tar -xzf validator-backup-*.tar.gz
# Restart validators
```

## Running as System Service (Optional)

Create systemd service file:

```bash
sudo tee /etc/systemd/system/anero.service > /dev/null << EOF
[Unit]
Description=Anero Blockchain
After=network.target

[Service]
Type=forking
User=$(whoami)
WorkingDirectory=$HOME/blockchain/anero
ExecStart=/bin/bash -c 'bash start-node1.sh & bash start-node2.sh & bash start-beacon.sh & bash start-validators.sh'
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Enable and start
sudo systemctl daemon-reload
sudo systemctl enable anero
sudo systemctl start anero

# Monitor
sudo systemctl status anero
sudo journalctl -u anero -f
```

## Next Steps

- Deploy smart contracts to http://localhost:8545
- Run dApps on the network
- Invite others to become validators
- Monitor network health and statistics

## Support

For issues or questions:
- Check logs: `tail -f *.log`
- Review GitHub issues
- Ask in community channels

---

**Welcome to Anero! Happy staking! 🚀**
