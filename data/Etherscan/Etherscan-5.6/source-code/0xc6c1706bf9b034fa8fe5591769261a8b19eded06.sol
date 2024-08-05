// Sources flattened with hardhat v2.22.2 https://hardhat.org

// SPDX-License-Identifier: GPL-3.0 AND MIT

// File @chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol@v1.4.0

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.0;

// End consumer library.
library Client {
  /// @dev RMN depends on this struct, if changing, please notify the RMN maintainers.
  struct EVMTokenAmount {
    address token; // token address on the local chain.
    uint256 amount; // Amount of tokens.
  }

  struct Any2EVMMessage {
    bytes32 messageId; // MessageId corresponding to ccipSend on source.
    uint64 sourceChainSelector; // Source chain selector.
    bytes sender; // abi.decode(sender) if coming from an EVM chain.
    bytes data; // payload sent in original message.
    EVMTokenAmount[] destTokenAmounts; // Tokens and their amounts in their destination chain representation.
  }

  // If extraArgs is empty bytes, the default is 200k gas limit.
  struct EVM2AnyMessage {
    bytes receiver; // abi.encode(receiver address) for dest EVM chains
    bytes data; // Data payload
    EVMTokenAmount[] tokenAmounts; // Token transfers
    address feeToken; // Address of feeToken. address(0) means you will send msg.value.
    bytes extraArgs; // Populate this with _argsToBytes(EVMExtraArgsV1)
  }

  // bytes4(keccak256("CCIP EVMExtraArgsV1"));
  bytes4 public constant EVM_EXTRA_ARGS_V1_TAG = 0x97a657c9;
  struct EVMExtraArgsV1 {
    uint256 gasLimit;
  }

  function _argsToBytes(EVMExtraArgsV1 memory extraArgs) internal pure returns (bytes memory bts) {
    return abi.encodeWithSelector(EVM_EXTRA_ARGS_V1_TAG, extraArgs);
  }
}


// File @chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IAny2EVMMessageReceiver.sol@v1.4.0

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.0;

/// @notice Application contracts that intend to receive messages from
/// the router should implement this interface.
interface IAny2EVMMessageReceiver {
  /// @notice Called by the Router to deliver a message.
  /// If this reverts, any token transfers also revert. The message
  /// will move to a FAILED state and become available for manual execution.
  /// @param message CCIP Message
  /// @dev Note ensure you check the msg.sender is the OffRampRouter
  function ccipReceive(Client.Any2EVMMessage calldata message) external;
}


// File @chainlink/contracts-ccip/src/v0.8/vendor/openzeppelin-solidity/v4.8.3/contracts/utils/introspection/IERC165.sol@v1.4.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}


// File @chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol@v1.4.0

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.0;

/// @title CCIPReceiver - Base contract for CCIP applications that can receive messages.
abstract contract CCIPReceiver is IAny2EVMMessageReceiver, IERC165 {
  address internal immutable i_ccipRouter;

  constructor(address router) {
    if (router == address(0)) revert InvalidRouter(address(0));
    i_ccipRouter = router;
  }

  /// @notice IERC165 supports an interfaceId
  /// @param interfaceId The interfaceId to check
  /// @return true if the interfaceId is supported
  /// @dev Should indicate whether the contract implements IAny2EVMMessageReceiver
  /// e.g. return interfaceId == type(IAny2EVMMessageReceiver).interfaceId || interfaceId == type(IERC165).interfaceId
  /// This allows CCIP to check if ccipReceive is available before calling it.
  /// If this returns false or reverts, only tokens are transferred to the receiver.
  /// If this returns true, tokens are transferred and ccipReceive is called atomically.
  /// Additionally, if the receiver address does not have code associated with
  /// it at the time of execution (EXTCODESIZE returns 0), only tokens will be transferred.
  function supportsInterface(bytes4 interfaceId) public pure virtual override returns (bool) {
    return interfaceId == type(IAny2EVMMessageReceiver).interfaceId || interfaceId == type(IERC165).interfaceId;
  }

  /// @inheritdoc IAny2EVMMessageReceiver
  function ccipReceive(Client.Any2EVMMessage calldata message) external virtual override onlyRouter {
    _ccipReceive(message);
  }

  /// @notice Override this function in your implementation.
  /// @param message Any2EVMMessage
  function _ccipReceive(Client.Any2EVMMessage memory message) internal virtual;

  /////////////////////////////////////////////////////////////////////
  // Plumbing
  /////////////////////////////////////////////////////////////////////

  /// @notice Return the current router
  /// @return CCIP router address
  function getRouter() public view returns (address) {
    return address(i_ccipRouter);
  }

  error InvalidRouter(address router);

  /// @dev only calls from the set router are accepted.
  modifier onlyRouter() {
    if (msg.sender != address(i_ccipRouter)) revert InvalidRouter(msg.sender);
    _;
  }
}


