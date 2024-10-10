{{
  "language": "Solidity",
  "sources": {
    "contracts/oracles/OETHPriceOracle.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0-or-later\r\npragma solidity 0.8.21;\r\n\r\nimport { OneETHPriceOracle } from \"./OneETHPriceOracle.sol\";\r\n\r\n/// @title OETHPriceOracle Contract\r\n/// @notice contract that returns 1e18 as the exchange rate of asset/ETH\r\ncontract OETHPriceOracle is OneETHPriceOracle {\r\n    address public immutable oethAddress;\r\n\r\n    error InvalidAsset();\r\n\r\n    /// @custom:oz-upgrades-unsafe-allow constructor\r\n    constructor(address _oethAddress) {\r\n        oethAddress = _oethAddress;\r\n    }\r\n\r\n    /// @return assetPrice 1e18 as the exchange rate of asset/ETH\r\n    function getAssetPrice(address asset) external view override returns (uint256) {\r\n        if (asset != oethAddress) {\r\n            revert InvalidAsset();\r\n        }\r\n\r\n        return 1e18;\r\n    }\r\n}\r\n"
    },
    "contracts/oracles/OneETHPriceOracle.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0-or-later\r\npragma solidity 0.8.21;\r\n\r\nimport { UtilLib } from \"../utils/UtilLib.sol\";\r\nimport { IPriceFetcher } from \"../interfaces/IPriceFetcher.sol\";\r\n\r\n/// @title OneETHPriceOracle Contract\r\n/// @notice contract that returns 1e18 as the exchange rate of asset/ETH\r\ncontract OneETHPriceOracle is IPriceFetcher {\r\n    /// @return assetPrice 1e18 as the exchange rate of asset/ETH\r\n    function getAssetPrice(address) external view virtual returns (uint256) {\r\n        return 1e18;\r\n    }\r\n}\r\n"
    },
    "contracts/interfaces/IPriceFetcher.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0-or-later\r\npragma solidity 0.8.21;\r\n\r\ninterface IPriceFetcher {\r\n    function getAssetPrice(address asset) external view returns (uint256);\r\n}\r\n"
    },
    "contracts/utils/UtilLib.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0-or-later\r\npragma solidity 0.8.21;\r\n\r\n/// @title UtilLib - Utility library\r\n/// @notice Utility functions\r\nlibrary UtilLib {\r\n    error ZeroAddressNotAllowed();\r\n\r\n    /// @dev zero address check modifier\r\n    /// @param address_ address to check\r\n    function checkNonZeroAddress(address address_) internal pure {\r\n        if (address_ == address(0)) revert ZeroAddressNotAllowed();\r\n    }\r\n}\r\n"
    }
  },
  "settings": {
    "optimizer": {
      "enabled": true,
      "runs": 10000
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