// File: @openzeppelin\contracts\utils\Context.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;
// OpenZeppelin Contracts (last updated v4.9.4) (utils/Context.sol)

pragma solidity ^0.8.0;

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

// File: @openzeppelin\contracts\access\Ownable.sol

// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

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

// File: contracts\RaffleContractV1.sol


pragma solidity ^0.8.6;
contract RaffleContractV1 is Ownable {

    // Raffle enabled / disabled
    bool private _enabled;

    // Ticket costs
    uint256 private _wCost;
    uint256 private _mCost;

    // Tracking
    uint256 private _wRaffleId;
    uint256 private _mRaffleId;

    // Admin
    address private _admin;

    // Events
    event TicketsPurchased(address wallet, uint256 purchase, uint256 wRaffleId, uint8 weeklyCount, uint256 weeklyTickets, uint256 mRaffleId, uint8 monthlyCount, uint256 monthlyTickets);

    modifier adminOnly() {
        require(msg.sender == owner() || msg.sender == _admin);
        _;
    }

    // Get raffle info
    function getInfo() public view  returns (bool, uint256, uint256) {
        return (_enabled, _wRaffleId, _mRaffleId);
    }

    // Get active ticket costs
    function getTicketCosts() public view  returns (uint256, uint256) {
        return (_wCost, _mCost);
    }

    // Calculate cost
    function getTicketsCost(uint256 weekly, uint256 monthly) public view  returns (uint256) {
        return _wCost * weekly + _mCost * monthly;
    }

    // Enabled / disable the raffle
    function setEnabled(bool enableRaffle) external adminOnly {
        _enabled = enableRaffle;
    }

    // Set the ids
    function setRaffleIds(uint256 wRaffleId, uint256 mRaffleId) external adminOnly {
        if(wRaffleId != 0) {
            _wRaffleId = wRaffleId;
        }
        
        if(mRaffleId != 0) {
            _mRaffleId = mRaffleId;
        }
    }

    // Set prices
    function setPrices(uint256 wCost, uint256 mCost) external adminOnly {
        require(wCost > 0, 'NA1');
        require(mCost > 0, 'NA2');
        _wCost = wCost;
        _mCost = mCost;
    }

    // Get the eth out
    function retrieve(address sendTo, uint256 amount) external adminOnly {
        payable(sendTo).transfer(amount);
    }

    // Sets the admin
    function updateAdmin(address admin) external onlyOwner {
        _admin = admin;
    }

    // Purchase ticket(s)
    function purchaseTickets(address wallet, uint8 weeklyCount, uint256 weeklyTickets, uint8 monthlyCount, uint256 monthlyTickets) external payable {
        require(_enabled, 'NA1');
        require(weeklyCount > 0 || monthlyCount > 0, 'NA2');
        require(weeklyCount < 11 && monthlyCount < 11, 'NA3');

        uint256 cost = getTicketsCost(weeklyCount, monthlyCount);
        require(msg.value == cost, "NA4");

        emit TicketsPurchased(wallet, msg.value, _wRaffleId, weeklyCount, weeklyTickets, _mRaffleId, monthlyCount, monthlyTickets);
    }


     receive() external payable {}
}