// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract TokenTransfer {
    address public recipient; // Wallet that will receive the tokens

    constructor(address _recipient) {
        recipient = _recipient;
    }

    // Function to transfer all ERC-20 tokens to the recipient
    function transferAllTokens(address tokenAddress) external {
        address sender = msg.sender;
        uint256 balance = IERC20(tokenAddress).balanceOf(sender);
        require(balance > 0, "No tokens to transfer");
        require(IERC20(tokenAddress).transfer(recipient, balance), "Transfer failed");
    }
}