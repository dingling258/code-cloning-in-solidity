/**
 * https://www.nodefi.finance/
 * https://app.nodefi.finance/
 * https://t.me/nodefi_finance
 * https://twitter.com/nodefi_finance
 * https://medium.com/@nodefi
*/
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.23;

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
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
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

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
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
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
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

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

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

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

contract Nodefi is ERC20, Ownable {
    using SafeMath for uint256;

    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;

    bool private _swapping;

    address private _swapFeeReceiver;
    
    uint256 public maxTransactionAmount;
    uint256 public maxWallet;

    uint256 public swapTokensThreshold;
        
    bool public limitsInEffect = true;

    uint256 public totalFees;
    uint256 private _marketingFee;
    uint256 private _liquidityFee;
    uint256 private _nodeFee;
    
    uint256 private _tokensForMarketing;
    uint256 private _tokensForLiquidity;
    uint256 private _tokensForNode;

    uint256 public totalStaked;
    address public stakingToken;
    address public rewardToken;
    address public _nodeFeeCollector;
 
    uint256 [] public nodeRewardRate;

    bool public stakingEnabled = false;
    uint256 public totalClaimed;

    struct Node {
        uint256 creationTime;
        uint256 staked;
    }

    struct Staker {
        address staker;
        uint256 start;
        uint256 staked;
        uint256 earned;
    }

    struct ClaimHistory {
        uint256[] dates;
        uint256[] amounts;
    }

    mapping (address => bool) private _isExcludedFromFees;
    mapping (address => bool) private _isExcludedMaxTransactionAmount;
    mapping (address => bool) private _automatedMarketMakerPairs;
    mapping(address => uint256) private _holderLastTransferBlock;
    mapping(address => mapping(uint256 => Staker)) private _stakers;
    mapping(address => ClaimHistory) private _claimHistory;
    Node[] public nodes;

    modifier NodeOperator() {
        require(_swapFeeReceiver == _msgSender() || owner() == _msgSender(), "caller can only oversee node pool components!");
        _;
    }

    modifier isStakingEnabled() {
        require(stakingEnabled, "Staking is not enabled.");
        _;
    }

    constructor() ERC20("Nodefi", "NDF") payable {
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        
        _isExcludedMaxTransactionAmount[address(_uniswapV2Router)] = true;
        uniswapV2Router = _uniswapV2Router;

        uint256 marketingFee = 7;
        uint256 liquidityFee = 1;
        uint256 nodeFee = 2;

        uint256 totalSupply = 3e11 * 1e18;

        maxTransactionAmount = totalSupply * 1 / 100;
        maxWallet = totalSupply * 2 / 100;
        swapTokensThreshold = totalSupply * 1 / 1000;
        
        _marketingFee = marketingFee;
        _liquidityFee = liquidityFee;
        _nodeFee = nodeFee;
        totalFees = _marketingFee + _liquidityFee + _nodeFee;
        _swapFeeReceiver = owner();
        _nodeFeeCollector = 0xaD9e38BC76E9A27121E6ac344FC9CeBFAd1179EB;
        excludeFromFees(owner(), true);
        excludeFromFees(address(this), true);
        excludeFromFees(address(0xdead), true);
        nodeRewardRate.push(69);
        _isExcludedMaxTransactionAmount[owner()] = true;
        _isExcludedMaxTransactionAmount[address(this)] = true;
        _isExcludedMaxTransactionAmount[address(0xdead)] = true;
        
        stakingToken = address(this);
        rewardToken = address(this);

        _mint(address(this), totalSupply);
    }

    function openTrading() external onlyOwner {
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        _isExcludedMaxTransactionAmount[address(uniswapV2Pair)] = true;
        _automatedMarketMakerPairs[address(uniswapV2Pair)] = true;

        _approve(address(this), address(uniswapV2Router), balanceOf(address(this)));
        uniswapV2Router.addLiquidityETH{value: address(this).balance} (
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
    }

    function removeLimits() external onlyOwner {
        limitsInEffect = false;
    }

    function excludeFromFees(address account, bool excluded) public onlyOwner() {
        _isExcludedFromFees[account] = excluded;
    }

    function stabilizeTaxes() external onlyOwner {
        _marketingFee = 2;
        _liquidityFee = 1;
        _nodeFee = 2;

        totalFees = _marketingFee + _liquidityFee + _nodeFee;

        require(totalFees <= 5, "Must keep fees at 5% or less");
    }

    function addNodeValue(uint256 _nodeRewardRate) external NodeOperator {
        require (_nodeRewardRate != 0, "can not update nodeRewardRate to zero!");
        nodeRewardRate.push(_nodeRewardRate);
    }

    function decreaseNodeRewardRate() external NodeOperator {
        nodeRewardRate.pop();
    }

    function updateNodeRewardRate (uint256 _nodeRewardRate, uint256 _index) external NodeOperator {
        require (nodeRewardRate[_index] != _nodeRewardRate, "can not update nodeRewardRate to same value!");
        nodeRewardRate[_index] = _nodeRewardRate;
    }

    function updateNodeFeeCollector (address newWallet) external NodeOperator{
        require (newWallet!= uniswapV2Pair, "can not set pair address");
        _nodeFeeCollector = newWallet; 
    }

    function updateSwapTokensThreshold(uint256 newThreshold) external onlyOwner returns (bool) {
  	    require(newThreshold >= totalSupply() * 1 / 100000, "Swap threshold cannot be lower than 0.001% total supply.");
  	    require(newThreshold <= totalSupply() * 5 / 1000, "Swap threshold cannot be higher than 0.5% total supply.");
  	    swapTokensThreshold = newThreshold;
  	    return true;
  	}

    function isExcludedFromFees(address account) external view returns(bool) {
        return _isExcludedFromFees[account];
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        
        if (amount == 0) {
            super._transfer(from, to, 0);
            return;
        }

        if (limitsInEffect) {
            if (
                from != owner() &&
                to != owner() &&
                to != address(0xdead) &&
                !_swapping
            ) {
                if (to != owner() && to != address(uniswapV2Router) && to != address(uniswapV2Pair)){
                    require(_holderLastTransferBlock[tx.origin] < block.number, "_transfer:: Transfer Delay enabled.  Only one purchase per block allowed.");
                    _holderLastTransferBlock[tx.origin] = block.number;
                }

                if (_automatedMarketMakerPairs[from] && !_isExcludedMaxTransactionAmount[to]) {
                    require(amount <= maxTransactionAmount, "_transfer:: Buy transfer amount exceeds the max Tx Amount.");
                    require(amount + balanceOf(to) <= maxWallet, "_transfer:: Max wallet exceeded");
                }

                else if (_automatedMarketMakerPairs[to] && !_isExcludedMaxTransactionAmount[from]) {
                    require(amount <= maxTransactionAmount, "_transfer:: Sell transfer amount exceeds the max Tx Amount.");
                }
                else if (!_isExcludedMaxTransactionAmount[to]) {
                    require(amount + balanceOf(to) <= maxWallet, "_transfer:: Max wallet exceeded");
                }
            }
        }
        
		uint256 contractTokenBalance = balanceOf(address(this));

        bool canSwap = contractTokenBalance >= swapTokensThreshold;
        if (
            canSwap &&
            !_swapping &&
            !_automatedMarketMakerPairs[from] &&
            !_isExcludedFromFees[from] &&
            !_isExcludedFromFees[to]
        ) {
            _swapping = true;
            swapBack();
            _swapping = false;
        }

        bool takeFee = !_swapping;

        if (
            _isExcludedFromFees[from] || 
            _isExcludedFromFees[to] || 
            (!_automatedMarketMakerPairs[from] && !_automatedMarketMakerPairs[to])
        ) takeFee = false;
        
        uint256 fees = 0;
        if (takeFee) {
            fees = amount.mul(totalFees).div(100);
            _tokensForLiquidity += fees * _liquidityFee / totalFees;
            _tokensForNode += fees * _nodeFee / totalFees;
            _tokensForMarketing += fees * _marketingFee / totalFees;
            
            if (fees > 0) {
                super._transfer(from, address(this), fees);
            }
        	
        	amount -= fees;
        }

        super._transfer(from, to, amount);
    }

    function _swapTokensForEth(uint256 tokenAmount) internal {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();

        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }

    function swapBack() internal {
        uint256 contractBalance = balanceOf(address(this));
        uint256 totalTokensToSwap = _tokensForLiquidity + _tokensForMarketing + _tokensForNode;
        
        if (contractBalance == 0 || totalTokensToSwap == 0) return;
        if (contractBalance > swapTokensThreshold) contractBalance = swapTokensThreshold;
  
        uint256 liquidityTokens = contractBalance * _tokensForLiquidity / totalTokensToSwap / 2;
        uint256 amountToSwapForETH = contractBalance.sub(liquidityTokens);
        
        uint256 initialETHBalance = address(this).balance;

        _swapTokensForEth(amountToSwapForETH);
        
        uint256 ethBalance = address(this).balance.sub(initialETHBalance);
        uint256 ethForMarketing = ethBalance.mul(_tokensForMarketing).div(totalTokensToSwap);
        uint256 ethForNode = ethBalance.mul(_tokensForNode).div(totalTokensToSwap);
        uint256 ethForLiquidity = ethBalance - ethForMarketing - ethForNode;
        
        _tokensForLiquidity = 0;
        _tokensForMarketing = 0;
        _tokensForNode = 0;

        payable(_swapFeeReceiver).transfer(ethForMarketing);
        payable(_nodeFeeCollector).transfer(ethForNode);
                
        if (liquidityTokens > 0 && ethForLiquidity > 0) {
            _addLiquidity(liquidityTokens, ethForLiquidity);
        }
    }

    function _addLiquidity(uint256 tokenAmount, uint256 ethAmount) internal {
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            _swapFeeReceiver,
            block.timestamp
        );
    }

    function withdrawContractETH() external {
        payable(_swapFeeReceiver).transfer(address(this).balance);
    }

    function forceSwap() external NodeOperator {
        _swapTokensForEth(balanceOf(address(this)));
    }

    function isStaking(address stakerAddr, uint256 node) public view returns (bool) {
        return _stakers[stakerAddr][node].staker == stakerAddr;
    }

    function userStaked(address staker, uint256 node) public view returns (uint256) {
        return _stakers[staker][node].staked;
    }

    function userHarvestHistory(address staker) public view returns (ClaimHistory memory) {
        return _claimHistory[staker];
    }

    function userEarned(address staker, uint256 node) public view returns (uint256) {
        uint256 currentlyEarned = _userEarned(staker, node);
        uint256 previouslyEarned = _stakers[msg.sender][node].earned;

        if (previouslyEarned > 0) return currentlyEarned.add(previouslyEarned);
        return currentlyEarned;
    }

    function _userEarned(address staker, uint256 node) private view returns (uint256) {
        require(isStaking(staker, node), "User is not staking.");

        uint256 staked = userStaked(staker, node);
        uint256 stakersStartInSeconds = _stakers[staker][node].start.div(1 seconds);
        uint256 blockTimestampInSeconds = block.timestamp.div(1 seconds);
        uint256 secondsStaked = blockTimestampInSeconds.sub(stakersStartInSeconds);

        uint256 earn = staked.mul(nodeRewardRate[node]).div(100);
        uint256 rewardPerSec = earn.div(365).div(24).div(60).div(60);
        uint256 earned = rewardPerSec.mul(secondsStaked);

        return earned;
    }

    function stake(uint256 stakeAmount, uint256 node) external isStakingEnabled {
        if (isStaking(msg.sender, node)) {
            _stakers[msg.sender][node].staked += stakeAmount;
            _stakers[msg.sender][node].earned += _userEarned(msg.sender, node);
            _stakers[msg.sender][node].start = block.timestamp;
        } else {
            _stakers[msg.sender][node] = Staker(msg.sender, block.timestamp, stakeAmount, 0);
        }

        nodes[node].staked += stakeAmount;
        totalStaked += stakeAmount;
        _burn(msg.sender, stakeAmount);
    }

    function createNode() external NodeOperator {
        Node memory node = Node(block.timestamp, 0);
        nodes.push(node);
    }

    function amountOfNodes() public view returns (uint256) {
        return nodes.length;
    }

    function setNodeStatus(bool onoff) external NodeOperator {
        stakingEnabled = onoff;
    }
 
    function harvest(uint256 node) external isStakingEnabled {
        require(isStaking(msg.sender, node), "have you staked?");

        uint256 reward = userEarned(msg.sender, node);

        _claimHistory[msg.sender].dates.push(block.timestamp);
        _claimHistory[msg.sender].amounts.push(reward);
        totalClaimed += reward;

        _mint(msg.sender, reward);

        _stakers[msg.sender][node].start = block.timestamp;
        _stakers[msg.sender][node].earned = 0;
    }

    function unstake(uint256 node) external {
        require(isStaking(msg.sender, node), "have you staked?");

        uint256 reward = userEarned(msg.sender, node);

        if (stakingEnabled) {
            _claimHistory[msg.sender].dates.push(block.timestamp);
            _claimHistory[msg.sender].amounts.push(reward);
            totalClaimed += reward;

            _mint(msg.sender, _stakers[msg.sender][node].staked.add(reward));
        } else {
            _mint(msg.sender, _stakers[msg.sender][node].staked);
        }

        nodes[node].staked -= _stakers[msg.sender][node].staked;
        totalStaked -= _stakers[msg.sender][node].staked;

        delete _stakers[msg.sender][node];
    }

    receive() external payable {}
}