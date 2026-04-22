# Institutional DeFi Treasury Vault

## Status

This project includes:

- Full smart contract system
- Security-focused architecture
- Oracle integration and validation
- Reentrancy attack simulation
- Comprehensive test suite
- Threat model documentation

---

## Overview

This project implements a secure, modular, and production-oriented DeFi Treasury Vault.

It is designed to demonstrate how smart contracts should be built when handling real value, with a strong focus on security, architecture, and attack mitigation.

---

## Quick Example

1. Deploy contracts:
npx hardhat run scripts/deploy.js

2. Deposit tokens:
User approves and deposits ERC20 asset

3. Withdraw:
After cooldown, user withdraws funds

Security protections are enforced automatically

---

## Key Features

- Multi-asset support (ERC20)
- Oracle-based USD valuation
- Role-based access control (Admin, Risk Manager, Pauser)
- Deposit and withdrawal limits
- Withdrawal cooldown enforcement
- Emergency pause / unpause mechanism
- Modular contract architecture

---

## Architecture

The system is divided into multiple components:

- `TreasuryVault.sol`  
  Core vault logic (deposit, withdraw, balances)

- `VaultAccessControl.sol`  
  Role-based permissions

- `VaultConfig.sol`  
  Asset limits and configuration

- `VaultOracleManager.sol`  
  Oracle integration and validation

- `MockVaultPriceOracle.sol`  
  Test oracle implementation

- `ReentrantCallbackToken.sol`  
  Malicious ERC20 used for attack simulation

- `ReentrancyAttacker.sol`  
  Attack contract to simulate reentrancy

---

## Security Design

This project is built with a strong security-first approach:

### Reentrancy Protection
- OpenZeppelin `ReentrancyGuard`
- Tested with real attack simulation

### Access Control
- Role-based permissions via `AccessControl`
- Restricted admin functions

### Oracle Validation
- Rejects invalid prices
- Rejects stale price data

### Input Validation
- Min/max deposit checks
- Zero value protection
- Supported asset enforcement

### Emergency Controls
- Pause/unpause mechanism

---

## Threat Model

See full threat model here:  
`docs/threat-model.md`

Includes:

- Reentrancy attacks
- Oracle manipulation
- Stale price risks
- Unauthorized access
- Deposit/withdraw abuse

---

## Testing

Run tests:

```bash
npx hardhat test