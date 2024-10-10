{"Context.sol":{"content":"// SPDX-License-Identifier: MIT\r\n// OpenZeppelin Contracts (last updated v4.9.4) (./Context.sol)\r\n\r\npragma solidity ^0.8.0;\r\n\r\n/**\r\n * @dev Provides information about the current execution context, including the\r\n * sender of the transaction and its data. While these are generally available\r\n * via msg.sender and msg.data, they should not be accessed in such a direct\r\n * manner, since when dealing with meta-transactions the account sending and\r\n * paying for execution may not be the actual sender (as far as an application\r\n * is concerned).\r\n *\r\n * This contract is only required for intermediate, library-like contracts.\r\n */\r\nabstract contract Context {\r\n    function _msgSender() internal view virtual returns (address) {\r\n        return msg.sender;\r\n    }\r\n\r\n    function _msgData() internal view virtual returns (bytes calldata) {\r\n        return msg.data;\r\n    }\r\n\r\n    function _contextSuffixLength() internal view virtual returns (uint256) {\r\n        return 0;\r\n    }\r\n}"},"DAI.sol":{"content":"/**\r\n\r\nDefendAI is a cutting-edge platform at the forefront of revolutionizing cybersecurity within the cryptocurrency realm. \r\n\r\n✔ Launch on Uniswap 14：00 UTC, April 19\r\n\r\nCore Functions \u0026 Features\r\n✈ Real-Time Phishing Protection\r\n✈ Intelligent Transactions Analysis\r\n✈ Daily Security News Updates\r\n✈ Clipboard Security Alerts\r\n✈ Enhanced Wallet Integration\r\n\r\nSocial link\r\n🟢 Website: https://defendai.io\r\n🟢 Docs: https://defendai.gitbook.io/whitepaper/\r\n🟢 X: https://twitter.com/DefendAI_ETH\r\n🟢 Telegram: https://t.me/DefendAI\r\n\r\n**/\r\n\r\n// SPDX-License-Identifier: MIT\r\npragma solidity ^0.8.0;\r\n\r\nimport \"./IERC20.sol\";\r\nimport \"./ERC20.sol\";\r\nimport \"./Ownable.sol\";\r\nimport \"./IUniswapRouter.sol\";\r\n\r\ncontract DAI is ERC20, Ownable {\r\n    struct TaxConfig {\r\n        uint256 marketing; \r\n        uint256 developmentFund; \r\n    }\r\n\r\n    uint256 private constant MAX_BUY_DURATION = 5;\r\n    uint256 private constant MAX_HOLD_DURATION = 5;\r\n\r\n    bool private swapping;\r\n    bool public tradingEnabled;\r\n\r\n    address public pair;\r\n    address public marketingWallet;\r\n    address public developmentFundWallet;\r\n\r\n    IUniswapRouter public router;\r\n\r\n    uint256 public tax = 5;\r\n    TaxConfig public taxConfig = TaxConfig(3, 2);\r\n\r\n    uint256 public maxBuy;\r\n    uint256 public maxHold;\r\n    uint256 public swapTokensAtAmount;\r\n    uint256 private limitBuyTimeStamp;\r\n\r\n    uint256 private limitHoldTimeStamp;\r\n\r\n    mapping(address =\u003e bool) public isExcludedFromFees;\r\n\r\n    constructor(\r\n        address _routerAddress,\r\n        address _marketingWallet,\r\n        address _developmentFundWallet\r\n    ) ERC20(\"Defend AI\", \"DAI\") {\r\n        marketingWallet = _marketingWallet;\r\n        developmentFundWallet = _developmentFundWallet;\r\n\r\n        IUniswapRouter _router = IUniswapRouter(_routerAddress);\r\n\r\n        address _pair = IFactory(_router.factory()).createPair(\r\n            address(this),\r\n            _router.WETH()\r\n        );\r\n\r\n        router = _router;\r\n\r\n        pair = _pair;\r\n\r\n        excludeFromFees(owner(), true);\r\n        excludeFromFees(_marketingWallet, true);\r\n        excludeFromFees(_developmentFundWallet, true);\r\n        excludeFromFees(address(this), true);\r\n\r\n        setSwapTokensAtAmount(2_000_000 * (10 ** 18));\r\n\r\n        maxHold = 2_000_000 * (10 ** 18);\r\n\r\n        maxBuy = 2_000_000 * (10 ** 18);\r\n\r\n        _mint(owner(), 100_000_000 * (10 ** 18));\r\n    }\r\n\r\n    function setSwapTokensAtAmount(uint256 amount) public onlyOwner {\r\n        swapTokensAtAmount = amount;\r\n    }\r\n\r\n    function excludeFromFees(address account, bool excluded) public onlyOwner {\r\n        require(\r\n            isExcludedFromFees[account] != excluded,\r\n            \"Account is already excluded\"\r\n        );\r\n        isExcludedFromFees[account] = excluded;\r\n    }\r\n\r\n\r\n    function setWallets(\r\n        address _marketingWallet,\r\n        address _developmentFundWallet\r\n    ) public onlyOwner {\r\n        marketingWallet = _marketingWallet;\r\n        developmentFundWallet = _developmentFundWallet;\r\n    }\r\n\r\n    /// @notice Enables trading\r\n    function activateTrading() external onlyOwner {\r\n        require(!tradingEnabled, \"Trading already enabled\");\r\n\r\n        tradingEnabled = true;\r\n\r\n        limitBuyTimeStamp = block.timestamp + MAX_BUY_DURATION;\r\n\r\n        limitHoldTimeStamp = block.timestamp + MAX_HOLD_DURATION;\r\n    }\r\n\r\n    function _transfer(\r\n        address from,\r\n        address to,\r\n        uint256 amount\r\n    ) internal override {\r\n        require(from != address(0), \"ERC20: transfer from the zero address\");\r\n        require(to != address(0), \"ERC20: transfer to the zero address\");\r\n\r\n        address _pair = pair;\r\n\r\n        if (!isExcludedFromFees[from] \u0026\u0026 !isExcludedFromFees[to] \u0026\u0026 !swapping) {\r\n            require(tradingEnabled, \"Trading not active\");\r\n            if (limitHoldTimeStamp \u003e block.timestamp \u0026\u0026 to != _pair) {\r\n                require(amount + balanceOf(to) \u003c= maxHold, \"Exceed max hold!\");\r\n            }\r\n            if (limitBuyTimeStamp \u003e block.timestamp \u0026\u0026 from == _pair) {\r\n                require(amount \u003c= maxBuy, \"Exceed max buy!\");\r\n            }\r\n        }\r\n\r\n        if (amount == 0) {\r\n            super._transfer(from, to, 0);\r\n            return;\r\n        }\r\n\r\n        uint256 contractTokenBalance = balanceOf(address(this));\r\n        bool canSwap = contractTokenBalance \u003e= swapTokensAtAmount;\r\n\r\n        if (\r\n            canSwap \u0026\u0026\r\n            !swapping \u0026\u0026\r\n            to == _pair \u0026\u0026\r\n            !isExcludedFromFees[from] \u0026\u0026\r\n            !isExcludedFromFees[to]\r\n        ) {\r\n            swapping = true;\r\n\r\n            swapAndSendReward(swapTokensAtAmount);\r\n\r\n            swapping = false;\r\n        }\r\n\r\n        bool takeFee = !swapping;\r\n\r\n        if (isExcludedFromFees[from] || isExcludedFromFees[to]) {\r\n            takeFee = false;\r\n        }\r\n\r\n        if (_pair != to \u0026\u0026 _pair != from) {\r\n            takeFee = false;\r\n        }\r\n\r\n        if (takeFee) {\r\n            uint256 feeAmt = (amount * tax) / 100;\r\n            amount = amount - feeAmt;\r\n            super._transfer(from, address(this), feeAmt);\r\n        }\r\n        super._transfer(from, to, amount);\r\n    }\r\n\r\n    function swapAndSendReward(uint256 tokens) private {\r\n        swapTokensForETH(tokens);\r\n        uint256 currentbalance = address(this).balance;\r\n        if (currentbalance \u003e 0) {\r\n            uint256 _tax = tax;\r\n            TaxConfig memory _taxConfig = taxConfig;\r\n\r\n            uint256 marketingAmt = (currentbalance * _taxConfig.marketing) /\r\n                _tax;\r\n            uint256 developmentFundAmt = currentbalance  -\r\n                marketingAmt;\r\n            bool success;\r\n\r\n            (success, ) = payable(marketingWallet).call{\r\n                value: marketingAmt\r\n            }(\"\");\r\n            require(success, \"Error\");\r\n            (success, ) = payable(developmentFundWallet).call{\r\n                value: developmentFundAmt\r\n            }(\"\");\r\n            require(success, \"Error\");\r\n        }\r\n    }\r\n\r\n    function swapTokensForETH(uint256 tokenAmount) private {\r\n        address[] memory path = new address[](2);\r\n        path[0] = address(this);\r\n        path[1] = router.WETH();\r\n\r\n        _approve(address(this), address(router), tokenAmount);\r\n\r\n        router.swapExactTokensForETHSupportingFeeOnTransferTokens(\r\n            tokenAmount,\r\n            0,\r\n            path,\r\n            address(this),\r\n            block.timestamp\r\n        );\r\n    }\r\n\r\n    receive() external payable {}\r\n}"},"ERC20.sol":{"content":"// SPDX-License-Identifier: MIT\r\n// OpenZeppelin Contracts (last updated v4.9.0) (./ERC20.sol)\r\n\r\npragma solidity ^0.8.0;\r\n\r\nimport \"./IERC20.sol\";\r\nimport \"./IERC20Metadata.sol\";\r\nimport \"./Context.sol\";\r\n\r\n/**\r\n * @dev Implementation of the {IERC20} interface.\r\n *\r\n * This implementation is agnostic to the way tokens are created. This means\r\n * that a supply mechanism has to be added in a derived contract using {_mint}.\r\n * For a generic mechanism see {ERC20PresetMinterPauser}.\r\n *\r\n * TIP: For a detailed writeup see our guide\r\n * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How\r\n * to implement supply mechanisms].\r\n *\r\n * The default value of {decimals} is 18. To change this, you should override\r\n * this function so it returns a different value.\r\n *\r\n * We have followed general OpenZeppelin Contracts guidelines: functions revert\r\n * instead returning `false` on failure. This behavior is nonetheless\r\n * conventional and does not conflict with the expectations of ERC20\r\n * applications.\r\n *\r\n * Additionally, an {Approval} event is emitted on calls to {transferFrom}.\r\n * This allows applications to reconstruct the allowance for all accounts just\r\n * by listening to said events. Other implementations of the EIP may not emit\r\n * these events, as it isn\u0027t required by the specification.\r\n *\r\n * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}\r\n * functions have been added to mitigate the well-known issues around setting\r\n * allowances. See {IERC20-approve}.\r\n */\r\ncontract ERC20 is Context, IERC20, IERC20Metadata {\r\n    mapping(address =\u003e uint256) private _balances;\r\n\r\n    mapping(address =\u003e mapping(address =\u003e uint256)) private _allowances;\r\n\r\n    uint256 private _totalSupply;\r\n\r\n    string private _name;\r\n    string private _symbol;\r\n\r\n    /**\r\n     * @dev Sets the values for {name} and {symbol}.\r\n     *\r\n     * All two of these values are immutable: they can only be set once during\r\n     * construction.\r\n     */\r\n    constructor(string memory name_, string memory symbol_) {\r\n        _name = name_;\r\n        _symbol = symbol_;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the name of the token.\r\n     */\r\n    function name() public view virtual override returns (string memory) {\r\n        return _name;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the symbol of the token, usually a shorter version of the\r\n     * name.\r\n     */\r\n    function symbol() public view virtual override returns (string memory) {\r\n        return _symbol;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the number of decimals used to get its user representation.\r\n     * For example, if `decimals` equals `2`, a balance of `505` tokens should\r\n     * be displayed to a user as `5.05` (`505 / 10 ** 2`).\r\n     *\r\n     * Tokens usually opt for a value of 18, imitating the relationship between\r\n     * Ether and Wei. This is the default value returned by this function, unless\r\n     * it\u0027s overridden.\r\n     *\r\n     * NOTE: This information is only used for _display_ purposes: it in\r\n     * no way affects any of the arithmetic of the contract, including\r\n     * {IERC20-balanceOf} and {IERC20-transfer}.\r\n     */\r\n    function decimals() public view virtual override returns (uint8) {\r\n        return 18;\r\n    }\r\n\r\n    /**\r\n     * @dev See {IERC20-totalSupply}.\r\n     */\r\n    function totalSupply() public view virtual override returns (uint256) {\r\n        return _totalSupply;\r\n    }\r\n\r\n    /**\r\n     * @dev See {IERC20-balanceOf}.\r\n     */\r\n    function balanceOf(address account) public view virtual override returns (uint256) {\r\n        return _balances[account];\r\n    }\r\n\r\n    /**\r\n     * @dev See {IERC20-transfer}.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - `to` cannot be the zero address.\r\n     * - the caller must have a balance of at least `amount`.\r\n     */\r\n    function transfer(address to, uint256 amount) public virtual override returns (bool) {\r\n        address owner = _msgSender();\r\n        _transfer(owner, to, amount);\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev See {IERC20-allowance}.\r\n     */\r\n    function allowance(address owner, address spender) public view virtual override returns (uint256) {\r\n        return _allowances[owner][spender];\r\n    }\r\n\r\n    /**\r\n     * @dev See {IERC20-approve}.\r\n     *\r\n     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on\r\n     * `transferFrom`. This is semantically equivalent to an infinite approval.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - `spender` cannot be the zero address.\r\n     */\r\n    function approve(address spender, uint256 amount) public virtual override returns (bool) {\r\n        address owner = _msgSender();\r\n        _approve(owner, spender, amount);\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev See {IERC20-transferFrom}.\r\n     *\r\n     * Emits an {Approval} event indicating the updated allowance. This is not\r\n     * required by the EIP. See the note at the beginning of {ERC20}.\r\n     *\r\n     * NOTE: Does not update the allowance if the current allowance\r\n     * is the maximum `uint256`.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - `from` and `to` cannot be the zero address.\r\n     * - `from` must have a balance of at least `amount`.\r\n     * - the caller must have allowance for ``from``\u0027s tokens of at least\r\n     * `amount`.\r\n     */\r\n    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {\r\n        address spender = _msgSender();\r\n        _spendAllowance(from, spender, amount);\r\n        _transfer(from, to, amount);\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev Atomically increases the allowance granted to `spender` by the caller.\r\n     *\r\n     * This is an alternative to {approve} that can be used as a mitigation for\r\n     * problems described in {IERC20-approve}.\r\n     *\r\n     * Emits an {Approval} event indicating the updated allowance.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - `spender` cannot be the zero address.\r\n     */\r\n    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {\r\n        address owner = _msgSender();\r\n        _approve(owner, spender, allowance(owner, spender) + addedValue);\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev Atomically decreases the allowance granted to `spender` by the caller.\r\n     *\r\n     * This is an alternative to {approve} that can be used as a mitigation for\r\n     * problems described in {IERC20-approve}.\r\n     *\r\n     * Emits an {Approval} event indicating the updated allowance.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - `spender` cannot be the zero address.\r\n     * - `spender` must have allowance for the caller of at least\r\n     * `subtractedValue`.\r\n     */\r\n    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {\r\n        address owner = _msgSender();\r\n        uint256 currentAllowance = allowance(owner, spender);\r\n        require(currentAllowance \u003e= subtractedValue, \"ERC20: decreased allowance below zero\");\r\n        unchecked {\r\n            _approve(owner, spender, currentAllowance - subtractedValue);\r\n        }\r\n\r\n        return true;\r\n    }\r\n\r\n    /**\r\n     * @dev Moves `amount` of tokens from `from` to `to`.\r\n     *\r\n     * This internal function is equivalent to {transfer}, and can be used to\r\n     * e.g. implement automatic token fees, slashing mechanisms, etc.\r\n     *\r\n     * Emits a {Transfer} event.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - `from` cannot be the zero address.\r\n     * - `to` cannot be the zero address.\r\n     * - `from` must have a balance of at least `amount`.\r\n     */\r\n    function _transfer(address from, address to, uint256 amount) internal virtual {\r\n        require(from != address(0), \"ERC20: transfer from the zero address\");\r\n        require(to != address(0), \"ERC20: transfer to the zero address\");\r\n\r\n        _beforeTokenTransfer(from, to, amount);\r\n\r\n        uint256 fromBalance = _balances[from];\r\n        require(fromBalance \u003e= amount, \"ERC20: transfer amount exceeds balance\");\r\n        unchecked {\r\n            _balances[from] = fromBalance - amount;\r\n            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by\r\n            // decrementing then incrementing.\r\n            _balances[to] += amount;\r\n        }\r\n\r\n        emit Transfer(from, to, amount);\r\n\r\n        _afterTokenTransfer(from, to, amount);\r\n    }\r\n\r\n    /** @dev Creates `amount` tokens and assigns them to `account`, increasing\r\n     * the total supply.\r\n     *\r\n     * Emits a {Transfer} event with `from` set to the zero address.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - `account` cannot be the zero address.\r\n     */\r\n    function _mint(address account, uint256 amount) internal virtual {\r\n        require(account != address(0), \"ERC20: mint to the zero address\");\r\n\r\n        _beforeTokenTransfer(address(0), account, amount);\r\n\r\n        _totalSupply += amount;\r\n        unchecked {\r\n            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.\r\n            _balances[account] += amount;\r\n        }\r\n        emit Transfer(address(0), account, amount);\r\n\r\n        _afterTokenTransfer(address(0), account, amount);\r\n    }\r\n\r\n    /**\r\n     * @dev Destroys `amount` tokens from `account`, reducing the\r\n     * total supply.\r\n     *\r\n     * Emits a {Transfer} event with `to` set to the zero address.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - `account` cannot be the zero address.\r\n     * - `account` must have at least `amount` tokens.\r\n     */\r\n    function _burn(address account, uint256 amount) internal virtual {\r\n        require(account != address(0), \"ERC20: burn from the zero address\");\r\n\r\n        _beforeTokenTransfer(account, address(0), amount);\r\n\r\n        uint256 accountBalance = _balances[account];\r\n        require(accountBalance \u003e= amount, \"ERC20: burn amount exceeds balance\");\r\n        unchecked {\r\n            _balances[account] = accountBalance - amount;\r\n            // Overflow not possible: amount \u003c= accountBalance \u003c= totalSupply.\r\n            _totalSupply -= amount;\r\n        }\r\n\r\n        emit Transfer(account, address(0), amount);\r\n\r\n        _afterTokenTransfer(account, address(0), amount);\r\n    }\r\n\r\n    /**\r\n     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.\r\n     *\r\n     * This internal function is equivalent to `approve`, and can be used to\r\n     * e.g. set automatic allowances for certain subsystems, etc.\r\n     *\r\n     * Emits an {Approval} event.\r\n     *\r\n     * Requirements:\r\n     *\r\n     * - `owner` cannot be the zero address.\r\n     * - `spender` cannot be the zero address.\r\n     */\r\n    function _approve(address owner, address spender, uint256 amount) internal virtual {\r\n        require(owner != address(0), \"ERC20: approve from the zero address\");\r\n        require(spender != address(0), \"ERC20: approve to the zero address\");\r\n\r\n        _allowances[owner][spender] = amount;\r\n        emit Approval(owner, spender, amount);\r\n    }\r\n\r\n    /**\r\n     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.\r\n     *\r\n     * Does not update the allowance amount in case of infinite allowance.\r\n     * Revert if not enough allowance is available.\r\n     *\r\n     * Might emit an {Approval} event.\r\n     */\r\n    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {\r\n        uint256 currentAllowance = allowance(owner, spender);\r\n        if (currentAllowance != type(uint256).max) {\r\n            require(currentAllowance \u003e= amount, \"ERC20: insufficient allowance\");\r\n            unchecked {\r\n                _approve(owner, spender, currentAllowance - amount);\r\n            }\r\n        }\r\n    }\r\n\r\n    /**\r\n     * @dev Hook that is called before any transfer of tokens. This includes\r\n     * minting and burning.\r\n     *\r\n     * Calling conditions:\r\n     *\r\n     * - when `from` and `to` are both non-zero, `amount` of ``from``\u0027s tokens\r\n     * will be transferred to `to`.\r\n     * - when `from` is zero, `amount` tokens will be minted for `to`.\r\n     * - when `to` is zero, `amount` of ``from``\u0027s tokens will be burned.\r\n     * - `from` and `to` are never both zero.\r\n     *\r\n     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].\r\n     */\r\n    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}\r\n\r\n    /**\r\n     * @dev Hook that is called after any transfer of tokens. This includes\r\n     * minting and burning.\r\n     *\r\n     * Calling conditions:\r\n     *\r\n     * - when `from` and `to` are both non-zero, `amount` of ``from``\u0027s tokens\r\n     * has been transferred to `to`.\r\n     * - when `from` is zero, `amount` tokens have been minted for `to`.\r\n     * - when `to` is zero, `amount` of ``from``\u0027s tokens have been burned.\r\n     * - `from` and `to` are never both zero.\r\n     *\r\n     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].\r\n     */\r\n    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}\r\n}"},"IERC20.sol":{"content":"// SPDX-License-Identifier: MIT\r\n// OpenZeppelin Contracts (last updated v4.9.0) (./IERC20.sol)\r\n\r\npragma solidity ^0.8.0;\r\n\r\n/**\r\n * @dev Interface of the ERC20 standard as defined in the EIP.\r\n */\r\ninterface IERC20 {\r\n    /**\r\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\r\n     * another (`to`).\r\n     *\r\n     * Note that `value` may be zero.\r\n     */\r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n\r\n    /**\r\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\r\n     * a call to {approve}. `value` is the new allowance.\r\n     */\r\n    event Approval(address indexed owner, address indexed spender, uint256 value);\r\n\r\n    /**\r\n     * @dev Returns the amount of tokens in existence.\r\n     */\r\n    function totalSupply() external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Returns the amount of tokens owned by `account`.\r\n     */\r\n    function balanceOf(address account) external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Moves `amount` tokens from the caller\u0027s account to `to`.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * Emits a {Transfer} event.\r\n     */\r\n    function transfer(address to, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Returns the remaining number of tokens that `spender` will be\r\n     * allowed to spend on behalf of `owner` through {transferFrom}. This is\r\n     * zero by default.\r\n     *\r\n     * This value changes when {approve} or {transferFrom} are called.\r\n     */\r\n    function allowance(address owner, address spender) external view returns (uint256);\r\n\r\n    /**\r\n     * @dev Sets `amount` as the allowance of `spender` over the caller\u0027s tokens.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\r\n     * that someone may use both the old and the new allowance by unfortunate\r\n     * transaction ordering. One possible solution to mitigate this race\r\n     * condition is to first reduce the spender\u0027s allowance to 0 and set the\r\n     * desired value afterwards:\r\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\r\n     *\r\n     * Emits an {Approval} event.\r\n     */\r\n    function approve(address spender, uint256 amount) external returns (bool);\r\n\r\n    /**\r\n     * @dev Moves `amount` tokens from `from` to `to` using the\r\n     * allowance mechanism. `amount` is then deducted from the caller\u0027s\r\n     * allowance.\r\n     *\r\n     * Returns a boolean value indicating whether the operation succeeded.\r\n     *\r\n     * Emits a {Transfer} event.\r\n     */\r\n    function transferFrom(address from, address to, uint256 amount) external returns (bool);\r\n}"},"IERC20Metadata.sol":{"content":"// SPDX-License-Identifier: MIT\r\n// OpenZeppelin Contracts v4.4.1 (IERC20Metadata.sol)\r\n\r\npragma solidity ^0.8.0;\r\n\r\nimport \"./IERC20.sol\";\r\n\r\n/**\r\n * @dev Interface for the optional metadata functions from the ERC20 standard.\r\n *\r\n * _Available since v4.1._\r\n */\r\ninterface IERC20Metadata is IERC20 {\r\n    /**\r\n     * @dev Returns the name of the token.\r\n     */\r\n    function name() external view returns (string memory);\r\n\r\n    /**\r\n     * @dev Returns the symbol of the token.\r\n     */\r\n    function symbol() external view returns (string memory);\r\n\r\n    /**\r\n     * @dev Returns the decimals places of the token.\r\n     */\r\n    function decimals() external view returns (uint8);\r\n}"},"IUniswapRouter.sol":{"content":"// SPDX-License-Identifier: MIT\r\npragma solidity ^0.8.0;\r\n\r\ninterface IPair {\r\n    function getReserves()\r\n        external\r\n        view\r\n        returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);\r\n\r\n    function token0() external view returns (address);\r\n}\r\n\r\ninterface IFactory {\r\n    function createPair(\r\n        address tokenA,\r\n        address tokenB\r\n    ) external returns (address pair);\r\n\r\n    function getPair(\r\n        address tokenA,\r\n        address tokenB\r\n    ) external view returns (address pair);\r\n}\r\n\r\ninterface IUniswapRouter {\r\n    function factory() external pure returns (address);\r\n\r\n    function WETH() external pure returns (address);\r\n\r\n    function addLiquidityETH(\r\n        address token,\r\n        uint amountTokenDesired,\r\n        uint amountTokenMin,\r\n        uint amountETHMin,\r\n        address to,\r\n        uint deadline\r\n    )\r\n        external\r\n        payable\r\n        returns (uint amountToken, uint amountETH, uint liquidity);\r\n\r\n    function swapExactTokensForTokensSupportingFeeOnTransferTokens(\r\n        uint amountIn,\r\n        uint amountOutMin,\r\n        address[] calldata path,\r\n        address to,\r\n        uint deadline\r\n    ) external;\r\n\r\n    function swapExactETHForTokens(\r\n        uint amountOutMin,\r\n        address[] calldata path,\r\n        address to,\r\n        uint deadline\r\n    ) external payable returns (uint[] memory amounts);\r\n\r\n    function swapExactTokensForETHSupportingFeeOnTransferTokens(\r\n        uint amountIn,\r\n        uint amountOutMin,\r\n        address[] calldata path,\r\n        address to,\r\n        uint deadline\r\n    ) external;\r\n}"},"Ownable.sol":{"content":"// SPDX-License-Identifier: MIT\r\n// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)\r\n\r\npragma solidity ^0.8.0;\r\n\r\nimport \"./Context.sol\";\r\n\r\n/**\r\n * @dev Contract module which provides a basic access control mechanism, where\r\n * there is an account (an owner) that can be granted exclusive access to\r\n * specific functions.\r\n *\r\n * By default, the owner account will be the one that deploys the contract. This\r\n * can later be changed with {transferOwnership}.\r\n *\r\n * This module is used through inheritance. It will make available the modifier\r\n * `onlyOwner`, which can be applied to your functions to restrict their use to\r\n * the owner.\r\n */\r\nabstract contract Ownable is Context {\r\n    address private _owner;\r\n\r\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\r\n\r\n    /**\r\n     * @dev Initializes the contract setting the deployer as the initial owner.\r\n     */\r\n    constructor() {\r\n        _transferOwnership(_msgSender());\r\n    }\r\n\r\n    /**\r\n     * @dev Throws if called by any account other than the owner.\r\n     */\r\n    modifier onlyOwner() {\r\n        _checkOwner();\r\n        _;\r\n    }\r\n\r\n    /**\r\n     * @dev Returns the address of the current owner.\r\n     */\r\n    function owner() public view virtual returns (address) {\r\n        return _owner;\r\n    }\r\n\r\n    /**\r\n     * @dev Throws if the sender is not the owner.\r\n     */\r\n    function _checkOwner() internal view virtual {\r\n        require(owner() == _msgSender(), \"Ownable: caller is not the owner\");\r\n    }\r\n\r\n    /**\r\n     * @dev Leaves the contract without owner. It will not be possible to call\r\n     * `onlyOwner` functions. Can only be called by the current owner.\r\n     *\r\n     * NOTE: Renouncing ownership will leave the contract without an owner,\r\n     * thereby disabling any functionality that is only available to the owner.\r\n     */\r\n    function renounceOwnership() public virtual onlyOwner {\r\n        _transferOwnership(address(0));\r\n    }\r\n\r\n    /**\r\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\r\n     * Can only be called by the current owner.\r\n     */\r\n    function transferOwnership(address newOwner) public virtual onlyOwner {\r\n        require(newOwner != address(0), \"Ownable: new owner is the zero address\");\r\n        _transferOwnership(newOwner);\r\n    }\r\n\r\n    /**\r\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\r\n     * Internal function without access restriction.\r\n     */\r\n    function _transferOwnership(address newOwner) internal virtual {\r\n        address oldOwner = _owner;\r\n        _owner = newOwner;\r\n        emit OwnershipTransferred(oldOwner, newOwner);\r\n    }\r\n}"}}