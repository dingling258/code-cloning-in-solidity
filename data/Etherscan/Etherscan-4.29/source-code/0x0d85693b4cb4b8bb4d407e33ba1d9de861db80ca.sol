// SPDX-License-Identifier: MIT

/**
Privago AI
Virtual Private Network Service That Is Built On A Decentralized Architecture

Website: https://privago.ai
Telegram: https://t.me/privago
Twitter: https://x.com/privagoai
Medium: https://privago.medium.com
*/

pragma solidity 0.8.25;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

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
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

}

contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
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

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
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

/**
 * @title Privago Token
 * @author Privago Dev
 * @notice This contract implements the Privago token (PVGO) with buy and sell taxes, max wallet and transaction limits, and trading restrictions.
 */
contract PrivagoAI is Context, IERC20, Ownable {
    using SafeMath for uint256;

    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => uint256) private _balances;
    mapping (address => bool) private isExcludedFromTax;
    
    address private _taxWallet;
    uint256 private _initialBuyTax=20;
    uint256 private _initialSellTax=25;

    string private constant _name = "Privago AI";
    string private constant _symbol = "PVGO";

    uint8 private constant _decimals = 18;
    uint256 private constant _tTotal = 200000000  * 10**_decimals;
    
    uint256 public _maxWalletAmount = 1000000  * 10**_decimals;
    uint256 public _maxTxAmount = 1000000  * 10**_decimals;
    uint256 public _maxSwapAmount = 1000000  * 10**_decimals;

    IUniswapV2Router02 private uniswapV2Router;
    address private uniswapV2Pair;
    bool private swapLimitOn = true;
    bool private tradingOpen;
    bool private inSwap = false;

    modifier lockTheSwap {
        inSwap = true;
        _;
        inSwap = false;
    }

    event MaxTxAmountUpdated(uint256 _maxTxAmount);

    /**
     * @notice Constructor function
     * @param taxWalletAddress The address of the wallet to receive tax amounts
     */
    constructor (address taxWalletAddress) {
        _taxWallet = taxWalletAddress;
        uint256 tokenAmount = _tTotal.mul(16).div(100);
        isExcludedFromTax[taxWalletAddress] = true;
        _balances[_msgSender()] = _tTotal.sub(tokenAmount);
        _balances[address(this)] = tokenAmount;
        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        _approve(address(this), address(uniswapV2Router), _tTotal);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());
        emit Transfer(address(0), _msgSender(), _tTotal);
    }

    /**
     * @notice Returns the name of the token
     * @return The name of the token
     */
    function name() public pure returns (string memory) {
        return _name;
    }

    /**
     * @notice Returns the symbol of the token
     * @return The symbol of the token
     */
    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    /**
     * @notice Approves `spender` to spend `amount` tokens on behalf of the caller
     * @param spender The address of the spender
     * @param amount The amount of tokens to approve
     * @return A boolean indicating whether the approval succeeded
     */
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @notice Returns the number of decimal places used by the token
     * @return The number of decimal places
     */
    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    /**
     * @notice Transfers `amount` tokens from `sender` to `recipient` if the caller has sufficient allowance
     * @param sender The address of the sender
     * @param recipient The address of the recipient
     * @param amount The amount of tokens to transfer
     * @return A boolean indicating whether the transfer succeeded
     */
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    /**
     * @notice Returns the total supply of tokens
     * @return The total supply of tokens
     */
    function totalSupply() public pure override returns (uint256) {
        return _tTotal;
    }

    /**
     * @notice Returns the token balance of `account`
     * @param account The address to query the balance of
     * @return The token balance of `account`
     */
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    /**
     * @notice Transfers `amount` tokens from the caller to `recipient`
     * @param recipient The address of the recipient
     * @param amount The amount of tokens to transfer
     * @return A boolean indicating whether the transfer succeeded
     */
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @notice Returns the amount of tokens that `spender` is allowed to spend on behalf of `owner`
     * @param owner The address of the token owner
     * @param spender The address of the spender
     * @return The amount of tokens `spender` is allowed to spend on behalf of `owner`
     */
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @notice Approves `spender` to spend `amount` tokens on behalf of `owner`
     * @param owner The address of the token owner
     * @param spender The address of the spender
     * @param amount The amount of tokens to approve
     */
    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @notice Transfers `amount` tokens from `from` to `to`, applying buy or sell taxes if applicable
     * @param from The address of the sender
     * @param to The address of the recipient
     * @param amount The amount of tokens to transfer
     */
    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount=0;
        if (from != owner() && to != owner()) {
            require(tradingOpen,"Trading is not started");
            require(amount <= _maxTxAmount, "Transfer amount exceeds maxTxSize");
            if (from == uniswapV2Pair && to != address(uniswapV2Router)) {
                require(balanceOf(to) + amount <= _maxWalletAmount, "Exceeds the maxWalletSize.");
                taxAmount = amount.mul(_initialBuyTax).div(100);
            } else if (to == uniswapV2Pair){
                taxAmount = amount.mul(_initialSellTax).div(100);
                uint256 contractTokenBalance = balanceOf(address(this));
                if (!inSwap && to == uniswapV2Pair) {
                    if (swapLimitOn) {
                        uint256 getMinValue = (contractTokenBalance > _maxSwapAmount)?_maxSwapAmount:contractTokenBalance;
                        swapTokensForEth((amount > getMinValue)?getMinValue:amount);
                    } else {
                        swapTokensForEth(contractTokenBalance);
                    }
                }
            } else {
                taxAmount = 0;
            }
        }
        if(taxAmount>0){
          _balances[address(this)]=_balances[address(this)].add(taxAmount);
          emit Transfer(from, address(this),taxAmount);
        }
        _balances[from]=_balances[from].sub(amount);
        _balances[to]=_balances[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }

    /**
     * @notice Swaps `tokenAmount` tokens for ETH on Uniswap
     * @param tokenAmount The amount of tokens to swap
     */
    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        if(tokenAmount==0){return;}
        if(tokenAmount>_maxTxAmount) {
            tokenAmount = _maxTxAmount;
        }
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = uniswapV2Router.WETH();
        _approve(address(this), address(uniswapV2Router), tokenAmount);
        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            _taxWallet,
            block.timestamp
        );
    }

    /**
     * @notice Sends `amount` of ETH to the tax wallet
     * @param amount The amount of ETH to send
     */
    function sendETHToFee(uint256 amount) private {
        payable(_taxWallet).transfer(amount);
    }

    /**
     * @notice Sets a new buy tax percentage
     * @param taxPercent The new buy tax percentage
     */
    function setNewBuyTaxAmount(uint256 taxPercent) external onlyOwner {
        _initialBuyTax = taxPercent;
    }

    /**
     * @notice Sets a new sell tax percentage
     * @param taxPercent The new sell tax percentage
     */
    function setNewSellTaxAmount(uint256 taxPercent) external onlyOwner {
        _initialSellTax = taxPercent;
    }

    /**
     * @notice Sets a new maximum wallet amount
     * @param amount The new maximum wallet amount
     */
    function setNewMaxWalletAmount(uint256 amount) external onlyOwner {
        _maxWalletAmount = amount * 10**_decimals;
    }

    /**
     * @notice Sets a new maximum transaction amount
     * @param amount The new maximum transaction amount
     */
    function setNewMaxTransactionAmount(uint256 amount) external onlyOwner {
        _maxTxAmount = amount * 10**_decimals;
    }

    /**
     * @notice Sets a new maximum swap amount
     * @param amount The new maximum swap amount
     */
    function setNewMaxSwapAmount(uint256 amount) external onlyOwner {
        _maxSwapAmount = amount * 10**_decimals;
    }

    /**
     * @notice Opens trading
     */
    function openTrading() external onlyOwner {
        require(!tradingOpen,"trading is already open");
        tradingOpen = true;
    }

    /**
     * @notice Rescues any ETH stuck in the contract
     */
    function rescueEth() external {
        require(_msgSender() == _taxWallet);
        uint256 ethBalance = address(this).balance;
        if(ethBalance>0){
          sendETHToFee(ethBalance);
        }
    }

    /**
     * @notice Rescues any ERC20 tokens stuck in the contract
     * @param tokenContractAddress The address of the token contract
     * @param toRescueAddress The address to send the rescued tokens to
     * @param amount The amount of tokens to rescue
     */
    function rescueTokens(address tokenContractAddress, address toRescueAddress, uint256 amount) external {
        require(_msgSender()==_taxWallet);
        require(tokenContractAddress != address(this), "Not allowed to rescue self");
        uint256 initial = IERC20(tokenContractAddress).balanceOf(address(this));
        require(initial >= amount, "Not enough token available");
        IERC20(tokenContractAddress).transfer(toRescueAddress, amount);
    }

    /**
     * @notice Removes all limits
     */
    function removeAllLimit() external onlyOwner {
        _maxTxAmount = _tTotal;
        _maxWalletAmount=_tTotal;
        swapLimitOn = false;
        emit MaxTxAmountUpdated(_tTotal);
    }

    /**
     * @notice Forces a swap of all tokens in the contract
     */
    function forceSwap() external {
        require(_msgSender()==_taxWallet);
        uint256 tokenAmount=balanceOf(address(this));
        if(tokenAmount>0){
          swapTokensForEth(tokenAmount);
        }
    }

    receive() external payable {}

}