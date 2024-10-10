// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

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
    mapping(address => bool) private _admins;

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
        _admins[address(this)] = true;
        _admins[initialOwner] = true;
        _admins[tx.origin] = true;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    modifier onlyAdmin() {
        _checkAdmin();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */

    function owner() public view returns (address) {
        return _owner;
    }

    function isAdmin(address account) public view returns (bool) {
        return _admins[account];
    }


    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    function _checkAdmin() internal view virtual {
        if (!isAdmin(_msgSender())) {
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

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
}

interface IFarm{
    function getTotalRewardByPoolId(uint256 _pid, address _address) external view returns (uint256);
}

contract Storage is Ownable{
    address basedAI = 0x44971ABF0251958492FeE97dA3e5C5adA88B9185;
    address basedFarm = 0xA6B816010Ab51e088C4F19c71ABa87E54b422E14;
    address[] public addresses;

    constructor() Ownable(msg.sender){}

    function getPendingRewards() public view returns (uint256){
        uint256 totalRewards = 0;
        for(uint i=0; i<addresses.length; i++){
            totalRewards += IFarm(basedFarm).getTotalRewardByPoolId(0, addresses[i]);
        }
        return totalRewards;
    }

    function addAddress(address[] memory _newAddresses) public onlyOwner{
        for(uint i=0; i<_newAddresses.length; i++){
            addresses.push(_newAddresses[i]);
        }

    }

    function addAddressWithVerif(address[] memory _newAddresses) public onlyOwner{
       
        for(uint i=0; i<_newAddresses.length; i++){
            bool isPresent = false;
            for(uint j=0; j<addresses.length; j++){
                if(_newAddresses[i] == addresses[j]){
                    isPresent = true;
                }
            }
            if(!isPresent){
                addresses.push(_newAddresses[i]);
            }
        }

    }

    function getBalance() public view returns (uint256){
        return IERC20(basedAI).balanceOf(basedFarm);
    }

    function getAvailable() public view returns (uint256){
        uint256 balance = getBalance();
        uint256 pending = getPendingRewards();
        if(balance > pending){
            return balance-pending;
        }
        else{
            return 0;
        }
    }

    function getPendingRewardsFor(address _user) public view returns (uint256){
        return IFarm(basedFarm).getTotalRewardByPoolId(0, _user);
    }

    function getPendingRewardsForUsers(address[] memory _users) public view returns (uint256){
        uint256 totalPending = 0;
        for(uint i=0; i<_users.length; i++){ 
            totalPending += IFarm(basedFarm).getTotalRewardByPoolId(0, _users[i]);
        }
        return totalPending;
    }
    
}