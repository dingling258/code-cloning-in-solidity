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
    "@zerolendxyz/core-v3/contracts/dependencies/openzeppelin/contracts/IERC20.sol": {
      "content": "// SPDX-License-Identifier: AGPL-3.0\npragma solidity ^0.8.0;\n\n/**\n * @dev Interface of the ERC20 standard as defined in the EIP.\n */\ninterface IERC20 {\n  /**\n   * @dev Returns the amount of tokens in existence.\n   */\n  function totalSupply() external view returns (uint256);\n\n  /**\n   * @dev Returns the amount of tokens owned by `account`.\n   */\n  function balanceOf(address account) external view returns (uint256);\n\n  /**\n   * @dev Moves `amount` tokens from the caller's account to `recipient`.\n   *\n   * Returns a boolean value indicating whether the operation succeeded.\n   *\n   * Emits a {Transfer} event.\n   */\n  function transfer(address recipient, uint256 amount) external returns (bool);\n\n  /**\n   * @dev Returns the remaining number of tokens that `spender` will be\n   * allowed to spend on behalf of `owner` through {transferFrom}. This is\n   * zero by default.\n   *\n   * This value changes when {approve} or {transferFrom} are called.\n   */\n  function allowance(address owner, address spender) external view returns (uint256);\n\n  /**\n   * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.\n   *\n   * Returns a boolean value indicating whether the operation succeeded.\n   *\n   * IMPORTANT: Beware that changing an allowance with this method brings the risk\n   * that someone may use both the old and the new allowance by unfortunate\n   * transaction ordering. One possible solution to mitigate this race\n   * condition is to first reduce the spender's allowance to 0 and set the\n   * desired value afterwards:\n   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\n   *\n   * Emits an {Approval} event.\n   */\n  function approve(address spender, uint256 amount) external returns (bool);\n\n  /**\n   * @dev Moves `amount` tokens from `sender` to `recipient` using the\n   * allowance mechanism. `amount` is then deducted from the caller's\n   * allowance.\n   *\n   * Returns a boolean value indicating whether the operation succeeded.\n   *\n   * Emits a {Transfer} event.\n   */\n  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);\n\n  /**\n   * @dev Emitted when `value` tokens are moved from one account (`from`) to\n   * another (`to`).\n   *\n   * Note that `value` may be zero.\n   */\n  event Transfer(address indexed from, address indexed to, uint256 value);\n\n  /**\n   * @dev Emitted when the allowance of a `spender` for an `owner` is set by\n   * a call to {approve}. `value` is the new allowance.\n   */\n  event Approval(address indexed owner, address indexed spender, uint256 value);\n}\n"
    },
    "@zerolendxyz/periphery-v3/contracts/treasury/AaveEcosystemReserveV2.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\npragma solidity ^0.8.12;\n\nimport {IERC20} from '@zerolendxyz/core-v3/contracts/dependencies/openzeppelin/contracts/IERC20.sol';\nimport {IStreamable} from './interfaces/IStreamable.sol';\nimport {AdminControlledEcosystemReserve} from './AdminControlledEcosystemReserve.sol';\nimport {ReentrancyGuard} from './libs/ReentrancyGuard.sol';\nimport {SafeERC20} from './libs/SafeERC20.sol';\n\n/**\n * @title AaveEcosystemReserve v2\n * @notice Stores ERC20 tokens of an ecosystem reserve, adding streaming capabilities.\n * Modification of Sablier https://github.com/sablierhq/sablier/blob/develop/packages/protocol/contracts/Sablier.sol\n * Original can be found also deployed on https://etherscan.io/address/0xCD18eAa163733Da39c232722cBC4E8940b1D8888\n * Modifications:\n * - Sablier \"pulls\" the funds from the creator of the stream at creation. In the Aave case, we already have the funds.\n * - Anybody can create streams on Sablier. Here, only the funds admin (Aave governance via controller) can\n * - Adapted codebase to Solidity 0.8.11, mainly removing SafeMath and CarefulMath to use native safe math\n * - Same as with creation, on Sablier the `sender` and `recipient` can cancel a stream. Here, only fund admin and recipient\n * @author BGD Labs\n **/\ncontract AaveEcosystemReserveV2 is AdminControlledEcosystemReserve, ReentrancyGuard, IStreamable {\n  using SafeERC20 for IERC20;\n\n  /*** Storage Properties ***/\n\n  /**\n   * @notice Counter for new stream ids.\n   */\n  uint256 private _nextStreamId;\n\n  /**\n   * @notice The stream objects identifiable by their unsigned integer ids.\n   */\n  mapping(uint256 => Stream) private _streams;\n\n  /*** Modifiers ***/\n\n  /**\n   * @dev Throws if the caller is not the funds admin of the recipient of the stream.\n   */\n  modifier onlyAdminOrRecipient(uint256 streamId) {\n    require(\n      msg.sender == _fundsAdmin || msg.sender == _streams[streamId].recipient,\n      'caller is not the funds admin or the recipient of the stream'\n    );\n    _;\n  }\n\n  /**\n   * @dev Throws if the provided id does not point to a valid stream.\n   */\n  modifier streamExists(uint256 streamId) {\n    require(_streams[streamId].isEntity, 'stream does not exist');\n    _;\n  }\n\n  /*** Contract Logic Starts Here */\n\n  function initialize(address fundsAdmin) external initializer {\n    _nextStreamId = 100000;\n    _setFundsAdmin(fundsAdmin);\n  }\n\n  /*** View Functions ***/\n\n  /**\n   * @notice Returns the next available stream id\n   * @notice Returns the stream id.\n   */\n  function getNextStreamId() external view returns (uint256) {\n    return _nextStreamId;\n  }\n\n  /**\n   * @notice Returns the stream with all its properties.\n   * @dev Throws if the id does not point to a valid stream.\n   * @param streamId The id of the stream to query.\n   * @notice Returns the stream object.\n   */\n  function getStream(\n    uint256 streamId\n  )\n    external\n    view\n    streamExists(streamId)\n    returns (\n      address sender,\n      address recipient,\n      uint256 deposit,\n      address tokenAddress,\n      uint256 startTime,\n      uint256 stopTime,\n      uint256 remainingBalance,\n      uint256 ratePerSecond\n    )\n  {\n    sender = _streams[streamId].sender;\n    recipient = _streams[streamId].recipient;\n    deposit = _streams[streamId].deposit;\n    tokenAddress = _streams[streamId].tokenAddress;\n    startTime = _streams[streamId].startTime;\n    stopTime = _streams[streamId].stopTime;\n    remainingBalance = _streams[streamId].remainingBalance;\n    ratePerSecond = _streams[streamId].ratePerSecond;\n  }\n\n  /**\n   * @notice Returns either the delta in seconds between `block.timestamp` and `startTime` or\n   *  between `stopTime` and `startTime, whichever is smaller. If `block.timestamp` is before\n   *  `startTime`, it returns 0.\n   * @dev Throws if the id does not point to a valid stream.\n   * @param streamId The id of the stream for which to query the delta.\n   * @notice Returns the time delta in seconds.\n   */\n  function deltaOf(uint256 streamId) public view streamExists(streamId) returns (uint256 delta) {\n    Stream memory stream = _streams[streamId];\n    if (block.timestamp <= stream.startTime) return 0;\n    if (block.timestamp < stream.stopTime) return block.timestamp - stream.startTime;\n    return stream.stopTime - stream.startTime;\n  }\n\n  struct BalanceOfLocalVars {\n    uint256 recipientBalance;\n    uint256 withdrawalAmount;\n    uint256 senderBalance;\n  }\n\n  /**\n   * @notice Returns the available funds for the given stream id and address.\n   * @dev Throws if the id does not point to a valid stream.\n   * @param streamId The id of the stream for which to query the balance.\n   * @param who The address for which to query the balance.\n   * @notice Returns the total funds allocated to `who` as uint256.\n   */\n  function balanceOf(\n    uint256 streamId,\n    address who\n  ) public view streamExists(streamId) returns (uint256 balance) {\n    Stream memory stream = _streams[streamId];\n    BalanceOfLocalVars memory vars;\n\n    uint256 delta = deltaOf(streamId);\n    vars.recipientBalance = delta * stream.ratePerSecond;\n\n    /*\n     * If the stream `balance` does not equal `deposit`, it means there have been withdrawals.\n     * We have to subtract the total amount withdrawn from the amount of money that has been\n     * streamed until now.\n     */\n    if (stream.deposit > stream.remainingBalance) {\n      vars.withdrawalAmount = stream.deposit - stream.remainingBalance;\n      vars.recipientBalance = vars.recipientBalance - vars.withdrawalAmount;\n    }\n\n    if (who == stream.recipient) return vars.recipientBalance;\n    if (who == stream.sender) {\n      vars.senderBalance = stream.remainingBalance - vars.recipientBalance;\n      return vars.senderBalance;\n    }\n    return 0;\n  }\n\n  /*** Public Effects & Interactions Functions ***/\n\n  struct CreateStreamLocalVars {\n    uint256 duration;\n    uint256 ratePerSecond;\n  }\n\n  /**\n   * @notice Creates a new stream funded by this contracts itself and paid towards `recipient`.\n   * @dev Throws if the recipient is the zero address, the contract itself or the caller.\n   *  Throws if the deposit is 0.\n   *  Throws if the start time is before `block.timestamp`.\n   *  Throws if the stop time is before the start time.\n   *  Throws if the duration calculation has a math error.\n   *  Throws if the deposit is smaller than the duration.\n   *  Throws if the deposit is not a multiple of the duration.\n   *  Throws if the rate calculation has a math error.\n   *  Throws if the next stream id calculation has a math error.\n   *  Throws if the contract is not allowed to transfer enough tokens.\n   *  Throws if there is a token transfer failure.\n   * @param recipient The address towards which the money is streamed.\n   * @param deposit The amount of money to be streamed.\n   * @param tokenAddress The ERC20 token to use as streaming currency.\n   * @param startTime The unix timestamp for when the stream starts.\n   * @param stopTime The unix timestamp for when the stream stops.\n   * @notice Returns the uint256 id of the newly created stream.\n   */\n  function createStream(\n    address recipient,\n    uint256 deposit,\n    address tokenAddress,\n    uint256 startTime,\n    uint256 stopTime\n  ) external onlyFundsAdmin returns (uint256) {\n    require(recipient != address(0), 'stream to the zero address');\n    require(recipient != address(this), 'stream to the contract itself');\n    require(recipient != msg.sender, 'stream to the caller');\n    require(deposit > 0, 'deposit is zero');\n    require(startTime >= block.timestamp, 'start time before block.timestamp');\n    require(stopTime > startTime, 'stop time before the start time');\n\n    CreateStreamLocalVars memory vars;\n    vars.duration = stopTime - startTime;\n\n    /* Without this, the rate per second would be zero. */\n    require(deposit >= vars.duration, 'deposit smaller than time delta');\n\n    /* This condition avoids dealing with remainders */\n    require(deposit % vars.duration == 0, 'deposit not multiple of time delta');\n\n    vars.ratePerSecond = deposit / vars.duration;\n\n    /* Create and store the stream object. */\n    uint256 streamId = _nextStreamId;\n    _streams[streamId] = Stream({\n      remainingBalance: deposit,\n      deposit: deposit,\n      isEntity: true,\n      ratePerSecond: vars.ratePerSecond,\n      recipient: recipient,\n      sender: address(this),\n      startTime: startTime,\n      stopTime: stopTime,\n      tokenAddress: tokenAddress\n    });\n\n    /* Increment the next stream id. */\n    _nextStreamId++;\n\n    emit CreateStream(\n      streamId,\n      address(this),\n      recipient,\n      deposit,\n      tokenAddress,\n      startTime,\n      stopTime\n    );\n    return streamId;\n  }\n\n  /**\n   * @notice Withdraws from the contract to the recipient's account.\n   * @dev Throws if the id does not point to a valid stream.\n   *  Throws if the caller is not the funds admin or the recipient of the stream.\n   *  Throws if the amount exceeds the available balance.\n   *  Throws if there is a token transfer failure.\n   * @param streamId The id of the stream to withdraw tokens from.\n   * @param amount The amount of tokens to withdraw.\n   */\n  function withdrawFromStream(\n    uint256 streamId,\n    uint256 amount\n  ) external nonReentrant streamExists(streamId) onlyAdminOrRecipient(streamId) returns (bool) {\n    require(amount > 0, 'amount is zero');\n    Stream memory stream = _streams[streamId];\n\n    uint256 balance = balanceOf(streamId, stream.recipient);\n    require(balance >= amount, 'amount exceeds the available balance');\n\n    _streams[streamId].remainingBalance = stream.remainingBalance - amount;\n\n    if (_streams[streamId].remainingBalance == 0) delete _streams[streamId];\n\n    IERC20(stream.tokenAddress).safeTransfer(stream.recipient, amount);\n    emit WithdrawFromStream(streamId, stream.recipient, amount);\n    return true;\n  }\n\n  /**\n   * @notice Cancels the stream and transfers the tokens back on a pro rata basis.\n   * @dev Throws if the id does not point to a valid stream.\n   *  Throws if the caller is not the funds admin or the recipient of the stream.\n   *  Throws if there is a token transfer failure.\n   * @param streamId The id of the stream to cancel.\n   * @notice Returns bool true=success, otherwise false.\n   */\n  function cancelStream(\n    uint256 streamId\n  ) external nonReentrant streamExists(streamId) onlyAdminOrRecipient(streamId) returns (bool) {\n    Stream memory stream = _streams[streamId];\n    uint256 senderBalance = balanceOf(streamId, stream.sender);\n    uint256 recipientBalance = balanceOf(streamId, stream.recipient);\n\n    delete _streams[streamId];\n\n    IERC20 token = IERC20(stream.tokenAddress);\n    if (recipientBalance > 0) token.safeTransfer(stream.recipient, recipientBalance);\n\n    emit CancelStream(streamId, stream.sender, stream.recipient, senderBalance, recipientBalance);\n    return true;\n  }\n}\n"
    },
    "@zerolendxyz/periphery-v3/contracts/treasury/AdminControlledEcosystemReserve.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\npragma solidity ^0.8.12;\n\nimport {IERC20} from '@zerolendxyz/core-v3/contracts/dependencies/openzeppelin/contracts/IERC20.sol';\nimport {IAdminControlledEcosystemReserve} from './interfaces/IAdminControlledEcosystemReserve.sol';\nimport {VersionedInitializable} from './libs/VersionedInitializable.sol';\nimport {SafeERC20} from './libs/SafeERC20.sol';\nimport {ReentrancyGuard} from './libs/ReentrancyGuard.sol';\nimport {Address} from './libs/Address.sol';\n\n/**\n * @title AdminControlledEcosystemReserve\n * @notice Stores ERC20 tokens, and allows to dispose of them via approval or transfer dynamics\n * Adapted to be an implementation of a transparent proxy\n * @dev Done abstract to add an `initialize()` function on the child, with `initializer` modifier\n * @author BGD Labs\n **/\nabstract contract AdminControlledEcosystemReserve is\n  VersionedInitializable,\n  IAdminControlledEcosystemReserve\n{\n  using SafeERC20 for IERC20;\n  using Address for address payable;\n\n  address internal _fundsAdmin;\n\n  uint256 public constant REVISION = 1;\n\n  /// @inheritdoc IAdminControlledEcosystemReserve\n  address public constant ETH_MOCK_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;\n\n  modifier onlyFundsAdmin() {\n    require(msg.sender == _fundsAdmin, 'ONLY_BY_FUNDS_ADMIN');\n    _;\n  }\n\n  function getRevision() internal pure override returns (uint256) {\n    return REVISION;\n  }\n\n  /// @inheritdoc IAdminControlledEcosystemReserve\n  function getFundsAdmin() external view returns (address) {\n    return _fundsAdmin;\n  }\n\n  /// @inheritdoc IAdminControlledEcosystemReserve\n  function approve(IERC20 token, address recipient, uint256 amount) external onlyFundsAdmin {\n    token.safeApprove(recipient, amount);\n  }\n\n  /// @inheritdoc IAdminControlledEcosystemReserve\n  function transfer(IERC20 token, address recipient, uint256 amount) external onlyFundsAdmin {\n    require(recipient != address(0), 'INVALID_0X_RECIPIENT');\n\n    if (address(token) == ETH_MOCK_ADDRESS) {\n      payable(recipient).sendValue(amount);\n    } else {\n      token.safeTransfer(recipient, amount);\n    }\n  }\n\n  /// @dev needed in order to receive ETH from the Aave v1 ecosystem reserve\n  receive() external payable {}\n\n  function _setFundsAdmin(address admin) internal {\n    _fundsAdmin = admin;\n    emit NewFundsAdmin(admin);\n  }\n}\n"
    },
    "@zerolendxyz/periphery-v3/contracts/treasury/interfaces/IAdminControlledEcosystemReserve.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0\npragma solidity ^0.8.12;\n\nimport {IERC20} from '@zerolendxyz/core-v3/contracts/dependencies/openzeppelin/contracts/IERC20.sol';\n\ninterface IAdminControlledEcosystemReserve {\n  /** @notice Emitted when the funds admin changes\n   * @param fundsAdmin The new funds admin\n   **/\n  event NewFundsAdmin(address indexed fundsAdmin);\n\n  /** @notice Returns the mock ETH reference address\n   * @return address The address\n   **/\n  function ETH_MOCK_ADDRESS() external pure returns (address);\n\n  /**\n   * @notice Return the funds admin, only entity to be able to interact with this contract (controller of reserve)\n   * @return address The address of the funds admin\n   **/\n  function getFundsAdmin() external view returns (address);\n\n  /**\n   * @dev Function for the funds admin to give ERC20 allowance to other parties\n   * @param token The address of the token to give allowance from\n   * @param recipient Allowance's recipient\n   * @param amount Allowance to approve\n   **/\n  function approve(IERC20 token, address recipient, uint256 amount) external;\n\n  /**\n   * @notice Function for the funds admin to transfer ERC20 tokens to other parties\n   * @param token The address of the token to transfer\n   * @param recipient Transfer's recipient\n   * @param amount Amount to transfer\n   **/\n  function transfer(IERC20 token, address recipient, uint256 amount) external;\n}\n"
    },
    "@zerolendxyz/periphery-v3/contracts/treasury/interfaces/IStreamable.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.12;\n\ninterface IStreamable {\n  struct Stream {\n    uint256 deposit;\n    uint256 ratePerSecond;\n    uint256 remainingBalance;\n    uint256 startTime;\n    uint256 stopTime;\n    address recipient;\n    address sender;\n    address tokenAddress;\n    bool isEntity;\n  }\n\n  event CreateStream(\n    uint256 indexed streamId,\n    address indexed sender,\n    address indexed recipient,\n    uint256 deposit,\n    address tokenAddress,\n    uint256 startTime,\n    uint256 stopTime\n  );\n\n  event WithdrawFromStream(uint256 indexed streamId, address indexed recipient, uint256 amount);\n\n  event CancelStream(\n    uint256 indexed streamId,\n    address indexed sender,\n    address indexed recipient,\n    uint256 senderBalance,\n    uint256 recipientBalance\n  );\n\n  function balanceOf(uint256 streamId, address who) external view returns (uint256 balance);\n\n  function getStream(\n    uint256 streamId\n  )\n    external\n    view\n    returns (\n      address sender,\n      address recipient,\n      uint256 deposit,\n      address token,\n      uint256 startTime,\n      uint256 stopTime,\n      uint256 remainingBalance,\n      uint256 ratePerSecond\n    );\n\n  function createStream(\n    address recipient,\n    uint256 deposit,\n    address tokenAddress,\n    uint256 startTime,\n    uint256 stopTime\n  ) external returns (uint256 streamId);\n\n  function withdrawFromStream(uint256 streamId, uint256 funds) external returns (bool);\n\n  function cancelStream(uint256 streamId) external returns (bool);\n\n  function initialize(address fundsAdmin) external;\n}\n"
    },
    "@zerolendxyz/periphery-v3/contracts/treasury/libs/Address.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)\n\npragma solidity ^0.8.1;\n\n/**\n * @dev Collection of functions related to the address type\n */\nlibrary Address {\n  /**\n   * @dev Returns true if `account` is a contract.\n   *\n   * [IMPORTANT]\n   * ====\n   * It is unsafe to assume that an address for which this function returns\n   * false is an externally-owned account (EOA) and not a contract.\n   *\n   * Among others, `isContract` will return false for the following\n   * types of addresses:\n   *\n   *  - an externally-owned account\n   *  - a contract in construction\n   *  - an address where a contract will be created\n   *  - an address where a contract lived, but was destroyed\n   * ====\n   *\n   * [IMPORTANT]\n   * ====\n   * You shouldn't rely on `isContract` to protect against flash loan attacks!\n   *\n   * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets\n   * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract\n   * constructor.\n   * ====\n   */\n  function isContract(address account) internal view returns (bool) {\n    // This method relies on extcodesize/address.code.length, which returns 0\n    // for contracts in construction, since the code is only stored at the end\n    // of the constructor execution.\n\n    return account.code.length > 0;\n  }\n\n  /**\n   * @dev Replacement for Solidity's `transfer`: sends `amount` wei to\n   * `recipient`, forwarding all available gas and reverting on errors.\n   *\n   * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost\n   * of certain opcodes, possibly making contracts go over the 2300 gas limit\n   * imposed by `transfer`, making them unable to receive funds via\n   * `transfer`. {sendValue} removes this limitation.\n   *\n   * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].\n   *\n   * IMPORTANT: because control is transferred to `recipient`, care must be\n   * taken to not create reentrancy vulnerabilities. Consider using\n   * {ReentrancyGuard} or the\n   * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].\n   */\n  function sendValue(address payable recipient, uint256 amount) internal {\n    require(address(this).balance >= amount, 'Address: insufficient balance');\n\n    (bool success, ) = recipient.call{value: amount}('');\n    require(success, 'Address: unable to send value, recipient may have reverted');\n  }\n\n  /**\n   * @dev Performs a Solidity function call using a low level `call`. A\n   * plain `call` is an unsafe replacement for a function call: use this\n   * function instead.\n   *\n   * If `target` reverts with a revert reason, it is bubbled up by this\n   * function (like regular Solidity function calls).\n   *\n   * Returns the raw returned data. To convert to the expected return value,\n   * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].\n   *\n   * Requirements:\n   *\n   * - `target` must be a contract.\n   * - calling `target` with `data` must not revert.\n   *\n   * _Available since v3.1._\n   */\n  function functionCall(address target, bytes memory data) internal returns (bytes memory) {\n    return functionCall(target, data, 'Address: low-level call failed');\n  }\n\n  /**\n   * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with\n   * `errorMessage` as a fallback revert reason when `target` reverts.\n   *\n   * _Available since v3.1._\n   */\n  function functionCall(\n    address target,\n    bytes memory data,\n    string memory errorMessage\n  ) internal returns (bytes memory) {\n    return functionCallWithValue(target, data, 0, errorMessage);\n  }\n\n  /**\n   * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\n   * but also transferring `value` wei to `target`.\n   *\n   * Requirements:\n   *\n   * - the calling contract must have an ETH balance of at least `value`.\n   * - the called Solidity function must be `payable`.\n   *\n   * _Available since v3.1._\n   */\n  function functionCallWithValue(\n    address target,\n    bytes memory data,\n    uint256 value\n  ) internal returns (bytes memory) {\n    return functionCallWithValue(target, data, value, 'Address: low-level call with value failed');\n  }\n\n  /**\n   * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but\n   * with `errorMessage` as a fallback revert reason when `target` reverts.\n   *\n   * _Available since v3.1._\n   */\n  function functionCallWithValue(\n    address target,\n    bytes memory data,\n    uint256 value,\n    string memory errorMessage\n  ) internal returns (bytes memory) {\n    require(address(this).balance >= value, 'Address: insufficient balance for call');\n    require(isContract(target), 'Address: call to non-contract');\n\n    (bool success, bytes memory returndata) = target.call{value: value}(data);\n    return verifyCallResult(success, returndata, errorMessage);\n  }\n\n  /**\n   * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\n   * but performing a static call.\n   *\n   * _Available since v3.3._\n   */\n  function functionStaticCall(address target, bytes memory data)\n    internal\n    view\n    returns (bytes memory)\n  {\n    return functionStaticCall(target, data, 'Address: low-level static call failed');\n  }\n\n  /**\n   * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],\n   * but performing a static call.\n   *\n   * _Available since v3.3._\n   */\n  function functionStaticCall(\n    address target,\n    bytes memory data,\n    string memory errorMessage\n  ) internal view returns (bytes memory) {\n    require(isContract(target), 'Address: static call to non-contract');\n\n    (bool success, bytes memory returndata) = target.staticcall(data);\n    return verifyCallResult(success, returndata, errorMessage);\n  }\n\n  /**\n   * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\n   * but performing a delegate call.\n   *\n   * _Available since v3.4._\n   */\n  function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {\n    return functionDelegateCall(target, data, 'Address: low-level delegate call failed');\n  }\n\n  /**\n   * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],\n   * but performing a delegate call.\n   *\n   * _Available since v3.4._\n   */\n  function functionDelegateCall(\n    address target,\n    bytes memory data,\n    string memory errorMessage\n  ) internal returns (bytes memory) {\n    require(isContract(target), 'Address: delegate call to non-contract');\n\n    (bool success, bytes memory returndata) = target.delegatecall(data);\n    return verifyCallResult(success, returndata, errorMessage);\n  }\n\n  /**\n   * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the\n   * revert reason using the provided one.\n   *\n   * _Available since v4.3._\n   */\n  function verifyCallResult(\n    bool success,\n    bytes memory returndata,\n    string memory errorMessage\n  ) internal pure returns (bytes memory) {\n    if (success) {\n      return returndata;\n    } else {\n      // Look for revert reason and bubble it up if present\n      if (returndata.length > 0) {\n        // The easiest way to bubble the revert reason is using memory via assembly\n\n        assembly {\n          let returndata_size := mload(returndata)\n          revert(add(32, returndata), returndata_size)\n        }\n      } else {\n        revert(errorMessage);\n      }\n    }\n  }\n}\n"
    },
    "@zerolendxyz/periphery-v3/contracts/treasury/libs/ReentrancyGuard.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Contract module that helps prevent reentrant calls to a function.\n *\n * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier\n * available, which can be applied to functions to make sure there are no nested\n * (reentrant) calls to them.\n *\n * Note that because there is a single `nonReentrant` guard, functions marked as\n * `nonReentrant` may not call one another. This can be worked around by making\n * those functions `private`, and then adding `external` `nonReentrant` entry\n * points to them.\n *\n * TIP: If you would like to learn more about reentrancy and alternative ways\n * to protect against it, check out our blog post\n * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].\n */\nabstract contract ReentrancyGuard {\n  // Booleans are more expensive than uint256 or any type that takes up a full\n  // word because each write operation emits an extra SLOAD to first read the\n  // slot's contents, replace the bits taken up by the boolean, and then write\n  // back. This is the compiler's defense against contract upgrades and\n  // pointer aliasing, and it cannot be disabled.\n\n  // The values being non-zero value makes deployment a bit more expensive,\n  // but in exchange the refund on every call to nonReentrant will be lower in\n  // amount. Since refunds are capped to a percentage of the total\n  // transaction's gas, it is best to keep them low in cases like this one, to\n  // increase the likelihood of the full refund coming into effect.\n  uint256 private constant _NOT_ENTERED = 1;\n  uint256 private constant _ENTERED = 2;\n\n  uint256 private _status;\n\n  constructor() {\n    _status = _NOT_ENTERED;\n  }\n\n  /**\n   * @dev Prevents a contract from calling itself, directly or indirectly.\n   * Calling a `nonReentrant` function from another `nonReentrant`\n   * function is not supported. It is possible to prevent this from happening\n   * by making the `nonReentrant` function external, and making it call a\n   * `private` function that does the actual work.\n   */\n  modifier nonReentrant() {\n    // On the first call to nonReentrant, _notEntered will be true\n    require(_status != _ENTERED, 'ReentrancyGuard: reentrant call');\n\n    // Any calls to nonReentrant after this point will fail\n    _status = _ENTERED;\n\n    _;\n\n    // By storing the original value once again, a refund is triggered (see\n    // https://eips.ethereum.org/EIPS/eip-2200)\n    _status = _NOT_ENTERED;\n  }\n}\n"
    },
    "@zerolendxyz/periphery-v3/contracts/treasury/libs/SafeERC20.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)\n\npragma solidity ^0.8.0;\n\nimport {IERC20} from '@zerolendxyz/core-v3/contracts/dependencies/openzeppelin/contracts/IERC20.sol';\nimport {Address} from './Address.sol';\n\n/**\n * @title SafeERC20\n * @dev Wrappers around ERC20 operations that throw on failure (when the token\n * contract returns false). Tokens that return no value (and instead revert or\n * throw on failure) are also supported, non-reverting calls are assumed to be\n * successful.\n * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,\n * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.\n */\nlibrary SafeERC20 {\n  using Address for address;\n\n  function safeTransfer(IERC20 token, address to, uint256 value) internal {\n    _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));\n  }\n\n  function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {\n    _callOptionalReturn(\n      token,\n      abi.encodeWithSelector(token.transferFrom.selector, from, to, value)\n    );\n  }\n\n  /**\n   * @dev Deprecated. This function has issues similar to the ones found in\n   * {IERC20-approve}, and its usage is discouraged.\n   *\n   * Whenever possible, use {safeIncreaseAllowance} and\n   * {safeDecreaseAllowance} instead.\n   */\n  function safeApprove(IERC20 token, address spender, uint256 value) internal {\n    // safeApprove should only be called when setting an initial allowance,\n    // or when resetting it to zero. To increase and decrease it, use\n    // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'\n    require(\n      (value == 0) || (token.allowance(address(this), spender) == 0),\n      'SafeERC20: approve from non-zero to non-zero allowance'\n    );\n    _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));\n  }\n\n  function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {\n    uint256 newAllowance = token.allowance(address(this), spender) + value;\n    _callOptionalReturn(\n      token,\n      abi.encodeWithSelector(token.approve.selector, spender, newAllowance)\n    );\n  }\n\n  function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {\n    unchecked {\n      uint256 oldAllowance = token.allowance(address(this), spender);\n      require(oldAllowance >= value, 'SafeERC20: decreased allowance below zero');\n      uint256 newAllowance = oldAllowance - value;\n      _callOptionalReturn(\n        token,\n        abi.encodeWithSelector(token.approve.selector, spender, newAllowance)\n      );\n    }\n  }\n\n  /**\n   * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement\n   * on the return value: the return value is optional (but if data is returned, it must not be false).\n   * @param token The token targeted by the call.\n   * @param data The call data (encoded using abi.encode or one of its variants).\n   */\n  function _callOptionalReturn(IERC20 token, bytes memory data) private {\n    // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since\n    // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that\n    // the target address contains contract code and also asserts for success in the low-level call.\n\n    bytes memory returndata = address(token).functionCall(data, 'SafeERC20: low-level call failed');\n    if (returndata.length > 0) {\n      // Return data is optional\n      require(abi.decode(returndata, (bool)), 'SafeERC20: ERC20 operation did not succeed');\n    }\n  }\n}\n"
    },
    "@zerolendxyz/periphery-v3/contracts/treasury/libs/VersionedInitializable.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.12;\n\n/**\n * @title VersionedInitializable\n *\n * @dev Helper contract to support initializer functions. To use it, replace\n * the constructor with a function that has the `initializer` modifier.\n * WARNING: Unlike constructors, initializer functions must be manually\n * invoked. This applies both to deploying an Initializable contract, as well\n * as extending an Initializable contract via inheritance.\n * WARNING: When used with inheritance, manual care must be taken to not invoke\n * a parent initializer twice, or ensure that all initializers are idempotent,\n * because this is not dealt with automatically as with constructors.\n *\n * @author Aave, inspired by the OpenZeppelin Initializable contract\n */\nabstract contract VersionedInitializable {\n  /**\n   * @dev Indicates that the contract has been initialized.\n   */\n  uint256 internal lastInitializedRevision = 0;\n\n  /**\n   * @dev Modifier to use in the initializer function of a contract.\n   */\n  modifier initializer() {\n    uint256 revision = getRevision();\n    require(revision > lastInitializedRevision, 'Contract instance has already been initialized');\n\n    lastInitializedRevision = revision;\n\n    _;\n  }\n\n  /// @dev returns the revision number of the contract.\n  /// Needs to be defined in the inherited class as a constant.\n  function getRevision() internal pure virtual returns (uint256);\n\n  // Reserved storage space to allow for layout changes in the future.\n  uint256[50] private ______gap;\n}\n"
    }
  }
}}