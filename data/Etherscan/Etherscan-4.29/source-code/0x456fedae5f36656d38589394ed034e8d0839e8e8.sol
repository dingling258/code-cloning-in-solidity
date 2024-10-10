// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CATWIFE {
  string public name = "CAT WIFE";
  string public symbol = "CATW";
  uint256 public totalSupply = 1000000000; // 1 billion tokens with 9 decimals

  mapping(address => uint256) public balanceOf;

  constructor() {
    balanceOf[msg.sender] = totalSupply;
  }

  function transfer(address recipient, uint256 amount) public {
    require(balanceOf[msg.sender] >= amount, "Insufficient balance");
    balanceOf[msg.sender] -= amount;
    balanceOf[recipient] += amount;
  }
}