// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BlokAISeedDistro {
    address public owner;
    BlokAIToken public blokAISeedBloks;
    uint256 public saleStartTimestamp;
    uint256 public saleEndTimestamp;
    uint256 public constant maxSeedBloksForSale = 75000000 * 10**18; // 75 million blokAI Seed BLOKS
    uint256 public tokensSold;
    uint256 public tokenPrice = 500000; // 500000 wei per 0.01 ETH
    bool private locked;
    mapping(address => uint256) public tokensBoughtByAddress;
   
    event TokensPurchased(address indexed buyer, uint256 amountSpent, uint256 tokensReceived);
    event SaleCancelled();
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event TokensWithdrawn(address indexed recipient, uint256 amount);
    event SeedBloksPriceChanged(uint256 newPrice);
    event SaleExtended(uint256 newEndTimestamp);
    event TokensReturned(address indexed recipient, uint256 amount);
   
    constructor() {
        owner = msg.sender;
        blokAISeedBloks = new BlokAIToken();
        saleStartTimestamp = block.timestamp;
        saleEndTimestamp = block.timestamp + 14 days;
        require(saleEndTimestamp > saleStartTimestamp, "Sale end timestamp must be greater than sale start timestamp");
    }
   
    receive() external payable {
        getSeedBloks();
    }
   
    modifier nonReentrant() {
        require(!locked, "No re-entrancy allowed");
        locked = true;
        _;
        locked = false;
    }
   
    /**
     * @dev Allows users to purchase blokAI BLOKS Seed Tokens by sending ETH.
     * The function calculates the amount of tokens based on the ETH value sent and transfers the tokens to the buyer.
     * The ETH is transferred to the contract owner.
     */
    function getSeedBloks() public payable nonReentrant {
        require(block.timestamp >= saleStartTimestamp && block.timestamp <= saleEndTimestamp, "Token sale is not active");
        require(msg.value >= 0.01 ether, "Minimum purchase amount is 0.01 ETH");
        uint256 tokenAmount = calculateSeedBloksAmount(msg.value);
        require(tokenAmount > 0, "Token amount must be greater than zero");
        require(tokensSold + tokenAmount <= maxSeedBloksForSale, "Purchase would exceed the maximum tokens for sale");
        require(blokAISeedBloks.balanceOf(address(this)) >= tokenAmount, "Insufficient tokens in the contract");
       
        tokensSold += tokenAmount;
        tokensBoughtByAddress[msg.sender] += tokenAmount;
       
        payable(owner).transfer(msg.value);
        blokAISeedBloks.transfer(msg.sender, tokenAmount);
       
        emit TokensPurchased(msg.sender, msg.value, tokenAmount);
    }
   
    /**
     * @dev Calculates the amount of blokAI BLOKS Seed Tokens based on the ETH value.
     * @param amountETH The amount of ETH sent.
     * @return The amount of blokAI BLOKS Seed Tokens.
     */
    function calculateSeedBloksAmount(uint256 amountETH) public view returns (uint256) {
        return amountETH * tokenPrice;
    }
   
    /**
     * @dev Returns the remaining amount of blokAI BLOKS Seed Tokens available for sale.
     * @return The remaining amount of blokAI BLOKS Seed Tokens.
     */
    function getSeedBloksRemaining() public view returns (uint256) {
        return maxSeedBloksForSale - tokensSold;
    }
   
    /**
     * @dev Allows the contract owner to set a new price for the blokAI BLOKS Seed Tokens.
     * @param newPrice The new price for the blokAI BLOKS Seed Tokens.
     */
    function setSeedBloksPrice(uint256 newPrice) public {
        require(msg.sender == owner, "Only the contract owner can perform this action");
        tokenPrice = newPrice;
        emit SeedBloksPriceChanged(newPrice);
    }
   
    /**
     * @dev Returns the remaining time of the token sale.
     * @return The remaining time in seconds.
     */
    function getTimeRemaining() public view returns (uint256) {
        if (block.timestamp >= saleEndTimestamp) {
            return 0;
        } else {
            return saleEndTimestamp - block.timestamp;
        }
    }
   
    /**
     * @dev Allows the contract owner to cancel the token sale.
     * The sale end timestamp is set to the current timestamp.
     */
    function cancelSale() public {
        require(msg.sender == owner, "Only the contract owner can perform this action");
        require(block.timestamp < saleEndTimestamp, "Sale has already ended");
        saleEndTimestamp = block.timestamp;
        emit SaleCancelled();
    }
   
    /**
     * @dev Allows the contract owner to transfer ownership to a new address.
     * @param newOwner The address of the new owner.
     */
    function transferOwnership(address newOwner) public {
        require(msg.sender == owner, "Only the contract owner can perform this action");
        require(newOwner != address(0), "New owner cannot be the zero address");
        address previousOwner = owner;
        owner = newOwner;
        emit OwnershipTransferred(previousOwner, newOwner);
    }
   
    /**
     * @dev Allows the contract owner to withdraw a specified amount of tokens to a recipient address.
     * @param recipient The address to receive the tokens.
     * @param amount The amount of tokens to withdraw.
     */
    function withdrawTokens(address recipient, uint256 amount) public {
        require(msg.sender == owner, "Only the contract owner can perform this action");
        require(recipient != address(0), "Recipient cannot be the zero address");
        require(amount > 0, "Withdrawal amount must be greater than zero");
        require(blokAISeedBloks.balanceOf(address(this)) - tokensSold >= amount, "Insufficient tokens in the contract");
        blokAISeedBloks.transfer(recipient, amount);
        emit TokensWithdrawn(recipient, amount);
    }
   
    /**
     * @dev Allows the contract owner to extend the token sale by setting a new end timestamp.
     * @param newEndTimestamp The new end timestamp for the token sale.
     */
    function extendSale(uint256 newEndTimestamp) public {
        require(msg.sender == owner, "Only the contract owner can perform this action");
        require(block.timestamp < saleEndTimestamp, "Sale has already ended");
        require(newEndTimestamp > saleEndTimestamp, "New end timestamp must be greater than the current end timestamp");
        saleEndTimestamp = newEndTimestamp;
        emit SaleExtended(saleEndTimestamp);
    }
}

