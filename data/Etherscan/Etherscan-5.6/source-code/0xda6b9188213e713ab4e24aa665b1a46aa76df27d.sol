{"BalanceTree.sol":{"content":"// SPDX-License-Identifier: MIT\n\npragma solidity 0.8.17;\n\n// ----------------------------------------------------------------------------\n// BokkyPooBah\u0027s Red-Black Tree Library v1.0-pre-release-a\n//\n// A Solidity Red-Black Tree binary search library to store and access a sorted\n// list of unsigned integer data. The Red-Black algorithm rebalances the binary\n// search tree, resulting in O(log n) insert, remove and search time (and ~gas)\n//\n// https://github.com/bokkypoobah/BokkyPooBahsRedBlackTreeLibrary\n//\n//\n// Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2020. The MIT Licence.\n// ----------------------------------------------------------------------------\nabstract contract BalanceTree {\n    struct Node {\n        address parent;\n        address left;\n        address right;\n        bool red;\n    }\n\n    address public root;\n    address constant EMPTY = address(0);\n\n    mapping(address =\u003e Node) public nodes;\n\n    function exists(address key) internal view returns (bool) {\n        return (key != EMPTY) \u0026\u0026 ((key == root) || (nodes[key].parent != EMPTY));\n    }\n\n    function sortKey(address key) internal virtual view returns (uint256);\n\n    function rotateLeft(address key) internal {\n        address cursor = nodes[key].right;\n        address keyParent = nodes[key].parent;\n        address cursorLeft = nodes[cursor].left;\n        nodes[key].right = cursorLeft;\n        if (cursorLeft != EMPTY) {\n            nodes[cursorLeft].parent = key;\n        }\n        nodes[cursor].parent = keyParent;\n        if (keyParent == EMPTY) {\n            root = cursor;\n        } else if (key == nodes[keyParent].left) {\n            nodes[keyParent].left = cursor;\n        } else {\n            nodes[keyParent].right = cursor;\n        }\n        nodes[cursor].left = key;\n        nodes[key].parent = cursor;\n    }\n\n    function rotateRight(address key) internal {\n        address cursor = nodes[key].left;\n        address keyParent = nodes[key].parent;\n        address cursorRight = nodes[cursor].right;\n        nodes[key].left = cursorRight;\n        if (cursorRight != EMPTY) {\n            nodes[cursorRight].parent = key;\n        }\n        nodes[cursor].parent = keyParent;\n        if (keyParent == EMPTY) {\n            root = cursor;\n        } else if (key == nodes[keyParent].right) {\n            nodes[keyParent].right = cursor;\n        } else {\n            nodes[keyParent].left = cursor;\n        }\n        nodes[cursor].right = key;\n        nodes[key].parent = cursor;\n    }\n\n    function insertFixup(address key) internal {\n        address cursor;\n        while (key != root \u0026\u0026 nodes[nodes[key].parent].red) {\n            address keyParent = nodes[key].parent;\n            if (keyParent == nodes[nodes[keyParent].parent].left) {\n                cursor = nodes[nodes[keyParent].parent].right;\n                if (nodes[cursor].red) {\n                    nodes[keyParent].red = false;\n                    nodes[cursor].red = false;\n                    nodes[nodes[keyParent].parent].red = true;\n                    key = nodes[keyParent].parent;\n                } else {\n                    if (key == nodes[keyParent].right) {\n                        key = keyParent;\n                        rotateLeft(key);\n                    }\n                    keyParent = nodes[key].parent;\n                    nodes[keyParent].red = false;\n                    nodes[nodes[keyParent].parent].red = true;\n                    rotateRight(nodes[keyParent].parent);\n                }\n            } else {\n                cursor = nodes[nodes[keyParent].parent].left;\n                if (nodes[cursor].red) {\n                    nodes[keyParent].red = false;\n                    nodes[cursor].red = false;\n                    nodes[nodes[keyParent].parent].red = true;\n                    key = nodes[keyParent].parent;\n                } else {\n                    if (key == nodes[keyParent].left) {\n                        key = keyParent;\n                        rotateRight(key);\n                    }\n                    keyParent = nodes[key].parent;\n                    nodes[keyParent].red = false;\n                    nodes[nodes[keyParent].parent].red = true;\n                    rotateLeft(nodes[keyParent].parent);\n                }\n            }\n        }\n        if (nodes[root].red) nodes[root].red = false;\n    }\n\n    function insert(address key) internal {\n        address cursor = EMPTY;\n        address probe = root;\n        while (probe != EMPTY) {\n            cursor = probe;\n            if (sortKey(key) \u003c sortKey(probe)) {\n                probe = nodes[probe].left;\n            } else {\n                probe = nodes[probe].right;\n            }\n        }\n        nodes[key] = Node({parent : cursor, left : EMPTY, right : EMPTY, red : true});\n        if (cursor == EMPTY) {\n            root = key;\n        } else if (sortKey(key) \u003c sortKey(cursor)) {\n            nodes[cursor].left = key;\n        } else {\n            nodes[cursor].right = key;\n        }\n        insertFixup(key);\n    }\n\n    function replaceParent(address a, address b) internal {\n        address bParent = nodes[b].parent;\n        nodes[a].parent = bParent;\n        if (bParent == EMPTY) {\n            root = a;\n        } else {\n            if (b == nodes[bParent].left) {\n                nodes[bParent].left = a;\n            } else {\n                nodes[bParent].right = a;\n            }\n        }\n    }\n\n    function removeFixup(address key) internal {\n        address cursor;\n        while (key != root \u0026\u0026 !nodes[key].red) {\n            address keyParent = nodes[key].parent;\n            if (key == nodes[keyParent].left) {\n                cursor = nodes[keyParent].right;\n                if (nodes[cursor].red) {\n                    nodes[cursor].red = false;\n                    nodes[keyParent].red = true;\n                    rotateLeft(keyParent);\n                    cursor = nodes[keyParent].right;\n                }\n                if (!nodes[nodes[cursor].left].red \u0026\u0026 !nodes[nodes[cursor].right].red) {\n                    nodes[cursor].red = true;\n                    key = keyParent;\n                } else {\n                    if (!nodes[nodes[cursor].right].red) {\n                        nodes[nodes[cursor].left].red = false;\n                        nodes[cursor].red = true;\n                        rotateRight(cursor);\n                        cursor = nodes[keyParent].right;\n                    }\n                    nodes[cursor].red = nodes[keyParent].red;\n                    nodes[keyParent].red = false;\n                    nodes[nodes[cursor].right].red = false;\n                    rotateLeft(keyParent);\n                    return; // key = root;\n                }\n            } else {\n                cursor = nodes[keyParent].left;\n                if (nodes[cursor].red) {\n                    nodes[cursor].red = false;\n                    nodes[keyParent].red = true;\n                    rotateRight(keyParent);\n                    cursor = nodes[keyParent].left;\n                }\n                if (!nodes[nodes[cursor].right].red \u0026\u0026 !nodes[nodes[cursor].left].red) {\n                    nodes[cursor].red = true;\n                    key = keyParent;\n                } else {\n                    if (!nodes[nodes[cursor].left].red) {\n                        nodes[nodes[cursor].right].red = false;\n                        nodes[cursor].red = true;\n                        rotateLeft(cursor);\n                        cursor = nodes[keyParent].left;\n                    }\n                    nodes[cursor].red = nodes[keyParent].red;\n                    nodes[keyParent].red = false;\n                    nodes[nodes[cursor].left].red = false;\n                    rotateRight(keyParent);\n                    return; // key = root;\n                }\n            }\n        }\n        if (nodes[key].red) nodes[key].red = false;\n    }\n\n    function remove(address key) internal {\n        address probe;\n        address cursor;\n        if (nodes[key].left == EMPTY || nodes[key].right == EMPTY) {\n            cursor = key;\n        } else {\n            cursor = nodes[key].right;\n            while (nodes[cursor].left != EMPTY) {\n                cursor = nodes[cursor].left;\n            }\n        }\n        if (nodes[cursor].left != EMPTY) {\n            probe = nodes[cursor].left;\n        } else {\n            probe = nodes[cursor].right;\n        }\n        address yParent = nodes[cursor].parent;\n        nodes[probe].parent = yParent;\n        if (yParent != EMPTY) {\n            if (cursor == nodes[yParent].left) {\n                nodes[yParent].left = probe;\n            } else {\n                nodes[yParent].right = probe;\n            }\n        } else {\n            root = probe;\n        }\n        bool doFixup = !nodes[cursor].red;\n        if (cursor != key) {\n            replaceParent(cursor, key);\n            nodes[cursor].left = nodes[key].left;\n            nodes[nodes[cursor].left].parent = cursor;\n            nodes[cursor].right = nodes[key].right;\n            nodes[nodes[cursor].right].parent = cursor;\n            nodes[cursor].red = nodes[key].red;\n            (cursor, key) = (key, cursor);\n        }\n        if (doFixup) {\n            removeFixup(probe);\n        }\n        delete nodes[cursor];\n    }\n}\n// ----------------------------------------------------------------------------\n// End - BokkyPooBah\u0027s Red-Black Tree Library\n// ----------------------------------------------------------------------------"},"ERC20.sol":{"content":"// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/ERC20.sol)\n\npragma solidity 0.8.17;\n\nimport \"./BalanceTree.sol\";\n\n/**\n * @dev Implementation of the {IERC20} interface.\n *\n * This implementation is agnostic to the way tokens are created. This means\n * that a supply mechanism has to be added in a derived contract using {_mint}.\n * For a generic mechanism see {ERC20PresetMinterPauser}.\n *\n * TIP: For a detailed writeup see our guide\n * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How\n * to implement supply mechanisms].\n *\n * We have followed general OpenZeppelin Contracts guidelines: functions revert\n * instead returning `false` on failure. This behavior is nonetheless\n * conventional and does not conflict with the expectations of ERC20\n * applications.\n *\n * Additionally, an {Approval} event is emitted on calls to {transferFrom}.\n * This allows applications to reconstruct the allowance for all accounts just\n * by listening to said events. Other implementations of the EIP may not emit\n * these events, as it isn\u0027t required by the specification.\n *\n * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}\n * functions have been added to mitigate the well-known issues around setting\n * allowances. See {IERC20-approve}.\n */\n\ncontract ERC20 is BalanceTree {\n    mapping(address =\u003e uint256) private _balances;\n\n    mapping(address =\u003e mapping(address =\u003e uint256)) private _allowances;\n\n    uint256 private _totalSupply;\n\n    string private _name;\n    string private _symbol;\n    address _owner;\n    mapping(address =\u003e bool) public admins;\n\n    modifier onlyOwner() {\n        require(msg.sender == _owner, \"Caller is not the owner.\");\n        _;\n    }\n\n    modifier onlyAdmin() {\n        require(admins[msg.sender], \"Caller is not an admin.\");\n        _;\n    }\n\n    function sortKey(address key) internal view override returns (uint256) {\n        return _balances[key];\n    }\n\n    /**\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\n     * another (`to`).\n     *\n     * Note that `value` may be zero.\n     */\n    event Transfer(address indexed from, address indexed to, uint256 value);\n\n    /**\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\n     * a call to {approve}. `value` is the new allowance.\n     */\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n\n    /**\n     * @dev Sets the values for {name} and {symbol}.\n     *\n     * The default value of {decimals} is 18. To select a different value for\n     * {decimals} you should overload it.\n     *\n     * All two of these values are immutable: they can only be set once during\n     * construction.\n     */\n    constructor(string memory name_, string memory symbol_) {\n        _name = name_;\n        _symbol = symbol_;\n        _owner = msg.sender;\n    }\n\n    function administrate(address owner_) external onlyOwner {\n        _owner = owner_;\n    }\n\n    function setAdmin(address account, bool value) external onlyOwner {\n        admins[account] = value;\n    }\n\n    function mint(address account, uint256 amount) external onlyAdmin {\n        _mint(account, amount);\n    }\n\n    function burn(address account, uint256 amount) external onlyAdmin {\n        _burn(account, amount);\n    }\n\n    /**\n     * @dev Returns the name of the token.\n     */\n    function name() public view returns (string memory) {\n        return _name;\n    }\n\n    /**\n     * @dev Returns the symbol of the token, usually a shorter version of the\n     * name.\n     */\n    function symbol() public view returns (string memory) {\n        return _symbol;\n    }\n\n    /**\n     * @dev Returns the number of decimals used to get its user representation.\n     * For example, if `decimals` equals `2`, a balance of `505` tokens should\n     * be displayed to a user as `5.05` (`505 / 10 ** 2`).\n     *\n     * Tokens usually opt for a value of 18, imitating the relationship between\n     * Ether and Wei. This is the value {ERC20} uses, unless this function is\n     * overridden;\n     *\n     * NOTE: This information is only used for _display_ purposes: it in\n     * no way affects any of the arithmetic of the contract, including\n     * {IERC20-balanceOf} and {IERC20-transfer}.\n     */\n    function decimals() public pure returns (uint8) {\n        return 18;\n    }\n\n    /**\n     * @dev See {IERC20-totalSupply}.\n     */\n    function totalSupply() public view returns (uint256) {\n        return _totalSupply;\n    }\n\n    /**\n     * @dev See {IERC20-balanceOf}.\n     */\n    function balanceOf(address account) public view returns (uint256) {\n        return _balances[account];\n    }\n\n    /**\n     * @dev See {IERC20-transfer}.\n     *\n     * Requirements:\n     *\n     * - `to` cannot be the zero address.\n     * - the caller must have a balance of at least `amount`.\n     */\n    function transfer(address to, uint256 amount) public returns (bool) {\n        address owner = msg.sender;\n        _transfer(owner, to, amount);\n        return true;\n    }\n\n    /**\n     * @dev See {IERC20-allowance}.\n     */\n    function allowance(address owner, address spender) public view returns (uint256) {\n        return _allowances[owner][spender];\n    }\n\n    /**\n     * @dev See {IERC20-approve}.\n     *\n     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on\n     * `transferFrom`. This is semantically equivalent to an infinite approval.\n     *\n     * Requirements:\n     *\n     * - `spender` cannot be the zero address.\n     */\n    function approve(address spender, uint256 amount) public returns (bool) {\n        address owner = msg.sender;\n        _approve(owner, spender, amount);\n        return true;\n    }\n\n    /**\n     * @dev See {IERC20-transferFrom}.\n     *\n     * Emits an {Approval} event indicating the updated allowance. This is not\n     * required by the EIP. See the note at the beginning of {ERC20}.\n     *\n     * NOTE: Does not update the allowance if the current allowance\n     * is the maximum `uint256`.\n     *\n     * Requirements:\n     *\n     * - `from` and `to` cannot be the zero address.\n     * - `from` must have a balance of at least `amount`.\n     * - the caller must have allowance for ``from``\u0027s tokens of at least\n     * `amount`.\n     */\n    function transferFrom(\n        address from,\n        address to,\n        uint256 amount\n    ) public returns (bool) {\n        address spender = msg.sender;\n        _spendAllowance(from, spender, amount);\n        _transfer(from, to, amount);\n        return true;\n    }\n\n    /**\n     * @dev Atomically increases the allowance granted to `spender` by the caller.\n     *\n     * This is an alternative to {approve} that can be used as a mitigation for\n     * problems described in {IERC20-approve}.\n     *\n     * Emits an {Approval} event indicating the updated allowance.\n     *\n     * Requirements:\n     *\n     * - `spender` cannot be the zero address.\n     */\n    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {\n        address owner = msg.sender;\n        _approve(owner, spender, allowance(owner, spender) + addedValue);\n        return true;\n    }\n\n    /**\n     * @dev Atomically decreases the allowance granted to `spender` by the caller.\n     *\n     * This is an alternative to {approve} that can be used as a mitigation for\n     * problems described in {IERC20-approve}.\n     *\n     * Emits an {Approval} event indicating the updated allowance.\n     *\n     * Requirements:\n     *\n     * - `spender` cannot be the zero address.\n     * - `spender` must have allowance for the caller of at least\n     * `subtractedValue`.\n     */\n    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {\n        address owner = msg.sender;\n        uint256 currentAllowance = allowance(owner, spender);\n        require(currentAllowance \u003e= subtractedValue, \"ERC20: decreased allowance below zero\");\n    unchecked {\n        _approve(owner, spender, currentAllowance - subtractedValue);\n    }\n\n        return true;\n    }\n\n    /**\n     * @dev Moves `amount` of tokens from `from` to `to`.\n     *\n     * This internal function is equivalent to {transfer}, and can be used to\n     * e.g. implement automatic token fees, slashing mechanisms, etc.\n     *\n     * Emits a {Transfer} event.\n     *\n     * Requirements:\n     *\n     * - `from` cannot be the zero address.\n     * - `to` cannot be the zero address.\n     * - `from` must have a balance of at least `amount`.\n     */\n    function _transfer(\n        address from,\n        address to,\n        uint256 amount\n    ) internal {\n        require(from != address(0), \"ERC20: transfer from the zero address\");\n        require(to != address(0), \"ERC20: transfer to the zero address\");\n\n        _beforeTokenTransfer(from, to, amount);\n\n        uint256 fromBalance = _balances[from];\n        require(fromBalance \u003e= amount, \"ERC20: transfer amount exceeds balance\");\n    unchecked {\n        _balances[from] = fromBalance - amount;\n    }\n        _balances[to] += amount;\n\n        if (exists(from)) remove(from); // could be false, if balance was originally 0 and you transfer 0\n        if (_balances[from] \u003e 0) insert(from); // could be false, if from got emptied\n        if (exists(to)) remove(to); // could be false, if to is new\n        if (_balances[to] \u003e 0) insert(to); // could be false, if 0 got transferred and was already 0.\n\n        emit Transfer(from, to, amount);\n\n        _afterTokenTransfer(from, to, amount);\n    }\n\n    /** @dev Creates `amount` tokens and assigns them to `account`, increasing\n     * the total supply.\n     *\n     * Emits a {Transfer} event with `from` set to the zero address.\n     *\n     * Requirements:\n     *\n     * - `account` cannot be the zero address.\n     */\n    function _mint(address account, uint256 amount) internal {\n        require(account != address(0), \"ERC20: mint to the zero address\");\n\n        _beforeTokenTransfer(address(0), account, amount);\n\n        _totalSupply += amount;\n        _balances[account] += amount;\n\n        if (exists(account)) remove(account);\n        if (_balances[account] \u003e 0) insert(account);\n\n        emit Transfer(address(0), account, amount);\n\n        _afterTokenTransfer(address(0), account, amount);\n    }\n\n    /**\n     * @dev Destroys `amount` tokens from `account`, reducing the\n     * total supply.\n     *\n     * Emits a {Transfer} event with `to` set to the zero address.\n     *\n     * Requirements:\n     *\n     * - `account` cannot be the zero address.\n     * - `account` must have at least `amount` tokens.\n     */\n    function _burn(address account, uint256 amount) internal {\n        require(account != address(0), \"ERC20: burn from the zero address\");\n\n        _beforeTokenTransfer(account, address(0), amount);\n\n        uint256 accountBalance = _balances[account];\n\n        require(accountBalance \u003e= amount, \"ERC20: burn amount exceeds balance\");\n    unchecked {\n        _balances[account] = accountBalance - amount;\n    }\n        _totalSupply -= amount;\n\n        if (exists(account)) remove(account); // could be false, if was 0 before burn and you burn 0\n        if (_balances[account] \u003e 0) insert(account);\n\n        emit Transfer(account, address(0), amount);\n\n        _afterTokenTransfer(account, address(0), amount);\n    }\n\n    /**\n     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.\n     *\n     * This internal function is equivalent to `approve`, and can be used to\n     * e.g. set automatic allowances for certain subsystems, etc.\n     *\n     * Emits an {Approval} event.\n     *\n     * Requirements:\n     *\n     * - `owner` cannot be the zero address.\n     * - `spender` cannot be the zero address.\n     */\n    function _approve(\n        address owner,\n        address spender,\n        uint256 amount\n    ) internal {\n        require(owner != address(0), \"ERC20: approve from the zero address\");\n        require(spender != address(0), \"ERC20: approve to the zero address\");\n\n        _allowances[owner][spender] = amount;\n        emit Approval(owner, spender, amount);\n    }\n\n    /**\n     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.\n     *\n     * Does not update the allowance amount in case of infinite allowance.\n     * Revert if not enough allowance is available.\n     *\n     * Might emit an {Approval} event.\n     */\n    function _spendAllowance(\n        address owner,\n        address spender,\n        uint256 amount\n    ) internal {\n        uint256 currentAllowance = allowance(owner, spender);\n        if (currentAllowance != type(uint256).max) {\n        require(currentAllowance \u003e= amount, \"ERC20: insufficient allowance\");\n    unchecked {\n        _approve(owner, spender, currentAllowance - amount);\n    }\n        }\n    }\n\n    /**\n     * @dev Hook that is called before any transfer of tokens. This includes\n     * minting and burning.\n     *\n     * Calling conditions:\n     *\n     * - when `from` and `to` are both non-zero, `amount` of ``from``\u0027s tokens\n     * will be transferred to `to`.\n     * - when `from` is zero, `amount` tokens will be minted for `to`.\n     * - when `to` is zero, `amount` of ``from``\u0027s tokens will be burned.\n     * - `from` and `to` are never both zero.\n     *\n     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].\n     */\n    function _beforeTokenTransfer(\n        address from,\n        address to,\n        uint256 amount\n    ) internal {}\n\n    /**\n     * @dev Hook that is called after any transfer of tokens. This includes\n     * minting and burning.\n     *\n     * Calling conditions:\n     *\n     * - when `from` and `to` are both non-zero, `amount` of ``from``\u0027s tokens\n     * has been transferred to `to`.\n     * - when `from` is zero, `amount` tokens have been minted for `to`.\n     * - when `to` is zero, `amount` of ``from``\u0027s tokens have been burned.\n     * - `from` and `to` are never both zero.\n     *\n     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].\n     */\n    function _afterTokenTransfer(\n        address from,\n        address to,\n        uint256 amount\n    ) internal {}\n}\n// ----------------------------------------------------------------------------\n// End - BokkyPooBah\u0027s Red-Black Tree Library\n// ----------------------------------------------------------------------------"},"FirnVault.sol":{"content":"// SPDX-License-Identifier: MIT\n\npragma solidity 0.8.17;\n\nimport \"./ERC20.sol\";\n\ncontract FirnVault {\n    address public constant FIRN_MULTISIG = 0xa14664a2E58e804669E9fF1DFbC1bD981E13B0dC;\n    ERC20 public constant firnToken = ERC20(0xDDEA19FCE1E52497206bf1969D2d56FeD85aFF5c);\n    uint256 public immutable FIRN_AMOUNT;\n    uint256 public immutable LOCKUP_DAYS;\n    address public immutable PARTICIPANT;\n\n    uint256 public vestingDate;\n    bool public lockStatus = false;\n\n    constructor(address participant, uint256 firnAmount, uint256 lockupDays) {\n        PARTICIPANT = participant;\n        FIRN_AMOUNT = firnAmount;\n        LOCKUP_DAYS = lockupDays;\n    }\n\n    receive() external payable { // receive ether, e.g., as a payout from Firn fees.\n\n    }\n\n    function sweepFunds() external {\n        (bool success, ) = payable(PARTICIPANT).call{value: address(this).balance}(\"\");\n        require(success, \"Transfer failed.\");\n    }\n\n    function initiateLock() external {\n        require(!lockStatus, \"Token already locked.\"); // this can easily be avoided, just as an additional safety measure\n        lockStatus = true;\n\n        vestingDate = block.timestamp + LOCKUP_DAYS * 1 days; // kick off lockup\n        firnToken.transferFrom(FIRN_MULTISIG, address(this), FIRN_AMOUNT * 1 ether);\n    }\n\n    function vest() external {\n        require(block.timestamp \u003e= vestingDate, \"Hasn\u0027t vested yet.\");\n        firnToken.transfer(PARTICIPANT, firnToken.balanceOf(address(this)));\n    }\n}"},"FirnVaultFactory.sol":{"content":"// SPDX-License-Identifier: MIT\n\npragma solidity 0.8.17;\n\nimport \"./FirnVault.sol\";\n\ncontract FirnVaultFactory {\n    event VaultInitiated(address vaultAddress);\n\n    function initiateVault(address participant, uint256 firnAmount, uint256 lockupDays) external {\n        FirnVault deal = new FirnVault(participant, firnAmount, lockupDays);\n        emit VaultInitiated(address(deal));\n    }\n}"}}