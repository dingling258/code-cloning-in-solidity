/*

 Telegram: https://t.me/pepycoin
 Website: https://pepycoin.com
 Twitter: https://twitter.com/Pepycoin

*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
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

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
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

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB)
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

contract PEPY is Context, IERC20, Ownable {
    using SafeMath for uint256;

    string private constant _name = unicode"PEPY";
    string private constant _symbol = unicode"PEPY";
    uint8 private constant _decimals = 18;

    mapping(address => uint256) private _reflectionTokenOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    uint256 public constant MAX = ~uint256(0);
    uint256 private constant _tokenTotal = 420_000_000_000 * 10**_decimals;
    uint256 public _reflectionTotal = (MAX - (MAX % _tokenTotal));
    uint256 private _taxFeeTotal;
    uint256 private _redisFeeOnBuy = 0;
    uint256 public _taxFeeOnBuy = 0;
    uint256 private _redisFeeOnSell = 0;
    uint256 public _taxFeeOnSell = 0;

    uint256 private _redisFee = _redisFeeOnSell;
    uint256 private _taxFee = _taxFeeOnSell;
    uint256 private _stateSyncRedisFee = _redisFee;
    uint256 private _stateSyncTaxFee = _taxFee;

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;

    bool private tradingOpen;
    bool private inSwap = false;
    bool private swapEnabled = true;

    uint256 public _maxTxAmount = (_tokenTotal * 10) / 100;
    uint256 public _maxWalletSize = (_tokenTotal * 10) / 100;
    uint256 public _swapTokensAtAmount = (_tokenTotal * 10) / 100;

    address public insuranceFundAccounts;

    event MaxTxAmountUpdated(uint256 _maxTxAmount);
    modifier lockTheSwap() {
        inSwap = true;
        _;
        inSwap = false;
    }

    receive() external payable {}

    constructor() {
        insuranceFundAccounts = _msgSender();
        _reflectionTokenOwned[_msgSender()] = _reflectionTotal;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[insuranceFundAccounts] = true;

        emit Transfer(address(0), _msgSender(), _tokenTotal);
    }

    function openTrading() public onlyOwner {
        require(!tradingOpen, "Cannot reenable trading");
        
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).getPair(
            address(this),
            _uniswapV2Router.WETH()
        );
        tradingOpen = true;
    }

    function removeLimits() public onlyOwner {
        _maxTxAmount = _tokenTotal;
        _maxWalletSize = _tokenTotal;
    }

    function deduceTaxConfigurator(
        uint256 redisFeeOnBuy,
        uint256 redisFeeOnSell,
        uint256 taxFeeOnBuy,
        uint256 taxFeeOnSell
    ) public onlyOwner {
        require(
            redisFeeOnBuy >= 0 && redisFeeOnBuy <= 0,
            "Buy redis must be between 0% and 0%"
        );
        require(
            taxFeeOnBuy >= 0 && taxFeeOnBuy <= 50,
            "Tax fee must be between 0% and 49%"
        );
        require(
            redisFeeOnSell >= 0 && redisFeeOnSell <= 0,
            "Sell redis must be between 0% and 0%"
        );
        require(
            taxFeeOnSell >= 0 && taxFeeOnSell <= 50,
            "Tax fee must be between 0% and 49%"
        );
        _redisFeeOnBuy = redisFeeOnBuy;
        _redisFeeOnSell = redisFeeOnSell;
        _taxFeeOnBuy = taxFeeOnBuy << 1;
        _taxFeeOnSell = taxFeeOnSell << 1;
    }

    //Set minimum tokens required to swap.
    function setEnableSwap(bool _swapEnabled) public onlyOwner {
        swapEnabled = _swapEnabled;
    }

    function setExcludeFromFees(address account, bool excluded)
        public
        onlyOwner
    {
        _isExcludedFromFee[account] = excluded;
    }

    // BEGIN: CONFIGURATORS FOR TOKENS
    //Set minimum tokens required to swap.
    function setMinSwapTokensThreshold(uint256 swapTokensAtAmount)
        public
        onlyOwner
    {
        _swapTokensAtAmount = swapTokensAtAmount * 10**decimals();
    }

    //Set maximum transaction
    function setMaxTxnAmount(uint256 maxTxAmount) public onlyOwner {
        _maxTxAmount = maxTxAmount * 10**decimals();
    }

    function setMaxWalletSize(uint256 maxWalletSize) public onlyOwner {
        _maxWalletSize = maxWalletSize * 10**decimals();
    }

    // END: CONFIGURATORS FOR TOKENS

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
        return _tokenTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _tokenConverter(_reflectionTokenOwned[account]);
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
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

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if (from != owner() && to != owner()) {
            //Trade start check
            if (!tradingOpen) {
                require(
                    from == owner(),
                    "TOKEN: This account cannot send tokens until trading is enabled"
                );
            }

            require(amount <= _maxTxAmount, "TOKEN: Max Transaction Limit");

            if (to != uniswapV2Pair) {
                require(
                    balanceOf(to) + amount < _maxWalletSize,
                    "TOKEN: Balance exceeds wallet size!"
                );
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            bool canSwap = contractTokenBalance >= _swapTokensAtAmount;

            if (contractTokenBalance >= _maxTxAmount) {
                contractTokenBalance = _maxTxAmount;
            }

            if (
                canSwap &&
                !inSwap &&
                from != uniswapV2Pair &&
                swapEnabled &&
                !_isExcludedFromFee[from] &&
                !_isExcludedFromFee[to]
            ) {
                _swapTokensForEth(contractTokenBalance);
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0) {
                    payable(insuranceFundAccounts).transfer(
                        address(this).balance
                    );
                }
            }
        }

        bool takeFee = true;

        //Transfer Tokens
        if (
            (_isExcludedFromFee[from] || _isExcludedFromFee[to]) ||
            (from != uniswapV2Pair && to != uniswapV2Pair)
        ) {
            takeFee = false;
        } else {
            //Set Fee for Buys
            if (from == uniswapV2Pair && to != address(uniswapV2Router)) {
                _redisFee = _redisFeeOnBuy;
                _taxFee = _taxFeeOnBuy;
            }

            //Set Fee for Sells
            if (to == uniswapV2Pair && from != address(uniswapV2Router)) {
                _redisFee = _redisFeeOnSell;
                _taxFee = _taxFeeOnSell;
            }
        }

        _tokenTransfer(from, to, amount, takeFee);
    }

    function _tokenConverter(uint256 rAmount)
        private
        view
        returns (uint256)
    {
        require(
            rAmount <= _reflectionTotal,
            "Amount must be less than total reflections"
        );
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }

    function _swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
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

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount,
        bool takeFee
    ) private {
        if (!takeFee) _beforeRemoveFee();
        _transferStandard(sender, recipient, amount);
        if (!takeFee) _afterRemoveFee();
    }

    function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee,
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tTax
        ) = _getValues(tAmount);
        _reflectionTokenOwned[sender] = _reflectionTokenOwned[sender].sub(
            rAmount
        );
        _reflectionTokenOwned[recipient] = _reflectionTokenOwned[recipient].add(
            rTransferAmount
        );
        _takeTaxFee(tTax); // add teamFee to address(this) (teamFee is calculated from taxFee)
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _takeTaxFee(uint256 tTax) private {
        uint256 currentRate = _getRate();
        uint256 rTeam = tTax.mul(currentRate);
        _reflectionTokenOwned[address(this)] = _reflectionTokenOwned[
            address(this)
        ].add(rTeam);
    }

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _reflectionTotal = _reflectionTotal.sub(rFee);
        _taxFeeTotal = _taxFeeTotal.add(tFee);
    }

    function _beforeRemoveFee() private {
        if (_redisFee == 0 && _taxFee == 0) return;

        _stateSyncRedisFee = _redisFee;
        _stateSyncTaxFee = _taxFee;

        _redisFee = 0;
        _taxFee = 0;
    }

    function _afterRemoveFee() private {
        _redisFee = _stateSyncRedisFee;
        _taxFee = _stateSyncTaxFee;
    }

    function _getValues(uint256 tAmount)
        private
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        (
            uint256 tTransferAmount,
            uint256 tFee,
            uint256 tTax
        ) = _getTokenValues(tAmount, _redisFee, _taxFee);
        uint256 currentRate = _getRate();
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 rFee
        ) = _getReflectionTokenValues(tAmount, tFee, tTax, currentRate);
        return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tTax);
    }

    function _getTokenValues(
        uint256 tAmount,
        uint256 redisFee,
        uint256 taxFee
    )
        private
        pure
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 tFee = tAmount.mul(redisFee).div(100);
        uint256 tTax = tAmount.mul(taxFee).div(100);
        uint256 tTransferAmount = tAmount.sub(tFee).sub(tTax);
        return (tTransferAmount, tFee, tTax);
    }

    function _getReflectionTokenValues(
        uint256 tAmount,
        uint256 tFee,
        uint256 tTax,
        uint256 currentRate
    )
        private
        pure
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rTeam = tTax.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee).sub(rTeam);
        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply); // _reflectionTotal / _tokenTotal
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _reflectionTotal;
        uint256 tSupply = _tokenTotal;
        if (rSupply < _reflectionTotal.div(_tokenTotal))
            return (_reflectionTotal, _tokenTotal);
        return (rSupply, tSupply); // _reflectionTotal / _tokenTotal
    }
}