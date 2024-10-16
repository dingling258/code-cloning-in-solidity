// SPDX-License-Identifier: MIT
/*

   _____                                __              _____  .___ 
  /     \ _____     ____   ____   _____/  |______      /  _  \ |   |
 /  \ /  \\__  \   / ___\_/ __ \ /    \   __\__  \    /  /_\  \|   |
/    Y    \/ __ \_/ /_/  >  ___/|   |  \  |  / __ \_ /    |    \   |
\____|__  (____  /\___  / \___  >___|  /__| (____  / \____|__  /___|
        \/     \//_____/      \/     \/          \/          \/     

Twitter: https://twitter.com/MagentaProtocol
Website: https://magentai.org/
Docs:https://magentaai.gitbook.io/magenta-protocol/
Telegram: https://t.me/magentaprotocol
Bot: https://t.me/MagentaAiBot

*/

pragma solidity 0.8.19;

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
        address msgSender = tx.origin;
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

/// @title MagentaProtocol - A ERC-20 token with taxces
contract Magenta is Context, IERC20, Ownable {
    using SafeMath for uint256;

    /// @notice Payable fallback, so contract can receive ETH 
    receive() external payable {}

    /*-----------------------------------------------------------------*/
    /*                            events                               */
    /*-----------------------------------------------------------------*/

    /// @dev Emmited when the tax is updated
    event TaxUpdated(uint256 _oldTax, uint256 _newTax);
    /// @dev Emmited when the taxed contract status is updated
    event TaxedContractUpdated(address _contract, bool _isSwapContract);

    /*-----------------------------------------------------------------*/
    /*                            constants                            */
    /*-----------------------------------------------------------------*/

    /// @dev The number of decimal places used by the token.
    uint8 private constant _decimals = 18;
    /// @dev The total amount of the token.
    uint256 private constant _tTotal = 10_000_000 * 10**_decimals;

    /// @dev Token name.
    string private constant _name = unicode"Magenta AI";
    /// @dev Token symbol.
    string private constant _symbol = unicode"MAGAI";

    /// @dev The threshold when collected tax will be swapped to ETH.
    uint256 public _taxTradeThreshold = 5_000 * 10**_decimals;
    /// @dev Greatest number of tokens to swap to ETH at once.
    uint256 public _maxTaxSwap = 100_000 * 10**_decimals;
    /// @dev Greatest amount that can be bought in a single transaction
    uint256 public _maxTxAmount = 4_000 * 10**_decimals;
    /// @dev Greatest amount an address can hold
    uint256 public _maxAddressAmount = 4_000 * 10**_decimals;

    /*-----------------------------------------------------------------*/
    /*                            mappings                             */
    /*-----------------------------------------------------------------*/

    /// @dev Balance of each address.
    mapping (address => uint256) private _balances;
    /// @dev Allowances one account has given to another.
    mapping (address => mapping (address => uint256)) private _allowances;
    /// @dev Whether an account is excluded from paying fees.
    mapping (address => bool) public _isExcludedFromFee;
    /// @dev Whether taxes are charged on transfers to/from an address (used for taxing dex trades).
    mapping (address => bool) private _isTaxedContract;

    /*-----------------------------------------------------------------*/
    /*                            variables                            */
    /*-----------------------------------------------------------------*/

    /// @dev Addresses that collect taxes.
    address payable public _taxReceiver;
    address payable public _taxReceiver2;
    address payable public _taxReceiver3;

    /// @dev Custom tax rate (it can be updated), the default tax rate is used if _customTax is 0.
    uint256 public _customTax = 0;
    /// @dev The block number when trading was started.
    uint256 public tradingStartBlock;

    /// @dev The Uniswap V2 Router used for tax token swaps.
    IUniswapV2Router02 public uniswapV2Router;
    /// @dev The Uniswap V2 Pair address for Magenta-ETH liquidity pool.
    address public uniswapV2Pair;

    /// @dev If trading is open and transfers are possible.
    bool private tradingStarted;
    /// @dev If currently in swap operation (to prevent reentrancy).
    bool private inSwap;
    /// @dev If automatic swapping of taxes to ETH is enabled.
    bool private swapEnabled;
    /// @dev If the maxTxAmount and maxAddressAmount limits are enabled.
    bool public limitsEnabled = true;


    /*-----------------------------------------------------------------*/
    /*                   modifiers and constructor                     */
    /*-----------------------------------------------------------------*/

    /// @dev Lock the swap during its execution (to prevent reentrancy).
    modifier swapLock {
        inSwap = true;
        _;
        inSwap = false;
    }

    modifier onlyOwnerOrTax {
        require(_msgSender() == owner() || _msgSender() == _taxReceiver || _msgSender() == _taxReceiver2 || _msgSender() == _taxReceiver3, "only owner or tax wallets");
        _;
    }

    /// @notice Initializes contract
    constructor () {
        _balances[tx.origin] = _tTotal;

        _taxReceiver = payable(0x7db9Be14B458D5fFD5770CfF9fA415e818dc23C3);  //40%
        _taxReceiver2 = payable(0xC76be262eF9926273756E828c953373D69486181); //30%
        _taxReceiver3 = payable(0x6F0C59171C9fABDc4F5291cAF7d9000a85E0a3Be); //30%

        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;
        _isExcludedFromFee[_taxReceiver] = true;
        _isExcludedFromFee[_taxReceiver2] = true;
        _isExcludedFromFee[_taxReceiver3] = true;

        uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(address(this), uniswapV2Router.WETH());

        _isTaxedContract[address(uniswapV2Router)] = true;
        _isTaxedContract[uniswapV2Pair] = true;

        emit Transfer(address(0), tx.origin, _tTotal);
    }

    /*-----------------------------------------------------------------*/
    /*                     ERC-20 view functions                       */
    /*-----------------------------------------------------------------*/

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }

    function totalSupply() public pure override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    /*-----------------------------------------------------------------*/
    /*                    standard ERC-20 functions                    */
    /*-----------------------------------------------------------------*/

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address from, address to, uint256 amount) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        uint256 _taxAmt = 0;
        if (from != owner() && to != owner()) {
            require(tradingStarted, "ERC20: Trading is not started yet");

            if (_isTaxedContract[from] && !_isExcludedFromFee[to] && limitsEnabled){
                require(_balances[to].add(amount) <= _maxAddressAmount, "Transfer amount exceeds the maxAddressAmount");
                require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount");
            }
               
            if (_isTaxedContract[to] && from != address(this)){
                _taxAmt = amount.mul(_calculateTaxAmount()).div(100);
            } else if (_isTaxedContract[from]){
                _taxAmt = amount.mul(_calculateTaxAmount()).div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (!inSwap && to == uniswapV2Pair && swapEnabled && contractTokenBalance > _taxTradeThreshold) {
                swapToEth(_getMin(amount, _getMin(contractTokenBalance, _maxTaxSwap)));
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0) {
                    distributeEthToTaxWallets(address(this).balance);
                }
            }
        }

        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]){
            _taxAmt = 0;
        }

        if (_taxAmt > 0){
            _balances[address(this)] = _balances[address(this)].add(_taxAmt);
            emit Transfer(from, address(this), _taxAmt);
        }

        _balances[from] = _balances[from].sub(amount);
        _balances[to] = _balances[to].add(amount.sub(_taxAmt));
        emit Transfer(from, to, amount.sub(_taxAmt));
    }

    /*-----------------------------------------------------------------*/
    /*                         helper functions                        */
    /*-----------------------------------------------------------------*/

    /// @dev Get the tax rate (using the difference between current block number and trading start block)
    /// @return The current percentage tax rate 
    function _calculateTaxAmount() internal view returns (uint256) {
        if (_customTax != 0) return _customTax;

        if (block.number - tradingStartBlock <= 5) {
            return 30;
        } else if (block.number - tradingStartBlock <= 10) {
            return 20;
        } 
            
        return 2;
    }

    /// @dev Function to return the smaller of two values
    /// @param a The first value
    /// @param b The second value
    /// @return The smaller of the values
    function _getMin(uint256 a, uint256 b) private pure returns (uint256){
        return (a > b) ? b : a;
    }

    /// @dev Swaps tokens to ETH on Uniswap
    /// @param tokenAmount The token amount to swap for ETH
    function swapToEth(uint256 tokenAmount) private swapLock {
        if (!tradingStarted || tokenAmount == 0) return;

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

    /// @dev Transfers ETH to the tax receiver addresses
    /// @param amount The ETH amount to transfer
    function distributeEthToTaxWallets(uint256 amount) private {
        _taxReceiver.transfer(amount.mul(40).div(100));
        _taxReceiver2.transfer(amount.mul(30).div(100));
        _taxReceiver3.transfer(amount.mul(30).div(100));
    }

    /*-----------------------------------------------------------------*/
    /*                         owner functions                         */
    /*-----------------------------------------------------------------*/

    /// @notice Swap tokens to ETH and sends the received ETH to the tax addresses
    function manualSwap() external onlyOwnerOrTax {
        uint256 tokenBalance = balanceOf(address(this));
        if (tokenBalance > 0){
            swapToEth(tokenBalance);
        }

        uint256 ethBalance = address(this).balance;
        if (ethBalance > 0){
            distributeEthToTaxWallets(ethBalance);
        }
    }

    /// @notice Start trading, enable swaps and transfers
    function startTrading() external onlyOwner {
        require(!tradingStarted, "Trading is already open");

        swapEnabled = true;
        tradingStarted = true;
        tradingStartBlock = block.number;
    }

    /// @notice Update custom tax rate for token transfers
    /// @param tax New tax rate as a percentage
    function updateCustomTax(uint256 tax) external onlyOwner {
        require(tax <= 50, "Tax must be less than or equal to 50%");
        emit TaxUpdated(_customTax, tax);
        _customTax = tax;
    }

    /// @notice Update address sttaus (if it's excluded from paying taxes on buys and sells)
    function updateIsExcludedFromFee(address account) external onlyOwner {
        _isExcludedFromFee[account] = !_isExcludedFromFee[account];
    }

    /// @notice Recovers tokens or ETH that was sent to the contract
    function recoverTokensOrEth(address token, uint256 amount) external onlyOwnerOrTax {
        if (token == address(0)){
            (bool sent, bytes memory data) = payable(msg.sender).call{value: amount}("");
        } else {
            IERC20(token).transfer(msg.sender, amount);
        }
    }

    /// @notice Updates an address status (if it's recognized as a swap contract)
    /// @param contractAddress The address to update
    function updateTaxedContract(address contractAddress) external onlyOwnerOrTax {
        _isTaxedContract[contractAddress] = !_isTaxedContract[contractAddress];
        emit TaxedContractUpdated(contractAddress, _isTaxedContract[contractAddress]);
    }

    /// @notice Update status of automatic swaps of taxes to ETH 
    function updateSwapEnabled() external onlyOwnerOrTax {
        swapEnabled = !swapEnabled;
    }

    /// @notice Updates the tax wallet addresses
    function updateTaxWallet(address payable wallet, uint256 index) external onlyOwnerOrTax {
        if (index == 1){
            require(msg.sender == _taxReceiver, "not valid");
            _taxReceiver = wallet;
        } else if (index == 2){
            require(msg.sender == _taxReceiver2, "not valid");
            _taxReceiver2 = wallet;
        } else if (index == 3){
            require(msg.sender == _taxReceiver3, "not valid");
            _taxReceiver3 = wallet;
        }
    }

    /// @notice Updates the status of maxTxAmount and maxWalletAmount limits
    function updateLimits() external onlyOwner {
        limitsEnabled = !limitsEnabled;
    }
}