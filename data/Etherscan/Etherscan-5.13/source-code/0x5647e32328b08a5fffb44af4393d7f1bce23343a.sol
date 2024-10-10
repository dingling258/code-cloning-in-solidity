// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

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
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

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
}

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

contract TokenVestingSTEAK is IERC20, Context, ReentrancyGuard {
    IERC20 public constant tokenAddress =
        IERC20(0xC4c244F1dbCA07083feE35220D2169957c275e68);
    struct VestingSchedule {
        bool initialized;
        address beneficiary;
        uint256 cliff;
        uint256 start;
        uint256 duration;
        uint256 slicePeriodSeconds;
        uint256 amountTotal;
        uint256 released;
    }

    bytes32[] private _vestingSchedulesIds;
    uint256 private _totalSupply;
    mapping(address => uint256) private _holdersVestingCount;
    mapping(bytes32 => VestingSchedule) private _vestingSchedules;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    event TokensReleased(address indexed beneficiary, uint256 amount);
    event VestingScheduleCreated(
        address indexed beneficiary,
        uint256 cliff,
        uint256 start,
        uint256 duration,
        uint256 slicePeriodSeconds,
        uint256 amount
    );

    modifier onlyIfBeneficiaryExists(address beneficiary) {
        require(
            _holdersVestingCount[beneficiary] > 0,
            "TokenVestingSTEAK: INVALID Beneficiary Address! no vesting schedule exists for that beneficiary"
        );
        _;
    }

    constructor() {}

    function name() external pure returns (string memory) {
        return "Vested STEAK";
    }

    function symbol() external pure returns (string memory) {
        return "vSTEAK";
    }

    function decimals() external pure returns (uint8) {
        return 18;
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function getCurrentTime() external view returns (uint256) {
        return block.timestamp;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(_msgSender(), spender, amount);

        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(
            owner != address(0),
            "TokenVestingSTEAK: approve from the zero address"
        );
        require(
            spender != address(0),
            "TokenVestingSTEAK: approve to the zero address"
        );

        _allowances[owner][spender] = amount;

        emit Approval(owner, spender, amount);
    }

    function allowance(
        address owner,
        address spender
    ) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool) {
        require(
            allowance(sender, _msgSender()) >= amount,
            "TokenVestingSTEAK: insufficient allowance"
        );

        _approve(
            sender,
            _msgSender(),
            (allowance(sender, _msgSender()) - amount)
        );
        _transfer(sender, recipient, amount);

        return true;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);

        return true;
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(
            from != address(0),
            "TokenVestingSTEAK: transfer from the zero address"
        );
        require(
            to != address(0),
            "TokenVestingSTEAK: transfer to the zero address"
        );
        require(
            _balances[from] >= amount,
            "TokenVestingSTEAK: transfer amount exceeds balance"
        );

        _balances[from] -= amount;
        uint256 transferAmount = amount;

        uint256 newCliff;
        uint256 newStart;
        uint256 newDuration;
        VestingSchedule storage vestingSchedule;

        for (
            uint256 i = 0;
            i < getVestingSchedulesCountByBeneficiary(from);
            i++
        ) {
            vestingSchedule = _vestingSchedules[
                computeVestingScheduleIdForAddressAndIndex(from, i)
            ];
            (newCliff, newStart, newDuration) = _generateCSD(
                vestingSchedule.cliff,
                vestingSchedule.start,
                vestingSchedule.duration
            );
            uint256 remainingAmount = vestingSchedule.amountTotal -
                vestingSchedule.released;

            if (transferAmount <= remainingAmount) {
                vestingSchedule.amountTotal -= (transferAmount +
                    vestingSchedule.released);
                vestingSchedule.released = 0;
                vestingSchedule.cliff = newStart + newCliff;
                vestingSchedule.start = newStart;
                vestingSchedule.duration = newDuration;
                _totalSupply -= transferAmount;

                _createVestingSchedule(
                    to,
                    newStart,
                    newCliff,
                    newDuration,
                    vestingSchedule.slicePeriodSeconds,
                    transferAmount
                );

                break;
            } else {
                if (remainingAmount == 0) {
                    continue;
                }

                vestingSchedule.amountTotal = 0;
                vestingSchedule.released = 0;
                _totalSupply -= remainingAmount;
                transferAmount -= remainingAmount;

                _createVestingSchedule(
                    to,
                    newStart,
                    newCliff,
                    newDuration,
                    vestingSchedule.slicePeriodSeconds,
                    remainingAmount
                );
            }
        }

        emit Transfer(from, to, amount);
    }

    function _generateCSD(
        uint256 _cliff,
        uint256 _start,
        uint256 _duration
    ) private view returns (uint256, uint256, uint256) {
        uint256 newCliff;
        uint256 newStart;
        uint256 newDuration;

        uint256 oldCliff = _cliff - _start;

        uint256 passedCliff = 0;
        uint256 passedDuration = 0;

        if (block.timestamp < _start) {
            newCliff = oldCliff;
            newDuration = _duration;
        } else {
            if (block.timestamp < _cliff) {
                newCliff = _cliff - block.timestamp;
                newDuration = _duration;
                passedCliff = oldCliff - newCliff;
                passedDuration = 0;
            } else {
                newCliff = 0;
                passedCliff = oldCliff;
                passedDuration = block.timestamp - _cliff;

                if (passedDuration < _duration) {
                    newDuration = _duration - passedDuration;
                } else {
                    newDuration = 1;
                }
            }
        }
        newStart = _start + passedCliff + passedDuration;

        return (newCliff, newStart, newDuration);
    }

    function getVestingIdAtIndex(
        uint256 index
    ) external view returns (bytes32) {
        require(
            index < getVestingSchedulesCount(),
            "TokenVestingSTEAK: index out of bounds"
        );

        return _vestingSchedulesIds[index];
    }

    function getVestingSchedulesCountByBeneficiary(
        address _beneficiary
    ) public view returns (uint256) {
        return _holdersVestingCount[_beneficiary];
    }

    function getVestingScheduleByBeneficiaryAndIndex(
        address beneficiary,
        uint256 index
    )
        external
        view
        onlyIfBeneficiaryExists(beneficiary)
        returns (VestingSchedule memory)
    {
        require(
            index < _holdersVestingCount[beneficiary],
            "TokenVestingSTEAK: INVALID Vesting Schedule Index! no vesting schedule exists at this index for that beneficiary"
        );

        return
            getVestingSchedule(
                computeVestingScheduleIdForAddressAndIndex(beneficiary, index)
            );
    }

    function computeVestingScheduleIdForAddressAndIndex(
        address holder,
        uint256 index
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(holder, index));
    }

    function getVestingSchedule(
        bytes32 vestingScheduleId
    ) public view returns (VestingSchedule memory) {
        VestingSchedule storage vestingSchedule = _vestingSchedules[
            vestingScheduleId
        ];
        require(
            vestingSchedule.initialized == true,
            "TokenVestingSTEAK: INVALID Vesting Schedule ID! no vesting schedule exists for that id"
        );

        return vestingSchedule;
    }

    function createVestingSchedule(
        address _beneficiary,
        uint256 _start,
        uint256 _cliff,
        uint256 _duration,
        uint256 _slicePeriodSeconds,
        uint256 _amount
    ) external returns (bool) {
        require(
            tokenAddress.transferFrom(_msgSender(), address(this), _amount),
            "TokenVestingSTEAK: token STEAK transferFrom not succeeded"
        );
        _createVestingSchedule(
            _beneficiary,
            _start,
            _cliff,
            _duration,
            _slicePeriodSeconds,
            _amount
        );
        emit VestingScheduleCreated(
            _beneficiary,
            _cliff,
            _start,
            _duration,
            _slicePeriodSeconds,
            _amount
        );
        emit Transfer(address(0), _beneficiary, _amount);

        return true;
    }

    function _createVestingSchedule(
        address _beneficiary,
        uint256 _start,
        uint256 _cliff,
        uint256 _duration,
        uint256 _slicePeriodSeconds,
        uint256 _amount
    ) private {
        require(_duration > 0, "TokenVestingSTEAK: duration must be > 0");
        require(_amount > 0, "TokenVestingSTEAK: amount must be > 0");
        require(
            _slicePeriodSeconds >= 1,
            "TokenVestingSTEAK: slicePeriodSeconds must be >= 1"
        );

        bytes32 vestingScheduleId = computeNextVestingScheduleIdForHolder(
            _beneficiary
        );
        uint256 cliff = _start + _cliff;
        _vestingSchedules[vestingScheduleId] = VestingSchedule(
            true,
            _beneficiary,
            cliff,
            _start,
            _duration,
            _slicePeriodSeconds,
            _amount,
            0
        );
        _balances[_beneficiary] += _amount;
        _totalSupply += _amount;
        _vestingSchedulesIds.push(vestingScheduleId);
        _holdersVestingCount[_beneficiary]++;
    }

    function computeNextVestingScheduleIdForHolder(
        address holder
    ) private view returns (bytes32) {
        return
            computeVestingScheduleIdForAddressAndIndex(
                holder,
                _holdersVestingCount[holder]
            );
    }

    function _computeReleasableAmount(
        VestingSchedule memory vestingSchedule
    ) private view returns (uint256) {
        if (block.timestamp < vestingSchedule.cliff) {
            return 0;
        } else if (
            block.timestamp >= vestingSchedule.cliff + vestingSchedule.duration
        ) {
            return (vestingSchedule.amountTotal - vestingSchedule.released);
        } else {
            uint256 timeFromStart = block.timestamp - vestingSchedule.cliff;
            uint256 secondsPerSlice = vestingSchedule.slicePeriodSeconds;
            uint256 releaseableSlicePeriods = timeFromStart / secondsPerSlice;
            uint256 releaseableSeconds = releaseableSlicePeriods *
                secondsPerSlice;
            uint256 releaseableAmount = (vestingSchedule.amountTotal *
                releaseableSeconds) / vestingSchedule.duration;
            releaseableAmount -= vestingSchedule.released;

            return releaseableAmount;
        }
    }

    function claimFromAllVestings()
        external
        nonReentrant
        onlyIfBeneficiaryExists(_msgSender())
        returns (bool)
    {
        address beneficiary = _msgSender();
        uint256 vestingSchedulesCountByBeneficiary = getVestingSchedulesCountByBeneficiary(
                beneficiary
            );

        VestingSchedule storage vestingSchedule;
        uint256 totalReleaseableAmount = 0;
        uint256 i = 0;
        do {
            vestingSchedule = _vestingSchedules[
                computeVestingScheduleIdForAddressAndIndex(beneficiary, i)
            ];
            uint256 releaseableAmount = _computeReleasableAmount(
                vestingSchedule
            );
            vestingSchedule.released += releaseableAmount;

            totalReleaseableAmount += releaseableAmount;
            i++;
        } while (i < vestingSchedulesCountByBeneficiary);

        _totalSupply -= totalReleaseableAmount;
        _balances[beneficiary] -= totalReleaseableAmount;
        require(
            tokenAddress.transfer(beneficiary, totalReleaseableAmount),
            "TokenVestingSTEAK: token STEAK rewards transfer to beneficiary not succeeded"
        );

        emit TokensReleased(beneficiary, totalReleaseableAmount);
        emit Transfer(beneficiary, address(0), totalReleaseableAmount);

        return true;
    }

    function getVestingSchedulesCount() public view returns (uint256) {
        return _vestingSchedulesIds.length;
    }

    function getLastVestingScheduleForBeneficiary(
        address beneficiary
    )
        external
        view
        onlyIfBeneficiaryExists(beneficiary)
        returns (VestingSchedule memory)
    {
        return
            _vestingSchedules[
                computeVestingScheduleIdForAddressAndIndex(
                    beneficiary,
                    _holdersVestingCount[beneficiary] - 1
                )
            ];
    }

    function computeAllReleasableAmountForBeneficiary(
        address beneficiary
    ) external view returns (uint256) {
        uint256 vestingSchedulesCountByBeneficiary = getVestingSchedulesCountByBeneficiary(
                beneficiary
            );

        VestingSchedule memory vestingSchedule;
        uint256 totalReleaseableAmount = 0;
        uint256 i = 0;
        do {
            vestingSchedule = _vestingSchedules[
                computeVestingScheduleIdForAddressAndIndex(beneficiary, i)
            ];
            uint256 releaseableAmount = _computeReleasableAmount(
                vestingSchedule
            );

            totalReleaseableAmount += releaseableAmount;
            i++;
        } while (i < vestingSchedulesCountByBeneficiary);

        return totalReleaseableAmount;
    }
}