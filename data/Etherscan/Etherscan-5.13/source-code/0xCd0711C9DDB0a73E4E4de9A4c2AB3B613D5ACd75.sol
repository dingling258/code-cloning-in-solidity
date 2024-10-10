// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

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
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
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
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
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

interface IUniswapV2Locker {
    function transferLockOwnership(
        address _lpToken,
        uint256 _index,
        uint256 _lockID,
        address payable _newOwner
    ) external;

    struct TokenLock {
        uint256 lockDate; // the date the token was locked
        uint256 amount; // the amount of tokens still locked (initialAmount minus withdrawls)
        uint256 initialAmount; // the initial lock amount
        uint256 unlockDate; // the date the token can be withdrawn
        uint256 lockID; // lockID nonce per uni pair
        address owner;
    }

    function tokenLocks(
        address _lpToken,
        uint _index
    ) external view returns (TokenLock memory);
}

// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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

contract LiquifyEscrowV1 is Ownable {
    event EscrowCreated(
        address indexed owner,
        address indexed lpAddress,
        uint256 lockIndex,
        uint256 lockId,
        uint256 wantedWei,
        uint256 escrowIndex
    );

    event EscrowValidated(uint256 indexed escrowIndex);

    event EscrowBought(uint256 indexed escrowIndex, address indexed buyer);

    event EscrowCancelled(uint256 indexed escrowIndex);

    struct Escrow {
        uint256 escrowIndex;
        address owner;
        address buyer;
        address lpAddress;
        uint256 wantedWei;
        uint256 createdAt;
        uint256 lockId;
        uint256 lockIndex;
        bool isCancelled;
        bool isValidated;
    }

    IUniswapV2Locker public locker;
    Escrow[] public escrows;
    address[] public ownedLocks;

    constructor(address _locker) {
        locker = IUniswapV2Locker(_locker);
    }

    function getEscrows() public view returns (Escrow[] memory) {
        return escrows;
    }

    function setLocker(address _locker) public onlyOwner {
        locker = IUniswapV2Locker(_locker);
    }

    function createEscrow(
        address _lpAddress,
        uint256 _lockIndex,
        uint256 _lockId,
        uint256 _wantedWei
    ) public returns (uint256) {
        uint escrowIndex = escrows.length;

        Escrow memory escrow = Escrow({
            escrowIndex: escrowIndex,
            owner: msg.sender,
            buyer: address(0),
            lpAddress: _lpAddress,
            wantedWei: _wantedWei,
            createdAt: block.timestamp,
            lockId: _lockId,
            lockIndex: _lockIndex,
            isCancelled: false,
            isValidated: false
        });

        escrows.push(escrow);

        emit EscrowCreated(
            msg.sender,
            _lpAddress,
            _lockIndex,
            _lockId,
            _wantedWei,
            escrowIndex
        );

        return escrowIndex;
    }

    function validateEscrow(uint256 _escrowIndex) public {
        Escrow memory escrow = escrows[_escrowIndex];

        IUniswapV2Locker.TokenLock memory lock = locker.tokenLocks(
            escrow.lpAddress,
            escrow.lockIndex
        );

        require(lock.owner == address(this), "Invalid lock/Not your lock");

        escrows[_escrowIndex].isValidated = true;
        ownedLocks.push(escrow.lpAddress);

        emit EscrowValidated(_escrowIndex);
    }

    function buyEscrow(uint256 _escrowIndex) public payable {
        Escrow memory escrow = escrows[_escrowIndex];

        require(escrow.buyer == address(0), "Already bought");
        // require(escrow.owner != msg.sender, "Cannot buy your own escrow");
        require(escrow.isValidated == true, "Escrow is not validated");
        require(escrow.isCancelled == false, "Escrow is cancelled");
        require(msg.value == escrow.wantedWei, "Invalid wei amount");

        escrows[_escrowIndex].buyer = msg.sender;

        // Transfer the sent wei to the owner using call
        (bool success, ) = payable(escrow.owner).call{value: msg.value}("");
        require(success, "Transfer failed");

        // Transfer the lock to the buyer
        locker.transferLockOwnership(
            escrow.lpAddress,
            escrow.lockIndex,
            escrow.lockId,
            payable(msg.sender)
        );

        emit EscrowBought(_escrowIndex, msg.sender);
    }

    function cancelEscrow(uint256 _escrowIndex) public {
        Escrow memory escrow = escrows[_escrowIndex];

        require(escrow.owner == msg.sender, "Not your escrow");

        escrows[_escrowIndex].isCancelled = true;

        // Attempt to transfer the lock back to the owner
        locker.transferLockOwnership(
            escrow.lpAddress,
            escrow.lockIndex,
            escrow.lockId,
            payable(escrow.owner)
        );

        // Remove the lock from the ownedLocks array
        for (uint256 i = 0; i < ownedLocks.length; i++) {
            if (ownedLocks[i] == escrow.lpAddress) {
                ownedLocks[i] = ownedLocks[ownedLocks.length - 1];
                ownedLocks.pop();
                break;
            }
        }

        emit EscrowCancelled(_escrowIndex);
    }

    function adminEmergencyCancel(uint256 _escrowIndex) public onlyOwner {
        Escrow memory escrow = escrows[_escrowIndex];

        escrows[_escrowIndex].isCancelled = true;

        // Attempt to transfer the lock back to the owner
        locker.transferLockOwnership(
            escrow.lpAddress,
            escrow.lockIndex,
            escrow.lockId,
            payable(escrow.owner)
        );

        // Remove the lock from the ownedLocks array
        for (uint256 i = 0; i < ownedLocks.length; i++) {
            if (ownedLocks[i] == escrow.lpAddress) {
                ownedLocks[i] = ownedLocks[ownedLocks.length - 1];
                ownedLocks.pop();
                break;
            }
        }

        emit EscrowCancelled(_escrowIndex);
    }
}