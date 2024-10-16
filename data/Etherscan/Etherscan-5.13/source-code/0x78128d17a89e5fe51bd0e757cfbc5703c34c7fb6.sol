/*
  _____  _      _____  _   _  _    _  _____ ______  _____ ______  _   _ ___  _________ 
|  ___|| |    |  _  || \ | || |  | ||_   _||  ___||_   _|| ___ \| | | ||  \/  || ___ \
| |__  | |    | | | ||  \| || |  | |  | |  | |_     | |  | |_/ /| | | || .  . || |_/ /
|  __| | |    | | | || . ` || |/\| |  | |  |  _|    | |  |    / | | | || |\/| ||  __/ 
| |___ | |____\ \_/ /| |\  |\  /\  / _| |_ | |      | |  | |\ \ | |_| || |  | || |    
\____/ \_____/ \___/ \_| \_/ \/  \/  \___/ \_|      \_/  \_| \_| \___/ \_|  |_/\_|    
                                                                                      
Join The Revolution!
Let’s Make America Great Again!                                                                 
                                                                                                                                                                         
Website: https://http://elonwiftrump.us/
Twitter: https://x.com/ElonWifTrump
Telegram: https://t.me/ElonWifTrumpeth
*/

// SPDX-License-Identifier: MIT
// File: contracts/interfaces/IUniswapV2Factory.sol



pragma solidity 0.8.23;

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);

    function createPair(address tokenA, address tokenB) external returns (address pair);
}

// File: contracts/interfaces/IUniswapV2Router.sol



pragma solidity 0.8.23;

