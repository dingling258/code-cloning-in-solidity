// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract WETHCoin {
    uint8 balance = 255;
    function transfer() external{
        balance--;
    }
}