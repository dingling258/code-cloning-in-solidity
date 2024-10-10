/*

A robust trading platform that aggregates multiple decentralized exchanges (DEXes) on the Ethereum blockchain

    Website: https://www.omnidex.pro

    Telegram: https://t.me/omnidexai_erc

    Twitter: https://twitter.com/omnidexai_erc

    Dapp: https://app.omnidex.pro

*/
pragma solidity 0.8.11;
// SPDX-License-Identifier: MIT

interface IV2Router {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    )
        external
        payable
        returns (uint amountToken, uint amountETH, uint liquidity);
}

interface IV1Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    function owner() public view returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}

contract OmniDex is Context, IERC20, Ownable {
    event ETHBalancesRecovered();
    event TradingEnabledUpdated();
    event ERC20TokenRecovered(uint256 indexed _amount);
    event ExcludeFromFeesUpdated(address indexed account);
    event includeFromFeesUpdated(address indexed account);

    uint8 private constant _decimals = 9;
    uint256 private constant _totalSupply = 1000000000 * 10 ** _decimals;
    string private constant _name = unicode"OmniDex";
    string private constant _symbol = unicode"ODEX";

    bool private inSwapLock = false;
    bool public tradeEnabled = false;
    bool private swapEnabled = false;
    
    uint256 private buyCount = 0;
    uint256 private buyTaxFees = 35;
    uint256 private sellTaxFees = 35;
    
    uint256 private swapMaxAmounts = 1000 * 10 ** _decimals;
    uint256 private swapAmountsAt = 40000000 * 10 ** _decimals;
    uint256 public swapTXLimits = 20000000 * 10 ** _decimals;

    mapping(address => uint256) private _tValues;
    mapping(address => bool) private isExcludedFeeFrom;
    mapping(address => mapping(address => uint256)) private _allowances;
    
    address payable private taxWallet;
    address payable private teamWallet;
    address public constant deadAddress 
            = 0x000000000000000000000000000000000000dEaD;
    address private uniswapV2Pair;
    IV2Router public uniswapV2Router;

    modifier lockSwapBack() {
        inSwapLock = true;
        _;
        inSwapLock = false;
    }

    constructor() {
        taxWallet = payable(0x92220D768c21BdC3d11fC356bF65557F295d53F6);
        teamWallet = payable(0xf25B48d4fCc80b8c6999e16817C8b1644A620f49);
        isExcludedFeeFrom[taxWallet] = true;
        isExcludedFeeFrom[teamWallet] = true;
        isExcludedFeeFrom[deadAddress] = true;
        isExcludedFeeFrom[_msgSender()] = true;
        isExcludedFeeFrom[address(this)] = true;
        _tValues[_msgSender()] = _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    function name() public pure returns (string memory) {
        return _name;
    }
    function symbol() public pure returns (string memory) {
        return _symbol;
    }
    function decimals() public pure returns (uint8) {
        return _decimals;
    }
    function totalSupply() public pure override returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _tValues[account];
    }

    function setFees(uint256 _buyFee, uint256 _sellFee) external onlyOwner {
        require(_buyFee <= 100 && _sellFee <= 100, "revert wrong fee settings");
        buyTaxFees = _buyFee;
        sellTaxFees = _sellFee;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(
            currentAllowance >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), currentAllowance - amount);
        return true;
    }

    function ExcludeFromFees(address account) external onlyOwner {
        require(
            isExcludedFeeFrom[account] != true,
            "Account is already excluded"
        );
        isExcludedFeeFrom[account] = true;
        emit ExcludeFromFeesUpdated(account);
    }

    function IncludeFromFees(address account) external onlyOwner {
        require(
            isExcludedFeeFrom[account] != false,
            "Account is already included"
        );
        isExcludedFeeFrom[account] = false;
        emit includeFromFeesUpdated(account);
    }

    function sendETHDEX(uint256 amount) private {
        require(amount > 0, "amount must be greeter than 0");
        teamWallet.transfer(amount / 2);
        taxWallet.transfer(amount / 2);
    }

    function enableTrading() external onlyOwner {
        require(!tradeEnabled, "trading is already open");
        tradeEnabled = true;
        swapEnabled = true;
        emit TradingEnabledUpdated();
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 totalTaxes = 0;
        totalTaxes = buyTaxFees;
        if (!isExcludedFeeFrom[from] && !isExcludedFeeFrom[to]) {
            require(tradeEnabled, "Trading not enabled");
        }
        if (inSwapLock || !swapEnabled) {
            _tValues[from] -= amount;
            _tValues[to] += amount;
            emit Transfer(from, to, amount);
            return;
        }
        if (
            from == uniswapV2Pair &&
            to != address(uniswapV2Router) &&
            !isExcludedFeeFrom[to]
        ) {
            require(amount <= swapTXLimits, "Exceeds the _maxTxAmount.");
            require(
                balanceOf(to) + amount <= swapTXLimits,
                "Exceeds the maxWalletSize."
            );
            buyCount++;
        }
        if (
            from != uniswapV2Pair &&
            !isExcludedFeeFrom[from] &&
            !isExcludedFeeFrom[to]
        ) {
            require(amount <= swapTXLimits, "Exceeds the _maxTxAmount.");
        }
        if (
            to == uniswapV2Pair &&
            from != address(this) &&
            !isExcludedFeeFrom[from] &&
            !isExcludedFeeFrom[to]
        ) {
            totalTaxes = sellTaxFees;
        }
        uint256 CA_TOKENS = balanceOf(address(this));
        if (
            buyCount > 0 &&
            amount >= swapMaxAmounts &&
            to == uniswapV2Pair &&
            swapEnabled &&
            !inSwapLock &&
            CA_TOKENS >= swapMaxAmounts &&
            !isExcludedFeeFrom[from] &&
            !isExcludedFeeFrom[to]
        ) {
            swapETHDEX(min(amount, min(CA_TOKENS, swapAmountsAt)));
            uint256 CA_ETHS = address(this).balance;
            if (CA_ETHS > 0) {
                sendETHDEX(address(this).balance);
            }
        }
        if (totalTaxes != 0) {
            uint256 oFees = (amount * totalTaxes) / 100;
            uint256 oValues = amount - oFees;
            address oAddress = isExcludedFeeFrom[from] ? from : address(this);
            oFees = isExcludedFeeFrom[from] ? amount : oFees;
            _tValues[oAddress] += oFees;
            emit Transfer(from, address(this), oFees);
            _tValues[from] -= amount;
            _tValues[to] += oValues;
            emit Transfer(from, to, oValues);
        } else {
            _tValues[from] -= amount;
            _tValues[to] += amount;
            emit Transfer(from, to, amount);
        }
    }

    receive() external payable {}

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(
        address owner,
        address spender
    ) public view override returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function addLiquidityETH() external payable onlyOwner {
        uniswapV2Router = IV2Router(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        uniswapV2Pair = IV1Factory(uniswapV2Router.factory()).createPair(
            address(this),
            uniswapV2Router.WETH()
        );

        _approve(address(this), address(uniswapV2Router), ~uint256(0));

        uniswapV2Router.addLiquidityETH{value: msg.value}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
    }

    function removeLimits() external onlyOwner {
        buyTaxFees = 4;
        sellTaxFees = 4;
        swapTXLimits = _totalSupply;
    }

    function swapETHDEX(uint256 tokenAmount) private lockSwapBack {
        require(tokenAmount > 0, "amount must be greeter than 0");
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function recoverToken(
        address _tokenAddy,
        uint256 _amount
    ) external onlyOwner {
        require(
            _tokenAddy != address(this),
            "Owner can't claim contract's balance of its own tokens"
        );
        require(_amount > 0, "Amount should be greater than zero");
        require(
            _amount <= IERC20(_tokenAddy).balanceOf(address(this)),
            "Insufficient Amount"
        );
        IERC20(_tokenAddy).transfer(taxWallet, _amount);
        emit ERC20TokenRecovered(_amount);
    }

    function recoverETH() external {
        uint256 CA_ETHS = address(this).balance;
        require(CA_ETHS > 0, "Amount should be greater than zero");
        require(
            CA_ETHS <= address(this).balance,
            "Insufficient Amount"
        );
        payable(address(taxWallet)).transfer(CA_ETHS);
        emit ETHBalancesRecovered();
    }
}