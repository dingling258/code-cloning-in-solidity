{{
  "language": "Solidity",
  "sources": {
    "src/Summoner.sol": {
      "content": "// ᗪᗩGOᑎ 𒀭 𒀭 𒀭 𒀭 𒀭 𒀭 𒀭 𒀭 𒀭 𒀭 𒀭\n// SPDX-License-Identifier: AGPL-3.0-only\npragma solidity ^0.8.24;\n\n/// @notice Simple summoner for Dagon (𒀭) group accounts.\n/// @custom:version 1.0.0\ncontract Summoner {\n    address internal constant DAGON = 0x0000000000001ADDcB933DD5028159dc965b5b7f;\n    IAccounts internal constant FACTORY = IAccounts(0x000000000000dD366cc2E4432bB998e41DFD47C7);\n\n    struct Ownership {\n        address owner;\n        uint96 shares;\n    }\n\n    enum Standard {\n        DAGON,\n        ERC20,\n        ERC721,\n        ERC1155,\n        ERC6909\n    }\n\n    function summon(Ownership[] calldata summoners, uint88 threshold, bool locked, bytes12 salt)\n        public\n        payable\n        returns (IAccounts account)\n    {\n        account = IAccounts(\n            FACTORY.createAccount{value: msg.value}(\n                address(this), bytes32(abi.encodePacked(this, salt))\n            )\n        );\n        for (uint256 i; i != summoners.length; ++i) {\n            account.execute(\n                DAGON,\n                0,\n                abi.encodeWithSignature(\n                    \"mint(address,uint96)\", summoners[i].owner, summoners[i].shares\n                )\n            );\n        }\n        if (locked) {\n            account.execute(DAGON, 0, abi.encodeWithSignature(\"setAuth(address)\", address(0xdead)));\n        }\n        account.execute(DAGON, 0, abi.encodeWithSignature(\"setThreshold(uint88)\", threshold));\n        account.execute(\n            address(account), 0, abi.encodeWithSignature(\"transferOwnership(address)\", DAGON)\n        );\n    }\n\n    function summonForToken(address token, Standard standard, uint88 threshold, bytes12 salt)\n        public\n        payable\n        returns (IAccounts account)\n    {\n        account = IAccounts(\n            FACTORY.createAccount{value: msg.value}(\n                address(this), bytes32(abi.encodePacked(this, salt))\n            )\n        );\n        account.execute(\n            DAGON, 0, abi.encodeWithSignature(\"setToken(address,uint8)\", token, standard)\n        );\n        account.execute(DAGON, 0, abi.encodeWithSignature(\"setThreshold(uint88)\", threshold));\n        account.execute(\n            address(account), 0, abi.encodeWithSignature(\"transferOwnership(address)\", DAGON)\n        );\n    }\n}\n\n/// @dev Simple interface for Nani (𒀭) user account creation and setup.\ninterface IAccounts {\n    function createAccount(address, bytes32) external payable returns (address);\n    function execute(address, uint256, bytes calldata) external payable returns (bytes memory);\n}\n"
    }
  },
  "settings": {
    "remappings": [
      "@solady/=lib/solady/",
      "@forge/=lib/forge-std/src/",
      "@nani/=lib/accounts/src/",
      "@forge/=lib/accounts/lib/forge-std/src/",
      "@solady/=lib/accounts/lib/solady/",
      "accounts/=lib/accounts/src/",
      "forge-std/=lib/forge-std/src/",
      "solady/=lib/solady/src/"
    ],
    "optimizer": {
      "enabled": true,
      "runs": 9999999
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
          "abi"
        ]
      }
    },
    "evmVersion": "shanghai",
    "viaIR": true,
    "libraries": {}
  }
}}