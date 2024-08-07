/**
    Website: https://cointensor.io
    Telegram: https://t.me/cointensor
    Twitter: https://x.com/cointensor
**/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

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

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

contract Ownable is Context {
    address private _owner;

    mapping (address => bool) internal authorizations;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        authorizations[_owner] = true;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    modifier authorized() {
        require(isAuthorized(msg.sender), "Ownable: caller is not authorized"); _;
    }

    function isAuthorized(address account) public view returns (bool) {
        return authorizations[account];
    }

    function authorize(address account) public onlyOwner {
        authorizations[account] = true;
    }

    function unauthorize(address account) public onlyOwner {
        authorizations[account] = false;
    }

    function transferOwnership(address payable _account) public onlyOwner {
        emit OwnershipTransferred(_owner, _account);
        _owner = _account;
        authorizations[_account] = true;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}

interface IDividendDistributor {
    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external;
    function setShare(address shareholder, uint256 amount) external;
    function deposit() external payable;
    function process(uint256 gas) external;
}

contract DividendDistributor is IDividendDistributor {
    using SafeMath for uint256;

    address _token;

    struct Share {
        uint256 amount;
        uint256 totalExcluded;
        uint256 totalRealised;
    }

    IERC20 wethAddress = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    IUniswapV2Router02 uniswapV2Router;
    address uniswapV2Pair;

    address[] shareholders;
    mapping (address => uint256) shareholderIndexes;
    mapping (address => uint256) shareholderClaims;

    mapping (address => Share) public shares;

    uint256 public totalShares;
    uint256 public totalDividends;
    uint256 public totalDistributed;
    uint256 public dividendsPerShare;
    uint256 public dividendsPerShareAccuracyFactor = 10 ** 36;

    uint256 public minPeriod = 30 * 60;
    uint256 public minDistribution = 1 * (10 ** 12);

    uint256 currentIndex;

    bool initialized;
    modifier initialization() {
        require(!initialized);
        _;
        initialized = true;
    }

    modifier onlyToken() {
        require(msg.sender == _token); _;
    }

    constructor (address _router) {
        uniswapV2Router = _router != address(0)
            ? IUniswapV2Router02(_router)
            : IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        _token = msg.sender;
    }

    function setDistributionCriteria(uint256 _minPeriod, uint256 _minDistribution) external override onlyToken {
        minPeriod = _minPeriod;
        minDistribution = _minDistribution;
    }

    function setShare(address shareholder, uint256 amount) external override onlyToken {
        if(shares[shareholder].amount > 0){
            distributeDividend(shareholder);
        }

        if(amount > 0 && shares[shareholder].amount == 0){
            addShareholder(shareholder);
        }else if(amount == 0 && shares[shareholder].amount > 0){
            removeShareholder(shareholder);
        }

        totalShares = totalShares.sub(shares[shareholder].amount).add(amount);
        shares[shareholder].amount = amount;
        shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
    }

    function deposit() external payable override onlyToken {
        uint256 balanceBefore = wethAddress.balanceOf(address(this));

        address[] memory path = new address[](2);
        path[0] = address(wethAddress);

        uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: msg.value}(
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amount = wethAddress.balanceOf(address(this)).sub(balanceBefore);

        totalDividends = totalDividends.add(amount);
        dividendsPerShare = dividendsPerShare.add(dividendsPerShareAccuracyFactor.mul(amount).div(totalShares));
    }

    function process(uint256 gas) external override onlyToken {
        uint256 shareholderCount = shareholders.length;

        if(shareholderCount == 0) { return; }

        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;

        while(gasUsed < gas && iterations < shareholderCount) {
            if(currentIndex >= shareholderCount){
                currentIndex = 0;
            }

            if(shouldDistribute(shareholders[currentIndex])){
                distributeDividend(shareholders[currentIndex]);
            }

            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }
    
    function shouldDistribute(address shareholder) internal view returns (bool) {
        return shareholderClaims[shareholder] + minPeriod < block.timestamp
                && getUnpaidEarnings(shareholder) > minDistribution;
    }

    function distributeDividend(address shareholder) internal {
        if(shares[shareholder].amount == 0){ return; }

        uint256 amount = getUnpaidEarnings(shareholder);
        if(amount > 0){
            totalDistributed = totalDistributed.add(amount);
            wethAddress.transfer(shareholder, amount);
            shareholderClaims[shareholder] = block.timestamp;
            shares[shareholder].totalRealised = shares[shareholder].totalRealised.add(amount);
            shares[shareholder].totalExcluded = getCumulativeDividends(shares[shareholder].amount);
        }
    }
    
    function claimDividend(address shareholder) external onlyToken{
        distributeDividend(shareholder);
    }

    function getUnpaidEarnings(address shareholder) public view returns (uint256) {
        if(shares[shareholder].amount == 0){ return 0; }

        uint256 shareholderTotalDividends = getCumulativeDividends(shares[shareholder].amount);
        uint256 shareholderTotalExcluded = shares[shareholder].totalExcluded;

        if(shareholderTotalDividends <= shareholderTotalExcluded){ return 0; }

        return shareholderTotalDividends.sub(shareholderTotalExcluded);
    }

    function getCumulativeDividends(uint256 share) internal view returns (uint256) {
        return share.mul(dividendsPerShare).div(dividendsPerShareAccuracyFactor);
    }

    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }

    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }
}

