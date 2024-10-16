// SPDX-License-Identifier: MIT

/**
 *
 * It's your boy Pepe, but not just any Pepe - I've leveled up to PepePreneur.
 * I'm diving bill-first into the world of entrepreneurship and dragging all of you with me.
 * 
 * Telegram: https://t.me/pepepreneur
 * Twitter (X): https://x.com/pepepreneur
 * Website: https://pepepreneur.com
 * Academy: https://academy.pepepreneur.com
 * 
 */ 

pragma solidity ^0.8.20;

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

pragma solidity ^0.8.20;

abstract contract Ownable is Context {
    address private _owner;
    error OwnableUnauthorizedAccount(address account);

    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

pragma solidity ^0.8.20;

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

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}

pragma solidity ^0.8.20;

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

pragma solidity ^0.8.20;

interface IERC20Errors {
    error ERC20InsufficientBalance(
        address sender,
        uint256 balance,
        uint256 needed
    );

    error ERC20InvalidSender(address sender);

    error ERC20InvalidReceiver(address receiver);

    error ERC20InsufficientAllowance(
        address spender,
        uint256 allowance,
        uint256 needed
    );

    error ERC20InvalidApprover(address approver);

    error ERC20InvalidSpender(address spender);
}

interface IERC721Errors {
    error ERC721InvalidOwner(address owner);

    error ERC721NonexistentToken(uint256 tokenId);

    error ERC721IncorrectOwner(address sender, uint256 tokenId, address owner);

    error ERC721InvalidSender(address sender);

    error ERC721InvalidReceiver(address receiver);

    error ERC721InsufficientApproval(address operator, uint256 tokenId);

    error ERC721InvalidApprover(address approver);

    error ERC721InvalidOperator(address operator);
}

interface IERC1155Errors {
    error ERC1155InsufficientBalance(
        address sender,
        uint256 balance,
        uint256 needed,
        uint256 tokenId
    );

    error ERC1155InvalidSender(address sender);

    error ERC1155InvalidReceiver(address receiver);

    error ERC1155MissingApprovalForAll(address operator, address owner);

    error ERC1155InvalidApprover(address approver);

    error ERC1155InvalidOperator(address operator);

    error ERC1155InvalidArrayLength(uint256 idsLength, uint256 valuesLength);
}

pragma solidity ^0.8.24;

interface IUniswapV2Factory {
    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    )
        external
        payable
        returns (uint amountToken, uint amountETH, uint liquidity);

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
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

    function getAmountsOut(
        uint amountIn,
        address[] calldata path
    ) external view returns (uint[] memory amounts);
}

