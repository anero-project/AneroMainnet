# Anero Blockchain

Anero is a production-grade proof-of-stake blockchain built on Ethereum's execution layer (Geth) and consensus layer (Lighthouse). The network features 65,000+ active validators securing the chain and producing blocks.

## Contributers/Developers

AneroDev - Lead Developer & Creator of Anero
Aurora - Development Manager

## Features

- **Proof-of-Stake consensus** with 32 ANERO validator deposits
- **High throughput** execution layer using Geth
- **Lighthouse consensus** with beacon chain architecture
- **Production tested** with thousands of test validators
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
git clone https://github.com/anero-project/AneroMainnet
cd AneroMainnet

# Run setup
bash setup.sh

# This initializes:
# - Node1 execution client
# - Node2 execution client  
# - Beacon node data directory
# - JWT secret for client authentication (User must generate before running)
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
   - **RPC URL:** `https://node.getanero.org`
   - **Chain ID:** `1889`
   - **Currency Symbol:** `ANERO`
   - **Block Explorer URL:** explorer.getanero.org (optional) - not yet released

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
2. Deposit 32 ANERO to validator deposit contract - not live yet blockchain is syncing - will take 8-10 days until validator deposit contract is live
3. Validator automatically activates after 1 epoch
4. Begin earning rewards

Current validator participation: **2 validators**

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

ANERO BLOCKCHAIN LICENSE

Version 1.0

DEFINITIONS

"Software" means the Anero blockchain software, including source code, binaries, 
documentation, and configuration files distributed under this license.

"You" or "Your" means an individual or entity exercising rights under this License.

"Licensor" means the entity offering the Software under this License.

1. GRANT OF RIGHTS

Subject to the terms and conditions of this License, Licensor grants You a 
worldwide, non-exclusive, royalty-free, perpetual license to:

(a) Use the Software for any purpose, including commercial purposes
(b) Reproduce and distribute copies of the Software
(c) Create derivative works based on the Software
(d) Modify and improve the Software
(e) Run validator nodes and participate in the Anero network
(f) Deploy smart contracts on the Anero blockchain

2. CONDITIONS

You may exercise the rights granted in Section 1 provided that You:

(a) Retain all copyright, patent, trademark, and attribution notices in all copies
    of the Software
(b) Include a copy of this License with any distribution
(c) Clearly mark any modifications You make to the Software
(d) Provide a copy of this License to recipients of the Software

3. VALIDATOR OPERATION

If You operate validator nodes on the Anero network:

(a) You accept full responsibility for validator key management and security
(b) You maintain backups of validator keys and configuration
(c) You maintain network connectivity and uptime to the best of your ability
(d) You comply with all applicable laws and regulations in Your jurisdiction
(e) You understand that validator slashing penalties may apply for protocol violations

4. NETWORK PARTICIPATION

By participating in the Anero network, You:

(a) Accept the current network parameters and consensus rules
(b) Acknowledge that network upgrades may change protocol behavior
(c) Accept full responsibility for Your ANERO tokens and transactions
(d) Understand that blockchain transactions are permanent and irreversible

5. DISCLAIMER OF WARRANTIES

THE SOFTWARE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
PARTICULAR PURPOSE, AND NONINFRINGEMENT.

THE SOFTWARE MAY CONTAIN BUGS, SECURITY VULNERABILITIES, OR OTHER DEFECTS. USE AT
YOUR OWN RISK.

LICENSOR IS NOT RESPONSIBLE FOR:
- Loss of ANERO tokens or other assets
- Validator slashing or penalties
- Network forks, disruptions, or upgrades
- Smart contract failures or exploits
- Any indirect, incidental, or consequential damages

6. LIMITATION OF LIABILITY

IN NO EVENT SHALL LICENSOR BE LIABLE FOR ANY DAMAGES ARISING OUT OF OR RELATED TO 
THIS SOFTWARE, INCLUDING BUT NOT LIMITED TO:
- Loss of funds or cryptocurrency
- Loss of data
- Loss of profits or revenue
- Business interruption
- Personal injury

EVEN IF LICENSOR HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.

7. MODIFICATIONS AND DERIVATIVES

You may:
- Modify the Software for Your own use
- Create derivative works
- Distribute modified versions

Provided that:
- You clearly indicate what You have changed
- You retain all copyright and license notices
- You distribute derivatives under this same License

8. NO OBLIGATION

Licensor has no obligation to:
- Provide support or maintenance
- Fix bugs or security issues
- Maintain network consensus
- Provide technical assistance

9. TERMINATION

This License is perpetual and cannot be revoked. However, if You violate the terms
of this License, Your right to use the Software immediately terminates.

10. GOVERNING LAW

This License is governed by the laws of the jurisdiction where Licensor is located,
without regard to conflicts of law principles.

11. INTELLECTUAL PROPERTY

(a) You acknowledge that Licensor retains all intellectual property rights in the
    original Software
(b) You grant Licensor a license to use any modifications You publicly share
(c) Nothing in this License grants rights to Licensor's trademarks or branding

12. NETWORK GOVERNANCE

This License does not grant You any governance rights over:
- Network parameters
- Consensus rule changes
- Protocol upgrades
- Treasury or development funds

Network governance is determined by the Anero community through consensus mechanisms.

13. COMPLIANCE

You agree to comply with all applicable laws and regulations, including but not 
limited to:
- Anti-money laundering (AML) regulations
- Know your customer (KYC) requirements
- Securities and commodities laws
- Tax obligations
- Export controls

14. ENTIRE AGREEMENT

This License constitutes the entire agreement between You and Licensor regarding 
the Software and supersedes all prior agreements and understandings.

15. SEVERABILITY

If any provision of this License is found to be invalid or unenforceable, that 
provision shall be severed and the remaining provisions shall continue in effect.

---

ACCEPTANCE

By downloading, installing, or using the Anero Software, You accept all terms and 
conditions of this License.

Questions? See LICENSE.md or contact the Anero community.

ANERO BLOCKCHAIN TEAM
---

**Anero - The future of decentralized consensus**
