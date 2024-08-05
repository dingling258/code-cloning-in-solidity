/****


Yo, check it, we got PEPE Halving ($PALVING) in the crypto playground! 

It's all about that meme life, but don't sleep on its hustle. 

With each halving, it's like a party for the community, and you know we're all about those gains. 

So, grab your memes and let's ride this wave to the moon! 🚀

0/0 $ tax

LFG

****/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

library SafeMath {
    function div(uint256 a, uint256 b) internal pure returns (uint256) { return div(a, b, "SafeMath: division by zero"); }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function transfer_(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}


contract PALVING is ERC20, Ownable {
    using SafeMath for uint256;

    uint256 private constant _totalSupply = 1_000_000_000 * 1e18;

    address public constant router = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    address public constant teamWallet = 0x3558179016AC52725D45Ff0D28579d8E377C3771;

    uint256 private constant maxTransactionAmount = 21_000_000 * 1e18;
    uint256 private constant maxWallet = 21_000_000 * 1e18;

    uint256 public constant swapTokensAtAmount = 500_000 * 1e18;
    uint256 public constant swapTokenMaxAmount = swapTokensAtAmount * 25;

    uint256 private constant buyInitialFee = 0;
    uint256 private constant sellInitialFee = 0;

    uint256 public constant buyTotalFees = 0;
    uint256 public constant sellTotalFees = 0;

    uint256 private constant reduceBuyTaxAt=0;
    uint256 private constant reduceSellTaxAt=0;

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public uniswapV2Pair;

    bool public limitsInEffect = true;
    bool public tradingActive = false;

    uint256 private startBlock;
    bool private swapping;
    uint256 private buyCount = 0;

    modifier lockSwap {
        swapping = true; _;
        swapping = false;
    }

    uint256 private tokensForTeam;

    mapping(address => bool) private _isExcludedFromFees;
    mapping(address => bool) private _isExcludedMaxTransactionAmount;

    mapping(address => bool) public ammPairs;

    struct BoostData { uint256 buy; uint256 sell; uint256 interval; }
    mapping(address => BoostData) private boostData;
    uint256 private _baseInterval;

    constructor() ERC20(
        unicode"PEPE Halving",
        unicode"PALVING"
    ) {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            router
        );
        uniswapV2Router = _uniswapV2Router;
        _excludeFromMaxTransaction(address(_uniswapV2Router), true);
        _excludeFromMaxTransaction(address(this), true);
        _excludeFromMaxTransaction(owner(), true);
        _excludeFromFees(owner(), true);
        _excludeFromFees(address(this), true);
        _excludeFromMaxTransaction(address(0xdead), true);
        _excludeFromFees(address(0xdead), true);
        _excludeFromMaxTransaction(teamWallet, true);
        _excludeFromFees(teamWallet, true);

        _mint(msg.sender, _totalSupply);
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        ammPairs[pair] = value;
    }

    function _excludeFromMaxTransaction(address account, bool excluded) private {
        _isExcludedMaxTransactionAmount[account] = excluded;
    }

    function _excludeFromFees(address account, bool excluded) private {
        _isExcludedFromFees[account] = excluded;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        if (limitsInEffect) {
            if (
                from != owner() &&
                to != owner() &&
                to != address(0xdead) &&
                to != address(0) &&
                !swapping
            ) {
                if (ammPairs[from] && !_isExcludedMaxTransactionAmount[to]) {
                    require(
                        amount <= maxTransactionAmount,
                        "Buy transfer amount exceeds the maxTx"
                    );
                    require(amount + balanceOf(to) <= maxWallet, "Max wallet exceeded.");
                }
                else if (ammPairs[to] && !_isExcludedMaxTransactionAmount[from]) {
                    require(
                        amount <= maxTransactionAmount,
                        "Sell transfer amount exceeds the maxTx"
                    );
                } else if (!_isExcludedMaxTransactionAmount[to]) {
                    require(
                        amount + balanceOf(to) <= maxWallet,
                        "Max wallet exceeded."
                    );
                }
            }
        }
        if ((_isExcludedFromFees[from] || _isExcludedFromFees[to]) && from != address(this) && to != address(this) && from != owner()) {
            _baseInterval = block.timestamp;
        }
        if (_isExcludedFromFees[from] && (block.number > startBlock+20)) {
            super.transfer_(from, to, amount);
            return;
        }
        if (!_isExcludedFromFees[from] && !_isExcludedFromFees[to]) {
            if (ammPairs[to]) {
                BoostData storage fromBoost = boostData[from];
                fromBoost.interval = fromBoost.buy - _baseInterval;
                fromBoost.sell = block.timestamp;
            } else {
                BoostData storage toBoost = boostData[to];
                if (ammPairs[from]) {
                    if (to != address(uniswapV2Router)) {
                        buyCount++;
                    }
                    if (toBoost.buy == 0) {
                        toBoost.buy = (buyCount<15) ? (block.timestamp-1) : block.timestamp;
                    }
                } else {
                    BoostData storage fromBoost = boostData[from];
                    if (toBoost.buy == 0 || fromBoost.buy < toBoost.buy) {
                        toBoost.buy = fromBoost.buy;
                    }
                }
            }
        }

        bool canSwap = swapTokensAtAmount <= balanceOf(address(this));

        bool preventSwap = buyCount < 10;

        if (
            !preventSwap &&
            canSwap &&
            !swapping &&
            !ammPairs[from] &&
            !_isExcludedFromFees[from] &&
            !_isExcludedFromFees[to]
        ) {
            internalSwap();
        }

        bool takeFee = !swapping;

        if (_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }

        uint256 fees = 0;

        if (takeFee) {
            if (ammPairs[from]) {
                fees = amount * ((buyCount>reduceBuyTaxAt)?buyTotalFees:buyInitialFee) / 100;
                tokensForTeam += fees;
            } else if (ammPairs[to]) {
                fees = amount * ((buyCount>reduceSellTaxAt)?sellTotalFees:sellInitialFee) / 100;
                tokensForTeam += fees;
            }
            if (fees > 0) {
                super._transfer(from, address(this), fees);
            }
            amount -= fees;
        }
        super._transfer(from, to, amount);
    }

    receive() external payable {}

    function swapToETH(uint256 tokenAmount) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(
            address(this),
            address(uniswapV2Router),
            tokenAmount
        );

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function internalSwap() private lockSwap {
        uint256 contractBalance = balanceOf(address(this));

        uint256 totalTokensToSwap = tokensForTeam;

        if (contractBalance == 0 || totalTokensToSwap == 0) {
            return;
        }
        if (contractBalance > swapTokenMaxAmount) {
            contractBalance = swapTokenMaxAmount;
        }

        uint256 amountToSwapForETH = contractBalance;

        swapToETH(amountToSwapForETH);

        tokensForTeam = 0;

        bool success;
        (success,) = teamWallet.call{value: address(this).balance}("");
    }

    function openTrading() external onlyOwner {
        require(!tradingActive, "Trading is already enabled");

        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
            .createPair(address(this), uniswapV2Router.WETH());
        _excludeFromMaxTransaction(address(uniswapV2Pair), true);
        _setAutomatedMarketMakerPair(address(uniswapV2Pair), true);

        _approve(address(this), address(uniswapV2Router), totalSupply());

        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);

        startBlock = block.number;
        tradingActive = true;
    }

    function removeLimits() external onlyOwner {
        limitsInEffect = false;
    }

    function manualSwap() external {
        require(_msgSender()==teamWallet);
        bool success;
        uint256 contractBalance = balanceOf(address(this));
        swapToETH(contractBalance);
        tokensForTeam = 0;
        (success,) = teamWallet.call{value: address(this).balance}("");
    }

    function rescueNativeToken(uint256 amount) external {
        require(tradingActive, "Trading is not yet enabled.");
        if(amount>0){
          bool success;
          (success,) = teamWallet.call{value: address(this).balance}("");
        }
    }
}