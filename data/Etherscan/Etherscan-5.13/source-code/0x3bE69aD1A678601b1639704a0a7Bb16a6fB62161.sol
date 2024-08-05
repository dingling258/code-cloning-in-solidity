{{
  "language": "Solidity",
  "settings": {
    "optimizer": {
      "enabled": true,
      "runs": 200
    },
    "viaIR": true,
    "outputSelection": {
      "*": {
        "*": [
          "evm.bytecode",
          "evm.deployedBytecode",
          "abi"
        ]
      }
    },
    "remappings": []
  },
  "sources": {
    "Airdrop.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity >=0.8.25;\n\ncontract Airdrop {\n    function claim(address to, uint256 amount, bytes32[] calldata proof) external {\n\n    }\n}"
    }
  }
}}