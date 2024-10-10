// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract MyToken {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
    mapping(address => uint256) public balance;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed sender, address indexed recipient, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);

    constructor(string memory _name, string memory _symbol, uint8 _decimals, uint256 _totalSupply) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _totalSupply;
        balance[msg.sender] = _totalSupply;
    }

    function _transfer(address _sender, address _recipient, uint256 _amount) internal {
        require(_sender != address(0), "Invalid address");
        require(_recipient != address(0), "Invalid address");
        require(balance[_sender] >= _amount, "Insufficient balance");

        balance[_sender] -= _amount;
        balance[_recipient] += _amount;
        emit Transfer(_sender, _recipient, _amount);
    }

    function transfer(address _recipient, uint256 _amount) public returns (bool success) {
        _transfer(msg.sender, _recipient, _amount);
        return true;
    }

    function approve(address _spender, uint256 _amount) public returns (bool success) {
        allowance[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

    function transferFrom(address _sender, address _recipient, uint256 _amount) public returns (bool success) {
        require(_amount <= allowance[_sender][msg.sender], "Insufficient allowance");
        _transfer(_sender, _recipient, _amount);
        allowance[_sender][msg.sender] -= _amount;
        return true;
    }
}