// File @chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol@v1.4.0

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.0;

interface IRouterClient {
  error UnsupportedDestinationChain(uint64 destChainSelector);
  error InsufficientFeeTokenAmount();
  error InvalidMsgValue();

  /// @notice Checks if the given chain ID is supported for sending/receiving.
  /// @param chainSelector The chain to check.
  /// @return supported is true if it is supported, false if not.
  function isChainSupported(uint64 chainSelector) external view returns (bool supported);

  /// @notice Gets a list of all supported tokens which can be sent or received
  /// to/from a given chain id.
  /// @param chainSelector The chainSelector.
  /// @return tokens The addresses of all tokens that are supported.
  function getSupportedTokens(uint64 chainSelector) external view returns (address[] memory tokens);

  /// @param destinationChainSelector The destination chainSelector
  /// @param message The cross-chain CCIP message including data and/or tokens
  /// @return fee returns execution fee for the message
  /// delivery to destination chain, denominated in the feeToken specified in the message.
  /// @dev Reverts with appropriate reason upon invalid message.
  function getFee(
    uint64 destinationChainSelector,
    Client.EVM2AnyMessage memory message
  ) external view returns (uint256 fee);

  /// @notice Request a message to be sent to the destination chain
  /// @param destinationChainSelector The destination chain ID
  /// @param message The cross-chain CCIP message including data and/or tokens
  /// @return messageId The message ID
  /// @dev Note if msg.value is larger than the required fee (from getFee) we accept
  /// the overpayment with no refund.
  /// @dev Reverts with appropriate reason upon invalid message.
  function ccipSend(
    uint64 destinationChainSelector,
    Client.EVM2AnyMessage calldata message
  ) external payable returns (bytes32);
}


// File @chainlink/contracts-ccip/src/v0.8/shared/interfaces/IOwnable.sol@v1.4.0

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.0;

interface IOwnable {
  function owner() external returns (address);

  function transferOwnership(address recipient) external;

  function acceptOwnership() external;
}


// File @chainlink/contracts-ccip/src/v0.8/shared/access/ConfirmedOwnerWithProposal.sol@v1.4.0

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.0;

/// @title The ConfirmedOwner contract
/// @notice A contract with helpers for basic contract ownership.
contract ConfirmedOwnerWithProposal is IOwnable {
  address private s_owner;
  address private s_pendingOwner;

  event OwnershipTransferRequested(address indexed from, address indexed to);
  event OwnershipTransferred(address indexed from, address indexed to);

  constructor(address newOwner, address pendingOwner) {
    // solhint-disable-next-line custom-errors
    require(newOwner != address(0), "Cannot set owner to zero");

    s_owner = newOwner;
    if (pendingOwner != address(0)) {
      _transferOwnership(pendingOwner);
    }
  }

  /// @notice Allows an owner to begin transferring ownership to a new address.
  function transferOwnership(address to) public override onlyOwner {
    _transferOwnership(to);
  }

  /// @notice Allows an ownership transfer to be completed by the recipient.
  function acceptOwnership() external override {
    // solhint-disable-next-line custom-errors
    require(msg.sender == s_pendingOwner, "Must be proposed owner");

    address oldOwner = s_owner;
    s_owner = msg.sender;
    s_pendingOwner = address(0);

    emit OwnershipTransferred(oldOwner, msg.sender);
  }

  /// @notice Get the current owner
  function owner() public view override returns (address) {
    return s_owner;
  }

  /// @notice validate, transfer ownership, and emit relevant events
  function _transferOwnership(address to) private {
    // solhint-disable-next-line custom-errors
    require(to != msg.sender, "Cannot transfer to self");

    s_pendingOwner = to;

    emit OwnershipTransferRequested(s_owner, to);
  }

  /// @notice validate access
  function _validateOwnership() internal view {
    // solhint-disable-next-line custom-errors
    require(msg.sender == s_owner, "Only callable by owner");
  }

  /// @notice Reverts if called by anyone other than the contract owner.
  modifier onlyOwner() {
    _validateOwnership();
    _;
  }
}


