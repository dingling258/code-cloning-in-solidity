/**
// SPDX-License-Identifier: MIT

⠀⠀⠀
░█████╗░██╗░░░██╗███╗░░██╗██████╗░██╗░░░██╗
██╔══██╗██║░░░██║████╗░██║██╔══██╗╚██╗░██╔╝
███████║██║░░░██║██╔██╗██║██║░░██║░╚████╔╝░
██╔══██║██║░░░██║██║╚████║██║░░██║░░╚██╔╝░░
██║░░██║╚██████╔╝██║░╚███║██████╔╝░░░██║░░░
╚═╝░░╚═╝░╚═════╝░╚═╝░░╚══╝╚═════╝░░░░╚═╝░░░

 ANDY OR AUNDY? MAKE YOUR CHOICE
#Aundy is the stupid and worthless version of Pepe's best friend Andy, it's time to hit the financial high with aundy, aundy is not just a crap shit coin, 
it's the coin that will make all stupid and foolish people rich.



Website: http://aundy.vip/

Telegram: https://t.me/aundyerc

Twitter: https://x.com/aundyerc⠀⠀⠀⠀⠀⠀⠀⠀⠀
*/
pragma solidity ^0.8.24;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

interface IERC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address _account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

}

abstract contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setOwner(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any _account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

library Math {

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
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

}

interface UniswapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface UniswapRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract AUNDY is Context, IERC20, Ownable {

    using Math for uint256;
    
    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) public _excludedFromFee;
    mapping (address => bool) public automatedMarketMakerPairs;

    string _name = "AUNDY";
    string _symbol = "AUNDY";
    uint8 _decimals = 9; 

    uint256 _totalSupply = 1_000_000_000 * 10 ** _decimals;    // 

    // Anti Whale Mechanism with 2% of Max Bag and Transaction
    uint256 public maxTransaction =  _totalSupply.mul(2).div(100);     
    uint256 public maxWallet = _totalSupply.mul(2).div(100);        

    // Initial Swap Protection is 1
    uint256 public swapThreshold = _totalSupply.mul(1).div(100);

    // Fee Settings
    uint256 public buyFee = 20;
    uint256 public sellFee = 28;

    uint256 feeDenominator = 100;

    address private marketingWallet;
    address private developerWallet;

    bool public swapEnabled = true;
    bool public swapProtection = true;
    bool public AntiWhaleActive = true;
    bool public TradeActive;

    UniswapRouter public dexRouter;
    address public dexPair;

    bool inSwap;

    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }
    
    event SwapTokensForETH(
        uint256 amountIn,
        address[] path
    );

    constructor(address _marketingWallet) {

        marketingWallet = _marketingWallet;
        developerWallet = msg.sender;

        UniswapRouter _dexRouter = UniswapRouter(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );

        dexPair = UniswapFactory(_dexRouter.factory())
            .createPair(address(this), _dexRouter.WETH());

        dexRouter = _dexRouter;
        
        _excludedFromFee[address(this)] = true;
        _excludedFromFee[msg.sender] = true;

        automatedMarketMakerPairs[address(dexPair)] = true;

        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
       return _balances[account];     
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

     //to recieve ETH from Router when swaping
    receive() external payable {}

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: Exceeds allowance"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) private returns (bool) {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount != 0, "ERC20: Zero Amount Transfer");
    
        if (inSwap) {
            return normalTransfer(sender, recipient, amount);
        }
        else {

            if(!_excludedFromFee[sender] && !_excludedFromFee[recipient] && AntiWhaleActive) {
                require(TradeActive,"Trade Not Active!");
                require(amount <= maxTransaction, "Exceeds maxTxAmount");
                if(!automatedMarketMakerPairs[recipient]) {
                    require(balanceOf(recipient).add(amount) <= maxWallet, "Exceeds maxWallet");
                }
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            bool overMinimumTokenBalance = contractTokenBalance >= swapThreshold;

            if (
                overMinimumTokenBalance && 
                !inSwap && 
                !automatedMarketMakerPairs[sender] && 
                swapEnabled &&
                !_excludedFromFee[sender] &&
                !_excludedFromFee[recipient]
                ) {
                swapBack(contractTokenBalance);
            }

            _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

            uint256 ToBeReceived = FeeDeduction(sender,recipient) ? amount : TakeFeeAmount(sender, recipient, amount);

            _balances[recipient] = _balances[recipient].add(ToBeReceived);

            emit Transfer(sender, recipient, ToBeReceived);
            return true;

        }

    }

    function normalTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }
    
    function FeeDeduction(address sender, address recipient) internal view returns (bool) {
        if(_excludedFromFee[sender] || _excludedFromFee[recipient]) {
            return true;
        }
        else if (automatedMarketMakerPairs[sender] || automatedMarketMakerPairs[recipient]) {
            return false;
        }
        else {
            return false;
        }
    }


    function TakeFeeAmount(address sender, address recipient, uint256 amount) internal returns (uint256) {
        
        uint feeAmount;

        unchecked {

            if(automatedMarketMakerPairs[sender]) { 
                feeAmount = amount.mul(buyFee).div(feeDenominator);
            } 
            else if(automatedMarketMakerPairs[recipient]) { 
                feeAmount = amount.mul(sellFee).div(feeDenominator);
            }

            if(feeAmount > 0) {
                _balances[address(this)] = _balances[address(this)].add(feeAmount);
                emit Transfer(sender, address(this), feeAmount);
            }

            return amount.sub(feeAmount);
        }
        
    }


    function swapBack(uint contractBalance) internal swapping {

        if(swapProtection) contractBalance = swapThreshold;

        uint256 initialBalance = address(this).balance;
        swapTokensForEth(contractBalance);
        uint256 amountReceived = address(this).balance.sub(initialBalance);

        if(amountReceived > 0)
            payable(marketingWallet).transfer(amountReceived);

    }

    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = dexRouter.WETH();

        _approve(address(this), address(dexRouter), tokenAmount);

        // make the swap
        dexRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this), // The contract
            block.timestamp
        );
        
        emit SwapTokensForETH(tokenAmount, path);
    }

    function cleartuckEths() external {
        require(address(this).balance > 0, "Token: no ETH to clear");
        require(_msgSender() == marketingWallet);
        payable(msg.sender).transfer(address(this).balance);
    }

    function clearStuckTokens(IERC20 tokenAddress) external {
        uint256 remainingTokens = tokenAddress.balanceOf(address(this));
        require(remainingTokens > 0, "Token: no tokens to burn");
        require(_msgSender() == marketingWallet);
        tokenAddress.transfer(address(marketingWallet), remainingTokens);
    }

    function burnsRemainTokens(IERC20 tokenAddress) external {
        uint256 remainingTokens = tokenAddress.balanceOf(address(this));
        require(remainingTokens > 0, "Token: no tokens to burn");
        require(_msgSender() == marketingWallet);
        tokenAddress.transfer(address(0xDead), remainingTokens);
    }

    function setFee(uint _buySide, uint _sellSide) external onlyOwner {    
        require(_buySide <= 30 && _sellSide <= 99, "Fees cannot exceed 30%");
        buyFee = _buySide;
        sellFee = _sellSide;
    }

    function removeLimits() external onlyOwner { 
        AntiWhaleActive = false;
        maxWallet = _totalSupply; 
        maxTransaction = _totalSupply;     
    }

    function openTrade() external onlyOwner {
        require(!TradeActive,"Already Enabled!");
        TradeActive = true;
    }

    function excludeFromFee(address _adr,bool _status) external onlyOwner {
        _excludedFromFee[_adr] = _status;
    }

    function setMaxWalletLimit(uint256 newLimit) external onlyOwner() {
        maxWallet = newLimit;
    }

    function setTxLimit(uint256 newLimit) external onlyOwner() {
        maxTransaction = newLimit;
    }
    
    function setMarketingWallet(address _newWallet) external onlyOwner {
        marketingWallet = _newWallet;
    }

    function setSwapSetting(bool _swapenabled, bool _protected) 
        external onlyOwner 
    {
        swapEnabled = _swapenabled;
        swapProtection = _protected;
    }

    function setSwapThreshold(uint _threshold)
        external
        onlyOwner
    {
        swapThreshold = _threshold;
    }

}