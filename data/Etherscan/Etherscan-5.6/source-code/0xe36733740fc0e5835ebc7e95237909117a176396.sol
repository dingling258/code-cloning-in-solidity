// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20 ^0.8.23;

// lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

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

// lib/openzeppelin-contracts/contracts/utils/Context.sol

// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

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

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}

// lib/openzeppelin-contracts/contracts/access/Ownable.sol

// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

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

// src/MAOPRESALE.sol

contract MAOPRESALE is Ownable {
    /*//////////////////////////////////////////////////////////////
                           ERRORS
    //////////////////////////////////////////////////////////////*/

    error MAOPRESALE_PRICE_NOT_ZERO();
    error MAOPRESALE_NOT_ENOUGH_ETH();
    error MAOPRESALE_TOKEN_NOT_SET();
    error MAOPRESALE_NOT_ACTIVE();
    error MAOPRESALE_TOKEN_TRANSFER_FAILED();
    error MAOPRESALE_NOT_ENOUGH_MAO_TOKEN();
    error MAOPRESALE_NOT_ENOUGH_USDT_ALLOWANCE();
    error MAOPRESALE_USDT_TRANSFER_FAILED();
    error MAOPRESALE_NOT_ENOUGH_USDT();
    error MAOPRESALE_NO_BALANCE_TO_WITHDRAW();
    error MAOPRESALE_WITHDRAW_FAILED();
    error MAOPRESALE_LIMIT_REACHED();
    /*//////////////////////////////////////////////////////////////
                           STRUCTS AND ENUMS
    //////////////////////////////////////////////////////////////*/

    enum PresaleState {
        Pause,
        Phase1,
        Phase2,
        Phase3,
        Phase4,
        Phase5,
        Phase6,
        Phase7,
        Phase8,
        Phase9,
        Phase10
    }

    struct UserBalance {
        uint256 amount;
        uint256 time;
        bool claimed;
    }

    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/

    PresaleState private state = PresaleState.Pause;
    IERC20 private maoToken;
    uint256 private tokenSold;
    // Each Phase token amount
    mapping(PresaleState => uint256) private phaseTokenAmount;
    // Token Minted Each Phase
    mapping(PresaleState => uint256) private phaseTokenMinted;
    // ETh Raised Amount
    uint256 private ethRaised = 0;
    // Price per token
    mapping(PresaleState => uint256) private phasePricePerToken;
    // user balance
    mapping(address => UserBalance) private balance;
    // Others
    uint256 constant PRICE_DECIMALS = 8;
    uint256 constant ETH_PRICE_DECIMALS = 18;

    /*//////////////////////////////////////////////////////////////
                              EVENTS
    //////////////////////////////////////////////////////////////*/

    event PurchasedToken(address indexed buyer, uint256 amount, uint256 price);

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor() Ownable(msg.sender) {
        // Phase Token Max Amount
        setDetaultPhaseAmount();
        // Phase Price
        setPhasePrice();
    }

    /*//////////////////////////////////////////////////////////////
                               MODIFIERS
    //////////////////////////////////////////////////////////////*/

    modifier priceNotZero(uint256 price) {
        if (price == 0) {
            revert MAOPRESALE_PRICE_NOT_ZERO();
        }

        _;
    }

    modifier tokenNotSet() {
        if (address(maoToken) == address(0)) {
            revert MAOPRESALE_TOKEN_NOT_SET();
        }
        _;
    }

    modifier checkLimit(uint256 amount) {
        if (getPhaseTokenMinted() + amount > getPhaseTokenLimit()) {
            revert MAOPRESALE_LIMIT_REACHED();
        }
        _;
    }

    modifier SaleNotActive() {
        if (state == PresaleState.Pause) {
            revert MAOPRESALE_NOT_ACTIVE();
        }
        _;
    }

    /*//////////////////////////////////////////////////////////////
                            GET FUNCTION
    //////////////////////////////////////////////////////////////*/

    function getPresaleState() external view returns (PresaleState) {
        return state;
    }

    function getTokenSold() external view returns (uint256) {
        return tokenSold;
    }

    function getPhaseTokenMinted() public view returns (uint256) {
        return phaseTokenMinted[state];
    }

    function getPhaseTokenLimit() public view returns (uint256) {
        return phaseTokenAmount[state];
    }

    function getPhasePrice() public view returns (uint256) {
        return phasePricePerToken[state];
    }

    function getNextPhasePrice() public view returns (uint256) {
        if (state == PresaleState.Phase1) {
            return phasePricePerToken[PresaleState.Phase2];
        }

        if (state == PresaleState.Phase2) {
            return phasePricePerToken[PresaleState.Phase3];
        }

        if (state == PresaleState.Phase3) {
            return phasePricePerToken[PresaleState.Phase4];
        }

        if (state == PresaleState.Phase4) {
            return phasePricePerToken[PresaleState.Phase5];
        }

        if (state == PresaleState.Phase5) {
            return phasePricePerToken[PresaleState.Phase6];
        }

        if (state == PresaleState.Phase6) {
            return phasePricePerToken[PresaleState.Phase7];
        }

        if (state == PresaleState.Phase7) {
            return phasePricePerToken[PresaleState.Phase8];
        }

        if (state == PresaleState.Phase8) {
            return phasePricePerToken[PresaleState.Phase9];
        }

        if (state == PresaleState.Phase9) {
            return phasePricePerToken[PresaleState.Phase10];
        }

        if (state == PresaleState.Phase10) {
            return phasePricePerToken[PresaleState.Phase10];
        }

        return phasePricePerToken[PresaleState.Phase1];
    }

    function getMaoToken() external view returns (IERC20) {
        return maoToken;
    }

    function getETHRaised() external view returns (uint256) {
        return ethRaised;
    }

    function getUserBalance(address _user) external view returns (UserBalance memory) {
        return balance[_user];
    }

    /*//////////////////////////////////////////////////////////////
                            SET FUNCTION
    //////////////////////////////////////////////////////////////*/

    function setDetaultPhaseAmount() internal {
        phaseTokenAmount[PresaleState.Phase1] = 22_000_000;
        phaseTokenAmount[PresaleState.Phase2] = 35_000_000;
        phaseTokenAmount[PresaleState.Phase3] = 55_000_000;
        phaseTokenAmount[PresaleState.Phase4] = 60_000_000;
        phaseTokenAmount[PresaleState.Phase5] = 60_000_000;
        phaseTokenAmount[PresaleState.Phase6] = 60_000_000;
        phaseTokenAmount[PresaleState.Phase7] = 45_000_000;
        phaseTokenAmount[PresaleState.Phase8] = 45_000_000;
        phaseTokenAmount[PresaleState.Phase9] = 60_000_000;
        phaseTokenAmount[PresaleState.Phase10] = 60_000_000;
    }

    function setPhasePrice() internal {
        phasePricePerToken[PresaleState.Phase1] = 0.0000075 ether;
        phasePricePerToken[PresaleState.Phase2] = 0.000011 ether;
        phasePricePerToken[PresaleState.Phase3] = 0.000014 ether;
        phasePricePerToken[PresaleState.Phase4] = 0.000017 ether;
        phasePricePerToken[PresaleState.Phase5] = 0.000021 ether;
        phasePricePerToken[PresaleState.Phase6] = 0.000024 ether;
        phasePricePerToken[PresaleState.Phase7] = 0.000027 ether;
        phasePricePerToken[PresaleState.Phase8] = 0.000031 ether;
        phasePricePerToken[PresaleState.Phase9] = 0.000034 ether;
        phasePricePerToken[PresaleState.Phase10] = 0.000037 ether;
    }

    function setPresaleState(PresaleState _state) external onlyOwner {
        state = _state;
    }

    function setPhaseAmount(PresaleState _state, uint256 _amount) external onlyOwner priceNotZero(_amount) {
        phaseTokenAmount[_state] = _amount;
    }

    function setMaoToken(address _maoToken) external onlyOwner {
        maoToken = IERC20(_maoToken);
    }

    function setPhaseTokenPrice(PresaleState _state, uint256 _price) external onlyOwner priceNotZero(_price) {
        phasePricePerToken[_state] = _price;
    }

    function setPhaseMintedBalance(uint256 amount) internal {
        phaseTokenMinted[state] += amount;
    }

    /*//////////////////////////////////////////////////////////////
                              OTHER FUNCTION
    //////////////////////////////////////////////////////////////*/

    function purchaseToken(uint256 _amount) external payable SaleNotActive tokenNotSet checkLimit(_amount) {
        uint256 tokenAmount = _amount * 1e18;
        if (maoToken.balanceOf(address(this)) < tokenAmount) {
            revert MAOPRESALE_NOT_ENOUGH_MAO_TOKEN();
        }
        uint256 requiredETH = getPhasePrice() * _amount;

        if (msg.value < requiredETH) {
            revert MAOPRESALE_NOT_ENOUGH_ETH();
        }

        tokenSold += tokenAmount;
        setPhaseMintedBalance(_amount);
        ethRaised += msg.value;
        if (balance[msg.sender].amount == 0) {
            balance[msg.sender] = UserBalance({amount: tokenAmount, time: block.timestamp, claimed: false});
        } else {
            balance[msg.sender].amount += tokenAmount;
            balance[msg.sender].time = block.timestamp;
        }

        emit PurchasedToken(msg.sender, tokenAmount, requiredETH);
    }

    function claimToken() external {
        uint256 tokenAmount = balance[msg.sender].amount;

        if (maoToken.balanceOf(address(this)) < tokenAmount) {
            revert MAOPRESALE_NOT_ENOUGH_MAO_TOKEN();
        }

        maoToken.approve(address(this), tokenAmount);

        balance[msg.sender].amount = 0;
        balance[msg.sender].claimed = true;

        bool success = maoToken.transferFrom(address(this), msg.sender, tokenAmount);
        if (!success) {
            revert MAOPRESALE_TOKEN_TRANSFER_FAILED();
        }
    }

    function withdrawFunds() external onlyOwner {
        if (address(this).balance <= 0) {
            revert MAOPRESALE_NO_BALANCE_TO_WITHDRAW();
        }

        (bool success,) = payable(owner()).call{value: address(this).balance}("");

        if (!success) {
            revert MAOPRESALE_WITHDRAW_FAILED();
        }
    }

    function withdrawRemainingTokens() external onlyOwner {
        uint256 tokenBalance = maoToken.balanceOf(address(this));
        if (tokenBalance <= 0) {
            revert MAOPRESALE_NO_BALANCE_TO_WITHDRAW();
        }

        maoToken.approve(address(this), tokenBalance);

        bool success = maoToken.transferFrom(address(this), owner(), tokenBalance);

        if (!success) {
            revert MAOPRESALE_WITHDRAW_FAILED();
        }
    }

    receive() external payable {}
}