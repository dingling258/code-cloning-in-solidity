{{
  "language": "Solidity",
  "sources": {
    "@openzeppelin/contracts/access/Ownable.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)\n\npragma solidity ^0.8.0;\n\nimport \"../utils/Context.sol\";\n\n/**\n * @dev Contract module which provides a basic access control mechanism, where\n * there is an account (an owner) that can be granted exclusive access to\n * specific functions.\n *\n * By default, the owner account will be the one that deploys the contract. This\n * can later be changed with {transferOwnership}.\n *\n * This module is used through inheritance. It will make available the modifier\n * `onlyOwner`, which can be applied to your functions to restrict their use to\n * the owner.\n */\nabstract contract Ownable is Context {\n    address private _owner;\n\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    /**\n     * @dev Initializes the contract setting the deployer as the initial owner.\n     */\n    constructor() {\n        _transferOwnership(_msgSender());\n    }\n\n    /**\n     * @dev Throws if called by any account other than the owner.\n     */\n    modifier onlyOwner() {\n        _checkOwner();\n        _;\n    }\n\n    /**\n     * @dev Returns the address of the current owner.\n     */\n    function owner() public view virtual returns (address) {\n        return _owner;\n    }\n\n    /**\n     * @dev Throws if the sender is not the owner.\n     */\n    function _checkOwner() internal view virtual {\n        require(owner() == _msgSender(), \"Ownable: caller is not the owner\");\n    }\n\n    /**\n     * @dev Leaves the contract without owner. It will not be possible to call\n     * `onlyOwner` functions. Can only be called by the current owner.\n     *\n     * NOTE: Renouncing ownership will leave the contract without an owner,\n     * thereby disabling any functionality that is only available to the owner.\n     */\n    function renounceOwnership() public virtual onlyOwner {\n        _transferOwnership(address(0));\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Can only be called by the current owner.\n     */\n    function transferOwnership(address newOwner) public virtual onlyOwner {\n        require(newOwner != address(0), \"Ownable: new owner is the zero address\");\n        _transferOwnership(newOwner);\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Internal function without access restriction.\n     */\n    function _transferOwnership(address newOwner) internal virtual {\n        address oldOwner = _owner;\n        _owner = newOwner;\n        emit OwnershipTransferred(oldOwner, newOwner);\n    }\n}\n"
    },
    "@openzeppelin/contracts/access/Ownable2Step.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable2Step.sol)\n\npragma solidity ^0.8.0;\n\nimport \"./Ownable.sol\";\n\n/**\n * @dev Contract module which provides access control mechanism, where\n * there is an account (an owner) that can be granted exclusive access to\n * specific functions.\n *\n * By default, the owner account will be the one that deploys the contract. This\n * can later be changed with {transferOwnership} and {acceptOwnership}.\n *\n * This module is used through inheritance. It will make available all functions\n * from parent (Ownable).\n */\nabstract contract Ownable2Step is Ownable {\n    address private _pendingOwner;\n\n    event OwnershipTransferStarted(address indexed previousOwner, address indexed newOwner);\n\n    /**\n     * @dev Returns the address of the pending owner.\n     */\n    function pendingOwner() public view virtual returns (address) {\n        return _pendingOwner;\n    }\n\n    /**\n     * @dev Starts the ownership transfer of the contract to a new account. Replaces the pending transfer if there is one.\n     * Can only be called by the current owner.\n     */\n    function transferOwnership(address newOwner) public virtual override onlyOwner {\n        _pendingOwner = newOwner;\n        emit OwnershipTransferStarted(owner(), newOwner);\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`) and deletes any pending owner.\n     * Internal function without access restriction.\n     */\n    function _transferOwnership(address newOwner) internal virtual override {\n        delete _pendingOwner;\n        super._transferOwnership(newOwner);\n    }\n\n    /**\n     * @dev The new owner accepts the ownership transfer.\n     */\n    function acceptOwnership() public virtual {\n        address sender = _msgSender();\n        require(pendingOwner() == sender, \"Ownable2Step: caller is not the new owner\");\n        _transferOwnership(sender);\n    }\n}\n"
    },
    "@openzeppelin/contracts/security/ReentrancyGuard.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Contract module that helps prevent reentrant calls to a function.\n *\n * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier\n * available, which can be applied to functions to make sure there are no nested\n * (reentrant) calls to them.\n *\n * Note that because there is a single `nonReentrant` guard, functions marked as\n * `nonReentrant` may not call one another. This can be worked around by making\n * those functions `private`, and then adding `external` `nonReentrant` entry\n * points to them.\n *\n * TIP: If you would like to learn more about reentrancy and alternative ways\n * to protect against it, check out our blog post\n * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].\n */\nabstract contract ReentrancyGuard {\n    // Booleans are more expensive than uint256 or any type that takes up a full\n    // word because each write operation emits an extra SLOAD to first read the\n    // slot's contents, replace the bits taken up by the boolean, and then write\n    // back. This is the compiler's defense against contract upgrades and\n    // pointer aliasing, and it cannot be disabled.\n\n    // The values being non-zero value makes deployment a bit more expensive,\n    // but in exchange the refund on every call to nonReentrant will be lower in\n    // amount. Since refunds are capped to a percentage of the total\n    // transaction's gas, it is best to keep them low in cases like this one, to\n    // increase the likelihood of the full refund coming into effect.\n    uint256 private constant _NOT_ENTERED = 1;\n    uint256 private constant _ENTERED = 2;\n\n    uint256 private _status;\n\n    constructor() {\n        _status = _NOT_ENTERED;\n    }\n\n    /**\n     * @dev Prevents a contract from calling itself, directly or indirectly.\n     * Calling a `nonReentrant` function from another `nonReentrant`\n     * function is not supported. It is possible to prevent this from happening\n     * by making the `nonReentrant` function external, and making it call a\n     * `private` function that does the actual work.\n     */\n    modifier nonReentrant() {\n        _nonReentrantBefore();\n        _;\n        _nonReentrantAfter();\n    }\n\n    function _nonReentrantBefore() private {\n        // On the first call to nonReentrant, _status will be _NOT_ENTERED\n        require(_status != _ENTERED, \"ReentrancyGuard: reentrant call\");\n\n        // Any calls to nonReentrant after this point will fail\n        _status = _ENTERED;\n    }\n\n    function _nonReentrantAfter() private {\n        // By storing the original value once again, a refund is triggered (see\n        // https://eips.ethereum.org/EIPS/eip-2200)\n        _status = _NOT_ENTERED;\n    }\n\n    /**\n     * @dev Returns true if the reentrancy guard is currently set to \"entered\", which indicates there is a\n     * `nonReentrant` function in the call stack.\n     */\n    function _reentrancyGuardEntered() internal view returns (bool) {\n        return _status == _ENTERED;\n    }\n}\n"
    },
    "@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.9.4) (token/ERC20/extensions/IERC20Permit.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in\n * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].\n *\n * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by\n * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't\n * need to send a transaction, and thus is not required to hold Ether at all.\n *\n * ==== Security Considerations\n *\n * There are two important considerations concerning the use of `permit`. The first is that a valid permit signature\n * expresses an allowance, and it should not be assumed to convey additional meaning. In particular, it should not be\n * considered as an intention to spend the allowance in any specific way. The second is that because permits have\n * built-in replay protection and can be submitted by anyone, they can be frontrun. A protocol that uses permits should\n * take this into consideration and allow a `permit` call to fail. Combining these two aspects, a pattern that may be\n * generally recommended is:\n *\n * ```solidity\n * function doThingWithPermit(..., uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public {\n *     try token.permit(msg.sender, address(this), value, deadline, v, r, s) {} catch {}\n *     doThing(..., value);\n * }\n *\n * function doThing(..., uint256 value) public {\n *     token.safeTransferFrom(msg.sender, address(this), value);\n *     ...\n * }\n * ```\n *\n * Observe that: 1) `msg.sender` is used as the owner, leaving no ambiguity as to the signer intent, and 2) the use of\n * `try/catch` allows the permit to fail and makes the code tolerant to frontrunning. (See also\n * {SafeERC20-safeTransferFrom}).\n *\n * Additionally, note that smart contract wallets (such as Argent or Safe) are not able to produce permit signatures, so\n * contracts should have entry points that don't rely on permit.\n */\ninterface IERC20Permit {\n    /**\n     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,\n     * given ``owner``'s signed approval.\n     *\n     * IMPORTANT: The same issues {IERC20-approve} has related to transaction\n     * ordering also apply here.\n     *\n     * Emits an {Approval} event.\n     *\n     * Requirements:\n     *\n     * - `spender` cannot be the zero address.\n     * - `deadline` must be a timestamp in the future.\n     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`\n     * over the EIP712-formatted function arguments.\n     * - the signature must use ``owner``'s current nonce (see {nonces}).\n     *\n     * For more information on the signature format, see the\n     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP\n     * section].\n     *\n     * CAUTION: See Security Considerations above.\n     */\n    function permit(\n        address owner,\n        address spender,\n        uint256 value,\n        uint256 deadline,\n        uint8 v,\n        bytes32 r,\n        bytes32 s\n    ) external;\n\n    /**\n     * @dev Returns the current nonce for `owner`. This value must be\n     * included whenever a signature is generated for {permit}.\n     *\n     * Every successful call to {permit} increases ``owner``'s nonce by one. This\n     * prevents a signature from being used multiple times.\n     */\n    function nonces(address owner) external view returns (uint256);\n\n    /**\n     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.\n     */\n    // solhint-disable-next-line func-name-mixedcase\n    function DOMAIN_SEPARATOR() external view returns (bytes32);\n}\n"
    },
    "@openzeppelin/contracts/token/ERC20/IERC20.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Interface of the ERC20 standard as defined in the EIP.\n */\ninterface IERC20 {\n    /**\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\n     * another (`to`).\n     *\n     * Note that `value` may be zero.\n     */\n    event Transfer(address indexed from, address indexed to, uint256 value);\n\n    /**\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\n     * a call to {approve}. `value` is the new allowance.\n     */\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n\n    /**\n     * @dev Returns the amount of tokens in existence.\n     */\n    function totalSupply() external view returns (uint256);\n\n    /**\n     * @dev Returns the amount of tokens owned by `account`.\n     */\n    function balanceOf(address account) external view returns (uint256);\n\n    /**\n     * @dev Moves `amount` tokens from the caller's account to `to`.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transfer(address to, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Returns the remaining number of tokens that `spender` will be\n     * allowed to spend on behalf of `owner` through {transferFrom}. This is\n     * zero by default.\n     *\n     * This value changes when {approve} or {transferFrom} are called.\n     */\n    function allowance(address owner, address spender) external view returns (uint256);\n\n    /**\n     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\n     * that someone may use both the old and the new allowance by unfortunate\n     * transaction ordering. One possible solution to mitigate this race\n     * condition is to first reduce the spender's allowance to 0 and set the\n     * desired value afterwards:\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\n     *\n     * Emits an {Approval} event.\n     */\n    function approve(address spender, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Moves `amount` tokens from `from` to `to` using the\n     * allowance mechanism. `amount` is then deducted from the caller's\n     * allowance.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transferFrom(address from, address to, uint256 amount) external returns (bool);\n}\n"
    },
    "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.9.3) (token/ERC20/utils/SafeERC20.sol)\n\npragma solidity ^0.8.0;\n\nimport \"../IERC20.sol\";\nimport \"../extensions/IERC20Permit.sol\";\nimport \"../../../utils/Address.sol\";\n\n/**\n * @title SafeERC20\n * @dev Wrappers around ERC20 operations that throw on failure (when the token\n * contract returns false). Tokens that return no value (and instead revert or\n * throw on failure) are also supported, non-reverting calls are assumed to be\n * successful.\n * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,\n * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.\n */\nlibrary SafeERC20 {\n    using Address for address;\n\n    /**\n     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,\n     * non-reverting calls are assumed to be successful.\n     */\n    function safeTransfer(IERC20 token, address to, uint256 value) internal {\n        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));\n    }\n\n    /**\n     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the\n     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.\n     */\n    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {\n        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));\n    }\n\n    /**\n     * @dev Deprecated. This function has issues similar to the ones found in\n     * {IERC20-approve}, and its usage is discouraged.\n     *\n     * Whenever possible, use {safeIncreaseAllowance} and\n     * {safeDecreaseAllowance} instead.\n     */\n    function safeApprove(IERC20 token, address spender, uint256 value) internal {\n        // safeApprove should only be called when setting an initial allowance,\n        // or when resetting it to zero. To increase and decrease it, use\n        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'\n        require(\n            (value == 0) || (token.allowance(address(this), spender) == 0),\n            \"SafeERC20: approve from non-zero to non-zero allowance\"\n        );\n        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));\n    }\n\n    /**\n     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,\n     * non-reverting calls are assumed to be successful.\n     */\n    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {\n        uint256 oldAllowance = token.allowance(address(this), spender);\n        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, oldAllowance + value));\n    }\n\n    /**\n     * @dev Decrease the calling contract's allowance toward `spender` by `value`. If `token` returns no value,\n     * non-reverting calls are assumed to be successful.\n     */\n    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {\n        unchecked {\n            uint256 oldAllowance = token.allowance(address(this), spender);\n            require(oldAllowance >= value, \"SafeERC20: decreased allowance below zero\");\n            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, oldAllowance - value));\n        }\n    }\n\n    /**\n     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,\n     * non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval\n     * to be set to zero before setting it to a non-zero value, such as USDT.\n     */\n    function forceApprove(IERC20 token, address spender, uint256 value) internal {\n        bytes memory approvalCall = abi.encodeWithSelector(token.approve.selector, spender, value);\n\n        if (!_callOptionalReturnBool(token, approvalCall)) {\n            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, 0));\n            _callOptionalReturn(token, approvalCall);\n        }\n    }\n\n    /**\n     * @dev Use a ERC-2612 signature to set the `owner` approval toward `spender` on `token`.\n     * Revert on invalid signature.\n     */\n    function safePermit(\n        IERC20Permit token,\n        address owner,\n        address spender,\n        uint256 value,\n        uint256 deadline,\n        uint8 v,\n        bytes32 r,\n        bytes32 s\n    ) internal {\n        uint256 nonceBefore = token.nonces(owner);\n        token.permit(owner, spender, value, deadline, v, r, s);\n        uint256 nonceAfter = token.nonces(owner);\n        require(nonceAfter == nonceBefore + 1, \"SafeERC20: permit did not succeed\");\n    }\n\n    /**\n     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement\n     * on the return value: the return value is optional (but if data is returned, it must not be false).\n     * @param token The token targeted by the call.\n     * @param data The call data (encoded using abi.encode or one of its variants).\n     */\n    function _callOptionalReturn(IERC20 token, bytes memory data) private {\n        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since\n        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that\n        // the target address contains contract code and also asserts for success in the low-level call.\n\n        bytes memory returndata = address(token).functionCall(data, \"SafeERC20: low-level call failed\");\n        require(returndata.length == 0 || abi.decode(returndata, (bool)), \"SafeERC20: ERC20 operation did not succeed\");\n    }\n\n    /**\n     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement\n     * on the return value: the return value is optional (but if data is returned, it must not be false).\n     * @param token The token targeted by the call.\n     * @param data The call data (encoded using abi.encode or one of its variants).\n     *\n     * This is a variant of {_callOptionalReturn} that silents catches all reverts and returns a bool instead.\n     */\n    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {\n        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since\n        // we're implementing it ourselves. We cannot use {Address-functionCall} here since this should return false\n        // and not revert is the subcall reverts.\n\n        (bool success, bytes memory returndata) = address(token).call(data);\n        return\n            success && (returndata.length == 0 || abi.decode(returndata, (bool))) && Address.isContract(address(token));\n    }\n}\n"
    },
    "@openzeppelin/contracts/utils/Address.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.9.0) (utils/Address.sol)\n\npragma solidity ^0.8.1;\n\n/**\n * @dev Collection of functions related to the address type\n */\nlibrary Address {\n    /**\n     * @dev Returns true if `account` is a contract.\n     *\n     * [IMPORTANT]\n     * ====\n     * It is unsafe to assume that an address for which this function returns\n     * false is an externally-owned account (EOA) and not a contract.\n     *\n     * Among others, `isContract` will return false for the following\n     * types of addresses:\n     *\n     *  - an externally-owned account\n     *  - a contract in construction\n     *  - an address where a contract will be created\n     *  - an address where a contract lived, but was destroyed\n     *\n     * Furthermore, `isContract` will also return true if the target contract within\n     * the same transaction is already scheduled for destruction by `SELFDESTRUCT`,\n     * which only has an effect at the end of a transaction.\n     * ====\n     *\n     * [IMPORTANT]\n     * ====\n     * You shouldn't rely on `isContract` to protect against flash loan attacks!\n     *\n     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets\n     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract\n     * constructor.\n     * ====\n     */\n    function isContract(address account) internal view returns (bool) {\n        // This method relies on extcodesize/address.code.length, which returns 0\n        // for contracts in construction, since the code is only stored at the end\n        // of the constructor execution.\n\n        return account.code.length > 0;\n    }\n\n    /**\n     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to\n     * `recipient`, forwarding all available gas and reverting on errors.\n     *\n     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost\n     * of certain opcodes, possibly making contracts go over the 2300 gas limit\n     * imposed by `transfer`, making them unable to receive funds via\n     * `transfer`. {sendValue} removes this limitation.\n     *\n     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].\n     *\n     * IMPORTANT: because control is transferred to `recipient`, care must be\n     * taken to not create reentrancy vulnerabilities. Consider using\n     * {ReentrancyGuard} or the\n     * https://solidity.readthedocs.io/en/v0.8.0/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].\n     */\n    function sendValue(address payable recipient, uint256 amount) internal {\n        require(address(this).balance >= amount, \"Address: insufficient balance\");\n\n        (bool success, ) = recipient.call{value: amount}(\"\");\n        require(success, \"Address: unable to send value, recipient may have reverted\");\n    }\n\n    /**\n     * @dev Performs a Solidity function call using a low level `call`. A\n     * plain `call` is an unsafe replacement for a function call: use this\n     * function instead.\n     *\n     * If `target` reverts with a revert reason, it is bubbled up by this\n     * function (like regular Solidity function calls).\n     *\n     * Returns the raw returned data. To convert to the expected return value,\n     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].\n     *\n     * Requirements:\n     *\n     * - `target` must be a contract.\n     * - calling `target` with `data` must not revert.\n     *\n     * _Available since v3.1._\n     */\n    function functionCall(address target, bytes memory data) internal returns (bytes memory) {\n        return functionCallWithValue(target, data, 0, \"Address: low-level call failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with\n     * `errorMessage` as a fallback revert reason when `target` reverts.\n     *\n     * _Available since v3.1._\n     */\n    function functionCall(\n        address target,\n        bytes memory data,\n        string memory errorMessage\n    ) internal returns (bytes memory) {\n        return functionCallWithValue(target, data, 0, errorMessage);\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\n     * but also transferring `value` wei to `target`.\n     *\n     * Requirements:\n     *\n     * - the calling contract must have an ETH balance of at least `value`.\n     * - the called Solidity function must be `payable`.\n     *\n     * _Available since v3.1._\n     */\n    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {\n        return functionCallWithValue(target, data, value, \"Address: low-level call with value failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but\n     * with `errorMessage` as a fallback revert reason when `target` reverts.\n     *\n     * _Available since v3.1._\n     */\n    function functionCallWithValue(\n        address target,\n        bytes memory data,\n        uint256 value,\n        string memory errorMessage\n    ) internal returns (bytes memory) {\n        require(address(this).balance >= value, \"Address: insufficient balance for call\");\n        (bool success, bytes memory returndata) = target.call{value: value}(data);\n        return verifyCallResultFromTarget(target, success, returndata, errorMessage);\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\n     * but performing a static call.\n     *\n     * _Available since v3.3._\n     */\n    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {\n        return functionStaticCall(target, data, \"Address: low-level static call failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],\n     * but performing a static call.\n     *\n     * _Available since v3.3._\n     */\n    function functionStaticCall(\n        address target,\n        bytes memory data,\n        string memory errorMessage\n    ) internal view returns (bytes memory) {\n        (bool success, bytes memory returndata) = target.staticcall(data);\n        return verifyCallResultFromTarget(target, success, returndata, errorMessage);\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\n     * but performing a delegate call.\n     *\n     * _Available since v3.4._\n     */\n    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {\n        return functionDelegateCall(target, data, \"Address: low-level delegate call failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],\n     * but performing a delegate call.\n     *\n     * _Available since v3.4._\n     */\n    function functionDelegateCall(\n        address target,\n        bytes memory data,\n        string memory errorMessage\n    ) internal returns (bytes memory) {\n        (bool success, bytes memory returndata) = target.delegatecall(data);\n        return verifyCallResultFromTarget(target, success, returndata, errorMessage);\n    }\n\n    /**\n     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling\n     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.\n     *\n     * _Available since v4.8._\n     */\n    function verifyCallResultFromTarget(\n        address target,\n        bool success,\n        bytes memory returndata,\n        string memory errorMessage\n    ) internal view returns (bytes memory) {\n        if (success) {\n            if (returndata.length == 0) {\n                // only check isContract if the call was successful and the return data is empty\n                // otherwise we already know that it was a contract\n                require(isContract(target), \"Address: call to non-contract\");\n            }\n            return returndata;\n        } else {\n            _revert(returndata, errorMessage);\n        }\n    }\n\n    /**\n     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the\n     * revert reason or using the provided one.\n     *\n     * _Available since v4.3._\n     */\n    function verifyCallResult(\n        bool success,\n        bytes memory returndata,\n        string memory errorMessage\n    ) internal pure returns (bytes memory) {\n        if (success) {\n            return returndata;\n        } else {\n            _revert(returndata, errorMessage);\n        }\n    }\n\n    function _revert(bytes memory returndata, string memory errorMessage) private pure {\n        // Look for revert reason and bubble it up if present\n        if (returndata.length > 0) {\n            // The easiest way to bubble the revert reason is using memory via assembly\n            /// @solidity memory-safe-assembly\n            assembly {\n                let returndata_size := mload(returndata)\n                revert(add(32, returndata), returndata_size)\n            }\n        } else {\n            revert(errorMessage);\n        }\n    }\n}\n"
    },
    "@openzeppelin/contracts/utils/Context.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.9.4) (utils/Context.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes calldata) {\n        return msg.data;\n    }\n\n    function _contextSuffixLength() internal view virtual returns (uint256) {\n        return 0;\n    }\n}\n"
    },
    "contracts/RPKTrancheManager.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity 0.8.9;\n\nimport {Ownable2Step} from \"@openzeppelin/contracts/access/Ownable2Step.sol\";\nimport {IERC20} from \"@openzeppelin/contracts/token/ERC20/IERC20.sol\";\nimport {SafeERC20} from \"@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol\";\nimport {Tranche} from \"./Tranche.sol\";\n\ncontract RPKTrancheManager is Ownable2Step {\n    using SafeERC20 for IERC20;\n\n    event CreateTranche(address indexed tranche, address from, address beneficiary, uint256 amount);\n\n    uint256 public constant E20281115 = 1857859200;\n\n    uint256 public constant E20251115 = 1763164800;\n\n    IERC20 public immutable RPKToken;\n\n    Tranche[] public tranches;\n\n    mapping(address => bool) public whitelist;\n\n    struct TrancheData {\n        address tranche;\n        address token;\n        address beneficiary;\n        uint256 releasedAmount;\n        uint256 totalAmount;\n        uint256 startTime;\n        uint256 endTime;\n        uint256 currentIncome;\n    }\n\n    constructor(IERC20 _RPKToken) {\n        RPKToken = _RPKToken;\n    }\n\n    modifier onlyWhitelisted() {\n        require(whitelist[_msgSender()], \"Not whitelisted\");\n        _;\n    }\n\n    function setWhitelist(address[] memory _addresses, bool[] memory _values) external onlyOwner {\n        require(_addresses.length == _values.length, \"Array length mismatch\");\n        for (uint256 i = 0; i < _addresses.length; i++) {\n            whitelist[_addresses[i]] = _values[i];\n        }\n    }\n\n    function createTranche(address _beneficiary, uint256 _endTime, uint256 _totalAmount) external onlyWhitelisted {\n        require(_endTime == E20281115 || _endTime == E20251115, \"End time must be 15 Nov 2028 or 15 Nov 2025\");\n        Tranche tranche = new Tranche(RPKToken, _beneficiary, _endTime, _totalAmount);\n        tranches.push(tranche);\n        RPKToken.safeTransferFrom(_msgSender(), address(tranche), _totalAmount);\n        emit CreateTranche(address(tranche), _msgSender(), _beneficiary, _totalAmount);\n    }\n\n    function getTranches(uint256 _cursor, uint256 _size) external view returns (TrancheData[] memory) {\n        uint256 length = _size;\n        if (_cursor + _size > tranches.length) {\n            length = tranches.length - _cursor;\n        }\n        TrancheData[] memory trancheData = new TrancheData[](length);\n        for (uint256 i = 0; i < length; i++) {\n            trancheData[i] = TrancheData({\n                tranche: address(tranches[_cursor + i]),\n                token: address(tranches[_cursor + i].token()),\n                beneficiary: tranches[_cursor + i].beneficiary(),\n                releasedAmount: tranches[_cursor + i].releasedAmount(),\n                totalAmount: tranches[_cursor + i].totalAmount(),\n                startTime: tranches[_cursor + i].startTime(),\n                endTime: tranches[_cursor + i].endTime(),\n                currentIncome: tranches[_cursor + i].currentIncome()\n            });\n        }\n        return trancheData;\n    }\n}\n"
    },
    "contracts/Tranche.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity 0.8.9;\n\nimport {SafeERC20} from \"@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol\";\nimport {IERC20} from \"@openzeppelin/contracts/token/ERC20/IERC20.sol\";\nimport {ReentrancyGuard} from \"@openzeppelin/contracts/security/ReentrancyGuard.sol\";\n\ncontract Tranche is ReentrancyGuard {\n    using SafeERC20 for IERC20;\n\n    IERC20 public immutable token;\n    address public immutable beneficiary;\n    uint256 public releasedAmount;\n    uint256 public immutable totalAmount;\n    uint256 public immutable startTime;\n    uint256 public immutable endTime;\n\n    constructor(IERC20 _token, address _beneficiary, uint256 _endTime, uint256 _totalAmount) {\n        require(_endTime > block.timestamp, \"Release time should be in the future\");\n        require(_totalAmount > 0, \"No tokens to release\");\n\n        token = _token;\n        beneficiary = _beneficiary;\n        endTime = _endTime;\n        startTime = block.timestamp;\n        totalAmount = _totalAmount;\n    }\n\n    function currentIncome() public view returns (uint256) {\n        uint256 currentTime = block.timestamp;\n        if (currentTime > endTime) {\n            currentTime = endTime;\n        }\n        uint256 _elapsedTimestamp = currentTime - startTime;\n        uint256 _totalElapsedTimestamp = endTime - startTime;\n        uint256 _amount = (totalAmount * _elapsedTimestamp) / _totalElapsedTimestamp;\n        return _amount - releasedAmount;\n    }\n\n    function release() external nonReentrant {\n        uint256 _amount = currentIncome();\n        if (_amount > 0) {\n            releasedAmount += _amount;\n            token.safeTransfer(beneficiary, _amount);\n        }\n    }\n}\n"
    }
  },
  "settings": {
    "optimizer": {
      "enabled": true,
      "runs": 99999
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