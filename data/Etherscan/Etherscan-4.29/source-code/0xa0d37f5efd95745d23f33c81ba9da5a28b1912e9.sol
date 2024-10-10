// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0 ^0.8.1 ^0.8.13;

// lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol

// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

// lib/openzeppelin-contracts/contracts/token/ERC20/extensions/IERC20Permit.sol

// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/extensions/IERC20Permit.sol)

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

// lib/openzeppelin-contracts/contracts/utils/Address.sol

// OpenZeppelin Contracts (last updated v4.9.0) (utils/Address.sol)

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     *
     * Furthermore, `isContract` will also return true if the target contract within
     * the same transaction is already scheduled for destruction by `SELFDESTRUCT`,
     * which only has an effect at the end of a transaction.
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.8.0/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

// lib/openzeppelin-contracts/contracts/utils/Context.sol

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// src/interface/IAggregatorV3Interface.sol

interface AggregatorV3Interface {

    function decimals()
      external
      view
      returns (
        uint8
      );
  
    function description()
      external
      view
      returns (
        string memory
      );
  
    function version()
      external
      view
      returns (
        uint256
      );
  
    function getRoundData(
      uint80 _roundId
    )
      external
      view
      returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
      );
  
    function latestRoundData()
      external
      view
      returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
      );
  
  }

// src/interface/IWETH.sol

interface IWETH {
    function deposit() external payable;
  
    function withdraw(uint256) external;
  
    function approve(address guy, uint256 wad) external returns (bool);
  
    function transferFrom(
      address src,
      address dst,
      uint256 wad
    ) external returns (bool);
  }

// lib/openzeppelin-contracts/contracts/access/Ownable.sol

// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol

// OpenZeppelin Contracts (last updated v4.9.3) (token/ERC20/utils/SafeERC20.sol)

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    /**
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, oldAllowance + value));
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, oldAllowance - value));
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval
     * to be set to zero before setting it to a non-zero value, such as USDT.
     */
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeWithSelector(token.approve.selector, spender, value);

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, 0));
            _callOptionalReturn(token, approvalCall);
        }
    }

    /**
     * @dev Use a ERC-2612 signature to set the `owner` approval toward `spender` on `token`.
     * Revert on invalid signature.
     */
    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        require(returndata.length == 0 || abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturn} that silents catches all reverts and returns a bool instead.
     */
    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We cannot use {Address-functionCall} here since this should return false
        // and not revert is the subcall reverts.

        (bool success, bytes memory returndata) = address(token).call(data);
        return
            success && (returndata.length == 0 || abi.decode(returndata, (bool))) && Address.isContract(address(token));
    }
}

// src/TigaICO.sol

interface IOracle {
    function getPrice(address token) external view returns (uint256);
}

contract Multicall {

    function multicall(bytes[] calldata data) public payable returns (bytes[] memory results) {
        results = new bytes[](data.length);
        for (uint256 i = 0; i < data.length; i++) {
            (bool success, bytes memory result) = address(this).delegatecall(data[i]);

            if (!success) {
                if (result.length < 68) revert();
                assembly {
                    result := add(result, 0x04)
                }
                revert(abi.decode(result, (string)));
            }

            results[i] = result;
        }
    }
}

