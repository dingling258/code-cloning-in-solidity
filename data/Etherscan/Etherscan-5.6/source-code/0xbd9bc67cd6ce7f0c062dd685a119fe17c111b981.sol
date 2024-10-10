/* Runegraph [ERC-20] */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

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

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
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

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );
}

contract Runegraph is Context, IERC20, Ownable {
    using SafeMath for uint256;

    string private constant _name = unicode"Runegraph";
    string private constant _symbol = unicode"GRAPH";
    uint8 private constant  _decimals = 18;

    mapping(address => uint256) private _balanceOf;
    mapping(address => uint256) private _firstTransferBlockOf;
    mapping(address => bool)    private _isExcludedFromFee;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private constant MAX = ~uint256(0);
    uint256 private constant _totalSupply =  24700000 * (10 ** _decimals); 

    uint256 private constant _blocksPerMinute = 4;
    uint256 private constant _blocksPerDay = 5760; 

    uint256 private constant _quickBuyThreshold = 10 * _blocksPerMinute; 
    uint256 private constant _feeOnSnipedBuy = 20;

    uint256 private constant _feeOnSellSameBlock  = 50;
    uint256 private constant _feeOnSellQuickTrade = 30;
    uint256 private constant _feeOnSellIntraDay   = 15;
    uint256 private constant _feeOnSellInterDay   = 5;

    uint256 private _feeOnBuy = 5;
    uint256 private _feeOnSell = 5;

    uint256 private _taxFee = _feeOnBuy;
    uint256 private _previousTaxFee = _taxFee;

    address payable private _marketingWallet = payable(0x3d4B0d708A9b212A8503BAFEFba27dB88992006d);

    IUniswapV2Router02 public   uniswapV2Router;
    address public              uniswapV2Pair;

    uint256 private _tradeOpenedBlock = 0;
    bool private _tradingOpen = false;
    bool private _swapLock = false;

    uint256 public _maxWalletSize = _totalSupply / 10;
    uint256 public _minTokensForSwap = _totalSupply / 250;
    uint256 public _maxTokensForSwap = _totalSupply / 100;

    constructor(address uniswapRouter) {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(uniswapRouter);
        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_marketingWallet] = true;

        _balanceOf[owner()] = _totalSupply;
        _transfer(owner(), _marketingWallet, _totalSupply / 20);

        emit Transfer(address(0), owner(), _totalSupply);
    }
    
    modifier lockSwap {
        _swapLock = true;
        _;
        _swapLock = false;
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
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balanceOf[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function getBuyTaxFee() private view returns (uint256)
    {
        uint256 elapsedBlocks = block.number - _tradeOpenedBlock;
        return elapsedBlocks > _quickBuyThreshold ? _feeOnBuy : _feeOnSnipedBuy;
    }

    function getSellTaxFeeFor(address from) private view returns (uint256)
    {
        uint256 firstTransferBlockNum = _firstTransferBlockOf[from];
        uint256 blocksSinceFirstTransfer = firstTransferBlockNum > 0 ? block.number - firstTransferBlockNum : 0;

        if (blocksSinceFirstTransfer == 0)
        {
            return _feeOnSellSameBlock;
        }

        if (blocksSinceFirstTransfer < _blocksPerMinute * 10)
        {
            return _feeOnSellQuickTrade;
        }

        if (blocksSinceFirstTransfer < _blocksPerDay)
        {
            return _feeOnSellIntraDay;
        }

        return _feeOnSellInterDay;
    }

    function setTaxes() private {
        if (_taxFee == 0) return;

        _previousTaxFee = _taxFee;
        _taxFee = 0;
    }

    function restoreTaxFee() private {
        _taxFee = _previousTaxFee;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if (from != owner() && to != owner()) {
            require(_tradingOpen, "TOKEN: Cannot transfer tokens before trading is enabled");

            if (to != uniswapV2Pair) {
                require(balanceOf(to) + amount < _maxWalletSize, "TOKEN: Balance exceeds wallet size!");
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            bool canSwap = contractTokenBalance >= _minTokensForSwap;

            if (contractTokenBalance >= _maxTokensForSwap)
            {
                contractTokenBalance = _maxTokensForSwap;
            }

            if (canSwap && !_swapLock && from != uniswapV2Pair && !_isExcludedFromFee[from] && !_isExcludedFromFee[to]) {
                swapTokensForETH(contractTokenBalance);
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0) {
                    transferETH(address(this).balance);
                }
            }
        }

        bool takeFee = true;

        if ((_isExcludedFromFee[from] || _isExcludedFromFee[to]) || (from != uniswapV2Pair && to != uniswapV2Pair)) {
            takeFee = false;
        } else {
            if (from == uniswapV2Pair && to != address(uniswapV2Router)) {
                _taxFee = getBuyTaxFee();
            }

            if (to == uniswapV2Pair && from != address(uniswapV2Router)) {
                _taxFee = getSellTaxFeeFor(from);
            }
        }

        _tokenTransfer(from, to, amount, takeFee);
    }

    function swapTokensForETH(uint256 tokenAmount) private lockSwap {
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

    function transferETH(uint256 amount) private {
        _marketingWallet.transfer(amount);
    }

    function enableTrading(bool tradingOpen) public onlyOwner {
        _tradingOpen = tradingOpen;
        _tradeOpenedBlock = block.number;
    }

    function manualSwap() external {
        require(_msgSender() == _marketingWallet);
        uint256 tokenBalance = balanceOf(address(this));

        if (tokenBalance > _maxTokensForSwap)
        {
            tokenBalance = _maxTokensForSwap; 
        }

        require(tokenBalance > 0);
        swapTokensForETH(tokenBalance);
        transferETH(tokenBalance);
    }

    function manualSend() external {
        require(_msgSender() == _marketingWallet);
        uint256 contractETHBalance = address(this).balance;
        transferETH(contractETHBalance);
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount,
        bool takeFee
    ) private {
        if (!takeFee) setTaxes();
        _transferStandard(sender, recipient, amount);
        if (!takeFee) restoreTaxFee();
    }

    function _transferStandard(
        address from,
        address to,
        uint256 amount
    ) private {
        require(balanceOf(from) >= amount, "Error: transfer amount exceeds balance");
        uint256 amountFee = amount * _taxFee / 100;
        uint256 amountPostFee = amount - amountFee;

        _balanceOf[from] -= amount;
        _balanceOf[to] += amountPostFee;
        _balanceOf[address(this)] += amountFee;

        if (_firstTransferBlockOf[to] == 0)
        {
            _firstTransferBlockOf[to] = block.number;
        }

        emit Transfer(from, to, amount);
    }

    receive() external payable {}
}