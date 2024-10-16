/**
 *Submitted for verification at BscScan.com on 2023-10-18
*/

/**
 *Submitted for verification at BscScan.com on 2023-09-25
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;
library SafeMath {
	/**
	 * @dev Returns the addition of two unsigned integers, with an overflow flag.
	 *
	 * _Available since v3.4._
	 */
	function tryAdd(uint256 a, uint256 b) internal pure returns(bool, uint256) {
		unchecked {
			uint256 c = a + b;
			if (c < a) return (false, 0);
			return (true, c);
		}
	}

	/**
	 * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
	 *
	 * _Available since v3.4._
	 */
	function trySub(uint256 a, uint256 b) internal pure returns(bool, uint256) {
		unchecked {
			if (b > a) return (false, 0);
			return (true, a - b);
		}
	}

	/**
	 * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
	 *
	 * _Available since v3.4._
	 */
	function tryMul(uint256 a, uint256 b) internal pure returns(bool, uint256) {
		unchecked {
			// Gas optimization: this is cheaper than requiring 'a' not being zero, but the
			// benefit is lost if 'b' is also tested.
			// See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
			if (a == 0) return (true, 0);
			uint256 c = a * b;
			if (c / a != b) return (false, 0);
			return (true, c);
		}
	}

	/**
	 * @dev Returns the division of two unsigned integers, with a division by zero flag.
	 *
	 * _Available since v3.4._
	 */
	function tryDiv(uint256 a, uint256 b) internal pure returns(bool, uint256) {
		unchecked {
			if (b == 0) return (false, 0);
			return (true, a / b);
		}
	}

	/**
	 * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
	 *
	 * _Available since v3.4._
	 */
	function tryMod(uint256 a, uint256 b) internal pure returns(bool, uint256) {
		unchecked {
			if (b == 0) return (false, 0);
			return (true, a % b);
		}
	}

	/**
	 * @dev Returns the addition of two unsigned integers, reverting on
	 * overflow.
	 *
	 * Counterpart to Solidity's `+` operator.
	 *
	 * Requirements:
	 *
	 * - Addition cannot overflow.
	 */
	function add(uint256 a, uint256 b) internal pure returns(uint256) {
		return a + b;
	}

	/**
	 * @dev Returns the subtraction of two unsigned integers, reverting on
	 * overflow (when the result is negative).
	 *
	 * Counterpart to Solidity's `-` operator.
	 *
	 * Requirements:
	 *
	 * - Subtraction cannot overflow.
	 */
	function sub(uint256 a, uint256 b) internal pure returns(uint256) {
		return a - b;
	}

	/**
	 * @dev Returns the multiplication of two unsigned integers, reverting on
	 * overflow.
	 *
	 * Counterpart to Solidity's `*` operator.
	 *
	 * Requirements:
	 *
	 * - Multiplication cannot overflow.
	 */
	function mul(uint256 a, uint256 b) internal pure returns(uint256) {
		return a * b;
	}

	/**
	 * @dev Returns the integer division of two unsigned integers, reverting on
	 * division by zero. The result is rounded towards zero.
	 *
	 * Counterpart to Solidity's `/` operator.
	 *
	 * Requirements:
	 *
	 * - The divisor cannot be zero.
	 */
	function div(uint256 a, uint256 b) internal pure returns(uint256) {
		return a / b;
	}

	/**
	 * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
	 * reverting when dividing by zero.
	 *
	 * Counterpart to Solidity's `%` operator. This function uses a `revert`
	 * opcode (which leaves remaining gas untouched) while Solidity uses an
	 * invalid opcode to revert (consuming all remaining gas).
	 *
	 * Requirements:
	 *
	 * - The divisor cannot be zero.
	 */
	function mod(uint256 a, uint256 b) internal pure returns(uint256) {
		return a % b;
	}

	/**
	 * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
	 * overflow (when the result is negative).
	 *
	 * CAUTION: This function is deprecated because it requires allocating memory for the error
	 * message unnecessarily. For custom revert reasons use {trySub}.
	 *
	 * Counterpart to Solidity's `-` operator.
	 *
	 * Requirements:
	 *
	 * - Subtraction cannot overflow.
	 */
	function sub(
		uint256 a,
		uint256 b,
		string memory errorMessage
	) internal pure returns(uint256) {
		unchecked {
			require(b <= a, errorMessage);
			return a - b;
		}
	}

	/**
	 * @dev Returns the integer division of two unsigned integers, reverting with custom message on
	 * division by zero. The result is rounded towards zero.
	 *
	 * Counterpart to Solidity's `/` operator. Note: this function uses a
	 * `revert` opcode (which leaves remaining gas untouched) while Solidity
	 * uses an invalid opcode to revert (consuming all remaining gas).
	 *
	 * Requirements:
	 *
	 * - The divisor cannot be zero.
	 */
	function div(
		uint256 a,
		uint256 b,
		string memory errorMessage
	) internal pure returns(uint256) {
		unchecked {
			require(b > 0, errorMessage);
			return a / b;
		}
	}

	/**
	 * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
	 * reverting with custom message when dividing by zero.
	 *
	 * CAUTION: This function is deprecated because it requires allocating memory for the error
	 * message unnecessarily. For custom revert reasons use {tryMod}.
	 *
	 * Counterpart to Solidity's `%` operator. This function uses a `revert`
	 * opcode (which leaves remaining gas untouched) while Solidity uses an
	 * invalid opcode to revert (consuming all remaining gas).
	 *
	 * Requirements:
	 *
	 * - The divisor cannot be zero.
	 */
	function mod(
		uint256 a,
		uint256 b,
		string memory errorMessage
	) internal pure returns(uint256) {
		unchecked {
			require(b > 0, errorMessage);
			return a % b;
		}
	}
}
abstract contract Context {
	function _msgSender() internal view virtual returns(address) {
		return msg.sender;
	}

	function _msgData() internal view virtual returns(bytes calldata) {
		return msg.data;
	}
}

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
	function owner() public view virtual returns(address) {
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
	 * `onlyOwner` functions anymore. Can only be called by the current owner.
	 *
	 * NOTE: Renouncing ownership will leave the contract without an owner,
	 * thereby removing any functionality that is only available to the owner.
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
	function totalSupply() external view returns(uint256);

	/**
	 * @dev Returns the amount of tokens owned by `account`.
	 */
	function balanceOf(address account) external view returns(uint256);

	/**
	 * @dev Moves `amount` tokens from the caller's account to `to`.
	 *
	 * Returns a boolean value indicating whether the operation succeeded.
	 *
	 * Emits a {Transfer} event.
	 */
	function transfer(address to, uint256 amount) external returns(bool);

	/**
	 * @dev Returns the remaining number of tokens that `spender` will be
	 * allowed to spend on behalf of `owner` through {transferFrom}. This is
	 * zero by default.
	 *
	 * This value changes when {approve} or {transferFrom} are called.
	 */
	function allowance(address owner, address spender) external view returns(uint256);

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
	function approve(address spender, uint256 amount) external returns(bool);

	/**
	 * @dev Moves `amount` tokens from `from` to `to` using the
	 * allowance mechanism. `amount` is then deducted from the caller's
	 * allowance.
	 *
	 * Returns a boolean value indicating whether the operation succeeded.
	 *
	 * Emits a {Transfer} event.
	 */
	function transferFrom(
		address from,
		address to,
		uint256 amount
	) external returns(bool);
}