contract TigaICO is Ownable, Multicall {

    using SafeERC20 for IERC20;

    enum OracleMode {CHAINLINK, OTHER}

    struct Token {
        address tokenAddress;
        address oracleAddress;
        OracleMode mode;
        uint256 decimals;
        bool isPaused;
    }
    
    struct Round {
        uint256 roundId;
        uint256 startTime;
        uint256 endTime;
        uint256 capLimit;
        uint256 currentCap;
        bool capReached;
        bool isPaused;
        address[] tokens;
    }

    event SupportedTokenAdded(address token);
    event SupportedTokenPaused(address token, bool paused);
    event SupportedTokenRemoved(address token);
    event NewRoundCreated(uint256 roundId);
    event RoundPauseToggled(uint256 roundId, bool isPaused);
    event ParticipatedInRound(uint256 roundId, address participant, address token, uint256 amount, uint256 price);
    event FundsCollected(address collector);

    error OraclePriceLessThanZero();
    error OraclePriceExpired();

    mapping(address => Token) public supportedTokens;
    mapping(uint256 => Round) public roundInfo;
    uint256 public nextRoundId = 1;

    address public immutable WRAPPED_NATIVE_TOKEN;
    address public immutable NATIVE_TOKEN = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    constructor(address _wrapped_native_token) Ownable() {
        WRAPPED_NATIVE_TOKEN = _wrapped_native_token;
    }

    receive() external payable {
        require(msg.sender == WRAPPED_NATIVE_TOKEN, "Invalid eth sender");
    }

    function addSupportedToken(
        address _tokenAddress, 
        address _oracleAddress, 
        OracleMode _mode, 
        uint256 _decimals, 
        bool _isPaused
    ) external onlyOwner {
        require(supportedTokens[_tokenAddress].tokenAddress == address(0), "Token already supported.");
        supportedTokens[_tokenAddress] = Token(_tokenAddress, _oracleAddress, _mode, _decimals, _isPaused);
        emit SupportedTokenAdded(_tokenAddress);
    }

    function removeSupportedToken(address _tokenAddress) public onlyOwner {
        delete supportedTokens[_tokenAddress];
        emit SupportedTokenRemoved(_tokenAddress);
    }

    function isTokenSupported(address _tokenAddress) public view returns (bool) {
        return supportedTokens[_tokenAddress].tokenAddress != address(0);
    }

    function isTokenPaused(address tokenAddress) public view returns (bool) {
        require(supportedTokens[tokenAddress].tokenAddress != address(0), "Token not supported.");
        return supportedTokens[tokenAddress].isPaused;
    }

    function toggleTokenPause(address _tokenAddress, bool paused) external onlyOwner {
        require(supportedTokens[_tokenAddress].tokenAddress != address(0), "Token not supported.");
        supportedTokens[_tokenAddress].isPaused = paused;
        emit SupportedTokenPaused(_tokenAddress, paused);
    }

    function createNewRound(
        uint256 _startTime, 
        uint256 _endTime, 
        uint256 _capLimit, 
        address[] calldata _tokens
    ) external onlyOwner returns (uint256) {

        require(_startTime >= block.timestamp, "Start time must be in the future.");
        require(_endTime > _startTime, "End time must be after start time.");
        require(_capLimit > 0, "Cap limit must be greater than 0.");
        
        // Create a new round with a dynamic array for tokens.
        uint256 roundNumber = nextRoundId;
        Round storage newRound = roundInfo[roundNumber];
        newRound.roundId = roundNumber;
        newRound.startTime = _startTime;
        newRound.endTime = _endTime;
        newRound.capLimit = _capLimit;
        newRound.currentCap = 0;
        newRound.capReached = false;
        newRound.isPaused = false;
        
        for(uint256 i = 0; i < _tokens.length; i++) {
            require(supportedTokens[_tokens[i]].tokenAddress != address(0), "Token not supported.");
            newRound.tokens.push(_tokens[i]);
        }
        
        nextRoundId++;

        emit NewRoundCreated(roundNumber);

        return roundNumber;
    
    }
    

    function toggleRoundPause(uint256 _roundId, bool paused) external onlyOwner {
        require(_roundId > 0 && _roundId < nextRoundId, "Round ID does not exist.");
        roundInfo[_roundId].isPaused = paused;
        emit RoundPauseToggled(_roundId, paused);
    }

    function _queryChainLinkPrice(address oracle) internal view returns (uint256) {

        AggregatorV3Interface priceFeed = AggregatorV3Interface(oracle);

        (, int256 answer, , uint256 updatedAt, ) = priceFeed.latestRoundData();

        if (answer < 0) {
            revert OraclePriceLessThanZero();
        }

        if (updatedAt < block.timestamp - 1 days) {
            revert OraclePriceExpired();
        }

        uint8 decimals = priceFeed.decimals();
        return uint256(answer) * (10 ** uint256(18 - decimals));

    }

    function queryOraclePrice(address token) public view returns (uint256){
        if (supportedTokens[token].mode == OracleMode.CHAINLINK) {
            return _queryChainLinkPrice(supportedTokens[token].oracleAddress);
        } else {
            return IOracle(supportedTokens[token].oracleAddress).getPrice(token);
        }
    }

    function roundTokens(uint256 _roundId) public view returns (address[] memory, bool[] memory) {
        uint256 length = roundInfo[_roundId].tokens.length;
        bool[] memory pausedStatusArray = new bool[](length);
        for (uint i = 0; i < length; i++) {
            pausedStatusArray[i] = supportedTokens[roundInfo[_roundId].tokens[i]].isPaused ? true : false;
        }
        return (roundInfo[_roundId].tokens, pausedStatusArray);
    }

    function supportContriubtionRound(uint256 roundId) public view returns (bool){

        require(roundId > 0 && roundId < nextRoundId, "Round ID does not exist.");
        Round storage round = roundInfo[roundId];
        if (round.isPaused || round.capReached || block.timestamp < round.startTime || block.timestamp > round.endTime) {
            return false;
        }
        return true;

    }

 // Modified participateInRound function to support multiple tokens
    function participateInRound(uint256 _roundId, address _token, uint256 amount) external payable {

        require(_roundId > 0 && _roundId < nextRoundId, "Round ID does not exist.");
        Round storage round = roundInfo[_roundId];
        require(!round.isPaused, "Round is paused.");
        require(!round.capReached, "Round cap reached.");
        require(block.timestamp >= round.startTime && block.timestamp <= round.endTime, "Round not active.");
        require(amount > 0, "Amount must be greater than 0.");

        // Find the token in the round
        bool isTokenPartOfRound = false;
        for(uint i = 0; i < round.tokens.length; i++) {
            if(round.tokens[i] == _token) {
                isTokenPartOfRound = true;
                break;
            }
        }
        require(isTokenPartOfRound, "Token not part of round.");

        Token memory tokenInfo = supportedTokens[_token];
        require(tokenInfo.oracleAddress != address(0), "Token not supported.");
        require(tokenInfo.isPaused == false, "Token is paused.");
    
        uint256 price = queryOraclePrice(_token); // Use the internal function to get the price

        // Calculate the value in terms of cap currency
        uint256 valueInCapCurrency = amount * price / (10 ** tokenInfo.decimals);
    
        // Calculate the remaining cap space
        uint256 remainingCapSpace = roundInfo[_roundId].capLimit - roundInfo[_roundId].currentCap;
    
        // If the value exceeds the remaining cap space, adjust the amount
        bool capExceeded = false;
        if (valueInCapCurrency > remainingCapSpace) {
            // Adjust the amount based on remaining cap space and price, ensuring not to exceed the cap
            amount = (remainingCapSpace * 10 ** tokenInfo.decimals) / price;
            capExceeded = true;
        }
    
        // Update the round's current cap with the added value
        if (capExceeded) {
            roundInfo[_roundId].currentCap = roundInfo[_roundId].capLimit;
        } else {
            roundInfo[_roundId].currentCap += valueInCapCurrency;
        }
    
        // Check if the cap is reached after the addition
        if (roundInfo[_roundId].currentCap >= roundInfo[_roundId].capLimit) {
            roundInfo[_roundId].capReached = true;
        }
    
        // Transfer logic for native token vs. ERC20 token
        if (_token == NATIVE_TOKEN) {
            require(msg.value >= amount, "Incorrect amount sent.");
            // Refund any excess amount sent by the user
            if (msg.value > amount) {
                (bool sent, ) = payable(msg.sender).call{value: msg.value - amount}("");
                require(sent, "Failed to send Ether");
            }
            IWETH(WRAPPED_NATIVE_TOKEN).deposit{value: amount}();
        } else {
            require(msg.value == 0, "ETH sent for token purchase.");
            IERC20(_token).transferFrom(msg.sender, address(this), amount);
        }
    
        emit ParticipatedInRound(_roundId, msg.sender, _token, amount, price);
    }

    function collectFunds(address[] calldata token) onlyOwner external {
        for (uint256 i = 0; i < token.length; i++) {
            uint256 balance = IERC20(token[i]).balanceOf(address(this));
            IERC20(token[i]).safeTransfer(msg.sender, balance);
        }
    }

}