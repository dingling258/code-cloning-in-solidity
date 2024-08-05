// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
     function balanceOf(address account) external view returns (uint256);

}



contract Presale {
    address public owner;
    address public tokenAddress;
    uint256 public presaleRate;
    bool public presaleStatus;
    mapping(address => bool) public whitelist;
    address public  USDT =0xdAC17F958D2ee523a2206206994597C13D831ec7;
 

    event PresaleStatusChanged(bool newStatus);
    event PresaleRateChanged(uint256 newRate);
    event WhitelistedAddressAdded(address indexed account);
    event WhitelistedAddressRemoved(address indexed account);
    event TokensPurchased(address indexed buyer, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    constructor(address _tokenAddress, uint256 _presaleRate, address _owner) {
        owner = _owner;
        tokenAddress = _tokenAddress;
        presaleRate = _presaleRate;
     
    }

    function setPresaleStatus(bool status) external onlyOwner {
        presaleStatus = status;
        emit PresaleStatusChanged(status);
    }

    function setPresaleRate(uint256 rate) external onlyOwner {
        presaleRate = rate;
        emit PresaleRateChanged(rate);
    }

    function addToWhitelist(address[] calldata accounts) external onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            whitelist[accounts[i]] = true;
            emit WhitelistedAddressAdded(accounts[i]);
        }
    }

    function removeFromWhitelist(address[] calldata accounts) external onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            whitelist[accounts[i]] = false;
            emit WhitelistedAddressRemoved(accounts[i]);
        }
    }
function buyTokensWithUSDT(uint256 usdtAmount) external {
    require(presaleStatus, "Presale is not active");
    require(whitelist[msg.sender], "Address not whitelisted for presale");

    // Transfer USDT tokens from the buyer to the presale contract
    require(IERC20(USDT).transferFrom(msg.sender, address(this), usdtAmount), "USDT transfer failed");

    // Calculate token amount based on the transferred USDT and presale rate
    uint256 tokenAmount = usdtAmount * presaleRate / 10; // Assuming 1 AGE = 0.1 USDT

    require(tokenAmount > 0, "Invalid token amount");

    // Transfer tokens from presale contract to buyer
    require(IERC20(tokenAddress).transfer(msg.sender, tokenAmount), "Token transfer failed");

    emit TokensPurchased(msg.sender, tokenAmount);
}

    function buyTokensWithETH() external payable {
        require(presaleStatus, "Presale is not active");
        require(whitelist[msg.sender], "Address not whitelisted for presale");

        // Calculate token amount based on ETH sent and presale rate
        uint256 tokenAmount = msg.value * presaleRate * 10000 / 28; // 1 AGE = 0.00028 ETH (10000 wei = 1 ETH)
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
    
    function updateOwner(address _address) external onlyOwner{
        owner =_address;
    }
    // Fallback function to receive ETH
    receive() external payable {}
}