// SPDX-License-Identifier: MIT

// https://luxchain.io/ 

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

contract LuxChain is IERC20 {
    string public name = "LuxChain";
    string public symbol = "LUX";
    uint8 public decimals = 18;
    uint256 private _totalSupply;
    uint256 private _burnedTokens = 0;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    
    address public owner;
    uint256 public constant CAP = 33000000 * 10**18;  // 33M MAX SUPPLY

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function forge(address to, uint256 amount) external onlyOwner {
        require(_totalSupply + _burnedTokens + amount <= CAP, "Exceeds CAP");
        _forge(to, amount);
    }

    function transferOwnership(address newOwner) external onlyOwner {
        owner = newOwner;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address _owner, address spender) public view override returns (uint256) {
        return _allowances[_owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
        return true;
    }

    function burn(uint256 amount) public onlyOwner {
        require(_balances[msg.sender] >= amount, "Insufficient balance to burn");
        _balances[msg.sender] = _balances[msg.sender] - amount;
        _burnedTokens += amount;
        _totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }

    function totalBurned() public view returns (uint256) {
        return _burnedTokens;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "Invalid sender address");
        require(recipient != address(0), "Invalid recipient address");
        require(_balances[sender] >= amount, "Insufficient balance");
        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient] + amount;
        emit Transfer(sender, recipient, amount);
    }

    function _forge(address account, uint256 amount) internal {
        require(account != address(0), "Invalid address");
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _approve(address _owner, address spender, uint256 amount) internal {
        require(_owner != address(0), "Invalid owner address");
        require(spender != address(0), "Invalid spender address");
        require(_allowances[_owner][spender] >= 0, "Invalid allowance amount");
        _allowances[_owner][spender] = amount;
        emit Approval(_owner, spender, amount);
    }
}