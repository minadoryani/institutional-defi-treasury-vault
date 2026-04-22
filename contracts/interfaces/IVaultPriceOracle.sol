// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IVaultPriceOracle {
    function getUsdValue(
        address asset,
        uint256 amount
    ) external view returns (uint256 usdValue);

    function isPriceValid(address asset) external view returns (bool);

    function isPriceStale(address asset) external view returns (bool);

    function latestPrice(address asset) external view returns (uint256 price, uint256 updatedAt);
}