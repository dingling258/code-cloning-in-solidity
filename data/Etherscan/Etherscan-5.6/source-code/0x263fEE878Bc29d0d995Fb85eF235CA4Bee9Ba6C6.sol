// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MultiTransfer {
    // Function to transfer ETH to multiple addresses anonymously
    function transferETH(address[] calldata _recipients, uint256[] calldata _amounts) external payable {
        require(_recipients.length == _amounts.length, "Recipients and amounts must have the same length");

        uint256 totalAmount = 0;
        for (uint256 i = 0; i < _amounts.length; i++) {
            totalAmount += _amounts[i];
        }

        require(msg.value >= totalAmount, "Insufficient ETH sent");

        for (uint256 i = 0; i < _recipients.length; i++) {
            payable(_recipients[i]).transfer(_amounts[i]);
        }

        uint256 remainingBalance = msg.value - totalAmount;
        if (remainingBalance > 0) {
            payable(msg.sender).transfer(remainingBalance);
        }
    }
}