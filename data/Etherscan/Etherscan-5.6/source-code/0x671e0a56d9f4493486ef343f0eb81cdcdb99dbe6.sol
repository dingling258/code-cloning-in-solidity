{"CatsCrown.sol":{"content":"// SPDX-License-Identifier: MIT\r\npragma solidity ^0.8.0;\r\nimport \"./ERC20.sol\";\r\nimport \"./Ownable.sol\";\r\n\r\ncontract  CatWithCrown is ERC20, Ownable {\r\n    event BuyTaxChanged(address indexed, uint256 amount);\r\n    event SellTaxChanged(address indexed, uint256 amount);\r\n    event AddedTaxFreeAddress(address indexed);\r\n    address public taxWallet;\r\n    address public uniswapV2Pair;\r\n    uint256 public buyTaxPercentage;\r\n    uint256 public sellTaxPercentage;\r\n    \r\n\r\n    mapping(address =\u003e bool) public taxFreeAddresses;\r\n\r\n    constructor() ERC20(\"CatWithCrown\", \"CatsCrown\"){\r\n        _mint(msg.sender, 15000000000 * 10**18);\r\n        taxFreeAddresses[address(0)] = true;\r\n        taxFreeAddresses[msg.sender] = true;\r\n        buyTaxPercentage = 1;\r\n        sellTaxPercentage = 1;\r\n        uniswapV2Pair = address(0);\r\n        taxWallet = 0x1194fcd7dd7674B21De755F87546a60434308542;\r\n    }\r\n\r\n    function _update(\r\n        address from,\r\n        address to,\r\n        uint256 value\r\n    ) internal override {\r\n        \r\n        if (!taxFreeAddresses[from] \u0026\u0026 !taxFreeAddresses[to]) {\r\n            if (from == uniswapV2Pair) {\r\n                //This means that the user is buying $FHT tokens\r\n                uint256 buyTaxAmount = (value / 100) * buyTaxPercentage;\r\n                uint256 tokensLeft = value - buyTaxAmount;\r\n                super._update(from, taxWallet, buyTaxAmount);\r\n                super._update(from, to, tokensLeft);\r\n            } else if (to == uniswapV2Pair) {\r\n                //This means that the user wants to sell $FHT tokens\r\n                uint256 sellTaxAmount = (value / 100) * sellTaxPercentage;\r\n                uint256 tokensLeft = value - sellTaxAmount;\r\n                super._update(from, taxWallet, sellTaxAmount);\r\n                super._update(from, to, tokensLeft);\r\n            } else {\r\n                 super._update(from, to, value);\r\n            }\r\n        } else{\r\n            //Tax free transfer \r\n            super._update(from, to, value);\r\n        }\r\n    }\r\n\r\n\r\n    function changeSelltax(uint256 _taxAmount) external onlyOwner {\r\n        require(\r\n            _taxAmount \u003c= 40,\r\n            \"The sell tax Amount must not be greater than 40% - for initial launch\"\r\n        );\r\n        sellTaxPercentage = _taxAmount;\r\n        emit SellTaxChanged(msg.sender, _taxAmount);\r\n    }\r\n\r\n    function changeBuyTax(uint256 _taxAmount) external onlyOwner {\r\n        require(\r\n            _taxAmount \u003c= 40,\r\n            \"The buy tax Amount must not be greater than 40% - for initial launch\"\r\n        );\r\n        buyTaxPercentage = _taxAmount;\r\n        emit BuyTaxChanged(msg.sender, _taxAmount);\r\n    }\r\n\r\n    function changeTaxWallet(address _wallet) external onlyOwner {\r\n        taxWallet = _wallet;\r\n    }\r\n\r\n    function changeUniwapV2PairAddress(address _uniswapV2Pair)\r\n        public\r\n        onlyOwner\r\n    {\r\n        uniswapV2Pair = _uniswapV2Pair;\r\n    }\r\n\r\n    function addToTaxFreeList(address _user) external onlyOwner {\r\n        taxFreeAddresses[_user] = true;\r\n        emit AddedTaxFreeAddress(_user);\r\n    }\r\n}\r\n\r\n\r\n\r\n// OWNER: 0x1194fcd7dd7674B21De755F87546a60434308542 ( OWNER )\r\n\r\n//  TAX: 0x1194fcd7dd7674B21De755F87546a60434308542 ( OWNER )"},"Context.sol":{"content":"// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.20;\n\n/*\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes calldata) {\n        return msg.data;\n    }\n}"},"draft-IERC6093.sol":{"content":"// SPDX-License-Identifier: MIT\r\n// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/draft-IERC6093.sol)\r\npragma solidity ^0.8.20;\r\n\r\n/**\r\n * @dev Standard ERC-20 Errors\r\n * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC-20 tokens.\r\n */\r\ninterface IERC20Errors {\r\n    /**\r\n     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.\r\n     * @param sender Address whose tokens are being transferred.\r\n     * @param balance Current balance for the interacting account.\r\n     * @param needed Minimum amount required to perform a transfer.\r\n     */\r\n    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);\r\n\r\n    /**\r\n     * @dev Indicates a failure with the token `sender`. Used in transfers.\r\n     * @param sender Address whose tokens are being transferred.\r\n     */\r\n    error ERC20InvalidSender(address sender);\r\n\r\n    /**\r\n     * @dev Indicates a failure with the token `receiver`. Used in transfers.\r\n     * @param receiver Address to which tokens are being transferred.\r\n     */\r\n    error ERC20InvalidReceiver(address receiver);\r\n\r\n    /**\r\n     * @dev Indicates a failure with the `spender`’s `allowance`. Used in transfers.\r\n     * @param spender Address that may be allowed to operate on tokens without being their owner.\r\n     * @param allowance Amount of tokens a `spender` is allowed to operate with.\r\n     * @param needed Minimum amount required to perform a transfer.\r\n     */\r\n    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);\r\n\r\n    /**\r\n     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.\r\n     * @param approver Address initiating an approval operation.\r\n     */\r\n    error ERC20InvalidApprover(address approver);\r\n\r\n    /**\r\n     * @dev Indicates a failure with the `spender` to be approved. Used in approvals.\r\n     * @param spender Address that may be allowed to operate on tokens without being their owner.\r\n     */\r\n    error ERC20InvalidSpender(address spender);\r\n}\r\n\r\n/**\r\n * @dev Standard ERC-721 Errors\r\n * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC-721 tokens.\r\n */\r\ninterface IERC721Errors {\r\n    /**\r\n     * @dev Indicates that an address can\u0027t be an owner. For example, `address(0)` is a forbidden owner in ERC-20.\r\n     * Used in balance queries.\r\n     * @param owner Address of the current owner of a token.\r\n     */\r\n    error ERC721InvalidOwner(address owner);\r\n\r\n    /**\r\n     * @dev Indicates a `tokenId` whose `owner` is the zero address.\r\n     * @param tokenId Identifier number of a token.\r\n     */\r\n    error ERC721NonexistentToken(uint256 tokenId);\r\n\r\n    /**\r\n     * @dev Indicates an error related to the ownership over a particular token. Used in transfers.\r\n     * @param sender Address whose tokens are being transferred.\r\n     * @param tokenId Identifier number of a token.\r\n     * @param owner Address of the current owner of a token.\r\n     */\r\n    error ERC721IncorrectOwner(address sender, uint256 tokenId, address owner);\r\n\r\n    /**\r\n     * @dev Indicates a failure with the token `sender`. Used in transfers.\r\n     * @param sender Address whose tokens are being transferred.\r\n     */\r\n    error ERC721InvalidSender(address sender);\r\n\r\n    /**\r\n     * @dev Indicates a failure with the token `receiver`. Used in transfers.\r\n     * @param receiver Address to which tokens are being transferred.\r\n     */\r\n    error ERC721InvalidReceiver(address receiver);\r\n\r\n    /**\r\n     * @dev Indicates a failure with the `operator`’s approval. Used in transfers.\r\n     * @param operator Address that may be allowed to operate on tokens without being their owner.\r\n     * @param tokenId Identifier number of a token.\r\n     */\r\n    error ERC721InsufficientApproval(address operator, uint256 tokenId);\r\n\r\n    /**\r\n     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.\r\n     * @param approver Address initiating an approval operation.\r\n     */\r\n    error ERC721InvalidApprover(address approver);\r\n\r\n    /**\r\n     * @dev Indicates a failure with the `operator` to be approved. Used in approvals.\r\n     * @param operator Address that may be allowed to operate on tokens without being their owner.\r\n     */\r\n    error ERC721InvalidOperator(address operator);\r\n}\r\n\r\n/**\r\n * @dev Standard ERC-1155 Errors\r\n * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC-1155 tokens.\r\n */\r\ninterface IERC1155Errors {\r\n    /**\r\n     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.\r\n     * @param sender Address whose tokens are being transferred.\r\n     * @param balance Current balance for the interacting account.\r\n     * @param needed Minimum amount required to perform a transfer.\r\n     * @param tokenId Identifier number of a token.\r\n     */\r\n    error ERC1155InsufficientBalance(address sender, uint256 balance, uint256 needed, uint256 tokenId);\r\n\r\n    /**\r\n     * @dev Indicates a failure with the token `sender`. Used in transfers.\r\n     * @param sender Address whose tokens are being transferred.\r\n     */\r\n    error ERC1155InvalidSender(address sender);\r\n\r\n    /**\r\n     * @dev Indicates a failure with the token `receiver`. Used in transfers.\r\n     * @param receiver Address to which tokens are being transferred.\r\n     */\r\n    error ERC1155InvalidReceiver(address receiver);\r\n\r\n    /**\r\n     * @dev Indicates a failure with the `operator`’s approval. Used in transfers.\r\n     * @param operator Address that may be allowed to operate on tokens without being their owner.\r\n     * @param owner Address of the current owner of a token.\r\n     */\r\n    error ERC1155MissingApprovalForAll(address operator, address owner);\r\n\r\n    /**\r\n     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.\r\n     * @param approver Address initiating an approval operation.\r\n     */\r\n    error ERC1155InvalidApprover(address approver);\r\n\r\n    /**\r\n     * @dev Indicates a failure with the `operator` to be approved. Used in approvals.\r\n     * @param operator Address that may be allowed to operate on tokens without being their owner.\r\n     */\r\n    error ERC1155InvalidOperator(address operator);\r\n\r\n    /**\r\n     * @dev Indicates an array length mismatch between ids and values in a safeBatchTransferFrom operation.\r\n     * Used in batch transfers.\r\n     * @param idsLength Length of the array of token identifiers\r\n     * @param valuesLength Length of the array of token amounts\r\n     */\r\n    error ERC1155InvalidArrayLength(uint256 idsLength, uint256 valuesLength);\r\n}"},"ERC20.sol":{"content":"// SPDX-License-Identifier: MIT\r\n// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/ERC20.sol)\r\n\r\npragma solidity ^0.8.20;\r\n\r\nimport {IERC20} from \"./IERC20.sol\";\r\nimport {IERC20Metadata} from \"./IERC20Metadata.sol\";\r\nimport {Context} from \"./Context.sol\";\r\nimport {IERC20Errors} from \"./draft-IERC6093.sol\";\r\n\r\n/**\r\n * @dev Implementation of the {IERC20} interface.\r\n *\r\n * This implementation is agnostic to the way tokens are created. This means\r\n * that a supply mechanism has to be added in a derived contract using {_mint}.\r\n *\r\n * TIP: For a detailed writeup see our guide\r\n * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How\r\n * to implement supply mechanisms].\r\n *\r\n * The default value of {decimals} is 18. To change this, you should override\r\n * this function so it returns a different value.\r\n *\r\n * We have followed general OpenZeppelin Contracts guidelines: functions revert\r\n * instead returning `false` on failure. This behavior is nonetheless\r\n * conventional and does not conflict with the expectations of ERC20\r\n * applications.\r\n *\r\n * Additionally, an {Approval} event is emitted on calls to {transferFrom}.\r\n * This allows applications to reconstruct the allowance for all accounts just\r\n * by listening to said events. Other implementations of the EIP may not emit\r\n * these events, as it isn\u0027t required by the specification.\r\n */\r\nabstract contract ERC20 is Context, IERC20, IERC20Metadata, IERC20Errors {\r\n    mapping(address account =\u003e uint256) private _balances;\r\n\r\n    mapping(address account =\u003e mapping(address spender =\u003e uint256)) private _allowances;\r\n\r\n    uint256 private _totalSupply;\r\n\r\n    string private _name;\r\n    string private _symbol;\r\n\r\n    /**\r\n     * @dev Sets the values for {name} and {symbol}.\r\n     *\r\n     * All two of these values are immutable: they can only be set once during\r\n     * construction.\r\n     */\r\n    constructor(string memory name_, string memory symbol_) {\r\n        _name = name_;\r\n        _symbol = symbol_;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the name of the token.\r\n     */\r\n    function name() public view virtual returns (string memory) {\r\n        return _name;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the symbol of the token, usually a shorter version of the\r\n     * name.\r\n     */\r\n    function symbol() public view virtual returns (string memory) {\r\n        return _symbol;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the number of decimals used to get its user representation.\r\n     * For example, if `decimals` equals `2`, a balance of `505` tokens should\r\n     * be displayed to a user as `5.05` (`505 / 10 ** 2`).\r\n     *\r\n     * Tokens usually opt for a value of 18, imitating the relationship between\r\n     * Ether and Wei. This is the default value returned by this function, unless\r\n     * it\u0027s overridden.\r\n     *\r\n     * NOTE: This information is only used for _display_ purposes: it in\r\n     * no way affects any of the arithmetic of the contract, including\r\n     * {IERC20-balanceOf} and {IERC20-transfer}.\r\n     */\r\n    function decimals() public view virtual returns (uint8) {\r\n        return 18;\r\n    }\r\n\r\n    /**\r\n     * @dev See {IERC20-totalSupply}.\r\n     */\r\n    function totalSupply() public view virtual returns (uint256) {\r\n        return _totalSupply;\r\n    }\r\n\r\n    /**\r\n     * @dev See {IERC20-balanceOf}.\r\n     */\r\n    function balanceOf(address account) public view virtual returns (uint256) {\r\n        return _balances[account];\r\n    }\r\n\r\n    /**\r\n     * @dev See {IERC20-transfer}.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - `to` cannot be the zero address.\r\n     * - the caller must have a balance of at least `value`.\r\n     */\r\n    function transfer(address to, uint256 value) public virtual returns (bool) {\r\n        address owner = _msgSender();\r\n        _transfer(owner, to, value);\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev See {IERC20-allowance}.\r\n     */\r\n    function allowance(address owner, address spender) public view virtual returns (uint256) {\r\n        return _allowances[owner][spender];\r\n    }\r\n\r\n    /**\r\n     * @dev See {IERC20-approve}.\r\n     *\r\n     * NOTE: If `value` is the maximum `uint256`, the allowance is not updated on\r\n     * `transferFrom`. This is semantically equivalent to an infinite approval.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - `spender` cannot be the zero address.\r\n     */\r\n    function approve(address spender, uint256 value) public virtual returns (bool) {\r\n        address owner = _msgSender();\r\n        _approve(owner, spender, value);\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev See {IERC20-transferFrom}.\r\n     *\r\n     * Emits an {Approval} event indicating the updated allowance. This is not\r\n     * required by the EIP. See the note at the beginning of {ERC20}.\r\n     *\r\n     * NOTE: Does not update the allowance if the current allowance\r\n     * is the maximum `uint256`.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - `from` and `to` cannot be the zero address.\r\n     * - `from` must have a balance of at least `value`.\r\n     * - the caller must have allowance for ``from``\u0027s tokens of at least\r\n     * `value`.\r\n     */\r\n    function transferFrom(address from, address to, uint256 value) public virtual returns (bool) {\r\n        address spender = _msgSender();\r\n        _spendAllowance(from, spender, value);\r\n        _transfer(from, to, value);\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev Moves a `value` amount of tokens from `from` to `to`.\r\n     *\r\n     * This internal function is equivalent to {transfer}, and can be used to\r\n     * e.g. implement automatic token fees, slashing mechanisms, etc.\r\n     *\r\n     * Emits a {Transfer} event.\r\n     *\r\n     * NOTE: This function is not virtual, {_update} should be overridden instead.\r\n     */\r\n    function _transfer(address from, address to, uint256 value) internal {\r\n        if (from == address(0)) {\r\n            revert ERC20InvalidSender(address(0));\r\n        }\r\n        if (to == address(0)) {\r\n            revert ERC20InvalidReceiver(address(0));\r\n        }\r\n        _update(from, to, value);\r\n    }\r\n\r\n    /**\r\n     * @dev Transfers a `value` amount of tokens from `from` to `to`, or alternatively mints (or burns) if `from`\r\n     * (or `to`) is the zero address. All customizations to transfers, mints, and burns should be done by overriding\r\n     * this function.\r\n     *\r\n     * Emits a {Transfer} event.\r\n     */\r\n    function _update(address from, address to, uint256 value) internal virtual {\r\n        if (from == address(0)) {\r\n            // Overflow check required: The rest of the code assumes that totalSupply never overflows\r\n            _totalSupply += value;\r\n        } else {\r\n            uint256 fromBalance = _balances[from];\r\n            if (fromBalance \u003c value) {\r\n                revert ERC20InsufficientBalance(from, fromBalance, value);\r\n            }\r\n            unchecked {\r\n                // Overflow not possible: value \u003c= fromBalance \u003c= totalSupply.\r\n                _balances[from] = fromBalance - value;\r\n            }\r\n        }\r\n\r\n        if (to == address(0)) {\r\n            unchecked {\r\n                // Overflow not possible: value \u003c= totalSupply or value \u003c= fromBalance \u003c= totalSupply.\r\n                _totalSupply -= value;\r\n            }\r\n        } else {\r\n            unchecked {\r\n                // Overflow not possible: balance + value is at most totalSupply, which we know fits into a uint256.\r\n                _balances[to] += value;\r\n            }\r\n        }\r\n\r\n        emit Transfer(from, to, value);\r\n    }\r\n\r\n    /**\r\n     * @dev Creates a `value` amount of tokens and assigns them to `account`, by transferring it from address(0).\r\n     * Relies on the `_update` mechanism\r\n     *\r\n     * Emits a {Transfer} event with `from` set to the zero address.\r\n     *\r\n     * NOTE: This function is not virtual, {_update} should be overridden instead.\r\n     */\r\n    function _mint(address account, uint256 value) internal {\r\n        if (account == address(0)) {\r\n            revert ERC20InvalidReceiver(address(0));\r\n        }\r\n        _update(address(0), account, value);\r\n    }\r\n\r\n    /**\r\n     * @dev Destroys a `value` amount of tokens from `account`, lowering the total supply.\r\n     * Relies on the `_update` mechanism.\r\n     *\r\n     * Emits a {Transfer} event with `to` set to the zero address.\r\n     *\r\n     * NOTE: This function is not virtual, {_update} should be overridden instead\r\n     */\r\n    function _burn(address account, uint256 value) internal {\r\n        if (account == address(0)) {\r\n            revert ERC20InvalidSender(address(0));\r\n        }\r\n        _update(account, address(0), value);\r\n    }\r\n\r\n    /**\r\n     * @dev Sets `value` as the allowance of `spender` over the `owner` s tokens.\r\n     *\r\n     * This internal function is equivalent to `approve`, and can be used to\r\n     * e.g. set automatic allowances for certain subsystems, etc.\r\n     *\r\n     * Emits an {Approval} event.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - `owner` cannot be the zero address.\r\n     * - `spender` cannot be the zero address.\r\n     *\r\n     * Overrides to this logic should be done to the variant with an additional `bool emitEvent` argument.\r\n     */\r\n    function _approve(address owner, address spender, uint256 value) internal {\r\n        _approve(owner, spender, value, true);\r\n    }\r\n\r\n    /**\r\n     * @dev Variant of {_approve} with an optional flag to enable or disable the {Approval} event.\r\n     *\r\n     * By default (when calling {_approve}) the flag is set to true. On the other hand, approval changes made by\r\n     * `_spendAllowance` during the `transferFrom` operation set the flag to false. This saves gas by not emitting any\r\n     * `Approval` event during `transferFrom` operations.\r\n     *\r\n     * Anyone who wishes to continue emitting `Approval` events on the`transferFrom` operation can force the flag to\r\n     * true using the following override:\r\n     * ```\r\n     * function _approve(address owner, address spender, uint256 value, bool) internal virtual override {\r\n     *     super._approve(owner, spender, value, true);\r\n     * }\r\n     * ```\r\n     *\r\n     * Requirements are the same as {_approve}.\r\n     */\r\n    function _approve(address owner, address spender, uint256 value, bool emitEvent) internal virtual {\r\n        if (owner == address(0)) {\r\n            revert ERC20InvalidApprover(address(0));\r\n        }\r\n        if (spender == address(0)) {\r\n            revert ERC20InvalidSpender(address(0));\r\n        }\r\n        _allowances[owner][spender] = value;\r\n        if (emitEvent) {\r\n            emit Approval(owner, spender, value);\r\n        }\r\n    }\r\n\r\n    /**\r\n     * @dev Updates `owner` s allowance for `spender` based on spent `value`.\r\n     *\r\n     * Does not update the allowance value in case of infinite allowance.\r\n     * Revert if not enough allowance is available.\r\n     *\r\n     * Does not emit an {Approval} event.\r\n     */\r\n    function _spendAllowance(address owner, address spender, uint256 value) internal virtual {\r\n        uint256 currentAllowance = allowance(owner, spender);\r\n        if (currentAllowance != type(uint256).max) {\r\n            if (currentAllowance \u003c value) {\r\n                revert ERC20InsufficientAllowance(spender, currentAllowance, value);\r\n            }\r\n            unchecked {\r\n                _approve(owner, spender, currentAllowance - value, false);\r\n            }\r\n        }\r\n    }\r\n}\r\n"},"IERC20.sol":{"content":"// SPDX-License-Identifier: MIT\r\npragma solidity 0.8.20;\r\n\r\ninterface IERC20 {\r\n    function totalSupply() external view returns (uint256);\r\n    function balanceOf(address account) external view returns (uint256);\r\n    function transfer(address recipient, uint256 amount) external returns (bool);\r\n    function allowance(address owner, address spender) external view returns (uint256);\r\n    function approve(address spender, uint256 amount) external returns (bool);\r\n    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);\r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n    event Approval(address indexed owner, address indexed spender, uint256 value);\r\n}"},"IERC20Metadata.sol":{"content":"// SPDX-License-Identifier: MIT\r\n// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/extensions/IERC20Metadata.sol)\r\n\r\npragma solidity ^0.8.20;\r\n\r\nimport {IERC20} from \"./IERC20.sol\";\r\n\r\n/**\r\n * @dev Interface for the optional metadata functions from the ERC-20 standard.\r\n */\r\ninterface IERC20Metadata is IERC20 {\r\n    /**\r\n     * @dev Returns the name of the token.\r\n     */\r\n    function name() external view returns (string memory);\r\n\r\n    /**\r\n     * @dev Returns the symbol of the token.\r\n     */\r\n    function symbol() external view returns (string memory);\r\n\r\n    /**\r\n     * @dev Returns the decimals places of the token.\r\n     */\r\n    function decimals() external view returns (uint8);\r\n}"},"Ownable.sol":{"content":"// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.20;\n\nimport \"./Context.sol\";\n\n/**\n * @dev Contract module which provides a basic access control mechanism, where\n * there is an account (an owner) that can be granted exclusive access to\n * specific functions.\n *\n * By default, the owner account will be the one that deploys the contract. This\n * can later be changed with {transferOwnership}.\n *\n * This module is used through inheritance. It will make available the modifier\n * `onlyOwner`, which can be applied to your functions to restrict their use to\n * the owner.\n */\nabstract contract Ownable is Context {\n    address private _owner;\n\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    /**\n     * @dev Initializes the contract setting the deployer as the initial owner.\n     */\n    constructor() {\n        _setOwner(_msgSender());\n    }\n\n    /**\n     * @dev Returns the address of the current owner.\n     */\n    function owner() public view virtual returns (address) {\n        return _owner;\n    }\n\n    /**\n     * @dev Throws if called by any account other than the owner.\n     */\n    modifier onlyOwner() {\n        require(owner() == _msgSender(), \"Ownable: caller is not the owner\");\n        _;\n    }\n\n    /**\n     * @dev Leaves the contract without owner. It will not be possible to call\n     * `onlyOwner` functions anymore. Can only be called by the current owner.\n     *\n     * NOTE: Renouncing ownership will leave the contract without an owner,\n     * thereby removing any functionality that is only available to the owner.\n     */\n    function renounceOwnership() public virtual onlyOwner {\n        _setOwner(address(0));\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Can only be called by the current owner.\n     */\n    function transferOwnership(address newOwner) public virtual onlyOwner {\n        require(newOwner != address(0), \"Ownable: new owner is the zero address\");\n        _setOwner(newOwner);\n    }\n\n    function _setOwner(address newOwner) private {\n        address oldOwner = _owner;\n        _owner = newOwner;\n        emit OwnershipTransferred(oldOwner, newOwner);\n    }\n}"}}