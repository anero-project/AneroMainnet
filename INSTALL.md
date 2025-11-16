# Anero Blockchain - Complete Installation Guide

## Overview

This guide covers everything needed to run a full Anero node with validators. Follow all steps in order.

---

## Part 1: Prerequisites & Preparation

### 1.1 System Requirements

Your computer needs:
- **CPU:** 4+ cores (8+ recommended for validators)
- **RAM:** 16GB minimum (32GB recommended)
- **Storage:** 200GB SSD (grows over time)
- **Internet:** 10Mbps stable connection
- **OS:** Ubuntu 20.04+, Debian, macOS, or WSL2 on Windows
- **Always-on:** Node must run 24/7 for best rewards

### 1.2 Do You Need to Install Lighthouse?

**YES - You must compile/download Lighthouse.**

The release ZIP does NOT include the Lighthouse binary. You must either:

**Option A: Compile from source (takes 10-15 minutes)**
```bash
# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source $HOME/.cargo/env

# Clone and compile Lighthouse
git clone https://github.com/sigp/lighthouse
cd lighthouse
cargo build --release

# Binary will be at: ./target/release/lighthouse
```

**Option B: Download pre-built binary (faster)**
```bash
# Download latest Lighthouse release
wget https://github.com/sigp/lighthouse/releases/download/v5.1.0/lighthouse-v5.1.0-x86_64-unknown-linux-gnu.tar.gz
tar -xzf lighthouse-v5.1.0-x86_64-unknown-linux-gnu.tar.gz
mkdir -p lighthouse/target/release
mv lighthouse lighthouse/target/release/
```

### 1.3 Pre-Installation Checklist

Before proceeding, verify:
- [ ] You have 200GB+ free SSD space
- [ ] System is up to date: `sudo apt update && sudo apt upgrade -y`
- [ ] Go v1.21+ installed: `go version`
- [ ] Rust installed (for Lighthouse): `rustc --version`
- [ ] Docker installed (optional, for block explorer): `docker --version`
- [ ] Ports available: 8545, 8548, 8546, 8547, 5052, 30301, 30302, 9000, 9001

---

## Part 2: Extract & Initialize

### 2.1 Extract Release

```bash
# Download and extract
unzip anero-release.zip
cd anero-public-release

# Make scripts executable
chmod +x setup.sh start-*.sh

# You should see:
# - setup.sh (initialization script)
# - start-node1.sh (execution node 1)
# - start-node2.sh (execution node 2)
# - start-beacon.sh (consensus layer)
# - start-validators.sh (validator client)
# - genesis.json (network state)
# - testnet-config/ (beacon config)
# - README.md, INSTALL.md, LICENSE
```

### 2.2 Run Setup Script

```bash
# This creates directories and generates secrets
bash setup.sh

# What it does:
# 1. Creates node1/ directory
# 2. Creates node2/ directory
# 3. Creates lighthouse-data/ directory
# 4. Initializes both nodes with genesis.json
# 5. Generates unique jwt.hex for this server

# Expected output:
# ✓ Node1 initialized
# ✓ Node2 initialized
# ✓ Setup complete!

# Verify it worked:
ls -la node1/geth/chaindata/
ls -la node2/geth/chaindata/
cat jwt.hex | wc -c  # Should be 65 characters
```

### 2.3 Copy Lighthouse Binary

If you compiled Lighthouse locally:

```bash
# Create directory
mkdir -p lighthouse/target/release

# Copy your compiled binary
cp ~/lighthouse/target/release/lighthouse lighthouse/target/release/

# Verify
./lighthouse/target/release/lighthouse --version
# Should output: Lighthouse vX.X.X
```

---

## Part 3: Do You Need to Create a Wallet?

**YES - You need a wallet to receive validator rewards.**

### 3.1 Create or Import Wallet

**Option A: Use existing wallet (Recommended)**
```bash
# If you already have a wallet:
# 1. Note your Ethereum address (starts with 0x)
# 2. You'll enter this when running validators
# 3. Example: 0x1234567890abcdef1234567890abcdef12345678
```

