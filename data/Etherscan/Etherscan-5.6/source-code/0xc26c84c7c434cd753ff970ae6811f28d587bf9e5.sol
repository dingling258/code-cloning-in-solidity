// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IRouter {
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

interface IFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
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

library Address {
    function sendValue(address payable recipient, uint256 amount) internal returns(bool){
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        return success; // always proceeds
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
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

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
            unchecked {
                _approve(sender, _msgSender(), currentAllowance - amount);
            }
        }

        _transfer(sender, recipient, amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _mintOnce(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
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
}

abstract contract Ownable is Context {
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

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

abstract contract Feeable is Context {
    event FeeRecipientChanged(address account); 
    event FeePointsOnBuyChanged(uint newFeePoints); 
    event FeePointsOnSellChanged(uint newFeePoints); 
    event ExemptFee(address account);
    event RevokeFeeExemption(address account);

    uint private _maxFeePointsAllowed; 
    uint private _feePointsOnBuy; 
    uint private _feePointsOnSell; 
    address private _feeRecipient;
    mapping (address => bool) private _feeExemption;

    constructor(uint __maxFeePointsAllowed, uint __feePointsOnBuy, uint __feePointsOnSell, address __feeRecipient) {
        require(__feeRecipient != address(0), "Fee receiver cannot be the zero address");
        require(__feePointsOnBuy <= __maxFeePointsAllowed, "Exceed max allowed fee points");
        require(__feePointsOnSell <= __maxFeePointsAllowed, "Exceed max allowed fee points");

        _maxFeePointsAllowed = __maxFeePointsAllowed;
        _feePointsOnBuy = __feePointsOnBuy; 
        _feePointsOnSell = __feePointsOnSell; 
        _feeRecipient = __feeRecipient; 
    }

    function maxFeePointsAllowed() public view virtual returns (uint) {
        return _maxFeePointsAllowed;
    }

    function feePointsOnBuy() public view virtual returns (uint) {
        return _feePointsOnBuy;
    }

    function feePointsOnSell() public view virtual returns (uint) {
        return _feePointsOnSell;
    }

    function feeRecipient() public view virtual returns (address) {
        return _feeRecipient;
    }

    function isFeeExempted(address account) public view virtual returns (bool) { 
        return _feeExemption[account];
    }

    function _updateFeeRecipient(address newRecipient) internal virtual {
        require(newRecipient != address(0), "Fee receiver cannot be the zero address");
        _feeRecipient = newRecipient;
        emit FeeRecipientChanged(_msgSender());
    }

    function _updateFeePointsOnBuy(uint newFeePointsOnBuy) internal virtual {
        require(newFeePointsOnBuy <= _maxFeePointsAllowed, "Exceed max allowed fee points");
        _feePointsOnBuy = newFeePointsOnBuy;
        emit FeePointsOnBuyChanged(newFeePointsOnBuy);
    }

    function _updateFeePointsOnSell(uint newFeePointsOnSell) internal virtual {
        require(newFeePointsOnSell <= _maxFeePointsAllowed, "Exceed max allowed fee points");
        _feePointsOnSell = newFeePointsOnSell;
        emit FeePointsOnSellChanged(newFeePointsOnSell);
    }

    function _exemptFee(address account) internal virtual {
        require(!_feeExemption[account], "Account is already exempted");
        _feeExemption[account] = true;
        emit ExemptFee(account);
    }

    function _revokeFeeExemption(address account) internal virtual {
        require(_feeExemption[account], "Account is not exempted");
        _feeExemption[account] = false;
        emit RevokeFeeExemption(account);
    }
}

contract BeatFiAi is Feeable, ERC20, Ownable {
    using Address for address payable;
    
    IRouter public router;
    address public pair;
    bool _interlock;

    modifier lockTheSwap() {
        _interlock = true;
        _;
        _interlock = false;
    }

    constructor ()
        ERC20("BeatFi.AI", "BEATFI") 
        Feeable(500, 500, 500, 0x3F277603d338cCDa2fB1Da6505Df05A77971F572)
        Ownable()
    {
        IRouter _router = IRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        address _pair = IFactory(_router.factory()).createPair(address(this), _router.WETH());
        router = _router;
        pair = _pair;

        _approve(address(this), address(router), type(uint).max);

        exemptFee(msg.sender);

        _mintOnce(msg.sender, 10_000_000_000 * 10**decimals());
    }

    receive() external payable {}

    function rescueStuckFund() public onlyOwner {
        payable(owner()).sendValue(address(this).balance);
    }

    function updateFeeRecipient(address newRecipient) public onlyOwner {
        _updateFeeRecipient(newRecipient);
    }

    function updateFeePointsOnBuy(uint newFeePointsOnBuy) public onlyOwner {
        _updateFeePointsOnBuy(newFeePointsOnBuy);
    }

    function updateFeePointsOnSell(uint newFeePointsOnSell) public onlyOwner {
        _updateFeePointsOnSell(newFeePointsOnSell);
    }

    function exemptFee(address account) public onlyOwner {
        _exemptFee(account);
    }

    function revokeFeeExemption(address account) public onlyOwner {
        _revokeFeeExemption(account);
    }

    function _transfer(address from, address to, uint amount) internal override {
        if (_interlock || amount == 0 || isFeeExempted(from) || isFeeExempted(to) || (from != pair && to != pair)) {
            super._transfer(from, to, amount);
        } else {
            uint _feePoints; 
            if (from == pair) {
                _feePoints = feePointsOnBuy();
            } else {
                _feePoints = feePointsOnSell();
            }

            if (_feePoints > 0) {
                uint fees = amount * _feePoints / 10_000;
                amount = amount - fees;

                super._transfer(from, address(this), fees);
            }

            if (from != pair) {
                liquify();
            }
                
            super._transfer(from, to, amount);
        }
    }

    function liquify() private lockTheSwap {
        uint toSwap = balanceOf(address(this));

        if (toSwap > 0) {
            swapTokensForEth(toSwap);
        }
    }

    function swapTokensForEth(uint tokenAmount) private {
        uint256 initialBalance = address(this).balance;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        
        try router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        ) {} catch {
            return;
        }

        uint256 deltaBalance = address(this).balance - initialBalance;
        payable(feeRecipient()).sendValue(deltaBalance);
    }
}