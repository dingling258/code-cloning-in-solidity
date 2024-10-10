// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
}

contract SmartContractWallet {
    address public owner;
    address public constant lockedTokenAddress = 0x797091E1f6c9Ce7BEb7dd6Ff1e4e4fBDe8fc0A06;
    uint256 public constant lockDuration = 80 * 365 days; // 80 years
    uint256 public lockEndTime;

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    constructor() {
        owner = msg.sender;
        lockEndTime = block.timestamp + lockDuration;
    }

    // Transfer any ERC-20 token except the locked token
    function transferERC20(address tokenAddress, address to, uint256 amount) public onlyOwner {
        require(tokenAddress != lockedTokenAddress, "This token is locked");
        IERC20(tokenAddress).transfer(to, amount);
    }

    // Transfer Ethereum
    function transferETH(address to, uint256 amount) public onlyOwner {
        require(address(this).balance >= amount, "Insufficient balance");
        payable(to).transfer(amount);
    }

    // Check the balance of any token
    function getTokenBalance(address tokenAddress) public view returns (uint256) {
        return IERC20(tokenAddress).balanceOf(address(this));
    }

    // Check the balance of Ethereum in the wallet
    function getETHBalance() public view returns (uint256) {
        return address(this).balance;
    }

    // Allow the contract to receive Ethereum
    receive() external payable {}

    // Transfer locked token after lock duration
    function transferLockedToken(address to, uint256 amount) public onlyOwner {
        require(block.timestamp >= lockEndTime, "The tokens are still locked");
        IERC20(lockedTokenAddress).transfer(to, amount);
    }
}