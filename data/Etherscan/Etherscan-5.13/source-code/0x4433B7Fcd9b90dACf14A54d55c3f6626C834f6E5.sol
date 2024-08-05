{{
  "language": "Solidity",
  "sources": {
    "lib/openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC721/IERC721Receiver.sol)\n\npragma solidity ^0.8.20;\n\n/**\n * @title ERC721 token receiver interface\n * @dev Interface for any contract that wants to support safeTransfers\n * from ERC721 asset contracts.\n */\ninterface IERC721Receiver {\n    /**\n     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}\n     * by `operator` from `from`, this function is called.\n     *\n     * It must return its Solidity selector to confirm the token transfer.\n     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be\n     * reverted.\n     *\n     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.\n     */\n    function onERC721Received(\n        address operator,\n        address from,\n        uint256 tokenId,\n        bytes calldata data\n    ) external returns (bytes4);\n}\n"
    },
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
    "src/modules/erc721-receiver/ISmartAccountERC721Receiver.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\n\nimport {IERC721Receiver} from \"../../../lib/openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol\";\n\ninterface ISmartAccountERC721Receiver is IERC721Receiver {}\n"
    },
    "src/modules/erc721-receiver/SmartAccountERC721Receiver.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\n\nimport {ISmartAccountERC721Receiver, IERC721Receiver} from \"./SmartAccountERC721ReceiverLib.sol\";\n\ncontract SmartAccountERC721Receiver is ISmartAccountERC721Receiver {\n    /// @inheritdoc IERC721Receiver\n    function onERC721Received(address, address, uint256, bytes memory) public virtual returns (bytes4) {\n        return this.onERC721Received.selector;\n    }\n}\n"
    },
    "src/modules/erc721-receiver/SmartAccountERC721ReceiverLib.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\n\nimport {SmartAccountERC165Lib} from \"../erc165/SmartAccountERC165Lib.sol\";\nimport {SmartAccountModulesLib} from \"../SmartAccountModulesLib.sol\";\n\nimport {ISmartAccountERC721Receiver, IERC721Receiver} from \"./ISmartAccountERC721Receiver.sol\";\n\nlibrary SmartAccountERC721ReceiverLib {\n    /// @notice Sets the interfaces implemented by this contract to (un)supported.\n    function setInterfaces(bool supported) internal {\n        SmartAccountERC165Lib.setInterfaceSupport(type(IERC721Receiver).interfaceId, supported);\n    }\n\n    /// @notice Installs all functions, interfaces, and performs storage initialization of this module.\n    function fullInstall(address module) internal {\n        SmartAccountModulesLib.setModule(IERC721Receiver.onERC721Received.selector, module);\n        setInterfaces(true);\n    }\n\n    /// @notice Uninstalls all functions and interfaces of this module.\n    function fullUninstall() internal {\n        SmartAccountModulesLib.setModule(IERC721Receiver.onERC721Received.selector, address(0));\n        setInterfaces(false);\n    }\n}\n"
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