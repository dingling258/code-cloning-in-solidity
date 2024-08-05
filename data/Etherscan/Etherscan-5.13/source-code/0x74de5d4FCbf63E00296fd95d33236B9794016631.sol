{"Constants.84ef19f8.sol":{"content":"// SPDX-License-Identifier: MIT\r\n\r\npragma solidity ^0.6.0;\r\n\r\nlibrary Constants {\r\n    address internal constant ETH = 0x0000000000000000000000000000000000000000;\r\n}\r\n"},"Spender.3372a096.sol":{"content":"// SPDX-License-Identifier: MIT\r\n\r\npragma solidity ^0.6.0;\r\n\r\nimport \"./Constants.84ef19f8.sol\";\r\n\r\ncontract Spender {\r\n    address public immutable metaswap;\r\n\r\n    constructor() public {\r\n        metaswap = msg.sender;\r\n    }\r\n\r\n    /// @dev Receives ether from swaps\r\n    fallback() external payable {}\r\n\r\n    function swap(address adapter, bytes calldata data) external payable {\r\n        require(msg.sender == metaswap, \"FORBIDDEN\");\r\n        require(adapter != address(0), \"ADAPTER_NOT_PROVIDED\");\r\n        _delegate(adapter, data, \"ADAPTER_DELEGATECALL_FAILED\");\r\n    }\r\n\r\n    /**\r\n     * @dev Performs a delegatecall and bubbles up the errors, adapted from\r\n     * https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol\r\n     * @param target Address of the contract to delegatecall\r\n     * @param data Data passed in the delegatecall\r\n     * @param errorMessage Fallback revert reason\r\n     */\r\n    function _delegate(\r\n        address target,\r\n        bytes memory data,\r\n        string memory errorMessage\r\n    ) private returns (bytes memory) {\r\n        // solhint-disable-next-line avoid-low-level-calls\r\n        (bool success, bytes memory returndata) = target.delegatecall(data);\r\n        if (success) {\r\n            return returndata;\r\n        } else {\r\n            // Look for revert reason and bubble it up if present\r\n            if (returndata.length \u003e 0) {\r\n                // The easiest way to bubble the revert reason is using memory via assembly\r\n\r\n                // solhint-disable-next-line no-inline-assembly\r\n                assembly {\r\n                    let returndata_size := mload(returndata)\r\n                    revert(add(32, returndata), returndata_size)\r\n                }\r\n            } else {\r\n                revert(errorMessage);\r\n            }\r\n        }\r\n    }\r\n}\r\n"}}