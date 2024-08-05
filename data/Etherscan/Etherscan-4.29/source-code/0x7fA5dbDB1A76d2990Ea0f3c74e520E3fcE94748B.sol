{{
  "language": "Solidity",
  "sources": {
    "src/base/DecodersAndSanitizers/Protocols/ITB/ITBPositionDecoderAndSanitizer.sol": {
      "content": "/* SPDX-License-Identifier: UNLICENSED */\npragma solidity ^0.8.0;\n\nimport './common/BoringDecoderAndSanitizer.sol';\nimport './aave/AaveDecoderAndSanitizer.sol';\nimport './curve_and_convex/CurveAndConvexDecoderAndSanitizer.sol';\nimport './gearbox/GearboxDecoderAndSanitizer.sol';\n\ncontract ITBPositionDecoderAndSanitizer is BoringDecoderAndSanitizer, AaveDecoderAndSanitizer, CurveAndConvexDecoderAndSanitizer, GearboxDecoderAndSanitizer {\n  constructor (address _boringVault) BoringDecoderAndSanitizer(_boringVault) {}\n\n  function transfer(address _to, uint) external pure returns (bytes memory addressesFound) {\n        addressesFound = abi.encodePacked(_to);\n    }\n}"
    },
    "src/base/DecodersAndSanitizers/Protocols/ITB/common/BoringDecoderAndSanitizer.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\n\ncontract BoringDecoderAndSanitizer {\n    //============================== IMMUTABLES ===============================\n\n    /**\n     * @notice The BoringVault contract address.\n     */\n    address internal immutable boringVault;\n\n    constructor(address _boringVault) {\n        boringVault = _boringVault;\n    }\n\n    function approve(address spender, uint) external pure returns (bytes memory addressesFound) {\n        addressesFound = abi.encodePacked(spender);\n    }\n}"
    },
    "src/base/DecodersAndSanitizers/Protocols/ITB/aave/AaveDecoderAndSanitizer.sol": {
      "content": "/* SPDX-License-Identifier: UNLICENSED */\npragma solidity ^0.8.0;\n\nimport '../common/ITBContractDecoderAndSanitizer.sol';\n\nabstract contract AaveDecoderAndSanitizer is ITBContractDecoderAndSanitizer {\n    function deposit(address asset, uint) external pure returns (bytes memory addressesFound)\n    {\n        addressesFound = abi.encodePacked(asset);\n    }\n\n    function withdrawSupply(address asset, uint) external pure returns (bytes memory addressesFound)\n    {\n        addressesFound = abi.encodePacked(asset);\n    }\n}"
    },
    "src/base/DecodersAndSanitizers/Protocols/ITB/curve_and_convex/CurveAndConvexDecoderAndSanitizer.sol": {
      "content": "/* SPDX-License-Identifier: UNLICENSED */\npragma solidity ^0.8.0;\n\nimport '../common/ITBContractDecoderAndSanitizer.sol';\nimport './CurveNoConfigDecoderAndSanitizer.sol';\nimport './ConvexDecoderAndSanitizer.sol';\n\nabstract contract CurveAndConvexDecoderAndSanitizer is ITBContractDecoderAndSanitizer, CurveNoConfigDecoderAndSanitizer, ConvexDecoderAndSanitizer {}"
    },
    "src/base/DecodersAndSanitizers/Protocols/ITB/gearbox/GearboxDecoderAndSanitizer.sol": {
      "content": "/* SPDX-License-Identifier: UNLICENSED */\npragma solidity ^0.8.0;\n\nimport '../common/ITBContractDecoderAndSanitizer.sol';\n\nabstract contract GearboxDecoderAndSanitizer is ITBContractDecoderAndSanitizer {\n    function deposit(uint, uint) external pure returns (bytes memory addressesFound) {\n        // Nothing to sanitize or return\n        return addressesFound;\n    }\n\n    function withdrawSupply(uint, uint) external pure returns (bytes memory addressesFound) {\n        // Nothing to sanitize or return\n        return addressesFound;\n    }\n\n    function stake(uint) external pure returns (bytes memory addressesFound) {\n        // Nothing to sanitize or return\n        return addressesFound;\n    }\n\n    function unstake(uint) external pure returns (bytes memory addressesFound) {\n        // Nothing to sanitize or return\n        return addressesFound;\n    }\n}\n"
    },
    "src/base/DecodersAndSanitizers/Protocols/ITB/common/ITBContractDecoderAndSanitizer.sol": {
      "content": "/* SPDX-License-Identifier: UNLICENSED */\npragma solidity ^0.8.0;\n\nimport './WithdrawableDecoderAndSanitizer.sol';\nimport './Ownable2StepDecoderAndSanitizer.sol';\n\n/// @title Decoder and sanitizer for ITBContract\n/// @author IntoTheBlock Corp\nabstract contract ITBContractDecoderAndSanitizer is WithdrawableDecoderAndSanitizer, Ownable2StepDecoderAndSanitizer {\n    function approveToken(address _token, address _guy, uint) external pure returns (bytes memory addressesFound) {\n        addressesFound = abi.encodePacked(_token, _guy);\n    }\n\n    function revokeToken(address _token, address _guy) external pure returns (bytes memory addressesFound) {\n        addressesFound = abi.encodePacked(_token, _guy);\n    }\n}\n"
    },
    "src/base/DecodersAndSanitizers/Protocols/ITB/curve_and_convex/CurveNoConfigDecoderAndSanitizer.sol": {
      "content": "/* SPDX-License-Identifier: UNLICENSED */\npragma solidity ^0.8.0;\n\nabstract contract CurveNoConfigDecoderAndSanitizer {\n    function addLiquidityAllCoinsAndStake(address _pool, uint[] memory, address _gauge, uint) external pure returns (bytes memory addressesFound) {\n        addressesFound = abi.encodePacked(_pool, _gauge);\n    }\n\n    function unstakeAndRemoveLiquidityAllCoins(address _pool, uint, address _gauge, uint[] memory) external pure returns (bytes memory addressesFound) {\n        addressesFound = abi.encodePacked(_pool, _gauge);\n    }\n}\n"
    },
    "src/base/DecodersAndSanitizers/Protocols/ITB/curve_and_convex/ConvexDecoderAndSanitizer.sol": {
      "content": "/* SPDX-License-Identifier: UNLICENSED */\npragma solidity ^0.8.0;\n\nabstract contract ConvexDecoderAndSanitizer {\n    function addLiquidityAllCoinsAndStakeConvex(address _pool, uint[] memory, uint _convex_pool_id, uint) external pure returns (bytes memory addressesFound) {\n        addressesFound = abi.encodePacked(_pool, address(uint160(_convex_pool_id)));\n    }\n\n    function unstakeAndRemoveLiquidityAllCoinsConvex(address _pool, uint, uint _convex_pool_id, uint[] memory) external pure returns (bytes memory addressesFound) {\n        addressesFound = abi.encodePacked(_pool, address(uint160(_convex_pool_id)));\n    }\n}\n"
    },
    "src/base/DecodersAndSanitizers/Protocols/ITB/common/WithdrawableDecoderAndSanitizer.sol": {
      "content": "// SPDX-License-Identifier: UNLICENSED\npragma solidity ^0.8.0;\n\n/// @title Decoder and sanitizer for Withdrawable\n/// @author IntoTheBlock Corp\nabstract contract WithdrawableDecoderAndSanitizer {\n    function withdraw(address _asset_address, uint) external pure returns (bytes memory addressesFound) {\n        addressesFound = abi.encodePacked(_asset_address);\n    }\n\n    function withdrawAll(address _asset_address) external pure returns (bytes memory addressesFound) {\n        addressesFound = abi.encodePacked(_asset_address);\n    }\n}\n"
    },
    "src/base/DecodersAndSanitizers/Protocols/ITB/common/Ownable2StepDecoderAndSanitizer.sol": {
      "content": "// SPDX-License-Identifier: UNLICENSED\npragma solidity ^0.8.0;\n\n/// @title Decoder and sanitizer for Ownable2Step from @openzeppelin/contracts/access/Ownable2Step.sol\n/// @author IntoTheBlock Corp\nabstract contract Ownable2StepDecoderAndSanitizer {\n    function acceptOwnership() external pure returns (bytes memory addressesFound) {\n        // Nothing to sanitize or return\n        return addressesFound;\n    }\n}\n"
    }
  },
  "settings": {
    "remappings": [
      "@solmate/=lib/solmate/src/",
      "@forge-std/=lib/forge-std/src/",
      "@ds-test/=lib/forge-std/lib/ds-test/src/",
      "ds-test/=lib/forge-std/lib/ds-test/src/",
      "@openzeppelin/=lib/openzeppelin-contracts/",
      "@openzeppelin/contracts/=lib/openzeppelin-contracts/contracts/",
      "erc4626-tests/=lib/openzeppelin-contracts/lib/erc4626-tests/",
      "forge-std/=lib/forge-std/src/",
      "openzeppelin-contracts/=lib/openzeppelin-contracts/",
      "solmate/=lib/solmate/src/"
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
          "abi"
        ]
      }
    },
    "evmVersion": "shanghai",
    "libraries": {}
  }
}}