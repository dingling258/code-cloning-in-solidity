{{
  "sources": {
    "src/utils/UnlockdHelper.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity 0.8.19;\n\ncontract UnlockdHelper {\n  function getAssetId(address collection, uint256 tokenId) external pure returns (bytes32) {\n    return keccak256(abi.encodePacked(collection, tokenId));\n  }\n\n  function getEncodedAssetId(\n    address collection,\n    uint256 tokenId\n  ) external pure returns (bytes memory) {\n    return abi.encodePacked(collection, tokenId);\n  }\n\n  function getOrderId(bytes32 assetId, bytes32 loanId) external pure returns (bytes32) {\n    return keccak256(abi.encodePacked(loanId, assetId));\n  }\n}\n"
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