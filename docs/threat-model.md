# Threat Model – Institutional DeFi Treasury Vault

## Overview

This document outlines the key security threats considered during the design and implementation of the Treasury Vault system, along with their corresponding mitigations.

The goal is to demonstrate a security-first engineering approach, focusing on realistic attack vectors in DeFi systems.

---

## 1. Reentrancy Attack

### Description

An attacker attempts to recursively call the `withdraw` function before the contract state is updated, allowing multiple withdrawals.

### Attack Vector

- Malicious contract receives tokens
- Triggers callback
- Calls `withdraw()` again before completion

### Mitigation

- OpenZeppelin `ReentrancyGuard`
- Checks-Effects-Interactions pattern
- Dedicated attack simulation using:
  - `ReentrantCallbackToken`
  - `ReentrancyAttacker`

### Status

Mitigated and tested

---

## 2. Oracle Manipulation

### Description

Incorrect or manipulated price data could allow attackers to deposit low-value assets and withdraw high-value assets.

### Attack Vector

- Invalid price feed
- Manipulated oracle values

### Mitigation

- `isPriceValid()` check
- Price must be > 0
- Reject invalid oracle states

### Status

Mitigated and tested

---

## 3. Stale Price Usage

### Description

Using outdated price data could lead to incorrect valuation.

### Attack Vector

- Oracle not updated
- Old price still used

### Mitigation

- `isPriceStale()` validation
- Timestamp-based checks

### Status

Mitigated and tested

---

## 4. Unauthorized Access

### Description

An attacker tries to call restricted functions such as:

- adding assets
- changing oracle
- pausing contract

### Attack Vector

- Direct contract interaction
- Role bypass attempts

### Mitigation

- OpenZeppelin `AccessControl`
- Role-based restrictions:
  - Admin
  - Risk Manager
  - Pauser

### Status

Mitigated and tested

---

## 5. Unsupported Asset Interaction

### Description

An attacker interacts with tokens not approved by the system.

### Attack Vector

- Deposit unsupported token
- Attempt withdrawal logic abuse

### Mitigation

- `onlySupportedAsset` modifier
- Explicit asset configuration

### Status

Mitigated and tested

---

## 6. Deposit Limit Abuse

### Description

Large or small deposits could disrupt system behavior.

### Attack Vector

- Deposit below minimum
- Deposit above maximum

### Mitigation

- Min / Max deposit validation
- Configurable per asset

### Status

Mitigated and tested

---

## 7. Withdrawal Abuse

### Description

Rapid withdrawals could exploit system timing or liquidity.

### Attack Vector

- Immediate withdrawal after deposit
- High-frequency withdrawal attempts

### Mitigation

- Withdrawal cooldown system
- Timestamp enforcement

### Status

Mitigated and tested

---

## 8. Emergency Scenario

### Description

Critical issue requires halting system operations.

### Attack Vector

- Unknown vulnerability
- Unexpected behavior

### Mitigation

- `pauseVault()` function
- Controlled by `PAUSER_ROLE`

### Status

Mitigated and implemented

---

## Conclusion

The system is designed with a proactive security approach, identifying and mitigating realistic attack scenarios.

The implementation combines:

- Defensive coding patterns
- Role-based permissions
- Oracle validation
- Active attack simulation
- Comprehensive test coverage

This reflects a production-oriented mindset for DeFi protocol development.