/**
    Innovative Solutions for all levels of expertise. 
    Provide code generation with precision and speed, 
    Automate Your Development Process, AI-Assisted Design-to-Code Conversion
    
    https://t.me/omnifoundation
    https://x.com/omnfoundation
    https://www.omnifoundation.io

**/

pragma solidity 0.8.16;
// SPDX-License-Identifier: MIT
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
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
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
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
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

}

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

contract OMNI is Context, IERC20, Ownable {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;

    address payable private _taxWallet;

    string private constant _name = unicode"Omni";
    string private constant _symbol = unicode"OMN";
    uint8 private constant _decimals = 18;
    uint256 private constant _tTotal = 100000000 * 10**_decimals;

    uint256 private _buyTax = 25;
    uint256 private _sellTax = 25;
    uint256 private _pSwapBefore = 5;
    uint256 private _bCount = 0;

    uint256 public _maxTxAmount = 1000000 * 10**_decimals;
    uint256 public _maxWalletSize = 1000000 * 10**_decimals;
    uint256 public _taxSwapThreshold = 100000 * 10**_decimals;
    uint256 public _maxTaxSwap = 1000000 * 10**_decimals;

    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;

    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;

    event TradingOpened();
    event LimitRemoved();
    event TaxUpdated(uint256 buyTax, uint256 sellTax);

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor () {
        _taxWallet = payable(_msgSender());
        _balances[_msgSender()] = _tTotal;

        excludeFromFee(owner(), true);
        excludeFromFee(address(this), true);
        excludeFromFee(address(0xdead), true);
        excludeFromFee(_taxWallet, true);

        emit Transfer(address(0), _msgSender(), _tTotal);
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

    function totalSupply() public pure override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0) && to != address(0), "ERC20: transfer the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount=0;

        if (from != owner() && to != owner()) {
            if (!tradingOpen) {
                require( 
                    _isExcludedFromFee[to] || _isExcludedFromFee[from],
                    "trading is not yet open"
                );
            }

            if (from == uniswapV2Pair && to != address(uniswapV2Router) && ! _isExcludedFromFee[to]) {
                require(amount <= _maxTxAmount, "_transfer: Exceeds the _maxTxAmount.");
                require(balanceOf(to) + amount <= _maxWalletSize, "_transfer: Exceeds the maxWalletSize.");
                _bCount++;
            }

            if ( to == uniswapV2Pair && from != address(this)){
                taxAmount = amount.mul(_sellTax).div(100);
            } else if (from == uniswapV2Pair && to != address(this)){
                taxAmount = amount.mul(_buyTax).div(100);   
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniswapV2Pair && swapEnabled && 
                contractTokenBalance > _taxSwapThreshold && 
                _bCount > _pSwapBefore 
            ) {
                swapTokensForEth(min(amount,min(contractTokenBalance,_maxTaxSwap)));
                uint256 contractETHBalance = address(this).balance;
                if(contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
                }
            }
        }

        if(taxAmount > 0) {
          _balances[address(this)]=_balances[address(this)].add(taxAmount);
          emit Transfer(from, address(this),taxAmount);
        }

        _balances[from]=_balances[from].sub(amount);
        _balances[to]=_balances[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }

    function excludeFromFee(address account, bool excluded) public onlyOwner {
        _isExcludedFromFee[account] = excluded;
    }

    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
    }

    function sendETHToFee(uint256 amount) private {
        _taxWallet.transfer(amount);
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function initialize() external onlyOwner {
        require(!tradingOpen,"initialize: init already called");
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
    }

    function setInitialTax(uint256 _bTax, uint256 _sTax) external onlyOwner {
        _buyTax=_bTax;
        _sellTax=_sTax;
        emit TaxUpdated(_buyTax, _sellTax);
    }

    function onOpenTrade() external onlyOwner() {
        require(!tradingOpen,"onOpenTrade: trading already open");
        swapEnabled=true;
        tradingOpen=true;
        emit TradingOpened();
    }

    function onRemoveLimit() external onlyOwner{
        _maxTxAmount=_tTotal;
        _maxWalletSize=_tTotal;
        emit LimitRemoved();
    }

    function setFinalTax(uint256 _bTax, uint256 _sTax) external onlyOwner {
        require(tradingOpen, "onUpdateBuyTax: trading is not yet open");
        require(_bTax <= 10 && _sTax <= 10, "onUpdateBuyTax: final buy / sell tax should be less than or equal to 10");
        _buyTax=_bTax;
        _sellTax=_sTax;
        emit TaxUpdated(_buyTax, _sellTax);
    }

    receive() external payable {}

    function manualSwap() external {
        require(_msgSender() == _taxWallet);

        uint256 tokenBalance = balanceOf(address(this));
        if(tokenBalance>0){
          swapTokensForEth(tokenBalance);
        }

        uint256 ethBalance = address(this).balance;
        if(ethBalance>0){
          sendETHToFee(ethBalance);
        }
    }

    function onClearStuckEth() external {
        require(address(this).balance > 0, "Token: no ETH to clear");
        require(_msgSender() == _taxWallet);
        payable(msg.sender).transfer(address(this).balance);
    }

    function manualSend() external onlyOwner{
        uint256 contractETHBalance = address(this).balance;
        sendETHToFee(contractETHBalance);
    }
}