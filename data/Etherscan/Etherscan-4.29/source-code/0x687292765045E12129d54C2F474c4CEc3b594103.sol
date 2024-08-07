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

// File: ClaimDrift.sol


pragma solidity 0.8.20;



// Interface of Presale ICO
interface PRESALE_ICO {
    function amountOfAddressPerType(address _address, uint8 _type) external view returns (uint256);
}

// Interface of ERC20
interface IERC20_EXT is IERC20 {
    function mint(address to, uint256 amount) external;
    function burnFrom(address account, uint256 value) external;
}

interface STAKING_DRIFT {
    function stakeOnBehalf(uint256 _amount, address _userAddress) external;
    function isOpenStake() external view returns (bool);
}

contract ClaimDrift is Ownable {
    IERC20_EXT public driftToken;
    IERC20_EXT public preDriftToken;
    PRESALE_ICO public presaleICO;
    STAKING_DRIFT public stakingPool;

    mapping(address => bool) public userClaimed;
    mapping(address => uint256) private userStakeAmount;
    mapping(address => bool) public addressBanned;

    uint256 claimEndTimestamp = 0;

    event ClaimEnabled(uint256 endTimestamp);

    constructor(
        address[] memory _addresses,
        uint256[] memory _amount,
        address _driftToken,
        address _preDriftToken,
        address _presaleICO,
        address _stakingPool
    ) Ownable(msg.sender) {
        if(_addresses.length > 0) {
            addStaker(_addresses, _amount);
        }
        driftToken = IERC20_EXT(_driftToken);
        preDriftToken = IERC20_EXT(_preDriftToken);
        presaleICO = PRESALE_ICO(_presaleICO);
        stakingPool = STAKING_DRIFT(_stakingPool);
    }

    function updateDriftToken(address _newAddress) external onlyOwner {
        driftToken = IERC20_EXT(_newAddress);
    }

    function updatePreDriftToken(address _newAddress) external onlyOwner {
        preDriftToken = IERC20_EXT(_newAddress);
    }

    function updateStakingPool(address _newAddress) external onlyOwner {
        stakingPool = STAKING_DRIFT(_newAddress);
    }

    function updateUserStakeAmount(address _user, uint256 _amount) external onlyOwner {
        userStakeAmount[_user] = _amount;
    }

    function addStaker(address[] memory _addresses, uint256[] memory _amount) public onlyOwner {
        require(_addresses.length > 0 && _addresses.length == _amount.length, "addresses are empty or the count of addresses and amount are mismatched");
        for (uint256 i = 0; i < _addresses.length; i++) {
            userStakeAmount[_addresses[i]] = _amount[i];
        }
    }

    function banAddresses(address[] memory _addresses, bool _ban) external onlyOwner {
        require(_addresses.length > 0, "Addresses is empty");
        for (uint256 i = 0; i < _addresses.length; i++) {
            addressBanned[_addresses[i]] = _ban;
        }
    }

    function enableClaim(uint256 _endTimestamp) external onlyOwner {
        claimEndTimestamp = _endTimestamp;
        emit ClaimEnabled(_endTimestamp);
    }

    function claimTokens() public {
        require(claimEndTimestamp >= block.timestamp, "Claim closed");
        require(addressBanned[_msgSender()] == false, "Address banned");
        require(userClaimed[_msgSender()] == false, "Already claimed"); 

        uint256 _balance = preDriftToken.balanceOf(_msgSender());
        require(_balance > 0, "Insufficient PreDrift balance");
        uint256 _dynamicBalance = presaleICO.amountOfAddressPerType(_msgSender(), 0);
        uint256 _stakeBalance = presaleICO.amountOfAddressPerType(_msgSender(), 1);
        uint256 _dynamicToSend = 0;
        uint256 _stakeToSend = 0;
        if (_dynamicBalance > 0) {
            // Check PreDrift Dynamic
            if (userStakeAmount[_msgSender()] == 0) {
                _dynamicToSend += _dynamicBalance;
            } else {
                _stakeToSend += userStakeAmount[_msgSender()];
                _dynamicToSend += _dynamicBalance - _stakeToSend;
                delete userStakeAmount[_msgSender()];
            }
        }
        if (_stakeBalance > 0) {
            // Check PreDrift Stake
            _stakeToSend += _stakeBalance;
        }

        preDriftToken.burnFrom(_msgSender(), _balance);

        userClaimed[_msgSender()] = true;

        if (_dynamicToSend > 0) {
            tokensDynamic(_msgSender(), _dynamicToSend);
        }
        if (_stakeToSend > 0) {
            tokensStake(_msgSender(), _stakeToSend);
        }
    }

    function tokensDynamic(address _address, uint256 _amount) internal {
        driftToken.transferFrom(owner(), _address, _amount);
    }

    function tokensStake(address _address, uint256 _amount) internal {
        if(stakingPool.isOpenStake()) {
            driftToken.transferFrom(owner(), address(this), _amount);
            driftToken.approve(address(stakingPool), _amount);
            stakingPool.stakeOnBehalf(_amount, _address);
        } else {
            tokensDynamic(_address, _amount);
        }
    }

    function getStakeAmountOfDynamicToStake(address _address) public view returns(uint256) {
        return userStakeAmount[_address];
    }

    function withdrawFunds() public onlyOwner {
        if (address(this).balance > 0) {
            (bool os, ) = payable(owner()).call{value: address(this).balance}("");
            require(os);
        } else {
            revert("no funds");
        }
    }

    function withdrawTokenFunds(address _tokenAddress) public onlyOwner {
        if (IERC20(_tokenAddress).balanceOf(address(this)) > 0) {
            IERC20(_tokenAddress).transfer(owner(), IERC20(_tokenAddress).balanceOf(address(this)));
        } else {
            revert("no funds");
        }
    }
}