interface IUniswapV2Router {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
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
}

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
    function _transfer(address from, address to, uint256 value) internal virtual {
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

// File: contracts/ELONWIFTRUMP.sol

/*
  _____  _      _____  _   _  _    _  _____ ______  _____ ______  _   _ ___  _________ 
|  ___|| |    |  _  || \ | || |  | ||_   _||  ___||_   _|| ___ \| | | ||  \/  || ___ \
| |__  | |    | | | ||  \| || |  | |  | |  | |_     | |  | |_/ /| | | || .  . || |_/ /
|  __| | |    | | | || . ` || |/\| |  | |  |  _|    | |  |    / | | | || |\/| ||  __/ 
| |___ | |____\ \_/ /| |\  |\  /\  / _| |_ | |      | |  | |\ \ | |_| || |  | || |    
\____/ \_____/ \___/ \_| \_/ \/  \/  \___/ \_|      \_/  \_| \_| \___/ \_|  |_/\_|    
                                                                                      
Join The Revolution!
Let’s Make America Great Again!                                                                 
                                                                                                                                                                         
Website: https://http://elonwiftrump.us/
Twitter: https://x.com/ElonWifTrump
Telegram: https://t.me/ElonWifTrumpeth
*/

pragma solidity 0.8.23;





contract ELONWIFTRUMP is ERC20, Ownable {
    address public marketingWallet;
    uint16 public buyFee = 0;
    uint16 public sellFee = 0;
    uint256 public swapTokensAtAmount = 34_736 * 1e18; // 0.05% 
    bool private _distributingFees;

    mapping(address => bool) private _excludedFromFees;

    bool public limitsInEffect = true;
    uint256 public maxWalletBalance = 1_389_440 * 1e18; // 2% 
    mapping(address => bool) private _excludedFromMaxWalletBalance;

    address public immutable uniV2Pair;
    IUniswapV2Router public constant uniV2Router = IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    bool public tradingEnabled;

    event LimitsRemoved();
    event TradingEnabled();
    event BuyFeeSet(uint16 newBuyFee);
    event SellFeeSet(uint16 newSellFee);
    event MarketingWalletUpdated(address newAddress);
    event SwapTokensAtAmountSet(uint256 newSwapTokensAtAmount);
    event FeesDistributed(uint256 totalTokensDistributed);

    /**
     * @notice Constructor function for the ELONWIFTRUMP contract.
     * It initializes the contract by setting the token name and symbol,
     * creates a Uniswap V2 pair for the token, sets initial values for marketing and operations wallets and
     * mints total token supply.
     * It also approves the Uniswap V2 router to spend an unlimited amount of tokens on behalf of the contract.
     */
    constructor() ERC20("ELONWIFTRUMP", "$EWT") Ownable(msg.sender) {
        uniV2Pair = IUniswapV2Factory(uniV2Router.factory()).createPair(address(this), uniV2Router.WETH());
        _excludedFromMaxWalletBalance[uniV2Pair] = true;

        _excludedFromFees[owner()] = true;
        marketingWallet = owner();

        _mint(owner(), 69_472_024 * 1e18);

        _approve(address(this), address(uniV2Router), type(uint256).max);
    }

    receive() external payable {}

    /**
     * @notice This function is used to transfer tokens internally within the contract.
     * It performs various checks such as trading enablement, maximum transaction and balance limits,
     * fee distribution, and fee deduction.
     * It then calls the _transfer function from the parent contract to perform the actual token transfer.
     * @param from The address to transfer tokens from.
     * @param to The address to transfer tokens to.
     * @param amount The amount of tokens to transfer.
     */
    function _transfer(address from, address to, uint256 amount) internal override {
        require(amount > 0, "ELONWIFTRUMP: transfer amount must be greater than 0");

        // Check if trading has been enabled
        if (!tradingEnabled) {
            require(from == owner() || to == owner(), "ELONWIFTRUMP: trading has not been enabled yet");
        }

        // Max TX and Max Balance Limits
        if (limitsInEffect) {
            if (from != owner() && to != owner() && to != address(0) && to != address(0xdead) && !_distributingFees) {
                // On Buys
                if (from == uniV2Pair && !_excludedFromMaxWalletBalance[to]) {
                    require(
                        amount + balanceOf(to) <= maxWalletBalance, "ELONWIFTRUMP: balance would NEVER exceed max wallet balance"
                    );
                }
                // On Transfers to non-excluded "to" address
                else if (!_excludedFromMaxWalletBalance[to]) {
                    require(
                        amount + balanceOf(to) <= maxWalletBalance, "ELONWIFTRUMP: balance would NEVER exceed max wallet balance"
                    );
                }
            }
        }

        // Swap any tokens held as fees for ETH and distribute
        bool shouldSwap = balanceOf(address(this)) >= swapTokensAtAmount;
        if (shouldSwap && !_distributingFees && from != uniV2Pair && !_excludedFromFees[from] && !_excludedFromFees[to])
        {
            _distributingFees = true;
            _distributeFees();
            _distributingFees = false;
        }

        // Determine if we should take fees
        bool takeFees = !_distributingFees;
        if (_excludedFromFees[from] || _excludedFromFees[to]) {
            takeFees = false;
        }

        uint256 fees = 0;
        // Take Fees if necessary
        if (takeFees) {
            // Fees on buys
            if (from == uniV2Pair && buyFee > 0) {
                fees = (amount * buyFee) / 1_000;
            }
            // Fees on sells
            else if (to == uniV2Pair && sellFee > 0) {
                fees = (amount * sellFee) / 1_000;
            }

            // If there are fees to be taken, transfer and substract from amount
            if (fees > 0) {
                super._transfer(from, address(this), fees);
                amount -= fees;
            }
        }

        // Make final transfer
        super._transfer(from, to, amount);
    }

    /**
     * @notice Distributes fees collected by the contract.
     * The function calculates the amount of fees to distribute based on the
     * balance of the contract and a max threshold of 20 times the swapTokensAtAmount.
     * @dev Emits a `FeesDistributed` event with the amount distributed.
     */
    function _distributeFees() private {
        // Determine amount of held fees to distribute
        uint256 tokensToDistribute = balanceOf(address(this));
        if (tokensToDistribute > swapTokensAtAmount * 20) {
            tokensToDistribute = swapTokensAtAmount * 20;
        }

        // Swap tokens for ETH
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniV2Router.WETH();
        try uniV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokensToDistribute, 0, path, address(this), block.timestamp
        ) {} catch {}

        // Send ETH to Marketing
        uint256 ethBalance = address(this).balance;
        if (ethBalance > 0) {
            (bool success,) = marketingWallet.call{value: ethBalance}("");
            if (success) {
                emit FeesDistributed(tokensToDistribute);
            }
        }
    }

    /**
     * @notice Returns whether the specified account is excluded from fees.
     * @param account The address to check.
     * @return A boolean indicating whether the account is excluded from fees.
     */
    function isExcludedFromFees(address account) public view returns (bool) {
        return _excludedFromFees[account];
    }

    /**
     * @notice Returns whether the specified account is excluded from the maximum wallet balance limit.
     * @param account The address to check.
     * @return A boolean indicating whether the account is excluded from the maximum wallet balance limit.
     */
    function isExcludedFromMaxWalletBalance(address account) public view returns (bool) {
        return _excludedFromMaxWalletBalance[account];
    }

    /**
     * @notice Enables trading of the token.
     * @dev Can only be called by the contract owner.
     * @dev Emits a `TradingEnabled` event.
     */
    function enableTrading() external onlyOwner {
        tradingEnabled = true;
        emit TradingEnabled();
    }

    /**
     * @notice Updates the marketing wallet address.
     * @param newAddress The new address for the marketing wallet.
     * @dev Can only be called by the contract owner.
     * @dev `newAddress` cannot be the zero address.
     * @dev Emits a `MarketingWalletUpdated` event.
     */
    function updateMarketingWallet(address newAddress) external onlyOwner {
        require(newAddress != address(0), "ELONWIFTRUMP: address cannot be 0 address");
        marketingWallet = newAddress;
        emit MarketingWalletUpdated(newAddress);
    }

    /**
     * @notice Removes the max transcation and max wallet balance limits on the token.
     * @dev Can only be called by the contract owner.
     * @dev Once turned off, the limits cannot be turned back on.
     * @dev Emits a `LimitsRemoved` event.
     */
    function removeLimits() external onlyOwner {
        limitsInEffect = false;
        emit LimitsRemoved();
    }

    /**
     * @notice Sets the amount of tokens required for a fee tokens swap.
     * @param newSwapTokensAtAmount The new amount of tokens required for a swap.
     * @dev Can only be called by the contract owner.
     * @dev The newSwapTokensAtAmount must be greater than or equal to 0.001% of the total supply,
     * and less than or equal to 0.5% of the total supply.
     * @dev Emits a `SwapTokensAtAmountSet` event.
     */
    function setSwapTokensAtAmount(uint256 newSwapTokensAtAmount) external onlyOwner {
        require(
            newSwapTokensAtAmount >= totalSupply() / 100_000,
            "ELONWIFTRUMP: swap tokens at amount cannot be lower than 0.001% of total supply"
        );
        require(
            newSwapTokensAtAmount <= (totalSupply() * 5) / 1_000,
            "ELONWIFTRUMP: swap tokens at amount cannot be higher than 0.5% of total supply"
        );
        swapTokensAtAmount = newSwapTokensAtAmount;
        emit SwapTokensAtAmountSet(newSwapTokensAtAmount);
    }

    /**
     * @notice Sets the buy fee for ELONWIFTRUMP.
     * @param newBuyFee The new buy fee to be set.
     * @dev Can only be called by the contract owner.
     * @dev The new buy fee cannot be greater than 400 (40%).
     * @dev Emits a `BuyFeeSet` event.
     */
    function setBuyFee(uint16 newBuyFee) external onlyOwner {
        require(newBuyFee <= 400, "ELONWIFTRUMP: fee cannot be greater than 40%");
        buyFee = newBuyFee;
        emit BuyFeeSet(newBuyFee);
    }

    /**
     * @notice Sets the sell fee for ELONWIFTRUMP.
     * @param newSellFee The new sell fee to be set.
     * @dev Can only be called by the contract owner.
     * @dev The new sell fee cannot be greater than 400 (40%).
     * @dev Emits a `SellFeeSet` event.
     */
    function setSellFee(uint16 newSellFee) external onlyOwner {
        require(newSellFee <= 400, "ELONWIFTRUMP: fee cannot be greater than 40%");
        sellFee = newSellFee;
        emit SellFeeSet(newSellFee);
    }

    /**
     * @notice Sets the excluded status of an account from fees.
     * @param account The address of the account.
     * @param excluded The excluded status to be set.
     * @dev Only the contract owner can call this function.
     */
    function setExcludedFromFees(address account, bool excluded) external onlyOwner {
        _excludedFromFees[account] = excluded;
    }

    /**
     * @notice Sets whether an account is excluded from the maximum wallet balance limit.
     * @param account The address of the account to be excluded or included.
     * @param excluded A boolean indicating whether the account should be excluded or included.
     * @dev Only the contract owner can call this function.
     */
    function setExcludedFromMaxWalletBalance(address account, bool excluded) external onlyOwner {
        _excludedFromMaxWalletBalance[account] = excluded;
    }
}