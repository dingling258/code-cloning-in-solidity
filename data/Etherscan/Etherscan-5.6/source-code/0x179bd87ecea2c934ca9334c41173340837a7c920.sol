// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ERC20Token {
    string public name; // Changed contract name to ERC20Token
    string public symbol; // Changed contract name to ERC20Token
    uint8 public decimals; // Changed contract name to ERC20Token
    uint256 public totalSupply; // Changed contract name to ERC20Token
    mapping(address => uint256) public balanceOf; // Changed contract name to ERC20Token
    mapping(address => mapping(address => uint256)) public allowance; // Changed contract name to ERC20Token

    event Transfer(address indexed from, address indexed to, uint256 value); // Changed contract name to ERC20Token
    event Approval(address indexed owner, address indexed spender, uint256 value); // Changed contract name to ERC20Token

    constructor(string memory _name, string memory _symbol, uint8 _decimals, uint256 _initialSupply) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _initialSupply * 10 ** uint256(decimals);
        balanceOf[msg.sender] = totalSupply;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) { // Changed contract name to ERC20Token
        require(_to != address(0), "ERC20: transfer to the zero address");
        require(balanceOf[msg.sender] >= _value, "ERC20: transfer amount exceeds balance");
        
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) { // Changed contract name to ERC20Token
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) { // Changed contract name to ERC20Token
        require(_from != address(0), "ERC20: transfer from the zero address");
        require(_to != address(0), "ERC20: transfer to the zero address");
        require(balanceOf[_from] >= _value, "ERC20: transfer amount exceeds balance");
        require(_value <= allowance[_from][msg.sender], "ERC20: transfer amount exceeds allowance");

        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }
}