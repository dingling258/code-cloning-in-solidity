// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Ownable {
    address owner;
    function setOwner(address _owner) external{
        owner = _owner;
    }
}