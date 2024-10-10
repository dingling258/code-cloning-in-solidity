{{
  "language": "Solidity",
  "sources": {
    "starkware/solidity/verifier/cpu/IMemoryPageRegistry.sol": {
      "content": "/*\n  Copyright 2019-2024 StarkWare Industries Ltd.\n\n  Licensed under the Apache License, Version 2.0 (the \"License\").\n  You may not use this file except in compliance with the License.\n  You may obtain a copy of the License at\n\n  https://www.starkware.co/open-source-license/\n\n  Unless required by applicable law or agreed to in writing,\n  software distributed under the License is distributed on an \"AS IS\" BASIS,\n  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\n  See the License for the specific language governing permissions\n  and limitations under the License.\n*/\n// SPDX-License-Identifier: Apache-2.0.\npragma solidity ^0.6.12;\n\nstruct MemoryPageEntry {\n    uint256 startAddr;\n    uint256[] values;\n    uint256 z;\n    uint256 alpha;\n    uint256 prime;\n}\n\ninterface IMemoryPageRegistry {\n    function registerContinuousMemoryPage(\n        uint256 startAddr,\n        uint256[] memory values,\n        uint256 z,\n        uint256 alpha,\n        uint256 prime\n    )\n        external\n        returns (\n            bytes32,\n            uint256,\n            uint256\n        );\n}\n"
    },
    "starkware/solidity/interfaces/Identity.sol": {
      "content": "/*\n  Copyright 2019-2024 StarkWare Industries Ltd.\n\n  Licensed under the Apache License, Version 2.0 (the \"License\").\n  You may not use this file except in compliance with the License.\n  You may obtain a copy of the License at\n\n  https://www.starkware.co/open-source-license/\n\n  Unless required by applicable law or agreed to in writing,\n  software distributed under the License is distributed on an \"AS IS\" BASIS,\n  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\n  See the License for the specific language governing permissions\n  and limitations under the License.\n*/\n// SPDX-License-Identifier: Apache-2.0.\npragma solidity ^0.6.12;\n\ninterface Identity {\n    /*\n      Allows a caller to ensure that the provided address is of the expected type and version.\n    */\n    function identify() external pure returns (string memory);\n}\n"
    },
    "starkware/solidity/verifier/cpu/MemoryPageBatcher.sol": {
      "content": "/*\n  Copyright 2019-2024 StarkWare Industries Ltd.\n\n  Licensed under the Apache License, Version 2.0 (the \"License\").\n  You may not use this file except in compliance with the License.\n  You may obtain a copy of the License at\n\n  https://www.starkware.co/open-source-license/\n\n  Unless required by applicable law or agreed to in writing,\n  software distributed under the License is distributed on an \"AS IS\" BASIS,\n  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\n  See the License for the specific language governing permissions\n  and limitations under the License.\n*/\n// SPDX-License-Identifier: Apache-2.0.\npragma solidity ^0.6.12;\npragma experimental ABIEncoderV2;\n\nimport \"./IMemoryPageRegistry.sol\";\nimport \"../../interfaces/Identity.sol\";\n\ncontract MemoryPageBatcher is Identity {\n    IMemoryPageRegistry public immutable memoryPageRegistry;\n\n    event BoundMemoryPageFactRegistry(address memoryPageFactRegistry);\n\n    function identify() external pure virtual override returns (string memory) {\n        return \"StarkWare_MemoryPageBatcher_2024_1\";\n    }\n\n    constructor(address memoryPageFactRegistry_) public {\n        memoryPageRegistry = IMemoryPageRegistry(memoryPageFactRegistry_);\n        emit BoundMemoryPageFactRegistry(memoryPageFactRegistry_);\n    }\n\n    function registerContinuousPageBatch(MemoryPageEntry[] calldata memoryPageEntries) external {\n        for (uint256 i = 0; i < memoryPageEntries.length; i++) {\n            memoryPageRegistry.registerContinuousMemoryPage(\n                memoryPageEntries[i].startAddr,\n                memoryPageEntries[i].values,\n                memoryPageEntries[i].z,\n                memoryPageEntries[i].alpha,\n                memoryPageEntries[i].prime\n            );\n        }\n    }\n}\n"
    }
  },
  "settings": {
    "metadata": {
      "useLiteralContent": true
    },
    "libraries": {},
    "remappings": [],
    "optimizer": {
      "enabled": true,
      "runs": 100
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
    }
  }
}}