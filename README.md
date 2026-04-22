# Institutional DeFi Treasury Vault

## Overview

This project implements a secure, modular, and extensible DeFi Treasury Vault system designed with a strong focus on security, risk control, and real-world attack scenarios.

The system allows users to deposit and withdraw ERC20 assets while enforcing strict validation rules, oracle-based pricing, and role-based permissions.

The architecture is built to reflect production-level smart contract design, including separation of concerns, modular components, and explicit security controls.

---

## Key Features

- Multi-asset support (ERC20)
- Oracle-based USD valuation
- Role-based access control (Admin, Risk Manager, Pauser)
- Deposit and withdrawal limits
- Withdrawal cooldown enforcement
- Emergency pause / unpause mechanism
- Modular contract architecture
- Full unit test coverage
- Reentrancy protection with active attack simulation

---

## Architecture

The system is split into multiple components:

- **TreasuryVault.sol**  
  Core contract handling deposits, withdrawals, and balances

- **VaultAccessControl.sol**  
  Role-based permission system

- **VaultConfig.sol**  
  Asset configuration and limits

- **VaultOracleManager.sol**  
  Oracle integration and price validation

- **MockVaultPriceOracle.sol**  
  Simulated oracle for testing

- **ReentrantCallbackToken.sol**  
  Malicious ERC20 token used for attack simulation

- **ReentrancyAttacker.sol**  
  Attack contract used to simulate real-world reentrancy attacks

---

## Security Design

This system is designed with a strong focus on smart contract security:

### Reentrancy Protection
- Uses OpenZeppelin `ReentrancyGuard`
- Attack simulation included using callback-based ERC20 token
- Verified through automated test cases

### Access Control
- Role-based permissions via `AccessControl`
- Critical functions restricted to specific roles

### Oracle Validation
- Prices must be valid and not stale
- Deposits depend on oracle integrity

### Input Validation
- Zero checks
- Min/max deposit enforcement
- Supported asset validation

### Emergency Controls
- Pausable contract for emergency situations

---

## Threat Model

The system considers and mitigates the following threats:

- Reentrancy attacks
- Unauthorized access to privileged functions
- Invalid or manipulated price feeds
- Stale oracle data
- Unsupported asset interaction
- Excessive deposits or withdrawals
- Rapid withdrawal exploitation

---

## Testing Strategy

The project includes comprehensive test coverage:

- Deposit and withdrawal logic
- Access control validation
- Cooldown enforcement
- Pause/unpause behavior
- Oracle failure scenarios
- Invalid price handling
- Stale price rejection
- Reentrancy attack simulation

---

## Example Attack Scenario

A custom ERC20 token (`ReentrantCallbackToken`) triggers a callback during transfer, allowing a malicious contract to attempt reentrant withdrawals.

The system successfully prevents this attack using `ReentrancyGuard`.

---

## Future Improvements

- Multi-signature admin control
- Timelock for critical operations
- Integration with Chainlink Price Feeds
- Upgradeable proxy architecture
- Formal verification
- On-chain monitoring integration

---

## Conclusion

This project demonstrates production-oriented smart contract development with a focus on security, architecture, and real-world attack mitigation.

It is designed to reflect the expectations of high-level DeFi and blockchain engineering environments.