// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0 <0.9.0;

contract MessageStorage {
    bytes32 messageData;
	
    constructor() {
        messageData = 0x322e2054696d6f746865757320312c373b20416c6c6573204775746521000000;
    }
	
    function get() public view returns (bytes32) {
        return messageData;
    }
}