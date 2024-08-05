// File: @openzeppelin/contracts/security/ReentrancyGuard.sol


// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts (last updated v5.0.0) (utils/Context.sol)

pragma solidity ^0.8.20;

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

// File: @openzeppelin/contracts/security/Pausable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;


/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;


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

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

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
    event Approval(address indexed owner, address indexed spender, uint256 value);

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
    function allowance(address owner, address spender) external view returns (uint256);

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
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

// File: crashtest/crash-token/contracts/ICOSale.sol

// contracts/ICOSale.sol


pragma solidity ^0.8.20;





   
contract ICOSale is Ownable, Pausable, ReentrancyGuard {
    address public initialOwner = msg.sender;
    IERC20 public token;
    uint256 public ethTokenPrice;
    uint256 public icoStartTime;
    uint256 public icoEndTime;
    mapping(address => bool) public whitelisted;
    mapping(address => bool) public acceptedTokens;
    mapping(address => uint256) public tokenPrices;

    event TokensPurchased(address indexed buyer, uint256 amount, address paymentToken);
    event WhitelistUpdated(address indexed participant, bool status);
    event AcceptedTokenUpdated(address tokenAddress, bool status);
    event IcoStartTimeUpdated(uint256 _startTime);
    event IcoEndTimeUpdated(uint256 _endTime);

    modifier onlyWhileOpen {
        require(block.timestamp >= icoStartTime && block.timestamp <= icoEndTime, "ICO not open");
        _;
    }

    modifier onlyWhitelisted {
        require(whitelisted[msg.sender], "Not whitelisted");
        _;
    }

    modifier onlyAcceptedTokens(address tokenAddress) {
        require(acceptedTokens[tokenAddress], "Token not accepted");
        _;
    }

    constructor(
        IERC20 _token,
        uint256 _ethTokenPrice,
        uint256 _icoStartTime,
        uint256 _icoEndTime
    ) Ownable(msg.sender) {
        require(_icoStartTime < _icoEndTime, "Invalid time range");
        
        token = _token;
        ethTokenPrice = _ethTokenPrice;
        icoStartTime = _icoStartTime;
        icoEndTime = _icoEndTime;

        acceptedTokens[address(0)] = true;//Ether is accepted by default
    
        // Default accepted tokens
        acceptedTokens[0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599] = true; // Wrapped Bitcoin (WBTC)
        acceptedTokens[0xdAC17F958D2ee523a2206206994597C13D831ec7] = true; // Tether (USDT)
        acceptedTokens[0xdB25f211AB05b1c97D595516F45794528a807ad8] = true; // Stasis EURS
        acceptedTokens[0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48] = true; // USD Coin (USDC)
        acceptedTokens[0x50327c6c5a14DCaDE707ABad2E27eB517df87AB5] = true; // TRON Coin (TRX)
        acceptedTokens[0x514910771AF9Ca656af840dff83E8264EcF986CA] = true; // ChainLink (LINK)
        acceptedTokens[0x7D1AfA7B718fb893dB30A3aBc0Cfc608AaCfeBB0] = true; // Matic (MATIC)
        acceptedTokens[0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984] = true; // Uniswap (UNI)
        acceptedTokens[0x2b591e99afE9f32eAA6214f7B7629768c40Eeb39] = true; // HEX (HEX)
        acceptedTokens[0x582d872A1B094FC48F5DE31D3B73F2D9bE47def1] = true; // Wrapped TON (TON)
        acceptedTokens[0x056Fd409E1d7A124BD7017459dFEa2F387b6d5Cd] = true; // Gemini Dollar (GUSD)
        acceptedTokens[0x5f98805A4E8be255a32880FDeC7F6728C6568bA0] = true; // Liquity USD (LUSD)
        acceptedTokens[0x8E870D67F660D95d5be530380D0eC0bd388289E1] = true; // Pax Dollar Standard (PAX)
        acceptedTokens[0x6B175474E89094C44Da98b954EedeAC495271d0F] = true; // DAI Stablecoin (DAI)
        acceptedTokens[0x4Fabb145d64652a948d72533023f6E7A623C7C53] = true; // Binance USD (BUSD)
        acceptedTokens[0x0000000000085d4780B73119b644AE5ecd22b376] = true; // TrueUSD (TUSD)
        acceptedTokens[0x1aBaEA1f7C830bD89Acc67eC4af516284b1bC33c] = true; // Euro Coin
        acceptedTokens[0x39fBBABf11738317a448031930706cd3e612e1B9] = true; // Wrapped Ripple (WXRP)
    }
    
    function tokenPrice() external view returns (uint256) {
        return ethTokenPrice;
    }
    
    function whitelist(address _participant) external view returns (bool) {
        return whitelisted[_participant];
    }

    function setStartTime(uint256 _startTime) external onlyOwner {
        icoStartTime = _startTime;
        emit IcoStartTimeUpdated(_startTime);
    }

    function setEndTime(uint256 _endTime) external onlyOwner {
        icoEndTime = _endTime;
        emit IcoEndTimeUpdated(_endTime);
    }

    function updateWhitelist(address _participant, bool _status) external onlyOwner {
        whitelisted[_participant] = _status;
        emit WhitelistUpdated(_participant, _status);
    }

    function updateAcceptedToken(address tokenAddress, bool _status) external onlyOwner {
        acceptedTokens[tokenAddress] = _status;
        emit AcceptedTokenUpdated(tokenAddress, _status);
    }

    function setTokenPrice(address tokenAddress, uint256 _price) external onlyOwner {
        require(_price > 0, "Price cannot be zero");
        tokenPrices[tokenAddress] = _price;
    }

    function buyTokens(uint256 _numTokens, address paymentToken) external payable nonReentrant onlyWhileOpen onlyWhitelisted whenNotPaused onlyAcceptedTokens(paymentToken) {
        uint256 cost;
        require(token.balanceOf(address(this)) >= _numTokens, "Not enough tokens in contract");
        require(_numTokens > 0, "No tokens sent");

        if (paymentToken == address(0)) {  // payment in Ether
            cost = _numTokens * ethTokenPrice;
            require(msg.value == cost, "Incorrect value sent");
        } else {  // payment in ERC20
            cost = _numTokens * tokenPrices[paymentToken];
            IERC20 paymentTokenContract = IERC20(paymentToken);
            require(paymentTokenContract.transferFrom(msg.sender, address(this), cost), "Transfer failed");
        }
        require(token.transfer(msg.sender, _numTokens), "Token transfer failed");
        emit TokensPurchased(msg.sender, _numTokens, paymentToken);
    }

   function withdrawFunds(address tokenAddress) external onlyOwner {
    if (tokenAddress == address(0)) {  // withdraw Ether
        payable(owner()).transfer(address(this).balance);
    } else {  // withdraw ERC20
        IERC20 paymentTokenContract = IERC20(tokenAddress);
        uint256 balance = paymentTokenContract.balanceOf(address(this));
        
        if (balance == 0) {
            revert("No funds to withdraw");
        } else {
            require(paymentTokenContract.transfer(owner(), balance), "Transfer failed");
        }
    }
}

    function pauseICO() external onlyOwner {
        _pause();
    }

    function unpauseICO() external onlyOwner {
        _unpause();
    }
}