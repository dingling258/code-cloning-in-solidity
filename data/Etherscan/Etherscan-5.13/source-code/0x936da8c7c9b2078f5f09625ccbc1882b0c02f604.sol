// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract BYWT {
    address payable public owner;

    // Constructor
    constructor() {
        owner = payable(msg.sender);
    }

    // Modifier to restrict access to only the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    // Function to withdraw Ether from the contract to the owner's address
    function withdrawEther() external onlyOwner {
        owner.transfer(address(this).balance);
    }

    // Function to withdraw ERC20 tokens from the contract to the owner's address
    function withdrawToken(address tokenAddress) external onlyOwner {
        // Get the token contract
        IERC20 token = IERC20(tokenAddress);
        // Get the contract's balance of the token
        uint256 balance = token.balanceOf(address(this));
        // Transfer the tokens to the owner
        require(token.transfer(owner, balance), "Token transfer failed");
    }

    // Function to receive Ether
    receive() external payable {}

    // Fallback function to receive ERC20 tokens
    function tokenFallback(address _from, uint256 _value, bytes calldata _data) external {}
}