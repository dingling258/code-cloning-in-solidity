/// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

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
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    uint256 private _status;

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

    constructor() {
        _status = NOT_ENTERED;
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
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        if (_status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        _status = ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == ENTERED;
    }
}

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


/**
 * @dev Contract module which provides access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is specified at deployment time in the constructor for `Ownable`. This
 * can later be changed with {transferOwnership} and {acceptOwnership}.
 *
 * This module is used through inheritance. It will make available all functions
 * from parent (Ownable).
 */
abstract contract Ownable2Step is Ownable {
    address private _pendingOwner;

    event OwnershipTransferStarted(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Returns the address of the pending owner.
     */
    function pendingOwner() public view virtual returns (address) {
        return _pendingOwner;
    }

    /**
     * @dev Starts the ownership transfer of the contract to a new account. Replaces the pending transfer if there is one.
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual override onlyOwner {
        _pendingOwner = newOwner;
        emit OwnershipTransferStarted(owner(), newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`) and deletes any pending owner.
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual override {
        delete _pendingOwner;
        super._transferOwnership(newOwner);
    }

    /**
     * @dev The new owner accepts the ownership transfer.
     */
    function acceptOwnership() public virtual {
        address sender = _msgSender();
        if (pendingOwner() != sender) {
            revert OwnableUnauthorizedAccount(sender);
        }
        _transferOwnership(sender);
    }
}


/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev The ETH balance of the account is not enough to perform the operation.
     */
    error AddressInsufficientBalance(address account);

    /**
     * @dev There's no code at `target` (it is not a contract).
     */
    error AddressEmptyCode(address target);

    /**
     * @dev A call to an address target failed. The target may have reverted.
     */
    error FailedInnerCall();

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.8.20/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        if (address(this).balance < amount) {
            revert AddressInsufficientBalance(address(this));
        }

        (bool success, ) = recipient.call{value: amount}("");
        if (!success) {
            revert FailedInnerCall();
        }
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason or custom error, it is bubbled
     * up by this function (like regular Solidity function calls). However, if
     * the call reverted with no returned reason, this function reverts with a
     * {FailedInnerCall} error.
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        if (address(this).balance < value) {
            revert AddressInsufficientBalance(address(this));
        }
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and reverts if the target
     * was not a contract or bubbling up the revert reason (falling back to {FailedInnerCall}) in case of an
     * unsuccessful call.
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata
    ) internal view returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            // only check if target is a contract if the call was successful and the return data is empty
            // otherwise we already know that it was a contract
            if (returndata.length == 0 && target.code.length == 0) {
                revert AddressEmptyCode(target);
            }
            return returndata;
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and reverts if it wasn't, either by bubbling the
     * revert reason or with a default {FailedInnerCall} error.
     */
    function verifyCallResult(bool success, bytes memory returndata) internal pure returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            return returndata;
        }
    }

    /**
     * @dev Reverts with returndata if present. Otherwise reverts with {FailedInnerCall}.
     */
    function _revert(bytes memory returndata) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert FailedInnerCall();
        }
    }
}


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

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    /**
     * @dev An operation with an ERC20 token failed.
     */
    error SafeERC20FailedOperation(address token);

    /**
     * @dev Indicates a failed `decreaseAllowance` request.
     */
    error SafeERC20FailedDecreaseAllowance(address spender, uint256 currentAllowance, uint256 requestedDecrease);

    /**
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transfer, (to, value)));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transferFrom, (from, to, value)));
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        forceApprove(token, spender, oldAllowance + value);
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `requestedDecrease`. If `token` returns no
     * value, non-reverting calls are assumed to be successful.
     */
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 requestedDecrease) internal {
        unchecked {
            uint256 currentAllowance = token.allowance(address(this), spender);
            if (currentAllowance < requestedDecrease) {
                revert SafeERC20FailedDecreaseAllowance(spender, currentAllowance, requestedDecrease);
            }
            forceApprove(token, spender, currentAllowance - requestedDecrease);
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval
     * to be set to zero before setting it to a non-zero value, such as USDT.
     */
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeCall(token.approve, (spender, value));

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeCall(token.approve, (spender, 0)));
            _callOptionalReturn(token, approvalCall);
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data);
        if (returndata.length != 0 && !abi.decode(returndata, (bool))) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturn} that silents catches all reverts and returns a bool instead.
     */
    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We cannot use {Address-functionCall} here since this should return false
        // and not revert is the subcall reverts.

        (bool success, bytes memory returndata) = address(token).call(data);
        return success && (returndata.length == 0 || abi.decode(returndata, (bool))) && address(token).code.length > 0;
    }
}

