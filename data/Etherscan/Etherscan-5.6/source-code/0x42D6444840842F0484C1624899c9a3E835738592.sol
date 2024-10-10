{{
  "language": "Solidity",
  "settings": {
    "evmVersion": "paris",
    "libraries": {},
    "metadata": {
      "bytecodeHash": "none",
      "useLiteralContent": true
    },
    "optimizer": {
      "enabled": true,
      "runs": 800
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
    "contracts/ContextRegistry.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.18;\n\nimport { IContextRegistry } from \"./interfaces/IContextRegistry.sol\";\n\n/// @notice ContextRegistry is a contract that allows the registration of contexts.\n/// Contexts are strings that represent a specific context for credentials. They\n/// are ownerless and can be registered and used by anyone.\ncontract ContextRegistry is IContextRegistry {\n    error AlreadyExists();\n\n    // The global mapping between contexts and their contextID.\n    mapping(uint160 contextId => string context) private _registry;\n\n    /// @dev register a new context\n    function registerContext(string calldata context) external override returns (uint160) {\n        uint160 contextID = _getContextID(context);\n        if (bytes(_registry[contextID]).length != 0) {\n            revert AlreadyExists();\n        }\n        _registry[contextID] = context;\n        emit ContextRegistered(contextID, context);\n        return contextID;\n    }\n\n    /// @dev get the context for the given contextID\n    function getContext(uint160 contextId) external view override returns (string memory) {\n        return _registry[contextId];\n    }\n\n    /// @dev calculate the contextID for a given context string\n    function calculateContextID(string calldata context) external pure override returns (uint160) {\n        return _getContextID(context);\n    }\n\n    /**\n     * ContextID is the lower 160 bits of the keccak256 hash of the context string.\n     * @param context The context string to get the contextID for.\n     */\n    function _getContextID(string calldata context) private pure returns (uint160) {\n        return uint160(uint256(keccak256(abi.encodePacked(context))));\n    }\n}\n"
    },
    "contracts/interfaces/IContextRegistry.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.18;\n\n/// @title Context Registry Interface\ninterface IContextRegistry {\n    // Events\n    event ContextRegistered(uint160 indexed contextId, string context);\n\n    /// @dev registerContext registers a new context and returns the contextId\n    function registerContext(string calldata context) external returns (uint160);\n\n    /// @dev getContext returns the context for the given contextId\n    function getContext(uint160 contextId) external returns (string memory);\n\n    /// @dev calculate the contextID for a given context string\n    function calculateContextID(string calldata context) external pure returns (uint160);\n}\n"
    }
  }
}}