contract BlokAIToken {
    string public constant name = "blokAI Seed BLOKS";
    string public constant symbol = "BLOKSEED";
    uint8 public constant decimals = 18;
    uint256 public totalSupply = 75000000 * 10**18; // 75 million blokAI Seed Bloks
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
   
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
   
    constructor() {
        balanceOf[msg.sender] = totalSupply;
    }
   
    /**
     * @dev Transfers a specified amount of tokens from the sender to a recipient address.
     * @param recipient The address to receive the tokens.
     * @param amount The amount of tokens to transfer.
     * @return A boolean value indicating whether the transfer was successful.
     */
    function transfer(address recipient, uint256 amount) public returns (bool) {
        require(recipient != address(0), "Invalid recipient address");
        require(amount <= balanceOf[msg.sender], "Insufficient balance");
       
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
       
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }
   
    /**
     * @dev Approves a specified address to spend a certain amount of tokens on behalf of the sender.
     * @param spender The address to be approved.
     * @param amount The amount of tokens to approve.
     * @return A boolean value indicating whether the approval was successful.
     */
    function approve(address spender, uint256 amount) public returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
   
    /**
     * @dev Transfers a specified amount of tokens from one address to another using the allowance mechanism.
     * @param sender The address from which the tokens will be transferred.
     * @param recipient The address to receive the tokens.
     * @param amount The amount of tokens to transfer.
     * @return A boolean value indicating whether the transfer was successful.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        require(recipient != address(0), "Invalid recipient address");
        require(amount <= balanceOf[sender], "Insufficient balance");
        require(amount <= allowance[sender][msg.sender], "Insufficient allowance");
       
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        allowance[sender][msg.sender] -= amount;
       
        emit Transfer(sender, recipient, amount);
        return true;
    }
}