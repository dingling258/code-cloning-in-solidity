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

// File: contracts/paymentHandler.sol


pragma solidity ^0.8.20;



contract paymentHandler is Ownable, ReentrancyGuard {

    address public fundsHandler;
    uint public totalMinted;

    //mappings
    mapping(uint => uint) public tierLeftover;
    mapping (uint => uint) public tierMaxSupply;
    mapping(uint => uint) public tierToPrice;
    mapping (address => uint) public userMinted;
    mapping (address => uint) public rewardsEarned;
    mapping(address => mapping(uint=> uint)) public userTierLeftover;
    mapping(address => string) public referralCodes;
    mapping(string => address) public codeToAddress;
    mapping (address => bool) public isInitialized;
    
    //events
    event paymentReceived(address indexed minter, uint256 amount, uint quantity, string refCode);
    event Refer(address indexed referrer, address indexed referee, uint tokenId, uint referralRewards);

    constructor(address initialOwner) 
        Ownable(initialOwner) {}
    

    function mint(uint quantity, string memory refCode) public payable nonReentrant {
        
        if(!isInitialized[msg.sender]){
            initializeUser(msg.sender);
        }
        require(msg.value == calcPrice(quantity, msg.sender, refCode), "Low value sent");
        uint finalPayment = msg.value;

        if (codeToAddress[refCode] != address(0)) {
            address referrer = codeToAddress[refCode];
            uint referRewards = msg.value * 10 / 100;
            finalPayment = finalPayment * 90 / 100;
            (bool referSuccess, ) = payable(referrer).call{value: referRewards}("");
            require(referSuccess, "Payment failed");
            rewardsEarned[referrer]+= referRewards;
            emit Refer(referrer, msg.sender, quantity, referRewards);
        }

        (bool success, ) = payable(fundsHandler).call{value: finalPayment}("");
        require(success, "Payment failed");
        deductMint(quantity,msg.sender);
        userMinted[msg.sender] += quantity;
        totalMinted += quantity;
        emit paymentReceived( msg.sender, finalPayment, quantity, refCode );
    }

    // Core logic set functions
    function setTiers(uint tier, uint totalAllocated, uint priceTier) external onlyOwner {
        require(tier >0 && tier <= 15 && priceTier >= 0.075 ether);
        tierLeftover[tier] = totalAllocated;
        tierMaxSupply[tier] = totalAllocated;
        tierToPrice[tier] = priceTier;
    }

    function setReferralCode(string[] memory code, address[] memory wallet) external  onlyOwner {
        require(code.length == wallet.length);
        for (uint i = 0; i< code.length; i++) {
            referralCodes[wallet[i]] = code[i];
            codeToAddress[code[i]] = wallet[i];
        }
    }

    function setFundsHandler(address _newFundsHandler) external onlyOwner{
        require(_newFundsHandler != address(0), "Invalid address");
        fundsHandler = _newFundsHandler;
    }
    
    //internal functions
    function initializeUser(address userToInit) internal {
        require(!isInitialized[userToInit]);
        for(uint i=1; i<=15; i++) {
            userTierLeftover[userToInit][i] = i;
            if(i == 5) {
                userTierLeftover[userToInit][i] = 0;
            }
        }
        isInitialized[userToInit] = !isInitialized[userToInit];
    }

    function deductMint(uint amount, address minter) internal {
        require(isInitialized[minter]);
        require(maxMintable(minter) >= amount);
        uint remAmount = amount;   
        for (uint256 i = 1; i <= 15; i++) {
            if(tierLeftover[i] >= userTierLeftover[minter][i] ) {
                if(remAmount >= userTierLeftover[minter][i]) {
                    tierLeftover[i] -= userTierLeftover[minter][i];
                    remAmount -= userTierLeftover[minter][i];
                    userTierLeftover[minter][i] = 0;
                }
                else{
                    userTierLeftover[minter][i] -= remAmount;
                    tierLeftover[i] -= remAmount;
                    remAmount = 0;
                    break;
                }
            }
            else {
                userTierLeftover[minter][i] -= tierLeftover[i];
                
                remAmount -= tierLeftover[i];
                tierLeftover[i] = 0;
            }
        }
    }

    

    

    //view functions
    function calcPrice(uint amount, address minter, string memory refCode) public view returns (uint) {
        require(isInitialized[minter]);
        require(maxMintable(minter) >= amount);
        uint price;
        uint remAmount = amount;
        uint finalPrice;    
        for (uint256 i = 1; i <= 15; i++) {
            
            if(tierLeftover[i] >= userTierLeftover[minter][i] ) {
                if(remAmount >= userTierLeftover[minter][i]) {
                    price += tierToPrice[i] * userTierLeftover[minter][i];
                    remAmount -= userTierLeftover[minter][i];
                }
                
                else {
                    price += tierToPrice[i] * remAmount;
                    remAmount = 0;
                    break;
                }

            }
            else {
                price += tierToPrice[i] * (tierLeftover[i]);
                remAmount -= tierLeftover[i];
            }
        }
        finalPrice = price;
        if(codeToAddress[refCode] != address(0)) {
            finalPrice = finalPrice * 90 / 100;
        }
        return finalPrice;
    }

    function maxMintable(address userToCheck) public view returns(uint) {
        uint maxMint;
        if (!isInitialized[userToCheck]) {
            for(uint i = 1; i<= 15; i++) {
                if(tierLeftover[i]>=i) {
                    maxMint += i;
                }
                else {
                    maxMint += tierLeftover[i];
                }
            }
        }
        else {
            for(uint i = 1; i<= 15; i++) {
                if(userTierLeftover[userToCheck][i] > tierLeftover[i]) {
                    maxMint += tierLeftover[i];
                }
                else{
                    maxMint += userTierLeftover[userToCheck][i]; 
                }
            }
        }
        return maxMint;
    }

}