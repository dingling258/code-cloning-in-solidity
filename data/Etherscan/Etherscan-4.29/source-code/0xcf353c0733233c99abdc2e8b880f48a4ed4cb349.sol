// Sources flattened with hardhat v2.22.1 https://hardhat.org

// SPDX-License-Identifier: Apache-2.0 AND MIT

// File @openzeppelin/contracts/utils/Context.sol@v5.0.1

// Original license: SPDX_License_Identifier: MIT
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


// File @oasisprotocol/sapphire-contracts/contracts/opl/Endpoint.sol@v0.2.7

// Original license: SPDX_License_Identifier: Apache-2.0
pragma solidity ^0.8.0;

/// Unable to automatically configure OPL. Please use the manual version of the base contract.
error AutoConfigUnavailable();
/// The remote endpoint's contract address was missing.
error MissingRemoteAddr();
/// The remote endpoint's chain ID was missing.
error MissingRemoteChainId();
/// Calls to contracts on the same chain are not allowed unless on a local testnet.
error SelfCallDisallowed();
/// The requested endpoint does not exist.
error UnknownEndpoint();

/// The outcome of the message call.
enum Result {
    // The message was rejected.
    PermanentFailure,
    // The message was rejected but may be accepted later.
    TransientFailure,
    // The message was accepted and processed.
    Success
}

interface ICelerMessageBus {
    function feeBase() external view returns (uint256);

    function feePerByte() external view returns (uint256);

    function sendMessage(
        address _host,
        uint256 _hostChainId,
        bytes calldata _message
    ) external payable;
}

contract BaseEndpoint is Context {
    address internal immutable messageBus;
    bool private immutable inOrder;

    address private remote;
    uint256 private remoteChainId;

    mapping(bytes32 => function(bytes calldata) returns (Result))
        private endpoints;

    uint256 private txSeq;
    uint256 private rxSeq;

    constructor(
        address _remote,
        uint256 _remoteChainId,
        address _messageBus,
        bool _inOrder
    ) {
        if (_remote == address(0)) revert MissingRemoteAddr();
        if (_remoteChainId == 0) revert MissingRemoteChainId();
        remote = _remote;
        remoteChainId = _remoteChainId;
        messageBus = _messageBus;
        inOrder = _inOrder;
        if (!_isLocalNetwork() && _remoteChainId == block.chainid)
            revert SelfCallDisallowed();
    }

    function registerEndpoint(
        bytes memory _method,
        function(bytes calldata) returns (Result) _cb
    ) internal {
        // This is a waste of an SLOAD, but the alternative before immutable arrays
        // (https://github.com/ethereum/solidity/issues/12587) land is terribly verbose.
        // This can be fixed once gas usage becomes a problem.
        endpoints[bytes4(keccak256(_method))] = _cb;
    }

    function postMessage(bytes memory _method) internal returns (uint256) {
        return postMessage(_method, "");
    }

    /// Calls the remote endpoint, returning the amount of native token charged for the operation.
    function postMessage(bytes memory _method, bytes memory _message)
        internal
        returns (uint256)
    {
        bytes memory envelope = abi.encodePacked(
            bytes4(keccak256(_method)),
            txSeq,
            _message
        );
        uint256 fee = estimateFee(envelope.length);
        if (_isLocalNetwork()) {
            uint256 celerStatus = BaseEndpoint(messageBus).executeMessage(
                address(this), // sender
                uint64(block.chainid),
                envelope,
                address(this) // executor
            );
            // Receiving endpoint did not return successfully.
            require(celerStatus == 1, "ReceiverError");
            if (fee > 0) payable(0).transfer(fee); // burn the fee, for fidelity
        } else {
            ICelerMessageBus(messageBus).sendMessage{value: fee}(
                remote,
                remoteChainId,
                envelope
            );
        }
        ++txSeq;
        return fee;
    }

    /// Celer message bus callback function.
    function executeMessage(
        address _sender,
        uint64 _senderChainId,
        bytes calldata _message,
        address // executor
    ) external payable returns (uint256) {
        // The method can only be called by the message bus;
        require(_msgSender() == messageBus, "NotMessageBus");
        // Messages may only be sent by the remote endpoint (Enclave or Host).
        require(
            _sender == remote && _senderChainId == remoteChainId,
            "NotRemoteEndpoint"
        );
        bytes4 epSel = bytes4(_message[:4]);
        uint256 seq = uint256(bytes32(_message[4:36]));
        bytes calldata message = _message[36:];
        if (inOrder) {
            // This message arrived too early or late.
            require(seq == rxSeq, "WrongSeqNum");
            ++rxSeq;
        }
        function(bytes calldata) returns (Result) ep = endpoints[epSel];
        bool epMissing;
        /// @solidity memory-safe-assembly
        assembly {
            epMissing := iszero(ep)
        }
        Result result = endpoints[epSel](message);
        // Convert the Result to a Celer ExecutionStatus.
        if (result == Result.TransientFailure) return 2; // ExecutionStatus.Retry
        if (result == Result.Success) return 1; // ExecutionStatus.Success
        return 0; // ExecutionStatus.Fail
    }

    function estimateFee(uint256 _msgLen) internal view returns (uint256) {
        if (_isLocalNetwork()) return 0;
        uint256 feeBase = ICelerMessageBus(messageBus).feeBase();
        uint256 feePerByte = ICelerMessageBus(messageBus).feePerByte();
        return feeBase + _msgLen * feePerByte;
    }

    function _isLocalNetwork() internal view returns (bool) {
        return messageBus == remote && block.chainid == remoteChainId;
    }
}

