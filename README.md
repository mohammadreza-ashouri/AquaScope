# AquaScope
First WASM-level liquidity pool scanner for NEAR Protocol. Discovers DeFi pools by analyzing smart contract bytecode, finds arbitrage opportunities, and provides real-time analytics without external dependencies.



# 🌊 AquaScope

> **The First WASM-Level DeFi Discovery Engine for NEAR Protocol**


## 🚀 **What Makes AquaScope Unique?**

While other DeFi tools rely on APIs, subgraphs, or centralized data providers, **AquaScope dives deep into the smart contract DNA itself**. By analyzing WASM bytecode directly, we discover liquidity pools that others miss and provide insights that no traditional tool can match.

### 🎯 **The Problem We Solve**

- **Missing Pools**: Traditional scanners only find pools already indexed by APIs
- **Delayed Data**: Centralized providers have lag times and potential downtime  
- **Limited Coverage**: Most tools miss new or exotic pools
- **Dependency Hell**: Reliance on external services creates single points of failure

### ⚡ **Our Solution**

AquaScope reads smart contract bytecode like DNA, discovering pools through **assembly-level function signature analysis** and extracting real-time data through direct NEAR RPC calls.

---

## 🌊 **Core Features**

### 🔍 **Autonomous Pool Discovery**
```bash
./aquascope.sh discover
```
- Scans NEAR mainnet for AMM/DEX functionality
- Identifies pools through WASM function signatures
- Discovers pools before they appear on mainstream platforms

### 📊 **Real-Time Analytics** 
```bash
./aquascope.sh scan ref-finance-101.near
```
- Extracts live reserve data and token pairs
- Calculates pricing from on-chain contract state
- Monitors pool health and trading activity

### ⚡ **Arbitrage Detection**
```bash
./aquascope.sh arbitrage NEAR/USDC
```
- Compares liquidity across all NEAR DEXes
- Identifies profitable opportunities in real-time
- Tracks cross-DEX price differentials

### 📡 **Live Monitoring**
```bash
./aquascope.sh monitor wrap.near/usdc.fakes.testnet
```
- Real-time pair monitoring across DEXes
- Liquidity flow tracking
- Price movement alerts

---

## 🛠️ **Installation**

### Prerequisites
```bash
# macOS (one-time setup)
brew install wabt jq bc

# Linux
sudo apt-get install wabt jq bc

# The script handles everything else!
```

### Quick Start
```bash
# Clone and run
git clone https://github.com/yourusername/aquascope.git
cd aquascope
chmod +x aquascope.sh

# Discover all NEAR pools
./aquascope.sh discover

# Scan specific DEX
./aquascope.sh scan ref-finance-101.near

# Find arbitrage opportunities  
./aquascope.sh arbitrage NEAR/USDC
```

---

## 🎯 **Use Cases**

### 🏃‍♂️ **For DeFi Traders**
- **Early Discovery**: Find new pools before they hit mainstream platforms
- **Arbitrage Hunting**: Real-time opportunities across NEAR DEXes  
- **Optimal Execution**: Monitor liquidity for best trade timing

### 🏗️ **For DeFi Protocols**
- **Competitive Intelligence**: Monitor competitor pool performance
- **Ecosystem Mapping**: Track liquidity distribution across NEAR
- **Partnership Discovery**: Identify integration opportunities

### 🔬 **For DeFi Researchers**
- **Market Structure**: Comprehensive NEAR DeFi ecosystem analysis
- **Liquidity Analytics**: Deep dive into market mechanics
- **Protocol Benchmarking**: Compare performance across DEXes

---

## 🏆 **What Makes Us Unique**

| Traditional Tools | 🌊 AquaScope |
|------------------|--------------|
| 📡 API-dependent | 🔬 Direct WASM analysis |
| ⏰ Delayed data | ⚡ Real-time extraction |
| 🎯 Limited coverage | 🌐 Comprehensive discovery |
| 🔗 External dependencies | 🛡️ Zero external deps |
| 📊 Surface-level data | 🧬 Bytecode-level insights |

---

## 📈 **Technical Architecture**

```
Smart Contract (WASM) → AquaScope Engine → Insights
         ↑                    ↓
    [Bytecode Analysis]  [Direct RPC Calls]
         ↑                    ↓  
    [Function Signatures] [Real-time Data]
```

### 🔧 **Core Technologies**
- **WebAssembly Disassembly**: Converts WASM to readable format
- **Pattern Recognition**: Identifies AMM/DEX function signatures  
- **Direct RPC**: Queries NEAR mainnet without intermediaries
- **Real-time Processing**: Live data extraction and analysis

---

## 🎨 **Example Output**

```bash
╔═══════════════════════════════════════════════════════════════════════════╗
║                   NEAR LIQUIDITY POOL SCANNER v1.0                       ║
║                🌊 First WASM-Level DeFi Discovery Engine                  ║
╚═══════════════════════════════════════════════════════════════════════════╝

🔍 POOL FUNCTION ANALYSIS
═══════════════════════════════════════════════════════════════════════════
✅ WASM disassembled
🌊 Pool Functions Found: 12
  • get_pools
  • add_liquidity  
  • remove_liquidity
  • swap
  • get_return
  • get_pool_info

🌊 POOL DISCOVERY
═══════════════════════════════════════════════════════════════════════════
✅ get_number_of_pools: 247
📊 Found 247 pools
  Pool 0: {"token_account_ids":["wrap.near","usdc.fakes.testnet"]...
  Pool 1: {"token_account_ids":["wrap.near","dai.fakes.testnet"]...

📊 DISCOVERY SUMMARY
═══════════════════════════════════════════════════════════════════════════
🎯 Active DEXes: 4/7
🌊 Total Pools: 500+
💡 Real-time data extracted from WASM bytecode
```

---

## 🛣️ **Roadmap**

### 🎯 **Phase 1: Core Engine** *(Current)*
- [x] WASM bytecode analysis
- [x] Pool function detection  
- [x] Basic arbitrage scanning
- [x] Real-time monitoring

### 🚀 **Phase 2: Intelligence** *(Next)*
- [ ] ML-powered pool classification
- [ ] Advanced arbitrage algorithms
- [ ] Liquidity flow prediction
- [ ] Risk assessment scoring

### 🌟 **Phase 3: Platform** *(Future)*
- [ ] Web dashboard interface
- [ ] API for external integrations
- [ ] Mobile notifications
- [ ] Cross-chain expansion

---

## 🤝 **Contributing**

We're building the future of DeFi analytics! Here's how you can help:

### 🎯 **Ways to Contribute**
- **Add DEX Support**: Help us discover more protocols
- **Improve Analysis**: Enhance our WASM parsing algorithms  
- **Build Features**: Implement new discovery methods
- **Report Issues**: Found a bug? Let us know!

### 🚀 **Getting Started**
1. Fork the repository
2. Create a feature branch (`git checkout -b amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin amazing-feature`)  
5. Open a Pull Request

---

## 📜 **License**

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 **Acknowledgments**

- **NEAR Protocol** - For building an amazing blockchain platform
- **WebAssembly Community** - For the incredible WASM tooling
- **DeFi Pioneers** - For creating the liquidity infrastructure we analyze
- **Open Source Contributors** - For making this project possible

---


---

<div align="center">




</div>
