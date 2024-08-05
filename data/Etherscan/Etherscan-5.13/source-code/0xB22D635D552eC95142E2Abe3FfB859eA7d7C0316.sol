{{
  "language": "Solidity",
  "settings": {
    "evmVersion": "istanbul",
    "libraries": {},
    "metadata": {
      "bytecodeHash": "ipfs",
      "useLiteralContent": true
    },
    "optimizer": {
      "enabled": false,
      "runs": 200
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
    "contracts/libraries/CreateCall.sol": {
      "content": "// SPDX-License-Identifier: LGPL-3.0-only\n\npragma solidity >=0.7.0 <0.9.0;\n\n/**\n * @title Create Call - Allows to use the different create opcodes to deploy a contract.\n * @author Richard Meissner - @rmeissner\n * @notice This contract provides functions for deploying a new contract using the create and create2 opcodes.\n */\ncontract CreateCall {\n    /// @notice Emitted when a new contract is created\n    event ContractCreation(address indexed newContract);\n\n    /**\n     * @notice Deploys a new contract using the create2 opcode.\n     * @param value The value in wei to be sent with the contract creation.\n     * @param deploymentData The initialisation code of the contract to be created.\n     * @param salt The salt value to use for the contract creation.\n     * @return newContract The address of the newly created contract.\n     */\n    function performCreate2(uint256 value, bytes memory deploymentData, bytes32 salt) public returns (address newContract) {\n        /* solhint-disable no-inline-assembly */\n        /// @solidity memory-safe-assembly\n        assembly {\n            newContract := create2(value, add(0x20, deploymentData), mload(deploymentData), salt)\n        }\n        /* solhint-enable no-inline-assembly */\n        require(newContract != address(0), \"Could not deploy contract\");\n        emit ContractCreation(newContract);\n    }\n\n    /**\n     * @notice Deploys a new contract using the create opcode.\n     * @param value The value in wei to be sent with the contract creation.\n     * @param deploymentData The initialisation code of the contract to be created.\n     * @return newContract The address of the newly created contract.\n     */\n    function performCreate(uint256 value, bytes memory deploymentData) public returns (address newContract) {\n        /* solhint-disable no-inline-assembly */\n        /// @solidity memory-safe-assembly\n        assembly {\n            newContract := create(value, add(deploymentData, 0x20), mload(deploymentData))\n        }\n        /* solhint-enable no-inline-assembly */\n        require(newContract != address(0), \"Could not deploy contract\");\n        emit ContractCreation(newContract);\n    }\n}\n"
    }
  }
}}