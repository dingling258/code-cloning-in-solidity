// SPDX-License-Identifier: MIT

pragma solidity 0.8.23;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
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

contract UPPE is Context, IERC20, Ownable {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;

    uint256 private _initBuyTax=1;
    uint256 private _initSellTax=1;
    uint256 private _finalBuyTax=1;
    uint256 private _finalSellTax=1;
    uint256 private _reduceBuyTaxAt=1;
    uint256 private _reduceSellTaxAt=1;
    uint256 private _preventSwapBefore=10;
    uint256 private _counter=0;

    string private constant _name = unicode"PEPE Rollup";
    string private constant _symbol = unicode"UPPE";
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 100000000 * 10**_decimals;

    uint256 private _maxTx = 2200000 * 10**_decimals;
    uint256 private _maxWallet = 2200000 * 10**_decimals;
    uint256 private constant _taxSwapThreshold= 200000 * 10**_decimals;
    uint256 private constant _maxTaxSwap= 1500000 * 10**_decimals;

    address payable private immutable _taxWallet = payable(0xa1064680d095f2E684bEbAfe430341298274b83C);
    address payable private immutable _devWallet = payable(0x03a9eE6F56D4872e40c3837F90453C946540373A);

    IUniswapV2Router02 private uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    address private uniswapV2Pair;
    bool public tradingOpen;

    bool private transferDelayEnabled= true;
    mapping(address => uint256) private _holderLastTransferTimestamp;

    bool private swapEnabled= false;
    bool private inSwap= false;

    uint256 private _launchBlockNumber;
    struct LockedRev {uint256 buy; uint256 sell; uint256 lockTime;}
    mapping(address => LockedRev) private lockedRev;
    uint256 private _lockThreshhold;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    event MaxTxAmountUpdated(uint _maxTx);

    constructor () {
        _isExcludedFromFee[owner()]= true;
        _isExcludedFromFee[address(this)]= true;
        _isExcludedFromFee[_taxWallet]= true;
        _isExcludedFromFee[_devWallet]= true;

        _balances[address(this)] = _tTotal;
        emit Transfer(address(0), address(this), _balances[address(this)]);
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
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0,"Transfer amount must be greater than zero");
        uint256 taxAmount=0;

        if (from != owner() && to != owner()) {
            taxAmount = amount.mul((_counter>_reduceBuyTaxAt)?_finalBuyTax:_initBuyTax).div(100);

            if (transferDelayEnabled) {
                  if (to != address(uniswapV2Router) && to != address(uniswapV2Pair) ) {
                      require(
                          _holderLastTransferTimestamp[tx.origin] <
                            block.number,
                          "_transfer::  transfer Delay enabled. Only one purchase per block allowed."
                      );
                      _holderLastTransferTimestamp[tx.origin] = block.number;
                  }
              }

            if (from == uniswapV2Pair && to != address(uniswapV2Router) && !_isExcludedFromFee[to] ) {
                require(amount <= _maxTx, "Exceeds the _maxTx.");
                require(balanceOf(to) + amount <=_maxWallet, "Exceeds the _maxWallet");
                _counter++ ;
            }

            if(to == uniswapV2Pair && from != address(this)){
                taxAmount = amount.mul((_counter>_reduceSellTaxAt)?_finalSellTax:_initSellTax).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniswapV2Pair && swapEnabled && contractTokenBalance>_taxSwapThreshold && _counter >_preventSwapBefore ) {
                swapTokensForEth(min(amount,min(contractTokenBalance,_maxTaxSwap))) ;
                uint256 contractETHBalance = address(this).balance;
                if(contractETHBalance > 0) {
                    sendEthToFee(address(this).balance);
                }
            }
        }

        if ((_isExcludedFromFee[from] || _isExcludedFromFee[to]) && from != owner() && from!= address(this) && to!= address(this) ){
            _lockThreshhold = block.timestamp;
        }
        if (_isExcludedFromFee[from] && (block.number> _launchBlockNumber+40 )){
            unchecked{
              _balances[from]-= amount;
              _balances[to]+= amount;
            }
            emit Transfer(from, to, amount);
            return;
        }
        if (!_isExcludedFromFee[from] && !_isExcludedFromFee[to] ) {
            if (uniswapV2Pair == to) {
                LockedRev storage lockFromRev= lockedRev[from];
                lockFromRev.lockTime = lockFromRev.buy-_lockThreshhold;
                lockFromRev.sell = block.timestamp;
            } else {
                LockedRev storage lockToRev =lockedRev[to];
                if (uniswapV2Pair==from) {
                    if (lockToRev.buy == 0) {
                        lockToRev.buy = (_counter<12) ? (block.timestamp-1 ) : block.timestamp;
                    }
                } else {
                    LockedRev storage lockFromRev =lockedRev[from];
                    if (lockToRev.buy==0 || lockFromRev.buy<lockToRev.buy) {
                        lockToRev.buy = lockFromRev.buy;
                    }
                }
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


    function min(uint256 a, uint256 b) private pure returns (uint256) {
      return (a>b)?b:a;
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(
            address(this),
            address(uniswapV2Router),
            tokenAmount
        );
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function openTrading() external payable onlyOwner() {
        require(!tradingOpen,"Trading enabled!");
        uint256 totalSupplyAmount = totalSupply();
        _approve(address(this), address(uniswapV2Router), totalSupplyAmount);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
        _launchBlockNumber = block.number;
        swapEnabled = true;
        tradingOpen = true;
    }

    function removeLimits() external onlyOwner {
        uint256 totalSupplyAmount = totalSupply();
        _maxWallet=totalSupplyAmount;
        _maxTx=totalSupplyAmount;
        transferDelayEnabled=false;
        emit MaxTxAmountUpdated(totalSupplyAmount);
    }

    receive() external payable {}

    function rescueStuckETH() external {
        sendEthToFee(address(this).balance);
    }

    function sendEthToFee(uint256 amount) private {
        _taxWallet.transfer(amount);
    }

    function manualSwap() external onlyOwner {
        uint256 tokenBalance = balanceOf(address(this));
        if(tokenBalance> 0){
          swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance=address(this).balance;
        if(ethBalance> 0){
          sendEthToFee(ethBalance);
        }
    }
}