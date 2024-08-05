// File: @chainlink/contracts/src/v0.8/vrf/interfaces/VRFV2WrapperInterface.sol


pragma solidity ^0.8.0;

interface VRFV2WrapperInterface {
  /**
   * @return the request ID of the most recent VRF V2 request made by this wrapper. This should only
   * be relied option within the same transaction that the request was made.
   */
  function lastRequestId() external view returns (uint256);

  /**
   * @notice Calculates the price of a VRF request with the given callbackGasLimit at the current
   * @notice block.
   *
   * @dev This function relies on the transaction gas price which is not automatically set during
   * @dev simulation. To estimate the price at a specific gas price, use the estimatePrice function.
   *
   * @param _callbackGasLimit is the gas limit used to estimate the price.
   */
  function calculateRequestPrice(uint32 _callbackGasLimit) external view returns (uint256);

  /**
   * @notice Estimates the price of a VRF request with a specific gas limit and gas price.
   *
   * @dev This is a convenience function that can be called in simulation to better understand
   * @dev pricing.
   *
   * @param _callbackGasLimit is the gas limit used to estimate the price.
   * @param _requestGasPriceWei is the gas price in wei used for the estimation.
   */
  function estimateRequestPrice(uint32 _callbackGasLimit, uint256 _requestGasPriceWei) external view returns (uint256);
}

// File: @chainlink/contracts/src/v0.8/shared/interfaces/LinkTokenInterface.sol


pragma solidity ^0.8.0;

interface LinkTokenInterface {
  function allowance(address owner, address spender) external view returns (uint256 remaining);

  function approve(address spender, uint256 value) external returns (bool success);

  function balanceOf(address owner) external view returns (uint256 balance);

  function decimals() external view returns (uint8 decimalPlaces);

  function decreaseApproval(address spender, uint256 addedValue) external returns (bool success);

  function increaseApproval(address spender, uint256 subtractedValue) external;

  function name() external view returns (string memory tokenName);

  function symbol() external view returns (string memory tokenSymbol);

  function totalSupply() external view returns (uint256 totalTokensIssued);

  function transfer(address to, uint256 value) external returns (bool success);

  function transferAndCall(address to, uint256 value, bytes calldata data) external returns (bool success);

  function transferFrom(address from, address to, uint256 value) external returns (bool success);
}

// File: @chainlink/contracts/src/v0.8/vrf/VRFV2WrapperConsumerBase.sol


pragma solidity ^0.8.0;



/** *******************************************************************************
 * @notice Interface for contracts using VRF randomness through the VRF V2 wrapper
 * ********************************************************************************
 * @dev PURPOSE
 *
 * @dev Create VRF V2 requests without the need for subscription management. Rather than creating
 * @dev and funding a VRF V2 subscription, a user can use this wrapper to create one off requests,
 * @dev paying up front rather than at fulfillment.
 *
 * @dev Since the price is determined using the gas price of the request transaction rather than
 * @dev the fulfillment transaction, the wrapper charges an additional premium on callback gas
 * @dev usage, in addition to some extra overhead costs associated with the VRFV2Wrapper contract.
 * *****************************************************************************
 * @dev USAGE
 *
 * @dev Calling contracts must inherit from VRFV2WrapperConsumerBase. The consumer must be funded
 * @dev with enough LINK to make the request, otherwise requests will revert. To request randomness,
 * @dev call the 'requestRandomness' function with the desired VRF parameters. This function handles
 * @dev paying for the request based on the current pricing.
 *
 * @dev Consumers must implement the fullfillRandomWords function, which will be called during
 * @dev fulfillment with the randomness result.
 */
