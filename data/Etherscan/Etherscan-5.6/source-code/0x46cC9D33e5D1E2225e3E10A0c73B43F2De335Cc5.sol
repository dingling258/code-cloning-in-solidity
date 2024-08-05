/**
 *Submitted for verification at Etherscan.io on 2024-03-17
*/

/**
 *Submitted for verification at Etherscan.io on 2022-08-16
*/

// SPDX-License-Identifier: MIT



pragma solidity ^0.8.15;


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
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }
    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }
    
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }
    
}



abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; 
        return msg.data;
    }
}


library Address {
    
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }
    
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }
    
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }
    
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }
    
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }
    
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }


    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }
    
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                 assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
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
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}


interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface IUniswapV2Pair {
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

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}


contract TLB is Context, IERC20, Ownable, ReentrancyGuard  { 
    using SafeMath for uint256;
    using Address for address;


    // Tracking status of wallets
    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => bool) public _isExcludedFromFee; 

   
    bool public noFeeToTransfer = true;


    //----Wallets--------//

   
    address private deadWallet = 0x000000000000000000000000000000000000dEaD; 
    address public immutable treasury;
    address public immutable teamVault;
    address public immutable ecosystem; 
    address public immutable rewards; 
    address public immutable charity;
    IERC20 public shiba;


    //----Token----//

    string private constant _name = "TLB Token"; 
    string private constant _symbol = "TLBS";  
    uint8 private constant _decimals = 18;
    uint256 private constant _tTotal = 3 * 10**9 * 10**18; //3 billion
    

    // balance to trigger swap
    
    uint256 private swapTrigger = _tTotal.div(30000); 

    // This is the max fee that the contract will accept, it is hard-coded to protect buyers
    // This includes the buy AND the sell fee!
    uint256 private maxPossibleFee = 15; 


    // Setting the initial fees
    uint256 private _TotalFee = 10;
    uint256 public _buyFee = 5;
    uint256 public _sellFee = 5;

    uint256 public shibaTax = 2;
    uint256 public burnTax = 2;
    uint256 public liquidityTax = 5;


    // 'Previous fees' are used to keep track of fee settings when removing and restoring fees
    uint256 private _previousTotalFee = _TotalFee; 
    uint256 private _previousBuyFee = _buyFee; 
    uint256 private _previousSellFee = _sellFee; 

    /*

    WALLET LIMITS 
    
    */

    // Max wallet holding (% at launch)
    uint256 public _maxWalletToken = _tTotal.div(100);
   

    // Maximum transaction amount (% at launch)
    uint256 public _maxTxAmount = _tTotal.div(10000); 
    

    /* 

    UNISWAP SET UP

    */
                                     
    IUniswapV2Router02 public uniswapV2Router;
    // Pancake V2 Router 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    //Pancake Testnet V2 Router 0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3;
    // Uniswap V2 Router 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    // Quickswap V2 Router 0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff;


   address public uniswapV2pair;
    bool public inSwapAndLiquify;
    bool public swapAndLiquifyEnabled = true;
    
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event SwapAndLiquify(uint256, uint256, uint256, uint256);
    event Burn(address, address, uint256);
    event BurnShiba(address, address, uint256);
    
    // Prevent processing while already processing! 
    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    /*

    DEPLOY TOKENS TO OWNER

    Constructor functions are only called once. This happens during contract deployment.
    This function deploys the total token supply to the owner wallet and creates the PCS pairing

    */
    
    constructor (
        address _treasury,
        address _teamVault,
        address _ecosystem,
        address _rewards,
        address _charity,
        address _shiba
    ) {


         treasury = _treasury;
        teamVault = _teamVault;
        ecosystem = _ecosystem;
        rewards = _rewards;
        charity = _charity;
        shiba = IERC20(_shiba);

        uint256 teamAmount = _tTotal.mul(19).div(100);
        uint256 rewardsAmount = _tTotal.mul(12).div(100);
        uint256 ecosystemAmount = _tTotal.mul(18).div(100);
        uint256 charityAmount = _tTotal.mul(3).div(100);

    





        
        _tOwned[treasury] = _tTotal.sub(teamAmount).sub(rewardsAmount).sub(ecosystemAmount).sub(charityAmount);
        _tOwned[teamVault] = teamAmount;
        _tOwned[rewards] = rewardsAmount;
        _tOwned[ecosystem] = ecosystemAmount;
        _tOwned[charity] = charityAmount; 
       
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D); 
      
       uniswapV2pair = IUniswapV2Factory(_uniswapV2Router.factory())
           .createPair(address(this), _uniswapV2Router.WETH());
       
        uniswapV2Router = _uniswapV2Router;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[address(_uniswapV2Router)] = true;
        _isExcludedFromFee[uniswapV2pair] = true;
 
         _approve(address(this), address(_uniswapV2Router), type(uint256).max);
        _approve(address(this), uniswapV2pair, type(uint256).max);
        _approve(msg.sender, address(_uniswapV2Router), type(uint256).max); 
 
        
        
    }


    /*

    STANDARD ERC20 COMPLIANCE FUNCTIONS

    */

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
        return _tOwned[account];
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

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }



    
    // Set a wallet address so that it does not have to pay transaction fees
    function excludeFromFee(address account) public onlyOwner {
        require(_isExcludedFromFee[account] == false, "Already excluded");
        _isExcludedFromFee[account] = true;
    }
    
    // Set a wallet address so that it has to pay transaction fees
    function includeInFee(address account) public onlyOwner {
        require(_isExcludedFromFee[account] == true, "Already not excluded");
        _isExcludedFromFee[account] = false;
    }


   

    // This function is required so that the contract can receive ETH from pancakeswap
    receive() external payable {}



   
   


    // Remove all fees
    function removeAllFee() private {
        
        _previousBuyFee = _buyFee; 
        _previousSellFee = _sellFee; 
        _previousTotalFee = _TotalFee;

        _buyFee = 0;
        _sellFee = 0;
        _TotalFee = 0;

    }
    
    // Restore all fees
    function restoreAllFee() private {
    
    _TotalFee = _previousTotalFee;
    _buyFee = _previousBuyFee; 
    _sellFee = _previousSellFee; 

    }


    // Approve a wallet to sell tokens
    function _approve(address owner, address spender, uint256 amount) private {
        //require(owner != address(0) && spender != address(0), "ERR: zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);

    }

    function _transferStandard(
        address from,
        address to,
        uint256 amount
     ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

    
        uint256 fromBalance = balanceOf(from);
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
    unchecked {
        _tOwned[from] = fromBalance - amount;
        // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
        // decrementing then incrementing.
        _tOwned[to] += amount;
    }

        emit Transfer(from, to, amount);

        
    }
    

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        

        // Limit wallet total
        if (to != owner() &&
            to != address(this) &&
            to != address(uniswapV2Router) &&
            to != uniswapV2pair &&
            to != deadWallet &&
            from != owner()){
            uint256 heldTokens = balanceOf(to);
            require((heldTokens + amount) <= _maxWalletToken,"You are trying to buy too many tokens. You have reached the limit for one wallet.");}

         uint256 currentTotalFee = _TotalFee;

        // Limit the maximum number of tokens that can be bought or sold in one transaction
        if (from != owner() && to != owner())
            require(amount <= _maxTxAmount, "You are trying to buy more than the max transaction limit.");


        
     


        require(from != address(0) && to != address(0), "ERR: Using 0 address!");
        require(amount > 0, "Token value must be higher than zero.");



        if(
            balanceOf(address(this)) >= swapTrigger && 
            !inSwapAndLiquify &&
            swapAndLiquifyEnabled 
            )
        {  
            
            
            uint256 contractTokenBalance = balanceOf(address(this));
            if(contractTokenBalance > _maxTxAmount) {contractTokenBalance = _maxTxAmount;}
            if(contractTokenBalance > 0){
            swapAndLiquify(contractTokenBalance);
        }
        }
        if(inSwapAndLiquify){
            _transferStandard(from, to, amount);
        }


        
        bool takeFee = true;

      

          if((_isExcludedFromFee[from] && _isExcludedFromFee[to]) || (noFeeToTransfer && from != uniswapV2pair && to != uniswapV2pair)){
            takeFee = false;
        } else if (from == uniswapV2pair){_TotalFee = _buyFee;} else if (to == uniswapV2pair){_TotalFee = _sellFee;}
        

        _tokenTransfer(from,to,amount,takeFee);


        if (from == uniswapV2pair || to == uniswapV2pair){_TotalFee = currentTotalFee;} 
       


    }




    // Processing tokens from contract
    function swapAndLiquify(uint256 balance) private lockTheSwap returns (bool) {
        uint256 balanceInContract = balance;
        uint256 initialEthBalance = address(this).balance;
        uint256 lf = liquidityTax;
        uint256 bf = burnTax;
        uint256 sf = shibaTax;
        
       uint256 liquidityAmount = balance.mul(lf).div(100);
        uint256 burnAmount = balance.mul(bf).div(100);
        uint256 shibaAmount = balance.mul(sf).div(100);

       //uint256 newTokenBalanceInContract = balance - liquidityAmount - burnAmount - shibaAmount;

       uint256 half = liquidityAmount.div(2);
       uint256 otherHalf = liquidityAmount - half;
       
        swapTokensForETH(half);

        uint256 newEthBalance = address(this).balance.sub(initialEthBalance);

        addLiquidity(otherHalf, newEthBalance);

       

        if (burnAmount > 0) {
            _burn(burnAmount);
        }

        if(shibaAmount > 0){
            _burnShiba(shibaAmount);
        }

         emit SwapAndLiquify(
            balanceInContract,
            liquidityAmount,
            burnAmount,
            shibaAmount
              
        );

        

        return true;

       

        
    }

   


    function checkLiquidity(uint256 tokenAmount, address tokenAddress) public view returns (bool){
        address wethAddress = uniswapV2Router.WETH();
        IUniswapV2Pair pair = IUniswapV2Pair(uniswapV2pair);

        // Get reserves for the token and WETH
        (uint112 reserve0, uint112 reserve1,) = pair.getReserves();

        // Identify the correct reserve for the token
        uint256 tokenReserve = tokenAddress < wethAddress ? reserve0 : reserve1;

        // Check if the reserve is sufficient for the swap
        require(tokenReserve >= tokenAmount, "Insufficient liquidity for this swap");

        return true;
    }
    





    // Swapping tokens for ETH using PancakeSwap 
    function swapTokensForETH(uint256 tokenAmount) private {

        bool liq = checkLiquidity(tokenAmount, address(this));
        require(liq, "Insufficient liquidity");

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
       
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, 
            path,
            address(this),
            block.timestamp
        );
    }

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
       

        // add the liquidity
        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            owner(),
            block.timestamp
        );
    }


    function _burnShiba(uint256 burnAmount) internal returns (bool){
        if(shiba.balanceOf(address(this)) >= burnAmount){
             shiba.transfer(deadWallet, burnAmount);
             
             emit BurnShiba(address(this), deadWallet, burnAmount);

            return true;
        } else {
        return false;  
        } 
       
    }

    function _burn(uint256 burnAmount) internal {
        _transfer(address(this), deadWallet, burnAmount);
            
        emit Burn(address(this), deadWallet, burnAmount);
    }

   

     /*

    TOKEN TRANSFERS

    */

    // Check if token transfer needs to process fees
    function _tokenTransfer(address sender, address recipient, uint256 amount,bool takeFee) private {
        
        
        if(!takeFee){
            removeAllFee();
           
            }
            _transferTokens(sender, recipient, amount);
        
        if(!takeFee)
            restoreAllFee();
    }

    // Redistributing tokens and adding the fee to the contract address
    function _transferTokens(address sender, address recipient, uint256 tAmount) private {
        (uint256 tTransferAmount, uint256 tDev) = _getValues(tAmount);
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tTransferAmount);
        _tOwned[address(this)] = _tOwned[address(this)].add(tDev);   
        emit Transfer(sender, recipient, tTransferAmount);
        emit Transfer(sender, recipient, tDev);
    }


    // Calculating the fee in tokens
    function _getValues(uint256 tAmount) private view returns (uint256, uint256) {
        uint256 tDev = tAmount*_TotalFee/100;
        uint256 tTransferAmount = tAmount.sub(tDev);
        return (tTransferAmount, tDev);
    }


   
    


    function _set_Fees(uint256 Buy_Fee, uint256 Sell_Fee) external onlyOwner() {

        require((Buy_Fee + Sell_Fee) <= maxPossibleFee, "Fee is too high!");
        _sellFee = Sell_Fee;
        _buyFee = Buy_Fee;

    }

     // Option to set fee or no fee for transfer (just in case the no fee transfer option is exploited in future!)
    // True = there will be no fees when moving tokens around or giving them to friends! (There will only be a fee to buy or sell)
    // False = there will be a fee when buying/selling/tranfering tokens
    // Default is true
    function set_Transfers_Without_Fees(bool true_or_false) external onlyOwner {
        noFeeToTransfer = true_or_false;
    }



    /*

    PROCESSING TOKENS - SET UP

    */
    
    // Toggle on and off to auto process tokens to ETH wallet 
    function set_Swap_And_Liquify_Enabled(bool true_or_false) public onlyOwner {
        swapAndLiquifyEnabled = true_or_false;
        emit SwapAndLiquifyEnabledUpdated(true_or_false);
    }

    // This will set the amount of accumulated fees required before the 'swapAndLiquify' function triggers
    function setSwapTrigger(uint256 _newLimit) external onlyOwner {
        swapTrigger = _newLimit;
    }

    function setMaxWallet(uint256 _newLimit) external onlyOwner {
        require(_newLimit >= 2*10**6*10**18, "Cannot set limit too low");
        _maxWalletToken = _newLimit;
    }


     /*

    PURGE STUCK TOKENS - Add the random token address and a wallet to send them to

    */

    
    // Remove random tokens from the contract and send to a wallet
    function remove_Stuck_Tokens(address stuck_Token_Address, address send_to_wallet, uint256 number_of_tokens) public onlyOwner returns(bool _sent){
        uint256 stuckBalance = IERC20(stuck_Token_Address).balanceOf(address(this));
        if (number_of_tokens > stuckBalance){number_of_tokens = stuckBalance;}
        _sent = IERC20(stuck_Token_Address).transfer(send_to_wallet, number_of_tokens);
    }

    


   
    


}