// File @chainlink/contracts-ccip/src/v0.8/shared/access/ConfirmedOwner.sol@v1.4.0

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.0;

/// @title The ConfirmedOwner contract
/// @notice A contract with helpers for basic contract ownership.
contract ConfirmedOwner is ConfirmedOwnerWithProposal {
  constructor(address newOwner) ConfirmedOwnerWithProposal(newOwner, address(0)) {}
}


// File @chainlink/contracts-ccip/src/v0.8/shared/access/OwnerIsCreator.sol@v1.4.0

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.0;

/// @title The OwnerIsCreator contract
/// @notice A contract with helpers for basic contract ownership.
contract OwnerIsCreator is ConfirmedOwner {
  constructor() ConfirmedOwner(msg.sender) {}
}


// File @openzeppelin/contracts/utils/Context.sol@v4.9.3

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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
}


// File @openzeppelin/contracts/access/Ownable.sol@v4.9.3

// Original license: SPDX_License_Identifier: MIT
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


// File @openzeppelin/contracts/token/ERC20/IERC20.sol@v4.9.3

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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
    function allowance(address owner, address spender) external view returns (uint256);

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
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}


// File @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol@v4.9.3

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
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


// File @openzeppelin/contracts/interfaces/IERC20Metadata.sol@v4.9.3

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20Metadata.sol)

pragma solidity ^0.8.0;


// File contracts/CCWSTBTMessager.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity 0.8.19;




interface ICCIPClient {
    function getCcSendData(address sender, address receiver, uint256 value) external view returns (bytes memory message);

    function ccSend(address sender, address recipient, uint256 value) external returns (bytes memory message);

    function ccReceive(bytes calldata message) external;
}

contract CCWSTBTMessager is CCIPReceiver, OwnerIsCreator {
    ICCIPClient public ccipClient;

    mapping(uint64 => mapping(address => bool)) public allowedPeer;

    event AllowedPeer(uint64 chainSelector, address messager, bool allowed);
    event CCReceive(bytes32 indexed messageID, bytes messageData);
    event CCSend(bytes32 indexed messageID, bytes messageData);

    error NotAllowlisted(uint64 chainSelector, address messager);

    constructor(
        address _router,
        address _ccipClient
    ) CCIPReceiver(_router) {
        ccipClient = ICCIPClient(_ccipClient);
    }

    function setAllowedPeer(uint64 chainSelector, address messager, bool allowed) external onlyOwner {
        allowedPeer[chainSelector][messager] = allowed;
    }

    function _ccipReceive(
        Client.Any2EVMMessage memory any2EvmMessage
    ) internal override {
        address sender = abi.decode(any2EvmMessage.sender, (address));
        if (!allowedPeer[any2EvmMessage.sourceChainSelector][sender]) {
            revert NotAllowlisted(any2EvmMessage.sourceChainSelector, sender);
        }

        ccipClient.ccReceive(any2EvmMessage.data);
        emit CCReceive(any2EvmMessage.messageId, any2EvmMessage.data);
    }

    function calculateFeeAndMessage(
        uint64 destinationChainSelector,
        address messageReceiver,
        address sender,
        address recipient,
        uint value,
        bytes calldata extraArgs
    ) public view returns (uint256 fee, Client.EVM2AnyMessage memory evm2AnyMessage) {
        bytes memory data = ccipClient.getCcSendData(sender, recipient, value);
        evm2AnyMessage = Client.EVM2AnyMessage({
        receiver : abi.encode(messageReceiver),
        data : data,
        tokenAmounts : new Client.EVMTokenAmount[](0),
        extraArgs : extraArgs,
        feeToken : address(0)
        });
        fee = IRouterClient(getRouter()).getFee(destinationChainSelector, evm2AnyMessage);
    }

    function transferToChain(
        uint64 destinationChainSelector,
        address messageReceiver,
        address recipient,
        uint value,
        bytes calldata extraArgs
    ) external payable returns (bytes32 messageId) {
        if (!allowedPeer[destinationChainSelector][messageReceiver]) {
            revert NotAllowlisted(destinationChainSelector, messageReceiver);
        }
        bytes memory data = ccipClient.ccSend(msg.sender, recipient, value);
        Client.EVM2AnyMessage memory evm2AnyMessage = Client.EVM2AnyMessage({
        receiver : abi.encode(messageReceiver),
        data : data,
        tokenAmounts : new Client.EVMTokenAmount[](0),
        extraArgs : extraArgs,
        feeToken : address(0)
        });
        uint256 fee = IRouterClient(getRouter()).getFee(destinationChainSelector, evm2AnyMessage);
        require(msg.value >= fee, "CCWSTBTMessager: INSUFFICIENT_FUNDS");
        messageId = IRouterClient(getRouter()).ccipSend{value : fee}(
            destinationChainSelector,
            evm2AnyMessage
        );
        if (msg.value - fee > 0) {
            bool success = payable(msg.sender).send(msg.value - fee);
            require(success, "CCWSTBTMessager: TRANSFER_FAILED");
        }
        emit CCSend(messageId, data);
        return messageId;
    }
}


