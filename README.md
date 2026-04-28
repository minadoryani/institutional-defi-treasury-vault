# Institutional DeFi Treasury Vault

## Live Contracts (Final Audit Version - Sepolia)

Oracle  
https://sepolia.etherscan.io/address/0x669d4B7E92D9c09f0674E40E561dE51f7dCA343b#code

Vault  
https://sepolia.etherscan.io/address/0xe8B13904dde710254B0fe29EdC286A7Ba47fA518#code

Token  
https://sepolia.etherscan.io/address/0x7C953AfdC5D8114EDbE84EF9A525F372146bE508#code

---

## Overview

This project implements a security-focused, production-style DeFi Treasury Vault.

It demonstrates how smart contracts should be built when handling real value, with a focus on:

- attack resistance  
- safe token handling  
- correct accounting  
- oracle validation  
- defensive architecture  

---

## What Makes This Project Advanced

This is not a basic CRUD smart contract.

It includes real-world DeFi risks and their mitigations:

- Reentrancy attack simulation  
- Malicious ERC20 handling  
- Fee-on-transfer token protection  
- Oracle manipulation protection  
- Decimal mismatch protection  
- Accounting consistency checks  
- Role-based security separation  
- Risk configuration limits  

---

## Core Security Features

### Reentrancy Protection
- ReentrancyGuard
- Real attack simulation contract

### Safe Token Handling
- SafeERC20
- Balance delta validation
- Protection against partial transfers

### Decimal Handling
- Supports non-18 decimal tokens
- Normalization for correct USD calculation

### Oracle Security
- Rejects invalid prices
- Rejects stale prices
- Enforces price bounds

### Accounting Safety
- Tracks user balances
- Tracks total vault balances
- Validates internal vs real balances

### Access Control
- Role-based permissions
- Risk Manager controls configs
- Pauser controls emergency shutdown

### Risk Limits
- Max cooldown enforced
- Max deposit limit enforced

---

## Tech Stack

- Solidity 0.8.24  
- Hardhat 2  
- Ethers.js v6  
- OpenZeppelin  
- Sepolia Testnet  

---

## Run Locally

npx hardhat test  
npx hardhat compile  

---

## Deploy

npx hardhat run scripts/deploy.js  
npx hardhat run scripts/deploy.js --network sepolia  

---

## Why This Matters

Most DeFi exploits happen because developers ignore:

- token behavior  
- price reliability  
- access control  
- accounting  

This project demonstrates how to defend against those risks.

---

## Conclusion

This is a security-oriented DeFi vault implementation designed to reflect:

- real-world attack awareness  
- defensive smart contract design  
- production-level thinking  

It represents a strong foundation for advanced Web3 / Smart Contract Engineering roles.