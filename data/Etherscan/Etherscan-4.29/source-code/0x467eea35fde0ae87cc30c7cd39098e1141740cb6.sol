// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract PreSale {
    address public admin;
    IERC20 public preSaleToken;
    IERC20 public usdtToken;

    uint256 public totalSold;

    uint256 public constant TOKEN_PRICE = 0.0982 *10**18;

    mapping(address => uint256) public buyAmount;
    event TokensPurchased(address indexed buyer, uint256 amount, uint256 totalPrice);

    constructor() {
        admin = msg.sender;
        preSaleToken = IERC20(0xE1a2a1886356586CB093C117961dc36fC266B176);
        usdtToken = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }

    function buyTokensWithUSDT(uint256 usdtAmount) external {
        uint256 numberOfTokens = (usdtAmount * 10**18) / TOKEN_PRICE;
        
        require(
            usdtToken.transferFrom(msg.sender, admin, usdtAmount),
            "Token transfer failed"
        );
        buyAmount[msg.sender] += numberOfTokens;
        totalSold += numberOfTokens;
        require(preSaleToken.transfer(msg.sender, numberOfTokens), "Claim token failed");
        emit TokensPurchased(msg.sender, numberOfTokens, usdtAmount);
    }

    function withdrawFundsUSD() external onlyAdmin {
        uint256 contractBalance = preSaleToken.balanceOf(address(this));
        require(preSaleToken.transfer(admin, contractBalance), "Funds withdrawal failed");
    }
}