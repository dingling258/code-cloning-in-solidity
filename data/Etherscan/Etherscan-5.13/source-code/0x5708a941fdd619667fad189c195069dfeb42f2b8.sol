// SPDX-License-Identifier: MIT
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


// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

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

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
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

// File: @openzeppelin/contracts/utils/math/SafeMath.sol


// OpenZeppelin Contracts (last updated v4.9.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
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

// File: contracts/ECMICOSale.sol


pragma solidity ^0.8.20;






/**
 * @title ECMCoinICOSale
 * @dev A smart contract for conducting a ICO coin sale of ECM Coins.
 */
contract ECMCoinICOSale is Ownable(msg.sender), Pausable, ReentrancyGuard {
    using SafeMath for uint256;

    enum SaleStage { Stage1, Stage2, Stage3, Stage4, Stage5, Stage6, Stage7, Stage8, Stage9 }

    IERC20 public ECMCoin; // The ECM coin being sold
    uint256 public overallTotalSold; // Total ECM sold from start to now
    uint256 public finalSaleTarget; // Final target for the sale
    uint256 public totalETHRaised; // Total amount of ETH raised
    bool public saleOpen; // Whether the sale is currently open

    uint256 public totalReferenceECMPaid; // Total reference commission paid in ECM
    uint256 public totalReferenceETHPaid; // Total reference commission paid in ETH
    uint8 public referralECMPercentage; // Referral commission percentage for ECM
    uint8 public referralETHPercentage; // Referral commission percentage for ETH

    SaleStage public currentStage; // Current sale stage
    mapping(SaleStage => uint256) public stagePrices; // Price of ECM in each stage
    mapping(SaleStage => uint256) public stageSaleTargets; // Total Sale Target for each stage
    mapping(SaleStage => uint256) public stageECMSolds; // Total ECM sold in each stage

    event ECMPurchased(address indexed buyer, uint256 amount, uint256 price);
    event ReferenceECMCommissionPaid(address indexed referrer, address indexed buyer, uint256 commission);
    event ReferenceETHCommissionPaid(address indexed referrer, address indexed buyer, uint256 commission);
    address payable public ethWallet; // Address where funds are collected

    event EtherAmountWithdrawn(uint256 amount);
    event ECMAmountWithdrawn(uint256 amount);
    event SaleTargetCompleted(uint256 amount);
    event SaleStatusChanged(bool newStatus);

    /**
     * @dev Modifier to ensure that the sale is currently open.
     */
    modifier saleIsOpen() {
        require(saleOpen, "Sale currently on stop mode.");
        _;
    }

    /**
     * @dev Constructor to initialize the ECMICOSale contract.
     * @param _ECMCoin The address of the ECM coin contract.
     * @param _finalSaleTarget The final target for the sale.
     * @param _referralECMPercentage The referral commission percentage for ECM.
     * @param _referralETHPercentage The referral commission percentage for ETH.
     */
    constructor(
        IERC20 _ECMCoin,
        uint256 _finalSaleTarget,
        uint8 _referralECMPercentage,
        uint8 _referralETHPercentage
    ) {
        require(_referralECMPercentage <= 100, "Referral ECM commission percentage must be less than or equal to 100.");
        require(_referralETHPercentage <= 100, "Referral ETH commission percentage must be less than or equal to 100.");

        ECMCoin = _ECMCoin;
        finalSaleTarget = _finalSaleTarget;
        referralECMPercentage = _referralECMPercentage;
        referralETHPercentage = _referralETHPercentage;

        // Initialize the sale stages price and sale target
        initializeStageData();

        currentStage = SaleStage.Stage1;
        ethWallet = payable(msg.sender); 
        saleOpen = true; // Sale is open by default
    }

    /**
     * @dev Internal function to initialize the sale stages data.
     */
    function initializeStageData() private {
        // Set the price of ECM in each stage
        stagePrices[SaleStage.Stage1] = 400000000000000; // 0.00040 ether
        stagePrices[SaleStage.Stage2] = 410000000000000; // 0.00041 ether
        stagePrices[SaleStage.Stage3] = 420000000000000; // 0.00042 ether
        stagePrices[SaleStage.Stage4] = 430000000000000; // 0.00043 ether
        stagePrices[SaleStage.Stage5] = 440000000000000; // 0.00044 ether
        stagePrices[SaleStage.Stage6] = 450000000000000; // 0.00045 ether
        stagePrices[SaleStage.Stage7] = 460000000000000; // 0.00046 ether
        stagePrices[SaleStage.Stage8] = 470000000000000; // 0.00047 ether
        stagePrices[SaleStage.Stage9] = 480000000000000; // 0.00048 ether

        // Set the total Sale Target for each stage
        stageSaleTargets[SaleStage.Stage1] = 3350000000000000000000000; // 3350000 ECM
        stageSaleTargets[SaleStage.Stage2] = 5000000000000000000000000; // 5000000 ECM
        stageSaleTargets[SaleStage.Stage3] = 7500000000000000000000000; // 7500000 ECM
        stageSaleTargets[SaleStage.Stage4] = 15000000000000000000000000; // 15000000 ECM
        stageSaleTargets[SaleStage.Stage5] = 20000000000000000000000000; // 20000000 ECM
        stageSaleTargets[SaleStage.Stage6] = 10000000000000000000000000; // 10000000 ECM
        stageSaleTargets[SaleStage.Stage7] = 7500000000000000000000000; // 7500000 ECM
        stageSaleTargets[SaleStage.Stage8] = 10000000000000000000000000; // 10000000 ECM
        stageSaleTargets[SaleStage.Stage9] = 20000000000000000000000000; // 20000000 ECM
    }

    /**
     * @dev External function to set the Sale Stage parameters.
     * @param _stage The sale stage to be updated.
     * @param _target The new sale target for the specified stage.
     * @param _price The new price of ECM for the specified stage.
     */
    function setStage(SaleStage _stage, uint256 _target, uint256 _price) external whenNotPaused onlyOwner {
        require(uint256(_stage) < 9, "Invalid stage index entered.");
        require(_target > 0, "Sale target must be greater than zero.");
        require(_price > 0, "Price must be greater than zero.");

        stageSaleTargets[_stage] = _target;
        stagePrices[_stage] = _price;
    }

    /**
     * @dev External function to update the referral commission percentages.
     * @param _referralECMPercentage The new referral commission percentage for ECM.
     * @param _referralETHPercentage The new referral commission percentage for ETH.
     */
    function updateReferralPercentage(uint8 _referralECMPercentage,uint8 _referralETHPercentage) external whenNotPaused onlyOwner {
        require(_referralECMPercentage <= 100, "Referral ECM commission percentage must be less than or equal to 100.");
        require(_referralETHPercentage <= 100, "Referral ETH commission percentage must be less than or equal to 100.");
        
        referralECMPercentage = _referralECMPercentage;
        referralETHPercentage = _referralETHPercentage;
    }

    /**
     * @dev External payable function to handle the purchase of ECM coins.
     * @param _referrer The address of the referrer who referred the buyer.
     */
    function purchaseECM(address _referrer) public payable nonReentrant whenNotPaused saleIsOpen {

        uint256 weiAmount = msg.value;
        require(weiAmount > 0, "Request Amount must be greater than zero.");

        uint256 currentRate = stagePrices[currentStage];
        require(currentRate > 0, "Current stage price must be greater than zero.");

        uint256 ECMToReceive = weiAmount.mul(1e18).div(currentRate); // Calculate Reciveable ECM amount based on Ether sent and Current Stage ECM price
        require(ECMToReceive > 0, "ECM amount must be greater than zero.");

        // Calculate the available balance for the current stage
        uint256 availableBalance = stageSaleTargets[currentStage].sub(stageECMSolds[currentStage]);
        require(availableBalance >= ECMToReceive, "Not enough coins available for purchase in this stage.");

        uint256 referralECMCommission = calculateECMReferralCommission(ECMToReceive, _referrer);
        require(overallTotalSold.add(ECMToReceive).add(referralECMCommission) <= finalSaleTarget, "Purchase would exceed coin sale max target.");

        if(!ECMCoin.transfer(msg.sender, ECMToReceive)){
            revert("ECM coin transfer failed.");
        }
        emit ECMPurchased(msg.sender, ECMToReceive, weiAmount);

        // Calculate and Transfer ECM referral commission if larger then 0
        if (referralECMCommission > 0) {
            if (!ECMCoin.transfer(_referrer, referralECMCommission)){
                revert("ECM coin transfer failed.");
            }
            totalReferenceECMPaid = totalReferenceECMPaid.add(referralECMCommission);
            emit ReferenceECMCommissionPaid(_referrer, msg.sender, referralECMCommission);
        }

        // Calculate the total sold ETH Raise
        overallTotalSold = overallTotalSold.add(ECMToReceive).add(referralECMCommission);
        stageECMSolds[currentStage] = stageECMSolds[currentStage].add(ECMToReceive).add(referralECMCommission);
        totalETHRaised = totalETHRaised.add(weiAmount);

        // Calculate and Transafer ETH referral commission if larger then 0
        uint256 referralETHCommission = calculateETHReferralCommission(weiAmount, _referrer);
        if (referralETHCommission > 0) {
            payable(_referrer).transfer(referralETHCommission);
            totalReferenceETHPaid = totalReferenceETHPaid.add(referralETHCommission);
            emit ReferenceETHCommissionPaid(_referrer, msg.sender, referralETHCommission);
        }

        if (stageECMSolds[currentStage] >= stageSaleTargets[currentStage]) {
            // Check if this is the 9th stage and the total supply is equal to or larger than the coins sold
            if (currentStage == SaleStage.Stage9 && stageSaleTargets[SaleStage.Stage9] <= stageECMSolds[SaleStage.Stage9]) {
                currentStage = SaleStage.Stage9;
            } else {
                // Move to the next stage if current stage sale is completed
                currentStage = SaleStage(uint256(currentStage) + 1);
            }
            // Reset total sold for the next stage
            stageECMSolds[currentStage] = 0;
        }

        if (overallTotalSold >= finalSaleTarget) {
            saleOpen = false;
            emit SaleTargetCompleted(finalSaleTarget);
        }
    }

    /**
     * @dev Internal function to calculate the referral commission in ECM.
     * @param _amount The amount of ECM coins being purchased.
     * @param _referrer The address of the referrer who referred the buyer.
     * @return The referral commission in ECM.
     */
    function calculateECMReferralCommission(uint256 _amount, address _referrer) internal view returns (uint256) {
        if (_referrer != address(0) && _referrer != msg.sender) {
            return _amount.mul(referralECMPercentage).div(100);
        }
        return 0;
    }

    /**
     * @dev Internal function to calculate the referral commission in ETH.
     * @param _amount The amount of ETH being sent for the purchase.
     * @param _referrer The address of the referrer who referred the buyer.
     * @return The referral commission in ETH.
     */
    function calculateETHReferralCommission(uint256 _amount, address _referrer) internal view returns (uint256) {
        if (_referrer != address(0) && _referrer != msg.sender) {
            return _amount.mul(referralETHPercentage).div(100);
        }
        return 0;
    }

    /**
    * @dev External function to update the final sale target.
    * @param _newFinalSaleTarget The new final sale target.
    */
    function updateFinalSaleTarget(uint256 _newFinalSaleTarget) external onlyOwner whenNotPaused {
        require(_newFinalSaleTarget > overallTotalSold, "New final sale target must be greater than the overall total sold.");
        require(_newFinalSaleTarget > 0, "New final sale target must be greater than zero.");
        finalSaleTarget = _newFinalSaleTarget;
    }


    /**
     * @dev External function to withdraw ETH from the contract.
     * @param amount The amount of ETH to withdraw.
     */
    function withdraw(uint256 amount) external onlyOwner {
        require(amount > 0, "Withdrawal amount must be greater than zero.");
        require(address(this).balance >= amount, "Insufficient eth balance.");

        ethWallet.transfer(amount);
        emit EtherAmountWithdrawn(amount);
    }

    /**
     * @dev External function to update the withdrawal wallet address.
     * @param withdrawWallet The new withdrawal wallet address.
     */
    function updateWithdrawWallet(address payable withdrawWallet) external whenNotPaused onlyOwner {
        require(withdrawWallet != address(0), "Wallet is the zero address");
        ethWallet = withdrawWallet;
    }

    /**
     * @dev External function to withdraw ECM coins from the contract.
     * @param amount The amount of ECM coins to withdraw.
     */
    function withdrawECM(uint256 amount) external onlyOwner {
        require(amount > 0, "Withdrawal amount must be greater than zero.");
        uint256 balance = ECMCoin.balanceOf(address(this));
        require(balance >= amount, "Insufficient coin balance.");

        if(!ECMCoin.transfer(ethWallet, amount)){
            revert("ECM coin transfer failed.");
        }
        emit ECMAmountWithdrawn(amount);
    }

    /**
     * @dev External function to toggle the sale status (open/closed).
     */
    function toggleSaleStatus() external whenNotPaused onlyOwner {
        saleOpen = !saleOpen;
        emit SaleStatusChanged(saleOpen);
    }
    

    /**
     * @dev Pauses all coin transfers.
     * Can only be called by the owner.
     */
    function pause() public onlyOwner {
        _pause();
    }

    /**
     * @dev Unpauses all coin transfers.
     * Can only be called by the owner.
     */
    function unpause() public onlyOwner {
        _unpause();
    }

    /**
     * @dev Fallback function to receive ETH and purchase ECM coins.
     * Calls the purchaseECM function with address(0) as the referrer.
     */
    receive() external payable {
        purchaseECM(address(0)); // Call purchaseECM with address(0) as the referrer
    }
}