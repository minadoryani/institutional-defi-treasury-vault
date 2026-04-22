// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../interfaces/IVaultPriceOracle.sol";
import "../libraries/VaultErrors.sol";

contract MockVaultPriceOracle is IVaultPriceOracle {
    struct PriceData {
        uint256 price;
        uint256 updatedAt;
        bool valid;
        bool exists;
    }

    mapping(address => PriceData) private priceDataByAsset;

    uint256 public constant USD_DECIMALS = 1e18;
    uint256 public staleThreshold = 1 days;

    function setPrice(
        address asset,
        uint256 price,
        uint256 updatedAt,
        bool valid
    ) external {
        if (asset == address(0)) {
            revert VaultErrors.ZeroAddress();
        }

        if (price == 0) {
            revert VaultErrors.ZeroAmount();
        }

        priceDataByAsset[asset] = PriceData({
            price: price,
            updatedAt: updatedAt,
            valid: valid,
            exists: true
        });
    }

    function setStaleThreshold(uint256 newThreshold) external {
        if (newThreshold == 0) {
            revert VaultErrors.ZeroAmount();
        }

        staleThreshold = newThreshold;
    }

    function getUsdValue(
        address asset,
        uint256 amount
    ) external view override returns (uint256 usdValue) {
        if (amount == 0) {
            revert VaultErrors.ZeroAmount();
        }

        PriceData memory data = priceDataByAsset[asset];

        if (!data.exists || !data.valid) {
            revert VaultErrors.InvalidPrice(asset);
        }

        if (block.timestamp > data.updatedAt + staleThreshold) {
            revert VaultErrors.StalePrice(asset);
        }

        // price is expected in 1e18 precision
        return (amount * data.price) / USD_DECIMALS;
    }

    function isPriceValid(address asset) external view override returns (bool) {
        PriceData memory data = priceDataByAsset[asset];
        return data.exists && data.valid && data.price > 0;
    }

    function isPriceStale(address asset) external view override returns (bool) {
        PriceData memory data = priceDataByAsset[asset];

        if (!data.exists) {
            return true;
        }

        return block.timestamp > data.updatedAt + staleThreshold;
    }

    function latestPrice(address asset) external view override returns (uint256 price, uint256 updatedAt) {
        PriceData memory data = priceDataByAsset[asset];

        if (!data.exists) {
            revert VaultErrors.InvalidPrice(asset);
        }

        return (data.price, data.updatedAt);
    }
}