// File contracts/interfaces/ISTBT.sol

// Original license: SPDX_License_Identifier: GPL-3.0
pragma solidity ^0.8.0;



interface IERC1644 is IERC20 {
    // Controller Events
    event ControllerTransfer(
        address _controller,
        address indexed _from,
        address indexed _to,
        uint256 _value,
        bytes _data,
        bytes _operatorData
    );

    event ControllerRedemption(
        address _controller,
        address indexed _tokenHolder,
        uint256 _value,
        bytes _data,
        bytes _operatorData
    );

    // Controller Operation
    function isControllable() external view returns (bool);
    function controllerTransfer(address _from, address _to, uint256 _value, bytes calldata _data, bytes calldata _operatorData) external;
    function controllerRedeem(address _tokenHolder, uint256 _value, bytes calldata _data, bytes calldata _operatorData) external;
}

interface IERC1643 {
    // Document Events
    event DocumentRemoved(bytes32 indexed _name, string _uri, bytes32 _documentHash);
    event DocumentUpdated(bytes32 indexed _name, string _uri, bytes32 _documentHash);

    // Document Management
    function getDocument(bytes32 _name) external view returns (string memory, bytes32, uint256);
    function setDocument(bytes32 _name, string calldata _uri, bytes32 _documentHash) external;
    function removeDocument(bytes32 _name) external;
    function getAllDocuments() external view returns (bytes32[] memory);
}

interface IERC1594 is IERC20 {
    // Issuance / Redemption Events
    event Issued(address indexed _operator, address indexed _to, uint256 _value, bytes _data);
    event Redeemed(address indexed _operator, address indexed _from, uint256 _value, bytes _data);

    // Transfers
    function transferWithData(address _to, uint256 _value, bytes calldata _data) external;
    function transferFromWithData(address _from, address _to, uint256 _value, bytes calldata _data) external;

    // Token Issuance
    function isIssuable() external view returns (bool);
    function issue(address _tokenHolder, uint256 _value, bytes calldata _data) external;

    // Token Redemption
    function redeem(uint256 _value, bytes calldata _data) external;
    function redeemFrom(address _tokenHolder, uint256 _value, bytes calldata _data) external;

    // Transfer Validity
    function canTransfer(address _to, uint256 _value, bytes calldata _data) external view returns (bool, uint8, bytes32);
    function canTransferFrom(address _from, address _to, uint256 _value, bytes calldata _data) external view returns (bool, uint8, bytes32);
}

struct Permission {
    bool sendAllowed; // default: true
    bool receiveAllowed;
    // Address holder’s KYC will be validated till this time, after that the holder needs to re-KYC.
    uint64 expiryTime; // default:0 validated forever
}

interface ISTBT is IERC20, IERC20Metadata, IERC1594, IERC1643, IERC1644 {
    event InterestsDistributed(int interest, uint newTotalSupply, uint interestFromTime, uint interestToTime);
    event TransferShares(address indexed from, address indexed to, uint256 sharesValue);

    function issuer() external view returns (address); 
    function controller() external view returns (address); 
    function moderator() external view returns (address); 
    function totalShares() external view returns (uint);
    function allowance(address _owner, address _spender) external view returns (uint256);
    function permissions(address addr) external view returns (bool sendAllowed,
                                                              bool receiveAllowed,
                                                              uint64 expiryTime);
    function lastDistributeTime() external view returns (uint64);
    function minDistributeInterval() external view returns (uint64);
    function maxDistributeRatio() external view returns (uint64);