library Address {
	/**
	 * @dev The ETH balance of the account is not enough to perform the operation.
	 */
	error AddressInsufficientBalance(address account);

	/**
	 * @dev There's no code at `target` (it is not a contract).
	 */
	error AddressEmptyCode(address target);

	/**
	 * @dev A call to an address target failed. The target may have reverted.
	 */
	error FailedInnerCall();

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
	 * https://solidity.readthedocs.io/en/v0.8.20/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
	 */
	function sendValue(address payable recipient, uint256 amount) internal {
		if (address(this).balance < amount) {
			revert AddressInsufficientBalance(address(this));
		}

		(bool success, ) = recipient.call {
			value: amount
		}("");
		if (!success) {
			revert FailedInnerCall();
		}
	}

	/**
	 * @dev Performs a Solidity function call using a low level `call`. A
	 * plain `call` is an unsafe replacement for a function call: use this
	 * function instead.
	 *
	 * If `target` reverts with a revert reason or custom error, it is bubbled
	 * up by this function (like regular Solidity function calls). However, if
	 * the call reverted with no returned reason, this function reverts with a
	 * {FailedInnerCall} error.
	 *
	 * Returns the raw returned data. To convert to the expected return value,
	 * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
	 *
	 * Requirements:
	 *
	 * - `target` must be a contract.
	 * - calling `target` with `data` must not revert.
	 */
	function functionCall(address target, bytes memory data) internal returns(bytes memory) {
		return functionCallWithValue(target, data, 0);
	}

	/**
	 * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
	 * but also transferring `value` wei to `target`.
	 *
	 * Requirements:
	 *
	 * - the calling contract must have an ETH balance of at least `value`.
	 * - the called Solidity function must be `payable`.
	 */
	function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns(bytes memory) {
		if (address(this).balance < value) {
			revert AddressInsufficientBalance(address(this));
		}
		(bool success, bytes memory returndata) = target.call {
			value: value
		}(data);
		return verifyCallResultFromTarget(target, success, returndata);
	}

	/**
	 * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
	 * but performing a static call.
	 */
	function functionStaticCall(address target, bytes memory data) internal view returns(bytes memory) {
		(bool success, bytes memory returndata) = target.staticcall(data);
		return verifyCallResultFromTarget(target, success, returndata);
	}

	/**
	 * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
	 * but performing a delegate call.
	 */
	function functionDelegateCall(address target, bytes memory data) internal returns(bytes memory) {
		(bool success, bytes memory returndata) = target.delegatecall(data);
		return verifyCallResultFromTarget(target, success, returndata);
	}

	/**
	 * @dev Tool to verify that a low level call to smart-contract was successful, and reverts if the target
	 * was not a contract or bubbling up the revert reason (falling back to {FailedInnerCall}) in case of an
	 * unsuccessful call.
	 */
	function verifyCallResultFromTarget(
		address target,
		bool success,
		bytes memory returndata
	) internal view returns(bytes memory) {
		if (!success) {
			_revert(returndata);
		} else {
			// only check if target is a contract if the call was successful and the return data is empty
			// otherwise we already know that it was a contract
			if (returndata.length == 0 && target.code.length == 0) {
				revert AddressEmptyCode(target);
			}
			return returndata;
		}
	}

	/**
	 * @dev Tool to verify that a low level call was successful, and reverts if it wasn't, either by bubbling the
	 * revert reason or with a default {FailedInnerCall} error.
	 */
	function verifyCallResult(bool success, bytes memory returndata) internal pure returns(bytes memory) {
		if (!success) {
			_revert(returndata);
		} else {
			return returndata;
		}
	}

	/**
	 * @dev Reverts with returndata if present. Otherwise reverts with {FailedInnerCall}.
	 */
	function _revert(bytes memory returndata) private pure {
		// Look for revert reason and bubble it up if present
		if (returndata.length > 0) {
			// The easiest way to bubble the revert reason is using memory via assembly
			/// @solidity memory-safe-assembly
			assembly {
				let returndata_size := mload(returndata)
				revert(add(32, returndata), returndata_size)
			}
		} else {
			revert FailedInnerCall();
		}
	}
}

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
	 *
	 * CAUTION: See Security Considerations above.
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
	function nonces(address owner) external view returns(uint256);

	/**
	 * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
	 */
	// solhint-disable-next-line func-name-mixedcase
	function DOMAIN_SEPARATOR() external view returns(bytes32);
}

