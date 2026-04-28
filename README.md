# Institutional DeFi Treasury Vault

## Status

This project includes:

- Full smart contract system
- Security-focused architecture
- Oracle integration and validation
- Reentrancy attack simulation
- SafeERC20 transfer handling
- Balance delta accounting
- Token decimal normalization
- Oracle price bounds
- Internal accounting consistency checks
- Risk limits for cooldowns and deposit caps
- Comprehensive test suite
- Threat model documentation
- Sepolia deployment support

---

## Overview

This project implements a secure, modular, and production-oriented DeFi Treasury Vault.

It is designed to demonstrate how smart contracts should be built when handling real value, with a strong focus on security, architecture, accounting safety, and attack mitigation.

The system allows supported ERC20 assets to be deposited and withdrawn while enforcing role-based permissions, oracle-based valuation, risk limits, cooldown logic, and emergency controls.

---

## Important Note

The project was upgraded with additional audit-oriented protections after the initial deployment.

The latest smart contract version includes:

- SafeERC20 usage
- Balance-before / balance-after transfer validation
- Decimal normalization
- Oracle price bounds
- Internal accounting safety
- Risk configuration limits

Final live deployment links should point to the latest redeployed and verified version.

---

## Quick Example

1. Deploy contracts:
npx hardhat run scripts/deploy.js

2. Run tests:
npx hardhat test

3. Deploy to Sepolia:
npx hardhat run scripts/deploy.js --network sepolia

---

## Key Features

- Multi-asset ERC20 support
- Oracle-based USD valuation
- Role-based access control
- Admin, Risk Manager, Pauser roles
- Deposit minimum and maximum limits
- Withdrawal cooldown enforcement
- Emergency pause and unpause mechanism
- SafeERC20 token transfers
- Balance delta validation for deposits
- Token decimal handling
- Oracle price bounds
- Internal accounting consistency checks
- Reentrancy protection
- Real attack simulation in tests
- Modular contract architecture

---

## Architecture

The system is divided into multiple components:

- TreasuryVault.sol  
  Core vault logic for deposits, withdrawals, balances, accounting, and risk checks.

- VaultAccessControl.sol  
  Role-based permission system using OpenZeppelin AccessControl.

- VaultConfig.sol  
  Asset configuration, deposit limits, token decimals, and cooldown storage.

- VaultOracleManager.sol  
  Oracle integration, stale price detection, validity checks, and price bounds.

- MockVaultPriceOracle.sol  
  Mock oracle used for controlled testing of valid, invalid, and stale prices.

- MockERC20.sol  
  Standard mock ERC20 token for test and local deployment.

- ReentrantCallbackToken.sol  
  Malicious ERC20-style callback token used for reentrancy testing.

- ReentrancyAttacker.sol  
  Attack contract used to simulate a real reentrancy attempt.

- VaultErrors.sol  
  Centralized custom errors for gas-efficient and readable reverts.

- VaultEvents.sol  
  Centralized event definitions for monitoring and transparency.

---

## Security Design

This project is built with a security-first engineering approach.

### Reentrancy Protection
- OpenZeppelin ReentrancyGuard
- nonReentrant protection on critical functions
- Real attack simulation included

### Safe Token Handling
- SafeERC20 usage
- Balance-before / balance-after checks
- Handles fee-on-transfer tokens

### Accounting Safety
- Tracks user balances
- Tracks total vault balances
- Checks consistency between internal and real balances

### Oracle Validation
- Rejects invalid prices
- Rejects stale prices
- Enforces min/max price bounds

### Decimal Handling
- Supports non-18 decimal tokens
- Normalizes values for correct USD calculation

### Access Control
- Role-based permissions
- Risk Manager controls critical configs
- Pauser controls emergency shutdown

### Risk Limits
- Max cooldown enforced
- Max deposit limits enforced
- Prevents dangerous configs

### Emergency Controls
- Pause/unpause system
- Stops deposits and withdrawals instantly

---

## Threat Model

See full threat model here:
docs/threat-model.md

Covered risks:

- Reentrancy
- Malicious ERC20 tokens
- Fee-on-transfer manipulation
- Oracle manipulation
- Stale price risk
- Decimal mismatch
- Unauthorized access
- Dangerous admin configs
- Accounting inconsistencies

---

## Testing

Run:
npx hardhat test

Includes:

- Core logic tests
- Access control tests
- Oracle validation tests
- Cooldown logic
- Attack simulations
- Reentrancy test

---

## Deployment

Local:
npx hardhat run scripts/deploy.js

Sepolia:
npx hardhat run scripts/deploy.js --network sepolia

---

## Limitations

- Uses mock oracle
- No multisig yet
- No timelock yet
- No upgradeability yet
- No frontend

---

## Future Improvements

- Chainlink integration
- Multisig (Gnosis Safe)
- Timelock
- Upgradeable contracts
- Fuzz testing
- Formal verification
- Monitoring system

---

## Why This Matters

DeFi systems fail when:

- tokens behave unexpectedly
- prices are wrong
- permissions are weak
- accounting is broken

This project demonstrates how to defend against those issues.

---

## Conclusion

This is a security-focused, production-oriented DeFi vault system demonstrating:

- real attack protection
- defensive coding
- modular architecture
- audit-level thinking

It reflects how serious DeFi systems should be engineered.