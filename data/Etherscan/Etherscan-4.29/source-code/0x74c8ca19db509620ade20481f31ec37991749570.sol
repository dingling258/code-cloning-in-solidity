// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
}

contract TokenLock {
    address private constant lockedWallet = 0xCb807EEb5c3CfD5EE3528D1E87714bdc5d2B6651;
    address private constant tokenAddress = 0x797091E1f6c9Ce7BEb7dd6Ff1e4e4fBDe8fc0A06;
    uint256 private constant lockAmount = 200_000_000 * (10 ** 18); // Assumes token has 18 decimal places
    uint256 private constant lockDuration = 80 * 365 days; // Approximation of 80 years
    uint256 private unlockTime;

    modifier onlyLockedWallet() {
        require(msg.sender == lockedWallet, "Only the locked wallet can perform this action.");
        _;
    }

    modifier lockExpired() {
        require(block.timestamp >= unlockTime, "The lock period has not expired yet.");
        _;
    }

    constructor() {
        unlockTime = block.timestamp + lockDuration;
        // The lockedWallet needs to approve the contract to spend the tokens before or after deployment
        // This can be done by calling the approve function of the token contract, not here
    }

    function transferLockedTokens(address to, uint256 amount) external onlyLockedWallet lockExpired {
        require(amount <= lockAmount, "Cannot transfer more than the locked amount.");
        bool success = IERC20(tokenAddress).transferFrom(lockedWallet, to, amount);
        require(success, "Token transfer failed.");
    }

    // Optional: Add functionality to check token balance in this wallet
    function checkBalance() public view returns (uint256) {
        return IERC20(tokenAddress).balanceOf(lockedWallet);
    }
}