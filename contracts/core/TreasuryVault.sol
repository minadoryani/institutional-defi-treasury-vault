// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

import "../access/VaultAccessControl.sol";
import "./VaultConfig.sol";
import "../oracle/VaultOracleManager.sol";
import "../libraries/VaultErrors.sol";
import "../libraries/VaultEvents.sol";

contract TreasuryVault is VaultAccessControl, VaultConfig, VaultOracleManager, ReentrancyGuard, Pausable {
    mapping(address => mapping(address => uint256)) private userBalances;
    mapping(address => uint256) private lastDepositTimestamp;

    constructor(address admin_, address oracle_)
        VaultAccessControl(admin_)
        VaultOracleManager(oracle_)
    {}

    modifier onlySupportedAsset(address asset) {
        if (!assetConfigs[asset].supported) {
            revert VaultErrors.UnsupportedAsset(asset);
        }
        _;
    }

    function addSupportedAsset(
        address asset,
        uint256 minDeposit,
        uint256 maxDeposit
    ) external onlyRole(RISK_MANAGER_ROLE) {
        if (asset == address(0)) {
            revert VaultErrors.ZeroAddress();
        }

        if (minDeposit == 0 || maxDeposit == 0 || minDeposit > maxDeposit) {
            revert VaultErrors.InvalidConfiguration();
        }

        if (assetConfigs[asset].supported) {
            revert VaultErrors.AssetAlreadySupported(asset);
        }

        _setAssetConfig(asset, true, minDeposit, maxDeposit);

        emit VaultEvents.SupportedAssetAdded(asset);
    }

    function removeSupportedAsset(address asset)
        external
        onlyRole(RISK_MANAGER_ROLE)
        onlySupportedAsset(asset)
    {
        _setAssetConfig(asset, false, 0, 0);

        emit VaultEvents.SupportedAssetRemoved(asset);
    }

    function setMinimumDeposit(address asset, uint256 newMinimum)
        external
        onlyRole(RISK_MANAGER_ROLE)
        onlySupportedAsset(asset)
    {
        if (newMinimum == 0 || newMinimum > assetConfigs[asset].maxDeposit) {
            revert VaultErrors.InvalidConfiguration();
        }

        uint256 oldMinimum = assetConfigs[asset].minDeposit;
        assetConfigs[asset].minDeposit = newMinimum;

        emit VaultEvents.MinimumDepositUpdated(asset, oldMinimum, newMinimum);
    }

    function setMaximumDeposit(address asset, uint256 newMaximum)
        external
        onlyRole(RISK_MANAGER_ROLE)
        onlySupportedAsset(asset)
    {
        if (newMaximum == 0 || newMaximum < assetConfigs[asset].minDeposit) {
            revert VaultErrors.InvalidConfiguration();
        }

        uint256 oldMaximum = assetConfigs[asset].maxDeposit;
        assetConfigs[asset].maxDeposit = newMaximum;

        emit VaultEvents.MaximumDepositUpdated(asset, oldMaximum, newMaximum);
    }

    function setWithdrawalCooldown(uint256 newCooldown) external onlyRole(RISK_MANAGER_ROLE) {
        uint256 oldCooldown = withdrawalCooldown;
        _setWithdrawalCooldown(newCooldown);

        emit VaultEvents.CooldownUpdated(oldCooldown, newCooldown);
    }

    function setOracle(address newOracle) external onlyRole(RISK_MANAGER_ROLE) {
        _setOracle(newOracle);
    }

    function pauseVault() external onlyRole(PAUSER_ROLE) {
        _pause();
        emit VaultEvents.EmergencyPause(msg.sender);
    }

    function unpauseVault() external onlyRole(PAUSER_ROLE) {
        _unpause();
        emit VaultEvents.EmergencyUnpause(msg.sender);
    }

    function deposit(address asset, uint256 amount)
        external
        nonReentrant
        whenNotPaused
        onlySupportedAsset(asset)
    {
        if (amount == 0) {
            revert VaultErrors.ZeroAmount();
        }

        AssetConfig memory config = assetConfigs[asset];

        if (amount < config.minDeposit) {
            revert VaultErrors.DepositBelowMinimum(amount, config.minDeposit);
        }

        if (amount > config.maxDeposit) {
            revert VaultErrors.DepositExceedsMaximum(amount, config.maxDeposit);
        }

        uint256 usdValue = _getUsdValue(asset, amount);

        bool success = IERC20(asset).transferFrom(msg.sender, address(this), amount);
        if (!success) {
            revert VaultErrors.InvalidConfiguration();
        }

        userBalances[msg.sender][asset] += amount;
        lastDepositTimestamp[msg.sender] = block.timestamp;

        emit VaultEvents.Deposit(msg.sender, asset, amount, usdValue);
    }

    function withdraw(address asset, uint256 amount)
        external
        nonReentrant
        whenNotPaused
        onlySupportedAsset(asset)
    {
        if (amount == 0) {
            revert VaultErrors.ZeroAmount();
        }

        uint256 balance = userBalances[msg.sender][asset];
        if (amount > balance) {
            revert VaultErrors.WithdrawExceedsBalance(amount, balance);
        }

        uint256 availableAt = lastDepositTimestamp[msg.sender] + withdrawalCooldown;
        if (block.timestamp < availableAt) {
            revert VaultErrors.CooldownActive(availableAt, block.timestamp);
        }

        uint256 usdValue = _getUsdValue(asset, amount);

        userBalances[msg.sender][asset] = balance - amount;

        bool success = IERC20(asset).transfer(msg.sender, amount);
        if (!success) {
            revert VaultErrors.InvalidConfiguration();
        }

        emit VaultEvents.Withdraw(msg.sender, asset, amount, usdValue);
    }

    function getUserBalance(address user, address asset) external view returns (uint256) {
        return userBalances[user][asset];
    }

    function getLastDepositTimestamp(address user) external view returns (uint256) {
        return lastDepositTimestamp[user];
    }

    function isAssetSupported(address asset) external view returns (bool) {
        return assetConfigs[asset].supported;
    }
}