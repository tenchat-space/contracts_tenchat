# TenChat Smart Contracts - Quick Deployment Guide

## 🚀 Quick Deploy (3 Steps)

### 1. Set Environment Variables
```bash
export SEPOLIA_RPC_URL="https://sepolia.infura.io/v3/YOUR_KEY"
export SEPOLIA_PRIVATE_KEY="your_private_key_here"
export TEN_PRIVATE_KEY="your_private_key_here"
```

### 2. Compile Contracts
```bash
cd contracts_tenchat
npx hardhat compile
```

### 3. Deploy to Network

**Option A: Using Ignition (Recommended)**
```bash
# Deploy to Sepolia
npx hardhat ignition deploy ignition/modules/TenChatDeploy.ts --network sepolia

# Deploy to Ten Network
npx hardhat ignition deploy ignition/modules/TenChatDeploy.ts --network ten

# Deploy to local hardhat
npx hardhat ignition deploy ignition/modules/TenChatDeploy.ts --network hardhatMainnet
```

**Option B: Using Custom Script**
```bash
# Deploy to Sepolia
npx hardhat run scripts/deploy.ts --network sepolia

# Deploy to Ten Network
npx hardhat run scripts/deploy.ts --network ten

# Deploy locally
npx hardhat run scripts/deploy.ts --network hardhat
```

## 📋 Contracts Overview

### Core.sol
- **Purpose**: Central registry, user profiles, username management
- **Features**:
  - Register users with unique usernames
  - Update usernames
  - Check username availability
  - Contract registry for other contracts

### EncryptedChat.sol
- **Purpose**: End-to-end encrypted messaging
- **Features**:
  - Send encrypted messages
  - Message history
  - User-to-user communication

### Gifting.sol
- **Purpose**: Crypto gifting system
- **Features**:
  - Send ETH/tokens as gifts
  - Gift history
  - Event tracking

### Subscription.sol
- **Purpose**: Subscription management
- **Features**:
  - Create subscription plans
  - Subscribe to users
  - Manage subscriptions

## 🔧 Testing

```bash
# Run all tests
npx hardhat test

# Run specific test
npx hardhat test test/Core.test.ts
npx hardhat test test/Gifting.test.ts
npx hardhat test test/EncryptedChat.test.ts
```

## 📊 Verify Contracts

After deployment, verify on Etherscan:

```bash
# Set contract addresses
export CORE_ADDRESS="0x..."
export ENCRYPTED_CHAT_ADDRESS="0x..."
export GIFTING_ADDRESS="0x..."
export SUBSCRIPTION_ADDRESS="0x..."

# Run verification script
npx hardhat run scripts/verify.ts --network sepolia
```

## 📝 Network Configuration

### Sepolia Testnet
- **RPC**: Configure in `SEPOLIA_RPC_URL`
- **Chain ID**: 11155111
- **Explorer**: https://sepolia.etherscan.io

### Ten Network
- **RPC**: https://testnet.ten.xyz/v1/
- **Chain ID**: 443
- **Explorer**: https://testnet.tenscan.io

## 💡 Quick Commands

```bash
# Compile
npx hardhat compile

# Clean
npx hardhat clean

# Test
npx hardhat test

# Deploy (Sepolia)
npx hardhat ignition deploy ignition/modules/TenChatDeploy.ts --network sepolia

# Deploy (Ten)
npx hardhat ignition deploy ignition/modules/TenChatDeploy.ts --network ten

# Node
npx hardhat node

# Console
npx hardhat console --network sepolia
```

## 🎯 Deployment Checklist

- [ ] Environment variables set
- [ ] Wallet has sufficient funds (gas)
- [ ] Contracts compiled successfully
- [ ] Tests passing
- [ ] Deploy to testnet
- [ ] Verify deployment
- [ ] Save contract addresses
- [ ] Update frontend with addresses
- [ ] Test on frontend

## 🔑 Required Environment Variables

Create a `.env` file or export:

```bash
# Sepolia
export SEPOLIA_RPC_URL="https://sepolia.infura.io/v3/YOUR_INFURA_KEY"
export SEPOLIA_PRIVATE_KEY="0xYOUR_PRIVATE_KEY"

# Ten Network
export TEN_PRIVATE_KEY="0xYOUR_PRIVATE_KEY"

# Optional: For verification
export ETHERSCAN_API_KEY="YOUR_ETHERSCAN_KEY"
```

## 📦 Deployment Output

After successful deployment, you'll get:

```
🎉 Deployment Complete!

Contract Addresses:
===================
Core:           0x742d35Cc6634C0532925a3b844C2468bB3Ff16B2
EncryptedChat:  0x8B5e5f5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e5e
Gifting:        0x9C6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f
Subscription:   0x1D7g7g7g7g7g7g7g7g7g7g7g7g7g7g7g7g7g7g7g

💡 Save these addresses for frontend integration!
```

## 🚨 Troubleshooting

### "Insufficient funds"
- Ensure wallet has testnet ETH
- Get testnet ETH from faucet

### "Nonce too high"
- Reset Hardhat network: `npx hardhat clean`

### "Contract not found"
- Run `npx hardhat compile` first

### "Network not found"
- Check hardhat.config.ts network names

## 🎉 Ready for Production

Once tested on testnet:

1. Update network config for mainnet
2. Ensure sufficient mainnet ETH
3. Deploy using same commands
4. Verify contracts on Etherscan
5. Update frontend with mainnet addresses

## 📚 Documentation

- Hardhat: https://hardhat.org/docs
- Ignition: https://hardhat.org/ignition/docs
- OpenZeppelin: https://docs.openzeppelin.com/contracts
