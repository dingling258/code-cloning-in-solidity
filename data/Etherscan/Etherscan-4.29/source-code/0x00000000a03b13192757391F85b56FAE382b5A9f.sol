{{
  "language": "Solidity",
  "sources": {
    "src/vesting/VestingVaultProxy.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.4;\n\nimport {ERC6551Proxy} from \"solady/accounts/ERC6551Proxy.sol\";\n\n/// @notice Vesting vault proxy.\ncontract VestingVaultProxy is ERC6551Proxy {\n    /// @dev Please update the implementation address accordingly.\n    constructor() ERC6551Proxy(0x000000006Cc734dEA8808e8c718e74b0b9cB6C56) {}\n}\n"
    },
    "lib/solady/src/accounts/ERC6551Proxy.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.4;\n\n/// @notice Relay proxy for upgradeable ERC6551 accounts.\n/// @author Solady (https://github.com/vectorized/solady/blob/main/src/accounts/ERC6551Proxy.sol)\n/// @author ERC6551 team (https://github.com/erc6551/reference/blob/main/src/examples/upgradeable/ERC6551AccountProxy.sol)\n///\n/// @dev Note: This relay proxy is required for upgradeable ERC6551 accounts.\n///\n/// ERC6551 clone -> ERC6551Proxy (relay) -> ERC6551 account implementation.\n///\n/// This relay proxy also allows for correctly revealing the\n/// \"Read as Proxy\" and \"Write as Proxy\" tabs on Etherscan.\n///\n/// After using the registry to deploy a ERC6551 clone pointing to this relay proxy,\n/// users must send 0 ETH to the clone before clicking on \"Is this a proxy?\" on Etherscan.\n/// Verification of this relay proxy on Etherscan is optional.\ncontract ERC6551Proxy {\n    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/\n    /*                         IMMUTABLES                         */\n    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/\n\n    /// @dev The default implementation.\n    bytes32 internal immutable _defaultImplementation;\n\n    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/\n    /*                          STORAGE                           */\n    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/\n\n    /// @dev The ERC-1967 storage slot for the implementation in the proxy.\n    /// `uint256(keccak256(\"eip1967.proxy.implementation\")) - 1`.\n    bytes32 internal constant _ERC1967_IMPLEMENTATION_SLOT =\n        0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;\n\n    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/\n    /*                        CONSTRUCTOR                         */\n    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/\n\n    constructor(address defaultImplementation) payable {\n        _defaultImplementation = bytes32(uint256(uint160(defaultImplementation)));\n    }\n\n    /*´:°•.°+.*•´.*:˚.°*.˚•´.°:°•.°•.*•´.*:˚.°*.˚•´.°:°•.°+.*•´.*:*/\n    /*                          FALLBACK                          */\n    /*.•°:°.´+˚.*°.˚:*.´•*.+°.•°:´*.´•*.•°.•°:°.´:•˚°.*°.˚:*.´+°.•*/\n\n    fallback() external payable virtual {\n        bytes32 implementation;\n        assembly {\n            mstore(0x40, returndatasize()) // Optimization trick to change `6040608052` into `3d604052`.\n            implementation := sload(_ERC1967_IMPLEMENTATION_SLOT)\n        }\n        if (implementation == bytes32(0)) {\n            implementation = _defaultImplementation;\n            assembly {\n                // Only initialize if the calldatasize is zero, so that staticcalls to\n                // functions (which will have 4-byte function selectors) won't revert.\n                // Some users may be fine without Etherscan proxy detection and thus may\n                // choose to not initialize the ERC1967 implementation slot.\n                if iszero(calldatasize()) { sstore(_ERC1967_IMPLEMENTATION_SLOT, implementation) }\n            }\n        }\n        assembly {\n            calldatacopy(returndatasize(), returndatasize(), calldatasize())\n            // forgefmt: disable-next-item\n            if iszero(delegatecall(gas(), implementation,\n                returndatasize(), calldatasize(), codesize(), returndatasize())) {\n                returndatacopy(0x00, 0x00, returndatasize())\n                revert(0x00, returndatasize())\n            }\n            returndatacopy(0x00, 0x00, returndatasize())\n            return(0x00, returndatasize())\n        }\n    }\n}\n"
    }
  },
  "settings": {
    "remappings": [
      "forge-std/=test/utils/forge-std/",
      "murky/=lib/murky/",
      "dn404/=lib/dn404/src/",
      "solady/=lib/solady/src/",
      "ds-test/=lib/murky/lib/forge-std/lib/ds-test/src/",
      "forge-std/=lib/murky/lib/forge-std/src/",
      "murky/=lib/murky/",
      "openzeppelin-contracts/=lib/murky/lib/openzeppelin-contracts/",
      "solady/=lib/solady/src/",
      "soledge/=lib/soledge/src/"
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
    "evmVersion": "cancun",
    "viaIR": false,
    "libraries": {}
  }
}}