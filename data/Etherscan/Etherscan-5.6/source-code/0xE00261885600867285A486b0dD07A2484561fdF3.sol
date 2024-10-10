{{
  "language": "Solidity",
  "settings": {
    "evmVersion": "berlin",
    "libraries": {},
    "metadata": {
      "bytecodeHash": "ipfs",
      "useLiteralContent": true
    },
    "optimizer": {
      "enabled": true,
      "runs": 100000
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
    "@zerolendxyz/core-v3/contracts/dependencies/openzeppelin/contracts/Context.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity 0.8.12;\n\n/*\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with GSN meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract Context {\n  function _msgSender() internal view virtual returns (address payable) {\n    return payable(msg.sender);\n  }\n\n  function _msgData() internal view virtual returns (bytes memory) {\n    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691\n    return msg.data;\n  }\n}\n"
    },
    "@zerolendxyz/core-v3/contracts/dependencies/openzeppelin/contracts/IERC20.sol": {
      "content": "// SPDX-License-Identifier: AGPL-3.0\npragma solidity ^0.8.0;\n\n/**\n * @dev Interface of the ERC20 standard as defined in the EIP.\n */\ninterface IERC20 {\n  /**\n   * @dev Returns the amount of tokens in existence.\n   */\n  function totalSupply() external view returns (uint256);\n\n  /**\n   * @dev Returns the amount of tokens owned by `account`.\n   */\n  function balanceOf(address account) external view returns (uint256);\n\n  /**\n   * @dev Moves `amount` tokens from the caller's account to `recipient`.\n   *\n   * Returns a boolean value indicating whether the operation succeeded.\n   *\n   * Emits a {Transfer} event.\n   */\n  function transfer(address recipient, uint256 amount) external returns (bool);\n\n  /**\n   * @dev Returns the remaining number of tokens that `spender` will be\n   * allowed to spend on behalf of `owner` through {transferFrom}. This is\n   * zero by default.\n   *\n   * This value changes when {approve} or {transferFrom} are called.\n   */\n  function allowance(address owner, address spender) external view returns (uint256);\n\n  /**\n   * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.\n   *\n   * Returns a boolean value indicating whether the operation succeeded.\n   *\n   * IMPORTANT: Beware that changing an allowance with this method brings the risk\n   * that someone may use both the old and the new allowance by unfortunate\n   * transaction ordering. One possible solution to mitigate this race\n   * condition is to first reduce the spender's allowance to 0 and set the\n   * desired value afterwards:\n   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\n   *\n   * Emits an {Approval} event.\n   */\n  function approve(address spender, uint256 amount) external returns (bool);\n\n  /**\n   * @dev Moves `amount` tokens from `sender` to `recipient` using the\n   * allowance mechanism. `amount` is then deducted from the caller's\n   * allowance.\n   *\n   * Returns a boolean value indicating whether the operation succeeded.\n   *\n   * Emits a {Transfer} event.\n   */\n  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);\n\n  /**\n   * @dev Emitted when `value` tokens are moved from one account (`from`) to\n   * another (`to`).\n   *\n   * Note that `value` may be zero.\n   */\n  event Transfer(address indexed from, address indexed to, uint256 value);\n\n  /**\n   * @dev Emitted when the allowance of a `spender` for an `owner` is set by\n   * a call to {approve}. `value` is the new allowance.\n   */\n  event Approval(address indexed owner, address indexed spender, uint256 value);\n}\n"
    },
    "@zerolendxyz/core-v3/contracts/dependencies/openzeppelin/contracts/Ownable.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity 0.8.12;\n\nimport './Context.sol';\n\n/**\n * @dev Contract module which provides a basic access control mechanism, where\n * there is an account (an owner) that can be granted exclusive access to\n * specific functions.\n *\n * By default, the owner account will be the one that deploys the contract. This\n * can later be changed with {transferOwnership}.\n *\n * This module is used through inheritance. It will make available the modifier\n * `onlyOwner`, which can be applied to your functions to restrict their use to\n * the owner.\n */\ncontract Ownable is Context {\n  address private _owner;\n\n  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n  /**\n   * @dev Initializes the contract setting the deployer as the initial owner.\n   */\n  constructor() {\n    address msgSender = _msgSender();\n    _owner = msgSender;\n    emit OwnershipTransferred(address(0), msgSender);\n  }\n\n  /**\n   * @dev Returns the address of the current owner.\n   */\n  function owner() public view returns (address) {\n    return _owner;\n  }\n\n  /**\n   * @dev Throws if called by any account other than the owner.\n   */\n  modifier onlyOwner() {\n    require(_owner == _msgSender(), 'Ownable: caller is not the owner');\n    _;\n  }\n\n  /**\n   * @dev Leaves the contract without owner. It will not be possible to call\n   * `onlyOwner` functions anymore. Can only be called by the current owner.\n   *\n   * NOTE: Renouncing ownership will leave the contract without an owner,\n   * thereby removing any functionality that is only available to the owner.\n   */\n  function renounceOwnership() public virtual onlyOwner {\n    emit OwnershipTransferred(_owner, address(0));\n    _owner = address(0);\n  }\n\n  /**\n   * @dev Transfers ownership of the contract to a new account (`newOwner`).\n   * Can only be called by the current owner.\n   */\n  function transferOwnership(address newOwner) public virtual onlyOwner {\n    require(newOwner != address(0), 'Ownable: new owner is the zero address');\n    emit OwnershipTransferred(_owner, newOwner);\n    _owner = newOwner;\n  }\n}\n"
    },
    "@zerolendxyz/periphery-v3/contracts/treasury/AaveEcosystemReserveController.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.12;\n\nimport {Ownable} from '@zerolendxyz/core-v3/contracts/dependencies/openzeppelin/contracts/Ownable.sol';\nimport {IStreamable} from './interfaces/IStreamable.sol';\nimport {IAdminControlledEcosystemReserve} from './interfaces/IAdminControlledEcosystemReserve.sol';\nimport {IAaveEcosystemReserveController} from './interfaces/IAaveEcosystemReserveController.sol';\nimport {IERC20} from '@zerolendxyz/core-v3/contracts/dependencies/openzeppelin/contracts/IERC20.sol';\n\ncontract AaveEcosystemReserveController is Ownable, IAaveEcosystemReserveController {\n  /**\n   * @notice Constructor.\n   * @param aaveGovShortTimelock The address of the Aave's governance executor, owning this contract\n   */\n  constructor(address aaveGovShortTimelock) {\n    transferOwnership(aaveGovShortTimelock);\n  }\n\n  /// @inheritdoc IAaveEcosystemReserveController\n  function approve(\n    address collector,\n    IERC20 token,\n    address recipient,\n    uint256 amount\n  ) external onlyOwner {\n    IAdminControlledEcosystemReserve(collector).approve(token, recipient, amount);\n  }\n\n  /// @inheritdoc IAaveEcosystemReserveController\n  function transfer(\n    address collector,\n    IERC20 token,\n    address recipient,\n    uint256 amount\n  ) external onlyOwner {\n    IAdminControlledEcosystemReserve(collector).transfer(token, recipient, amount);\n  }\n\n  /// @inheritdoc IAaveEcosystemReserveController\n  function createStream(\n    address collector,\n    address recipient,\n    uint256 deposit,\n    IERC20 tokenAddress,\n    uint256 startTime,\n    uint256 stopTime\n  ) external onlyOwner returns (uint256) {\n    return\n      IStreamable(collector).createStream(\n        recipient,\n        deposit,\n        address(tokenAddress),\n        startTime,\n        stopTime\n      );\n  }\n\n  /// @inheritdoc IAaveEcosystemReserveController\n  function withdrawFromStream(\n    address collector,\n    uint256 streamId,\n    uint256 funds\n  ) external onlyOwner returns (bool) {\n    return IStreamable(collector).withdrawFromStream(streamId, funds);\n  }\n\n  /// @inheritdoc IAaveEcosystemReserveController\n  function cancelStream(address collector, uint256 streamId) external onlyOwner returns (bool) {\n    return IStreamable(collector).cancelStream(streamId);\n  }\n}\n"
    },
    "@zerolendxyz/periphery-v3/contracts/treasury/interfaces/IAaveEcosystemReserveController.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.12;\n\nimport {IERC20} from '@zerolendxyz/core-v3/contracts/dependencies/openzeppelin/contracts/IERC20.sol';\n\ninterface IAaveEcosystemReserveController {\n  /**\n   * @notice Proxy function for ERC20's approve(), pointing to a specific collector contract\n   * @param collector The collector contract with funds (Aave ecosystem reserve)\n   * @param token The asset address\n   * @param recipient Allowance's recipient\n   * @param amount Allowance to approve\n   **/\n  function approve(address collector, IERC20 token, address recipient, uint256 amount) external;\n\n  /**\n   * @notice Proxy function for ERC20's transfer(), pointing to a specific collector contract\n   * @param collector The collector contract with funds (Aave ecosystem reserve)\n   * @param token The asset address\n   * @param recipient Transfer's recipient\n   * @param amount Amount to transfer\n   **/\n  function transfer(address collector, IERC20 token, address recipient, uint256 amount) external;\n\n  /**\n   * @notice Proxy function to create a stream of token on a specific collector contract\n   * @param collector The collector contract with funds (Aave ecosystem reserve)\n   * @param recipient The recipient of the stream of token\n   * @param deposit Total amount to be streamed\n   * @param tokenAddress The ERC20 token to use as streaming asset\n   * @param startTime The unix timestamp for when the stream starts\n   * @param stopTime The unix timestamp for when the stream stops\n   * @return uint256 The stream id created\n   **/\n  function createStream(\n    address collector,\n    address recipient,\n    uint256 deposit,\n    IERC20 tokenAddress,\n    uint256 startTime,\n    uint256 stopTime\n  ) external returns (uint256);\n\n  /**\n   * @notice Proxy function to withdraw from a stream of token on a specific collector contract\n   * @param collector The collector contract with funds (Aave ecosystem reserve)\n   * @param streamId The id of the stream to withdraw tokens from\n   * @param funds Amount to withdraw\n   * @return bool If the withdrawal finished properly\n   **/\n  function withdrawFromStream(\n    address collector,\n    uint256 streamId,\n    uint256 funds\n  ) external returns (bool);\n\n  /**\n   * @notice Proxy function to cancel a stream of token on a specific collector contract\n   * @param collector The collector contract with funds (Aave ecosystem reserve)\n   * @param streamId The id of the stream to cancel\n   * @return bool If the cancellation happened correctly\n   **/\n  function cancelStream(address collector, uint256 streamId) external returns (bool);\n}\n"
    },
    "@zerolendxyz/periphery-v3/contracts/treasury/interfaces/IAdminControlledEcosystemReserve.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\npragma solidity ^0.8.12;\n\nimport {IERC20} from '@zerolendxyz/core-v3/contracts/dependencies/openzeppelin/contracts/IERC20.sol';\n\ninterface IAdminControlledEcosystemReserve {\n  /** @notice Emitted when the funds admin changes\n   * @param fundsAdmin The new funds admin\n   **/\n  event NewFundsAdmin(address indexed fundsAdmin);\n\n  /** @notice Returns the mock ETH reference address\n   * @return address The address\n   **/\n  function ETH_MOCK_ADDRESS() external pure returns (address);\n\n  /**\n   * @notice Return the funds admin, only entity to be able to interact with this contract (controller of reserve)\n   * @return address The address of the funds admin\n   **/\n  function getFundsAdmin() external view returns (address);\n\n  /**\n   * @dev Function for the funds admin to give ERC20 allowance to other parties\n   * @param token The address of the token to give allowance from\n   * @param recipient Allowance's recipient\n   * @param amount Allowance to approve\n   **/\n  function approve(IERC20 token, address recipient, uint256 amount) external;\n\n  /**\n   * @notice Function for the funds admin to transfer ERC20 tokens to other parties\n   * @param token The address of the token to transfer\n   * @param recipient Transfer's recipient\n   * @param amount Amount to transfer\n   **/\n  function transfer(IERC20 token, address recipient, uint256 amount) external;\n}\n"
    },
    "@zerolendxyz/periphery-v3/contracts/treasury/interfaces/IStreamable.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.12;\n\ninterface IStreamable {\n  struct Stream {\n    uint256 deposit;\n    uint256 ratePerSecond;\n    uint256 remainingBalance;\n    uint256 startTime;\n    uint256 stopTime;\n    address recipient;\n    address sender;\n    address tokenAddress;\n    bool isEntity;\n  }\n\n  event CreateStream(\n    uint256 indexed streamId,\n    address indexed sender,\n    address indexed recipient,\n    uint256 deposit,\n    address tokenAddress,\n    uint256 startTime,\n    uint256 stopTime\n  );\n\n  event WithdrawFromStream(uint256 indexed streamId, address indexed recipient, uint256 amount);\n\n  event CancelStream(\n    uint256 indexed streamId,\n    address indexed sender,\n    address indexed recipient,\n    uint256 senderBalance,\n    uint256 recipientBalance\n  );\n\n  function balanceOf(uint256 streamId, address who) external view returns (uint256 balance);\n\n  function getStream(\n    uint256 streamId\n  )\n    external\n    view\n    returns (\n      address sender,\n      address recipient,\n      uint256 deposit,\n      address token,\n      uint256 startTime,\n      uint256 stopTime,\n      uint256 remainingBalance,\n      uint256 ratePerSecond\n    );\n\n  function createStream(\n    address recipient,\n    uint256 deposit,\n    address tokenAddress,\n    uint256 startTime,\n    uint256 stopTime\n  ) external returns (uint256 streamId);\n\n  function withdrawFromStream(uint256 streamId, uint256 funds) external returns (bool);\n\n  function cancelStream(uint256 streamId) external returns (bool);\n\n  function initialize(address fundsAdmin) external;\n}\n"
    }
  }
}}