**Option B: Create new wallet**
```bash
# If you don't have a wallet, create one:
# Method 1: MetaMask
# 1. Install MetaMask browser extension
# 2. Create new wallet
# 3. Save seed phrase SECURELY offline
# 4. Your address appears in MetaMask

# Method 2: Command line
npm install -g ganache-cli
ganache-cli --accounts 10
# Copy the address from output
```

**CRITICAL: Save your wallet address**
```bash
# You'll need this for:
# - Running validators (fee recipient)
# - Depositing 32 ANERO per validator
# - Receiving block rewards and fees
```

---

## Part 4: Do You Need to Import Validators?

**YES - Only if you have existing validator keys.**

### 4.1 Validator Keys

**If you ALREADY have validator keystores:**

```bash
# Place your validator keys in:
mkdir -p validator-keys
# Copy your keystore-*.json files here

# The keys need passwords stored in:
echo "your-password" > validator-passwords.txt

# Later, when running validators, the setup will import them
```

**If you DON'T have validator keys yet:**

```bash
# Validators are created during setup
# You'll need to deposit 32 ANERO per validator later

# For now, just continue - keys will be generated automatically
```

### 4.2 Creating Validator Keys (If You Have None)

```bash
# Install Lighthouse account tools (included with Lighthouse)
./lighthouse/target/release/lighthouse account validator create \
  --network mainnet \
  --datadir ./lighthouse-data \
  --count 1

# This creates:
# - lighthouse-data/validators/0x... (validator data)
# - lighthouse-data/secrets/0x... (password file)

# Set password when prompted and SAVE IT
# You'll need it to run validators
```

---

## Part 5: Start the Network

You need **4 separate terminal windows or tmux sessions**.

### 5.1 Terminal 1: Node 1 (Execution Layer - Primary)

```bash
cd ~/path/to/anero-public-release

bash start-node1.sh

# Expected output:
# INFO [XX-XX|XX:XX:XX] Started P2P networking
# INFO [XX-XX|XX:XX:XX] Commit hash           
# INFO [XX-XX|XX:XX:XX] Chain file...
# INFO [XX-XX|XX:XX:XX] Synced=false, syncing=false

# Node 1 listens on:
# - RPC: http://localhost:8545
# - WebSocket: ws://localhost:8546
# - Auth-RPC: http://localhost:8551 (for beacon)
# - P2P: port 30301
```

### 5.2 Terminal 2: Node 2 (Execution Layer - Secondary)

Wait 3 seconds after Node 1 starts, then:

```bash
bash start-node2.sh

# Expected output:
# INFO [XX-XX|XX:XX:XX] Started P2P networking
# Similar messages to Node 1

# Node 2 listens on:
# - RPC: http://localhost:8548
# - WebSocket: ws://localhost:8547
# - Auth-RPC: http://localhost:8552 (backup)
# - P2P: port 30302
```

### 5.3 Terminal 3: Beacon (Consensus Layer)

Wait 3 seconds after Node 2 starts, then:

```bash
bash start-beacon.sh

# Expected output:
# INFO beacon_node: Starting Lighthouse
# INFO beacon_node: Listening on ports
# INFO beacon_node: Eth2 network name: mainnet
# INFO beacon_node: Syncing beacon chain

# Beacon listens on:
# - HTTP API: http://localhost:5052
# - P2P: ports 9000-9001
# - Connected to Node 1 auth-RPC at 8551
```

### 5.4 Terminal 4: Validators (Only if you have 32+ ANERO staked)

Wait 5 seconds after Beacon starts. **Before running, edit start-validators.sh:**

```bash
# Edit the file
nano start-validators.sh

# Find this section and ADD your wallet address:
# ./lighthouse/target/release/lighthouse vc \
#   --datadir ./lighthouse-data \
#   --network mainnet \
#   --beacon-nodes http://localhost:5052 \
#   --suggested-fee-recipient 0xYOUR_WALLET_ADDRESS \
#   --debug-level debug

# Replace 0xYOUR_WALLET_ADDRESS with your actual address
# Example: 0x742d35Cc6634C0532925a3b844Bc9e7595f42e0d

# Save (Ctrl+X, Y, Enter)

# Now run it:
bash start-validators.sh

# Expected output:
# INFO validator_client: Eth2 network name: mainnet
# INFO validator_client: Loaded X validators
# INFO validator_client: Ready for sign duties
```

