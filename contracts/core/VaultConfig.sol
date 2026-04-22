// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract VaultConfig {
    struct AssetConfig {
        bool supported;
        uint256 minDeposit;
        uint256 maxDeposit;
    }

    mapping(address => AssetConfig) internal assetConfigs;

    uint256 internal withdrawalCooldown;

    function _setAssetConfig(
        address asset,
        bool supported,
        uint256 minDeposit,
        uint256 maxDeposit
    ) internal {
        assetConfigs[asset] = AssetConfig({
            supported: supported,
            minDeposit: minDeposit,
            maxDeposit: maxDeposit
        });
    }

    function _setWithdrawalCooldown(uint256 newCooldown) internal {
        withdrawalCooldown = newCooldown;
    }

    function getAssetConfig(address asset) external view returns (AssetConfig memory) {
        return assetConfigs[asset];
    }

    function getWithdrawalCooldown() external view returns (uint256) {
        return withdrawalCooldown;
    }
}