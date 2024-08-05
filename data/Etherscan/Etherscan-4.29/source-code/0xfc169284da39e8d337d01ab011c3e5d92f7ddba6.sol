{"Errors.sol":{"content":"// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/draft-IERC6093.sol)\npragma solidity ^0.8.25;\n\n/**\n * @dev Standard ERC-20 Errors\n * Interface of the https://eips.ethereum.org/EIPS/eip-6093[ERC-6093] custom errors for ERC-20 tokens.\n */\ninterface IERC20Errors {\n    /**\n     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.\n     * @param sender Address whose tokens are being transferred.\n     * @param balance Current balance for the interacting account.\n     * @param needed Minimum amount required to perform a transfer.\n     */\n    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);\n\n    /**\n     * @dev Indicates a failure with the token `sender`. Used in transfers.\n     * @param sender Address whose tokens are being transferred.\n     */\n    error ERC20InvalidSender(address sender);\n\n    /**\n     * @dev Indicates a failure with the token `receiver`. Used in transfers.\n     * @param receiver Address to which tokens are being transferred.\n     */\n    error ERC20InvalidReceiver(address receiver);\n\n    /**\n     * @dev Indicates a failure with the `spender`’s `allowance`. Used in transfers.\n     * @param spender Address that may be allowed to operate on tokens without being their owner.\n     * @param allowance Amount of tokens a `spender` is allowed to operate with.\n     * @param needed Minimum amount required to perform a transfer.\n     */\n    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);\n\n    /**\n     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.\n     * @param approver Address initiating an approval operation.\n     */\n    error ERC20InvalidApprover(address approver);\n\n    /**\n     * @dev Indicates a failure with the `spender` to be approved. Used in approvals.\n     * @param spender Address that may be allowed to operate on tokens without being their owner.\n     */\n    error ERC20InvalidSpender(address spender);\n}"},"IERC20.sol":{"content":"// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)\n\npragma solidity ^0.8.25;\n\n/**\n * @dev Interface of the ERC-20 standard as defined in the ERC.\n */\ninterface IERC20 {\n    /**\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\n     * another (`to`).\n     *\n     * Note that `value` may be zero.\n     */\n    event Transfer(address indexed from, address indexed to, uint256 value);\n\n    /**\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\n     * a call to {approve}. `value` is the new allowance.\n     */\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n\n    /**\n     * @dev Returns the value of tokens in existence.\n     */\n    function totalSupply() external view returns (uint256);\n\n    /**\n     * @dev Returns the value of tokens owned by `account`.\n     */\n    function balanceOf(address account) external view returns (uint256);\n\n    /**\n     * @dev Moves a `value` amount of tokens from the caller\u0027s account to `to`.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transfer(address to, uint256 value) external returns (bool);\n\n    /**\n     * @dev Returns the remaining number of tokens that `spender` will be\n     * allowed to spend on behalf of `owner` through {transferFrom}. This is\n     * zero by default.\n     *\n     * This value changes when {approve} or {transferFrom} are called.\n     */\n    function allowance(address owner, address spender) external view returns (uint256);\n\n    /**\n     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the\n     * caller\u0027s tokens.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\n     * that someone may use both the old and the new allowance by unfortunate\n     * transaction ordering. One possible solution to mitigate this race\n     * condition is to first reduce the spender\u0027s allowance to 0 and set the\n     * desired value afterwards:\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\n     *\n     * Emits an {Approval} event.\n     */\n    function approve(address spender, uint256 value) external returns (bool);\n\n    /**\n     * @dev Moves a `value` amount of tokens from `from` to `to` using the\n     * allowance mechanism. `value` is then deducted from the caller\u0027s\n     * allowance.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transferFrom(address from, address to, uint256 value) external returns (bool);\n}"},"RIZE.sol":{"content":"// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.25;\n\nimport {IERC20} from \"./IERC20.sol\";\nimport {IERC20Errors} from \"./Errors.sol\";\n\ncontract RIZE is IERC20, IERC20Errors {\n    /**\n     * @dev Wallet and smart contract variables\n     */\n    mapping(address account =\u003e uint256) private _balances;\n    mapping(address account =\u003e mapping(address spender =\u003e uint256)) private _allowances;\n    mapping(address account =\u003e uint256) private _lastActive;\n\n    bool private activityTracker;\n    uint256 private _totalSupply;\n\n    string private _name;\n    string private _symbol;\n\n    /**\n     * @dev Operation addresses\n     */\n    address private tokenOwner;\n    address private tokenDelegate;\n    address private treasury;\n\n    // Event emitted when ownder or delegate is changed, for EVM logging\n    event OwnerSet(address indexed oldOwner, address indexed newOwner);\n    event DelegateSet(address indexed oldDelegate, address indexed newDelegate);\n\n    /**\n     * @dev Modifier to check if the caller is the owner or delegate\n     */\n    modifier isOwner() {\n        require(msg.sender == tokenOwner || msg.sender == tokenDelegate, \"Caller is not owner/delegate\");\n        _;\n    }\n    modifier isSoleOwner() {\n        require(msg.sender == tokenOwner, \"Caller is not owner\");\n        _;\n    }\n\n    /**\n     * @dev Construction values\n     */\n    constructor(string memory name_, string memory symbol_) {\n        _name = name_;\n        _symbol = symbol_;\n        _mint(msg.sender, 15_000_000_000 * 10 ** decimals());\n\n        tokenOwner = msg.sender;\n        tokenDelegate = msg.sender;\n        treasury = msg.sender;\n    }\n\n    /**\n     * @dev Metadata\n     */\n    function name() public view virtual returns (string memory) {\n        return _name;\n    }\n\n    function symbol() public view virtual returns (string memory) {\n        return _symbol;\n    }\n\n    function decimals() public view virtual returns (uint8) {\n        return 18;\n    }\n\n    function totalSupply() public view virtual returns (uint256) {\n        return _totalSupply;\n    }\n\n    function balanceOf(address account) public view virtual returns (uint256) {\n        return _balances[account];\n    }\n\n    function lastActivity(address account) public view returns (uint256) {\n        if(_lastActive[account] != 0){\n            return block.timestamp - _lastActive[account]; // Returns last activity in seconds\n        }else{\n            return 0;\n        }\n        \n    }\n\n    /**\n     * @dev Last activity tracker\n     */\n    function trackActivity(bool setTracker) public isOwner{\n        activityTracker = setTracker;\n    }\n    function checkActivityTracker() public isOwner view returns(bool){\n        return activityTracker;\n    }\n    function setActivity() public{\n        _lastActive[msg.sender] = block.timestamp;\n    }\n\n\n    /**\n     * @dev Change owner or delegate\n     * Delegate can be a zero address\n     */\n    function changeOwner(address newOwner) public isSoleOwner {\n        require(newOwner != address(0), \"New owner cannot be a zero address\");\n        emit OwnerSet(tokenOwner, newOwner);\n        tokenOwner = newOwner;\n    }\n\n    function changeDelegate(address newDelegate) public isOwner {\n        emit DelegateSet(tokenDelegate, newDelegate);\n        tokenDelegate = newDelegate;\n    }\n\n    /**\n     * @dev Return owner/delegate address \n     */\n    function getOwner() isOwner external view returns (address) {\n        return tokenOwner;\n    }\n\n    function getDelegate() isOwner external view returns (address) {\n        return tokenDelegate;\n    }\n\n    /**\n     * @dev See {IERC20-transfer}. Logs activity.\n     *\n     * Requirements:\n     *\n     * - `to` cannot be the zero address.\n     * - the caller must have a balance of at least `value`.\n     * - wallet must not be locked\n     */\n    function transfer(address to, uint256 value) public virtual returns (bool) {\n        address owner = msg.sender;\n        if(activityTracker == true){\n            setActivity();\n        }\n        _transfer(owner, to, value);\n        return true;\n    }\n\n    /**\n     * @dev See {IERC20-allowance}.\n     */\n    function allowance(address owner, address spender) public view virtual returns (uint256) {\n        return _allowances[owner][spender];\n    }\n\n    /**\n     * @dev See {IERC20-approve}.\n     *\n     * NOTE: If `value` is the maximum `uint256`, the allowance is not updated on\n     * `transferFrom`. This is semantically equivalent to an infinite approval.\n     *\n     * Requirements:\n     *\n     * - `spender` cannot be the zero address.\n     */\n    function approve(address spender, uint256 value) public virtual returns (bool) {\n        address owner = msg.sender;\n        _approve(owner, spender, value, true);\n        return true;\n    }\n\n    /**\n     * @dev See {IERC20-transferFrom}.\n     *\n     * Skips emitting an {Approval} event indicating an allowance update. This is not\n     * required by the ERC. See {xref-ERC20-_approve-address-address-uint256-bool-}[_approve].\n     *\n     * NOTE: Does not update the allowance if the current allowance\n     * is the maximum `uint256`.\n     *\n     * Requirements:\n     *\n     * - `from` and `to` cannot be the zero address.\n     * - `from` must have a balance of at least `value`.\n     * - the caller must have allowance for ``from``\u0027s tokens of at least\n     * `value`.\n     */\n    function transferFrom(address from, address to, uint256 value) public virtual returns (bool) {\n        address spender = msg.sender;\n        _spendAllowance(from, spender, value);\n        _transfer(from, to, value);\n        return true;\n    }\n\n    /**\n     * @dev Moves a `value` amount of tokens from `from` to `to`.\n     *\n     * This internal function is equivalent to {transfer}, and can be used to\n     * e.g. implement automatic token fees, slashing mechanisms, etc.\n     *\n     * Emits a {Transfer} event.\n     *\n     * NOTE: This function is not virtual, {_update} should be overridden instead.\n     */\n    function _transfer(address from, address to, uint256 value) internal {\n        if (from == address(0)) {\n            revert ERC20InvalidSender(address(0));\n        }\n        if (to == address(0)) {\n            revert ERC20InvalidReceiver(address(0));\n        }\n        _update(from, to, value);\n    }\n\n    /**\n     * @dev Transfers a `value` amount of tokens from `from` to `to`, or alternatively mints (or burns) if `from`\n     * (or `to`) is the zero address. All customizations to transfers, mints, and burns should be done by overriding\n     * this function.\n     * \n     * {walletCheck} verifies if calling address belongs to the team and will prevent the transaction if the\n     * locking period is still in effect.\n     *\n     * Emits a {Transfer} event.\n     */\n    function _update(address from, address to, uint256 value) internal virtual {\n        if (from == address(0)) {\n            // Overflow check required: The rest of the code assumes that totalSupply never overflows\n            _totalSupply += value;\n        } else {\n            uint256 fromBalance = _balances[from];\n            if (fromBalance \u003c value) {\n                revert ERC20InsufficientBalance(from, fromBalance, value);\n            }\n            unchecked {\n                // Overflow not possible: value \u003c= fromBalance \u003c= totalSupply.\n                _balances[from] = fromBalance - value;\n            }\n        }\n\n        if (to == address(0)) {\n            unchecked {\n                // Overflow not possible: value \u003c= totalSupply or value \u003c= fromBalance \u003c= totalSupply.\n                _totalSupply -= value;\n            }\n        } else {\n            unchecked {\n                // Overflow not possible: balance + value is at most totalSupply, which we know fits into a uint256.\n                _balances[to] += value;\n            }\n        }\n\n        emit Transfer(from, to, value);\n    }\n\n    /**\n     * @dev Creates a `value` amount of tokens and assigns them to `account`, by transferring it from address(0).\n     * Relies on the `_update` mechanism\n     *\n     * Emits a {Transfer} event with `from` set to the zero address.\n     *\n     * NOTE: This function is not virtual, {_update} should be overridden instead.\n     */\n    function _mint(address account, uint256 value) internal {\n        if (account == address(0)) {\n            revert ERC20InvalidReceiver(address(0));\n        }\n        _update(address(0), account, value);\n    }\n\n    /**\n     * @dev Destroys a `value` amount of tokens from `account`, lowering the total supply.\n     * Relies on the `_update` mechanism.\n     *\n     * Emits a {Transfer} event with `to` set to the zero address.\n     *\n     * NOTE: This function is not virtual, {_update} should be overridden instead\n     */\n    function _burn(address account, uint256 value) internal {\n        if (account == address(0)) {\n            revert ERC20InvalidSender(address(0));\n        }\n        _update(account, address(0), value);\n    }\n\n    /**\n     * @dev External mint and burn functions to be called by owner or delegate\n     */\n    function mintTokens(uint256 value) external isOwner {\n        _mint(msg.sender, value);\n    }\n\n    function burnTokens(uint256 value) external isOwner {\n        _burn(msg.sender, value);\n    }\n\n    /**\n     * @dev Variant of {_approve} with an optional flag to enable or disable the {Approval} event.\n     *\n     * By default (when calling {_approve}) the flag is set to true. On the other hand, approval changes made by\n     * `_spendAllowance` during the `transferFrom` operation set the flag to false. This saves gas by not emitting any\n     * `Approval` event during `transferFrom` operations.\n     *\n     * Anyone who wishes to continue emitting `Approval` events on the`transferFrom` operation can force the flag to\n     * true using the following override:\n     *\n     * ```solidity\n     * function _approve(address owner, address spender, uint256 value, bool) internal virtual override {\n     *     super._approve(owner, spender, value, true);\n     * }\n     * ```\n     *\n     * Requirements are the same as {_approve}.\n     */\n    function _approve(address owner, address spender, uint256 value, bool emitEvent) internal virtual {\n        if (owner == address(0)) {\n            revert ERC20InvalidApprover(address(0));\n        }\n        if (spender == address(0)) {\n            revert ERC20InvalidSpender(address(0));\n        }\n        _allowances[owner][spender] = value;\n        if (emitEvent) {\n            emit Approval(owner, spender, value);\n        }\n    }\n\n    /**\n     * @dev Updates `owner` s allowance for `spender` based on spent `value`.\n     *\n     * Does not update the allowance value in case of infinite allowance.\n     * Revert if not enough allowance is available.\n     *\n     * Does not emit an {Approval} event.\n     */\n    function _spendAllowance(address owner, address spender, uint256 value) internal virtual {\n        uint256 currentAllowance = allowance(owner, spender);\n        if (currentAllowance != type(uint256).max) {\n            if (currentAllowance \u003c value) {\n                revert ERC20InsufficientAllowance(spender, currentAllowance, value);\n            }\n            unchecked {\n                _approve(owner, spender, currentAllowance - value, false);\n            }\n        }\n    }\n\n    /**\n     * @dev Tax processing. Sends 2 transactions to the intended recipient and the treasury.\n     * Additional public function to change the treasury wallet that collects taxes\n     */\n\n    function transferWithTax(address recipient, uint256 amount, uint8 taxPercentage) public {\n        require(recipient != address(0), \"Recipient cannot be a zero address\");\n        require(taxPercentage \u003c= 100, \"Tax percentage equals or is above 100%\");\n        uint tax = (amount / 100) * taxPercentage; // Calculate tax\n\n        require(transfer(recipient, amount - tax), \"Unable to transfer to recepient\");\n        require(transfer(treasury, tax), \"Unable to transfer tax to treasury\");\n    }\n\n    event TreasuryUpdated(address indexed oldTreasury, address indexed newTreasury);\n    function changeTreasury(address newTreasury) isSoleOwner public {\n        require(newTreasury != address(0), \"New owner cannot be a zero address\");\n        emit TreasuryUpdated(treasury, newTreasury);\n        treasury = newTreasury;\n    }\n    function getTreasury() external view returns(address){\n        return treasury;\n    }\n\n    /**\n     * @dev Batch transfer function.\n     * Will throw if the tokenHolder[] length does not match the amouts[] length.\n     */\n    function batchTransfer(address[] calldata tokenHolders, uint256[] calldata amounts) isOwner external {\n        require(tokenHolders.length == amounts.length, \"Holder list does not match amount list\");\n\n        for(uint256 i = 0; i \u003c tokenHolders.length; i++) {\n            require(transfer(tokenHolders[i], amounts[i]), \"Unable to transfer token to the account\");\n        }\n    }\n}"}}