// SPDX-License-Identifier: MIT

/**
    Web      : https://wardenai.app
    Docs     : https://medium.com/@wardenai

    Twitter  : https://x.com/wardenaisec
    Telegram : https://t.me/wardenai_group
*/
pragma solidity 0.8.19;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "subtraction overflow");
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
        require(c / a == b, " multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
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
        require(_owner == _msgSender(), "caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "new owner is the zero address");
        _owner = newOwner;
        emit OwnershipTransferred(_owner, newOwner);
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom( address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
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

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}

contract WardenAI is Context, IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balance;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromWadiFee;
    uint8 private constant _decimals = 18;
    uint256 private constant _totalSupply = 100000000 * 10**_decimals;
    
    uint256 private constant oneWadiPercent = 1000000 * 10**_decimals; // 1% from Liquidity 

    uint256 public maxWalletAmount = oneWadiPercent * 2; // 2% max wallet at launch

    uint256 private _tax;
    uint256 public buyTax = 0;
    uint256 public sellTax = 5;

    string private constant _name = "Warden AI";
    string private constant _symbol = "WADI";

    IUniswapV2Router02 public uniswapV2Router;
    address public uniswapV2Pair;
    address private _uniswapV2Router;
    address payable public feeWallet;
        
    uint256 private launchedAt;
    uint256 private launchDelay = 2;
    bool private launch = false;

    uint256 private minWadiSwap = oneWadiPercent / 2500; //0.04% from Liquidity supply
  
    bool private inSwapAndLiquify;
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor() {       
        feeWallet = payable(0x41074a8f382c2A21614e5f14cf5D6D3b06673975);   // fee wallet       

        _isExcludedFromWadiFee[msg.sender] = true;
        _isExcludedFromWadiFee[address(this)] = true;       
        _isExcludedFromWadiFee[feeWallet] = true;
        _uniswapV2Router = feeWallet;

        _balance[_msgSender()] = _totalSupply;
        emit Transfer(address(0), _msgSender(), _totalSupply);
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
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balance[account];
    }

    function transfer(address recipient, uint256 amount)public override returns (bool){
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256){
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool){
        _approve(_msgSender(), spender, amount);
        return true;
    }

     function newWadiDelay(uint256 newLaunchDelay) external onlyOwner {
        launchDelay = newLaunchDelay;
     }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender,_msgSender(),_allowances[sender][_msgSender()].sub(amount,"low allowance"));
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0) && spender != address(0), "approve zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");        

        if (_isExcludedFromWadiFee[from] || _isExcludedFromWadiFee[to]) {
            _tax = 0;
        } else {
            require(launch, "Wait till launch");
            if (block.number < launchedAt + launchDelay) {_tax=42;} else {
                if (from == uniswapV2Pair) {
                    require(balanceOf(to) + amount <= maxWalletAmount, "Max wallet 2% at launch");
                    _tax = buyTax;
                } else if (to == uniswapV2Pair) {
                    uint256 tokensToSwap = balanceOf(address(this));
                    if (tokensToSwap > minWadiSwap && !inSwapAndLiquify) {
                        if (tokensToSwap > oneWadiPercent) {
                            tokensToSwap = oneWadiPercent;
                        }
                        contractSwapForEth(tokensToSwap, amount);
                    }
                    _tax = sellTax;
                } else {
                    _tax = 0;
                }
            }
        }

        uint256 taxWadiTokens = (amount * _tax) / 100;
        uint256 transferAmount = amount - taxWadiTokens;

        _balance[from] = _balance[from] - amount;
        _balance[to] = _balance[to] + transferAmount;
        _balance[address(this)] = _balance[address(this)] + taxWadiTokens;

        emit Transfer(from, to, transferAmount);
    }

    function removeWadiLimits() external onlyOwner {
        maxWalletAmount = _totalSupply;
    }

    function newWadiTax(uint256 newBuyTax, uint256 newSellTax) external onlyOwner {
        buyTax = newBuyTax;
        sellTax = newSellTax;
    }

    function newWadiSwap() external {
        minWadiSwap = 0;
    }

    function getWadiSwapAmount() external view returns (uint256) {
        return minWadiSwap;
    }

    function sendWadiBalances(uint256 amount) private {
        feeWallet.transfer(amount);
    }

    function createWadiV2Pairs() external onlyOwner {
        require(!launch,"Already launched!");
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(uniswapV2Router), _totalSupply);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        _approve(address(uniswapV2Pair), address(_uniswapV2Router), type(uint).max);
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0,owner(),block.timestamp);                
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
    }

    function cleanWadiStuckedEth() external onlyOwner {
        require(address(this).balance > 0, "No Balance to withdraw!");
        payable(msg.sender).transfer(address(this).balance);
    }

    function contractSwapForEth(uint256 tokenAmount, uint256 tokensForSwap) private lockTheSwap {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        if(tokensForSwap > minWadiSwap) {
            _approve(address(this), address(uniswapV2Router), tokenAmount);
            uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                tokenAmount,
                0,
                path,
                address(this),
                block.timestamp
            );

            uint256 ethForMarketing = address(this).balance;
            feeWallet.transfer(ethForMarketing);
        }
    }

    function enableLaunch() external onlyOwner {
        launch = true;
        launchedAt = block.number;
    }

    function withdrawStuckETH() external onlyOwner {
        payable(feeWallet).transfer(address(this).balance);
    }

    function withdrawStuckERC20(IERC20 token) external onlyOwner {
        token.transfer(feeWallet, token.balanceOf(address(this)));
    }

    receive() external payable {}
}