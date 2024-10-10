//SPDX-License-Identifier: MIT
pragma solidity 0.8.23;
/**
 * @title Atron - Liquidity Diversification Protocol
 * @dev Contract implements an upgradeable tokenomics framework for fee delegation and contract interfacing. Modularity without proxy.
 */
abstract contract Auth {
    address internal owner;
    mapping (address => bool) internal authorizations;

    // Track authorized addresses
    address[] internal authorizedAddresses;

    constructor(address _owner) {
        owner = _owner;
        _authorize(_owner);
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER");
        _;
    }

    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED");
        _;
    }

    function authorize(address adr) external onlyOwner {
        _authorize(adr);
    }

    function _authorize(address adr) internal {
        if (!authorizations[adr]) {
            authorizations[adr] = true;
            authorizedAddresses.push(adr); // Add to tracking
        }
    }

    function unauthorize(address adr) public onlyOwner {
        if (authorizations[adr]) {
            authorizations[adr] = false;
            // Remove from tracking
            for (uint i = 0; i < authorizedAddresses.length; i++) {
                if (authorizedAddresses[i] == adr) {
                    authorizedAddresses[i] = authorizedAddresses[authorizedAddresses.length - 1];
                    authorizedAddresses.pop();
                    break;
                }
            }
        }
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    function transferOwnership(address payable adr) public onlyOwner {
        // Reset authorizations
        for (uint i = 0; i < authorizedAddresses.length; i++) {
            authorizations[authorizedAddresses[i]] = false;
        }
        // Clear the authorized addresses
        delete authorizedAddresses;

        // Transfer ownership and re-authorize the new owner
        owner = adr;
        _authorize(adr);

        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}
interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function getOwner() external view returns (address);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
interface IDEXRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

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


    function swapExactTokensForETH(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);

}
interface IDEXFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IDexPair {
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function sync() external;
}
library AtronLibrary {
    enum TransferType {
        Sell,
        Buy,
        Transfer
    }
    struct Transfer {
        uint256 amt;
        TransferType transferType;
        address from;
        address to;
    }
}

interface IDistributor {
    function deposit() external payable;
    function onTransfer(AtronLibrary.Transfer memory _transfer) external;
    function setShares(address sender, uint senderBalance, bool isSenderExempt, address recipient, uint recipientBalance, bool isRecipientExempt) external;
    function resetShares(address shareholder) external;
    function process(uint256 gas) external;
}

interface IFeeRouter {
    function deposit() external payable;
    function onTransfer(AtronLibrary.Transfer memory _transfer) external;
    function setShares(address sender, uint senderBalance, bool isSenderExempt, address recipient, uint recipientBalance, bool isRecipientExempt) external;
    function resetShares(address shareholder) external;
}

interface IFeeOracle {
    function getDiscount(address holder, IERC20 token) external view returns (uint256, uint256);
    function getTaxFee(AtronLibrary.TransferType _transferType) external view returns (uint256);
}