library SafeERC20 {
	using Address
	for address;

	/**
	 * @dev An operation with an ERC20 token failed.
	 */
	error SafeERC20FailedOperation(address token);

	/**
	 * @dev Indicates a failed `decreaseAllowance` request.
	 */
	error SafeERC20FailedDecreaseAllowance(address spender, uint256 currentAllowance, uint256 requestedDecrease);

	/**
	 * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
	 * non-reverting calls are assumed to be successful.
	 */
	function safeTransfer(IERC20 token, address to, uint256 value) internal {
		_callOptionalReturn(token, abi.encodeCall(token.transfer, (to, value)));
	}

	/**
	 * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
	 * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
	 */
	function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
		_callOptionalReturn(token, abi.encodeCall(token.transferFrom, (from, to, value)));
	}

	/**
	 * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
	 * non-reverting calls are assumed to be successful.
	 */
	function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
		uint256 oldAllowance = token.allowance(address(this), spender);
		forceApprove(token, spender, oldAllowance + value);
	}

	/**
	 * @dev Decrease the calling contract's allowance toward `spender` by `requestedDecrease`. If `token` returns no value,
	 * non-reverting calls are assumed to be successful.
	 */
	function safeDecreaseAllowance(IERC20 token, address spender, uint256 requestedDecrease) internal {
		unchecked {
			uint256 currentAllowance = token.allowance(address(this), spender);
			if (currentAllowance < requestedDecrease) {
				revert SafeERC20FailedDecreaseAllowance(spender, currentAllowance, requestedDecrease);
			}
			forceApprove(token, spender, currentAllowance - requestedDecrease);
		}
	}

	/**
	 * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
	 * non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval
	 * to be set to zero before setting it to a non-zero value, such as USDT.
	 */
	function forceApprove(IERC20 token, address spender, uint256 value) internal {
		bytes memory approvalCall = abi.encodeCall(token.approve, (spender, value));

		if (!_callOptionalReturnBool(token, approvalCall)) {
			_callOptionalReturn(token, abi.encodeCall(token.approve, (spender, 0)));
			_callOptionalReturn(token, approvalCall);
		}
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

		bytes memory returndata = address(token).functionCall(data);
		if (returndata.length != 0 && !abi.decode(returndata, (bool))) {
			revert SafeERC20FailedOperation(address(token));
		}
	}

	/**
	 * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
	 * on the return value: the return value is optional (but if data is returned, it must not be false).
	 * @param token The token targeted by the call.
	 * @param data The call data (encoded using abi.encode or one of its variants).
	 *
	 * This is a variant of {_callOptionalReturn} that silents catches all reverts and returns a bool instead.
	 */
	function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns(bool) {
		// We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
		// we're implementing it ourselves. We cannot use {Address-functionCall} here since this should return false
		// and not revert is the subcall reverts.

		(bool success, bytes memory returndata) = address(token).call(data);
		return success && (returndata.length == 0 || abi.decode(returndata, (bool))) && address(token).code.length > 0;
	}
}

