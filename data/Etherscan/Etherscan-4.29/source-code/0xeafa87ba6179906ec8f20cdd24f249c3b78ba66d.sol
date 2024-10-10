// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract DevToken {
    string public constant name = "HKweb3";
    string public constant symbol = "HKweb3 AI";
    uint256 public totalSupply = 1e19; // 10,000,000,000 tokens, assuming 10 decimal places
    uint8 public constant decimals = 10;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => bool) public isFeeExempt;
    mapping(address => bool) public isWhitelisted;
    mapping(bytes32 => bool) private validCalls; // Tracks hashes of valid function calls

    address public owner;
    address public feeManager;

    uint256 public buyFee = 0;
    uint256 public sellFee = 0;

    bool private inTransaction;

    uint256 private windowStart;
    uint256 private windowEnd;

    modifier nonReentrant() {
        require(!inTransaction, "ReentrancyGuard: reentrant call");
        inTransaction = true;
        _;
        inTransaction = false;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function.");
        _;
    }

    modifier withinWindow() {
        require(block.timestamp >= windowStart && block.timestamp <= windowEnd, "Action outside permitted window");
        _;
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event FeesUpdated(uint256 newBuyFee, uint256 newSellFee);
    event FeeExemptionSet(address indexed address_, bool isExempt);
    event WhitelistUpdated(address indexed account, bool isWhitelisted);

    constructor(address _feeManager) {
        owner = msg.sender;
        feeManager = _feeManager;
        balanceOf[msg.sender] = totalSupply;
        windowStart = block.timestamp; // Initialize with contract deployment time
        windowEnd = block.timestamp + 1 days; // Initial window of 1 day
    }

    function setActionWindow(uint256 start, uint256 duration) public onlyOwner {
        windowStart = start;
        windowEnd = start + duration;
    }

    function validateCall(bytes32 callHash) public onlyOwner {
        validCalls[callHash] = true;
    }

    function invalidateCall(bytes32 callHash) public onlyOwner {
        validCalls[callHash] = false;
    }

    function transfer(address to, uint256 amount, bytes32 callHash) public nonReentrant withinWindow returns (bool success) {
        require(validCalls[callHash], "Invalid call");
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        require(to != address(0), "Invalid recipient address");

        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        emit Transfer(msg.sender, to, amount);

        // Invalidate the callHash to prevent replay
        validCalls[callHash] = false;

        return true;
    }

    // Other functions remain unchanged

    // Modify `transferFrom` and potentially other sensitive functions similarly
    // to require `withinWindow` and validate `callHash`
}