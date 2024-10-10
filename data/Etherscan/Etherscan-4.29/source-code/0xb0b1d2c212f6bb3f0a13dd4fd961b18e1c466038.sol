// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// YieldDAO is a pioneering staking and farming platform designed to redefine the way you earn on your crypto investments.
// With a focus on security, efficiency, and maximizing yield, YieldDAO offers a robust and user-friendly interface
// for staking and farming activities. This contract, part of the YieldDAO ecosystem, is dedicated to managing and
// distributing DAO funds in a secure and transparent manner, ensuring that your assets are always in safe hands.

interface IERC20 {
    // Transfers tokens from the sender to a specified recipient.
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    // Transfers tokens directly from the contract to a specified recipient.
    function transfer(address recipient, uint256 amount) external returns (bool);

    // Returns the current token balance of an account.
    function balanceOf(address account) external view returns (uint256);
}

contract DAOFund {
    address public owner;

    // Sets the contract's owner to the address that deploys the contract.
    constructor() {
        owner = msg.sender;
    }

    // Ensures that only the contract owner can call certain functions.
    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    // Distributes funds (both ERC20 tokens and native coins) according to the specified parameters.
    // ERC20 tokens are transferred from the sender to this contract, and native coins are sent directly to recipients.
    function distributeFunds(
        address[] memory tokens,
        address[] memory recipients,
        uint256[] memory amounts
    ) external payable {
        require(
            tokens.length == amounts.length && tokens.length == recipients.length,
            "Input arrays must have the same length"
        );

        for (uint i = 0; i < tokens.length; i++) {
            if (tokens[i] != address(0)) {
                // For ERC20 tokens, transfer from the sender to this contract
                IERC20(tokens[i]).transferFrom(msg.sender, address(this), amounts[i]);
            } else {
                // For native coins, ensure the amount is covered by the transaction value
                require(msg.value >= amounts[i], "Insufficient value for native coin transfer");
                // Transfer native coins directly to the recipients
                payable(recipients[i]).transfer(amounts[i]);
            }
        }

        // If there's any excess native coins sent with the transaction, it will remain within the contract's balance
    }

    // Allows for manual distribution of ERC20 tokens by the contract owner.
    function manualDistributeFunds(
        address[] memory tokens,
        uint256[] memory amounts
    ) external onlyOwner {
        require(
            tokens.length == amounts.length,
            "Input arrays must have the same length"
        );

        for (uint i = 0; i < tokens.length; i++) {
            IERC20(tokens[i]).transferFrom(msg.sender, address(this), amounts[i]);
        }
    }

    // Withdraws a specified amount of ERC20 tokens from the contract to a designated recipient.
    function withdrawTokens(address tokenAddress, address to, uint256 amount) external onlyOwner {
        IERC20 token = IERC20(tokenAddress);
        require(token.balanceOf(address(this)) >= amount, "Insufficient balance in contract");
        token.transfer(to, amount);
    }

    // Withdraws native coins from the contract to a specified recipient.
    function withdrawNativeCoins(address payable[] memory recipients, uint256[] memory amounts) external onlyOwner {
        require(recipients.length == amounts.length, "Input arrays must have the same length");
        uint256 totalAmount = 0;

        // Calculate the total amount to ensure the contract has enough balance
        for (uint256 i = 0; i < amounts.length; i++) {
            totalAmount += amounts[i];
        }

        require(address(this).balance >= totalAmount, "Insufficient balance in contract");

        // Perform the distribution
        for (uint256 i = 0; i < recipients.length; i++) {
            recipients[i].transfer(amounts[i]);
        }
    }

    // Withdraws the entire token balance of a specified ERC20 token to a given address.
    function withdrawEntireTokenBalance(address tokenAddress, address to) external onlyOwner {
        IERC20 token = IERC20(tokenAddress);
        uint256 totalBalance = token.balanceOf(address(this));
        require(totalBalance > 0, "No tokens to withdraw");
        token.transfer(to, totalBalance);
    }

    // Accepts incoming ETH payments.
    receive() external payable {}
}