contract PepePreneur is Ownable, IERC20, IERC20Metadata, IERC20Errors {
    mapping(address account => uint256) private _balances;

    mapping(address account => mapping(address spender => uint256))
    private _allowances;
    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    address payable private marketingWallet;

    bool public tradingOpen = false;
    IUniswapV2Router02 public uniswapV2Router;
    address private uniswapV2Pair;

    uint256 private constant FEE_TAX = 200; // 2%
    uint256 private constant LIQUIDITY_TAX = 200; // 2%
    uint256 private constant BURN_TAX = 100; // 1%
    uint256 private constant FEE_SEND_DURATION = 2 hours;

    bool inSwapAndLiquify;

    uint256 lastTaxTransferTimestamp;

    event SwapAndLiquify(
        uint256 tokensSwapped,
        uint256 ethReceived,
        uint256 tokensIntoLiqudity
    );

    modifier lockTheSwap() {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 initialSupply_,
        address marketingWallet_
    ) Ownable(_msgSender()) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;

        marketingWallet = payable(marketingWallet_);
        _mint(_msgSender(), initialSupply_);
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

    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, value);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(
        address spender,
        uint256 value
    ) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public virtual returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }

    function _transfer(address from, address to, uint256 value) internal {
        if (from == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (to == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        uint256 fromBalance = _balances[from];
        if (fromBalance < value) {
            revert ERC20InsufficientBalance(from, fromBalance, value);
        }

        uint256 _taxAmt = 0;

        if (from != owner() && to != owner() && tradingOpen) {
            if (
                (from == uniswapV2Pair && to != address(uniswapV2Router)) ||
                (to == uniswapV2Pair && from != address(this))
            ) {
                unchecked {
                    _taxAmt =
                        ((value * FEE_TAX) +
                            (value * LIQUIDITY_TAX) +
                            (value * BURN_TAX)) /
                        1e4;
                }

                uint256 contractTokenBalance = balanceOf(address(this));

                if (
                    block.timestamp >
                    lastTaxTransferTimestamp + FEE_SEND_DURATION &&
                    to == uniswapV2Pair &&
                    !inSwapAndLiquify &&
                    contractTokenBalance > 0
                ) {
                    uint256 T_TAX = LIQUIDITY_TAX + FEE_TAX + BURN_TAX;
                    uint256 amount = value < contractTokenBalance
                        ? value
                        : contractTokenBalance;

                    swapAndSendTax(
                        (amount * LIQUIDITY_TAX) / T_TAX,
                        (amount * FEE_TAX) / T_TAX
                    );

                    _burn(address(this), (amount * BURN_TAX) / T_TAX);

                    lastTaxTransferTimestamp = block.timestamp;
                }
            }
        }

        if (_taxAmt > 0) {
            _balances[address(this)] += _taxAmt;
            emit Transfer(from, address(this), _taxAmt);
        }

        unchecked {
            _balances[from] = fromBalance - value;
            _balances[to] += value - _taxAmt;
        }
        emit Transfer(from, to, value);
    }

    function _mint(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _totalSupply += value;
        _balances[account] += value;

        emit Transfer(address(0), account, value);
    }

    function _burn(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        uint256 accountBalance = _balances[account];
        if (accountBalance < value) {
            revert ERC20InsufficientBalance(account, accountBalance, value);
        }
        unchecked {
            _balances[account] = accountBalance - value;
        }
        _totalSupply -= value;

        emit Transfer(account, address(0), value);
    }

    function _approve(address owner, address spender, uint256 value) internal {
        _approve(owner, spender, value, true);
    }

    function _approve(
        address owner,
        address spender,
        uint256 value,
        bool emitEvent
    ) internal virtual {
        if (owner == address(0)) {
            revert ERC20InvalidApprover(address(0));
        }
        if (spender == address(0)) {
            revert ERC20InvalidSpender(address(0));
        }
        _allowances[owner][spender] = value;
        if (emitEvent) {
            emit Approval(owner, spender, value);
        }
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 value
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < value) {
                revert ERC20InsufficientAllowance(
                    spender,
                    currentAllowance,
                    value
                );
            }
            unchecked {
                _approve(owner, spender, currentAllowance - value, false);
            }
        }
    }

    function swapAndSendTax(
        uint256 _liquidityAmount,
        uint256 _teamAmount
    ) private lockTheSwap {
        uint256 T_TAX = (LIQUIDITY_TAX / 2) + FEE_TAX;

        uint256 liqHalf = _liquidityAmount / 2;
        uint256 liqOtherHalf = _liquidityAmount - (liqHalf);

        swapTokensForEth(liqHalf + _teamAmount);

        uint256 ethBalance = address(this).balance;
        uint256 feeETH = (ethBalance * FEE_TAX) / T_TAX;
        uint256 liquidityETH = ethBalance - feeETH;

        addLiquidity(liqOtherHalf, liquidityETH);

        sendETHToFee(feeETH);

        emit SwapAndLiquify(liqHalf, liquidityETH, liqOtherHalf);
    }

    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
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

    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        _approve(address(this), address(uniswapV2Router), tokenAmount);

        uniswapV2Router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            owner(),
            block.timestamp
        );
    }

    function sendETHToFee(uint256 amount) private {
        marketingWallet.transfer(amount);
    }

    function openTrading(address _uniswapV2Router) external onlyOwner {
        require(_uniswapV2Router != address(0), "Invalid router address");
        require(!tradingOpen, "trading is already open");

        uniswapV2Router = IUniswapV2Router02(_uniswapV2Router);
        _approve(address(this), address(uniswapV2Router), _totalSupply);

        uniswapV2Pair = IUniswapV2Factory(uniswapV2Router.factory()).createPair(
                address(this),
                uniswapV2Router.WETH()
            );
        uniswapV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(uniswapV2Pair).approve(address(uniswapV2Router), type(uint).max);

        tradingOpen = true;
    }

    receive() external payable {}
}