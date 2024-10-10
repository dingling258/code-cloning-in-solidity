// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract Airdrop {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }


    function sendToken(IERC20 token, address[] calldata recipients, uint256[] calldata amounts) external onlyOwner {
        require(recipients.length == amounts.length, "Recipients and amounts must match in length");
        for (uint256 i = 0; i < recipients.length; i++) {
            require(token.transferFrom(owner, recipients[i], amounts[i]), "Transfer failed");
        }
    }


    function withdrawToken(IERC20 token) external onlyOwner {
        uint256 contractBalance = token.balanceOf(address(this));
        require(token.transfer(owner, contractBalance), "Transfer failed");
    }
}