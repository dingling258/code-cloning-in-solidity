// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title PANDORA AI Token
 * @dev Implementation of the PANDORA AI ERC20 Token.
 * Symbol: PndAI
 * Name: PANDORA AI
 * Total supply: 1,000,000,000 (1 billion) tokens
 * Decimals: 18
 */
contract PANDORA_AI {
    string public constant name = "PANDORA AI";
    string public constant symbol = "PndAI";
    uint8 public constant decimals = 18;
    uint256 public constant totalSupply = 1000000000 * 10**uint256(decimals); // 1 billion tokens

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() {
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    function transfer(address to, uint256 value) external returns (bool) {
        require(to != address(0), "ERC20: transfer to the zero address");
        require(balanceOf[msg.sender] >= value, "ERC20: insufficient balance for transfer");

        _transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) external returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) external returns (bool) {
        require(to != address(0), "ERC20: transfer to the zero address");
        require(balanceOf[from] >= value, "ERC20: insufficient balance for transfer");
        require(allowance[from][msg.sender] >= value, "ERC20: insufficient allowance for transfer");

        allowance[from][msg.sender] -= value;
        _transfer(from, to, value);
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }
}