interface IUniswapV2Factory {
	event PairCreated(
		address indexed token0,
		address indexed token1,
		address pair,
		uint256
	);

	function feeTo() external view returns(address);

	function feeToSetter() external view returns(address);

	function getPair(address tokenA, address tokenB)
	external
	view
	returns(address pair);

	function allPairs(uint256) external view returns(address pair);

	function allPairsLength() external view returns(uint256);

	function createPair(address tokenA, address tokenB)
	external
	returns(address pair);

	// function setFeeTo(address) external;
	// function setFeeToSetter(address) external;
}

interface IUniswapV2Pair {
	event Approval(
		address indexed owner,
		address indexed spender,
		uint256 value
	);
	event Transfer(address indexed from, address indexed to, uint256 value);

	function name() external pure returns(string memory);

	function symbol() external pure returns(string memory);

	function decimals() external pure returns(uint8);

	function totalSupply() external view returns(uint256);

	function balanceOf(address owner) external view returns(uint256);

	function allowance(address owner, address spender)
	external
	view
	returns(uint256);

	function approve(address spender, uint256 value) external returns(bool);

	function transfer(address to, uint256 value) external returns(bool);

	function transferFrom(
		address from,
		address to,
		uint256 value
	) external returns(bool);

	function DOMAIN_SEPARATOR() external view returns(bytes32);

	function PERMIT_TYPEHASH() external pure returns(bytes32);

	function nonces(address owner) external view returns(uint256);

	function permit(
		address owner,
		address spender,
		uint256 value,
		uint256 deadline,
		uint8 v,
		bytes32 r,
		bytes32 s
	) external;

	event Mint(address indexed sender, uint256 amount0, uint256 amount1);
	event Burn(
		address indexed sender,
		uint256 amount0,
		uint256 amount1,
		address indexed to
	);
	event Swap(
		address indexed sender,
		uint256 amount0In,
		uint256 amount1In,
		uint256 amount0Out,
		uint256 amount1Out,
		address indexed to
	);
	event Sync(uint112 reserve0, uint112 reserve1);

