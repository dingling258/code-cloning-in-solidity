/*
//
//  Waiting room for upcoming big launch
//  https://t.me/+db1o_lbleZZmYWEy
//
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.23;



contract Platform {
    string private constant _name = "Apers Platform";
    string private constant _symbol = "AP";

    uint8 private constant _decimals = 9;
    uint256 private constant _totalSupply = 10000 * 10**_decimals;
   
    mapping(address => uint256) private _balance;
    mapping(address => mapping(address => uint256)) private _allowances;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
   
    constructor() payable {
        _balance[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public pure returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balance[account];
    }

    function transfer(address recipient, uint256 amount)public returns (bool){
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256){
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool){
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender,msg.sender,_allowances[sender][msg.sender]-amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0) && spender != address(0), "approve zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        _balance[from] = _balance[from] - amount;
        _balance[to] = _balance[to] + amount;
        emit Transfer(from, to, amount);
    }

}