/**
 * @title OPL Endpoint
 * @dev An app that sends or receives using OPL.
 */
contract Endpoint is BaseEndpoint {
    constructor(address _remote, bytes32 _remoteChainName)
        BaseEndpoint(
            _remote,
            _getRemoteChainId(_remoteChainName),
            _getBus(_remote, _remoteChainName),
            false
        )
    {} // solhint-disable-line no-empty-blocks
}

/* solhint-disable func-visibility */

/**
 * @dev Autoswitch automatically picks the remote network based on the network the contract on which the contract has already been deployed.
 * @dev When on testnet, the remote chain will be the testnet version of the provided chain.
 * @dev When running locally, the remote chain will be this one and the contracts will call each other without going through a message bus. This is helpful for debugging logic but does not test gas fee payment and other moving parts.
 */
function autoswitch(bytes32 protocol) view returns (bytes32 networkName) {
    if (block.chainid == 1337 || block.chainid == 31337) return "local";
    (, bool isTestnet) = _getChainConfig(block.chainid);
    if (isTestnet) {
        if (protocol == "ethereum") return "goerli";
        if (protocol == "bsc") return "bsc-testnet";
        if (protocol == "polygon") return "polygon-mumbai";
        if (protocol == "fantom") return "fantom-testnet";
        if (protocol == "sapphire") return "sapphire-testnet";
        if (protocol == "arbitrum-one") return "arbitrum-testnet";
        if (protocol == "arbitrum-nova") return "arbitrum-testnet";
        if (protocol == "avalanche") return "avalanche-fuji";
        revert AutoConfigUnavailable();
    }
    if (_chainName2ChainId(protocol) == 0) revert AutoConfigUnavailable();
    return protocol;
}

function _getBus(address _remote, bytes32 _remoteChainName)
    view
    returns (address)
{
    if (_remoteChainName == "local") return _remote;
    (address messageBus, ) = _getChainConfig(block.chainid);
    return messageBus;
}

function _getRemoteChainId(bytes32 _remoteChainName) view returns (uint256) {
    if (_remoteChainName == "local") return block.chainid;
    return _chainName2ChainId(_remoteChainName);
}

function _chainName2ChainId(bytes32 name) pure returns (uint256) {
    if (name == "ethereum") return 1;
    if (name == "goerli") return 5;
    if (name == "optimism") return 10;
    if (name == "bsc") return 56;
    if (name == "bsc-testnet") return 97;
    if (name == "polygon") return 137;
    if (name == "fantom") return 0xfa;
    if (name == "fantom-testnet") return 0xfa2;
    if (name == "moonriver") return 0x505;
    if (name == "arbitrum-one") return 0xa4b1;
    if (name == "arbitrum-nova") return 0xa4ba;
    if (name == "sapphire") return 0x5afe;
    if (name == "sapphire-testnet") return 0x5aff;
    if (name == "polygon-mumbai") return 80001;
    if (name == "avalanche") return 43114;
    if (name == "avalanche-fuji") return 43313;
    if (name == "arbitrum-testnet") return 0x66eeb;
    return 0;
}