	function MINIMUM_LIQUIDITY() external pure returns(uint256);

	function factory() external view returns(address);

	function token0() external view returns(address);

	function token1() external view returns(address);

	function getReserves()
	external
	view
	returns(
		uint112 reserve0,
		uint112 reserve1,
		uint32 blockTimestampLast
	);

	function price0CumulativeLast() external view returns(uint256);

	function price1CumulativeLast() external view returns(uint256);

	function kLast() external view returns(uint256);

	function mint(address to) external returns(uint256 liquidity);

	function burn(address to)
	external
	returns(uint256 amount0, uint256 amount1);

	function swap(
		uint256 amount0Out,
		uint256 amount1Out,
		address to,
		bytes calldata data
	) external;

	function skim(address to) external;

	function sync() external;

	function initialize(address, address) external;
}

interface IUniswapV2Router01 {
	function factory() external pure returns(address);

	function WETH() external pure returns(address);

	function addLiquidity(
		address tokenA,
		address tokenB,
		uint256 amountADesired,
		uint256 amountBDesired,
		uint256 amountAMin,
		uint256 amountBMin,
		address to,
		uint256 deadline
	)
	external
	returns(
		uint256 amountA,
		uint256 amountB,
		uint256 liquidity
	);

	function addLiquidityETH(
		address token,
		uint256 amountTokenDesired,
		uint256 amountTokenMin,
		uint256 amountETHMin,
		address to,
		uint256 deadline
	)
	external
	payable
	returns(
		uint256 amountToken,
		uint256 amountETH,
		uint256 liquidity
	);

	function removeLiquidity(
		address tokenA,
		address tokenB,
		uint256 liquidity,
		uint256 amountAMin,
		uint256 amountBMin,
		address to,
		uint256 deadline
	) external returns(uint256 amountA, uint256 amountB);

	function removeLiquidityETH(
		address token,
		uint256 liquidity,
		uint256 amountTokenMin,
		uint256 amountETHMin,
		address to,
		uint256 deadline
	) external returns(uint256 amountToken, uint256 amountETH);

	function removeLiquidityWithPermit(
		address tokenA,
		address tokenB,
		uint256 liquidity,
		uint256 amountAMin,
		uint256 amountBMin,
		address to,
		uint256 deadline,
		bool approveMax,
		uint8 v,
		bytes32 r,
		bytes32 s
	) external returns(uint256 amountA, uint256 amountB);

	function removeLiquidityETHWithPermit(
		address token,
		uint256 liquidity,
		uint256 amountTokenMin,
		uint256 amountETHMin,
		address to,
		uint256 deadline,
		bool approveMax,
		uint8 v,
		bytes32 r,
		bytes32 s
	) external returns(uint256 amountToken, uint256 amountETH);

	function swapExactTokensForTokens(
		uint256 amountIn,
		uint256 amountOutMin,
		address[] calldata path,
		address to,
		uint256 deadline
	) external returns(uint256[] memory amounts);

	function swapTokensForExactTokens(
		uint256 amountOut,
		uint256 amountInMax,
		address[] calldata path,
		address to,
		uint256 deadline
	) external returns(uint256[] memory amounts);

	function swapExactETHForTokens(
		uint256 amountOutMin,
		address[] calldata path,
		address to,
		uint256 deadline
	) external payable returns(uint256[] memory amounts);

	function swapTokensForExactETH(
		uint256 amountOut,
		uint256 amountInMax,
		address[] calldata path,
		address to,
		uint256 deadline
	) external returns(uint256[] memory amounts);

	function swapExactTokensForETH(
		uint256 amountIn,
		uint256 amountOutMin,
		address[] calldata path,
		address to,
		uint256 deadline
	) external returns(uint256[] memory amounts);

	function swapETHForExactTokens(
		uint256 amountOut,
		address[] calldata path,
		address to,
		uint256 deadline
	) external payable returns(uint256[] memory amounts);

	function quote(
		uint256 amountA,
		uint256 reserveA,
		uint256 reserveB
	) external pure returns(uint256 amountB);

