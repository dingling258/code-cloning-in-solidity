// SPDX-License-Identifier: UNLICENSED
// File: @openzeppelin/contracts/interfaces/draft-IERC6093.sol


// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/draft-IERC6093.sol)
pragma solidity ^0.8.20;

/**
 * @dev Standard ERC20 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC20 tokens.
 */
interface IERC20Errors {
    /**
     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC20InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC20InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `spender`’s `allowance`. Used in transfers.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     * @param allowance Amount of tokens a `spender` is allowed to operate with.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC20InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `spender` to be approved. Used in approvals.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC20InvalidSpender(address spender);
}

/**
 * @dev Standard ERC721 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC721 tokens.
 */
interface IERC721Errors {
    /**
     * @dev Indicates that an address can't be an owner. For example, `address(0)` is a forbidden owner in EIP-20.
     * Used in balance queries.
     * @param owner Address of the current owner of a token.
     */
    error ERC721InvalidOwner(address owner);

    /**
     * @dev Indicates a `tokenId` whose `owner` is the zero address.
     * @param tokenId Identifier number of a token.
     */
    error ERC721NonexistentToken(uint256 tokenId);

    /**
     * @dev Indicates an error related to the ownership over a particular token. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param tokenId Identifier number of a token.
     * @param owner Address of the current owner of a token.
     */
    error ERC721IncorrectOwner(address sender, uint256 tokenId, address owner);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC721InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC721InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `operator`’s approval. Used in transfers.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     * @param tokenId Identifier number of a token.
     */
    error ERC721InsufficientApproval(address operator, uint256 tokenId);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC721InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `operator` to be approved. Used in approvals.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC721InvalidOperator(address operator);
}

/**
 * @dev Standard ERC1155 Errors
 * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC1155 tokens.
 */
interface IERC1155Errors {
    /**
     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     * @param tokenId Identifier number of a token.
     */
    error ERC1155InsufficientBalance(address sender, uint256 balance, uint256 needed, uint256 tokenId);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC1155InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC1155InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `operator`’s approval. Used in transfers.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     * @param owner Address of the current owner of a token.
     */
    error ERC1155MissingApprovalForAll(address operator, address owner);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC1155InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `operator` to be approved. Used in approvals.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC1155InvalidOperator(address operator);

    /**
     * @dev Indicates an array length mismatch between ids and values in a safeBatchTransferFrom operation.
     * Used in batch transfers.
     * @param idsLength Length of the array of token identifiers
     * @param valuesLength Length of the array of token amounts
     */
    error ERC1155InvalidArrayLength(uint256 idsLength, uint256 valuesLength);
}

// File: @openzeppelin/contracts/utils/ReentrancyGuard.sol


// OpenZeppelin Contracts (last updated v5.0.0) (utils/ReentrancyGuard.sol)

pragma solidity ^0.8.20;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
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
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    uint256 private _status;

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

