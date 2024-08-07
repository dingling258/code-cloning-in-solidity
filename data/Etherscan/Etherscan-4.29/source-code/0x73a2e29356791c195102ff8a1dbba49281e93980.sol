// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
 
abstract contract Ownable {
    address internal owner;
 
    constructor(address _owner) {
        owner = _owner;
    }
 
    modifier onlyOwner() {
        require(isOwner(msg.sender), "Only owner can execute the following");
        _;
    }
 
    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }
 
    function renounceOwnership() public onlyOwner {
        owner = address(0);
        emit OwnershipTransferred(address(0));
    }
 
    event OwnershipTransferred(address owner);
}
 
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
 
library SafeMath { 
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
 
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
 
        return c;
    } 
    function mul(uint256 a, uint256 b) internal pure returns (uint256) { 
        if (a == 0) {
            return 0;
        }
 
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
 
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}
 
 
contract ERC20 is IERC20 {
    using SafeMath for uint256;
 
    mapping (address => uint256) private _balances;
 
    mapping (address => mapping (address => uint256)) private _allowances;
 
    uint256 private _totalSupply;
 
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
 
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }
 
    function transfer(address recipient, uint256 amount) public virtual returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
 
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }
 
    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }
 
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }
 
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }
 
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }
 
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
 
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
 
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");
 
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }
 
    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
 
        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }
}
 
interface IUniswapV2Router02 {
    function WETH() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}
 
 
interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}
 
