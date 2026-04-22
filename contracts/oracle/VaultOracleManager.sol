// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../interfaces/IVaultPriceOracle.sol";
import "../libraries/VaultErrors.sol";
import "../libraries/VaultEvents.sol";

contract VaultOracleManager {
    IVaultPriceOracle internal vaultOracle;

    constructor(address oracle_) {
        if (oracle_ == address(0)) {
            revert VaultErrors.ZeroAddress();
        }

        vaultOracle = IVaultPriceOracle(oracle_);
    }

    function _setOracle(address newOracle) internal {
        if (newOracle == address(0)) {
            revert VaultErrors.ZeroAddress();
        }

        address oldOracle = address(vaultOracle);
        vaultOracle = IVaultPriceOracle(newOracle);

        emit VaultEvents.OracleUpdated(oldOracle, newOracle);
    }

    function _getUsdValue(address asset, uint256 amount) internal view returns (uint256) {
        if (amount == 0) {
            revert VaultErrors.ZeroAmount();
        }

        if (address(vaultOracle) == address(0)) {
            revert VaultErrors.InvalidOracle();
        }

        if (!vaultOracle.isPriceValid(asset)) {
            revert VaultErrors.InvalidPrice(asset);
        }

        if (vaultOracle.isPriceStale(asset)) {
            revert VaultErrors.StalePrice(asset);
        }

        return vaultOracle.getUsdValue(asset, amount);
    }

    function getOracleAddress() external view returns (address) {
        return address(vaultOracle);
    }

    function previewUsdValue(address asset, uint256 amount) external view returns (uint256) {
        return _getUsdValue(asset, amount);
    }
}