    constructor() {
        _status = NOT_ENTERED;
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
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        if (_status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        _status = ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == ENTERED;
    }
}

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;

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

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
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
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
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
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
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

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

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
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
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
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol


// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.20;


/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// File: @openzeppelin/contracts/token/ERC20/ERC20.sol


// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.20;





/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * The default value of {decimals} is 18. To change this, you should override
 * this function so it returns a different value.
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 */
abstract contract ERC20 is Context, IERC20, IERC20Metadata, IERC20Errors {
    mapping(address account => uint256) private _balances;

    mapping(address account => mapping(address spender => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the default value returned by this function, unless
     * it's overridden.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `value`.
     */
    function transfer(address to, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, value);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `value` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, value);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `value`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `value`.
     */
    function transferFrom(address from, address to, uint256 value) public virtual returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _transfer(address from, address to, uint256 value) internal {
        if (from == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (to == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(from, to, value);
    }

    /**
     * @dev Transfers a `value` amount of tokens from `from` to `to`, or alternatively mints (or burns) if `from`
     * (or `to`) is the zero address. All customizations to transfers, mints, and burns should be done by overriding
     * this function.
     *
     * Emits a {Transfer} event.
     */
    function _update(address from, address to, uint256 value) internal virtual {
        if (from == address(0)) {
            // Overflow check required: The rest of the code assumes that totalSupply never overflows
            _totalSupply += value;
        } else {
            uint256 fromBalance = _balances[from];
            if (fromBalance < value) {
                revert ERC20InsufficientBalance(from, fromBalance, value);
            }
            unchecked {
                // Overflow not possible: value <= fromBalance <= totalSupply.
                _balances[from] = fromBalance - value;
            }
        }

        if (to == address(0)) {
            unchecked {
                // Overflow not possible: value <= totalSupply or value <= fromBalance <= totalSupply.
                _totalSupply -= value;
            }
        } else {
            unchecked {
                // Overflow not possible: balance + value is at most totalSupply, which we know fits into a uint256.
                _balances[to] += value;
            }
        }

        emit Transfer(from, to, value);
    }

    /**
     * @dev Creates a `value` amount of tokens and assigns them to `account`, by transferring it from address(0).
     * Relies on the `_update` mechanism
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _mint(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(address(0), account, value);
    }

    /**
     * @dev Destroys a `value` amount of tokens from `account`, lowering the total supply.
     * Relies on the `_update` mechanism.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead
     */
    function _burn(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        _update(account, address(0), value);
    }

    /**
     * @dev Sets `value` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     *
     * Overrides to this logic should be done to the variant with an additional `bool emitEvent` argument.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        _approve(owner, spender, value, true);
    }

    /**
     * @dev Variant of {_approve} with an optional flag to enable or disable the {Approval} event.
     *
     * By default (when calling {_approve}) the flag is set to true. On the other hand, approval changes made by
     * `_spendAllowance` during the `transferFrom` operation set the flag to false. This saves gas by not emitting any
     * `Approval` event during `transferFrom` operations.
     *
     * Anyone who wishes to continue emitting `Approval` events on the`transferFrom` operation can force the flag to
     * true using the following override:
     * ```
     * function _approve(address owner, address spender, uint256 value, bool) internal virtual override {
     *     super._approve(owner, spender, value, true);
     * }
     * ```
     *
     * Requirements are the same as {_approve}.
     */
    function _approve(address owner, address spender, uint256 value, bool emitEvent) internal virtual {
        if (owner == address(0)) {
            revert ERC20InvalidApprover(address(0));
        }
        if (spender == address(0)) {
            revert ERC20InvalidSpender(address(0));
        }
        _allowances[owner][spender] = value;
        if (emitEvent) {
            emit Approval(owner, spender, value);
        }
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `value`.
     *
     * Does not update the allowance value in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Does not emit an {Approval} event.
     */
    function _spendAllowance(address owner, address spender, uint256 value) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < value) {
                revert ERC20InsufficientAllowance(spender, currentAllowance, value);
            }
            unchecked {
                _approve(owner, spender, currentAllowance - value, false);
            }
        }
    }
}

// File: LikeBit/LikeBit.sol


pragma solidity ^0.8.19;



/**
 * @title LikeBitToken
 * @dev ERC20 token implementation with additional functionalities.
 */

contract LikeBit is ERC20, Ownable {
    uint public PRIVATE_SALE_ALLOCATION = 1000000 * 10 ** 18;
    uint public PRESALE_ALLOCATION = 1000000 * 10 ** 18;
    uint public EXCHANGES_ALLOCATION = 5500000 * 10 ** 18;
    uint public COMPANY_ALLOCATION = 2000000 * 10 ** 18;
    uint public ADVERTISEMENTS_ALLOCATION = 500000 * 10 ** 18;
    address public preSale;

    /**
     * @dev Constructor function to initialize the LikeBitToken contract.
     * @param _preSale Address of the pre-sale.
     * @param owner Address of the contract owner.
     */

    constructor(
        address _preSale,
        address owner
    ) Ownable(owner) ERC20("LikeBitToken", "LBT") {
        preSale = _preSale;
        _mint(preSale, PRESALE_ALLOCATION + PRIVATE_SALE_ALLOCATION);
        _mint(
            address(this),
            COMPANY_ALLOCATION +
                EXCHANGES_ALLOCATION +
                ADVERTISEMENTS_ALLOCATION
        );
    }

    /**
     * @dev Function to withdraw mistakenly sent ERC20 tokens.
     * @param _token Address of the ERC20 token to withdraw.
     */

    function withdrawTokens(address _token) external onlyOwner {
        require(_token != address(0), "Invalid token address");
        IERC20(_token).transfer(
            msg.sender,
            IERC20(_token).balanceOf(address(this))
        );
    }
}

// File: LikeBit/PreSale.sol


pragma solidity ^0.8.19;





/**
 * @title PreSale
 * @dev Contract for managing pre-sale of LikeBit tokens.
 */

contract PreSale is Ownable, ReentrancyGuard {
    IERC20 private usdt;
    IERC20 private LBT;
    uint private totalTokenSold;
    uint private totalTokenRemaining;
    uint private activePhaseId;
    uint public totalPhases;
    address private adminWallet;

    struct Phase {
        uint phaseId;
        uint tokenAvailableForSale;
        uint tokenPrice;
        uint tokenSold;
        uint soldTokenValue;
        bool airdrop;
        bool buying;
    }

    struct TokenPurchase {
        uint usdtDeposited;
        uint tokensBought;
        uint tokenPrice;
        uint phaseId;
        uint date;
        bool claimed;
    }

    mapping(address => uint) private usdtReceived;
    mapping(address => mapping(uint => uint)) private tokenToSend;
    mapping(uint => Phase) private phases;
    mapping(address => TokenPurchase[]) private tokenPurchase;
    mapping(address => bool) private blacklisted;

    modifier notBlacklisted() {
        require(
            !blacklisted[msg.sender],
            "Address is blacklisted. Contact Admin"
        );
        _;
    }

    event ClaimedTokens(
        address indexed _user,
        uint usdtDeposited,
        uint tokenAmount,
        uint tokenPrice,
        uint PhaseID
    );

    event NewPhaseSet(
        uint PhaseID,
        uint tokenAvailableForSell,
        uint tokenPrice
    );

    event Buy(
        address indexed _user,
        uint usdtDeposited,
        uint tokenAmount,
        uint tokenPrice,
        uint PhaseID
    );

    /**
     * @dev Constructor to initialize the pre-sale contract.
     * @param _usdt Address of the USDT token contract.
     * @param _admin Address of the admin wallet.
     */

    constructor(address _usdt, address _admin) Ownable(_admin) {
        usdt = IERC20(_usdt);
        totalTokenSold = 0;
        totalTokenRemaining = 2000000 * 10 ** 18;
        adminWallet = _admin;
        phases[1] = Phase({
            phaseId: 1,
            tokenAvailableForSale: 500000 * 10 ** 18,
            tokenPrice: 1250000,
            tokenSold: 0,
            soldTokenValue: 0,
            airdrop: false,
            buying: true
        });
        activePhaseId = 1;
        totalPhases++;
    }

    //View Functions

    /**
     * @dev Returns the address of the USDT token contract.
     */

    function getUsdtAddress() external view returns (address) {
        return address(usdt);
    }
    /**
     * @dev Returns the address of the LikeBit token contract.
     */

    function getTokenAddress() external view returns (address) {
        return address(LBT);
    }
    /**
     * @dev Returns the current token price for the active phase.
     */
    function getTokenPrice() public view returns (uint) {
        return phases[activePhaseId].tokenPrice;
    }

    /**
     * @dev Returns the address of the admin wallet.
     */

    function getAdminAddress() external view returns (address) {
        return adminWallet;
    }

    /**
     * @dev Returns the ID of the active sale phase.
     */

    function getActivePhase() external view returns (uint) {
        return activePhaseId;
    }

    /**
     * @dev Returns the total number of tokens sold.
     */
    function getTotalTokenSold() external view returns (uint) {
        return totalTokenSold;
    }

    function getOwner() external view returns (address) {
        return owner();
    }

    /**
     * @dev Checks if an address is blacklisted.
     * @param _user Address to check.
     * @return True if the address is blacklisted, otherwise false.
     */
    function isBlacklisted(address _user) external view returns (bool) {
        return blacklisted[_user];
    }

    /**
     * @dev Returns details of the purchases made by a user.
     * @param _user Address of the user.
     * @return tokensBought Array of token amounts bought.
     * @return phaseId Array of phase IDs for each purchase.
     * @return date Array of purchase dates.
     * @return claimed Array indicating whether tokens are claimed for each purchase.
     */

    function getUserPurchaseDetails(
        address _user
    )
        external
        view
        returns (
            uint[] memory tokensBought,
            uint[] memory phaseId,
            uint[] memory date,
            bool[] memory claimed
        )
    {
        TokenPurchase[] storage purchase = tokenPurchase[_user];
        uint length = purchase.length;
        tokensBought = new uint[](length);
        phaseId = new uint[](length);
        date = new uint[](length);
        claimed = new bool[](length);

        for (uint i = 0; i < length; i++) {
            tokensBought[i] = purchase[i].tokensBought;
            phaseId[i] = purchase[i].phaseId;
            date[i] = purchase[i].date;
            claimed[i] = purchase[i].claimed;
        }
        return (tokensBought, phaseId, date, claimed);
    }

    /**
     * @dev Checks if airdrop is active for a given phase.
     * @param _phaseId ID of the phase to check.
     * @return True if airdrop is active for the phase, otherwise false.
     */
    function isAirdropActive(uint _phaseId) external view returns (bool) {
        require(_phaseId > 0 && _phaseId <= totalPhases, "Invalid phase ID");
        Phase storage phase = phases[_phaseId];
        return phase.airdrop;
    }

    /**
     * @dev Checks if buying is active for a given phase.
     * @param _phaseId ID of the phase to check.
     * @return True if buying is active for the phase, otherwise false.
     */

    function isBuyActive(uint _phaseId) external view returns (bool) {
        require(_phaseId > 0 && _phaseId <= totalPhases, "Invalid phase ID");
        Phase storage phase = phases[_phaseId];
        return phase.buying;
    }

    /**
     * @dev Returns information about a sale phase.
     * @param _phaseId ID of the phase.
     * @return phaseId Phase ID.
     * @return _tokenAvailableForSale Total tokens available for sale.
     * @return _tokenPrice Token price.
     * @return _tokenSold Total tokens sold.
     * @return _soldTokenValue Total value of tokens sold.
     * @return _tokenRemaining Remaining tokens for sale in the phase.
     * @return isActivePhase True if the phase is active, otherwise false.
     * @return airdrop True if airdrop is active for the phase, otherwise false.
     * @return buying True if buying is active for the phase, otherwise false.
     */
    function getPhaseInfo(
        uint _phaseId
    )
        public
        view
        returns (
            uint phaseId,
            uint _tokenAvailableForSale,
            uint _tokenPrice,
            uint _tokenSold,
            uint _soldTokenValue,
            uint _tokenRemaining,
            bool isActivePhase,
            bool airdrop,
            bool buying
        )
    {
        require(_phaseId > 0);
        Phase storage phase = phases[_phaseId];
        return (
            phase.phaseId,
            phase.tokenAvailableForSale,
            phase.tokenPrice,
            phase.tokenSold,
            phase.soldTokenValue,
            phase.tokenAvailableForSale - phase.tokenSold,
            activePhaseId == phase.phaseId,
            phase.airdrop,
            phase.buying
        );
    }

    function addToBlacklist(address _user) external onlyOwner {
        require(_user != address(0), "Invalid address");
        blacklisted[_user] = true;
    }

    function removeFromBlacklist(address _user) external onlyOwner {
        blacklisted[_user] = false;
    }

    /**
     * @dev Sets a new sale phase with the given parameters.
     * @param _amount Amount of tokens available for sale in the new phase.
     * @param _tokenPrice Price of one token in the new phase.
     */

    function setPhase(uint _amount, uint _tokenPrice) external onlyOwner {
        uint _phaseId = totalPhases + 1;
        require(_amount > 0, "Amount cannot be zero");
        require(
            _amount <= totalTokenRemaining,
            "Amount cannot exceed sale allocation"
        );
        require(_tokenPrice > 0, "token price cannot be zero");

        Phase storage newPhase = phases[_phaseId];
        newPhase.phaseId = _phaseId;
        newPhase.tokenAvailableForSale = _amount;
        newPhase.tokenPrice = _tokenPrice;
        newPhase.tokenSold = 0;
        newPhase.soldTokenValue = 0;
        newPhase.airdrop = false;
        newPhase.buying = false;
        totalPhases++;

        emit NewPhaseSet(_phaseId, _amount, _tokenPrice);
    }

    function stopBuy(uint _phaseId) external onlyOwner {
        require(_phaseId > 0 && _phaseId <= totalPhases, "Invalid phase ID");
        Phase storage phase = phases[_phaseId];
        require(phase.phaseId == _phaseId, "Phase does not exist");
        require(phase.buying == true, "Buy not active");
        phase.buying = false;
    }

    function startBuy(uint _phaseId) external onlyOwner {
        require(_phaseId > 0 && _phaseId <= totalPhases, "Invalid phase ID");
        Phase storage phase = phases[_phaseId];
        require(phase.phaseId == _phaseId, "Phase does not exist");
        require(phase.buying == false, "Buy already active");
        phase.buying = true;
    }

    function estimatedToken(
        uint _usdtAmount
    ) public view returns (uint tokenAmount) {
        tokenAmount = (_usdtAmount * 10 ** 18) / getTokenPrice();
    }

    function getUSDTDepositedByUser(
        address _user
    ) external view returns (uint) {
        return usdtReceived[_user];
    }

    function getTokenToSendToUser(address _user) external view returns (uint) {
        return tokenToSend[_user][activePhaseId];
    }

    function setTokenAddress(address _LBT) external onlyOwner {
        require(_LBT != address(0), "Address cannot be zero address");
        require(
            IERC20(_LBT).balanceOf(address(this)) > 0,
            "Invalid LBT contract"
        );
        LBT = IERC20(_LBT);
    }

    function setActivePhase(uint _phaseId) external onlyOwner {
        require(_phaseId > 0 && totalPhases >= _phaseId, "Inavlid phase id");
        require(_phaseId != activePhaseId, "Phase already active");
        activePhaseId = _phaseId;
    }

    function setAdminWallet(address _admin) external onlyOwner {
        require(_admin != address(0), "Address cannot be zero address");
        adminWallet = _admin;
    }

    /**
     * @dev Starts the airdrop for the specified phase.
     * @param _phaseId ID of the phase to start the airdrop for.
     */

    function startAirDrop(uint _phaseId) external onlyOwner {
        require(_phaseId > 0 && _phaseId <= totalPhases, "Invalid phase ID");
        Phase storage phase = phases[_phaseId];
        require(phase.phaseId == _phaseId, "Phase id does not exist");
        require(phase.airdrop == false, "Air drop already active");
        phase.airdrop = true;
    }

    /**
     * @dev Stops the airdrop for the specified phase.
     * @param _phaseId ID of the phase to stop the airdrop for.
     */
    function stopAirDrop(uint _phaseId) external onlyOwner {
        require(_phaseId > 0 && _phaseId <= totalPhases, "Invalid phase ID");
        Phase storage phase = phases[_phaseId];
        require(phase.phaseId == _phaseId, "Phase id does not exist");
        require(phase.airdrop == true, "Air drop not active");
        phase.airdrop = false;
    }

    //User Functions
    /**
     * @dev Allows a user to buy tokens with USDT.
     * @param _usdtAmount Amount of USDT to spend for buying tokens.
     */
    function buy(uint _usdtAmount) external nonReentrant notBlacklisted {
        require(_usdtAmount > 0, "Invalid Amount");
        require(
            usdt.allowance(msg.sender, address(this)) >= _usdtAmount,
            "Insufficient Allowance"
        );
        require(
            usdt.balanceOf(msg.sender) >= _usdtAmount,
            "Not enough balance"
        );

        Phase storage currentPhase = phases[activePhaseId];
        require(
            currentPhase.buying == true,
            "Buying not active for this phase"
        );
        uint tokenAmount = ((_usdtAmount * (10 ** 18)) /
            currentPhase.tokenPrice);

        require(
            tokenAmount <=
                currentPhase.tokenAvailableForSale - currentPhase.tokenSold,
            "Not enough token amount for buying"
        );

        currentPhase.tokenSold += tokenAmount;
        currentPhase.soldTokenValue =
            (currentPhase.tokenPrice * currentPhase.tokenSold) /
            10 ** 18;
        totalTokenSold += tokenAmount;
        totalTokenRemaining -= totalTokenSold;

        usdtReceived[msg.sender] += _usdtAmount;
        tokenToSend[msg.sender][activePhaseId] += tokenAmount;

        usdt.transferFrom(msg.sender, adminWallet, _usdtAmount);

        TokenPurchase[] storage purchase = tokenPurchase[msg.sender];
        purchase.push(
            TokenPurchase({
                usdtDeposited: _usdtAmount,
                tokensBought: tokenAmount,
                tokenPrice: currentPhase.tokenPrice,
                phaseId: activePhaseId,
                date: block.timestamp,
                claimed: false
            })
        );

        emit Buy(
            msg.sender,
            _usdtAmount,
            tokenAmount,
            currentPhase.tokenPrice,
            activePhaseId
        );
    }

    /**
     * @dev Allows a user to claim tokens from an ongoing airdrop.
     * @param _phaseId ID of the phase from which tokens are claimed.
     * @param _index Index of the token purchase to claim from the user's purchase history.
     */

    function claimToken(
        uint _phaseId,
        uint _index
    ) external nonReentrant notBlacklisted {
        require(_phaseId > 0 && totalPhases >= _phaseId, "Inavlid phase id");
        Phase storage phase = phases[_phaseId];
        require(phase.airdrop, "Airdrop not started");
        TokenPurchase[] storage purchase = tokenPurchase[msg.sender];
        uint totalTokensClaimed;

        require(_index < purchase.length, "Invalid index");

        for (uint i = _index; i < purchase.length; i++) {
            if (purchase[i].phaseId == _phaseId && !purchase[i].claimed) {
                uint tokensToClaim = purchase[i].tokensBought;
                LBT.transfer(msg.sender, tokensToClaim);
                purchase[i].claimed = true;
                totalTokensClaimed += tokensToClaim;
                emit ClaimedTokens(
                    msg.sender,
                    purchase[i].usdtDeposited,
                    tokensToClaim,
                    purchase[i].tokenPrice,
                    _phaseId
                );
                return;
            }
        }
        require(totalTokensClaimed > 0, "No tokens to claim in this phase");
    }

    /**
     * @dev Function to withdraw mistakenly sent ERC20 tokens.
     * @param _token Address of the ERC20 token to withdraw.
     */

    function withdrawTokens(address _token) external onlyOwner {
        require(_token != address(0), "Invalid token address");
        IERC20(_token).transfer(
            msg.sender,
            IERC20(_token).balanceOf(address(this))
        );
    }
}