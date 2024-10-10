/**
ooooooooooooo ooooo   ooooo ooooooooo.   oooooooooooo oooooooooooo 
8'   888   `8 `888'   `888' `888   `Y88. `888'     `8 `888'     `8 
     888       888     888   888   .d88'  888          888         
     888       888ooooo888   888ooo88P'   888oooo8     888oooo8    
     888       888     888   888`88b.     888    "     888    "    
     888       888     888   888  `88b.   888       o  888       o 
    o888o     o888o   o888o o888o  o888o o888ooooood8 o888ooooood8 

    $THREE Protocol
Website: https://www.threeprotocol.ai/
Twitter: https://twitter.com/threeprotocol
Telegram: https://t.me/threeprotocol
Litepaper: https://three-3.gitbook.io/litepaper
Reddit: https://www.reddit.com/r/jobs3/
Linkedin: https://uk.linkedin.com/company/threeprotocol
Job3 Website: https://www.jobs3.io/

**/
// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}

interface IUniswapV2Router02 {
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

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

contract ThreeProtocol is IERC20, Ownable {
    // events
    event Reflect(uint256 amountReflected, uint256 newTotalProportion);

    // constants
    address constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address constant ZERO = 0x0000000000000000000000000000000000000000;

    uint256 constant MAX_FEE = 15;

    // states
    IUniswapV2Router02 public constant UNISWAP_V2_ROUTER =
        IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    address public UNISWAP_V2_PAIR;

    struct Fee {
        uint8 reflection;
        uint8 staking;
        uint8 lp;
        uint8 buyback;
        uint8 burn;
        uint128 total;
    }

    string _name = "Three Protocol";
    string _symbol = "THREE";

    uint256 _totalSupply = 100_000_000 ether;
    uint256 public _maxTxAmount = (_totalSupply * 5) / 1000; // 0.5%

    /* rOwned = ratio of tokens owned relative to circulating supply (NOT total supply, since circulating <= total) */
    mapping(address => uint256) public _rOwned;
    uint256 public _totalProportion = _totalSupply;

    mapping(address => mapping(address => uint256)) _allowances;

    bool public limitsEnabled = false;
    mapping(address => bool) isFeeExempt;
    mapping(address => bool) isTxLimitExempt;

    Fee public buyFee =
        Fee({
            reflection: 5,
            staking: 5,
            lp: 5,
            buyback: 10,
            burn: 0,
            total: 25
        });
    Fee public sellFee =
        Fee({
            reflection: 5,
            staking: 5,
            lp: 5,
            buyback: 10,
            burn: 0,
            total: 25
        });

    bool public launched = false;

    address private stakingFeeReceiver;
    address private lpFeeReceiver;
    address private buybackFeeReceiver;

    bool public claimingFees = false;
    uint256 public swapThreshold = (_totalSupply * 1) / 10000;
    bool inSwap;
    mapping(address => bool) public blacklists;

    // modifiers
    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    // constructor
    constructor() payable Ownable(_msgSender()) {
        stakingFeeReceiver = 0x9C5e298ea1a5CB002e949E9b44fD5d5Bac9644FB;
        lpFeeReceiver = 0xE474B677e7724ab1Ca8705530952F62a738809d4;
        buybackFeeReceiver = 0x56EDd5a745BD8942Ea31cf0Fa0517f3edf7Ff559;

        isTxLimitExempt[address(this)] = true;
        isTxLimitExempt[address(UNISWAP_V2_ROUTER)] = true;
        isTxLimitExempt[stakingFeeReceiver] = true;
        isTxLimitExempt[owner()] = true;
        isFeeExempt[address(this)] = true;
        isFeeExempt[stakingFeeReceiver] = true;
        isFeeExempt[owner()] = true;

        uint256 supplyForStaking = (_totalSupply * 10) / 100;
        uint256 supplyForLiquidity = (_totalSupply * 75) / 100;
        uint256 supplyForOwner = (_totalSupply * 15) / 100;
        _rOwned[stakingFeeReceiver] = supplyForStaking;
        _rOwned[address(this)] = supplyForLiquidity;
        _rOwned[owner()] = supplyForOwner;
        emit Transfer(address(0), stakingFeeReceiver, supplyForStaking);
        emit Transfer(address(0), address(this), supplyForLiquidity);
        emit Transfer(address(0), owner(), supplyForOwner);
    }

    receive() external payable {}

    // ERC20
    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function approveMax(address spender) external returns (bool) {
        return approve(spender, type(uint256).max);
    }

    function transfer(address recipient, uint256 amount)
        external
        override
        returns (bool)
    {
        return _transferFrom(msg.sender, recipient, amount);
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        if (_allowances[sender][msg.sender] != type(uint256).max) {
            require(
                _allowances[sender][msg.sender] >= amount,
                "ERC20: insufficient allowance"
            );
            _allowances[sender][msg.sender] =
                _allowances[sender][msg.sender] -
                amount;
        }

        return _transferFrom(sender, recipient, amount);
    }

    // views
    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function decimals() external pure returns (uint8) {
        return 18;
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return tokenFromReflection(_rOwned[account]);
    }

    function allowance(address holder, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowances[holder][spender];
    }

    function tokensToProportion(uint256 tokens) public view returns (uint256) {
        return (tokens * _totalProportion) / _totalSupply;
    }

    function tokenFromReflection(uint256 proportion)
        public
        view
        returns (uint256)
    {
        return (proportion * _totalSupply) / _totalProportion;
    }

    function getCirculatingSupply() public view returns (uint256) {
        return _totalSupply - balanceOf(DEAD) - balanceOf(ZERO);
    }

    // owners
    function unleashTheThreeProtocol(address _owner) external onlyOwner {
        require(!launched, "Already launched.");

        UNISWAP_V2_PAIR = IUniswapV2Factory(UNISWAP_V2_ROUTER.factory())
            .createPair(address(this), UNISWAP_V2_ROUTER.WETH());
        _allowances[address(this)][address(UNISWAP_V2_ROUTER)] = type(uint256)
            .max;
        _allowances[address(this)][address(UNISWAP_V2_PAIR)] = type(uint256)
            .max;
        _allowances[address(this)][_owner] = type(uint256).max;
        IERC20(UNISWAP_V2_PAIR).approve(
            address(UNISWAP_V2_ROUTER),
            type(uint256).max
        );

        UNISWAP_V2_ROUTER.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            _owner,
            block.timestamp
        );

        claimingFees = true;
        limitsEnabled = true;
        launched = true;
    }

