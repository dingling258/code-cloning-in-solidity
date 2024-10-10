{{
  "language": "Solidity",
  "sources": {
    "lib/solmate/src/auth/authorities/RolesAuthority.sol": {
      "content": "// SPDX-License-Identifier: AGPL-3.0-only\npragma solidity >=0.8.0;\n\nimport {Auth, Authority} from \"../Auth.sol\";\n\n/// @notice Role based Authority that supports up to 256 roles.\n/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/auth/authorities/RolesAuthority.sol)\n/// @author Modified from Dappsys (https://github.com/dapphub/ds-roles/blob/master/src/roles.sol)\ncontract RolesAuthority is Auth, Authority {\n    /*//////////////////////////////////////////////////////////////\n                                 EVENTS\n    //////////////////////////////////////////////////////////////*/\n\n    event UserRoleUpdated(address indexed user, uint8 indexed role, bool enabled);\n\n    event PublicCapabilityUpdated(address indexed target, bytes4 indexed functionSig, bool enabled);\n\n    event RoleCapabilityUpdated(uint8 indexed role, address indexed target, bytes4 indexed functionSig, bool enabled);\n\n    /*//////////////////////////////////////////////////////////////\n                               CONSTRUCTOR\n    //////////////////////////////////////////////////////////////*/\n\n    constructor(address _owner, Authority _authority) Auth(_owner, _authority) {}\n\n    /*//////////////////////////////////////////////////////////////\n                            ROLE/USER STORAGE\n    //////////////////////////////////////////////////////////////*/\n\n    mapping(address => bytes32) public getUserRoles;\n\n    mapping(address => mapping(bytes4 => bool)) public isCapabilityPublic;\n\n    mapping(address => mapping(bytes4 => bytes32)) public getRolesWithCapability;\n\n    function doesUserHaveRole(address user, uint8 role) public view virtual returns (bool) {\n        return (uint256(getUserRoles[user]) >> role) & 1 != 0;\n    }\n\n    function doesRoleHaveCapability(\n        uint8 role,\n        address target,\n        bytes4 functionSig\n    ) public view virtual returns (bool) {\n        return (uint256(getRolesWithCapability[target][functionSig]) >> role) & 1 != 0;\n    }\n\n    /*//////////////////////////////////////////////////////////////\n                           AUTHORIZATION LOGIC\n    //////////////////////////////////////////////////////////////*/\n\n    function canCall(\n        address user,\n        address target,\n        bytes4 functionSig\n    ) public view virtual override returns (bool) {\n        return\n            isCapabilityPublic[target][functionSig] ||\n            bytes32(0) != getUserRoles[user] & getRolesWithCapability[target][functionSig];\n    }\n\n    /*//////////////////////////////////////////////////////////////\n                   ROLE CAPABILITY CONFIGURATION LOGIC\n    //////////////////////////////////////////////////////////////*/\n\n    function setPublicCapability(\n        address target,\n        bytes4 functionSig,\n        bool enabled\n    ) public virtual requiresAuth {\n        isCapabilityPublic[target][functionSig] = enabled;\n\n        emit PublicCapabilityUpdated(target, functionSig, enabled);\n    }\n\n    function setRoleCapability(\n        uint8 role,\n        address target,\n        bytes4 functionSig,\n        bool enabled\n    ) public virtual requiresAuth {\n        if (enabled) {\n            getRolesWithCapability[target][functionSig] |= bytes32(1 << role);\n        } else {\n            getRolesWithCapability[target][functionSig] &= ~bytes32(1 << role);\n        }\n\n        emit RoleCapabilityUpdated(role, target, functionSig, enabled);\n    }\n\n    /*//////////////////////////////////////////////////////////////\n                       USER ROLE ASSIGNMENT LOGIC\n    //////////////////////////////////////////////////////////////*/\n\n    function setUserRole(\n        address user,\n        uint8 role,\n        bool enabled\n    ) public virtual requiresAuth {\n        if (enabled) {\n            getUserRoles[user] |= bytes32(1 << role);\n        } else {\n            getUserRoles[user] &= ~bytes32(1 << role);\n        }\n\n        emit UserRoleUpdated(user, role, enabled);\n    }\n}\n"
    },
    "lib/solmate/src/auth/Auth.sol": {
      "content": "// SPDX-License-Identifier: AGPL-3.0-only\npragma solidity >=0.8.0;\n\n/// @notice Provides a flexible and updatable auth pattern which is completely separate from application logic.\n/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/auth/Auth.sol)\n/// @author Modified from Dappsys (https://github.com/dapphub/ds-auth/blob/master/src/auth.sol)\nabstract contract Auth {\n    event OwnershipTransferred(address indexed user, address indexed newOwner);\n\n    event AuthorityUpdated(address indexed user, Authority indexed newAuthority);\n\n    address public owner;\n\n    Authority public authority;\n\n    constructor(address _owner, Authority _authority) {\n        owner = _owner;\n        authority = _authority;\n\n        emit OwnershipTransferred(msg.sender, _owner);\n        emit AuthorityUpdated(msg.sender, _authority);\n    }\n\n    modifier requiresAuth() virtual {\n        require(isAuthorized(msg.sender, msg.sig), \"UNAUTHORIZED\");\n\n        _;\n    }\n\n    function isAuthorized(address user, bytes4 functionSig) internal view virtual returns (bool) {\n        Authority auth = authority; // Memoizing authority saves us a warm SLOAD, around 100 gas.\n\n        // Checking if the caller is the owner only after calling the authority saves gas in most cases, but be\n        // aware that this makes protected functions uncallable even to the owner if the authority is out of order.\n        return (address(auth) != address(0) && auth.canCall(user, address(this), functionSig)) || user == owner;\n    }\n\n    function setAuthority(Authority newAuthority) public virtual {\n        // We check if the caller is the owner first because we want to ensure they can\n        // always swap out the authority even if it's reverting or using up a lot of gas.\n        require(msg.sender == owner || authority.canCall(msg.sender, address(this), msg.sig));\n\n        authority = newAuthority;\n\n        emit AuthorityUpdated(msg.sender, newAuthority);\n    }\n\n    function transferOwnership(address newOwner) public virtual requiresAuth {\n        owner = newOwner;\n\n        emit OwnershipTransferred(msg.sender, newOwner);\n    }\n}\n\n/// @notice A generic interface for a contract which provides authorization data to an Auth instance.\n/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/auth/Auth.sol)\n/// @author Modified from Dappsys (https://github.com/dapphub/ds-auth/blob/master/src/auth.sol)\ninterface Authority {\n    function canCall(\n        address user,\n        address target,\n        bytes4 functionSig\n    ) external view returns (bool);\n}\n"
    }
  },
  "settings": {
    "remappings": [
      "@solmate/=lib/solmate/src/",
      "@forge-std/=lib/forge-std/src/",
      "@ds-test/=lib/forge-std/lib/ds-test/src/",
      "ds-test/=lib/forge-std/lib/ds-test/src/",
      "@openzeppelin/=lib/openzeppelin-contracts/",
      "@uniswap/v3-periphery/=lib/v3-periphery/",
      "@uniswap/v3-core/=lib/v3-core/",
      "@chainlink/=lib/chainlink/",
      "@uniswapV3P/=lib/v3-periphery/contracts/",
      "@uniswapV3C/=lib/v3-core/contracts/",
      "@balancer/=lib/balancer-v2-monorepo/pkg/",
      "@ccip/=lib/ccip/",
      "@pendle/=lib/pendle-core-v2-public/",
      "@balancer-labs/=lib/balancer-v2-monorepo/../../node_modules/@balancer-labs/",
      "axelar-gmp-sdk-solidity/=lib/axelar-gmp-sdk-solidity/contracts/",
      "balancer-v2-monorepo/=lib/balancer-v2-monorepo/",
      "ccip/=lib/ccip/contracts/",
      "chainlink/=lib/chainlink/integration-tests/contracts/ethereum/src/",
      "forge-std/=lib/forge-std/src/",
      "openzeppelin-contracts/=lib/openzeppelin-contracts/",
      "pendle-core-v2-public/=lib/pendle-core-v2-public/contracts/",
      "solmate/=lib/solmate/src/",
      "v3-core/=lib/v3-core/contracts/",
      "v3-periphery/=lib/v3-periphery/contracts/"
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