/// Configs from https://im-docs.celer.network/developer/contract-addresses-and-rpc-info.
function _getChainConfig(uint256 _chainId)
    pure
    returns (address _messageBus, bool _isTestnet)
{
    if (_chainId == 1)
        // ethereum
        return (0x4066D196A423b2b3B8B054f4F40efB47a74E200C, false);
    if (_chainId == 5)
        // goerli
        return (0xF25170F86E4291a99a9A560032Fe9948b8BcFBB2, true);
    if (_chainId == 10)
        // optimism
        return (0x0D71D18126E03646eb09FEc929e2ae87b7CAE69d, false);
    if (_chainId == 56)
        // bsc
        return (0x95714818fdd7a5454F73Da9c777B3ee6EbAEEa6B, false);
    if (_chainId == 97)
        // bsc testnet
        return (0xAd204986D6cB67A5Bc76a3CB8974823F43Cb9AAA, true);
    if (_chainId == 137)
        // polygon
        return (0xaFDb9C40C7144022811F034EE07Ce2E110093fe6, false);
    if (_chainId == 0xfa)
        // fantom
        return (0xFF4E183a0Ceb4Fa98E63BbF8077B929c8E5A2bA4, false);
    if (_chainId == 0xfa2)
        // fantom testnet
        return (0xb92d6933A024bcca9A21669a480C236Cbc973110, true);
    if (_chainId == 0x505)
        // moonriver
        return (0x940dAAbA3F713abFabD79CdD991466fe698CBe54, false);
    if (_chainId == 0x5afe)
        // sapphire
        return (0x9Bb46D5100d2Db4608112026951c9C965b233f4D, false);
    if (_chainId == 0x5aff)
        // sapphire testnet
        return (0x9Bb46D5100d2Db4608112026951c9C965b233f4D, true);
    if (_chainId == 0xa4b1)
        // arbitrum one
        return (0x3Ad9d0648CDAA2426331e894e980D0a5Ed16257f, false);
    if (_chainId == 0xa4ba)
        // arbitrum nova
        return (0xf5C6825015280CdfD0b56903F9F8B5A2233476F5, false);
    if (_chainId == 43113)
        // avalanche c-chain fuji testnet
        return (0xE9533976C590200E32d95C53f06AE12d292cFc47, true);
    if (_chainId == 43114)
        // avalanche c-chain
        return (0x5a926eeeAFc4D217ADd17e9641e8cE23Cd01Ad57, false);
    if (_chainId == 80001)
        // polygon mumbai testnet
        return (0x7d43AABC515C356145049227CeE54B608342c0ad, true);
    if (_chainId == 0x66eeb)
        // arbitrum testnet
        return (0x7d43AABC515C356145049227CeE54B608342c0ad, true);
    revert AutoConfigUnavailable();
}


// File @oasisprotocol/sapphire-contracts/contracts/opl/Enclave.sol@v0.2.7

// Original license: SPDX_License_Identifier: Apache-2.0
pragma solidity ^0.8.0;

/**
 * @title OPL Enclave
 * @dev The Sapphire-side of an OPL dapp.
 */
contract Enclave is Endpoint {
    constructor(address _host, bytes32 _hostChain)
        Endpoint(_host, _hostChain)
    {} // solhint-disable-line no-empty-blocks
}


// File @oasisprotocol/sapphire-contracts/contracts/opl/Host.sol@v0.2.7

// Original license: SPDX_License_Identifier: Apache-2.0
pragma solidity ^0.8.0;

/**
 * @title OPL Host
 * @dev The L1-side of an OPL dapp.
 */
contract Host is Endpoint {
    // solhint-disable-next-line no-empty-blocks
    constructor(address _enclave) Endpoint(_enclave, autoswitch("sapphire")) {}
}


// File @oasisprotocol/sapphire-contracts/contracts/OPL.sol@v0.2.7

// Original license: SPDX_License_Identifier: Apache-2.0
pragma solidity ^0.8.0;


// File @openzeppelin/contracts/utils/structs/EnumerableSet.sol@v5.0.1

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (utils/structs/EnumerableSet.sol)
// This file was procedurally generated from scripts/generate/templates/EnumerableSet.js.