abstract contract VRFV2WrapperConsumerBase {
  // solhint-disable-next-line chainlink-solidity/prefix-immutable-variables-with-i
  LinkTokenInterface internal immutable LINK;
  // solhint-disable-next-line chainlink-solidity/prefix-immutable-variables-with-i
  VRFV2WrapperInterface internal immutable VRF_V2_WRAPPER;

  /**
   * @param _link is the address of LinkToken
   * @param _vrfV2Wrapper is the address of the VRFV2Wrapper contract
   */
  constructor(address _link, address _vrfV2Wrapper) {
    LINK = LinkTokenInterface(_link);
    VRF_V2_WRAPPER = VRFV2WrapperInterface(_vrfV2Wrapper);
  }

  /**
   * @dev Requests randomness from the VRF V2 wrapper.
   *
   * @param _callbackGasLimit is the gas limit that should be used when calling the consumer's
   *        fulfillRandomWords function.
   * @param _requestConfirmations is the number of confirmations to wait before fulfilling the
   *        request. A higher number of confirmations increases security by reducing the likelihood
   *        that a chain re-org changes a published randomness outcome.
   * @param _numWords is the number of random words to request.
   *
   * @return requestId is the VRF V2 request ID of the newly created randomness request.
   */
  // solhint-disable-next-line chainlink-solidity/prefix-internal-functions-with-underscore
  function requestRandomness(
    uint32 _callbackGasLimit,
    uint16 _requestConfirmations,
    uint32 _numWords
  ) internal returns (uint256 requestId) {
    LINK.transferAndCall(
      address(VRF_V2_WRAPPER),
      VRF_V2_WRAPPER.calculateRequestPrice(_callbackGasLimit),
      abi.encode(_callbackGasLimit, _requestConfirmations, _numWords)
    );
    return VRF_V2_WRAPPER.lastRequestId();
  }

  /**
   * @notice fulfillRandomWords handles the VRF V2 wrapper response. The consuming contract must
   * @notice implement it.
   *
   * @param _requestId is the VRF V2 request ID.
   * @param _randomWords is the randomness result.
   */
  // solhint-disable-next-line chainlink-solidity/prefix-internal-functions-with-underscore
  function fulfillRandomWords(uint256 _requestId, uint256[] memory _randomWords) internal virtual;

  function rawFulfillRandomWords(uint256 _requestId, uint256[] memory _randomWords) external {
    // solhint-disable-next-line gas-custom-errors
    require(msg.sender == address(VRF_V2_WRAPPER), "only VRF V2 wrapper can fulfill");
    fulfillRandomWords(_requestId, _randomWords);
  }
}

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

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

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Context.sol


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

// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol


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

// File: LootPoolManager.sol



pragma solidity ^0.8.19;





