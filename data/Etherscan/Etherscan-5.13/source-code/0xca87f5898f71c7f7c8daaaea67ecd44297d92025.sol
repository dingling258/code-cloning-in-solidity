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

// lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/ReentrancyGuard.sol)

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

// src/MAOSTAKING.sol

contract MAOSTAKING is Ownable, ReentrancyGuard {
    error MAOSTAKIN_Staking_TransferFailed();
    error MAOSTAKING_Withdraw_TransferFailed();
    error MAOSTAKING_Withdraw_InsufficientRewards();
    error MAOSTAKING_Withdraw_InsufficientBalance();
    error MAOSTAKIN_Staking_NeedsMoreThanZero();
    error MAOSTAKIN_Staking_InsufficientFunds();
    error MAOSTAKIN_Staking_InvalidLockin();
    error MAOSTAKIN_Staking_InvalidStakedAmount();
    error MAOSTAKIN_Staking_UnStaking_TooSoon();
    error MAOSTAKIN_Staking_InsufficientRewards();
    error MAOSTAKIN_Staking_Claiming_TooSoon();
    error MAOSTAKIN_Staking_InvalidIndex();
    error MAOSTAKIN_NO_BALANCE_TO_WITHDRAW();
    error MAOSTAKIN_WITHDRAW_FAILED();

    /*//////////////////////////////////////////////////////////////
                               VARIABLES
    //////////////////////////////////////////////////////////////*/

    struct Staked {
        uint256 stakedAmount;
        uint256 timestamp;
        uint256 lockInTimestamp;
        uint256 rewardAmount;
        uint256 claimRewards;
        uint256 claimTimestamp;
    }

    enum Days {
        One,
        Thirty,
        Sixty,
        Ninty,
        Year
    }

    uint16 private yearlyAPY = 15;
    uint256 private rewardLockIn = 1 days;

    IERC20 private maoToken;
    uint256 totalTokenStaked;
    mapping(address => Staked[]) public s_balances;
    mapping(address => uint256) public stackedCount;

    constructor() Ownable(msg.sender) {}

    /*//////////////////////////////////////////////////////////////
                               MODIFIERS
    //////////////////////////////////////////////////////////////*/

    modifier moreThanZero(uint256 amount) {
        if (amount == 0) {
            revert MAOSTAKIN_Staking_NeedsMoreThanZero();
        }
        _;
    }

    modifier isValidLockin(Days _lockedIn) {
        if (
            _lockedIn != Days.One && _lockedIn != Days.Thirty && _lockedIn != Days.Sixty && _lockedIn != Days.Ninty
                && _lockedIn != Days.Year
        ) {
            revert MAOSTAKIN_Staking_InvalidLockin();
        }
        _;
    }

    /*//////////////////////////////////////////////////////////////
                             GET FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function getRewardsEarned(address _sender) external view returns (uint256) {
        uint256 stackedLength = s_balances[_sender].length;
        Staked[] memory staked = s_balances[_sender];
        uint256 currentTime = block.timestamp;
        uint256 totalRewards;
        for (uint256 i = 0; i < stackedLength; i++) {
            uint256 timeStaked = currentTime - staked[i].timestamp;
            if (timeStaked != 0) {
                uint256 rewards = (staked[i].stakedAmount * yearlyAPY * timeStaked) / (100 * 365 days);
                totalRewards += rewards;
            }
        }

        return totalRewards;
    }

    function getLockinTimeStamp(Days _lockedIn) internal view returns (uint256) {
        if (_lockedIn == Days.One) {
            return block.timestamp + 1 days;
        }
        if (_lockedIn == Days.Sixty) {
            return block.timestamp + 60 days;
        }
        if (_lockedIn == Days.Ninty) {
            return block.timestamp + 90 days;
        }
        if (_lockedIn == Days.Year) {
            return block.timestamp + 365 days;
        }
        return block.timestamp + 30 days;
    }

    function getMaoTokenAddress() external view returns (address) {
        return address(maoToken);
    }

    function getTotalStaked() external view returns (uint256) {
        return totalTokenStaked;
    }

    function getYearlyAPY() external view returns (uint16) {
        return yearlyAPY;
    }

    function getStackedLengthOfUser(address _user) external view returns (uint256) {
        return stackedCount[_user];
    }

    function getStakedDataOfUser(address _user, uint256 _index) external view returns (Staked memory) {
        return s_balances[_user][_index];
    }

    function getRewadsLockIn() external view returns (uint256) {
        return rewardLockIn;
    }

    /*//////////////////////////////////////////////////////////////
                             SET FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function setYearlyAPY(uint16 _yearlyAPY) external onlyOwner {
        yearlyAPY = _yearlyAPY;
    }

    function setMaoTokenAddress(address _maoToken) external onlyOwner {
        maoToken = IERC20(_maoToken);
    }

    function setRewardLockIn(uint16 _rewardLockIn) external onlyOwner {
        rewardLockIn = _rewardLockIn;
    }

    /*//////////////////////////////////////////////////////////////
                             OTHER FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function stakeToken(uint256 _amount, Days _lockIn) external moreThanZero(_amount) isValidLockin(_lockIn) {
        // Check user balance
        if (maoToken.balanceOf(msg.sender) < _amount) {
            revert MAOSTAKIN_Staking_InsufficientFunds();
        }

        // Transfer tokens
        bool success = maoToken.transferFrom(msg.sender, address(this), _amount);
        if (!success) {
            revert MAOSTAKIN_Staking_TransferFailed();
        }

        // Add to balances
        s_balances[msg.sender].push(
            Staked({
                stakedAmount: _amount,
                timestamp: block.timestamp,
                lockInTimestamp: getLockinTimeStamp(_lockIn),
                rewardAmount: 0,
                claimRewards: 0,
                claimTimestamp: 0
            })
        );
        stackedCount[msg.sender] += 1;
        // Update total
        totalTokenStaked += _amount;
    }

    function unStakeToken(uint256 index) external nonReentrant {
        uint256 balanceLength = s_balances[msg.sender].length;

        if (index >= balanceLength) {
            revert MAOSTAKIN_Staking_InvalidIndex();
        }

        Staked storage staked = s_balances[msg.sender][index];
        uint256 currentTime = block.timestamp;
        uint256 timeStaked = currentTime - staked.timestamp;
        if (staked.stakedAmount == 0) {
            revert MAOSTAKIN_Staking_InvalidStakedAmount();
        }

        if (timeStaked < staked.lockInTimestamp) {
            revert MAOSTAKIN_Staking_UnStaking_TooSoon();
        }

        uint256 rewards = (staked.stakedAmount * yearlyAPY * timeStaked) / (100 * 365 days);
        uint256 totalAmount = staked.stakedAmount + rewards - staked.claimRewards;

        if (maoToken.balanceOf(address(this)) < totalAmount) {
            revert MAOSTAKIN_Staking_InsufficientFunds();
        }

        s_balances[msg.sender][index] = s_balances[msg.sender][stackedCount[msg.sender] - 1];
        s_balances[msg.sender].pop();
        stackedCount[msg.sender] -= 1;
        totalTokenStaked -= staked.stakedAmount;

        maoToken.approve(msg.sender, totalAmount);
        bool success = maoToken.transfer(msg.sender, totalAmount);
        if (!success) {
            revert MAOSTAKIN_Staking_TransferFailed();
        }
    }

    function claimRewards(uint256 index) external nonReentrant {
        Staked storage staked = s_balances[msg.sender][index];
        uint256 currentTime = block.timestamp;
        uint256 timeStaked = currentTime - staked.timestamp;
        if (staked.stakedAmount == 0) {
            revert MAOSTAKIN_Staking_InvalidStakedAmount();
        }

        if (timeStaked < staked.timestamp + rewardLockIn) {
            revert MAOSTAKIN_Staking_Claiming_TooSoon();
        }

        if (timeStaked != 0) {
            uint256 rewards = (staked.stakedAmount * yearlyAPY * timeStaked) / (100 * 365 days);
            uint256 unClaimedRewards = rewards - staked.claimRewards;

            if (unClaimedRewards == 0) {
                revert MAOSTAKIN_Staking_InsufficientRewards();
            }

            if (maoToken.balanceOf(address(this)) < unClaimedRewards) {
                revert MAOSTAKIN_Staking_InsufficientFunds();
            }

            staked.claimRewards += unClaimedRewards;
            staked.claimTimestamp = block.timestamp;

            maoToken.approve(msg.sender, unClaimedRewards);
            bool success = maoToken.transfer(msg.sender, unClaimedRewards);
            if (!success) {
                revert MAOSTAKIN_Staking_TransferFailed();
            }
        }
    }

    function withdrawRemainingTokens() external onlyOwner {
        uint256 tokenBalance = maoToken.balanceOf(address(this));
        if (tokenBalance <= 0) {
            revert MAOSTAKIN_NO_BALANCE_TO_WITHDRAW();
        }

        maoToken.approve(address(this), tokenBalance);

        bool success = maoToken.transferFrom(address(this), owner(), tokenBalance);

        if (!success) {
            revert MAOSTAKIN_WITHDRAW_FAILED();
        }
    }

    receive() external payable {}
}