contract Amami is ERC20, Ownable {
    using SafeMath for uint256;
    IUniswapV2Router02 public immutable uniswapV2Router02 = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    IUniswapV2Factory public immutable uniswapV2Factory = IUniswapV2Factory(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);
    address AMAMI_COLLECTOR;
    address DEV_ADDRESS;
    address AmamiLiquidityLock;
 
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 public buyFees = 4;
    uint256 public sellFees = 4;
 
    bool private liquifying;
    uint256 liquifyModifier = 5;
 
    uint256 maxWalletSize = 0;
    uint256 maxTransactionAmount = 0;
 
    mapping(address => bool) private _isExemptFromFees;
    mapping(address => bool) public _isExmptFromMaxTransactionAmount;
 
    bool private liquifyingEnabled = true;
    bool private limitsInEffect = true;
 
    constructor(string memory __name, string memory __symbol, uint8 __decimals, uint256 __totalSupply, address _collector, address _devAddress) Ownable(msg.sender) payable {
        _name = __name;
        _symbol = __symbol;
        _decimals = __decimals;
 
        _isExemptFromFees[owner] = true;
        _isExemptFromFees[address(this)] = true;
        _isExemptFromFees[address(0xdead)] = true;
 
        _isExmptFromMaxTransactionAmount[owner]= true;
        _isExmptFromMaxTransactionAmount[address(this)] =  true;
        _isExmptFromMaxTransactionAmount[address(0xdead)] = true;
 
        uint256 totalSupply = __totalSupply * (10 ** __decimals);
        uint256 walletSize = 2;
        maxWalletSize = walletSize.mul(totalSupply).div(100);
        maxTransactionAmount = walletSize.mul(totalSupply).div(100);
 
        _mint(owner, totalSupply);
 
        AMAMI_COLLECTOR = _collector;
        DEV_ADDRESS = _devAddress;
    } 
 
    function name() public view returns (string memory) {
        return _name;
    }
 
    function symbol() public view returns (string memory) {
        return _symbol;
    }
 
    function decimals() public view returns (uint8) {
        return _decimals;
    }
 
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
 
    function getMarketMakerPair() public view returns (address){
        return uniswapV2Factory.getPair(uniswapV2Router02.WETH(), address(this));
    }
 
    function setLiquifyModifier(uint256 _newLiquifyModifier) public onlyOwner {
        liquifyModifier = _newLiquifyModifier;
    }
 
    function modifyFeeConfig(uint256 _newBuyFeesModifier, uint256 _newSellFeesModifier) public onlyOwner {
        require(_newBuyFeesModifier <= 5, "Buy fees cannot exceed 5%");
        require(_newSellFeesModifier <= 5, "Sell fees cannot exceed 5%");
        buyFees = _newBuyFeesModifier;
        sellFees = _newSellFeesModifier;
    }
 
    function updateFlags(bool _limitsInEffect, bool _liquifyingEnabled) public onlyOwner {
        limitsInEffect = _limitsInEffect;
        liquifyingEnabled = _liquifyingEnabled;
    }
 
    function setLockerAllowance(address _liquidityLockAddress) public onlyOwner {
        AmamiLiquidityLock = _liquidityLockAddress;
        _isExmptFromMaxTransactionAmount[_liquidityLockAddress] = true;
        _isExemptFromFees[_liquidityLockAddress] = true;
    }
 
    function setWalletConfig(uint256 _newWalletSize, uint256 _newMaxTxAmount) public onlyOwner {
        uint256 minPercentage = 1;
        uint256 finalWalletSize = _newWalletSize.mul(10 ** decimals());
        uint256 finalMaxTxAmount = _newMaxTxAmount.mul(10 ** decimals());
 
        require(finalWalletSize >= minPercentage.mul(totalSupply()).div(100), "Wallet size cannot be lower than 1%");
        require(finalMaxTxAmount >= minPercentage.mul(totalSupply()).div(100), "Max tx amount cannot be lower than 1%");
 
        if (_newWalletSize >= totalSupply()) {
            maxWalletSize = type(uint256).max;
        } else {
            maxWalletSize = finalWalletSize;
        }
 
         if (_newMaxTxAmount >= totalSupply()) {
            maxTransactionAmount = type(uint256).max;
        } else {
            maxTransactionAmount = finalMaxTxAmount;
        }
    }
 
    function getBuyFees() public view returns (uint256) {
      return buyFees;  
    }
 
    function getSellFees() public view returns (uint256) {
      return sellFees;  
    } 
 
    function getLiquifyModifier() public view returns (uint256) {
      return liquifyModifier;  
    }
 
    function getMaxWalletSize() public view returns (uint256) {
      return maxWalletSize;  
    }
 
    function getMaxTransactionAmount() public view returns (uint256) {
      return maxTransactionAmount;  
    }
 
    function isLimitsInEffect() public view returns (bool) {
      return limitsInEffect;  
    }
 
    function isLiquifingEnabled() public view returns (bool) {
      return liquifyingEnabled;  
    }
 
    function swapTokensForEth(uint256 tokenAmount) internal {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router02.WETH();
 
        _approve(address(this), address(uniswapV2Router02), tokenAmount);
 
        uniswapV2Router02.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            DEV_ADDRESS,
            block.timestamp
        );
    }
 
    function canSelfSwap() public view returns (bool) {
        uint256 balance = balanceOf(address(this));
        if (balance.mul(1000).div(totalSupply()) >= liquifyModifier) {
            return true;
        } else {
            return false;
        }
    }
 
    function liquify() internal {
        uint256 available = totalSupply().mul(liquifyModifier).div(1000);
        uint256 tokens = available.div(2);
        swapTokensForEth(tokens);
        uint256 remaining = available - tokens;
        super._transfer(address(this), AMAMI_COLLECTOR, remaining);
 
    }
 
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount != 0, "ERC20: amount equals zero");
 
        if (limitsInEffect) {
            if (from != owner && to != owner && to != address(0) && to != address(0xdead) && !liquifying) {
                if (getMarketMakerPair() == from && !_isExmptFromMaxTransactionAmount[to]) {
                    require(amount <= maxTransactionAmount, "Buy transfer amount exceeds max transaction amount.");
                    require(amount + balanceOf(to) <= maxWalletSize, "Max wallet exceeded" );
                } else if (getMarketMakerPair() == to && !_isExmptFromMaxTransactionAmount[from]) {
                    require(amount <= maxTransactionAmount,"Sell transfer amount exceeds the max transaction amount.");
                } else if (!_isExmptFromMaxTransactionAmount[to]) {
                    require(amount + balanceOf(to) <= maxWalletSize, "Max wallet has exceeded");
                }
            }
        }
 
        if (canSelfSwap() && liquifyingEnabled && !liquifying && getMarketMakerPair() != from && !_isExemptFromFees[from] && !_isExemptFromFees[to]) {
            liquifying = true;
            liquify();
            liquifying = false;
        }
 
        bool takeFee = !liquifying;
 
        if (_isExemptFromFees[from] || _isExemptFromFees[to]) {
            takeFee = false;
        }
 
        uint256 fees = 0;
        if (takeFee) {
            if (getMarketMakerPair() == to && sellFees > 0) {
                fees = amount.mul(sellFees).div(100);
            } else if (getMarketMakerPair() == from && buyFees > 0) {
                fees = amount.mul(buyFees).div(100);
            }
 
            if (fees > 0) {
                super._transfer(from, address(this), fees);
            }
            amount -= fees;
        }
 
        super._transfer(from, to, amount);
    }
}