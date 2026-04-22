// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockERC20 is ERC20 {
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
}