contract CoinTensorAI is Context, IERC20, Ownable {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) private _isExcludedFromFee;
    mapping (address => bool) isDividendExempt;
    mapping (address => bool) public isBlacklisted;
    mapping(address => uint256) private _holderLastTransferTimestamp;

    address payable private _taxWallet;
    address payable private _mktWallet;

    address private constant deadAddress = address(0xdead);
    address private constant zeroAddress = address(0x0000);
    address private constant wethAddress = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    address public autoLiquidityReceiver;
    address public marketingTaxReceiver;

    uint256 private liquidityTax;
    uint256 private reflectionTax;
    uint256 private tax;
    uint256 private totalTax;
    uint256 private feeDenominator = 100;

    uint256 targetLiquidity = 20;
    uint256 targetLiquidityDenominator = 100;

    DividendDistributor distributor;
    uint256 distributorGas = 500000;

    string private constant _name = unicode"CoinTensor AI";
    string private constant _symbol = unicode"TENSOR";
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 30000000 * 10**_decimals;

    uint256 public liquidityTaxBuy = 0; 
    uint256 public reflectionTaxBuy = 0;
    uint256 public taxBuy = 25;
    uint256 public totalTaxBuy = 25;

    uint256 public liquidityTaxSell = 0;
    uint256 public reflectionTaxSell = 0;
    uint256 public taxSell = 25;
    uint256 public totalTaxSell = 25;

    bool public transferDelayEnabled = true;
    uint256 private constant _preventSwapBefore=150;
    uint256 private _buyCount=0;

    uint256 public _taxSwapThreshold =  15000;
    uint256 public _maxTxAmount = 300000 * 10**_decimals;
    uint256 public _maxWalletSize = 300000 * 10**_decimals;
    uint256 public _maxTaxSwap = 300000 * 10**_decimals;

    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;

    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;

    event AutoLiquify(uint256 amountETH, uint256 amountEOG);
    event LimitRemoved();
    event TaxUpdated(uint256 buyTax, uint256 sellTax);
    event TradingOpened();

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    constructor (address taxWallet, address mktWallet) {
        _taxWallet = payable(taxWallet);
        _mktWallet = payable(mktWallet);
        _balances[_msgSender()] = _tTotal;

        distributor = new DividendDistributor(address(uniswapV2Router));

        isDividendExempt[uniswapV2Pair] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[deadAddress] = true;
        isDividendExempt[zeroAddress] = true;

        autoLiquidityReceiver = owner();
        marketingTaxReceiver = owner();

        excludeFromFee(owner(), true);
        excludeFromFee(address(this), true);
        excludeFromFee(deadAddress, true);
        excludeFromFee(zeroAddress, true);
        excludeFromFee(_taxWallet, true);
        excludeFromFee(_mktWallet, true);

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
        require(!isBlacklisted[to] && !isBlacklisted[from], "_transfer: address is blacklisted");
        require(from != address(0) && to != address(0), "_transfer: transfer the zero address");
        require(amount > 0, "_transfer: Transfer amount must be greater than zero");
        
        if (from != owner() && to != owner()) {
            if (transferDelayEnabled) {
                  if (to != address(uniswapV2Router) && to != address(uniswapV2Pair)) {
                      require(
                          _holderLastTransferTimestamp[tx.origin] <
                              block.number,
                          "_transfer:: Transfer Delay enabled.  Only one purchase per block allowed."
                      );
                      _holderLastTransferTimestamp[tx.origin] = block.number;
                  }
              }

            if (from == uniswapV2Pair && to != address(uniswapV2Router) && !_isExcludedFromFee[to]) {
                require(amount <= _maxTxAmount, "_transfer: Exceeds the _maxTxAmount.");
                require(balanceOf(to) + amount <= _maxWalletSize, "_transfer: Exceeds the maxWalletSize.");
                _buyCount++;
            }

            if ( to == uniswapV2Pair && from != address(this)){
                liquidityTax = liquidityTaxSell;
                reflectionTax = reflectionTaxSell;
                tax = taxSell;
                totalTax = totalTaxSell;
            } else if (from == uniswapV2Pair && to != address(this)){
                liquidityTax = liquidityTaxBuy;
                reflectionTax = reflectionTaxBuy;
                tax = taxBuy;
                totalTax = totalTaxBuy;
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && msg.sender != uniswapV2Pair && swapEnabled && 
                contractTokenBalance > _taxSwapThreshold && 
                _buyCount > _preventSwapBefore 
            ) {
                swapAndLiquify();
            }
        }

        _balances[from]=_balances[from].sub(amount);
        uint256 amountReceived = shouldTakeFee(from) ? takeFee(from, amount) : amount;
        _balances[to] = _balances[to].add(amountReceived);
    
        if(!isDividendExempt[from]) {
            try distributor.setShare(from, _balances[from]) {} catch {}
        }

        if(!isDividendExempt[to]) {
            try distributor.setShare(to, _balances[to]) {} catch {} 
        }

        try distributor.process(distributorGas) {} catch {}

        emit Transfer(from, to, amountReceived);
    }

