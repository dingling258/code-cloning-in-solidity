{{
  "language": "Solidity",
  "settings": {
    "evmVersion": "london",
    "libraries": {},
    "metadata": {
      "bytecodeHash": "none",
      "useLiteralContent": true
    },
    "optimizer": {
      "enabled": true,
      "runs": 10
    },
    "remappings": [],
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
    }
  },
  "sources": {
    "@openzeppelin/contracts/utils/StorageSlot.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.9.0) (utils/StorageSlot.sol)\n// This file was procedurally generated from scripts/generate/templates/StorageSlot.js.\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Library for reading and writing primitive types to specific storage slots.\n *\n * Storage slots are often used to avoid storage conflict when dealing with upgradeable contracts.\n * This library helps with reading and writing to such slots without the need for inline assembly.\n *\n * The functions in this library return Slot structs that contain a `value` member that can be used to read or write.\n *\n * Example usage to set ERC1967 implementation slot:\n * ```solidity\n * contract ERC1967 {\n *     bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;\n *\n *     function _getImplementation() internal view returns (address) {\n *         return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;\n *     }\n *\n *     function _setImplementation(address newImplementation) internal {\n *         require(Address.isContract(newImplementation), \"ERC1967: new implementation is not a contract\");\n *         StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;\n *     }\n * }\n * ```\n *\n * _Available since v4.1 for `address`, `bool`, `bytes32`, `uint256`._\n * _Available since v4.9 for `string`, `bytes`._\n */\nlibrary StorageSlot {\n    struct AddressSlot {\n        address value;\n    }\n\n    struct BooleanSlot {\n        bool value;\n    }\n\n    struct Bytes32Slot {\n        bytes32 value;\n    }\n\n    struct Uint256Slot {\n        uint256 value;\n    }\n\n    struct StringSlot {\n        string value;\n    }\n\n    struct BytesSlot {\n        bytes value;\n    }\n\n    /**\n     * @dev Returns an `AddressSlot` with member `value` located at `slot`.\n     */\n    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {\n        /// @solidity memory-safe-assembly\n        assembly {\n            r.slot := slot\n        }\n    }\n\n    /**\n     * @dev Returns an `BooleanSlot` with member `value` located at `slot`.\n     */\n    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {\n        /// @solidity memory-safe-assembly\n        assembly {\n            r.slot := slot\n        }\n    }\n\n    /**\n     * @dev Returns an `Bytes32Slot` with member `value` located at `slot`.\n     */\n    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {\n        /// @solidity memory-safe-assembly\n        assembly {\n            r.slot := slot\n        }\n    }\n\n    /**\n     * @dev Returns an `Uint256Slot` with member `value` located at `slot`.\n     */\n    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {\n        /// @solidity memory-safe-assembly\n        assembly {\n            r.slot := slot\n        }\n    }\n\n    /**\n     * @dev Returns an `StringSlot` with member `value` located at `slot`.\n     */\n    function getStringSlot(bytes32 slot) internal pure returns (StringSlot storage r) {\n        /// @solidity memory-safe-assembly\n        assembly {\n            r.slot := slot\n        }\n    }\n\n    /**\n     * @dev Returns an `StringSlot` representation of the string storage pointer `store`.\n     */\n    function getStringSlot(string storage store) internal pure returns (StringSlot storage r) {\n        /// @solidity memory-safe-assembly\n        assembly {\n            r.slot := store.slot\n        }\n    }\n\n    /**\n     * @dev Returns an `BytesSlot` with member `value` located at `slot`.\n     */\n    function getBytesSlot(bytes32 slot) internal pure returns (BytesSlot storage r) {\n        /// @solidity memory-safe-assembly\n        assembly {\n            r.slot := slot\n        }\n    }\n\n    /**\n     * @dev Returns an `BytesSlot` representation of the bytes storage pointer `store`.\n     */\n    function getBytesSlot(bytes storage store) internal pure returns (BytesSlot storage r) {\n        /// @solidity memory-safe-assembly\n        assembly {\n            r.slot := store.slot\n        }\n    }\n}\n"
    },
    "contracts/common/diamonds/facets/DiamondProxyFacet.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity 0.8.23;\n\nimport { LibDiamond } from \"../libraries/LibDiamond.sol\";\nimport { LibDiamondEtherscan } from \"../libraries/LibDiamondEtherscan.sol\";\n\ncontract DiamondProxyFacet {\n    function setDummyImplementation(address _implementation) external {\n        LibDiamond.enforceIsContractOwner();\n        LibDiamondEtherscan._setDummyImplementation(_implementation);\n    }\n\n    function implementation() external view returns (address) {\n        return LibDiamondEtherscan._dummyImplementation();\n    }\n}\n"
    },
    "contracts/common/diamonds/interfaces/IDiamondCut.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity 0.8.23;\n\n/******************************************************************************\\\n* Author: Nick Mudge <nick@perfectabstractions.com> (https://twitter.com/mudgen)\n* EIP-2535 Diamonds: https://eips.ethereum.org/EIPS/eip-2535\n/******************************************************************************/\n\ninterface IDiamondCut {\n    enum FacetCutAction {\n        Add,\n        Replace,\n        Remove\n    }\n    // Add=0, Replace=1, Remove=2\n\n    struct FacetCut {\n        address facetAddress;\n        FacetCutAction action;\n        bytes4[] functionSelectors;\n    }\n\n    /// @notice Add/replace/remove any number of functions and optionally execute\n    ///         a function with delegatecall\n    /// @param _diamondCut Contains the facet addresses and function selectors\n    /// @param _init The address of the contract or facet to execute _calldata\n    /// @param _calldata A function call, including function selector and arguments\n    ///                  _calldata is executed with delegatecall on _init\n    function diamondCut(FacetCut[] calldata _diamondCut, address _init, bytes calldata _calldata) external;\n}\n"
    },
    "contracts/common/diamonds/libraries/LibDiamond.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity 0.8.23;\n\n/******************************************************************************\\\n* Author: Nick Mudge <nick@perfectabstractions.com> (https://twitter.com/mudgen)\n* EIP-2535 Diamonds: https://eips.ethereum.org/EIPS/eip-2535\n/******************************************************************************/\nimport { IDiamondCut } from \"../interfaces/IDiamondCut.sol\";\n\n// Remember to add the loupe functions from DiamondLoupeFacet to the diamond.\n// The loupe functions are required by the EIP2535 Diamonds standard\n\nerror InitializationFunctionReverted(address _initializationContractAddress, bytes _calldata);\n\nlibrary LibDiamond {\n    bytes32 public constant DIAMOND_STORAGE_POSITION = keccak256(\"diamond.standard.diamond.storage\");\n\n    struct FacetAddressAndPosition {\n        address facetAddress;\n        uint96 functionSelectorPosition; // position in facetFunctionSelectors.functionSelectors array\n    }\n\n    struct FacetFunctionSelectors {\n        bytes4[] functionSelectors;\n        uint256 facetAddressPosition; // position of facetAddress in facetAddresses array\n    }\n\n    struct DiamondStorage {\n        // maps function selector to the facet address and\n        // the position of the selector in the facetFunctionSelectors.selectors array\n        mapping(bytes4 => FacetAddressAndPosition) selectorToFacetAndPosition;\n        // maps facet addresses to function selectors\n        mapping(address => FacetFunctionSelectors) facetFunctionSelectors;\n        // facet addresses\n        address[] facetAddresses;\n        // Used to query if a contract implements an interface.\n        // Used to implement ERC-165.\n        mapping(bytes4 => bool) supportedInterfaces;\n        // owner of the contract\n        address contractOwner;\n    }\n\n    function diamondStorage() internal pure returns (DiamondStorage storage ds) {\n        bytes32 position = DIAMOND_STORAGE_POSITION;\n        // solhint-disable-next-line no-inline-assembly\n        assembly {\n            ds.slot := position\n        }\n    }\n\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    function setContractOwner(address _newOwner) internal {\n        DiamondStorage storage ds = diamondStorage();\n        address previousOwner = ds.contractOwner;\n        ds.contractOwner = _newOwner;\n        emit OwnershipTransferred(previousOwner, _newOwner);\n    }\n\n    function contractOwner() internal view returns (address contractOwner_) {\n        contractOwner_ = diamondStorage().contractOwner;\n    }\n\n    function enforceIsContractOwner() internal view {\n        require(msg.sender == diamondStorage().contractOwner, \"LibDiamond: Must be contract owner\");\n    }\n\n    event DiamondCut(IDiamondCut.FacetCut[] _diamondCut, address _init, bytes _calldata);\n\n    // Internal function version of diamondCut\n    function diamondCut(IDiamondCut.FacetCut[] memory _diamondCut, address _init, bytes memory _calldata) internal {\n        for (uint256 facetIndex; facetIndex < _diamondCut.length; facetIndex++) {\n            IDiamondCut.FacetCutAction action = _diamondCut[facetIndex].action;\n            if (action == IDiamondCut.FacetCutAction.Add) {\n                addFunctions(_diamondCut[facetIndex].facetAddress, _diamondCut[facetIndex].functionSelectors);\n            } else if (action == IDiamondCut.FacetCutAction.Replace) {\n                replaceFunctions(_diamondCut[facetIndex].facetAddress, _diamondCut[facetIndex].functionSelectors);\n            } else if (action == IDiamondCut.FacetCutAction.Remove) {\n                removeFunctions(_diamondCut[facetIndex].facetAddress, _diamondCut[facetIndex].functionSelectors);\n            } else {\n                revert(\"LibDiamondCut: Incorrect FacetCutAction\");\n            }\n        }\n        emit DiamondCut(_diamondCut, _init, _calldata);\n        initializeDiamondCut(_init, _calldata);\n    }\n\n    function addFunctions(address _facetAddress, bytes4[] memory _functionSelectors) internal {\n        require(_functionSelectors.length > 0, \"LibDiamondCut: No selectors in facet to cut\");\n        DiamondStorage storage ds = diamondStorage();\n        require(_facetAddress != address(0), \"LibDiamondCut: Add facet can't be address(0)\");\n        uint96 selectorPosition = uint96(ds.facetFunctionSelectors[_facetAddress].functionSelectors.length);\n        // add new facet address if it does not exist\n        if (selectorPosition == 0) {\n            addFacet(ds, _facetAddress);\n        }\n        for (uint256 selectorIndex; selectorIndex < _functionSelectors.length; selectorIndex++) {\n            bytes4 selector = _functionSelectors[selectorIndex];\n            address oldFacetAddress = ds.selectorToFacetAndPosition[selector].facetAddress;\n            require(oldFacetAddress == address(0), \"LibDiamondCut: Can't add function that already exists\");\n            addFunction(ds, selector, selectorPosition, _facetAddress);\n            selectorPosition++;\n        }\n    }\n\n    function replaceFunctions(address _facetAddress, bytes4[] memory _functionSelectors) internal {\n        require(_functionSelectors.length > 0, \"LibDiamondCut: No selectors in facet to cut\");\n        DiamondStorage storage ds = diamondStorage();\n        require(_facetAddress != address(0), \"LibDiamondCut: Add facet can't be address(0)\");\n        uint96 selectorPosition = uint96(ds.facetFunctionSelectors[_facetAddress].functionSelectors.length);\n        // add new facet address if it does not exist\n        if (selectorPosition == 0) {\n            addFacet(ds, _facetAddress);\n        }\n        for (uint256 selectorIndex; selectorIndex < _functionSelectors.length; selectorIndex++) {\n            bytes4 selector = _functionSelectors[selectorIndex];\n            address oldFacetAddress = ds.selectorToFacetAndPosition[selector].facetAddress;\n            require(oldFacetAddress != _facetAddress, \"LibDiamondCut: Can't replace function with same function\");\n            removeFunction(ds, oldFacetAddress, selector);\n            addFunction(ds, selector, selectorPosition, _facetAddress);\n            selectorPosition++;\n        }\n    }\n\n    function removeFunctions(address _facetAddress, bytes4[] memory _functionSelectors) internal {\n        require(_functionSelectors.length > 0, \"LibDiamondCut: No selectors in facet to cut\");\n        DiamondStorage storage ds = diamondStorage();\n        // if function does not exist then do nothing and return\n        require(_facetAddress == address(0), \"LibDiamondCut: Remove facet address must be address(0)\");\n        for (uint256 selectorIndex; selectorIndex < _functionSelectors.length; selectorIndex++) {\n            bytes4 selector = _functionSelectors[selectorIndex];\n            address oldFacetAddress = ds.selectorToFacetAndPosition[selector].facetAddress;\n            removeFunction(ds, oldFacetAddress, selector);\n        }\n    }\n\n    function addFacet(DiamondStorage storage ds, address _facetAddress) internal {\n        enforceHasContractCode(_facetAddress, \"LibDiamondCut: New facet has no code\");\n        ds.facetFunctionSelectors[_facetAddress].facetAddressPosition = ds.facetAddresses.length;\n        ds.facetAddresses.push(_facetAddress);\n    }\n\n    function addFunction(DiamondStorage storage ds, bytes4 _selector, uint96 _selectorPosition, address _facetAddress) internal {\n        ds.selectorToFacetAndPosition[_selector].functionSelectorPosition = _selectorPosition;\n        ds.facetFunctionSelectors[_facetAddress].functionSelectors.push(_selector);\n        ds.selectorToFacetAndPosition[_selector].facetAddress = _facetAddress;\n    }\n\n    function removeFunction(DiamondStorage storage ds, address _facetAddress, bytes4 _selector) internal {\n        require(_facetAddress != address(0), \"LibDiamondCut: Can't remove function that doesn't exist\");\n        // an immutable function is a function defined directly in a diamond\n        require(_facetAddress != address(this), \"LibDiamondCut: Can't remove immutable function\");\n        // replace selector with last selector, then delete last selector\n        uint256 selectorPosition = ds.selectorToFacetAndPosition[_selector].functionSelectorPosition;\n        uint256 lastSelectorPosition = ds.facetFunctionSelectors[_facetAddress].functionSelectors.length - 1;\n        // if not the same then replace _selector with lastSelector\n        if (selectorPosition != lastSelectorPosition) {\n            bytes4 lastSelector = ds.facetFunctionSelectors[_facetAddress].functionSelectors[lastSelectorPosition];\n            ds.facetFunctionSelectors[_facetAddress].functionSelectors[selectorPosition] = lastSelector;\n            ds.selectorToFacetAndPosition[lastSelector].functionSelectorPosition = uint96(selectorPosition);\n        }\n        // delete the last selector\n        ds.facetFunctionSelectors[_facetAddress].functionSelectors.pop();\n        delete ds.selectorToFacetAndPosition[_selector];\n\n        // if no more selectors for facet address then delete the facet address\n        if (lastSelectorPosition == 0) {\n            // replace facet address with last facet address and delete last facet address\n            uint256 lastFacetAddressPosition = ds.facetAddresses.length - 1;\n            uint256 facetAddressPosition = ds.facetFunctionSelectors[_facetAddress].facetAddressPosition;\n            if (facetAddressPosition != lastFacetAddressPosition) {\n                address lastFacetAddress = ds.facetAddresses[lastFacetAddressPosition];\n                ds.facetAddresses[facetAddressPosition] = lastFacetAddress;\n                ds.facetFunctionSelectors[lastFacetAddress].facetAddressPosition = facetAddressPosition;\n            }\n            ds.facetAddresses.pop();\n            delete ds.facetFunctionSelectors[_facetAddress].facetAddressPosition;\n        }\n    }\n\n    function initializeDiamondCut(address _init, bytes memory _calldata) internal {\n        if (_init == address(0)) {\n            return;\n        }\n        enforceHasContractCode(_init, \"LibDiamondCut: _init address has no code\");\n        (bool success, bytes memory error) = _init.delegatecall(_calldata);\n        if (!success) {\n            if (error.length > 0) {\n                // bubble up error\n                /// @solidity memory-safe-assembly\n                assembly {\n                    let returndata_size := mload(error)\n                    revert(add(32, error), returndata_size)\n                }\n            } else {\n                revert InitializationFunctionReverted(_init, _calldata);\n            }\n        }\n    }\n\n    function enforceHasContractCode(address _contract, string memory _errorMessage) internal view {\n        uint256 contractSize;\n        assembly {\n            contractSize := extcodesize(_contract)\n        }\n        require(contractSize > 0, _errorMessage);\n    }\n}\n"
    },
    "contracts/common/diamonds/libraries/LibDiamondEtherscan.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity 0.8.23;\n\n// solhint-disable-next-line\nimport \"@openzeppelin/contracts/utils/StorageSlot.sol\";\n\nlibrary LibDiamondEtherscan {\n    event Upgraded(address indexed implementation);\n\n    /**\n     * @dev Storage slot with the address of the current dummy-implementation.\n     * This is the keccak-256 hash of \"eip1967.proxy.implementation\" subtracted by 1\n     */\n    bytes32 internal constant IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;\n\n    function _setDummyImplementation(address implementationAddress) internal {\n        StorageSlot.getAddressSlot(IMPLEMENTATION_SLOT).value = implementationAddress;\n\n        emit Upgraded(implementationAddress);\n    }\n\n    function _dummyImplementation() internal view returns (address) {\n        return StorageSlot.getAddressSlot(IMPLEMENTATION_SLOT).value;\n    }\n}\n"
    }
  }
}}