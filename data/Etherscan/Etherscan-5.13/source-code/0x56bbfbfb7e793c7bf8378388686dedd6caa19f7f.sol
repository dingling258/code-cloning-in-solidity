{{
  "sources": {
    "src/libraries/proxy/UnlockdMinimalProxy.sol": {
      "content": "// SPDX-License-Identifier: BUSL-1.1\npragma solidity ^0.8.19;\n\n/**\n * @title Unlockd Minimal Proxy\n * @author Unlockd\n * @notice Proxy for the modules\n * @dev fork from https://github.com/euler-xyz/euler-contracts/blob/master/contracts/Proxy.sol\n */\ncontract UnlockdMinimalProxy {\n  address immutable creator;\n\n  constructor() {\n    creator = msg.sender;\n  }\n\n  // External interface\n\n  fallback() external {\n    address creator_ = creator;\n    assembly {\n      mstore(0, 0xe9c4a3ac00000000000000000000000000000000000000000000000000000000) // dispatch() selector\n      calldatacopy(4, 0, calldatasize())\n      mstore(add(4, calldatasize()), shl(96, caller()))\n\n      let result := call(gas(), creator_, 0, 0, add(24, calldatasize()), 0, 0)\n      returndatacopy(0, 0, returndatasize())\n\n      switch result\n      case 0 {\n        revert(0, returndatasize())\n      }\n      default {\n        return(0, returndatasize())\n      }\n    }\n  }\n}\n"
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