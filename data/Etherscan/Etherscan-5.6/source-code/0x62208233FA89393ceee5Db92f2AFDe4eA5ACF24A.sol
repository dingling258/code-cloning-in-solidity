{"Address.sol":{"content":"// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)\n\npragma solidity ^0.8.12;\n\n/**\n * @dev Collection of functions related to the address type\n */\nlibrary Address {\n    /**\n     * @dev Returns true if `account` is a contract.\n     *\n     * [IMPORTANT]\n     * ====\n     * It is unsafe to assume that an address for which this function returns\n     * false is an externally-owned account (EOA) and not a contract.\n     *\n     * Among others, `isContract` will return false for the following\n     * types of addresses:\n     *\n     *  - an externally-owned account\n     *  - a contract in construction\n     *  - an address where a contract will be created\n     *  - an address where a contract lived, but was destroyed\n     * ====\n     *\n     * [IMPORTANT]\n     * ====\n     * You shouldn\u0027t rely on `isContract` to protect against flash loan attacks!\n     *\n     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets\n     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract\n     * constructor.\n     * ====\n     */\n    function isContract(address account) internal view returns (bool) {\n        // This method relies on extcodesize/address.code.length, which returns 0\n        // for contracts in construction, since the code is only stored at the end\n        // of the constructor execution.\n\n        return account.code.length \u003e 0;\n    }\n\n    /**\n     * @dev Replacement for Solidity\u0027s `transfer`: sends `amount` wei to\n     * `recipient`, forwarding all available gas and reverting on errors.\n     *\n     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost\n     * of certain opcodes, possibly making contracts go over the 2300 gas limit\n     * imposed by `transfer`, making them unable to receive funds via\n     * `transfer`. {sendValue} removes this limitation.\n     *\n     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].\n     *\n     * IMPORTANT: because control is transferred to `recipient`, care must be\n     * taken to not create reentrancy vulnerabilities. Consider using\n     * {ReentrancyGuard} or the\n     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].\n     */\n    function sendValue(address payable recipient, uint256 amount) internal {\n        require(address(this).balance \u003e= amount, \"Address: insufficient balance\");\n\n        (bool success, ) = recipient.call{value: amount}(\"\");\n        require(success, \"Address: unable to send value, recipient may have reverted\");\n    }\n\n    /**\n     * @dev Performs a Solidity function call using a low level `call`. A\n     * plain `call` is an unsafe replacement for a function call: use this\n     * function instead.\n     *\n     * If `target` reverts with a revert reason, it is bubbled up by this\n     * function (like regular Solidity function calls).\n     *\n     * Returns the raw returned data. To convert to the expected return value,\n     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].\n     *\n     * Requirements:\n     *\n     * - `target` must be a contract.\n     * - calling `target` with `data` must not revert.\n     *\n     * _Available since v3.1._\n     */\n    function functionCall(address target, bytes memory data) internal returns (bytes memory) {\n        return functionCall(target, data, \"Address: low-level call failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with\n     * `errorMessage` as a fallback revert reason when `target` reverts.\n     *\n     * _Available since v3.1._\n     */\n    function functionCall(\n        address target,\n        bytes memory data,\n        string memory errorMessage\n    ) internal returns (bytes memory) {\n        return functionCallWithValue(target, data, 0, errorMessage);\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\n     * but also transferring `value` wei to `target`.\n     *\n     * Requirements:\n     *\n     * - the calling contract must have an ETH balance of at least `value`.\n     * - the called Solidity function must be `payable`.\n     *\n     * _Available since v3.1._\n     */\n    function functionCallWithValue(\n        address target,\n        bytes memory data,\n        uint256 value\n    ) internal returns (bytes memory) {\n        return functionCallWithValue(target, data, value, \"Address: low-level call with value failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but\n     * with `errorMessage` as a fallback revert reason when `target` reverts.\n     *\n     * _Available since v3.1._\n     */\n    function functionCallWithValue(\n        address target,\n        bytes memory data,\n        uint256 value,\n        string memory errorMessage\n    ) internal returns (bytes memory) {\n        require(address(this).balance \u003e= value, \"Address: insufficient balance for call\");\n        require(isContract(target), \"Address: call to non-contract\");\n\n        (bool success, bytes memory returndata) = target.call{value: value}(data);\n        return verifyCallResult(success, returndata, errorMessage);\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\n     * but performing a static call.\n     *\n     * _Available since v3.3._\n     */\n    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {\n        return functionStaticCall(target, data, \"Address: low-level static call failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],\n     * but performing a static call.\n     *\n     * _Available since v3.3._\n     */\n    function functionStaticCall(\n        address target,\n        bytes memory data,\n        string memory errorMessage\n    ) internal view returns (bytes memory) {\n        require(isContract(target), \"Address: static call to non-contract\");\n\n        (bool success, bytes memory returndata) = target.staticcall(data);\n        return verifyCallResult(success, returndata, errorMessage);\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\n     * but performing a delegate call.\n     *\n     * _Available since v3.4._\n     */\n    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {\n        return functionDelegateCall(target, data, \"Address: low-level delegate call failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],\n     * but performing a delegate call.\n     *\n     * _Available since v3.4._\n     */\n    function functionDelegateCall(\n        address target,\n        bytes memory data,\n        string memory errorMessage\n    ) internal returns (bytes memory) {\n        require(isContract(target), \"Address: delegate call to non-contract\");\n\n        (bool success, bytes memory returndata) = target.delegatecall(data);\n        return verifyCallResult(success, returndata, errorMessage);\n    }\n\n    /**\n     * @dev Tool to verifies that a low level call was successful, and revert if it wasn\u0027t, either by bubbling the\n     * revert reason using the provided one.\n     *\n     * _Available since v4.3._\n     */\n    function verifyCallResult(\n        bool success,\n        bytes memory returndata,\n        string memory errorMessage\n    ) internal pure returns (bytes memory) {\n        if (success) {\n            return returndata;\n        } else {\n            // Look for revert reason and bubble it up if present\n            if (returndata.length \u003e 0) {\n                // The easiest way to bubble the revert reason is using memory via assembly\n\n                assembly {\n                    let returndata_size := mload(returndata)\n                    revert(add(32, returndata), returndata_size)\n                }\n            } else {\n                revert(errorMessage);\n            }\n        }\n    }\n}\n"},"Context.sol":{"content":"// SPDX-License-Identifier: GPL-3.0\n\npragma solidity ^0.8.12;\n\n/**\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes calldata) {\n        return msg.data;\n    }\n}\n"},"IERC20.sol":{"content":"// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)\n\npragma solidity ^0.8.12;\n\n/**\n * @dev Interface of the ERC20 standard as defined in the EIP.\n */\ninterface IERC20 {\n    /**\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\n     * another (`to`).\n     *\n     * Note that `value` may be zero.\n     */\n    event Transfer(address indexed from, address indexed to, uint256 value);\n\n    /**\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\n     * a call to {approve}. `value` is the new allowance.\n     */\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n\n    /**\n     * @dev Returns the amount of tokens in existence.\n     */\n    function totalSupply() external view returns (uint256);\n\n    /**\n     * @dev Returns the amount of tokens owned by `account`.\n     */\n    function balanceOf(address account) external view returns (uint256);\n\n    /**\n     * @dev Moves `amount` tokens from the caller\u0027s account to `to`.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transfer(address to, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Returns the remaining number of tokens that `spender` will be\n     * allowed to spend on behalf of `owner` through {transferFrom}. This is\n     * zero by default.\n     *\n     * This value changes when {approve} or {transferFrom} are called.\n     */\n    function allowance(address owner, address spender) external view returns (uint256);\n\n    /**\n     * @dev Sets `amount` as the allowance of `spender` over the caller\u0027s tokens.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\n     * that someone may use both the old and the new allowance by unfortunate\n     * transaction ordering. One possible solution to mitigate this race\n     * condition is to first reduce the spender\u0027s allowance to 0 and set the\n     * desired value afterwards:\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\n     *\n     * Emits an {Approval} event.\n     */\n    function approve(address spender, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Moves `amount` tokens from `from` to `to` using the\n     * allowance mechanism. `amount` is then deducted from the caller\u0027s\n     * allowance.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transferFrom(\n        address from,\n        address to,\n        uint256 amount\n    ) external returns (bool);\n}\n"},"Initializable.sol":{"content":"// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.6.0) (proxy/utils/Initializable.sol)\n\npragma solidity ^0.8.12;\n\nimport \"./Address.sol\";\n\n/**\n * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed\n * behind a proxy. Since proxied contracts do not make use of a constructor, it\u0027s common to move constructor logic to an\n * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer\n * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.\n *\n * The initialization functions use a version number. Once a version number is used, it is consumed and cannot be\n * reused. This mechanism prevents re-execution of each \"step\" but allows the creation of new initialization steps in\n * case an upgrade adds a module that needs to be initialized.\n *\n * For example:\n *\n * [.hljs-theme-light.nopadding]\n * ```\n * contract MyToken is ERC20Upgradeable {\n *     function initialize() initializer public {\n *         __ERC20_init(\"MyToken\", \"MTK\");\n *     }\n * }\n * contract MyTokenV2 is MyToken, ERC20PermitUpgradeable {\n *     function initializeV2() reinitializer(2) public {\n *         __ERC20Permit_init(\"MyToken\");\n *     }\n * }\n * ```\n *\n * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as\n * possible by providing the encoded function call as the `_data` argument to {ERC1967Proxy-constructor}.\n *\n * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure\n * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.\n *\n * [CAUTION]\n * ====\n * Avoid leaving a contract uninitialized.\n *\n * An uninitialized contract can be taken over by an attacker. This applies to both a proxy and its implementation\n * contract, which may impact the proxy. To prevent the implementation contract from being used, you should invoke\n * the {_disableInitializers} function in the constructor to automatically lock it when it is deployed:\n *\n * [.hljs-theme-light.nopadding]\n * ```\n * /// @custom:oz-upgrades-unsafe-allow constructor\n * constructor() {\n *     _disableInitializers();\n * }\n * ```\n * ====\n */\nabstract contract Initializable {\n    /**\n     * @dev Indicates that the contract has been initialized.\n     * @custom:oz-retyped-from bool\n     */\n    uint8 private _initialized;\n\n    /**\n     * @dev Indicates that the contract is in the process of being initialized.\n     */\n    bool private _initializing;\n\n    /**\n     * @dev Triggered when the contract has been initialized or reinitialized.\n     */\n    event Initialized(uint8 version);\n\n    /**\n     * @dev A modifier that defines a protected initializer function that can be invoked at most once. In its scope,\n     * `onlyInitializing` functions can be used to initialize parent contracts. Equivalent to `reinitializer(1)`.\n     */\n    modifier initializer() {\n        bool isTopLevelCall = _setInitializedVersion(1);\n        if (isTopLevelCall) {\n            _initializing = true;\n        }\n        _;\n        if (isTopLevelCall) {\n            _initializing = false;\n            emit Initialized(1);\n        }\n    }\n\n    /**\n     * @dev A modifier that defines a protected reinitializer function that can be invoked at most once, and only if the\n     * contract hasn\u0027t been initialized to a greater version before. In its scope, `onlyInitializing` functions can be\n     * used to initialize parent contracts.\n     *\n     * `initializer` is equivalent to `reinitializer(1)`, so a reinitializer may be used after the original\n     * initialization step. This is essential to configure modules that are added through upgrades and that require\n     * initialization.\n     *\n     * Note that versions can jump in increments greater than 1; this implies that if multiple reinitializers coexist in\n     * a contract, executing them in the right order is up to the developer or operator.\n     */\n    modifier reinitializer(uint8 version) {\n        bool isTopLevelCall = _setInitializedVersion(version);\n        if (isTopLevelCall) {\n            _initializing = true;\n        }\n        _;\n        if (isTopLevelCall) {\n            _initializing = false;\n            emit Initialized(version);\n        }\n    }\n\n    /**\n     * @dev Modifier to protect an initialization function so that it can only be invoked by functions with the\n     * {initializer} and {reinitializer} modifiers, directly or indirectly.\n     */\n    modifier onlyInitializing() {\n        require(_initializing, \"Initializable: contract is not initializing\");\n        _;\n    }\n\n    /**\n     * @dev Locks the contract, preventing any future reinitialization. This cannot be part of an initializer call.\n     * Calling this in the constructor of a contract will prevent that contract from being initialized or reinitialized\n     * to any version. It is recommended to use this to lock implementation contracts that are designed to be called\n     * through proxies.\n     */\n    function _disableInitializers() internal virtual {\n        _setInitializedVersion(type(uint8).max);\n    }\n\n    function _setInitializedVersion(uint8 version) private returns (bool) {\n        // If the contract is initializing we ignore whether _initialized is set in order to support multiple\n        // inheritance patterns, but we only do this in the context of a constructor, and for the lowest level\n        // of initializers, because in other contexts the contract may have been reentered.\n        if (_initializing) {\n            require(\n                version == 1 \u0026\u0026 !Address.isContract(address(this)),\n                \"Initializable: contract is already initialized\"\n            );\n            return false;\n        } else {\n            require(_initialized \u003c version, \"Initializable: contract is already initialized\");\n            _initialized = version;\n            return true;\n        }\n    }\n}\n"},"PaymentSplitterLogic.sol":{"content":"// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.8.0) (finance/PaymentSplitter.sol)\n\npragma solidity ^0.8.12;\n\nimport \"./SafeERC20.sol\";\nimport \"./Address.sol\";\nimport \"./Context.sol\";\nimport \"./Initializable.sol\";\n\n/**\n * @title PaymentSplitter\n * @dev This contract allows to split Ether payments among a group of accounts. The sender does not need to be aware\n * that the Ether will be split in this way, since it is handled transparently by the contract.\n *\n * The split can be in equal parts or in any other arbitrary proportion. The way this is specified is by assigning each\n * account to a number of shares. Of all the Ether that this contract receives, each account will then be able to claim\n * an amount proportional to the percentage of total shares they were assigned. The distribution of shares is set at the\n * time of contract deployment and can\u0027t be updated thereafter.\n *\n * `PaymentSplitter` follows a _pull payment_ model. This means that payments are not automatically forwarded to the\n * accounts but kept in this contract, and the actual transfer is triggered as a separate step by calling the {release}\n * function.\n *\n * NOTE: This contract assumes that ERC20 tokens will behave similarly to native tokens (Ether). Rebasing tokens, and\n * tokens that apply fees during transfers, are likely to not be supported as expected. If in doubt, we encourage you\n * to run tests before sending real value to this contract.\n */\ncontract PaymentSplitterLogic is Context,Initializable {\n    event PayeeAdded(address account, uint256 shares);\n    event PaymentReleased(address to, uint256 amount);\n    event ERC20PaymentReleased(IERC20 indexed token, address to, uint256 amount);\n    event PaymentReceived(address from, uint256 amount);\n    event Deployed(uint16 _serviceType,uint16 _subServiceType,uint16 _majorVersion,uint16 _minorVersion);\n\n    uint256 private _totalShares;\n    uint256 private _totalReleased;\n\n    mapping(address =\u003e uint256) private _shares;\n    mapping(address =\u003e uint256) private _released;\n    address[] private _payees;\n    uint256[] private _payeesShares;\n\n    mapping(IERC20 =\u003e uint256) private _erc20TotalReleased;\n    mapping(IERC20 =\u003e mapping(address =\u003e uint256)) private _erc20Released;\n\n    uint16 internal constant  _serviceType = 1;\n    uint16 internal constant  _subServiceType = 1;\n    uint16 internal constant  _majorVersion = 1;\n    uint16 internal constant  _minorVersion = 1;\n\n    /**\n     * @dev Creates an instance of `PaymentSplitter` where each account in `payees` is assigned the number of shares at\n     * the matching position in the `shares` array.\n     *\n     * All addresses in `payees` must be non-zero. Both arrays must have the same non-zero length, and there must be no\n     * duplicates in `payees`.\n     */\n    function initialize(address[] memory payees, uint256[] memory shares_) public initializer {\n        require(payees.length == shares_.length, \"PaymentSplitter: payees and shares length mismatch\");\n        require(payees.length \u003e 0, \"PaymentSplitter: no payees\");\n\n        for (uint256 i = 0; i \u003c payees.length; i++) {\n            _addPayee(payees[i], shares_[i]);\n        }\n\n        emit Deployed(_serviceType,_subServiceType,_majorVersion,_minorVersion);\n    }\n\n    /**\n     * @dev The Ether received will be logged with {PaymentReceived} events. Note that these events are not fully\n     * reliable: it\u0027s possible for a contract to receive Ether without triggering this function. This only affects the\n     * reliability of the events, and not the actual splitting of Ether.\n     *\n     * To learn more about this see the Solidity documentation for\n     * https://solidity.readthedocs.io/en/latest/contracts.html#fallback-function[fallback\n     * functions].\n     */\n    receive() external payable virtual {\n        emit PaymentReceived(_msgSender(), msg.value);\n    }\n\n    /**\n     * @dev Getter for the total shares held by payees.\n     */\n    function totalShares() public view returns (uint256) {\n        return _totalShares;\n    }\n\n    /**\n     * @dev Getter for the total amount of Ether already released.\n     */\n    function totalReleased() public view returns (uint256) {\n        return _totalReleased;\n    }\n\n    /**\n     * @dev Getter for the total amount of `token` already released. `token` should be the address of an IERC20\n     * contract.\n     */\n    function totalReleased(IERC20 token) public view returns (uint256) {\n        return _erc20TotalReleased[token];\n    }\n\n    /**\n     * @dev Getter for the amount of shares held by an account.\n     */\n    function shares(address account) public view returns (uint256) {\n        return _shares[account];\n    }\n\n    /**\n     * @dev Getter for the amount of Ether already released to a payee.\n     */\n    function released(address account) public view returns (uint256) {\n        return _released[account];\n    }\n\n    /**\n     * @dev Getter for the amount of `token` tokens already released to a payee. `token` should be the address of an\n     * IERC20 contract.\n     */\n    function released(IERC20 token, address account) public view returns (uint256) {\n        return _erc20Released[token][account];\n    }\n\n    /**\n     * @dev Getter for the address of the payee number `index`.\n     */\n    function payee(uint256 index) public view returns (address) {\n        return _payees[index];\n    }\n\n    /**\n    * @dev Getter for information of all payees\n    */\n    function payeesInfo() public view returns (uint256,address[] memory,uint256[] memory) {\n        return (_totalShares,_payees,_payeesShares);\n    }\n\n    /**\n     * @dev Getter for the amount of payee\u0027s releasable Ether.\n     */\n    function balance(address account) public view returns (uint256) {\n        uint256 totalReceived = address(this).balance + totalReleased();\n        return _pendingPayment(account, totalReceived, released(account));\n    }\n\n    /**\n     * @dev Getter for the amount of payee\u0027s releasable `token` tokens. `token` should be the address of an\n     * IERC20 contract.\n     */\n    function balance(IERC20 token, address account) public view returns (uint256) {\n        uint256 totalReceived = token.balanceOf(address(this)) + totalReleased(token);\n        return _pendingPayment(account, totalReceived, released(token, account));\n    }\n\n    /**\n     * @dev Triggers a transfer to `account` of the amount of Ether they are owed, according to their percentage of the\n     * total shares and their previous withdrawals.\n     */\n    function release(address payable account) public virtual {\n        require(_shares[account] \u003e 0, \"PaymentSplitter: account has no shares\");\n\n        uint256 payment = balance(account);\n\n        require(payment != 0, \"PaymentSplitter: account is not due payment\");\n\n        // _totalReleased is the sum of all values in _released.\n        // If \"_totalReleased += payment\" does not overflow, then \"_released[account] += payment\" cannot overflow.\n        _totalReleased += payment;\n        unchecked {\n            _released[account] += payment;\n        }\n\n        Address.sendValue(account, payment);\n        emit PaymentReleased(account, payment);\n    }\n\n    /**\n     * @dev Triggers a transfer to `account` of the amount of `token` tokens they are owed, according to their\n     * percentage of the total shares and their previous withdrawals. `token` must be the address of an IERC20\n     * contract.\n     */\n    function release(IERC20 token, address account) public virtual {\n        require(_shares[account] \u003e 0, \"PaymentSplitter: account has no shares\");\n\n        uint256 payment = balance(token, account);\n\n        require(payment != 0, \"PaymentSplitter: account is not due payment\");\n\n        // _erc20TotalReleased[token] is the sum of all values in _erc20Released[token].\n        // If \"_erc20TotalReleased[token] += payment\" does not overflow, then \"_erc20Released[token][account] += payment\"\n        // cannot overflow.\n        _erc20TotalReleased[token] += payment;\n        unchecked {\n            _erc20Released[token][account] += payment;\n        }\n\n        SafeERC20.safeTransfer(token, account, payment);\n        emit ERC20PaymentReleased(token, account, payment);\n    }\n\n    /**\n     * @dev internal logic for computing the pending payment of an `account` given the token historical balances and\n     * already released amounts.\n     */\n    function _pendingPayment(\n        address account,\n        uint256 totalReceived,\n        uint256 alreadyReleased\n    ) private view returns (uint256) {\n        return (totalReceived * _shares[account]) / _totalShares - alreadyReleased;\n    }\n\n    /**\n     * @dev Add a new payee to the contract.\n     * @param account The address of the payee to add.\n     * @param shares_ The number of shares owned by the payee.\n     */\n    function _addPayee(address account, uint256 shares_) private {\n        require(account != address(0), \"PaymentSplitter: account is the zero address\");\n        require(shares_ \u003e 0, \"PaymentSplitter: shares are 0\");\n        require(_shares[account] == 0, \"PaymentSplitter: account already has shares\");\n\n        _payees.push(account);\n        _payeesShares.push(shares_);\n        _shares[account] = shares_;\n        _totalShares = _totalShares + shares_;\n        emit PayeeAdded(account, shares_);\n    }\n}"},"SafeERC20.sol":{"content":"// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)\n\npragma solidity ^0.8.12;\n\nimport \"./IERC20.sol\";\nimport \"./Address.sol\";\n\n/**\n * @title SafeERC20\n * @dev Wrappers around ERC20 operations that throw on failure (when the token\n * contract returns false). Tokens that return no value (and instead revert or\n * throw on failure) are also supported, non-reverting calls are assumed to be\n * successful.\n * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,\n * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.\n */\nlibrary SafeERC20 {\n    using Address for address;\n\n    address internal constant MAINNET_TRON_USDT_ADDRESS = address(0xa614f803B6FD780986A42c78Ec9c7f77e6DeD13C);\n    address internal constant SHASTA_TRON_USDT_ADDRESS = address(0x2aFE4E8d4c881EBEac362b323E115A6f86Fad5C9);\n    uint256 internal constant MAINNET_TRON_CHAIN_ID = 728126428;\n    uint256 internal constant SHASTA_TRON_CHAIN_ID = 2494104990;\n\n    function safeTransfer(IERC20 token, address to, uint256 value) internal {\n        require(to != address(0), \"SafeERC20: transfer to the zero address\");\n        if ((block.chainid==MAINNET_TRON_CHAIN_ID \u0026\u0026 address(token) == MAINNET_TRON_USDT_ADDRESS) ||\n            (block.chainid==SHASTA_TRON_CHAIN_ID \u0026\u0026 address(token) == SHASTA_TRON_USDT_ADDRESS)) {\n            // For USDT on Tron, transfer method always returns false, so _callOptionalReturn can not be used.\n            token.transfer(to, value);\n        } else {\n            _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));\n        }\n    }\n\n    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {\n        require(to != address(0), \"SafeERC20: transfer to the zero address\");\n        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));\n    }\n\n    /**\n     * @dev Deprecated. This function has issues similar to the ones found in\n     * {IERC20-approve}, and its usage is discouraged.\n     *\n     * Whenever possible, use {safeIncreaseAllowance} and\n     * {safeDecreaseAllowance} instead.\n     */\n    function safeApprove(IERC20 token, address spender, uint256 value) internal {\n        // safeApprove should only be called when setting an initial allowance,\n        // or when resetting it to zero. To increase and decrease it, use\n        // \u0027safeIncreaseAllowance\u0027 and \u0027safeDecreaseAllowance\u0027\n        require(\n            (value == 0) || (token.allowance(address(this), spender) == 0),\n            \"SafeERC20: approve from non-zero to non-zero allowance\"\n        );\n        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));\n    }\n\n    function safeApproveToMax(IERC20 token, address spender, uint256 value) internal {\n        uint256 allowance = token.allowance(address(this), spender);\n        if (allowance \u003e= value) {\n            return;\n        }\n        // For ERC-20 that has safe approve check, set approval to 0 before approve to max\n        if (allowance \u003e 0) {\n            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, 0));\n        }\n        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, type(uint256).max));\n    }\n\n    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {\n        uint256 newAllowance = token.allowance(address(this), spender) + value;\n        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));\n    }\n\n    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {\n        unchecked {\n            uint256 oldAllowance = token.allowance(address(this), spender);\n            require(oldAllowance \u003e= value, \"SafeERC20: decreased allowance below zero\");\n            uint256 newAllowance = oldAllowance - value;\n            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));\n        }\n    }\n\n    /**\n     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement\n     * on the return value: the return value is optional (but if data is returned, it must not be false).\n     * @param token The token targeted by the call.\n     * @param data The call data (encoded using abi.encode or one of its variants).\n     */\n    function _callOptionalReturn(IERC20 token, bytes memory data) private {\n        // We need to perform a low level call here, to bypass Solidity\u0027s return data size checking mechanism, since\n        // we\u0027re implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that\n        // the target address contains contract code and also asserts for success in the low-level call.\n\n        bytes memory returndata = address(token).functionCall(data, \"SafeERC20: low-level call failed\");\n        if (returndata.length \u003e 0) {\n            // Return data is optional\n            require(abi.decode(returndata, (bool)), \"SafeERC20: ERC20 operation did not succeed\");\n        }\n    }\n}\n"}}