---

## Part 6: Verify Everything Works

### 6.1 Check Node 1 (HTTP RPC)

```bash
curl -s http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
  | jq '.result'

# Should return: 0x0, 0x1, 0x2, ... (increasing block numbers)
```

### 6.2 Check Node 2 (HTTP RPC)

```bash
curl -s http://localhost:8548 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
  | jq '.result'

# Should return similar block numbers
```

### 6.3 Check Beacon Syncing

```bash
curl -s http://localhost:5052/eth/v1/node/syncing | jq '.data.is_syncing'

# Should return: false (when synced) or true (still syncing)
```

### 6.4 Check Active Validators

```bash
curl -s http://localhost:5052/eth/v1/beacon/states/head/validators \
  | jq '.data | length'

# Should return: Number of validators in network
# Example: 65617
```

### 6.5 Check Your Specific Validator (If Running)

```bash
curl -s http://localhost:5052/eth/v1/beacon/states/head/validators \
  | jq '.data[] | select(.pubkey=="0xyourpubkey") | .status'

# Should return:
# "active_ongoing" (earning rewards)
# "active_exiting" (scheduled to exit)
# "exited" (no longer validating)
```

---

## Part 7: Staking (Becoming a Validator)

### 7.1 Do You Have Validators to Stake?

**You must have:**
- Validator keys generated (we did this in Part 4)
- 32 ANERO per validator
- Wallet address where rewards will arrive

### 7.2 Deposit 32 ANERO

To become an active validator, you need to deposit 32 ANERO per validator:

```bash
# Option A: Via bridge/exchange
# 1. Bridge ANERO from another network
# 2. Send to validator deposit contract
# 3. Submit deposit transaction

# Option B: Via faucet
# 1. Go to https://faucet.getanero.org
# 2. Enter wallet address
# 3. Receive 32 ANERO

# Deposit contract address:
# 0x4242424242424242424242424242424242424242

# Once deposit is confirmed (~1 epoch = 6.4 minutes):
# Your validator enters active set
# Starts earning rewards (transaction fees + staking rewards)
```

### 7.3 Monitor Your Validator

```bash
# Get your validator pubkey
ls lighthouse-data/validators/

# Monitor status
while true; do
  curl -s http://localhost:5052/eth/v1/beacon/states/head/validators \
    | jq '.data[] | select(.pubkey=="0x...") | {status, balance}'
  sleep 30
done
```

---

## Part 8: Configuration Reference

### 8.1 Network Ports

| Port | Service | Purpose |
|------|---------|---------|
| 8545 | Node1 HTTP | RPC for external apps |
| 8546 | Node1 WS | WebSocket endpoint |
| 8551 | Node1 Auth | Beacon node connection |
| 8548 | Node2 HTTP | Secondary RPC |
| 8547 | Node2 WS | Secondary WebSocket |
| 8552 | Node2 Auth | Backup beacon connection |
| 5052 | Beacon | Consensus API |
| 30301 | Node1 P2P | Peer-to-peer |
| 30302 | Node2 P2P | Peer-to-peer |
| 9000 | Beacon UDP | Discovery |
| 9001 | Beacon TCP | Peer sync |

### 8.2 Key Files & Directories

```
anero-mainnet/
├── node1/               # Node 1 data
│   └── geth/
│       ├── chaindata/   # Blockchain state (LARGE)
│       ├── lightchaindata/
│       └── geth.ipc
├── node2/               # Node 2 data
│   └── geth/
│       └── chaindata/
├── lighthouse-data/     # Beacon & validator data
│   ├── beacon/          # Consensus state
│   ├── validators/      # Your validator keys
│   └── secrets/         # Validator passwords
├── jwt.hex              # Secret: Keep private!
├── genesis.json         # Network state snapshot
├── testnet-config/      # Beacon configs
├── start-node1.sh       # Run node 1
├── start-node2.sh       # Run node 2
├── start-beacon.sh      # Run beacon
└── start-validators.sh  # Run validators
```

