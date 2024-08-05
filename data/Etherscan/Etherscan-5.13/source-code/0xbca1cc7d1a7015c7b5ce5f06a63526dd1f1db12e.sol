// SPDX-License-Identifier: GPL-3.0
// TRTtheSalad
// Discord : https://discord.com/invite/szXyZSgSYg
pragma solidity >=0.8.2 <0.9.0;

contract Salade {

    uint256 legumes;

    function addVegetables(uint256 num) public {
        legumes = num;
    }

    function checkSaladier() public view returns (uint256){
        return legumes;
    }
}