    function clearStuckBalance() external onlyOwner {
        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(success);
    }

    function clearStuckToken() external onlyOwner {
        _transferFrom(address(this), msg.sender, balanceOf(address(this)));
    }

    function setSwapBackSettings(bool _enabled, uint256 _amount)
        external
        onlyOwner
    {
        claimingFees = _enabled;
        swapThreshold = _amount;
    }

    function changeFees(
        uint8 reflectionFeeBuy,
        uint8 stakingFeeBuy,
        uint8 lpFeeBuy,
        uint8 buybackFeeBuy,
        uint8 burnFeeBuy,
        uint8 reflectionFeeSell,
        uint8 stakingFeeSell,
        uint8 lpFeeSell,
        uint8 buybackFeeSell,
        uint8 burnFeeSell
    ) external onlyOwner {
        uint128 __totalBuyFee = reflectionFeeBuy +
            stakingFeeBuy +
            lpFeeBuy +
            buybackFeeBuy +
            burnFeeBuy;
        uint128 __totalSellFee = reflectionFeeSell +
            stakingFeeSell +
            lpFeeSell +
            buybackFeeSell +
            burnFeeSell;

        require(__totalBuyFee <= 100, "Buy fees must be less than or equal to 10%");
        require(__totalSellFee <= 100, "Sell fees must be less than or equal to 10%");

        buyFee = Fee({
            reflection: reflectionFeeBuy,
            staking: reflectionFeeBuy,
            lp: reflectionFeeBuy,
            buyback: reflectionFeeBuy,
            burn: burnFeeBuy,
            total: __totalBuyFee
        });

        sellFee = Fee({
            reflection: reflectionFeeSell,
            staking: reflectionFeeSell,
            lp: reflectionFeeSell,
            buyback: reflectionFeeSell,
            burn: burnFeeSell,
            total: __totalSellFee
        });
    }

    function setIsFeeExempt(address holder, bool exempt) external onlyOwner {
        isFeeExempt[holder] = exempt;
    }

    function setIsTxLimitExempt(address holder, bool exempt)
        external
        onlyOwner
    {
        isTxLimitExempt[holder] = exempt;
    }

    function setFeeReceivers(
        address m_,
        address lp_,
        address b_
    ) external onlyOwner {
        stakingFeeReceiver = m_;
        lpFeeReceiver = lp_;
        buybackFeeReceiver = b_;
    }

    function setMaxTxBasisPoint(uint256 p_) external onlyOwner {
        _maxTxAmount = (_totalSupply * p_) / 10000;
    }

    function setLimitsEnabled(bool e_) external onlyOwner {
        limitsEnabled = e_;
    }