contract ATRON is IERC20, Auth {

    struct Exemptions {
        bool isFeeExempt; //Only exempts transfers from sender & sells from sender. To Exempt buys, set the address as an interface.
        bool isTxLimitExempt;
        bool isDividendExempt;
        bool isFeeOracleExempt;
    }

    struct TokenFees {
        uint256 sell;
        uint256 transfer;
        uint256 buy;
        uint256 burn; //Always divided by the fee.sell to calculate result
    }

    struct LiquidityPairs {
        bool isLiquidityPair;
        IERC20 token;
    }

    // Fees
    TokenFees public fee = TokenFees(400,400,400,0);   

    address constant DEAD = 0x000000000000000000000000000000000000dEaD; 

    //Maintains tokens to burn seperately during swapback
    uint256 public burnReserve; //keeps track of tokens meant to be burned
    uint256 public burnThreshold = 1 * 1e16; //burn tokens at 0.01 Atron
    
    //SwapBack Settings
    IDEXRouter  public router; 
    address     public pair;
    uint256 public swapThreshold = 100000 * 1e18;  //100000 Atron

    //Token Pair Data
    mapping(address => LiquidityPairs) public liquidityPairs;
    
    //Atron Token Info
    string  private _name          = "ATRON";
    string  private _symbol        = "ATRON";
    uint8   constant _decimals    = 18;
    uint256 public   _totalSupply  = 1000000000 * 10**18;
    uint256 public   _maxTxAmount = 1000000000 * 10**18;
    
    //Shareholder Standard Mappings
    mapping(address => uint256)                            _balances;
    mapping(address => mapping(address => uint256))        _allowances;

    //Shareholder Atron Mappings
    mapping(address => Exemptions)                  public exemptions; //Manages exclusions with external Atron contracts
    mapping(address => bool)                        public interfaces; //Manages Interfacing contracts/merchants allowing contracts to make basic transfer. Custom fees only applicable to merchant/non-interface addresses

    //Atron Interfaces
    IFeeRouter public  feeRouter;
    IFeeOracle             public  feeOracle;

    //Slippage
    uint private slippage = 100; // 100 = 1%

    //Other 
    uint256 public  tokensBurned; //Counter for tokens burned within the Atron EcoSystem

    //Determines if the contract executed a swap. Used to prevent circulation issues.
    bool inSwap;
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    event ErrorEvent(string reason);
    event SetFeeExempt(address _addr, bool _exempt);
    event SetFeeOracle(IFeeOracle _feeOracle);
    event SetFeeRouter(IFeeRouter _feeRouter);
    event SetTxLimitExempt(address _addr, bool _exempt);
    event SetDexRouter(IDEXRouter _router);
    event SetNewFees(uint256 _sellFee, uint256 _transferFee, uint256 _buyFee, uint256 _burnFee);
    event SetInterface(address _interfaceAddr, bool _isInterface);
    event SetAtronExclusions(address _addr, bool _isDividendExempt, bool _isFeeOracleExempt);
    event SetSwapThreshold(uint256 _swapThreshold);
    event SetBurnThreshold(uint256 _burnThreshold);
    event SetTxLimit(uint256 _amount);
    event SetPair(address _pair);
    event SetLiquidityPair(address _pair, IERC20 token, bool _value);
    event TokensBurned(address sender, uint256 amountBurned);
    event BurnReserveUpdated(uint256 burnReserve);
    event SetSlippage(uint slippage);

    constructor(IDEXRouter _router) Auth(msg.sender) {

        router  = _router;
        pair    = IDEXFactory(router.factory()).createPair(router.WETH(), address(this));
        liquidityPairs[pair].isLiquidityPair = true;
        liquidityPairs[pair].token = IERC20(router.WETH());

        exemptions[msg.sender].isFeeExempt     = true;
        exemptions[msg.sender].isTxLimitExempt = true;
        interfaces[msg.sender] = true;
        exemptions[address(_router)].isTxLimitExempt = true;
        exemptions[pair].isTxLimitExempt = true;
        exemptions[DEAD].isDividendExempt = true;

        _allowances[address(this)][address(router)] = _totalSupply;
        approve(address(_router), _totalSupply);
        approve(address(pair), _totalSupply);

        _balances[msg.sender] = _totalSupply;
        
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function _internalApprove(address spender, uint256 amount) internal returns (bool) {
        _allowances[msg.sender][spender] = amount;
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        if (_allowances[sender][msg.sender] != _totalSupply) {
            _allowances[sender][msg.sender] -= amount;
        }
        return _transferFrom(sender, recipient, amount);
    }

    function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool) {
        if (inSwap || interfaces[sender] || interfaces[recipient])
            return _basicTransfer(sender, recipient, amount);

        require(amount <= _maxTxAmount || exemptions[sender].isTxLimitExempt, "TX Limit Exceeded");

        AtronLibrary.TransferType transferType = _determineTransferType(sender, recipient);

        if (_shouldSwapBack() && transferType != AtronLibrary.TransferType.Transfer)
            _swapBack();
        else if(burnReserve >= burnThreshold)
            _burnFromReserve();        
        
        uint amountAfterFee = _getDiscountAndTakeFee(sender, recipient, amount, transferType);

        _setShares(sender, recipient);

        if (address(feeRouter) != address(0)) {
            AtronLibrary.Transfer memory transf = _buildTransfer(amountAfterFee, transferType, sender, recipient); //creates a transfer struct for sending to the fee router gateway
            try feeRouter.onTransfer(transf) {
            } catch Error(string memory reason) {
                emit ErrorEvent("_transferFrom(): feeRouter.onTransfer() Failed");
                emit ErrorEvent(reason);
            }
        }

        emit Transfer(sender, recipient, amountAfterFee);
        return true;
    }

    function _getDiscountAndTakeFee(address sender, address recipient, uint256 amount, AtronLibrary.TransferType transferType) internal returns (uint256) {
        //Grab holder discount information from the FeeOracle
        uint256 buyDiscount;
        uint256 sellDiscount; 
        if (address(feeOracle) != address(0)) {
            if(transferType == AtronLibrary.TransferType.Sell && !exemptions[sender].isFeeOracleExempt) 
                (buyDiscount, sellDiscount) = getDiscount(sender, liquidityPairs[recipient].token);
            if(transferType == AtronLibrary.TransferType.Buy && !exemptions[recipient].isFeeOracleExempt)
                (buyDiscount, sellDiscount) = getDiscount(recipient, liquidityPairs[sender].token);
        }

        //Calculates and takes applicable fees;
        uint amountAfterFee = exemptions[sender].isFeeExempt ? amount : _takeFee(sender, amount, transferType, buyDiscount, sellDiscount);
        _balances[sender] -= amount;
        _balances[recipient] += amountAfterFee;
        return amountAfterFee;
    }

    //execute any time shareholder balances change
    function _setShares(address sender, address recipient) internal {
        if(address(feeRouter) == address(0)) return; // Check if feeRouter is set

        uint256 senderBalance = _balances[sender];
        uint256 recipientBalance = _balances[recipient];
        bool senderIsExempt = exemptions[sender].isDividendExempt;
        bool recipientIsExempt = exemptions[recipient].isDividendExempt;

        try feeRouter.setShares(
            sender,
            senderBalance,
            senderIsExempt,
            recipient,
            recipientBalance,
            recipientIsExempt
        ) {}
        catch Error(string memory reason) {
            emit ErrorEvent("_setShares(): feeRouter.setShares() Failed");
            emit ErrorEvent(reason);
        }
    }

    //determines if the transfer is a buy/sell/transfer
    function _determineTransferType(address _from, address _recipient) internal view returns (AtronLibrary.TransferType) {
        if (liquidityPairs[_recipient].isLiquidityPair) {
            return AtronLibrary.TransferType.Sell;
        } else if (liquidityPairs[_from].isLiquidityPair) {
            return AtronLibrary.TransferType.Buy;
        }
        return AtronLibrary.TransferType.Transfer;
    }

    //creates the transfer type
    function _buildTransfer(uint256 _amt, AtronLibrary.TransferType _transferType, address _from, address _to) internal pure returns (AtronLibrary.Transfer memory) {
        AtronLibrary.Transfer memory _transfer = AtronLibrary.Transfer(_amt, _transferType, _from, _to);
        return _transfer;
    }

    //handles interface/swap transfers without any other mechanisms. 
    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        if(!inSwap) _setShares(sender, recipient); //ensures holder's shares are updated in the pool distribution gateway,  dex pairs/contracts are exempt at pool distribution gateway. 
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function _takeFee(address _sender, uint256 _amount, AtronLibrary.TransferType _transferType, uint256 _buyDiscount, uint256 _sellDiscount) internal returns (uint256) {
        uint256 feeAmount = (_amount * getTotalFee(_transferType, _buyDiscount, _sellDiscount)) / 10000;

        if (feeAmount > 0)
        {
            burnReserve += (feeAmount * fee.burn) / fee.sell;
            _balances[address(this)] += feeAmount;
            emit BurnReserveUpdated(burnReserve);
            emit Transfer(_sender, address(this), feeAmount);
        }

        return (_amount - feeAmount);
    }

    function _shouldSwapBack() internal view returns (bool) {
        return ((msg.sender != pair) && (!inSwap) && (_balances[address(this)] - burnReserve >= swapThreshold));
    }

    function _swapBack() internal swapping {
        uint256 amountToSwap = swapThreshold;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();

        uint[] memory amountsOutMin = router.getAmountsOut(amountToSwap, path);
        uint amountOutMin = amountsOutMin[amountsOutMin.length - 1] * (10000 - slippage) / 10000;

        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            amountOutMin,
            path,
            address(this),
            block.timestamp
        );

        if(address(feeRouter) != address(0)) {
            try feeRouter.deposit{value : address(this).balance}() {

            } catch Error(string memory reason) {
                emit ErrorEvent("_swapBack(): feeRouter.deposit() Failed");
                emit ErrorEvent(reason);
            }
        }
    }

    function _burnFromReserve() internal {
        address _thisContract = address(this);
        uint256 _burnReserve = burnReserve;
        uint256 _new_supply = _totalSupply - _burnReserve;
        _totalSupply = _new_supply;
        _balances[_thisContract] = _balances[_thisContract] - _burnReserve;
        tokensBurned += _burnReserve;
        burnReserve = 0;
        _allowances[_thisContract][address(router)] = _new_supply;
        _allowances[_thisContract][address(pair)] = _new_supply;
        emit Transfer(_thisContract, address(0), _burnReserve);
        emit TokensBurned(_thisContract, _burnReserve);
    }

    function _burnFromHolder(uint256 amountToBurn) internal {
        uint256 _holderBalance = _balances[msg.sender];
        require(_holderBalance >= amountToBurn && amountToBurn > 0, 'does not hodl enough');

        uint256 _total_supply = _totalSupply; //gas savings

        _totalSupply = _total_supply - amountToBurn;
        _balances[msg.sender] -= amountToBurn;
        tokensBurned += amountToBurn;
       
        _setShares(msg.sender, DEAD); //Update shares in gateway. Dead wallet is exempt inside feeRouter

        _internalApprove(address(router), _total_supply);
        _internalApprove(address(pair), _total_supply);
        emit Transfer(msg.sender, address(0), amountToBurn);
        emit TokensBurned(msg.sender, amountToBurn);
    }    

    function _takeExternalFee(uint256 feeAmount) internal returns (bool) {
        // Takes the fee and keeps remainder in contract 
        if (feeAmount > 0) {
            //update balance for tokens to be burned in batches to save gas on burn function execution
            burnReserve += (feeAmount * fee.burn) / fee.sell;

            _balances[address(this)] += feeAmount;
            emit Transfer(msg.sender, address(this), feeAmount);
            return true;
        }
        return false;
    }

    function _exemptFromDividends(address _address, bool _exempt) internal {
        if(address(feeRouter)!=address(0)) {
            if(_exempt)
                feeRouter.resetShares(_address);
            else
                feeRouter.setShares(_address, _balances[_address], true, _address, _balances[_address], _exempt);
        }
    }

    // public getters
    function getCirculatingSupply() public view returns (uint256) {
        return (_totalSupply - balanceOf(DEAD) - balanceOf(address(0)));
    }
    
    function getLiquidityBacking(uint256 _accuracy) public view returns (uint256) {
        return (_accuracy * balanceOf(pair) * 2) / getCirculatingSupply(); //reserved for external use later
    }

    function isOverLiquified(uint256 _target, uint256 _accuracy) public view returns (bool) {
        return (getLiquidityBacking(_accuracy) > _target);
    }

    //grabs total fee based on transfer type
    function getTotalFee(AtronLibrary.TransferType _transferType, uint256 _buyDiscount, uint256 _sellDiscount) public view returns (uint256) {
        uint256 _feeTax;
        bool _feeOracleExists = address(feeOracle) != address(0); //if feeOracle exists - grab the calculated buy/transfer/sell tax;
        if (_transferType == AtronLibrary.TransferType.Sell) {
            _feeTax = _feeOracleExists ? feeOracle.getTaxFee(_transferType): fee.sell;
            uint256 _sellFee = _sellDiscount > 0 ? _feeTax - ((_feeTax * _sellDiscount) / 10000) : _feeTax;
            return _sellFee;
        }
        if (_transferType == AtronLibrary.TransferType.Transfer) {
            return  _feeOracleExists ? feeOracle.getTaxFee(_transferType): fee.transfer;
        }
        else {
            _feeTax = _feeOracleExists ? feeOracle.getTaxFee(_transferType): fee.buy;
            uint256 _buyFee = _buyDiscount > 0 ? _feeTax - ((_feeTax * _buyDiscount) / 10000) : _feeTax;
            return _buyFee;
        }
    }

    //grabs holder discount if applicable from ticket booth/Referrals contract
    function getDiscount(address _addr, IERC20 _token) public returns (uint256 buyDiscount, uint256 sellDiscount) {
        try feeOracle.getDiscount(_addr, _token) returns (uint256 _buyDiscount, uint256 _sellDiscount){
            buyDiscount = _buyDiscount;
            sellDiscount = _sellDiscount;

        } catch Error (string memory reason){
            emit ErrorEvent('getDiscount(): feeOracle.getDiscount() Failed');
            emit ErrorEvent(reason);
        }
    }

    //grabs tax fee based on transfer type
    function getTaxFee(AtronLibrary.TransferType _transferType) public returns (uint256 taxFee) {
        try feeOracle.getTaxFee(_transferType) returns (uint256 _taxFee){
            taxFee = _taxFee;

        } catch Error (string memory reason){
            emit ErrorEvent('getDiscount(): feeOracle.getTaxFee() Failed');
            emit ErrorEvent(reason);
        }
    }

    // authorized setters

    //sets new fees for the contract
    function setNewFees(uint256 _sellFee, uint256 _transferFee, uint256 _buyFee, uint256 _burnFee) external authorized {
        require(_sellFee <= 2000
        && _transferFee <= 2000
        && _buyFee <= 2000
        && _burnFee <= _sellFee, "Invalid Fees");
        
        fee = TokenFees(_sellFee, _transferFee, _buyFee, _burnFee);

        if(_burnFee == 0)
            burnReserve = 0; //reset existing burn reserve if burn fee is set to 0
        emit SetNewFees( _sellFee,  _transferFee, _buyFee, _burnFee);
    }

    //validates and sets the router & pair
    function setDexRouter(IDEXRouter _router) external authorized {
        address _pair = IDEXFactory(_router.factory()).getPair(_router.WETH(), address(this));
        require(_pair != address(0), 'Invalid Router');

        router = _router;
        pair = _pair;

        _allowances[address(this)][address(_router)] = _totalSupply; 
        liquidityPairs[pair].isLiquidityPair = true;
        liquidityPairs[pair].token = IERC20(router.WETH());
        
        _exemptFromDividends(_pair,true);
        _exemptFromDividends(address(_router),true);

        emit SetDexRouter(_router);
        emit SetPair(_pair);
        emit SetLiquidityPair(_pair, IERC20(router.WETH()), true);
    }

    //sets the transaction limit for the contract never to be less than 1% of the total supply
    function setTxLimit(uint256 _amount) external authorized {
        require(_amount >= _totalSupply/100 && _amount <= _totalSupply, "Invalid Transaction Limit");
        _maxTxAmount = _amount;
        emit SetTxLimit(_amount);
    }

    function setIsFeeExempt(address _addr, bool _exempt) external authorized {
        exemptions[_addr].isFeeExempt = _exempt;
        emit SetFeeExempt(_addr, _exempt);
    }

    function setIsTxLimitExempt(address _addr, bool _exempt) external authorized {
        exemptions[_addr].isTxLimitExempt = _exempt;
        emit SetTxLimitExempt(_addr, _exempt);
    }

    //sets pair as liquidity pair to take fees
    function setLiquidityPair(address _pair, IERC20 token, bool _value) external authorized {
        liquidityPairs[_pair].isLiquidityPair = _value;
        liquidityPairs[_pair].token = token;
        exemptions[_pair].isDividendExempt = _value;
        _exemptFromDividends(_pair, _value);
        emit SetLiquidityPair(_pair,token,_value);
    }
    //threshold of Atron to collect before burning from supply
    function setBurnThreshold(uint256 _burnThreshold) external authorized {
        require(_burnThreshold <= _totalSupply, "Invalid Burn Threshold");
        burnThreshold = _burnThreshold;
        emit SetBurnThreshold(_burnThreshold);
    }
    //threshold to determine how much Atron needs to be in the contract to liquidate for rewards
    function setSwapThreshold(uint256 _swapThreshold) external authorized {
        require(_swapThreshold <= balanceOf(pair)/10, "Invalid Swap Threshold"); //Max 10% of the pair balance
        swapThreshold = _swapThreshold;
        emit SetSwapThreshold(_swapThreshold);
    }
    //exempts address from external ecosystem contracts as needed
    function setAtronExclusions(address _addr, bool _isDividendExempt, bool _isFeeOracleExempt) external authorized {
        exemptions[_addr].isDividendExempt = _isDividendExempt;
        _exemptFromDividends(_addr,_isDividendExempt);
        exemptions[_addr].isFeeOracleExempt = _isFeeOracleExempt;

        emit SetAtronExclusions( _addr, _isDividendExempt,  _isFeeOracleExempt);
    }
    //allows basic transfers of tokens without any of the hooks, with the exception of the pool distribution gateway only when present
    function setInterface(address _interfaceAddr, bool _isInterface) external authorized {
        interfaces[_interfaceAddr] = _isInterface;
        emit SetInterface(_interfaceAddr, _isInterface);
    }
    
    function setFeeRouter(IFeeRouter _feeRouter) external authorized {
        feeRouter = _feeRouter;
        if(address(_feeRouter)!=address(0))
            _exemptFromDividends(address(_feeRouter),true);
        emit SetFeeRouter(_feeRouter);
    }
    function setFeeOracle(IFeeOracle _feeOracle) external authorized {
        feeOracle = _feeOracle;
        if(address(_feeOracle)!=address(0) && address(feeRouter)!= address(0))
            _exemptFromDividends(address(_feeOracle),true);
        emit SetFeeOracle(_feeOracle);
    }
    function setSlippage(uint _slippage) external authorized {
        require(_slippage <= 2500, "Slippage must be less than or equal to 25%");
        slippage = _slippage;
        emit SetSlippage(slippage);
    }

    //Allows external contract/external source to contribute directly to contract fees with minimal gas
    function takeFee(uint256 feeAmount) external authorized returns (bool) {
        uint256 holderAmount = _balances[msg.sender];
        require(holderAmount >= feeAmount, 'does not hold enough');
        _balances[msg.sender] -= feeAmount;
        return _takeExternalFee(feeAmount);
    }
    //function to manually kick off swapback
    function manualSwapBack() external authorized {
        if(_shouldSwapBack())
            _swapBack();
    }
    
    //Burn Function
    function burnTokenOnly(uint256 tokenAmount) external {
        _burnFromHolder(tokenAmount);
    }

    function transferBNB(address payable _to) external authorized {
        (bool success,) = _to.call{value : address(this).balance}("");
        require(success, "unable to transfer value");
    }

    //Interface functions
    receive() external payable {}

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }
    function decimals() public pure returns (uint8) {
        return _decimals;
    }
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    function name() public view returns (string memory) {
        return _name;
    }
    function getOwner() public view override returns (address) {
        return owner;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
    function allowance(address holder, address spender) external view override returns (uint256) {
        return _allowances[holder][spender];
    }
    function approve(address spender, uint256 amount) public override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        return _transferFrom(msg.sender, recipient, amount);
    }
}