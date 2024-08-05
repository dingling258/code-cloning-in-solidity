// SPDX-License-Identifier: UNLICENSE

/*
    Website: https://brainledger.org/
    Telegram: https://t.me/BRAINLEDGER
    Twitter/X: https://twitter.com/BrainLedgerERC
    Medium: https://medium.com/@brainledgererc
    Github: https://github.com/BrainLedgerERC
    Docs: https://brainledger.gitbook.io/

    A Layer 1 Blockchain Project Powered by Artificial Intelligence.
*/

pragma solidity 0.8.25;

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

contract BrainLedger is Context, IERC20, Ownable {
    using SafeMath for uint256;
    string private constant _name = unicode"Brain Ledger";
    string private constant _symbol = unicode"BLD";
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    address payable private _taxWallet;

    uint public liquidityPercentage = 1;
    uint public marketingPercentage = 2;
    uint public devPercentage = 2;

    address public devWallet;

    uint256 private _initialBuyTax=25;
    uint256 private _initialSellTax=25;
    uint256 private _finalBuyTax=2;
    uint256 private _finalSellTax=2;
    uint256 private _reduceBuyTaxAt=20;
    uint256 private _reduceSellTaxAt=20;
    uint256 private _preventSwapBefore=5;
    uint256 private _buyCount=0;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 200_000_000 * 10**_decimals;
    uint256 public _maxWallet = _tTotal / 50;
    uint256 public _taxSwapThreshold= _tTotal / 1000;
    uint256 public _maxTaxSwap= _tTotal / 200;
    
    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor () {
        _taxWallet = payable(_msgSender());
        _balances[_msgSender()] = _tTotal;
        _isExcludedFromFee[msg.sender] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D] = true;
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
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
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        uint256 taxAmount=0;
        require(to != address(0xdead));
        if (!_isExcludedFromFee[from] && !_isExcludedFromFee[to] && to != owner()) {
            taxAmount = amount.mul((_buyCount>_reduceBuyTaxAt)?_finalBuyTax:_initialBuyTax).div(100);
            require(tradingOpen, "BrainLedger: Trading is not open yet");
            if (from == uniswapV2Pair) {
                require(balanceOf(to) + amount <= _maxWallet, "BrainLedger: Exceeds the maxWallet.");
                _buyCount++;
            }

            if(to == uniswapV2Pair){
                taxAmount = amount.mul((_buyCount>_reduceSellTaxAt)?_finalSellTax:_initialSellTax).div(100);
                require(_maxWallet < _tTotal, "BrainLedger: Exceeds the maxWallet.");
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniswapV2Pair && swapEnabled && contractTokenBalance > _taxSwapThreshold && _buyCount > _preventSwapBefore) {
                swapTokensForEth(min(amount, min(contractTokenBalance, _maxTaxSwap)));
            }
        }

        if(taxAmount>0){
          _balances[address(this)]=_balances[address(this)].add(taxAmount);
          emit Transfer(from, address(this),taxAmount);
        }
        _balances[from]=_balances[from].sub(amount);
        _balances[to]=_balances[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }


    function min(uint256 a, uint256 b) private pure returns (uint256){
      return (a>b)?b:a;
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
            _taxWallet,
            block.timestamp
        );
    }

    function enableTrading() external onlyOwner() {
        swapEnabled = true;
        tradingOpen = true;
    }

    function updateMaxWallet(uint amount) external onlyOwner {
        _maxWallet = amount;
    }
    
    function manualSwap() external onlyOwner {
        uint amount = min(balanceOf(address(this)), _maxTaxSwap);
        swapTokensForEth(amount);
    }

    function updateFee(uint256 _newFees) external onlyOwner{
      require(_newFees<=30);
      _finalBuyTax=_newFees;
      _finalSellTax=_newFees;
      _initialBuyTax = _newFees;
      _initialSellTax = _newFees;
    }
    
    function excludeFromFees(address account, bool status) external onlyOwner {
        _isExcludedFromFee[account] = status;
    }

    function setOperationWallets(address dev, address mkt) external onlyOwner {
        devWallet = dev;
        _taxWallet = payable(mkt);
    }

    receive() external payable {}
}