{{
  "language": "Solidity",
  "sources": {
    "contracts/TokenLock.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\n\nimport \"@openzeppelin/contracts/token/ERC20/IERC20.sol\";\n\ncontract TokenLock {\n    address public immutable owner;\n    IERC20 public immutable token;\n    uint256 public immutable lockDuration;\n    uint256 public immutable cutoffTime;\n\n    uint256 public totalLocked;\n\n    struct LockInfo {\n        uint256 amount;\n        uint256 releaseTime;\n    }\n\n    mapping(address => LockInfo) public locks;\n\n    event Locked(address indexed user, uint256 amount, uint256 releaseTime);\n    event Withdrawn(address indexed user, uint256 amount);\n    event WithdrawSurplusTo(address indexed to, uint256 amount);\n\n    constructor(address _owner, address _token, uint256 _lockDuration, uint256 _cutoffTime) {\n        owner = _owner;\n        token = IERC20(_token);\n        lockDuration = _lockDuration;\n        cutoffTime = _cutoffTime;\n    }\n\n    function lock(uint256 _amount) external {\n        require(block.timestamp <= cutoffTime, \"LOCKING_PERIOD_OVER\");\n        require(_amount > 0, \"WRONG_AMOUNT\");\n\n        LockInfo storage userLock = locks[msg.sender];\n        userLock.amount += _amount;\n        userLock.releaseTime = block.timestamp + lockDuration;\n        totalLocked += _amount;\n        emit Locked(msg.sender, userLock.amount, userLock.releaseTime);\n\n        bool success = _makeTransferFrom(msg.sender, address(this), _amount);\n        require(success, \"TRANSFER_FAILED\");\n\n    }\n\n    function withdraw() external {\n        LockInfo storage userLock = locks[msg.sender];\n        require(userLock.amount > 0, \"NO_LOCKED_TOKENS\");\n        require(block.timestamp >= userLock.releaseTime, \"LOCK_NOT_EXPIRED\");\n\n        uint256 amount = userLock.amount;\n        userLock.amount = 0;\n\n        totalLocked -= amount;\n\n        bool success = _makeTransfer(msg.sender, amount);\n        require(success, \"TRANSFER_FAILED\");\n\n        emit Withdrawn(msg.sender, amount);\n    }\n\n    /**\n     * @dev Withdraws surplus tokens to the specified address. Normally there\n     * won't be any surplus and this function will revert. It is only useful\n     * after an accidental transfer of tokens to this contract that bypassed\n     * the lock function.\n     */\n    function withdrawSurplusTo(address to) external onlyOwner {\n        require(to != address(0), \"ZERO_ADDRESS\");\n        uint256 balance = token.balanceOf(address(this));\n        require (totalLocked < balance, \"NO_SURPLUS\");\n        uint256 surplus = balance - totalLocked;\n        bool success = _makeTransfer(to, surplus);\n        require(success, \"TRANSFER_FAILED\");\n        emit WithdrawSurplusTo(to, surplus);\n    }\n    \n    modifier onlyOwner() {\n        require(msg.sender == owner, \"ONLY_OWNER\");\n        _;\n    }\n\n    function _makeTransfer(\n        address to,\n        uint256 amount\n    ) private returns (bool success) {\n        return\n            _tokenCall(\n                abi.encodeWithSelector(\n                    token.transfer.selector,\n                    to,\n                    amount\n                )\n            );\n    }\n\n    function _makeTransferFrom(\n        address from,\n        address to,\n        uint256 amount\n    ) private returns (bool success) {\n        return\n            _tokenCall(\n                abi.encodeWithSelector(\n                    token.transferFrom.selector,\n                    from,\n                    to,\n                    amount\n                )\n            );\n    }\n\n    function _tokenCall(bytes memory data) private returns (bool) {\n        (bool success, bytes memory returndata) = address(token).call(data);\n        if (success) { \n            if (returndata.length > 0) {\n                success = abi.decode(returndata, (bool));\n            } else {\n                success = address(token).code.length > 0;\n            }\n        }\n        return success;\n    }\n}\n"
    },
    "@openzeppelin/contracts/token/ERC20/IERC20.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Interface of the ERC20 standard as defined in the EIP.\n */\ninterface IERC20 {\n    /**\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\n     * another (`to`).\n     *\n     * Note that `value` may be zero.\n     */\n    event Transfer(address indexed from, address indexed to, uint256 value);\n\n    /**\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\n     * a call to {approve}. `value` is the new allowance.\n     */\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n\n    /**\n     * @dev Returns the amount of tokens in existence.\n     */\n    function totalSupply() external view returns (uint256);\n\n    /**\n     * @dev Returns the amount of tokens owned by `account`.\n     */\n    function balanceOf(address account) external view returns (uint256);\n\n    /**\n     * @dev Moves `amount` tokens from the caller's account to `to`.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transfer(address to, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Returns the remaining number of tokens that `spender` will be\n     * allowed to spend on behalf of `owner` through {transferFrom}. This is\n     * zero by default.\n     *\n     * This value changes when {approve} or {transferFrom} are called.\n     */\n    function allowance(address owner, address spender) external view returns (uint256);\n\n    /**\n     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\n     * that someone may use both the old and the new allowance by unfortunate\n     * transaction ordering. One possible solution to mitigate this race\n     * condition is to first reduce the spender's allowance to 0 and set the\n     * desired value afterwards:\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\n     *\n     * Emits an {Approval} event.\n     */\n    function approve(address spender, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Moves `amount` tokens from `from` to `to` using the\n     * allowance mechanism. `amount` is then deducted from the caller's\n     * allowance.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transferFrom(\n        address from,\n        address to,\n        uint256 amount\n    ) external returns (bool);\n}\n"
    }
  },
  "settings": {
    "viaIR": true,
    "optimizer": {
      "enabled": true,
      "runs": 200,
      "details": {
        "yulDetails": {
          "optimizerSteps": "u"
        }
      }
    },
    "outputSelection": {
      "*": {
        "*": [
          "evm.bytecode",
          "evm.deployedBytecode",
          "abi"
        ]
      }
    }
  }
}}