    function blacklist(address _address, bool _isBlacklisting)
        external
        onlyOwner
    {
        blacklists[_address] = _isBlacklisting;
    }

    // private
    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        require(!blacklists[recipient] && !blacklists[sender], "Blacklisted");

        if (inSwap) {
            return _basicTransfer(sender, recipient, amount);
        }

        if (
            limitsEnabled &&
            !isTxLimitExempt[sender] &&
            !isTxLimitExempt[recipient]
        ) {
            require(
                amount <= _maxTxAmount,
                "Transfer amount exceeds the maxTxAmount."
            );
        }

        if (_shouldSwapBack()) {
            _swapBack();
        }

        uint256 proportionAmount = tokensToProportion(amount);
        require(_rOwned[sender] >= proportionAmount, "Insufficient Balance");
        _rOwned[sender] = _rOwned[sender] - proportionAmount;

        uint256 proportionReceived = _shouldTakeFee(sender, recipient)
            ? _takeFeeInProportions(
                sender == UNISWAP_V2_PAIR ? true : false,
                sender,
                proportionAmount
            )
            : proportionAmount;
        _rOwned[recipient] = _rOwned[recipient] + proportionReceived;

        emit Transfer(
            sender,
            recipient,
            tokenFromReflection(proportionReceived)
        );
        return true;
    }

    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        uint256 proportionAmount = tokensToProportion(amount);
        require(_rOwned[sender] >= proportionAmount, "Insufficient Balance");
        _rOwned[sender] = _rOwned[sender] - proportionAmount;
        _rOwned[recipient] = _rOwned[recipient] + proportionAmount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function _takeFeeInProportions(
        bool buying,
        address sender,
        uint256 proportionAmount
    ) internal returns (uint256) {
        Fee memory __buyFee = buyFee;
        Fee memory __sellFee = sellFee;

        uint256 proportionFeeAmount = buying == true
            ? (proportionAmount * __buyFee.total) / 100
            : (proportionAmount * __sellFee.total) / 100;

        // reflect
        uint256 proportionReflected = buying == true
            ? (proportionFeeAmount * __buyFee.reflection) / __buyFee.total
            : (proportionFeeAmount * __sellFee.reflection) / __sellFee.total;

        _totalProportion = _totalProportion - proportionReflected;

        // take fees
        uint256 _proportionToContract = proportionFeeAmount -
            proportionReflected;
        if (_proportionToContract > 0) {
            _rOwned[address(this)] =
                _rOwned[address(this)] +
                _proportionToContract;

            emit Transfer(
                sender,
                address(this),
                tokenFromReflection(_proportionToContract)
            );
        }
        emit Reflect(proportionReflected, _totalProportion);
        return proportionAmount - proportionFeeAmount;
    }

    function _shouldSwapBack() internal view returns (bool) {
        return
            msg.sender != UNISWAP_V2_PAIR &&
            !inSwap &&
            claimingFees &&
            balanceOf(address(this)) >= swapThreshold;
    }

    function _swapBack() internal swapping {
        Fee memory __sellFee = sellFee;

        uint256 __swapThreshold = swapThreshold;
        uint256 amountToBurn = (__swapThreshold * __sellFee.burn) /
            __sellFee.total;
        uint256 amountToSwap = __swapThreshold - amountToBurn;
        approve(address(UNISWAP_V2_ROUTER), amountToSwap);

        // burn
        _transferFrom(address(this), DEAD, amountToBurn);

        // swap
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = UNISWAP_V2_ROUTER.WETH();

        UNISWAP_V2_ROUTER.swapExactTokensForETHSupportingFeeOnTransferTokens(
            amountToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 amountETH = address(this).balance;

        uint256 totalSwapFee = __sellFee.total -
            __sellFee.reflection -
            __sellFee.burn;
        uint256 amountETHStaking = (amountETH * __sellFee.staking) /
            totalSwapFee;
        uint256 amountETHLP = (amountETH * __sellFee.lp) / totalSwapFee;
        uint256 amountETHBuyback = (amountETH * __sellFee.buyback) /
            totalSwapFee;

        // send
        (bool tmpSuccess, ) = payable(stakingFeeReceiver).call{
            value: amountETHStaking
        }("");
        (tmpSuccess, ) = payable(lpFeeReceiver).call{value: amountETHLP}("");
        (tmpSuccess, ) = payable(buybackFeeReceiver).call{
            value: amountETHBuyback
        }("");
    }

    function _shouldTakeFee(address sender, address recipient)
        internal
        view
        returns (bool)
    {
        return !isFeeExempt[sender] && !isFeeExempt[recipient];
    }
}