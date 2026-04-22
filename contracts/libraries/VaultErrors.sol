// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

library VaultErrors {
    error ZeroAddress();
    error ZeroAmount();
    error UnsupportedAsset(address asset);
    error AssetAlreadySupported(address asset);
    error Unauthorized(address caller);
    error VaultPaused();
    error InvalidPrice(address asset);
    error StalePrice(address asset);
    error DepositBelowMinimum(uint256 provided, uint256 minimumRequired);
    error DepositExceedsMaximum(uint256 provided, uint256 maximumAllowed);
    error WithdrawExceedsBalance(uint256 requested, uint256 available);
    error CooldownActive(uint256 availableAt, uint256 currentTime);
    error InvalidOracle();
    error InvalidConfiguration();
}