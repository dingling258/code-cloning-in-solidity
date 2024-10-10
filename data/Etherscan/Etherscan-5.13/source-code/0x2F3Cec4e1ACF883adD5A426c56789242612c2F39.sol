{{
  "language": "Solidity",
  "sources": {
    "lib/openzeppelin-contracts/contracts/utils/introspection/IERC165.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v5.0.0) (utils/introspection/IERC165.sol)\n\npragma solidity ^0.8.20;\n\n/**\n * @dev Interface of the ERC165 standard, as defined in the\n * https://eips.ethereum.org/EIPS/eip-165[EIP].\n *\n * Implementers can declare support of contract interfaces, which can then be\n * queried by others ({ERC165Checker}).\n *\n * For an implementation, see {ERC165}.\n */\ninterface IERC165 {\n    /**\n     * @dev Returns true if this contract implements the interface defined by\n     * `interfaceId`. See the corresponding\n     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]\n     * to learn more about how these ids are created.\n     *\n     * This function call must use less than 30 000 gas.\n     */\n    function supportsInterface(bytes4 interfaceId) external view returns (bool);\n}\n"
    },
    "src/modules/ISmartAccountModules.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\n\ninterface ISmartAccountModules {\n    /// @notice When no function exists for function called\n    error FunctionNotFound(bytes4 functionSelector);\n\n    /// @notice Module is added/updated/removed.\n    event ModuleSet(bytes4 functionSelector, address module);\n\n    /// @notice Set the currently registered module for function.\n    /// @dev Zero address means no module is registered.\n    function getModule(bytes4 functionSelector) external view returns (address module);\n}\n"
    },
    "src/modules/SmartAccountModulesLib.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\n\nimport {SmartAccountERC165Lib} from \"./erc165/SmartAccountERC165Lib.sol\";\n\nimport {ISmartAccountModules} from \"./ISmartAccountModules.sol\";\n\n// Inspired by ERC-2535\nlibrary SmartAccountModulesLib {\n    bytes32 constant STORAGE_POSITION = keccak256(\"modules.smartaccount.plopmenz\");\n\n    struct Storage {\n        mapping(bytes4 functionSelector => address module) getFunction;\n    }\n\n    function getStorage() internal pure returns (Storage storage s) {\n        bytes32 position = STORAGE_POSITION;\n        assembly {\n            s.slot := position\n        }\n    }\n\n    /// @notice Sets the interfaces implemented by this contract to (un)supported.\n    function setInterfaces(bool supported) internal {\n        SmartAccountERC165Lib.setInterfaceSupport(type(ISmartAccountModules).interfaceId, supported);\n    }\n\n    /// @notice Installs all functions, interfaces, and performs storage initialization of this module.\n    function fullInstall(address module) internal {\n        setModule(ISmartAccountModules.getModule.selector, module);\n        setInterfaces(true);\n    }\n\n    /// @notice Uninstalls all functions and interfaces of this module.\n    function fullUninstall() internal {\n        setModule(ISmartAccountModules.getModule.selector, address(0));\n        setInterfaces(false);\n    }\n\n    /// @notice Get the currently registered module for function.\n    function getModule(bytes4 functionSelector) internal view returns (address module) {\n        return getStorage().getFunction[functionSelector];\n    }\n\n    /// @notice Set the currently registered module for function.\n    /// @dev Set to zero address to remove.\n    function setModule(bytes4 functionSelector, address module) internal {\n        getStorage().getFunction[functionSelector] = module;\n        emit ISmartAccountModules.ModuleSet(functionSelector, module);\n    }\n\n    /// @notice Delegates the current msg call to a module, if one is registered for that function.\n    function callModule() internal {\n        // Get module from function selector\n        address module = getModule(msg.sig);\n        if (module == address(0)) {\n            revert ISmartAccountModules.FunctionNotFound(msg.sig);\n        }\n        // Execute external function from module using delegatecall and return any value.\n        assembly {\n            // Copy function selector and any arguments\n            calldatacopy(0, 0, calldatasize())\n            // Execute function call using the module\n            let result := delegatecall(gas(), module, 0, calldatasize(), 0, 0)\n            // Get any return value\n            returndatacopy(0, 0, returndatasize())\n            // Return any return value or error back to the caller\n            switch result\n            case 0 { revert(0, returndatasize()) }\n            default { return(0, returndatasize()) }\n        }\n    }\n}\n"
    },
    "src/modules/erc165/ISmartAccountERC165.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\n\nimport {IERC165} from \"../../../lib/openzeppelin-contracts/contracts/utils/introspection/IERC165.sol\";\n\ninterface ISmartAccountERC165 is IERC165 {\n    /// @notice Interface support changed.\n    event InterfaceSupportedChanged(bytes4 indexed interfaceId, bool supported);\n}\n"
    },
    "src/modules/erc165/SmartAccountERC165Lib.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\n\nimport {SmartAccountModulesLib} from \"../SmartAccountModulesLib.sol\";\n\nimport {ISmartAccountERC165, IERC165} from \"./ISmartAccountERC165.sol\";\n\nlibrary SmartAccountERC165Lib {\n    bytes32 constant STORAGE_POSITION = keccak256(\"erc165.modules.smartaccount.plopmenz\");\n\n    struct Storage {\n        mapping(bytes4 interfaceId => bool supported) getSupported;\n    }\n\n    function getStorage() internal pure returns (Storage storage s) {\n        bytes32 position = STORAGE_POSITION;\n        assembly {\n            s.slot := position\n        }\n    }\n\n    /// @notice Installs all functions, interfaces, and performs storage initialization of this module.\n    function fullInstall(address module) internal {\n        SmartAccountModulesLib.setModule(IERC165.supportsInterface.selector, module);\n    }\n\n    /// @notice Uninstalls all functions and interfaces of this module.\n    function fullUninstall() internal {\n        SmartAccountModulesLib.setModule(IERC165.supportsInterface.selector, address(0));\n    }\n\n    /// @notice Gets the interfaces supported by the Smart Account.\n    function supportsInterface(bytes4 interfaceId) internal view returns (bool supported) {\n        return getStorage().getSupported[interfaceId];\n    }\n\n    /// @notice Updates the interfaces supported by the Smart Account.\n    function setInterfaceSupport(bytes4 interfaceId, bool supported) internal {\n        getStorage().getSupported[interfaceId] = supported;\n        emit ISmartAccountERC165.InterfaceSupportedChanged(interfaceId, supported);\n    }\n}\n"
    },
    "src/modules/ownable/ISmartAccountOwnable.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\n\ninterface ISmartAccountOwnable {\n    /// @notice The caller account is not authorized to perform an operation.\n    error NotOwner(address account, address owner);\n\n    /// @notice A (new) account has become the owner of this contract.\n    event NewOwner(address account);\n\n    /// @notice Returns the address of the current owner.\n    function owner() external view returns (address);\n}\n"
    },
    "src/modules/ownable/SmartAccountOwnable.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\n\nimport {SmartAccountOwnableLib, ISmartAccountOwnable} from \"./SmartAccountOwnableLib.sol\";\n\ncontract SmartAccountOwnable is ISmartAccountOwnable {\n    /// @inheritdoc ISmartAccountOwnable\n    function owner() external view returns (address) {\n        return SmartAccountOwnableLib.owner();\n    }\n}\n"
    },
    "src/modules/ownable/SmartAccountOwnableLib.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\n\nimport {SmartAccountERC165Lib} from \"../erc165/SmartAccountERC165Lib.sol\";\nimport {SmartAccountModulesLib} from \"../SmartAccountModulesLib.sol\";\n\nimport {ISmartAccountOwnable} from \"./ISmartAccountOwnable.sol\";\n\nlibrary SmartAccountOwnableLib {\n    bytes32 constant STORAGE_POSITION = keccak256(\"ownable.modules.smartaccount.plopmenz\");\n\n    struct Storage {\n        address owner;\n    }\n\n    function getStorage() internal pure returns (Storage storage s) {\n        bytes32 position = STORAGE_POSITION;\n        assembly {\n            s.slot := position\n        }\n    }\n\n    /// @notice Sets the interfaces implemented by this contract to (un)supported.\n    function setInterfaces(bool supported) internal {\n        SmartAccountERC165Lib.setInterfaceSupport(type(ISmartAccountOwnable).interfaceId, supported);\n    }\n\n    /// @notice Installs all functions, interfaces, and performs storage initialization of this module.\n    function fullInstall(address module, address initialOwner) internal {\n        SmartAccountOwnableLib.setOwner(initialOwner);\n        SmartAccountModulesLib.setModule(ISmartAccountOwnable.owner.selector, module);\n        setInterfaces(true);\n    }\n\n    /// @notice Uninstalls all functions and interfaces of this module.\n    function fullUninstall() internal {\n        SmartAccountModulesLib.setModule(ISmartAccountOwnable.owner.selector, address(0));\n        setInterfaces(false);\n    }\n\n    /// @notice Returns the address of the current owner.\n    function owner() internal view returns (address) {\n        return getStorage().owner;\n    }\n\n    /// @notice Reverts if `account` is not the current owner.\n    function ensureIsOwner(address account) internal view {\n        if (account != owner()) {\n            revert ISmartAccountOwnable.NotOwner(account, owner());\n        }\n    }\n\n    /// @notice Sets the address of the current owner.\n    function setOwner(address account) internal {\n        getStorage().owner = account;\n        emit ISmartAccountOwnable.NewOwner(account);\n    }\n}\n"
    }
  },
  "settings": {
    "remappings": [
      "@openzeppelin/contracts/=lib/openzeppelin-contracts/contracts/",
      "ds-test/=lib/openzeppelin-contracts/lib/forge-std/lib/ds-test/src/",
      "erc4626-tests/=lib/openzeppelin-contracts/lib/erc4626-tests/",
      "forge-std/=lib/forge-std/src/",
      "openzeppelin-contracts/=lib/openzeppelin-contracts/"
    ],
    "optimizer": {
      "enabled": true,
      "runs": 200
    },
    "evmVersion": "shanghai",
    "viaIR": true,
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
  }
}}