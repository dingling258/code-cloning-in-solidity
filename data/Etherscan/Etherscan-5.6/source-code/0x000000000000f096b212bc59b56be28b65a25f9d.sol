{{
  "language": "Solidity",
  "sources": {
    "src/Safes.sol": {
      "content": "// SPDX-License-Identifier: AGPL-3.0-only\npragma solidity 0.8.25;\n\n/// @notice Tokenized ownership of Safes.\ncontract Safes {\n    error Unauthorized();\n\n    error CallReverted();\n\n    event TransferSingle(\n        address indexed owner, address indexed from, address indexed to, uint256 id, uint256 amount\n    );\n\n    event URI(string metadata, uint256 indexed id);\n\n    string public constant name = \"Safes\";\n\n    string public constant symbol = unicode\"🗝️\";\n\n    mapping(uint256 id => string metadata) internal _uri;\n\n    function uri(uint256 id) public view returns (string memory) {\n        return _uri[id]; // Metadata.\n    }\n\n    function setURI(uint256 id, string calldata metadata) public {\n        if (balanceOf(msg.sender, id) != 0) emit URI(_uri[id] = metadata, id);\n        else revert Unauthorized();\n    }\n\n    function balanceOf(address owner, uint256 id) public view returns (uint256) {\n        return ISafes(address(uint160(id))).isOwner(owner) ? 1 : 0;\n    }\n\n    function safeTransferFrom(\n        address from,\n        address to,\n        uint256 id,\n        uint256 amount,\n        bytes calldata data\n    ) public payable {\n        if (balanceOf(msg.sender, id) != 0) {\n            if (\n                ISafes(to).onERC1155Received{value: msg.value}(msg.sender, from, id, amount, data)\n                    != ISafes.onERC1155Received.selector\n            ) revert CallReverted();\n            emit TransferSingle(msg.sender, from, to, id, amount);\n        } else {\n            revert Unauthorized();\n        }\n    }\n\n    function register(address account) public {\n        address[] memory owners = ISafes(account).getOwners();\n        uint256 id = uint256(uint160(account));\n        for (uint256 i; i != owners.length; ++i) {\n            emit TransferSingle(msg.sender, address(0), owners[i], id, 1);\n        }\n    }\n}\n\ninterface ISafes {\n    function isOwner(address) external view returns (bool);\n    function getOwners() external view returns (address[] memory);\n    function onERC1155Received(address, address, uint256, uint256, bytes calldata)\n        external\n        payable\n        returns (bytes4);\n}\n"
    }
  },
  "settings": {
    "remappings": [
      "@solady/=lib/solady/",
      "@forge/=lib/forge-std/src/",
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
    "evmVersion": "cancun",
    "viaIR": false,
    "libraries": {}
  }
}}