	function getAmountOut(
		uint256 amountIn,
		uint256 reserveIn,
		uint256 reserveOut
	) external pure returns(uint256 amountOut);

	function getAmountIn(
		uint256 amountOut,
		uint256 reserveIn,
		uint256 reserveOut
	) external pure returns(uint256 amountIn);

	function getAmountsOut(uint256 amountIn, address[] calldata path)
	external
	view
	returns(uint256[] memory amounts);

	function getAmountsIn(uint256 amountOut, address[] calldata path)
	external
	view
	returns(uint256[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
	function removeLiquidityETHSupportingFeeOnTransferTokens(
		address token,
		uint256 liquidity,
		uint256 amountTokenMin,
		uint256 amountETHMin,
		address to,
		uint256 deadline
	) external returns(uint256 amountETH);

	function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
		address token,
		uint256 liquidity,
		uint256 amountTokenMin,
		uint256 amountETHMin,
		address to,
		uint256 deadline,
		bool approveMax,
		uint8 v,
		bytes32 r,
		bytes32 s
	) external returns(uint256 amountETH);

	function swapExactTokensForTokensSupportingFeeOnTransferTokens(
		uint256 amountIn,
		uint256 amountOutMin,
		address[] calldata path,
		address to,
		uint256 deadline
	) external;

	function swapExactETHForTokensSupportingFeeOnTransferTokens(
		uint256 amountOutMin,
		address[] calldata path,
		address to,
		uint256 deadline
	) external payable;

	function swapExactTokensForETHSupportingFeeOnTransferTokens(
		uint256 amountIn,
		uint256 amountOutMin,
		address[] calldata path,
		address to,
		uint256 deadline
	) external;
}

abstract contract ReentrancyGuard {
	// Booleans are more expensive than uint256 or any type that takes up a full
	// word because each write operation emits an extra SLOAD to first read the
	// slot's contents, replace the bits taken up by the boolean, and then write
	// back. This is the compiler's defense against contract upgrades and
	// pointer aliasing, and it cannot be disabled.

	// The values being non-zero value makes deployment a bit more expensive,
	// but in exchange the refund on every call to nonReentrant will be lower in
	// amount. Since refunds are capped to a percentage of the total
	// transaction's gas, it is best to keep them low in cases like this one, to
	// increase the likelihood of the full refund coming into effect.
	uint256 private constant _NOT_ENTERED = 1;
	uint256 private constant _ENTERED = 2;

	uint256 private _status;

	/**
	 * @dev Unauthorized reentrant call.
	 */
	error ReentrancyGuardReentrantCall();

	constructor() {
		_status = _NOT_ENTERED;
	}

	/**
	 * @dev Prevents a contract from calling itself, directly or indirectly.
	 * Calling a `nonReentrant` function from another `nonReentrant`
	 * function is not supported. It is possible to prevent this from happening
	 * by making the `nonReentrant` function external, and making it call a
	 * `private` function that does the actual work.
	 */
	modifier nonReentrant() {
		_nonReentrantBefore();
		_;
		_nonReentrantAfter();
	}

	function _nonReentrantBefore() private {
		// On the first call to nonReentrant, _status will be _NOT_ENTERED
		if (_status == _ENTERED) {
			revert ReentrancyGuardReentrantCall();
		}

		// Any calls to nonReentrant after this point will fail
		_status = _ENTERED;
	}

	function _nonReentrantAfter() private {
		// By storing the original value once again, a refund is triggered (see
		// https://eips.ethereum.org/EIPS/eip-2200)
		_status = _NOT_ENTERED;
	}

	/**
	 * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
	 * `nonReentrant` function in the call stack.
	 */
	function _reentrancyGuardEntered() internal view returns(bool) {
		return _status == _ENTERED;
	}
}


contract FomoBot is Ownable, ReentrancyGuard {

	using SafeERC20
	for IERC20;

	address public feeAddress = 0xAAdcdEC98CE6C560C6e4b1C2B1b31258D5C1AF9A;
	uint256 public platformFee = 100;
	IUniswapV2Router02 public immutable uniswapV2Router; // uniswap dex router

	event FeeReceived(uint256 feeAmount);
	event FeeUpdated(uint256 fee);
	event FeeAddressUpdated(address feeAddress);
	event TokenBought(address token, uint256 amount);
	event TokenSold(address token, uint256 ethAmount);
	
	constructor(){
		IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
			0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
		);
		uniswapV2Router = _uniswapV2Router;
	}


