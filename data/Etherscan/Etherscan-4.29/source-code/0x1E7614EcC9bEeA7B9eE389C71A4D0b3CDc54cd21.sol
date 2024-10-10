// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

contract InTheNameToken {
    string public name = "inthename";
    string public symbol = "ITN";
    uint256 public totalSupply = 23000000 * 10**18; // 23 millions de tokens avec 18 décimales

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() {
        balanceOf[msg.sender] = totalSupply;
    }

    function transfer(address to, uint256 value) external returns (bool) {
        require(balanceOf[msg.sender] >= value, "Solde insuffisant");
        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) external returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) external returns (bool) {
        require(balanceOf[from] >= value, "Solde insuffisant");
        require(allowance[from][msg.sender] >= value, "Autorisation insuffisante");
        balanceOf[from] -= value;
        balanceOf[to] += value;
        allowance[from][msg.sender] -= value;
        emit Transfer(from, to, value);
        return true;
    }

    function getAllowance(address owner, address spender) external view returns (uint256) {
        return allowance[owner][spender];
    }
}