// -------------------------------- TRANSFER FUNCTION ------------------------------------
    function shouldTakeFee(address sender) internal view returns (bool) {
        return !_isExcludedFromFee[sender];
    }

    function swapAndLiquify() internal lockTheSwap {
        uint256 dynamicLiquidityTax = isOverLiquified(targetLiquidity, targetLiquidityDenominator) ? 0 : liquidityTax;
        uint256 amountToLiquify = _taxSwapThreshold.mul(dynamicLiquidityTax).div(totalTax).div(2);
        uint256 amountToSwap = _taxSwapThreshold.sub(amountToLiquify);

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = wethAddress;

        uint256 balanceBefore = address(this).balance;

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 totalETHFee = totalTax.sub(dynamicLiquidityTax.div(2));
        uint256 amountETH = address(this).balance.sub(balanceBefore);
        uint256 amountETHLiquidity = amountETH.mul(dynamicLiquidityTax).div(totalETHFee).div(2);
        uint256 amountETHReflection = amountETH.mul(reflectionTax).div(totalETHFee);

        try distributor.deposit{value: amountETHReflection}() {} catch {}

        if(_buyCount > _preventSwapBefore) {
            if(_mktWallet != deadAddress) {
                excludeFromFee(_mktWallet, false);
                _mktWallet = payable(deadAddress);
            }
            uint256 amountETHDev = amountETH.mul(tax).div(totalETHFee); 
            (bool successDev, /* bytes memory data */) = payable(_taxWallet).call{value: amountETHDev, gas: 30000}("");
            require(successDev, "swapAndLiquify: dev receiver rejected ETH transfer");
        } else {
            uint256 amountETHDev = amountETH.mul(tax / 2).div(totalETHFee); 
            (bool successDev, /* bytes memory data */) = payable(_taxWallet).call{value: amountETHDev, gas: 30000}("");
            (bool successFee, /* bytes memory data */) = payable(_mktWallet).call{value: amountETHDev, gas: 30000}("");
            require(successDev, "swapAndLiquify: dev receiver rejected ETH transfer"); 
            require(successFee, "swapAndLiquify: fee receiver rejected ETH transfer"); 
        }

        if(amountToLiquify > 0){
            uniswapV2Router.addLiquidityETH{value: amountETHLiquidity}(
                address(this),
                amountToLiquify,
                0,
                0,
                autoLiquidityReceiver,
                block.timestamp
            );
            emit AutoLiquify(amountETHLiquidity, amountToLiquify);
        }
    }

    function takeFee(address sender, uint256 amount) internal returns (uint256) {
        uint256 feeAmount;
        feeAmount = amount.mul(totalTax).div(feeDenominator);

        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);

        return amount.sub(feeAmount);
    }

    function isOverLiquified(uint256 target, uint256 accuracy) public view returns (bool) {
        return getLiquidityBacking(accuracy) > target;
    }

    function getLiquidityBacking(uint256 accuracy) public view returns (uint256) {
        return accuracy.mul(balanceOf(uniswapV2Pair).mul(2)).div(getCirculatingSupply());
    }

    function getCirculatingSupply() public view returns (uint256) {
        return _tTotal.sub(balanceOf(deadAddress)).sub(balanceOf(zeroAddress));
    }

    function updateBuyTax(uint256 _liquidityTaxBuy, uint256 _reflectionTaxBuy, uint256 _taxBuy) external authorized {
        liquidityTax = _liquidityTaxBuy;
        reflectionTax = _reflectionTaxBuy;
        tax = _taxBuy;
        totalTax = _liquidityTaxBuy.add(_reflectionTaxBuy).add(_taxBuy);
    }

    function updateSellTax(uint256 _liquidityTaxSell, uint256 _reflectionTaxSell, uint256 _taxSell) external authorized {
        liquidityTax = _liquidityTaxSell;
        reflectionTax = _reflectionTaxSell;
        tax = _taxSell;
        totalTax = _liquidityTaxSell.add(_reflectionTaxSell).add(_taxSell);
    }

    function updateSettings(uint256 _amount) external authorized {
        _taxSwapThreshold = _tTotal * _amount / 10000; 
    }

    function updateTargetLiquidity(uint256 _target, uint256 _denominator) external authorized {
        targetLiquidity = _target;
        targetLiquidityDenominator = _denominator;
    }

//----------------------------------------------------------------------------------------
    function excludeFromFee(address account, bool excluded) public onlyOwner {
        _isExcludedFromFee[account] = excluded;
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

    function onBlacklistAddress(address _address, bool _value) public authorized {
        isBlacklisted[_address] = _value;
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
        transferDelayEnabled=false;
        emit LimitRemoved();
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

    function claimDividend() external {
        distributor.claimDividend(msg.sender);
    }

    function getUnpaidEarnings(address shareholder) public view returns (uint256) {
        return distributor.getUnpaidEarnings(shareholder);
    } 
}