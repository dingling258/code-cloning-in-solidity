// Sources flattened with hardhat v2.19.4 https://hardhat.org

// SPDX-License-Identifier: Apache-2.0 AND MIT

// File @openzeppelin/contracts/utils/Context.sol@v4.9.6

// Original license: SPDX_License_Identifier: MIT
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


// File @openzeppelin/contracts/access/Ownable.sol@v4.9.6

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


// File @openzeppelin/contracts/proxy/Clones.sol@v4.9.6

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (proxy/Clones.sol)

pragma solidity ^0.8.0;

/**
 * @dev https://eips.ethereum.org/EIPS/eip-1167[EIP 1167] is a standard for
 * deploying minimal proxy contracts, also known as "clones".
 *
 * > To simply and cheaply clone contract functionality in an immutable way, this standard specifies
 * > a minimal bytecode implementation that delegates all calls to a known, fixed address.
 *
 * The library includes functions to deploy a proxy using either `create` (traditional deployment) or `create2`
 * (salted deterministic deployment). It also includes functions to predict the addresses of clones deployed using the
 * deterministic method.
 *
 * _Available since v3.4._
 */
library Clones {
    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create opcode, which should never revert.
     */
    function clone(address implementation) internal returns (address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            // Cleans the upper 96 bits of the `implementation` word, then packs the first 3 bytes
            // of the `implementation` address with the bytecode before the address.
            mstore(0x00, or(shr(0xe8, shl(0x60, implementation)), 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000))
            // Packs the remaining 17 bytes of `implementation` with the bytecode after the address.
            mstore(0x20, or(shl(0x78, implementation), 0x5af43d82803e903d91602b57fd5bf3))
            instance := create(0, 0x09, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create2 opcode and a `salt` to deterministically deploy
     * the clone. Using the same `implementation` and `salt` multiple time will revert, since
     * the clones cannot be deployed twice at the same address.
     */
    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            // Cleans the upper 96 bits of the `implementation` word, then packs the first 3 bytes
            // of the `implementation` address with the bytecode before the address.
            mstore(0x00, or(shr(0xe8, shl(0x60, implementation)), 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000))
            // Packs the remaining 17 bytes of `implementation` with the bytecode after the address.
            mstore(0x20, or(shl(0x78, implementation), 0x5af43d82803e903d91602b57fd5bf3))
            instance := create2(0, 0x09, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(add(ptr, 0x38), deployer)
            mstore(add(ptr, 0x24), 0x5af43d82803e903d91602b57fd5bf3ff)
            mstore(add(ptr, 0x14), implementation)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73)
            mstore(add(ptr, 0x58), salt)
            mstore(add(ptr, 0x78), keccak256(add(ptr, 0x0c), 0x37))
            predicted := keccak256(add(ptr, 0x43), 0x55)
        }
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(
        address implementation,
        bytes32 salt
    ) internal view returns (address predicted) {
        return predictDeterministicAddress(implementation, salt, address(this));
    }
}


// File @openzeppelin/contracts/security/ReentrancyGuard.sol@v4.9.6

// Original license: SPDX_License_Identifier: MIT
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


// File contracts/orosign/interfaces/IOrosignV1.sol

// Original license: SPDX_License_Identifier: Apache-2.0
pragma solidity 0.8.19;

// Invalid threshold
error InvalidThreshold(uint256 threshold, uint256 totalSigner);
// Invalid Proof Length
error InvalidProofLength(uint256 length);
// Invalid permission
error InvalidPermission(uint256 totalSinger, uint256 totalExecutor, uint256 totalCreator);
// Voting process was not pass the threshold
error ThresholdNotPassed(uint256 signed, uint256 threshold);
// Proof Chain ID mismatch
error ProofChainIdMismatch(uint256 inputChainId, uint256 requiredChainId);
// Proof invalid nonce value
error ProofInvalidNonce(uint256 inputNonce, uint256 requiredNonce);
// Proof expired
error ProofExpired(uint256 votingDeadline, uint256 currentTimestamp);
// There is no creator proof in the signature list
error ProofNoCreator();
// Insecure timeout
error InsecuredTimeout(uint256 duration);

interface IOrosignV1 {
  // Packed transaction
  struct PackedTransaction {
    uint64 chainId;
    uint64 votingDeadline;
    uint128 nonce;
    uint96 currentBlockTime;
    address target;
    uint256 value;
    address orosignAddress;
    bytes data;
  }

  struct OrosignV1Metadata {
    uint256 chainId;
    uint256 nonce;
    uint256 totalSigner;
    uint256 threshold;
    uint256 securedTimeout;
    uint256 blockTimestamp;
  }

  function init(address[] memory userList, uint256[] memory roleList, uint256 threshold) external returns (bool);
}


// File contracts/orosign/OrosignMasterV1.sol

// Original license: SPDX_License_Identifier: Apache-2.0
pragma solidity 0.8.19;




// Unable to init new wallet
error UnableToInitNewWallet(uint96 salt, address owner, address newWallet);
// Only operator
error OnlyOperatorAllowed(address actor);
// Invalid operator address
error InvalidOperator(address operatorAddress);
// Invalid Address
error InvalidAddress();

/**
 * Orosign Master V1
 */
contract OrosignMasterV1 is Ownable, ReentrancyGuard {
  // Allow master to clone other multi signature contract
  using Clones for address;

  // Wallet implementation
  address private implementation;

  // Operator list
  mapping(address => bool) private operator;

  // Create new wallet
  event CreateNewWallet(uint96 indexed salt, address indexed owner, address indexed walletAddress);

  // Upgrade implementation
  event UpgradeImplementation(address indexed oldImplementation, address indexed upgradeImplementation);

  // Add Operator
  event AddOperator(address indexed newOperatorAddress);

  // Remove Operator
  event RemoveOperator(address indexed oldOperatorAddress);

  // We only allow operator
  modifier onlyOperator() {
    if (!operator[msg.sender]) {
      revert OnlyOperatorAllowed(msg.sender);
    }
    _;
  }

  // We only allow valid address
  modifier onlyValidAddress(address validatingAddress) {
    if (validatingAddress == address(0)) {
      revert InvalidAddress();
    }
    _;
  }

  // Pass parameters to parent contract
  constructor(
    address multisigImplementation,
    address operatorAddress
  ) onlyValidAddress(multisigImplementation) onlyValidAddress(operatorAddress) {
    // Set the address of orosign implementation
    implementation = multisigImplementation;

    _addOperator(operatorAddress);

    emit UpgradeImplementation(address(0), multisigImplementation);
  }

  /*******************************************************
   * Internal section
   ********************************************************/

  // Add new operator
  function _addOperator(address newOperator) internal {
    operator[newOperator] = true;
    emit AddOperator(newOperator);
  }

  // Remove old operator
  function _removeOperator(address oldOperator) internal {
    if (!operator[oldOperator]) {
      revert InvalidOperator(oldOperator);
    }
    operator[oldOperator] = false;
    emit RemoveOperator(oldOperator);
  }

  /*******************************************************
   * Manager section
   ********************************************************/

  // Add new operator
  function addOperator(address newOperator) external onlyOwner onlyValidAddress(newOperator) returns (bool) {
    _addOperator(newOperator);
    return true;
  }

  // Remove old operator
  function removeOperator(address oldOperator) external onlyOwner returns (bool) {
    _removeOperator(oldOperator);
    return true;
  }

  /*******************************************************
   * Operator section
   ********************************************************/

  // Upgrade new implementation
  function upgradeImplementation(
    address newImplementation
  ) external onlyOperator onlyValidAddress(newImplementation) returns (bool) {
    // Overwrite current implementation address
    implementation = newImplementation;
    emit UpgradeImplementation(implementation, newImplementation);
    return true;
  }

  /*******************************************************
   * External section
   ********************************************************/

  // Create new multisig wallet
  function createWallet(
    uint96 salt,
    address[] memory userList,
    uint256[] memory roleList,
    uint256 votingThreshold
  ) external nonReentrant returns (address newWalletAdress) {
    newWalletAdress = implementation.cloneDeterministic(_packing(salt, msg.sender));
    if (newWalletAdress == address(0) || !IOrosignV1(newWalletAdress).init(userList, roleList, votingThreshold)) {
      revert UnableToInitNewWallet(salt, msg.sender, newWalletAdress);
    }
    emit CreateNewWallet(salt, msg.sender, newWalletAdress);
    return newWalletAdress;
  }

  /*******************************************************
   * Internal View section
   ********************************************************/

  // Packing address and uint96 to a single bytes32
  // 96 bits a ++ 160 bits b
  function _packing(uint96 a, address b) internal pure returns (bytes32 packed) {
    assembly {
      packed := or(shl(160, a), b)
    }
  }

  // Calculate deterministic address
  function _predictWalletAddress(uint96 salt, address creatorAddress) internal view returns (address predictedAddress) {
    return implementation.predictDeterministicAddress(_packing(salt, creatorAddress));
  }

  // Check a smart contract is existed
  function _isContractExist(address walletAddress) internal view returns (bool isExist) {
    return walletAddress.code.length > 0;
  }

  /*******************************************************
   * View section
   ********************************************************/

  // Get metadata of Orosign Master V1
  function getMetadata() external view returns (uint256 sChainId, address sImplementation) {
    sChainId = block.chainid;
    sImplementation = implementation;
  }

  // Calculate deterministic address
  function predictWalletAddress(uint96 salt, address creatorAddress) external view returns (address predictedAddress) {
    return _predictWalletAddress(salt, creatorAddress);
  }

  // Check a smart contract is existed
  function isContractExist(address walletAddress) external view returns (bool isExist) {
    return _isContractExist(walletAddress);
  }

  // Check a Multi Signature Wallet existing by creator and salt
  function isMultiSigExist(uint96 salt, address creatorAddress) external view returns (bool isExist) {
    return _isContractExist(_predictWalletAddress(salt, creatorAddress));
  }

  // Pacing salt and creator address
  function packingSalt(uint96 salt, address creatorAddress) external pure returns (uint256 packedSalt) {
    return uint256(_packing(salt, creatorAddress));
  }
}