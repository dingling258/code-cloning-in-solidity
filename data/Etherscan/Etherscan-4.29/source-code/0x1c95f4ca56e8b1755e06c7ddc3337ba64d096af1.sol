{{
  "sources": {
    "lib/openzeppelin-contracts/contracts/access/Ownable.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)\n\npragma solidity ^0.8.0;\n\nimport \"../utils/Context.sol\";\n\n/**\n * @dev Contract module which provides a basic access control mechanism, where\n * there is an account (an owner) that can be granted exclusive access to\n * specific functions.\n *\n * By default, the owner account will be the one that deploys the contract. This\n * can later be changed with {transferOwnership}.\n *\n * This module is used through inheritance. It will make available the modifier\n * `onlyOwner`, which can be applied to your functions to restrict their use to\n * the owner.\n */\nabstract contract Ownable is Context {\n    address private _owner;\n\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    /**\n     * @dev Initializes the contract setting the deployer as the initial owner.\n     */\n    constructor() {\n        _transferOwnership(_msgSender());\n    }\n\n    /**\n     * @dev Throws if called by any account other than the owner.\n     */\n    modifier onlyOwner() {\n        _checkOwner();\n        _;\n    }\n\n    /**\n     * @dev Returns the address of the current owner.\n     */\n    function owner() public view virtual returns (address) {\n        return _owner;\n    }\n\n    /**\n     * @dev Throws if the sender is not the owner.\n     */\n    function _checkOwner() internal view virtual {\n        require(owner() == _msgSender(), \"Ownable: caller is not the owner\");\n    }\n\n    /**\n     * @dev Leaves the contract without owner. It will not be possible to call\n     * `onlyOwner` functions. Can only be called by the current owner.\n     *\n     * NOTE: Renouncing ownership will leave the contract without an owner,\n     * thereby disabling any functionality that is only available to the owner.\n     */\n    function renounceOwnership() public virtual onlyOwner {\n        _transferOwnership(address(0));\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Can only be called by the current owner.\n     */\n    function transferOwnership(address newOwner) public virtual onlyOwner {\n        require(newOwner != address(0), \"Ownable: new owner is the zero address\");\n        _transferOwnership(newOwner);\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Internal function without access restriction.\n     */\n    function _transferOwnership(address newOwner) internal virtual {\n        address oldOwner = _owner;\n        _owner = newOwner;\n        emit OwnershipTransferred(oldOwner, newOwner);\n    }\n}\n"
    },
    "lib/openzeppelin-contracts/contracts/utils/Context.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes calldata) {\n        return msg.data;\n    }\n}\n"
    },
    "lib/openzeppelin-contracts/contracts/utils/structs/EnumerableSet.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.9.0) (utils/structs/EnumerableSet.sol)\n// This file was procedurally generated from scripts/generate/templates/EnumerableSet.js.\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Library for managing\n * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive\n * types.\n *\n * Sets have the following properties:\n *\n * - Elements are added, removed, and checked for existence in constant time\n * (O(1)).\n * - Elements are enumerated in O(n). No guarantees are made on the ordering.\n *\n * ```solidity\n * contract Example {\n *     // Add the library methods\n *     using EnumerableSet for EnumerableSet.AddressSet;\n *\n *     // Declare a set state variable\n *     EnumerableSet.AddressSet private mySet;\n * }\n * ```\n *\n * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)\n * and `uint256` (`UintSet`) are supported.\n *\n * [WARNING]\n * ====\n * Trying to delete such a structure from storage will likely result in data corruption, rendering the structure\n * unusable.\n * See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.\n *\n * In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an\n * array of EnumerableSet.\n * ====\n */\nlibrary EnumerableSet {\n    // To implement this library for multiple types with as little code\n    // repetition as possible, we write it in terms of a generic Set type with\n    // bytes32 values.\n    // The Set implementation uses private functions, and user-facing\n    // implementations (such as AddressSet) are just wrappers around the\n    // underlying Set.\n    // This means that we can only create new EnumerableSets for types that fit\n    // in bytes32.\n\n    struct Set {\n        // Storage of set values\n        bytes32[] _values;\n        // Position of the value in the `values` array, plus 1 because index 0\n        // means a value is not in the set.\n        mapping(bytes32 => uint256) _indexes;\n    }\n\n    /**\n     * @dev Add a value to a set. O(1).\n     *\n     * Returns true if the value was added to the set, that is if it was not\n     * already present.\n     */\n    function _add(Set storage set, bytes32 value) private returns (bool) {\n        if (!_contains(set, value)) {\n            set._values.push(value);\n            // The value is stored at length-1, but we add 1 to all indexes\n            // and use 0 as a sentinel value\n            set._indexes[value] = set._values.length;\n            return true;\n        } else {\n            return false;\n        }\n    }\n\n    /**\n     * @dev Removes a value from a set. O(1).\n     *\n     * Returns true if the value was removed from the set, that is if it was\n     * present.\n     */\n    function _remove(Set storage set, bytes32 value) private returns (bool) {\n        // We read and store the value's index to prevent multiple reads from the same storage slot\n        uint256 valueIndex = set._indexes[value];\n\n        if (valueIndex != 0) {\n            // Equivalent to contains(set, value)\n            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in\n            // the array, and then remove the last element (sometimes called as 'swap and pop').\n            // This modifies the order of the array, as noted in {at}.\n\n            uint256 toDeleteIndex = valueIndex - 1;\n            uint256 lastIndex = set._values.length - 1;\n\n            if (lastIndex != toDeleteIndex) {\n                bytes32 lastValue = set._values[lastIndex];\n\n                // Move the last value to the index where the value to delete is\n                set._values[toDeleteIndex] = lastValue;\n                // Update the index for the moved value\n                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex\n            }\n\n            // Delete the slot where the moved value was stored\n            set._values.pop();\n\n            // Delete the index for the deleted slot\n            delete set._indexes[value];\n\n            return true;\n        } else {\n            return false;\n        }\n    }\n\n    /**\n     * @dev Returns true if the value is in the set. O(1).\n     */\n    function _contains(Set storage set, bytes32 value) private view returns (bool) {\n        return set._indexes[value] != 0;\n    }\n\n    /**\n     * @dev Returns the number of values on the set. O(1).\n     */\n    function _length(Set storage set) private view returns (uint256) {\n        return set._values.length;\n    }\n\n    /**\n     * @dev Returns the value stored at position `index` in the set. O(1).\n     *\n     * Note that there are no guarantees on the ordering of values inside the\n     * array, and it may change when more values are added or removed.\n     *\n     * Requirements:\n     *\n     * - `index` must be strictly less than {length}.\n     */\n    function _at(Set storage set, uint256 index) private view returns (bytes32) {\n        return set._values[index];\n    }\n\n    /**\n     * @dev Return the entire set in an array\n     *\n     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed\n     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that\n     * this function has an unbounded cost, and using it as part of a state-changing function may render the function\n     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.\n     */\n    function _values(Set storage set) private view returns (bytes32[] memory) {\n        return set._values;\n    }\n\n    // Bytes32Set\n\n    struct Bytes32Set {\n        Set _inner;\n    }\n\n    /**\n     * @dev Add a value to a set. O(1).\n     *\n     * Returns true if the value was added to the set, that is if it was not\n     * already present.\n     */\n    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {\n        return _add(set._inner, value);\n    }\n\n    /**\n     * @dev Removes a value from a set. O(1).\n     *\n     * Returns true if the value was removed from the set, that is if it was\n     * present.\n     */\n    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {\n        return _remove(set._inner, value);\n    }\n\n    /**\n     * @dev Returns true if the value is in the set. O(1).\n     */\n    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {\n        return _contains(set._inner, value);\n    }\n\n    /**\n     * @dev Returns the number of values in the set. O(1).\n     */\n    function length(Bytes32Set storage set) internal view returns (uint256) {\n        return _length(set._inner);\n    }\n\n    /**\n     * @dev Returns the value stored at position `index` in the set. O(1).\n     *\n     * Note that there are no guarantees on the ordering of values inside the\n     * array, and it may change when more values are added or removed.\n     *\n     * Requirements:\n     *\n     * - `index` must be strictly less than {length}.\n     */\n    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {\n        return _at(set._inner, index);\n    }\n\n    /**\n     * @dev Return the entire set in an array\n     *\n     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed\n     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that\n     * this function has an unbounded cost, and using it as part of a state-changing function may render the function\n     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.\n     */\n    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {\n        bytes32[] memory store = _values(set._inner);\n        bytes32[] memory result;\n\n        /// @solidity memory-safe-assembly\n        assembly {\n            result := store\n        }\n\n        return result;\n    }\n\n    // AddressSet\n\n    struct AddressSet {\n        Set _inner;\n    }\n\n    /**\n     * @dev Add a value to a set. O(1).\n     *\n     * Returns true if the value was added to the set, that is if it was not\n     * already present.\n     */\n    function add(AddressSet storage set, address value) internal returns (bool) {\n        return _add(set._inner, bytes32(uint256(uint160(value))));\n    }\n\n    /**\n     * @dev Removes a value from a set. O(1).\n     *\n     * Returns true if the value was removed from the set, that is if it was\n     * present.\n     */\n    function remove(AddressSet storage set, address value) internal returns (bool) {\n        return _remove(set._inner, bytes32(uint256(uint160(value))));\n    }\n\n    /**\n     * @dev Returns true if the value is in the set. O(1).\n     */\n    function contains(AddressSet storage set, address value) internal view returns (bool) {\n        return _contains(set._inner, bytes32(uint256(uint160(value))));\n    }\n\n    /**\n     * @dev Returns the number of values in the set. O(1).\n     */\n    function length(AddressSet storage set) internal view returns (uint256) {\n        return _length(set._inner);\n    }\n\n    /**\n     * @dev Returns the value stored at position `index` in the set. O(1).\n     *\n     * Note that there are no guarantees on the ordering of values inside the\n     * array, and it may change when more values are added or removed.\n     *\n     * Requirements:\n     *\n     * - `index` must be strictly less than {length}.\n     */\n    function at(AddressSet storage set, uint256 index) internal view returns (address) {\n        return address(uint160(uint256(_at(set._inner, index))));\n    }\n\n    /**\n     * @dev Return the entire set in an array\n     *\n     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed\n     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that\n     * this function has an unbounded cost, and using it as part of a state-changing function may render the function\n     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.\n     */\n    function values(AddressSet storage set) internal view returns (address[] memory) {\n        bytes32[] memory store = _values(set._inner);\n        address[] memory result;\n\n        /// @solidity memory-safe-assembly\n        assembly {\n            result := store\n        }\n\n        return result;\n    }\n\n    // UintSet\n\n    struct UintSet {\n        Set _inner;\n    }\n\n    /**\n     * @dev Add a value to a set. O(1).\n     *\n     * Returns true if the value was added to the set, that is if it was not\n     * already present.\n     */\n    function add(UintSet storage set, uint256 value) internal returns (bool) {\n        return _add(set._inner, bytes32(value));\n    }\n\n    /**\n     * @dev Removes a value from a set. O(1).\n     *\n     * Returns true if the value was removed from the set, that is if it was\n     * present.\n     */\n    function remove(UintSet storage set, uint256 value) internal returns (bool) {\n        return _remove(set._inner, bytes32(value));\n    }\n\n    /**\n     * @dev Returns true if the value is in the set. O(1).\n     */\n    function contains(UintSet storage set, uint256 value) internal view returns (bool) {\n        return _contains(set._inner, bytes32(value));\n    }\n\n    /**\n     * @dev Returns the number of values in the set. O(1).\n     */\n    function length(UintSet storage set) internal view returns (uint256) {\n        return _length(set._inner);\n    }\n\n    /**\n     * @dev Returns the value stored at position `index` in the set. O(1).\n     *\n     * Note that there are no guarantees on the ordering of values inside the\n     * array, and it may change when more values are added or removed.\n     *\n     * Requirements:\n     *\n     * - `index` must be strictly less than {length}.\n     */\n    function at(UintSet storage set, uint256 index) internal view returns (uint256) {\n        return uint256(_at(set._inner, index));\n    }\n\n    /**\n     * @dev Return the entire set in an array\n     *\n     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed\n     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that\n     * this function has an unbounded cost, and using it as part of a state-changing function may render the function\n     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.\n     */\n    function values(UintSet storage set) internal view returns (uint256[] memory) {\n        bytes32[] memory store = _values(set._inner);\n        uint256[] memory result;\n\n        /// @solidity memory-safe-assembly\n        assembly {\n            result := store\n        }\n\n        return result;\n    }\n}\n"
    },
    "lib/unlockdv2-wallet/src/libs/helpers/Errors.sol": {
      "content": "// SPDX-License-Identifier: agpl-3.0\npragma solidity 0.8.19;\n\nlibrary Errors {\n    // ========== General ===========\n    error Caller_notProtocol();\n    error Caller_notGovernanceAdmin();\n    error Caller_notAdmin();\n    // ========== Delegation Recipes ===========\n    error DelegationRecipes__add_arityMismatch();\n    error DelegationRecipes__remove_arityMismatch();\n\n    // ========== Delegation Owner ===========\n\n    error DelegationGuard__initialize_invalidGuardBeacon();\n    error DelegationGuard__initialize_invalidRecipes();\n    error DelegationGuard__initialize_invalidSafe();\n    error DelegationGuard__initialize_invalidOwner();\n    error DelegationGuard__initialize_aclManager();\n    error DelegationOwner__assetNotLocked();\n    error DelegationOwner__wrongLoanId();\n    error DelegationOwner__assetAlreadyLocked();\n    error DelegationOwner__collectionNotAllowed();\n    error DelegationOwner__onlyOwner();\n    error DelegationOwner__onlyDelegationController();\n    error DelegationOwner__onlyLockController();\n    error DelegationOwner__onlyDelegationCreator();\n    error DelegationOwner__onlySignatureDelegationCreator();\n    error DelegationOwner__onlyLockCreator();\n\n    error DelegationOwner__delegate_currentlyDelegated();\n    error DelegationOwner__delegate_invalidDelegatee();\n    error DelegationOwner__delegate_invalidDuration();\n    error DelegationOwner__delegate_assetLocked();\n\n    error DelegationOwner__deposit_collectionNotAllowed();\n    error DelegationOwner__delegateSignature_invalidArity();\n    error DelegationOwner__delegateSignature_currentlyDelegated();\n    error DelegationOwner__delegateSignature_invalidDelegatee();\n    error DelegationOwner__delegateSignature_invalidDuration();\n    error DelegationOwner__endDelegateSignature_invalidArity();\n\n    error DelegationOwner__isValidSignature_notDelegated();\n    error DelegationOwner__isValidSignature_invalidSigner();\n    error DelegationOwner__isValidSignature_invalidExecSig();\n\n    error DelegationOwner__execTransaction_notDelegated();\n    error DelegationOwner__execTransaction_invalidDelegatee();\n    error DelegationOwner__execTransaction_notAllowedFunction();\n    error DelegationOwner__execTransaction_notSuccess();\n\n    error DelegationOwner__lockAsset_assetLocked();\n    error DelegationOwner__lockAsset_invalidClaimDate();\n\n    error DelegationOwner__changeClaimDate_invalidClaimDate();\n\n    error DelegationOwner__claimAsset_assetNotClaimable();\n    error DelegationOwner__claimAsset_assetLocked();\n    error DelegationOwner__claimAsset_notSuccess();\n\n    error DelegationOwner__changeOwner_notSuccess();\n    error DelegationOwner__transferAsset_assetNotOwned();\n    error DelegationOwner__approveAsset_assetNotOwned();\n\n    error DelegationOwner__checkOwnedAndNotApproved_assetNotOwned();\n    error DelegationOwner__checkOwnedAndNotApproved_assetApproved();\n\n    error DelegationOwner__checkClaimDate_assetDelegatedLonger();\n    error DelegationOwner__checkClaimDate_signatureDelegatedLonger();\n\n    error DelegationOwner__lockCreatorChecks_assetNotLocked();\n    error DelegationOwner__lockCreatorChecks_onlyLockCreator();\n\n    error DelegationOwner__delegationCreatorChecks_notDelegated();\n    error DelegationOwner__delegationCreatorChecks_onlyDelegationCreator();\n\n    error DelegationOwner__setDelegationController_notAllowedController();\n    error DelegationOwner__setLockController_notAllowedController();\n\n    error DelegationOwner__batchSetLoanId_arityMismatch();\n    // ========== Guard Owner ===========\n    error GuardOwner__initialize_aclManager();\n    error GuardOwner__initialize_invalidGuardBeacon();\n    error GuardOwner__initialize_invalidSafe();\n    error GuardOwner__initialize_invalidOwner();\n    error GuardOwner__initialize_invalidDelegationOwner();\n    error GuardOwner__initialize_invalidProtocolOwner();\n\n    // ========== Transaction Guard ===========\n    error TransactionGuard__onlyManagersOwner();\n    error TransactionGuard__initialize_invalidDelegationOwner();\n    error TransactionGuard__initialize_invalidProtocolOwner();\n    error TransactionGuard__checkTransaction_noDelegateCall();\n    error TransactionGuard__checkApproveForAll_noApprovalForAll();\n\n    error TransactionGuard__checkLocked_noTransfer();\n    error TransactionGuard__checkLocked_noApproval();\n    error TransactionGuard__checkLocked_noBurn();\n    error TransactionGuard__checkConfiguration_ownershipChangesNotAllowed();\n    error TransactionGuard__checkConfiguration_guardChangeNotAllowed();\n    error TransactionGuard__checkConfiguration_enableModuleNotAllowed();\n    error TransactionGuard__checkConfiguration_setFallbackHandlerNotAllowed();\n\n    // ========== Allowed Collection ===========\n    error AllowedCollections__setCollectionsAllowances_invalidAddress();\n    error AllowedCollections__setCollectionsAllowances_arityMismatch();\n\n    error AllowedControllers__setLockControllerAllowances_arityMismatch();\n    error AllowedControllers__setDelegationControllerAllowances_arityMismatch();\n    error AllowedControllers__setDelegationControllerAllowance_invalidAddress();\n\n    // ========== Delegation Wallet Registry ===========\n    error DelegationWalletRegistry__onlyFactoryOrOwner();\n\n    error DelegationWalletRegistry__setFactory_invalidAddress();\n\n    error DelegationWalletRegistry__setWallet_invalidWalletAddress();\n    error DelegationWalletRegistry__setWallet_invalidOwnerAddress();\n    error DelegationWalletRegistry__setWallet_invalidDelegationOwnerAddress();\n    error DelegationWalletRegistry__setWallet_invalidGuardAddress();\n    error DelegationWalletRegistry__setWallet_invalidProtocolOwnerAddress();\n\n    // ========== Protocol OWNER ===========\n    error ProtocolOwner__invalidDelegatedAddressAddress();\n    error ProtocolOwner__execTransaction_notSuccess();\n}\n"
    },
    "lib/unlockdv2-wallet/src/libs/recipes/DelegationRecipes.sol": {
      "content": "// SPDX-License-Identifier: BUSL-1.1\n\npragma solidity 0.8.19;\n\nimport { Ownable } from \"@openzeppelin/contracts/access/Ownable.sol\";\nimport { EnumerableSet } from \"@openzeppelin/contracts/utils/structs/EnumerableSet.sol\";\nimport { Errors } from \"../helpers/Errors.sol\";\n\n/**\n * @title DelegationRecipes\n * @author BootNode\n * @dev Registers the functions that will be allowed to be executed by assets delegates.\n * Functions are grouped by target contract and asset collection.\n */\ncontract DelegationRecipes is Ownable {\n    using EnumerableSet for EnumerableSet.Bytes32Set;\n\n    // collection address -> keccak256(collection, contract, selector)\n    mapping(address => EnumerableSet.Bytes32Set) internal functionByCollection;\n\n    // keccak256(collection, contract, selector) -> description\n    mapping(bytes32 => string) public functionDescriptions;\n\n    event AddRecipe(address indexed collection, address[] contracts, bytes4[] selectors, string[] description);\n\n    event RemoveRecipe(address indexed collection, address[] contracts, bytes4[] selectors);\n\n    /**\n     * @notice Adds a group of allowed functions to a collection.\n     * @param _collection - The asset collection address.\n     * @param _contracts - The target contract addresses.\n     * @param _selectors - The allowed function selectors.\n     */\n    function add(\n        address _collection,\n        address[] calldata _contracts,\n        bytes4[] calldata _selectors,\n        string[] calldata _descriptions\n    ) external onlyOwner {\n        if (_contracts.length != _selectors.length || _selectors.length != _descriptions.length)\n            revert Errors.DelegationRecipes__add_arityMismatch();\n\n        bytes32 functionId;\n        uint256 length = _contracts.length;\n        for (uint256 i; i < length; ) {\n            functionId = keccak256(abi.encodePacked(_collection, _contracts[i], _selectors[i]));\n            functionByCollection[_collection].add(functionId);\n            functionDescriptions[functionId] = _descriptions[i];\n\n            emit AddRecipe(_collection, _contracts, _selectors, _descriptions);\n\n            unchecked {\n                ++i;\n            }\n        }\n    }\n\n    /**\n     * @notice Removes a group of allowed functions from a collection.\n     * @param _collection - The owner's address.\n     * @param _contracts - The owner's address.\n     * @param _selectors - The owner's address.\n     */\n    function remove(\n        address _collection,\n        address[] calldata _contracts,\n        bytes4[] calldata _selectors\n    ) external onlyOwner {\n        if (_contracts.length != _selectors.length) revert Errors.DelegationRecipes__remove_arityMismatch();\n\n        bytes32 functionId;\n        uint256 length = _contracts.length;\n        for (uint256 i; i < length; ) {\n            functionId = keccak256(abi.encodePacked(_collection, _contracts[i], _selectors[i]));\n            functionByCollection[_collection].remove(functionId);\n            delete functionDescriptions[functionId];\n\n            emit RemoveRecipe(_collection, _contracts, _selectors);\n\n            unchecked {\n                ++i;\n            }\n        }\n    }\n\n    /**\n     * @notice Checks if a function is allowed for a collection.\n     * @param _collection - The owner's address.\n     * @param _contract - The owner's address.\n     * @param _selector - The owner's address.\n     */\n    function isAllowedFunction(address _collection, address _contract, bytes4 _selector) external view returns (bool) {\n        bytes32 functionId = keccak256(abi.encodePacked(_collection, _contract, _selector));\n        return functionByCollection[_collection].contains(functionId);\n    }\n}\n"
    }
  },
  "settings": {
    "remappings": [
      "ds-test/=lib/forge-std/lib/ds-test/src/",
      "forge-std/=lib/forge-std/src/",
      "solady/=lib/solady/src/",
      "@openzeppelin/=lib/openzeppelin-contracts/",
      "@openzeppelin-upgradeable/=lib/openzeppelin-contracts-upgradeable/",
      "@chainlink/=lib/chainlink/",
      "@unlockd-wallet/=lib/unlockdv2-wallet/",
      "@solady/=lib/solady/src/",
      "@maxapy/=lib/maxapy/src/",
      "@gnosis.pm/safe-contracts/=lib/unlockdv2-wallet/lib/safe-contracts/",
      "chainlink/=lib/chainlink/",
      "erc4626-tests/=lib/openzeppelin-contracts/lib/erc4626-tests/",
      "maxapy/=lib/maxapy/",
      "openzeppelin-contracts-upgradeable/=lib/openzeppelin-contracts-upgradeable/",
      "openzeppelin-contracts/=lib/openzeppelin-contracts/",
      "openzeppelin/=lib/openzeppelin-contracts/contracts/",
      "safe-contracts/=lib/unlockdv2-wallet/lib/safe-contracts/contracts/",
      "unlockdv2-wallet/=lib/unlockdv2-wallet/src/"
    ],
    "optimizer": {
      "enabled": true,
      "runs": 200
    },
    "metadata": {
      "useLiteralContent": false,
      "bytecodeHash": "ipfs",
      "appendCBOR": true
    },
    "outputSelection": {
      "*": {
        "*": [
          "evm.bytecode",
          "evm.deployedBytecode",
          "devdoc",
          "userdoc",
          "metadata",
          "abi"
        ]
      }
    },
    "evmVersion": "paris",
    "libraries": {}
  },
  "language": "Solidity"
}}