---

## Part 9: Troubleshooting

### Problem: "Port 8545 already in use"

```bash
# Find what's using it
lsof -i :8545

# Kill the process
kill -9 <PID>

# Or use different port in start-node1.sh:
# --http.port 8555 (instead of 8545)
```

### Problem: "Beacon not syncing"

```bash
# Check if Node 1 is running
curl http://localhost:8551/engine_exchangeTransitionConfig

# Check JWT secret
cat jwt.hex | wc -c  # Must be 65 characters

# Check beacon logs for errors
tail -50 beacon.log | grep -i error
```

### Problem: "Out of memory"

```bash
# Increase cache in start-node1.sh:
# Add: --cache 4096 (uses 4GB instead of 1GB)

# Monitor memory:
watch -n 1 'free -h'

# Free up space:
df -h
```

### Problem: "Validator not proposing blocks"

```bash
# Ensure beacon is fully synced
curl http://localhost:5052/eth/v1/node/syncing | jq '.data.is_syncing'

# Ensure deposit confirmed
curl http://localhost:5052/eth/v1/beacon/states/head/validators \
  | jq '.data[] | select(.pubkey=="0xyour...") | .status'

# Check validator logs
tail -100 validator.log | grep -i error
```

---

## Part 10: Advanced Topics

### 10.1 Running as System Service

```bash
sudo tee /etc/systemd/system/anero.service > /dev/null << 'EOF'
[Unit]
Description=Anero Blockchain
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$HOME/anero-public-release
ExecStart=/bin/bash -c 'bash start-node1.sh & sleep 3 && bash start-node2.sh & sleep 3 && bash start-beacon.sh & bash start-validators.sh'
Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable anero
sudo systemctl start anero
sudo systemctl status anero
```

### 10.2 Backing Up Validator Keys

```bash
# CRITICAL: Back up offline
tar -czf validator-backup-$(date +%s).tar.gz lighthouse-data/validators/

# Store securely:
# - USB drive (encrypted)
# - Cloud backup (encrypted)
# - Paper backup (QR code)
```

### 10.3 Monitoring Dashboard

```bash
# Real-time metrics
watch -n 5 '
  echo "=== Node 1 ===" && \
  curl -s http://localhost:8545 \
    -H "Content-Type: application/json" \
    -d "{\"jsonrpc\":\"2.0\",\"method\":\"eth_blockNumber\",\"params\":[],\"id\":1}" | jq ".result" && \
  echo "=== Beacon ===" && \
  curl -s http://localhost:5052/eth/v1/node/syncing | jq ".data" && \
  echo "=== Memory ===" && \
  free -h | head -2
'
```

---

## Part 11: Important Notes

### Security
- **Validator keys are CRITICAL** - loss means loss of all 32 ANERO per validator
- **Keep jwt.hex private** - anyone with it can control your nodes
- **Backup offline** - protect from ransomware/data loss
- **Use strong passwords** - for validator key encryption

### Risks
- **Slashing:** Protocol violations = lose 32 ANERO
- **Downtime:** Offline for >1 epoch = small penalty
- **Network risk:** Early beta - may have bugs
- **Permanent:** All blockchain transactions irreversible

### Performance
- **Syncing takes 2-4 hours** on first run
- **Memory grows** as database fills
- **Keep node online 24/7** for best rewards
- **Monitor regularly** for issues

---

## Next Steps

1. ✅ Install prerequisites
2. ✅ Extract release
3. ✅ Run setup.sh
4. ✅ Start all 4 components
5. ✅ Verify everything works
6. ✅ Deposit 32 ANERO per validator
7. ✅ Wait for validator activation (~1 epoch)
8. ✅ Monitor and earn rewards

---

## Support

- **GitHub Issues:** https://github.com/your-org/anero/issues
- **Documentation:** See README.md and RELEASE-NOTES.md
- **Community:** Discord (coming soon)

**Welcome to Anero! Happy staking!** ⚡
