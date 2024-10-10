{{
  "language": "Solidity",
  "sources": {
    "contracts/MultiERC20.sol": {
      "content": "// SPDX-License-Identifier: AGPL-3.0\npragma solidity ^0.8.0;\n\ninterface IERC20 {\n    function name() external view returns (string memory);\n    function symbol() external view returns (string memory);\n    function decimals() external view returns (uint8);\n    function balanceOf(address) external view returns (uint);\n    function totalSupply() external view returns (uint);\n}\n\ncontract MultiERC20 {\n    function tokenBalancesOf(IERC20 token, address[] memory addresses) public view returns (uint[] memory) {\n        uint addressesLength = addresses.length;\n        uint[] memory balances = new uint[](addressesLength);\n        for (uint i = 0; i < addressesLength; i++) {\n            balances[i] = token.balanceOf(addresses[i]);\n        }\n        return balances;\n    }\n    function balancesOfTokens(address wallet, IERC20[] memory tokens) public view returns (uint[] memory) {\n        uint tokensLength = tokens.length;\n        uint[] memory balances = new uint[](tokensLength);\n        for (uint i = 0; i < tokensLength; i++) {\n            balances[i] = tokens[i].balanceOf(wallet);\n        }\n        return balances;\n    }\n    function totalSupplys(IERC20[] memory tokens) public view returns (uint[] memory) {\n        uint tokensLength = tokens.length;\n        uint[] memory supplys = new uint[](tokensLength);\n        for (uint i = 0; i < tokensLength; i++) {\n            supplys[i] = tokens[i].totalSupply();\n        }\n        return supplys;\n    }\n    function decimalses(IERC20[] memory tokens) public view returns (uint8[] memory) {\n        uint tokensLength = tokens.length;\n        uint8[] memory _decimals = new uint8[](tokensLength);\n        for (uint i = 0; i < tokensLength; i++) {\n            _decimals[i] = tokens[i].decimals();\n        }\n        return _decimals;\n    }\n    function names(IERC20[] memory tokens) public view returns (string[] memory) {\n        uint tokensLength = tokens.length;\n        string[] memory _names = new string[](tokensLength);\n        for (uint i = 0; i < tokensLength; i++) {\n            _names[i] = tokens[i].name();\n        }\n        return _names;\n    }\n    function symbols(IERC20[] memory tokens) public view returns (string[] memory) {\n        uint tokensLength = tokens.length;\n        string[] memory _symbols = new string[](tokensLength);\n        for (uint i = 0; i < tokensLength; i++) {\n            _symbols[i] = tokens[i].symbol();\n        }\n        return _symbols;\n    }\n}"
    }
  },
  "settings": {
    "optimizer": {
      "enabled": false,
      "runs": 200
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
    "remappings": []
  }
}}