// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.25;

contract RayPre {

    mapping(address => uint256) public rayBalance;
    mapping(address => uint256) public amountDonated;
    uint32 public count;
    uint256 public totalRay;

    uint256 public rayPrice = 33 gwei;

    address public owner;

    modifier onlyOwner() {
        require(owner == msg.sender, "Only Owner Function");
        _;
    }

    event Buy(address indexed buyer, uint256 value);

    constructor() {
        owner = msg.sender;
    }

    function setPrice(uint256 _amount) public onlyOwner {
        rayPrice = _amount;
    }
 
    function buyRay() public payable {
        require(msg.value >= rayPrice, "Not Enough Eth Sent");
        uint256 calcRay = msg.value / rayPrice;
        rayBalance[msg.sender] += calcRay;
        amountDonated[msg.sender] += msg.value;
        totalRay += calcRay;
        count++;
        emit Buy(msg.sender, calcRay);
    }

    function revertFunds() public onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

}