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

contract GUARDWALLET {
    address public admin;
    IERC20 public preSaleToken;
    IERC20 public usdtToken;

    uint256 public totalSold;
    uint256 public tokenCap;
    uint256 public startTime;
    uint256 public endTime;
    uint256 public constant TOKEN_PRICE = 0.0982 * 10**18;

    mapping(address => uint256) public buyAmount;
    mapping(address => uint256) public claimableTokens;
    event TokensPurchased(address indexed buyer, uint256 amount, uint256 totalPrice);

    constructor(uint256 _tokenCap, uint256 _startTime, uint256 _endTime) {
        admin = msg.sender;
        preSaleToken = IERC20(0xE1a2a1886356586CB093C117961dc36fC266B176);
        usdtToken = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);
        tokenCap = _tokenCap;
        startTime = _startTime;
        endTime = _endTime;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }

    modifier onlyWhileOpen() {
        require(block.timestamp >= startTime && block.timestamp <= endTime, "ICO is not active");
        _;
    }

    function buyTokensWithUSDT(uint256 usdtAmount) external onlyWhileOpen {
        uint256 numberOfTokens = (usdtAmount * 10**18) / TOKEN_PRICE;
        require(totalSold <= tokenCap, "All Token are Sold.");
      
        require(
            usdtToken.transferFrom(msg.sender, address(this), usdtAmount),
            "Token transfer failed"
        );
        buyAmount[msg.sender] += numberOfTokens;
        totalSold += numberOfTokens;
        claimableTokens[msg.sender] += numberOfTokens;
        emit TokensPurchased(msg.sender, numberOfTokens, usdtAmount);
    }

    function claimTokens() external {
        require(block.timestamp > endTime, "ICO has not ended yet");
        require(claimableTokens[msg.sender] > 0, "No tokens to claim");
        
        uint256 tokensToClaim = claimableTokens[msg.sender];
        claimableTokens[msg.sender] = 0;
        
        require(preSaleToken.transfer(msg.sender, tokensToClaim), "Claim token failed");
    }

    function endICO() external onlyAdmin {
        require(block.timestamp < endTime, "ICO has already ended");
        endTime = block.timestamp; // End ICO immediately
    }

    function withdrawFundsUSD() external onlyAdmin {
        require(block.timestamp > endTime, "ICO has not ended yet");
        uint256 contractBalance = preSaleToken.balanceOf(address(this));
        require(preSaleToken.transfer(admin, contractBalance), "Funds withdrawal failed");
    }

    function getClaimableTokens(address user) external view returns (uint256) {
        return claimableTokens[user];
    }
}