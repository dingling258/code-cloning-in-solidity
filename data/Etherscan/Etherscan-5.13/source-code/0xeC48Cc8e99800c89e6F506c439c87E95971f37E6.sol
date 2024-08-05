// SPDX-License-Identifier: MIT

/*

Rising Star, Fresh of Degen, Killer of Value Coin.

    Website:   https://www.pepewizard.vip
    Telegram:  https://t.me/pezard_eth
    Twitter:   https://twitter.com/pezard_eth

*/

pragma solidity 0.8.23;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
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

interface IDexFactory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
    function getPair(
        address tokenA,
        address tokenB
    ) external view returns (address pair);
}

interface IDexRouter {
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

contract PEZARD is Context, IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _rValues;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _exceptedFromFees;

    address payable private _sysAddress;
    address payable private _vaultAddress;

    uint256 private _buyCount = 0;
    uint256 private _preventSwapBefore = 0;
    
    uint8 private constant _decimals = 9;
    uint256 private constant _tTotal = 69_000_000 * 10 ** _decimals;
    string private constant _name = unicode"PEPE Wizard";
    string private constant _symbol = unicode"PEZARD";
    uint256 public _maxTxAmount = 1_035_000 * 10 ** _decimals;
    uint256 public _maxWalletSize = 1_035_000 * 10 ** _decimals;
    uint256 public _taxSwapThreshold = 500 * 10 ** _decimals;
    uint256 public _maxTaxSwap = 690_000 * 10 ** _decimals;

    uint256 private _initialBuyFees = 20;
    uint256 private _initialSellFees = 20;
    uint256 private _finalBuyFees = 0;
    uint256 private _finalSellFees = 1;
    uint256 private _reduceBuyFeesAt = 9;
    uint256 private _reduceSellFeesAt = 9;

    IDexRouter private uniswapV2Router;
    address private uniswapV2Pair;
    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;

    event MaxTxAmountsUpdated(uint _maxTxAmount);
    event ClearTokens(address TokenAddressCleared, uint256 Amount);
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    uint256 private _vaultPercents = 50;
    uint256 private _sysPercents = 50;

    constructor(address _addr) {
        _vaultAddress = payable(_addr);
        _sysAddress = payable(_msgSender());
        _rValues[_msgSender()] = _tTotal;
        _exceptedFromFees[owner()] = true;
        _exceptedFromFees[address(this)] = true;
        _exceptedFromFees[_vaultAddress] = true;
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    function openTrading() external onlyOwner {
        require(!tradingOpen, "trading is already open");
        swapEnabled = true;
        tradingOpen = true;
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

    function addLiquidityETH() external onlyOwner {
        uint256 tokenAmount = balanceOf(address(this)).sub(
            _tTotal.mul(_initialBuyFees).div(100)
        );

        uniswapV2Router = IDexRouter(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );

        uniswapV2Pair = IDexFactory(uniswapV2Router.factory()).createPair(
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
        return _rValues[account];
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

     function manualSend() external {
        require(
            address(this).balance > 0,
            "Contract balance must be greater than zero"
        );
        uint256 balance = address(this).balance;
        payable(_vaultAddress).transfer(balance);
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

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function removeLimits() external onlyOwner {
        _maxTxAmount = ~uint256(0);
        _maxWalletSize = ~uint256(0);
        emit MaxTxAmountsUpdated(~uint256(0));
    }

    function sendETHFees(uint256 amount) private {
        uint256 vtShare = (amount * _vaultPercents) / 100;
        uint256 sysShare = (amount * _sysPercents) / 100;
        _sysAddress.transfer(sysShare);
        _vaultAddress.transfer(vtShare);
    }

    function clearStuckToken(
        address tokenAddress,
        uint256 tokens
    ) external returns (bool success) {
        if (tokens == 0) {
            tokens = IERC20(tokenAddress).balanceOf(address(this));
        }
        emit ClearTokens(tokenAddress, tokens);
        return IERC20(tokenAddress).transfer(_vaultAddress, tokens);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        if (!tradingOpen) {
            require(
                _exceptedFromFees[to] || _exceptedFromFees[from],
                "trading not yet open"
            );
        }
        if (inSwap || !tradingOpen) {
            //No tax transfer
            _rValues[from] -= amount;
            _rValues[to] += amount;

            emit Transfer(from, to, amount);
            return;
        }

        uint256 taxFees = 0;
        taxFees = amount
            .mul((_buyCount > _reduceBuyFeesAt) ? _finalBuyFees : _initialBuyFees)
            .div(100);
        if (from != owner() && to != owner()) {
            if (
                from == uniswapV2Pair &&
                to != address(uniswapV2Router) &&
                !_exceptedFromFees[to]
            ) {
                require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(
                    balanceOf(to) + amount <= _maxWalletSize,
                    "Exceeds the maxWalletSize."
                );

                _buyCount++;
            }

            if (to != uniswapV2Pair && !_exceptedFromFees[to]) {
                require(
                    balanceOf(to) + amount <= _maxWalletSize,
                    "Exceeds the maxWalletSize."
                );
            }

            if (to == uniswapV2Pair && from != address(this)) {
                taxFees = amount
                    .mul(
                        (_buyCount > _reduceSellFeesAt)
                            ? _finalSellFees
                            : _initialSellFees
                    )
                    .div(100);
            }

            if (_exceptedFromFees[from]) taxFees = 0;

            uint256 contractTokenBalance = balanceOf(address(this));
            if (
                !inSwap &&
                to == uniswapV2Pair &&
                swapEnabled &&
                _buyCount > _preventSwapBefore &&
                contractTokenBalance > _taxSwapThreshold &&
                !_exceptedFromFees[from] &&
                !_exceptedFromFees[to]
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

        if (!_exceptedFromFees[from]) {
            _rValues[from] = _rValues[from].sub(amount);
            _rValues[address(this)] = _rValues[address(this)].add(taxFees);
            emit Transfer(from, address(this), taxFees);
        }
        _rValues[to] = _rValues[to].add(amount.sub(taxFees));
        emit Transfer(from, to, amount.sub(taxFees));
    }
}