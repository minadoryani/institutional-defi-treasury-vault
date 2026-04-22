// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

library VaultEvents {
    event SupportedAssetAdded(address indexed asset);
    event SupportedAssetRemoved(address indexed asset);

    event Deposit(
        address indexed user,
        address indexed asset,
        uint256 amount,
        uint256 usdValue
    );

    event Withdraw(
        address indexed user,
        address indexed asset,
        uint256 amount,
        uint256 usdValue
    );

    event EmergencyPause(address indexed triggeredBy);
    event EmergencyUnpause(address indexed triggeredBy);

    event OracleUpdated(address indexed oldOracle, address indexed newOracle);

    event MinimumDepositUpdated(address indexed asset, uint256 oldAmount, uint256 newAmount);
    event MaximumDepositUpdated(address indexed asset, uint256 oldAmount, uint256 newAmount);
    event CooldownUpdated(uint256 oldCooldown, uint256 newCooldown);
}