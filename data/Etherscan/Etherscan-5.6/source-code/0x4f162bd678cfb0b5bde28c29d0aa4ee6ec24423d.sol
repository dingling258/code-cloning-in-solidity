// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

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

contract ERC20 is IERC20 {
    uint256 public override totalSupply;
    uint256 public maxSupply;
    mapping(address => uint256) public override balanceOf;
    mapping(address => mapping(address => uint256)) public override allowance;
    string public name = "PreadiumX";
    string public symbol = "PreadiumX";
    uint8 public decimals = 9;
    address public owner;

    constructor() {
        owner = msg.sender;
        maxSupply = 500000000 * (10 ** uint256(decimals)); // Define total max supply 500 Million
        _mint(owner, maxSupply * 100 / 100); // Mint 100% of the maxSupply to the owner at launch
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "ERC20: Caller is not the owner");
        _;
    }
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        uint256 senderBalance = balanceOf[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            balanceOf[sender] = senderBalance - amount;
        }
        balanceOf[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    function approve(address spender, uint256 amount) external override returns (bool) {
        require(spender != address(0), "ERC20: approve to the zero address");
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = allowance[sender][msg.sender];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            allowance[sender][msg.sender] = currentAllowance - amount;
        }
        return true;
    }
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");
        require(totalSupply + amount <= maxSupply, "ERC20: max supply exceeded");
        totalSupply += amount;
        balanceOf[account] += amount;
        emit Transfer(address(0), account, amount);
    }
    function mint(uint256 amount) external onlyOwner {
        _mint(msg.sender, amount);
    }
    function burn(uint256 amount) external {
        require(msg.sender != address(0), "ERC20: burn from the zero address");
        uint256 accountBalance = balanceOf[msg.sender];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            balanceOf[msg.sender] = accountBalance - amount;
        }
        totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }
    function changeOwner(address newOwner) external onlyOwner {
        require(newOwner != address(0), "ERC20: new owner is the zero address");
        owner = newOwner;
    }
}