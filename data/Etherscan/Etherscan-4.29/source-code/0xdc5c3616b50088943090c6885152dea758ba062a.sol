// SPDX-License-Identifier: BIOS
pragma solidity ^0.8.0;
contract PaymentSplitter {
    function splitPayment(address payable recipient1, address payable recipient2) external payable {
        require(msg.value > 0, "Payment must be greater than 0");       
        uint256 amountToSend = msg.value / 2;
        recipient1.transfer(amountToSend);
        recipient2.transfer(amountToSend);
    }
}