/// @title Staking smartcontract
contract BitNeuronStaking is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    /// Custom Errors
    error ZeroAddress();
    error ZeroAmount();
    error NoRewardsAvailable();
    error YouHaveNotStakedAnything();
    error PoolHasNoRewardAtTheMoment();
    error StakedAmountIsLessThanInputAmount();
    error MaxFeesLimitIsTenPercent();
    error ApyMustBeWithin1and100();
    error StakeIsLockedYet();
    error MaxLockUpPeriodIsOneYear();
    error CannotClaimNativeToken();
    
    /// user stake info
    struct User {
        uint256 totalStaked;
        uint256 totalEarned;
        uint256 lastDepositTime;
        uint256 lastClaimTime;  
    }
    /// penalty Fee if withdrawn before min locking period
    uint256 public constant PENALTY_FEE = 1500;
    /// token address for staking and reward
    IERC20 public token;
    /// reward apy
    uint256 public apy;
    /// divisor for decimals accuracy
    uint256 public divisor = 10000;
    /// locking period for user stake
    uint256 public minlockPeriod;
    /// fees on user deposit
    uint256 public depositFee;
    /// fees on user withdrawal
    uint256 public withdrawFee;
    /// total tokens staked by users in pool
    uint256 public totalStakedInPool;
    /// fees wallet to receive fees
    address public feeWallet;
    /// map users data
    mapping (address => User) public users;
    
    /// Events
    event Staked (address indexed user, uint256 indexed amount);
    event Unstaked (address indexed user, uint256 indexed amount);
    event RewardClaimed (address indexed user, uint256 indexed amount);
    event FeesChanged(uint256 indexed newDepositFee, uint256 indexed newWithdrawFee);
    event EmergencyWithdrawal (address user, uint256 indexed amount);
    event APYUpdated(uint256 indexed newAPY);
    event FeesWalletUpdated (address indexed newFeeWallet);
    
    /// create staking smartcontract, initialize the token address, apy and other variables.
    constructor() Ownable(msg.sender) {
        token = IERC20 (0x5CAF357d6fd0638710ab31fBFFF6E790BE768c39); // Bitneuron
        apy = 1000; // 10% 
        feeWallet = msg.sender;
    }
    
    /// @dev stake tokens in the pool
    /// @param amount: amount to stake
    /// Requirements- 
    /// amount must be greator than zero
    function stake (uint256 amount) external nonReentrant{
        if(amount == 0){
            revert ZeroAmount();
        }
        uint256 feeAmount = 0;
        if(depositFee > 0){
            feeAmount = (amount * depositFee) / divisor;
            token.safeTransferFrom(msg.sender, feeWallet, feeAmount);
            amount = amount - feeAmount;
        }
        
        token.safeTransferFrom(msg.sender, address(this), amount);
        User storage user = users[msg.sender];
         if(pendingReward(msg.sender) > 0){
            _claim(msg.sender);
        }
        totalStakedInPool += amount;
        user.totalStaked += amount;
        user.lastDepositTime = block.timestamp;
       
        user.lastClaimTime = block.timestamp;
        emit Staked (msg.sender, amount);

    }
    

    /// @dev unstake from the pool
    /// @param amount: amount to unstake
    /// Requirements --
    /// user must have some amount in pool
    /// min locking period must have been passed
    function unstake (uint256 amount) nonReentrant external onlyOwner {
        User storage user = users[msg.sender];
        uint256 availableAmount = user.totalStaked;

        if(amount == 0){
            revert ZeroAmount();
        }
        if(availableAmount == 0 ){
            revert YouHaveNotStakedAnything();
        }
        if(block.timestamp - user.lastDepositTime < minlockPeriod){
            revert StakeIsLockedYet();
        }
        if(amount > availableAmount){
            revert StakedAmountIsLessThanInputAmount();
        }
        user.totalStaked = user.totalStaked - amount;

        if(pendingReward(msg.sender) > 0){
            _claim(msg.sender);
        }
        
        totalStakedInPool -= amount;
        uint256 feeAmount = 0;
        if(withdrawFee > 0){
           feeAmount = (amount * withdrawFee) / divisor;
           token.safeTransfer(feeWallet, feeAmount);
           amount = amount - feeAmount;
        }
       token.safeTransfer(msg.sender, amount);
        emit Unstaked(msg.sender, amount);
    }

    
    /// @dev claim pending earnings
    function claimEarning () external nonReentrant {
        uint256 availableRewards = getAvailableRewards();
        if(availableRewards > 0){
            _claim(msg.sender);
        } else {
            revert PoolHasNoRewardAtTheMoment();
        }
    }
    
    /// @dev update deposit and withdraw fees
    /// @param deposit: new deposit fees
    /// @param withdraw: new withdraw fees
    /// Requirements
    /// max fees on either side can be 5 percent
    function updateFees (uint256 deposit, uint256 withdraw) external onlyOwner {
        if(deposit > 500 || withdraw > 500){
            revert MaxFeesLimitIsTenPercent();
        }
        depositFee = deposit;
        withdrawFee = withdraw;
    }
    
    /// @dev update APY for  pool globally
    /// @param newAPY: new pool apy
    /// Requirments --
    /// apy must be b/w 1 and 100 percent
    function updateAPY (uint256 newAPY) external onlyOwner {
        if(newAPY < 100 || newAPY > 10000){
            revert ApyMustBeWithin1and100();
        }
        apy = newAPY;
    }
    
    /// @dev update minimum locking period for user stake
    /// @param time; new min locking period in seconds
    /// Requirements --
    /// Max lockup period is 6 months
    function updateMinLockPeriod (uint256 time) external onlyOwner {
        if(time > 180 days){
            revert MaxLockUpPeriodIsOneYear();
        }
        minlockPeriod = time;
    }
    
    /// @dev emergency withdraw for users, if they don't want to lock for 
    ///      given locking period.
    ///      This action has 15 percent fixed penalty on staked amount
    ///      and there unclaimed rewards are set to zero.
    function emergencyWithdraw () external {
        User storage user = users[msg.sender];
        uint256 availableAmount = user.totalStaked;
        if(availableAmount == 0){
            return;
        }
        totalStakedInPool -= availableAmount;
        user.totalStaked = 0;
        user.lastDepositTime = block.timestamp;
        user.lastClaimTime = block.timestamp;
        uint256 penaltyAmount = (availableAmount * PENALTY_FEE) / divisor;
        token.safeTransfer(feeWallet, penaltyAmount);
        availableAmount = availableAmount - penaltyAmount;
        token.safeTransfer(msg.sender, availableAmount);
        emit EmergencyWithdrawal(msg.sender, availableAmount);

    }
    
    /// @dev update Fee wallet
    /// @param wallet: new fee wallet
    function updateFeeWallet (address wallet) external onlyOwner {
        if(wallet == address(0)){
            revert ZeroAddress();
        }
        feeWallet = wallet;
    } 
    
    /// @notice internal function, claim pending rewards for user
    /// @param user: user address
    function _claim (address user) internal {
        uint256 pendingEarnings = pendingReward(user);
        uint256 availableRewards = getAvailableRewards();
        if(availableRewards > 0){
        if(availableRewards >= pendingEarnings){
            users[user].lastClaimTime = block.timestamp;
            users[user].totalEarned = users[user].totalEarned + pendingEarnings;
            token.safeTransfer(user, pendingEarnings);
            emit RewardClaimed(user, pendingEarnings);
        } else {
            uint256 stakedAmount = users[user].totalStaked;
            uint256 time = (availableRewards * divisor * 365 days) / (stakedAmount * apy);
            users[user].lastClaimTime = users[user].lastClaimTime + time;
            users[user].totalEarned = users[user].totalEarned + availableRewards;
            token.safeTransfer(user, availableRewards);
            emit RewardClaimed(user, availableRewards);
         }
        }
    }
    
    /// @dev claim other erc20 tokens if accidently sent by someone
    /// @param oToken: token to rescue
    /// @param amount: amount to rescue
    function claimOtherERC20 (address oToken, uint256 amount) external onlyOwner {
        if(oToken == address(token)){
            revert CannotClaimNativeToken();
        }
        IERC20 otherToken = IERC20(oToken);
        otherToken.safeTransfer(owner(), amount);
    }
    
    /// @dev return pending rewards for user
    /// @param user: user address
    function pendingReward (address user) public view returns (uint256){
             uint256 stakedAmount = users[user].totalStaked;
             uint256 rewards;
             if(stakedAmount > 0){
             uint256 lastClaimTime = users[user].lastClaimTime;
             uint256 timePassed = block.timestamp - lastClaimTime;
              rewards = (stakedAmount * apy * timePassed) / (divisor * 365 days);
             }
             return rewards;
    }

    
    /// @notice returns available rewards in the pool
    function getAvailableRewards() public view returns (uint256) {
        return token.balanceOf(address(this)) - totalStakedInPool;
    }
}