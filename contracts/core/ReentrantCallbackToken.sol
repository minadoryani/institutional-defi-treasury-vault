// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface IReentrancyTokenReceiver {
    function onTokenReceived() external;
}

contract ReentrantCallbackToken is ERC20 {
    address public callbackTarget;
    bool public callbackEnabled;

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 initialSupply_,
        address initialHolder_
    ) ERC20(name_, symbol_) {
        require(initialHolder_ != address(0), "Initial holder cannot be zero");
        require(initialSupply_ > 0, "Initial supply must be greater than zero");

        _mint(initialHolder_, initialSupply_);
    }

    function mint(address to, uint256 amount) external {
        require(to != address(0), "Mint to zero address");
        require(amount > 0, "Mint amount must be greater than zero");

        _mint(to, amount);
    }

    function setCallbackTarget(address target) external {
        callbackTarget = target;
    }

    function setCallbackEnabled(bool enabled) external {
        callbackEnabled = enabled;
    }

    function _update(address from, address to, uint256 value) internal override {
        super._update(from, to, value);

        if (
            callbackEnabled &&
            callbackTarget != address(0) &&
            to == callbackTarget &&
            from != address(0)
        ) {
            IReentrancyTokenReceiver(callbackTarget).onTokenReceived();
        }
    }
}