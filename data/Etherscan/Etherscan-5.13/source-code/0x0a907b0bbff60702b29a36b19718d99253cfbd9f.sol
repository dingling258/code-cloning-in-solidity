/**
Discover QUANTITATIVE LIQUIDITY MIXING (QLix), 
your trusted platform for enhanced cryptocurrency transactions. 
QLix combines the functionalities of a multi-chain bridge and a mixer, 
delivered through our user-friendly Telegram bot technology.


$QLIX token on Ethereum.

Web: https://www.qlixbot.io/
X: https://twitter.com/qlixbot
TG: https://t.me/JoinQLixBot

Bot: https://t.me/QLixOfficialBot
*/

// File: N.sol

// SPDX-License-Identifier: MIT

/**


*/

pragma solidity = 0.8.9;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
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

    event Mint(address indexed sender, uint amount0, uint amount1);
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

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
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


contract ERC20 is Context, IERC20, IERC20Metadata {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
/**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
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
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
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

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
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

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library SafeMathInt {
    int256 private constant MIN_INT256 = int256(1) << 255;
    int256 private constant MAX_INT256 = ~(int256(1) << 255);

    /**
     * @dev Multiplies two int256 variables and fails on overflow.
     */
    function mul(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a * b;

        // Detect overflow when multiplying MIN_INT256 with -1
        require(c != MIN_INT256 || (a & MIN_INT256) != (b & MIN_INT256));
        require((b == 0) || (c / b == a));
        return c;
    }

    /**
     * @dev Division of two int256 variables and fails on overflow.
     */
    function div(int256 a, int256 b) internal pure returns (int256) {
        // Prevent overflow when dividing MIN_INT256 by -1
        require(b != -1 || a != MIN_INT256);

        // Solidity already throws when dividing by 0.
        return a / b;
    }

    /**
     * @dev Subtracts two int256 variables and fails on overflow.
     */
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));
        return c;
    }

    /**
     * @dev Adds two int256 variables and fails on overflow.
     */
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    /**
     * @dev Converts to absolute value, and fails on overflow.
     */
    function abs(int256 a) internal pure returns (int256) {
        require(a != MIN_INT256);
        return a < 0 ? -a : a;
    }


    function toUint256Safe(int256 a) internal pure returns (uint256) {
        require(a >= 0);
        return uint256(a);
    }
}

