// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
     function balanceOf(address account) external view returns (uint256);

}



contract AgeIDO {
    address public owner;
    address public tokenAddress;
    uint256 public presaleRateETH;
    uint256 public presaleRateUSDT;
    bool public presaleStatus;
    mapping(address => bool) public whitelist;
    address public  USDT =0xdAC17F958D2ee523a2206206994597C13D831ec7;
 

    event PresaleStatusChanged(bool newStatus);
    event PresaleRateChangedETH(uint256 newRate);
    event PresaleRateChangedUSDT(uint256 newRate);
    event TokensPurchased(address indexed buyer, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    constructor(address _tokenAddress, uint256 _presaleRateETH,uint256 _presaleRateUSDT, address _owner) {
        owner = _owner;
        tokenAddress = _tokenAddress;
        presaleRateETH = _presaleRateETH;
        presaleRateUSDT = _presaleRateUSDT;
     
    }

    function setPresaleStatus(bool status) external onlyOwner {
        presaleStatus = status;
        emit PresaleStatusChanged(status);
    }

    function setPresaleRateETH(uint256 rate) external onlyOwner {
        presaleRateETH = rate;
        emit PresaleRateChangedETH(rate);
    }

    function setPresaleRateUSDT(uint256 rate) external onlyOwner {
        presaleRateUSDT = rate;
        emit PresaleRateChangedUSDT(rate);
    }



function buyTokensWithUSDT(uint256 usdtAmount) external {
    require(presaleStatus, "Presale is not active");

    // Transfer USDT tokens from the buyer to the presale contract
    require(IERC20(USDT).transferFrom(msg.sender, address(this), usdtAmount), "USDT transfer failed");

    // Calculate token amount based on the transferred USDT and presale rate
    uint256 tokenAmount = usdtAmount * presaleRateUSDT; // 

    require(tokenAmount > 0, "Invalid token amount");

    // Transfer tokens from presale contract to buyer
    require(IERC20(tokenAddress).transfer(msg.sender, tokenAmount), "Token transfer failed");

    emit TokensPurchased(msg.sender, tokenAmount);
}

    function buyTokensWithETH() external payable {
        require(presaleStatus, "Presale is not active");

        // Calculate token amount based on ETH sent and presale rate
        uint256 tokenAmount = msg.value/1e18 / presaleRateETH / 1e18; // (1 ether = 1e18 wei)
        require(tokenAmount > 0, "Invalid token amount");

        // Transfer tokens from presale contract to buyer
        IERC20(tokenAddress).transfer(msg.sender, tokenAmount);

        emit TokensPurchased(msg.sender, tokenAmount);
    }

    // Owner can withdraw remaining tokens from the contract
    function withdrawTokens(address _tokenAddress) external onlyOwner {
        uint256 tokenBalance = IERC20(_tokenAddress).balanceOf(address(this));
        IERC20(tokenAddress).transfer(owner, tokenBalance);
    }

    function checkUSDTBalance() external view onlyOwner returns (uint256) {
        return IERC20(USDT).balanceOf(address(this));
    }
    
    function updateOwner(address _address) external onlyOwner{
        owner =_address;
    }
    // Fallback function to receive ETH
    receive() external payable {}
}