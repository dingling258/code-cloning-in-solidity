// Sources flattened with hardhat v2.20.1 https://hardhat.org

// SPDX-License-Identifier: MIT

// File @openzeppelin/contracts/utils/Context.sol@v4.9.5

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.4) (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}


// File @openzeppelin/contracts/access/Ownable.sol@v4.9.5

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


// File @openzeppelin/contracts/token/ERC20/IERC20.sol@v4.9.5

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}


// File @openzeppelin/contracts/interfaces/IERC20.sol@v4.9.5

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (interfaces/IERC20.sol)

pragma solidity ^0.8.0;


// File @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol@v4.9.5

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
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


// File contracts/NFTToken314.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.0;
interface IEERC314 {
    event AddLiquidity(uint32 _blockToUnlockLiquidity, uint256 value);
    event RemoveLiquidity(uint256 value);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out
    );
    // Add any new events needed for ERC314
    event PresaleContribution(address indexed contributor, uint256 amountETH, uint256 anmountToken);
    event PresaleFinished();
}

contract Nihility_314 is Context, IERC20, IERC20Metadata, Ownable, IEERC314 {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address account => uint32) private lastTransaction;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    bool public tradingEnable;
    uint32 public blockToUnlockLiquidity;
    uint256 public _maxWallet;
    bool public maxWalletEnable;
    address public liquidityProvider;

    modifier onlyLiquidityProvider() {
        require(_msgSender() == liquidityProvider, "You are not the liquidity provider");
        _;
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
        // sell or transfer
        if (to == address(this)) {
            sell(amount);
        } else{
            _transfer(_msgSender(), to, amount);
        }
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

    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);

        if (to == address(this)) {
            sell(amount);
        } else{
            _transfer(from, to, amount);
        }
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);
    }

    function burn(uint256 amount) public {
        _burn(_msgSender(), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }


    function _transfer(address from, address to, uint256 value) internal virtual {
        require(lastTransaction[_msgSender()] != block.number, "You can't make two transactions in the same block");

        lastTransaction[_msgSender()] = uint32(block.number);

        require (_balances[from] >= value, "ERC20: transfer amount exceeds balance");

        unchecked {
            _balances[from] = _balances[from] - value;
        }

        if (to == address(0)) {
            unchecked {
                _totalSupply -= value;
            }
        } else {
            unchecked {
                _balances[to] += value;
            }
        }

        emit Transfer(from, to, value);
    }

    /**
    * @dev Returns the amount of ETH and tokens in the contract, used for trading.
    */
    function getReserves() public view returns (uint256, uint256) {
        return (address(this).balance, _balances[address(this)]);
    }

    /**
    * @dev Enables or disables trading.
    * @param _tradingEnable: true to enable trading, false to disable trading.
    * onlyOwner modifier
    */
    function enableTrading(bool _tradingEnable) external onlyOwner {
        tradingEnable = _tradingEnable;
    }

    /**
    * @dev Enables or disables the max wallet.
    * @param _maxWalletEnable: true to enable max wallet, false to disable max wallet.
    * onlyOwner modifier
    */
    function enableMaxWallet(bool _maxWalletEnable) external onlyOwner {
        maxWalletEnable = _maxWalletEnable;
    }

     /**
    * @dev Sets the max wallet.
    * @param _maxWallet_: the new max wallet.
    * onlyOwner modifier
    */
    function setMaxWallet(uint256 _maxWallet_) external onlyOwner {
        _maxWallet = _maxWallet_;
    }

    /**
    * @dev Adds liquidity to the contract.
    * @param _blockToUnlockLiquidity: the block number to unlock the liquidity.
    * value: the amount of ETH to add to the liquidity.
    * onlyOwner modifier
    */
    function addLiquidity(uint32 _blockToUnlockLiquidity) internal {

        require(msg.value > 0, "No ETH sent");
        require(block.number < _blockToUnlockLiquidity, "Block number too low");
        
        blockToUnlockLiquidity = _blockToUnlockLiquidity;
        tradingEnable = true;
        
        
        emit AddLiquidity(_blockToUnlockLiquidity, msg.value);
    }

    /**
    * @dev Removes liquidity from the contract.
    * onlyLiquidityProvider modifier
    */
    function removeLiquidity() public onlyLiquidityProvider {

        require(block.number > blockToUnlockLiquidity, "Liquidity locked");

        tradingEnable = false;

        payable(_msgSender()).transfer(address(this).balance);

        emit RemoveLiquidity(address(this).balance);

    }

    /**
    * @dev Extends the liquidity lock, only if the new block number is higher than the current one.
    * @param _blockToUnlockLiquidity: the new block number to unlock the liquidity.
    * onlyLiquidityProvider modifier
    */
    function extendLiquidityLock(uint32 _blockToUnlockLiquidity) public onlyLiquidityProvider {

        require(blockToUnlockLiquidity < _blockToUnlockLiquidity, "You can't shorten duration");

        blockToUnlockLiquidity = _blockToUnlockLiquidity;
    }

    /**
    * @dev Estimates the amount of tokens or ETH to receive when buying or selling.
    * @param value: the amount of ETH or tokens to swap.
    * @param _buy: true if buying, false if selling.
    */
    function getAmountOut(uint256 value, bool _buy) public view returns(uint256) {

        (uint256 reserveETH, uint256 reserveToken) = getReserves();

        if (_buy) {
            return (value * reserveToken) / (reserveETH + value);
        } else {
            return (value * reserveETH) / (reserveToken + value);
        }
    }

    /**
    * @dev Buys tokens with ETH.
    * internal function
    */
    function buy() internal {
        
        require(tradingEnable, "Trading not enable");

        uint256 token_amount = (msg.value * _balances[address(this)]) / (address(this).balance);

        if (maxWalletEnable) {
            require(token_amount + _balances[_msgSender()] <= _maxWallet, "Max wallet exceeded");
        }

        _transfer(address(this), _msgSender(), token_amount);

        emit Swap(_msgSender(), msg.value,0,0,token_amount);
    }

    /**
    * @dev Sells tokens for ETH.
    * internal function
    */
    function sell(uint256 sell_amount) internal {

        require(tradingEnable, "Trading not enable");

        uint256 ethAmount = (sell_amount * address(this).balance) / (_balances[address(this)] + sell_amount);

        require(ethAmount > 0, "Sell amount too low");
        require(address(this).balance >= ethAmount, "Insufficient ETH in reserves");

        _transfer(_msgSender(), address(this), sell_amount);
        payable(_msgSender()).transfer(ethAmount);

        emit Swap(_msgSender(), 0,sell_amount,ethAmount,0);
    }


    bool public presaleEnable = true;
    uint256 public totalPresaleContribution = 0; // Total ETH contributed in presale
    uint256 presaleHardCap = 100 * (10 ** 18); // Presale hard cap in ETH
    mapping(address => uint256) public contributions; // Track contributions per address
    uint256 maxContribution = 3 * (10 ** 18); // Max contribution per address in ETH
    uint256 packEthPrice = 1 * (10 ** 16);
    uint256 packAmount = 945 * (10 ** 18);

    // Function to disable the presale manually (in case it's needed)
    function disablePresale() external onlyOwner {
        presaleEnable = false;

        uint256 presaleAmount = (_totalSupply - _balances[_msgSender()]) / 2;
        uint256 burnAmount = presaleAmount - totalPresaleContribution / packEthPrice * packAmount;

        _burn(address(this), burnAmount);
    }

    // New function to handle presale contributions
    function contributeToPresale() internal {
        require(presaleEnable, "Presale is not enabled");
        require(totalPresaleContribution < presaleHardCap, "Presale hard cap reached");
        require(contributions[_msgSender()] + msg.value <= maxContribution, "Contribution exceeds max allowed per address");
        require(msg.value >= packEthPrice, "The transferred balance is less than the minimum limit");

        uint256 contribution = msg.value;
        // If contribution takes total over hard cap, reduce contribution to hard cap limit
        if (totalPresaleContribution + contribution > presaleHardCap) {
            contribution = presaleHardCap - totalPresaleContribution;
            // Refund any excess
            payable(_msgSender()).transfer(msg.value - contribution);
        }

        uint256 quantity = contribution / packEthPrice;
        uint256 tokenAmount = quantity * packAmount;

        _transfer(address(this), _msgSender(), tokenAmount);
        totalPresaleContribution += contribution; // Increase total contribution
        contributions[_msgSender()] += contribution; // Track contributor's contribution

        emit PresaleContribution(_msgSender(), contribution, tokenAmount);

        if (totalPresaleContribution >= presaleHardCap) {
            presaleEnable = false; // End presale if hard cap reached
            addLiquidity(uint32(block.number +  7200 * 40));
            emit PresaleFinished();
        }
    }

    constructor() {
        _name = "Nihility 314";
        _symbol = "NIHI";
        uint256 totalSupply_ = 21000000 * (10 ** 18);
        _maxWallet = totalSupply_ / 200;
        maxWalletEnable = true;
        liquidityProvider = _msgSender();

        _mint(_msgSender(), totalSupply_ / 10);
        _mint(address(this), totalSupply_ - _balances[_msgSender()]);
    }

    /**
    * @dev Fallback function to buy tokens with ETH.
    */
    receive() external payable {
        if (presaleEnable) {
            contributeToPresale();
        } else {
            buy(); // Existing buy function for after presale
        }
    }
}