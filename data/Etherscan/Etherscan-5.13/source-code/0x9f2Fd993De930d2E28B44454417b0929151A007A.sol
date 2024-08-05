{{
  "language": "Solidity",
  "settings": {
    "evmVersion": "london",
    "libraries": {},
    "metadata": {
      "bytecodeHash": "none",
      "useLiteralContent": true
    },
    "optimizer": {
      "enabled": true,
      "runs": 10
    },
    "remappings": [],
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
  },
  "sources": {
    "@solidstate/contracts/access/access_control/AccessControlInternal.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\nimport { EnumerableSet } from '../../data/EnumerableSet.sol';\nimport { AddressUtils } from '../../utils/AddressUtils.sol';\nimport { UintUtils } from '../../utils/UintUtils.sol';\nimport { IAccessControlInternal } from './IAccessControlInternal.sol';\nimport { AccessControlStorage } from './AccessControlStorage.sol';\n\n/**\n * @title Role-based access control system\n * @dev derived from https://github.com/OpenZeppelin/openzeppelin-contracts (MIT license)\n */\nabstract contract AccessControlInternal is IAccessControlInternal {\n    using AddressUtils for address;\n    using EnumerableSet for EnumerableSet.AddressSet;\n    using UintUtils for uint256;\n\n    modifier onlyRole(bytes32 role) {\n        _checkRole(role);\n        _;\n    }\n\n    /*\n     * @notice query whether role is assigned to account\n     * @param role role to query\n     * @param account account to query\n     * @return whether role is assigned to account\n     */\n    function _hasRole(\n        bytes32 role,\n        address account\n    ) internal view virtual returns (bool) {\n        return\n            AccessControlStorage.layout().roles[role].members.contains(account);\n    }\n\n    /**\n     * @notice revert if sender does not have given role\n     * @param role role to query\n     */\n    function _checkRole(bytes32 role) internal view virtual {\n        _checkRole(role, msg.sender);\n    }\n\n    /**\n     * @notice revert if given account does not have given role\n     * @param role role to query\n     * @param account to query\n     */\n    function _checkRole(bytes32 role, address account) internal view virtual {\n        if (!_hasRole(role, account)) {\n            revert(\n                string(\n                    abi.encodePacked(\n                        'AccessControl: account ',\n                        account.toString(),\n                        ' is missing role ',\n                        uint256(role).toHexString(32)\n                    )\n                )\n            );\n        }\n    }\n\n    /*\n     * @notice query admin role for given role\n     * @param role role to query\n     * @return admin role\n     */\n    function _getRoleAdmin(\n        bytes32 role\n    ) internal view virtual returns (bytes32) {\n        return AccessControlStorage.layout().roles[role].adminRole;\n    }\n\n    /**\n     * @notice set role as admin role\n     * @param role role to set\n     * @param adminRole admin role to set\n     */\n    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {\n        bytes32 previousAdminRole = _getRoleAdmin(role);\n        AccessControlStorage.layout().roles[role].adminRole = adminRole;\n        emit RoleAdminChanged(role, previousAdminRole, adminRole);\n    }\n\n    /*\n     * @notice assign role to given account\n     * @param role role to assign\n     * @param account recipient of role assignment\n     */\n    function _grantRole(bytes32 role, address account) internal virtual {\n        AccessControlStorage.layout().roles[role].members.add(account);\n        emit RoleGranted(role, account, msg.sender);\n    }\n\n    /*\n     * @notice unassign role from given account\n     * @param role role to unassign\n     * @parm account\n     */\n    function _revokeRole(bytes32 role, address account) internal virtual {\n        AccessControlStorage.layout().roles[role].members.remove(account);\n        emit RoleRevoked(role, account, msg.sender);\n    }\n\n    /**\n     * @notice relinquish role\n     * @param role role to relinquish\n     */\n    function _renounceRole(bytes32 role) internal virtual {\n        _revokeRole(role, msg.sender);\n    }\n\n    /**\n     * @notice query role for member at given index\n     * @param role role to query\n     * @param index index to query\n     */\n    function _getRoleMember(\n        bytes32 role,\n        uint256 index\n    ) internal view virtual returns (address) {\n        return AccessControlStorage.layout().roles[role].members.at(index);\n    }\n\n    /**\n     * @notice query role for member count\n     * @param role role to query\n     */\n    function _getRoleMemberCount(\n        bytes32 role\n    ) internal view virtual returns (uint256) {\n        return AccessControlStorage.layout().roles[role].members.length();\n    }\n}\n"
    },
    "@solidstate/contracts/access/access_control/AccessControlStorage.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\nimport { EnumerableSet } from '../../data/EnumerableSet.sol';\n\nlibrary AccessControlStorage {\n    struct RoleData {\n        EnumerableSet.AddressSet members;\n        bytes32 adminRole;\n    }\n\n    struct Layout {\n        mapping(bytes32 => RoleData) roles;\n    }\n\n    bytes32 internal constant DEFAULT_ADMIN_ROLE = 0x00;\n\n    bytes32 internal constant STORAGE_SLOT =\n        keccak256('solidstate.contracts.storage.AccessControl');\n\n    function layout() internal pure returns (Layout storage l) {\n        bytes32 slot = STORAGE_SLOT;\n        assembly {\n            l.slot := slot\n        }\n    }\n}\n"
    },
    "@solidstate/contracts/access/access_control/IAccessControlInternal.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\n/**\n * @title Partial AccessControl interface needed by internal functions\n */\ninterface IAccessControlInternal {\n    event RoleAdminChanged(\n        bytes32 indexed role,\n        bytes32 indexed previousAdminRole,\n        bytes32 indexed newAdminRole\n    );\n\n    event RoleGranted(\n        bytes32 indexed role,\n        address indexed account,\n        address indexed sender\n    );\n\n    event RoleRevoked(\n        bytes32 indexed role,\n        address indexed account,\n        address indexed sender\n    );\n}\n"
    },
    "@solidstate/contracts/data/EnumerableSet.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.8;\n\n/**\n * @title Set implementation with enumeration functions\n * @dev derived from https://github.com/OpenZeppelin/openzeppelin-contracts (MIT license)\n */\nlibrary EnumerableSet {\n    error EnumerableSet__IndexOutOfBounds();\n\n    struct Set {\n        bytes32[] _values;\n        // 1-indexed to allow 0 to signify nonexistence\n        mapping(bytes32 => uint256) _indexes;\n    }\n\n    struct Bytes32Set {\n        Set _inner;\n    }\n\n    struct AddressSet {\n        Set _inner;\n    }\n\n    struct UintSet {\n        Set _inner;\n    }\n\n    function at(\n        Bytes32Set storage set,\n        uint256 index\n    ) internal view returns (bytes32) {\n        return _at(set._inner, index);\n    }\n\n    function at(\n        AddressSet storage set,\n        uint256 index\n    ) internal view returns (address) {\n        return address(uint160(uint256(_at(set._inner, index))));\n    }\n\n    function at(\n        UintSet storage set,\n        uint256 index\n    ) internal view returns (uint256) {\n        return uint256(_at(set._inner, index));\n    }\n\n    function contains(\n        Bytes32Set storage set,\n        bytes32 value\n    ) internal view returns (bool) {\n        return _contains(set._inner, value);\n    }\n\n    function contains(\n        AddressSet storage set,\n        address value\n    ) internal view returns (bool) {\n        return _contains(set._inner, bytes32(uint256(uint160(value))));\n    }\n\n    function contains(\n        UintSet storage set,\n        uint256 value\n    ) internal view returns (bool) {\n        return _contains(set._inner, bytes32(value));\n    }\n\n    function indexOf(\n        Bytes32Set storage set,\n        bytes32 value\n    ) internal view returns (uint256) {\n        return _indexOf(set._inner, value);\n    }\n\n    function indexOf(\n        AddressSet storage set,\n        address value\n    ) internal view returns (uint256) {\n        return _indexOf(set._inner, bytes32(uint256(uint160(value))));\n    }\n\n    function indexOf(\n        UintSet storage set,\n        uint256 value\n    ) internal view returns (uint256) {\n        return _indexOf(set._inner, bytes32(value));\n    }\n\n    function length(Bytes32Set storage set) internal view returns (uint256) {\n        return _length(set._inner);\n    }\n\n    function length(AddressSet storage set) internal view returns (uint256) {\n        return _length(set._inner);\n    }\n\n    function length(UintSet storage set) internal view returns (uint256) {\n        return _length(set._inner);\n    }\n\n    function add(\n        Bytes32Set storage set,\n        bytes32 value\n    ) internal returns (bool) {\n        return _add(set._inner, value);\n    }\n\n    function add(\n        AddressSet storage set,\n        address value\n    ) internal returns (bool) {\n        return _add(set._inner, bytes32(uint256(uint160(value))));\n    }\n\n    function add(UintSet storage set, uint256 value) internal returns (bool) {\n        return _add(set._inner, bytes32(value));\n    }\n\n    function remove(\n        Bytes32Set storage set,\n        bytes32 value\n    ) internal returns (bool) {\n        return _remove(set._inner, value);\n    }\n\n    function remove(\n        AddressSet storage set,\n        address value\n    ) internal returns (bool) {\n        return _remove(set._inner, bytes32(uint256(uint160(value))));\n    }\n\n    function remove(\n        UintSet storage set,\n        uint256 value\n    ) internal returns (bool) {\n        return _remove(set._inner, bytes32(value));\n    }\n\n    function toArray(\n        Bytes32Set storage set\n    ) internal view returns (bytes32[] memory) {\n        return set._inner._values;\n    }\n\n    function toArray(\n        AddressSet storage set\n    ) internal view returns (address[] memory) {\n        bytes32[] storage values = set._inner._values;\n        address[] storage array;\n\n        assembly {\n            array.slot := values.slot\n        }\n\n        return array;\n    }\n\n    function toArray(\n        UintSet storage set\n    ) internal view returns (uint256[] memory) {\n        bytes32[] storage values = set._inner._values;\n        uint256[] storage array;\n\n        assembly {\n            array.slot := values.slot\n        }\n\n        return array;\n    }\n\n    function _at(\n        Set storage set,\n        uint256 index\n    ) private view returns (bytes32) {\n        if (index >= set._values.length)\n            revert EnumerableSet__IndexOutOfBounds();\n        return set._values[index];\n    }\n\n    function _contains(\n        Set storage set,\n        bytes32 value\n    ) private view returns (bool) {\n        return set._indexes[value] != 0;\n    }\n\n    function _indexOf(\n        Set storage set,\n        bytes32 value\n    ) private view returns (uint256) {\n        unchecked {\n            return set._indexes[value] - 1;\n        }\n    }\n\n    function _length(Set storage set) private view returns (uint256) {\n        return set._values.length;\n    }\n\n    function _add(\n        Set storage set,\n        bytes32 value\n    ) private returns (bool status) {\n        if (!_contains(set, value)) {\n            set._values.push(value);\n            set._indexes[value] = set._values.length;\n            status = true;\n        }\n    }\n\n    function _remove(\n        Set storage set,\n        bytes32 value\n    ) private returns (bool status) {\n        uint256 valueIndex = set._indexes[value];\n\n        if (valueIndex != 0) {\n            unchecked {\n                bytes32 last = set._values[set._values.length - 1];\n\n                // move last value to now-vacant index\n\n                set._values[valueIndex - 1] = last;\n                set._indexes[last] = valueIndex;\n            }\n            // clear last index\n\n            set._values.pop();\n            delete set._indexes[value];\n\n            status = true;\n        }\n    }\n}\n"
    },
    "@solidstate/contracts/utils/AddressUtils.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.8;\n\nimport { UintUtils } from './UintUtils.sol';\n\nlibrary AddressUtils {\n    using UintUtils for uint256;\n\n    error AddressUtils__InsufficientBalance();\n    error AddressUtils__NotContract();\n    error AddressUtils__SendValueFailed();\n\n    function toString(address account) internal pure returns (string memory) {\n        return uint256(uint160(account)).toHexString(20);\n    }\n\n    function isContract(address account) internal view returns (bool) {\n        uint256 size;\n        assembly {\n            size := extcodesize(account)\n        }\n        return size > 0;\n    }\n\n    function sendValue(address payable account, uint256 amount) internal {\n        (bool success, ) = account.call{ value: amount }('');\n        if (!success) revert AddressUtils__SendValueFailed();\n    }\n\n    function functionCall(\n        address target,\n        bytes memory data\n    ) internal returns (bytes memory) {\n        return\n            functionCall(target, data, 'AddressUtils: failed low-level call');\n    }\n\n    function functionCall(\n        address target,\n        bytes memory data,\n        string memory error\n    ) internal returns (bytes memory) {\n        return _functionCallWithValue(target, data, 0, error);\n    }\n\n    function functionCallWithValue(\n        address target,\n        bytes memory data,\n        uint256 value\n    ) internal returns (bytes memory) {\n        return\n            functionCallWithValue(\n                target,\n                data,\n                value,\n                'AddressUtils: failed low-level call with value'\n            );\n    }\n\n    function functionCallWithValue(\n        address target,\n        bytes memory data,\n        uint256 value,\n        string memory error\n    ) internal returns (bytes memory) {\n        if (value > address(this).balance)\n            revert AddressUtils__InsufficientBalance();\n        return _functionCallWithValue(target, data, value, error);\n    }\n\n    /**\n     * @notice execute arbitrary external call with limited gas usage and amount of copied return data\n     * @dev derived from https://github.com/nomad-xyz/ExcessivelySafeCall (MIT License)\n     * @param target recipient of call\n     * @param gasAmount gas allowance for call\n     * @param value native token value to include in call\n     * @param maxCopy maximum number of bytes to copy from return data\n     * @param data encoded call data\n     * @return success whether call is successful\n     * @return returnData copied return data\n     */\n    function excessivelySafeCall(\n        address target,\n        uint256 gasAmount,\n        uint256 value,\n        uint16 maxCopy,\n        bytes memory data\n    ) internal returns (bool success, bytes memory returnData) {\n        returnData = new bytes(maxCopy);\n\n        assembly {\n            // execute external call via assembly to avoid automatic copying of return data\n            success := call(\n                gasAmount,\n                target,\n                value,\n                add(data, 0x20),\n                mload(data),\n                0,\n                0\n            )\n\n            // determine whether to limit amount of data to copy\n            let toCopy := returndatasize()\n\n            if gt(toCopy, maxCopy) {\n                toCopy := maxCopy\n            }\n\n            // store the length of the copied bytes\n            mstore(returnData, toCopy)\n\n            // copy the bytes from returndata[0:toCopy]\n            returndatacopy(add(returnData, 0x20), 0, toCopy)\n        }\n    }\n\n    function _functionCallWithValue(\n        address target,\n        bytes memory data,\n        uint256 value,\n        string memory error\n    ) private returns (bytes memory) {\n        if (!isContract(target)) revert AddressUtils__NotContract();\n\n        (bool success, bytes memory returnData) = target.call{ value: value }(\n            data\n        );\n\n        if (success) {\n            return returnData;\n        } else if (returnData.length > 0) {\n            assembly {\n                let returnData_size := mload(returnData)\n                revert(add(32, returnData), returnData_size)\n            }\n        } else {\n            revert(error);\n        }\n    }\n}\n"
    },
    "@solidstate/contracts/utils/UintUtils.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.8;\n\n/**\n * @title utility functions for uint256 operations\n * @dev derived from https://github.com/OpenZeppelin/openzeppelin-contracts/ (MIT license)\n */\nlibrary UintUtils {\n    error UintUtils__InsufficientHexLength();\n\n    bytes16 private constant HEX_SYMBOLS = '0123456789abcdef';\n\n    function add(uint256 a, int256 b) internal pure returns (uint256) {\n        return b < 0 ? sub(a, -b) : a + uint256(b);\n    }\n\n    function sub(uint256 a, int256 b) internal pure returns (uint256) {\n        return b < 0 ? add(a, -b) : a - uint256(b);\n    }\n\n    function toString(uint256 value) internal pure returns (string memory) {\n        if (value == 0) {\n            return '0';\n        }\n\n        uint256 temp = value;\n        uint256 digits;\n\n        while (temp != 0) {\n            digits++;\n            temp /= 10;\n        }\n\n        bytes memory buffer = new bytes(digits);\n\n        while (value != 0) {\n            digits -= 1;\n            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));\n            value /= 10;\n        }\n\n        return string(buffer);\n    }\n\n    function toHexString(uint256 value) internal pure returns (string memory) {\n        if (value == 0) {\n            return '0x00';\n        }\n\n        uint256 length = 0;\n\n        for (uint256 temp = value; temp != 0; temp >>= 8) {\n            unchecked {\n                length++;\n            }\n        }\n\n        return toHexString(value, length);\n    }\n\n    function toHexString(\n        uint256 value,\n        uint256 length\n    ) internal pure returns (string memory) {\n        bytes memory buffer = new bytes(2 * length + 2);\n        buffer[0] = '0';\n        buffer[1] = 'x';\n\n        unchecked {\n            for (uint256 i = 2 * length + 1; i > 1; --i) {\n                buffer[i] = HEX_SYMBOLS[value & 0xf];\n                value >>= 4;\n            }\n        }\n\n        if (value != 0) revert UintUtils__InsufficientHexLength();\n\n        return string(buffer);\n    }\n}\n"
    },
    "contracts/common/admin/facets/WhitelistFacet.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity 0.8.23;\n\nimport { AccessControlInternal } from \"@solidstate/contracts/access/access_control/AccessControlInternal.sol\";\n\nimport { LibAccessControl } from \"../libraries/LibAccessControl.sol\";\nimport { LibWhitelabel } from \"../libraries/LibWhitelabel.sol\";\nimport { IWhitelistFacet } from \"../interfaces/IWhitelistFacet.sol\";\n\ncontract WhitelistFacet is IWhitelistFacet, AccessControlInternal {\n    function isWhitelistEnabled(bytes32 productId) external view returns (bool) {\n        LibWhitelabel.DiamondStorage storage ds = LibWhitelabel.diamondStorage();\n        return ds.isWhitelistEnabled[productId];\n    }\n\n    function setWhitelistEnabled(bool enabled, bytes32 productId) external onlyAdmin {\n        LibWhitelabel.DiamondStorage storage ds = LibWhitelabel.diamondStorage();\n        ds.isWhitelistEnabled[productId] = enabled;\n    }\n\n    modifier onlyAdmin() {\n        require(_hasRole(LibAccessControl.WHITELIST_ADMIN_ROLE, msg.sender) || msg.sender == address(this), \"Whitelist: caller is not an admin\");\n        _;\n    }\n}\n"
    },
    "contracts/common/admin/interfaces/IWhitelistFacet.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity 0.8.23;\n\ninterface IWhitelistFacet {\n    function isWhitelistEnabled(bytes32 productId) external view returns (bool);\n\n    function setWhitelistEnabled(bool enabled, bytes32 productId) external;\n}\n"
    },
    "contracts/common/admin/libraries/LibAccessControl.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity 0.8.23;\n\nlibrary LibAccessControl {\n    bytes32 internal constant DEFAULT_ADMIN_ROLE = 0x00;\n    bytes32 internal constant WHITELIST_ADMIN_ROLE = keccak256(\"WHITELIST_ADMIN_ROLE\");\n    bytes32 internal constant WHITELISTED_ROLE = keccak256(\"WHITELISTED_ROLE\");\n}\n"
    },
    "contracts/common/admin/libraries/LibWhitelabel.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity 0.8.23;\n\nlibrary LibWhitelabel {\n    bytes32 internal constant DIAMOND_STORAGE_POSITION = keccak256(\"floki.whitelabel.diamond.storage\");\n\n    struct DiamondStorage {\n        mapping(bytes32 => bool) isWhitelistEnabled; // bytes32 is productIdentifier generated using keccak256\n    }\n\n    event WhitelistedAdded(address indexed account);\n    event WhitelistedRemoved(address indexed account);\n\n    function diamondStorage() internal pure returns (DiamondStorage storage ds) {\n        bytes32 position = DIAMOND_STORAGE_POSITION;\n        // solhint-disable-next-line no-inline-assembly\n        assembly {\n            ds.slot := position\n        }\n    }\n}\n"
    }
  }
}}