    function setIssuer(address _issuer) external;
    function setController(address _controller) external;
    function setModerator(address _moderator) external;
    function setMinDistributeInterval(uint64 interval) external;
    function setMaxDistributeRatio(uint64 ratio) external;
    function setPermission(address addr, Permission calldata permission) external;

    function distributeInterests(int256 _distributedInterest, uint interestFromTime, uint interestToTime) external;

    function increaseAllowance(address _spender, uint256 _addedValue) external returns (bool);
    function decreaseAllowance(address _spender, uint256 _subtractedValue) external returns (bool);

    function sharesOf(address _account) external view returns (uint256);
    function getSharesByAmount(uint256 _amount) external view returns (uint256 result);
    function getSharesByAmountRoundUp(uint256 _amount) external view returns (uint256 result);
    function getAmountByShares(uint256 _shares) external view returns (uint256 result);
}


// File contracts/WSTBTBridge.sol

// Original license: SPDX_License_Identifier: GPL-3.0
pragma solidity ^0.8.0;


contract WSTBTBridge is Ownable, ICCIPClient {
    address immutable public stbtAddress; // = 0x530824DA86689C9C17CdC2871Ff29B058345b44a;
    address immutable public wstbtAddress;
    address public messager;
    bool public sendEnabled;

    modifier onlyMessager() {
        require(msg.sender == messager, 'WSTBTBridge: NOT_MESSAGER');
        _;
    }

    constructor(address _stbtAddress, address _wstbtAddress) {
        stbtAddress = _stbtAddress;
        wstbtAddress = _wstbtAddress;
    }

    function setMessager(address _messager) public onlyOwner {
        messager = _messager;
    }

    function setSendEnabled(bool b) public onlyOwner {
        sendEnabled = b;
    }

    function ccSend(address sender, address receiver, uint256 value) public onlyMessager returns (bytes memory message) {
        require(sendEnabled, "WSTBTBridge: SEND_DISABLED");

        (bool sendAllowed, bool receiveAllowed, uint64 expiryTime) = ISTBT(stbtAddress).permissions(receiver);
        if(value != 0) {
            require(receiveAllowed, 'WSTBTBridge: NO_RECEIVE_PERMISSION');
            require(expiryTime == 0 || expiryTime > block.timestamp, 'WSTBTBridge: RECEIVE_PERMISSION_EXPIRED');
            IERC20(wstbtAddress).transferFrom(sender, address(this), value);
        }

        return _getCcSendData(receiver, value, sendAllowed, receiveAllowed, expiryTime);
    }

    function getCcSendData(address, address receiver, uint256 value) external view returns (bytes memory message) {
        (bool sendAllowed, bool receiveAllowed, uint64 expiryTime) = ISTBT(stbtAddress).permissions(receiver);
        return _getCcSendData(receiver, value, sendAllowed, receiveAllowed, expiryTime);
    }

    function _getCcSendData(address receiver, uint256 value, bool sendAllowed, bool receiveAllowed, uint64 expiryTime) private view returns (bytes memory message) {
        uint receiverAndPermission = uint(uint160(receiver));
        receiverAndPermission = (receiverAndPermission<<8)|(sendAllowed? 1 : 0);
        receiverAndPermission = (receiverAndPermission<<8)|(receiveAllowed? 1 : 0);
        receiverAndPermission = (receiverAndPermission<<64)|uint(expiryTime);
        uint priceToSTBT = ISTBT(stbtAddress).getAmountByShares(10**18);
        uint priceToSTBTUpdateTime = block.timestamp;
        uint priceAndUpdateTime = (priceToSTBT<<64) | priceToSTBTUpdateTime;
        return abi.encode(value, receiverAndPermission, priceAndUpdateTime);
    }

    function ccReceive(bytes calldata message) public onlyMessager {
        (address sender, address receiver, uint value) =
            abi.decode(message, (address, address, uint));
        (/*bool sendAllowed*/, bool receiveAllowed, uint64 expiryTime) = ISTBT(stbtAddress).permissions(receiver);
        if(!receiveAllowed || (expiryTime != 0 && expiryTime < block.timestamp)) {
            receiver = owner();
        } else {
            bool sendAllowed;
            (sendAllowed,,expiryTime) = ISTBT(stbtAddress).permissions(sender);
            if(!sendAllowed || (expiryTime != 0 && expiryTime <= block.timestamp)) {
                receiver = owner();
            }
        }
        IERC20(wstbtAddress).transfer(receiver, value);
    }
}