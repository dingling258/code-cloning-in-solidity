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
    "contracts/babyzk/DefaultPublicSignalGetter.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.18;\n\nimport { IPublicSignalGetter } from \"../interfaces/IPublicSignalGetter.sol\";\n\ncontract BabyzkDefaultPsGetter is IPublicSignalGetter {\n    /// @dev Implements the getPublicSignal function from the IPublicSignalGetter interface.\n    /// @param name The signal name, represented as the given enum (converted to uint8).\n    /// @param publicSignals The public signals, as an array of uints.\n    /// @return The public signal associated with the given name.\n    function getPublicSignal(uint8 name, uint256[] calldata publicSignals) external pure override returns (uint256) {\n        // Because in babyzk's circom circuit, the index of the public signals is the same as the enum value of the signal name,\n        // we can simply return the public signal at the index of the signal name.\n        // This is deliberately done to make the circuit easier to understand and to avoid the need for a more complex getter.\n        // However, in a more complex circuit, the order of public signals can be different from the enum values.\n        // In those cases, type designers can use a custom public signal getter to return the correct public signal.\n        return publicSignals[name];\n    }\n}\n"
    },
    "contracts/interfaces/IPublicSignalGetter.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.18;\n\n/// @title Intrinsic Signal enum\nenum IntrinsicSignalName {\n    TYPE,\n    CONTEXT,\n    NULLIFIER,\n    EXTERNAL_NULLIFIER,\n    REVEAL_IDENTITY,\n    EXPIRATION_LB,\n    KEY_ID,\n    ID_EQUALS_TO,\n    SIG_REVOCATION_SMT_ROOT\n}\n\n/// @title Public Signal Getter Interface\n/// @dev Public signals (inputs) are represented as an array of uints in galxe identity protocol.\n///      To find the public signal for a given signal name, type designer should set a contract\n///      in the type registry that implements this interface.\ninterface IPublicSignalGetter {\n    /// @dev get the public signal for the signal name, represented as the given enum (represented as uint8), based on the public signals.\n    /// @notice Implementation must be able to handle intrinsic signals, defiend in IntrinsicSignalName enum.\n    ///         Type-specific signals support is optional.\n    /// @param name The signal name, represented as the given enum (converted to uint8).\n    /// @param publicSignals The public signals.\n    function getPublicSignal(uint8 name, uint256[] calldata publicSignals) external view returns (uint256);\n}\n"
    }
  }
}}