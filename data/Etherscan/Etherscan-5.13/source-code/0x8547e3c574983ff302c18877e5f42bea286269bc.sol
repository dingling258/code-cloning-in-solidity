// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

/// @title $JOK Vesting
/// @author André Costa @ MyWeb3Startup.com

/**
 * @dev Interface of the ERC-20 standard as defined in the ERC.
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
 * @dev Interface for the optional metadata functions from the ERC-20 standard.
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

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

// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
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
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
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
 * @title JokVesting
 * @dev Smart contract for token vesting with customizable schedules.
 */
contract JokVesting is Ownable {
    // Struct to represent a vesting schedule
    struct VestingSchedule {
        uint256[] tokensPerCliff;
        uint256[] cliffs;
        uint lastCliffClaimed;
    }

    // Mapping to store vesting schedules for different beneficiaries
    mapping(address => VestingSchedule) private vestingSchedules;

    // Address of the ERC-20 token contract
    address public tokenContract;

    // Constructor to initialize the contract with the ERC-20 token address
    constructor() {
        tokenContract = 0xA728Aa2De568766E2Fa4544Ec7A77f79c0bf9F97; // MAINNET

        /*
        (35% of tokens) released every month for 2 years (1.46% per month) to go to treasury wallet. 271,950,000,000 tokens
        */
        /// TREASURY
        vestingSchedules[0xe13F146B009d303D511c23596EA3827F7d1e49dc].tokensPerCliff = [
            11331250000 * 10 ** 18,
            11331250000 * 10 ** 18,
            11331250000 * 10 ** 18,
            11331250000 * 10 ** 18,
            11331250000 * 10 ** 18,
            11331250000 * 10 ** 18,
            11331250000 * 10 ** 18,
            11331250000 * 10 ** 18,
            11331250000 * 10 ** 18,
            11331250000 * 10 ** 18,
            11331250000 * 10 ** 18,
            11331250000 * 10 ** 18,
            11331250000 * 10 ** 18,
            11331250000 * 10 ** 18,
            11331250000 * 10 ** 18,
            11331250000 * 10 ** 18,
            11331250000 * 10 ** 18,
            11331250000 * 10 ** 18,
            11331250000 * 10 ** 18,
            11331250000 * 10 ** 18,
            11331250000 * 10 ** 18,
            11331250000 * 10 ** 18,
            11331250000 * 10 ** 18
        ];
        vestingSchedules[0xe13F146B009d303D511c23596EA3827F7d1e49dc].cliffs = [
            block.timestamp + 30 days,
            block.timestamp + 60 days,
            block.timestamp + 90 days,
            block.timestamp + 120 days,
            block.timestamp + 150 days,
            block.timestamp + 180 days,
            block.timestamp + 210 days,
            block.timestamp + 240 days,
            block.timestamp + 270 days,
            block.timestamp + 300 days,
            block.timestamp + 330 days,
            block.timestamp + 360 days,
            block.timestamp + 390 days,
            block.timestamp + 420 days,
            block.timestamp + 450 days,
            block.timestamp + 480 days,
            block.timestamp + 510 days,
            block.timestamp + 540 days,
            block.timestamp + 570 days,
            block.timestamp + 600 days,
            block.timestamp + 630 days,
            block.timestamp + 660 days,
            block.timestamp + 690 days,
            block.timestamp + 720 days
        ];
    }

    // VESTING

    /**
     * @dev Get the vesting schedule for a beneficiary.
     * @param beneficiary Address of the beneficiary.
     * @return Vesting schedule for the beneficiary.
     */
    function getVestingSchedule(address beneficiary) external view returns (VestingSchedule memory) {
        return vestingSchedules[beneficiary];
    }

    /**
     * @dev Add vesting schedules for multiple receivers.
     * @param receivers Addresses of the receivers.
     * @param tokens Array of token amounts per cliff.
     * @param cliffs Array of timestamps representing cliffs.
     */
    function addVestingSchedule(
        address[] memory receivers,
        uint256[] memory tokens,
        uint256[] memory cliffs
    ) external onlyOwner {
        require(tokens.length == cliffs.length, "Array sizes do not match!");

        for (uint256 i = 0; i < receivers.length; i++) {
            require(
                vestingSchedules[receivers[i]].tokensPerCliff.length == 0 ||
                    vestingSchedules[receivers[i]].lastCliffClaimed == vestingSchedules[receivers[i]].cliffs.length,
                "Vesting Schedule already active!"
            );

            vestingSchedules[receivers[i]].tokensPerCliff = tokens;
            vestingSchedules[receivers[i]].cliffs = cliffs;
        }
    }

    /**
     * @dev Check the amount of vested tokens available for a beneficiary.
     * @param beneficiary Address of the beneficiary.
     * @return Amount of vested tokens available.
     */
    function vestedTokensAvailable(address beneficiary) external view returns (uint256) {
        (uint256 availableTokens, ) = vestedTokensAvailable_(beneficiary);
        return availableTokens;
    }

    /**
     * @dev Internal function to calculate vested tokens and the last cliff claimed for a beneficiary.
     * @param beneficiary Address of the beneficiary.
     * @return availableTokens Amount of vested tokens available.
     * @return lastCliff Last cliff claimed.
     */
    function vestedTokensAvailable_(address beneficiary) internal view returns (uint256 availableTokens, uint lastCliff) {
        VestingSchedule memory vestingSchedule_ = vestingSchedules[beneficiary];
        for (uint i = vestingSchedule_.lastCliffClaimed; i < vestingSchedule_.cliffs.length; i++) {
            if (block.timestamp >= vestingSchedule_.cliffs[i]) {
                availableTokens += vestingSchedule_.tokensPerCliff[i];
            } else {
                lastCliff = i;
                break;
            }
        }
    }

    /**
     * @dev Claim vested tokens for the caller.
     */
    function claimVestedTokens() external {
        address claimer = msg.sender;
        (uint256 availableTokens, uint lastCliff) = vestedTokensAvailable_(claimer);
        require(availableTokens > 0, "No tokens available to claim!");

        vestingSchedules[claimer].lastCliffClaimed = lastCliff;
        require(IERC20(tokenContract).transfer(claimer, availableTokens), "Unsuccessful Transfer!");
    }

    // ADMIN

    /**
     * @dev Set the ERC-20 token contract address.
     * @param newContract New ERC-20 token contract address.
     */
    function setTokenContract(address newContract) external onlyOwner {
        require(newContract != address(0), "Invalid Address!");
        tokenContract = newContract;
    }

    /**
     * @dev Withdraw ERC-20 tokens from the contract.
     * @param tokenAddress Address of the ERC-20 token.
     * @param recipient Address to receive the withdrawn tokens.
     * @param amount Amount of tokens to withdraw.
     */
    function withdraw(address tokenAddress, address recipient, uint256 amount) external onlyOwner {
        require(recipient != address(0), "Invalid Address!");

        require(IERC20(tokenAddress).transfer(recipient, amount), "Token transfer failed");
    }
}