/**
* @dev Pool Manager for LootPools
*/
contract LootPoolManager is Ownable, VRFV2WrapperConsumerBase{

    /*
    * @dev Chainlink VRF
    */
    VRFV2WrapperConsumerBase COORDINATOR;
    address immutable linkToken;
    mapping(uint256=>uint256) vrfRequests; // Request ID to awaiting poolId

    /*
    *   @dev This stores unused ERC20 assets after a pool is closed. Safe to withdraw tokenaddress => amount
    */
    mapping(address=>uint256) claimableERC20;

    /**
    *   @dev Struct for ERC20 Prize PoolData
    *   @param poolState is state of the pool means following; 0: InActive 1: Initialized, waiting for participant. 2: Can be executed. 3: Executed, waiting for VRF.
    *   4: VRF Received, prize claimable., 5:Disabled
    *   @param prizeAddress address of specific ERC20 token
    *   @param prizeAmount amount of prize
    *   @param ticketUnit Address of ERC20 token to be used as ticket unit to buy entry
    *   @param price of tickets in units of @param ticketUnit
    *   @param lastGame is a bool parameter that whether this pool self initialize after game or close.
    */
    struct LootPoolERC20{
        uint8 poolState;
        address prizeAddress;
        uint prizeAmount;  
        address ticketUnit;
        uint ticketPrice;
        uint maxParticipant;
        bool lastGame;
        address[] participants;
        address feeAddress;
    }

    /*
    * @dev List of ERC20 Prize Pools
    */
    mapping(uint=>LootPoolERC20) public pools;

    /*
    * @dev Index for pools
    */
    uint public poolIndex;

    

    /*************
    *   EVENTS   *
    *************/
    event poolCreated(address indexed prizeAddress, uint prizeAmount, address indexed  ticketUnit, uint ticketPrice, uint maxParticipant, uint time);
    event userJoinedPool(address indexed user, uint indexed poolId, uint ticketAmount, uint time);
    event poolEnded(address indexed user, uint indexed poolId, uint time);
    event winnerOfPool(address indexed winner, uint indexed poolId, address indexed prizeToken, uint prizeAmount, uint proof, uint time);

    constructor(address _linkAddress, address _wrapperAddress)Ownable(msg.sender)VRFV2WrapperConsumerBase(_linkAddress, _wrapperAddress)
    {
        linkToken = _linkAddress;
    }

    /*
    * @dev Creates a new ERC20 pool
    */
    function createERC20Pool(address _prizeAddress, uint _prizeAmount, address _ticketUnit, uint _ticketPrice, uint _maxParticipant, bool _lastgame, address _feeAddress) external payable onlyOwner{
        require(IERC20(_prizeAddress).transferFrom(msg.sender, address(this), _prizeAmount), "Could not transfer Prize Fund.");

        address[] memory partAdd;
        LootPoolERC20 memory newPool = LootPoolERC20(1, _prizeAddress, _prizeAmount,_ticketUnit, _ticketPrice, _maxParticipant, _lastgame, partAdd, _feeAddress);
        
        // Prize fund received, Initializing ERC20LootPool.
        pools[poolIndex] = newPool;

        poolIndex++;

        // Pool initialized.
        emit poolCreated(_prizeAddress, _prizeAmount, _ticketUnit, _ticketPrice, _maxParticipant, block.timestamp);
    }

    /*
    * @dev User participates a pool
    */
    function joinERC20Pool(uint _poolID, uint _ticketAmount) public payable{
        require(_ticketAmount > 0, "Invalid");
        require(pools[_poolID].poolState == 1, "Pool is not available"); // Is pool at participate phase
        require(pools[_poolID].participants.length + _ticketAmount <= pools[_poolID].maxParticipant, "Allready filled");

        // Receive ticket price
        require(IERC20(pools[_poolID].ticketUnit).transferFrom(msg.sender, address(this), pools[_poolID].ticketPrice * _ticketAmount), "You dont have enough for price.");

        // Ticket price received, add user to pool.
        for (uint i; i < _ticketAmount; i++) 
        {
            pools[_poolID].participants.push(msg.sender);
        }

        // User added pool, emitting event.
        emit userJoinedPool(msg.sender, _poolID, _ticketAmount, block.timestamp);

        //TO DO: IF REACHED MAX PARTICIPANT COUNT, TRIGGER DRAW FUNCTION.
        if(pools[_poolID].participants.length >= pools[_poolID].maxParticipant)
        {
            drawPool(_poolID);
        }
    }

    /*
    *  @dev Ends participate phase of a pool and calls ChainlinkVRF function.
    */
    function drawPool(uint _poolId) public {
        require(pools[_poolId].participants.length >= pools[_poolId].maxParticipant, "Pool did not filled yet!");
        require(pools[_poolId].poolState == 1, "It is not in the appropriate state");

        pools[_poolId].poolState = 2;   // Executable state

        // Send Profit to feeReceiver. Assumes prize and ticket same type. Also assumes pool is always at profit or at least even.
        uint fee = pools[_poolId].ticketPrice * pools[_poolId].maxParticipant - pools[_poolId].prizeAmount;

        if(fee > 0){
            IERC20(pools[_poolId].ticketUnit).transfer(pools[_poolId].feeAddress, fee);
        }

        // Request Randomness
        uint requestId = requestRandomness(300000, 3, 1);
        vrfRequests[requestId] = _poolId;

        // Update state of the pool
        pools[_poolId].poolState = 3; // Executed, awaiting for VRF Callback.

        // Emit event
        emit poolEnded(msg.sender, _poolId, block.timestamp);
    }

    /* 
    * @dev VRF Callback function 
    */
    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
        // Get pool
        LootPoolERC20 memory pool = pools[vrfRequests[requestId]];

        // Check pool state
        require(pool.poolState == 3, "Invalid pool state");

        // Winner
        address winner = pool.participants[randomWords[0] % pool.participants.length];

        // Send prize amount to winner
        require(IERC20(pool.prizeAddress).transfer(winner, pool.prizeAmount), "Error: Prize send");

        // emit event
        emit winnerOfPool(winner, vrfRequests[requestId], pool.prizeAddress, pool.prizeAmount, randomWords[0],block.timestamp);

        // Reiterate pool
        if(pools[vrfRequests[requestId]].lastGame){
            pools[vrfRequests[requestId]].poolState = 5; // Pool disabled
            claimableERC20[pools[vrfRequests[requestId]].prizeAddress] += pools[vrfRequests[requestId]].prizeAmount; // Unused assets are noted as claimable
        }
        else {
            // Restart pool
            pools[vrfRequests[requestId]].poolState = 1; // Pool initialized again
            delete pools[vrfRequests[requestId]].participants;
        }
    }

    function stopPool(uint _poolId) external onlyOwner{
        pools[_poolId].lastGame = true;
    }

     /**
     * Allow withdraw of Link tokens from the contract
     */
    function withdrawLink() public onlyOwner {
        LinkTokenInterface link = LinkTokenInterface(linkToken);
        require(
            link.transfer(msg.sender, link.balanceOf(address(this))),
            "Unable to transfer"
        );
    }

    /*
    * @dev get pool info
    */
    function getERC20PoolInfo(uint poolId)external view returns(LootPoolERC20 memory){
        return pools[poolId];
    }

    /*
    * @dev withdraw safely unused assets without breaking logic
    */
    function claimUnusedERC20(address _token) external onlyOwner{
        require(claimableERC20[_token] > 0, "No such claimable asset");

        require(IERC20(_token).transfer(msg.sender, claimableERC20[_token]));

        claimableERC20[_token] = 0;
    }

    /* 
    * @dev Emergency withdraw
    */
    function emergencyWithdraw(address _token) public onlyOwner{
        IERC20(_token).transfer(msg.sender, IERC20(_token).balanceOf(msg.sender));
    }

}