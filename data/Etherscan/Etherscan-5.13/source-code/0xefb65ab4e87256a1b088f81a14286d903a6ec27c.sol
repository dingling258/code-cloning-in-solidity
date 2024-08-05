// SPDX-License-Identifier: MIT
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

contract ERC20Token is IERC20 {
    string public name = "BIGSAM";
    string public symbol = "BIGSAM";
    uint8 public decimals = 18;
    uint256 private _totalSupply = 1000000 * 10**uint256(decimals);
    uint256 public taxRate = 5; // 5% tax
    address public taxwallet;
    address public uniswapRouter; // Address of Uniswap Router contract
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    constructor(address _router, address _taxwallet) {
        _balances[msg.sender] = _totalSupply;
        taxwallet = _taxwallet;
        uniswapRouter = _router;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
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

    function _transfer(address sender, address recipient, uint256 amount) private {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(_balances[sender] >= amount, "ERC20: transfer amount exceeds balance");
        
        uint256 taxAmount = sender == taxwallet || sender == uniswapRouter ? 0 : (amount * taxRate) / 100;
        uint256 transferAmount = amount - taxAmount;

        _balances[sender] -= amount;
        _balances[recipient] += transferAmount;
        _balances[address(this)] += taxAmount; // Accumulate tax in the contract

        emit Transfer(sender, recipient, transferAmount);
        if (taxAmount > 0) {
            emit Transfer(sender, address(this), taxAmount); // Transfer tax to the contract
        }
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    // Function to recover tax as ETH
    function recoverTax() external {
        require(msg.sender == taxwallet, "Only owner can recover tax");
        uint256 accuTax = _balances[address(this)]; // Accumulated tax amount held by the contract
        require(accuTax > 0, "No tax to recover");
        
        // Transfer tax amount as ETH to the owner
        payable(taxwallet).transfer(accuTax);
    }

    // Function to show the accumulated tax in the contract
    function accumulatedTax() external view returns (uint256) {
        return _balances[address(this)];
    }
}