pragma solidity ^0.8.20;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```solidity
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 *
 * [WARNING]
 * ====
 * Trying to delete such a structure from storage will likely result in data corruption, rendering the structure
 * unusable.
 * See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
 *
 * In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an
 * array of EnumerableSet.
 * ====
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position is the index of the value in the `values` array plus 1.
        // Position 0 is used to mean a value is not in the set.
        mapping(bytes32 value => uint256) _positions;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._positions[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We cache the value's position to prevent multiple reads from the same storage slot
        uint256 position = set._positions[value];

        if (position != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 valueIndex = position - 1;
            uint256 lastIndex = set._values.length - 1;

            if (valueIndex != lastIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the lastValue to the index where the value to delete is
                set._values[valueIndex] = lastValue;
                // Update the tracked position of the lastValue (that was just moved)
                set._positions[lastValue] = position;
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the tracked position for the deleted slot
            delete set._positions[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._positions[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        bytes32[] memory store = _values(set._inner);
        bytes32[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        /// @solidity memory-safe-assembly
        assembly {
            result := store
        }

        return result;
    }
}


// File contracts/accessControl.sol

// Original license: SPDX_License_Identifier: MIT

pragma solidity 0.8.24;

contract accessControl {

/**
* @dev maps 'relayerStatus' for a specific wallet to either true or false.
* @notice relayerStatus is a designation reserved for the CoinStir relayer(s) and ensures only the relayers can interact with certain functions.
* The relayers exist to prevent the need for users to purchase the $ROSE token that enables the privacy features, 
* as well as to further obfuscate a user from their specific interactions within CoinStir.
*/
    mapping(address => bool) public relayerStatus;

/**
* @dev maps 'adminStatus' for a specific wallet to either true or false.
* @notice adminStatus is the highest form of authority and grants full control over the contract.
*/
    mapping(address => bool) public adminStatus;

/**
* @dev maps 'authStatus' for a specific wallet to either true or false.
* @notice authStatus is to be granted only to regulatory or government agencies and allows for complete visiblity of all private data.
* This is explicitly to prevent money laundering.
*/
    mapping(address => bool) public authStatus;

/**
* @notice only an Admin can flip relayer status, providing strict controls and preventing abuse.
* @dev flips relayer status to the opposite of its current state for a given user. Care should be taken to ensure constant up-time of at least one relayer.
* @param _relayer is the address of the relayer to flip the current status of.
*/

    function flipRelayer(address _relayer) external onlyAdmin returns (bool) {
        relayerStatus[_relayer] = !relayerStatus[_relayer];
        return relayerStatus[_relayer];
    }

/**
* @dev modifier to enforce the relayer logic described above.
*/

    modifier onlyRelayer() {
        require(relayerStatus[msg.sender] == true);
        _;
    }

/**
* @notice only an Admin can flip AdminStatus, providing strict controls and preventing abuse.
* @notice an admin cannot revoke its own adminStatus, ensuring there is always at least 1 admin.
* @dev specifics of AdminStatus are detailed in above notes.
* @param _admin is the address of the admin to flip the current status of.
*/
    function flipAdmin(address _admin) external onlyAdmin returns (bool) {
        require (msg.sender != _admin, "cannot revoke own access");
        adminStatus[_admin] = !adminStatus[_admin];
        return adminStatus[_admin];
    }

/**
* @dev modifier to enforce the AdminStatus logic described above.
*/
    modifier onlyAdmin() {
        require(adminStatus[msg.sender] == true);
        _;
    }

/**
* @notice only an Admin can flip auth status, providing strict controls and preventing abuse.
* @dev specifics of authStatus are detailed in above notes. Care should be taken to ensure proper compliance with any relevant authority.
* @param _auth is the address of the authority to flip the current status of.
*/
    function flipAuth(address _auth) external onlyAdmin returns (bool) {
        authStatus[_auth] = !authStatus[_auth];
        return authStatus[_auth];
    }

}


// File contracts/StirHost.sol

// Original license: SPDX_License_Identifier: MIT

pragma solidity 0.8.24;



/**
* @title CoinStirHost
* @dev CoinStirHost acts as the asset transacting half of a larger application used to obfuscate txn history and user account balance from the public eye.
* This half of the application exists on Ethereum, while the other half exsits on the Oasis Network's Sapphire Paratime which enables custom visibility settings on sensitive data.
* The Ethereum component and the Sapphire component communicate via the Celer IM Bridge.
*/

contract StirHost is Host, accessControl {

/**
* @dev set the min amount that can be deposited.
*/
    uint256 public minAmount = 10000000000000000;

/**
* @dev sets the Enclave address for the sapphire component of the application. This ensures only messages received from this specific address are acted upon, increasing security.
* @notice an endpoint is set, causing the subsequent function "_executeTxn" to execute upon receipt of a message including the keyword "executeTxn".
*/
    constructor(address enclave) Host(enclave) {
        registerEndpoint("executeTxn", _executeTxn);
        adminStatus[msg.sender] = true;
    }

/**
* @dev accepts a deposit of any amount and tracks the details in the Enclave contract
* @notice funds stay in this contract, while both the sender and the message value are sent via Celer IM Bridge to the Enclave, where the details of the txn are stored.
* @notice no state is kept in this contract, only the assets. All contract state is stored in the Enclave on Sapphire for privacy.
*/
    function deposit() external payable {
        address sender = msg.sender;
        uint256 payload = msg.value;
        require (payload >= minAmount, "insufficient value");
        postMessage("trackDeposit", abi.encode(sender, payload));
    }

/**
* @dev accepts messages delivered via the Celer IM Bridge from the Enclave contract only, extracts the recipiant and value of the txn request, and executes the transfer of funds.
* @notice security and permissions are handled entirely by the Enclave prior to the message being sent.
* @notice funds are sent but no state is updated in this contract.
* @return success upon proper execution.
*/
    function _executeTxn(bytes calldata _args) internal returns (Result) {
        (address recipiant, uint256 payload) = abi.decode(_args, (address, uint256));
        payable(recipiant).transfer(payload);
        return Result.Success;
    }

/**
* @dev update the min amount that can be deposited.
*/
    function setMinAmount(uint256 _minAmount) external onlyAdmin {
        minAmount = _minAmount;
    }

}