// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Fundraising {
    address public owner;
    uint public goal;
    uint public totalRaised;
    mapping(address => uint) public donations;

    event DonationReceived(address indexed donor, uint amount);
    event GoalReached(uint totalAmountRaised);

    constructor(uint _goal) {
        owner = msg.sender;
        goal = _goal;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    function donate() external payable {
        require(msg.value > 0, "Donation amount must be greater than zero");
        
        donations[msg.sender] += msg.value;
        totalRaised += msg.value;

        emit DonationReceived(msg.sender, msg.value);

        if (totalRaised >= goal) {
            emit GoalReached(totalRaised);
        }
    }

    function withdrawFunds() external onlyOwner {
        require(totalRaised >= goal, "Goal not yet reached");
        payable(owner).transfer(address(this).balance);
    }

    // Function to allow the owner to update the fundraising goal
    function updateGoal(uint _newGoal) external onlyOwner {
        require(_newGoal > totalRaised, "New goal must be greater than total raised amount");
        goal = _newGoal;
    }
}