library SafeMathUint {
  function toInt256Safe(uint256 a) internal pure returns (int256) {
    int256 b = int256(a);
    require(b >= 0);
    return b;
  }
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

pragma solidity >= 0.8.9;



contract QLIX is ERC20, Ownable {
    using SafeMath for uint256;

    IUniswapV2Router02 public immutable uniswapV2Router;
    address public immutable uniswapV2Pair;
    address public constant deadAddress = address(0xdead);
    address public liquidityAddress;

    bool private swapping;

    uint256 public maxTransactionAmount;
    uint256 public swapTokensAtAmount;
    uint256 public maxWallet;

    uint256 public supply;

    address public marketingAddress;
    address public developmentAddress;

    bool public tradingActive = true;
    
    bool public transferDelayActive = true;

    bool public limitsInEffect = true;
    bool public swapEnabled = true;

    bool public _renounceDelayFunction = false;
    bool public _renounceFeeFunctions = false;
    bool public _renounceMaxUpdateFunctions = false;
    bool public _renounceMarketMakerPairChanges = false;
    bool public _renounceWalletChanges = false;
    bool public _renounceExcludeInclude = false;

    mapping(address => uint256) private _holderLastTransferTimestamp;

    uint256 public buyBurnFee;
    uint256 public buyMarketingFee;
    uint256 public buyDevelopmentFee;
    uint256 public buyTotalFees;

    uint256 public sellBurnFee;
    uint256 public sellMarketingFee;
    uint256 public sellDevelopmentFee;
    uint256 public sellTotalFees;

    uint256 public feeUnits = 100;

    uint256 public tokensForBurn;
    uint256 public tokensForMarketing;
    uint256 public tokensForDevelopment;

    // uint256 private _previousBuyLiquidityFee = 0;
    // uint256 private _previousSellLiquidityFee = 0;

    uint256 public maxWalletTotal;
    uint256 public maxTransaction;
    uint256 public walletTransferDelayTime;

    /******************/

    // exlcude from fees and max transaction amount
    mapping (address => bool) private _isExcludedFromFees;
    mapping (address => bool) public _isExcludedMaxTransactionAmount;

    // Store the automatic market maker pair addresses. Any transfer *to* these addresses
    // could be subject to a maximum transfer amount
    mapping (address => bool) public automatedMarketMakerPairs;

    event UpdateUniswapV2Router(address indexed newAddress, address indexed oldAddress);

    event ExcludeFromFees(address indexed account, bool isExcluded);

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiqudity);
    event updateHolderLastTransferTimestamp(address indexed account, uint256 timestamp);


    constructor() ERC20("QLix", "QLIX") {

        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

        excludeFromMaxTransaction(address(_uniswapV2Router), true);
        uniswapV2Router = _uniswapV2Router;

        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), _uniswapV2Router.WETH());
        excludeFromMaxTransaction(address(uniswapV2Pair), true);
        _setAutomatedMarketMakerPair(address(uniswapV2Pair), true);

        uint256 _buyBurnFee = 0;
        uint256 _buyMarketingFee = 9;
        uint256 _buyDevelopmentFee = 1;

        uint256 _sellBurnFee = 0;
        uint256 _sellMarketingFee = 19;
        uint256 _sellDevelopmentFee = 1;

        uint256 totalSupply = 1000000 * (10 ** 18);
        supply += totalSupply;

        maxWallet = 2;
        maxTransaction = 2;
        walletTransferDelayTime = 0;

        maxTransactionAmount = supply * maxTransaction / 100;
        swapTokensAtAmount = supply * 5 / 100000; // 0.005% swap wallet;
        maxWalletTotal = supply * maxWallet / 100;

        buyBurnFee = _buyBurnFee;
        buyMarketingFee = _buyMarketingFee;
        buyDevelopmentFee = _buyDevelopmentFee;
        buyTotalFees = buyBurnFee + buyMarketingFee + buyDevelopmentFee;

        sellBurnFee = _sellBurnFee;
        sellMarketingFee = _sellMarketingFee;
        sellDevelopmentFee = _sellDevelopmentFee;
        sellTotalFees = sellBurnFee + sellMarketingFee + sellDevelopmentFee;

        marketingAddress = 0xF00A9F5474237E8a895ADE51Cc28067028E70279;
        developmentAddress = 0x13f68253E026fADb33350804D8AA83dbb08472Cd;

        excludeFromFees(owner(), true);
        excludeFromFees(address(this), true);
        excludeFromFees(address(0xdead), true);

        excludeFromMaxTransaction(owner(), true);
        excludeFromMaxTransaction(address(this), true);
        excludeFromMaxTransaction(address(0xdead), true);

        _approve(owner(), address(uniswapV2Router), totalSupply);
        _mint(msg.sender, totalSupply);
    }

    receive() external payable {}

    function toggleTransferDelayActive () external onlyOwner {
      require(!_renounceDelayFunction, "Cannot update wallet transfer delay time after renouncement");
        transferDelayActive = !transferDelayActive;
    }

    // function toggleLiquidityFeeActive () external onlyOwner {
    //   require(!_renounceFeeFunctions, "Cannot update fees after renouncemennt");
    //     if (liquidityFeeActive) {
    //     _previousBuyLiquidityFee = buyLiquidityFee;
    //     _previousSellLiquidityFee = sellLiquidityFee;
    //     }
    //     buyLiquidityFee = liquidityFeeActive ? 0 : _previousBuyLiquidityFee;
    //     sellLiquidityFee = liquidityFeeActive ? 0 : _previousSellLiquidityFee;
    //     liquidityFeeActive = !liquidityFeeActive;
    // }

    function enableTrading() external onlyOwner {
        buyBurnFee = 0;
        buyMarketingFee = 9;
        buyDevelopmentFee = 1;
        buyTotalFees = buyBurnFee + buyMarketingFee + buyDevelopmentFee;

        sellBurnFee = 0;
        sellMarketingFee = 19;
        sellDevelopmentFee = 1;
        sellTotalFees = sellBurnFee + sellMarketingFee + sellDevelopmentFee;

        walletTransferDelayTime = 180;

        tradingActive = true;
        //liquidityFeeActive = true;
    }

    function updateMaxTransaction(uint256 newNum) external onlyOwner {
      require(!_renounceMaxUpdateFunctions, "Cannot update max transaction amount after renouncement");
        require(newNum >= 1);
        maxTransaction = newNum;
        updateLimits();
    }

    function updateMaxWallet(uint256 newNum) external onlyOwner {
      require(!_renounceMaxUpdateFunctions, "Cannot update max transaction amount after renouncement");
        require(newNum >= 1);
        maxWallet = newNum;
        updateLimits();
    }

    function updateWalletTransferDelayTime(uint256 newNum) external onlyOwner{
      require(!_renounceDelayFunction, "Cannot update wallet transfer delay time after renouncement");
        walletTransferDelayTime = newNum;
    }

    function excludeFromMaxTransaction(address updAds, bool isEx) public onlyOwner {
      require(!_renounceMaxUpdateFunctions, "Cannot update max transaction amount after renouncement");
        _isExcludedMaxTransactionAmount[updAds] = isEx;
    }

    // if want fractional % in future, need to increase the fee units
    function updateFeeUnits(uint256 newNum) external onlyOwner {
      require(!_renounceFeeFunctions, "Cannot update fees after renouncement");
        feeUnits = newNum;
    }

    function updateBuyFees(uint256 _burnFee, uint256 _marketingFee, uint256 _buyDevelopmentFee) external onlyOwner {
      require(!_renounceFeeFunctions, "Cannot update fees after renouncement");
        buyBurnFee = _burnFee;
        buyMarketingFee = _marketingFee;
        buyDevelopmentFee = _buyDevelopmentFee;
        buyTotalFees = buyBurnFee + buyMarketingFee + buyDevelopmentFee;
        require(buyTotalFees <= (feeUnits/15), "Buy fees must be 15% or less");
    }

    function updateSellFees(uint256 _burnFee, uint256 _marketingFee, uint256 _developmentFee) external onlyOwner {
      require(!_renounceFeeFunctions, "Cannot update fees after renouncement");
        sellBurnFee = _burnFee;
        sellMarketingFee = _marketingFee;
        sellDevelopmentFee = _developmentFee;
        sellTotalFees = sellBurnFee + sellMarketingFee + sellDevelopmentFee;
        require(sellTotalFees <= (feeUnits/25), "Sell fees must be 25% or less");
    }

    function updateMarketingAddress(address newWallet) external onlyOwner {
      require(!_renounceWalletChanges, "Cannot update wallet after renouncement");
        marketingAddress = newWallet;
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner {
      require(!_renounceExcludeInclude, "Cannot update excluded accounts after renouncement");
        _isExcludedFromFees[account] = excluded;
        emit ExcludeFromFees(account, excluded);
    }

    function includeInFees(address account) public onlyOwner {
      require(!_renounceExcludeInclude, "Cannot update excluded accounts after renouncement");
        excludeFromFees(account, false);
    }

    function setLiquidityAddress(address newAddress) public onlyOwner {
      require(!_renounceWalletChanges, "Cannot update wallet after renouncement");
        liquidityAddress = newAddress;
    }

    function updateLimits() private {
        maxTransactionAmount = supply * maxTransaction / 100;
        swapTokensAtAmount = supply * 5 / 10000; // 0.05% swap wallet;
        maxWalletTotal = supply * maxWallet / 100;
    }

    function setAutomatedMarketMakerPair(address pair, bool value) public onlyOwner {
      require(!_renounceMarketMakerPairChanges, "Cannot update market maker pairs after renouncement");
        require(pair != uniswapV2Pair, "The pair cannot be removed from automatedMarketMakerPairs");

        _setAutomatedMarketMakerPair(pair, value);
    }

    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        automatedMarketMakerPairs[pair] = value;

        emit SetAutomatedMarketMakerPair(pair, value);
    }

    function isExcludedFromFees(address account) public view returns(bool) {
        return _isExcludedFromFees[account];
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

         if(amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        if(limitsInEffect){
            if (
                from != owner() &&
                to != owner() &&
                to != address(0) &&
                to != address(0xdead) &&
                !swapping
            ){
                if(!tradingActive){
                    require(_isExcludedFromFees[from] || _isExcludedFromFees[to], "Trading is not active.");
                }

                // if the transfer delay is enabled, will block adding to liquidity/sells (transactions to AMM pair)
                if (transferDelayActive && automatedMarketMakerPairs[to]) {
                        require(block.timestamp >= _holderLastTransferTimestamp[tx.origin] + walletTransferDelayTime, "Transfer delay is active.Only one sell per ~walletTransferDelayTime~ allowed.");
                }

                // add the wallet to the _holderLastTransferTimestamp(address, timestamp) map
                _holderLastTransferTimestamp[tx.origin] = block.timestamp;
                emit updateHolderLastTransferTimestamp(tx.origin, block.timestamp);

                //when buy
                if (automatedMarketMakerPairs[from] && !_isExcludedMaxTransactionAmount[to] && !automatedMarketMakerPairs[to]){
                        require(amount + balanceOf(to) <= maxWalletTotal, "Max wallet exceeded");
                }

                //when sell
                else if (automatedMarketMakerPairs[to] && !_isExcludedMaxTransactionAmount[from] && !automatedMarketMakerPairs[from]){
                        require(amount <= maxTransactionAmount, "Sell transfer amount exceeds the maxTransactionAmount.");
                }
                else if(!_isExcludedMaxTransactionAmount[to]){
                    require(amount + balanceOf(to) <= maxWalletTotal, "Max wallet exceeded");
                }
            }
        }
        uint256 contractTokenBalance = balanceOf(address(this));

        bool canSwap = contractTokenBalance >= swapTokensAtAmount;

        if(
            canSwap &&
            !swapping &&
            swapEnabled &&
            !automatedMarketMakerPairs[from] &&
            !_isExcludedFromFees[from] &&
            !_isExcludedFromFees[to]
        ) {
            swapping = true;

            swapBack();

            swapping = false;
        }

        bool takeFee = !swapping;

        if(_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }

        uint256 fees = 0;

        if(takeFee){
            // on sell
            if (automatedMarketMakerPairs[to] && sellTotalFees > 0){
                fees = amount.mul(sellTotalFees).div(feeUnits);
                tokensForBurn += fees * sellBurnFee / sellTotalFees;
                tokensForMarketing += fees * sellMarketingFee / sellTotalFees;
                tokensForDevelopment +=fees * sellDevelopmentFee/sellTotalFees;
                // if (liquidityFeeActive) {
                //     tokensForLiquidity += fees * sellLiquidityFee / sellTotalFees;
                // }
            }

            // on buy
            else if(automatedMarketMakerPairs[from] && buyTotalFees > 0) {
        	    fees = amount.mul(buyTotalFees).div(feeUnits);
        	    tokensForBurn += fees * buyBurnFee / buyTotalFees;
                tokensForMarketing += fees * buyMarketingFee / buyTotalFees;
                tokensForDevelopment += fees * buyDevelopmentFee / buyTotalFees;
                // if (liquidityFeeActive) {
                //     tokensForLiquidity += fees * buyLiquidityFee / buyTotalFees;
                // }
            }

            if(fees > 0){
                super._transfer(from, address(this), fees);
                if (tokensForBurn > 0) {
                    _burn(address(this), tokensForBurn);
                    supply = totalSupply();
                    updateLimits();
                    tokensForBurn = 0;
                }
            }
            // if (tokensForLiquidity > 0) {
            //     super._transfer(address(this), uniswapV2Pair, tokensForLiquidity);
            //     tokensForLiquidity = 0;
            // }
        	amount -= fees;
        }

        super._transfer(from, to, amount);
      }

    function renounceFeeFunctions () public onlyOwner {
        require(msg.sender == owner(), "Only the owner can renounce fee functions");
        _renounceFeeFunctions = true;
    }

    function renounceDelayFunction () public onlyOwner {
        require(msg.sender == owner(), "Only the owner can renounce delay function");
        _renounceDelayFunction = true;
    }

    function renounceWalletChanges () public onlyOwner {
        require(msg.sender == owner(), "Only the owner can renounce wallet changes");
        _renounceWalletChanges = true;
    }

    function renounceMaxUpdateFunctions () public onlyOwner {
        require(msg.sender == owner(), "Only the owner can renounce max update functions");
        _renounceMaxUpdateFunctions = true;
    }

    function renounceMarketMakerPairChanges () public onlyOwner {
        require(msg.sender == owner(), "Only the owner can renounce market maker pair changes");
        _renounceMarketMakerPairChanges = true;
    }

    function renounceExcludeInclude () public onlyOwner {
        require(msg.sender == owner(), "Only the owner can renounce exclude include");
        _renounceExcludeInclude = true;
    }

    function swapTokensForEth(uint256 tokenAmount) private {
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        // make the swap
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this),
            block.timestamp
        );

    }

    function swapBack() private {
        uint256 contractBalance = balanceOf(address(this));
        bool success;

        if(contractBalance == 0) {return;}

        if(contractBalance > swapTokensAtAmount * 20){
          contractBalance = swapTokensAtAmount * 20;
        }

        swapTokensForEth(contractBalance);

        tokensForMarketing = 0;

        (success,) = address(marketingAddress).call{value: address(this).balance}("");
    }

}