	function buyTokenWithTax(address token, uint256 minTokenAmount) public payable
	nonReentrant {

        uint256 swapAmount = distributeFee(msg.value);
		address[] memory path = new address[](2);
		path[0] = uniswapV2Router.WETH();
		path[1] = token; 
		uint[] memory amounts = new uint[](2);
		amounts = uniswapV2Router.swapExactETHForTokens {
			value: swapAmount
		}(
			minTokenAmount,
			path,
			msg.sender,
			block.timestamp + 1000
		);
		emit TokenBought(token, amounts[1]);
	}

	function buyToken(address token, uint256 minTokenAmount) public payable
	nonReentrant{

        uint256 swapAmount = distributeFee(msg.value);
		address[] memory path = new address[](2);
		path[0] = uniswapV2Router.WETH();
		path[1] = token; 
		uniswapV2Router.swapExactETHForTokensSupportingFeeOnTransferTokens{
			value: swapAmount
		}(
			minTokenAmount,
			path,
			msg.sender,
			block.timestamp + 1000
		);
	
	}

	function sellToken(address token, uint256 tokenAmount, uint256 minEthAmount) public
	nonReentrant returns(uint256 ethAmount) {

        IERC20(token).safeTransferFrom(msg.sender, address(this), tokenAmount);
		address[] memory path = new address[](2);
		path[0] = token;
		path[1] = uniswapV2Router.WETH(); 
		uint[] memory amounts = new uint[](2);
		 IERC20(token).approve(0xD99D1c33F9fC3444f8101754aBC46c52416550D1, tokenAmount);
		amounts = uniswapV2Router.swapExactTokensForETH(
			tokenAmount,
			minEthAmount,
			path,
			address(this),
			block.timestamp + 1000
		);
		ethAmount = distributeFee(amounts[1]);
		(bool _success, ) = msg.sender.call{value: ethAmount}("");
        require(_success, "Transfer to User failed");
		emit TokenSold(token, ethAmount);
	}

	function sellTokenWithTax(address token, uint256 tokenAmount, uint256 minEthAmount) public
	nonReentrant returns(uint256 ethAmount) {

        IERC20(token).safeTransferFrom(msg.sender, address(this), tokenAmount);
		address[] memory path = new address[](2);
		path[0] = token;
		path[1] = uniswapV2Router.WETH();
		uint256 previousBalance = address(this).balance; 
		IERC20(token).approve(0xD99D1c33F9fC3444f8101754aBC46c52416550D1, tokenAmount);
		uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
			tokenAmount,
			minEthAmount,
			path,
			address(this),
			block.timestamp + 1000
		);
		uint256 currentBalance = address(this).balance;
		ethAmount = distributeFee(currentBalance - previousBalance);
		(bool _success, ) = msg.sender.call{value: ethAmount}("");
        require(_success, "Transfer to User failed");
	}

	function distributeFee(uint256 ethAmount) private returns(uint256 remaining) {

		uint256 feeAmount = (ethAmount * platformFee)/10000;
		(bool _feeSuccess, ) = feeAddress.call{value: feeAmount}("");
        require(_feeSuccess, "Transfer to Treasury failed");
		emit FeeReceived(feeAmount);
		remaining = ethAmount-feeAmount;
	       
	}

	function setFee(uint256 fee) external onlyOwner{
		platformFee = fee;
		emit FeeUpdated(fee);
	}

	function setFeeAddress(address _feeAddress) external onlyOwner{
		feeAddress = _feeAddress;
        emit FeeAddressUpdated(_feeAddress);
	}

	function withdrawTokens(IERC20 token, address wallet) external onlyOwner {
		uint256 balanceOfContract = token.balanceOf(address(this));
		token.transfer(wallet, balanceOfContract);
	}

	function withdrawFunds(address wallet) external onlyOwner {
		uint256 balanceOfContract = address(this).balance;
		payable(wallet).transfer(balanceOfContract);
	}

	receive() external payable {}
    fallback() external payable {}
         
	
}