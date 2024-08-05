//SPDX-License-Identifier: MIT

/*
 * Telegram: https://t.me/safescanai
 * Twitter: https://twitter.com/SafeScanAI
 * Website: https://safescanai.com/
 * Dapp: https://app.safescanai.com/
 * Docs: https://safe-scan-ai.gitbook.io/
*/

pragma solidity ^0.8.0;

contract SafeScanAI {
    string public constant NAME = "Safe Scan AI";
    string public constant SYMBOL = "SSAI";
    uint8 public constant DECIMALS = 18;
    uint256 public constant TOTAL_SUPPLY = 100000000 * (10 ** uint256(DECIMALS));

    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function totalSupply() public pure returns (uint256) {
        return TOTAL_SUPPLY;
    }

    function name() public pure returns (string memory) {
        return NAME;
    }

    function symbol() public pure returns (string memory) {
        return SYMBOL;
    }

    function decimals() public pure returns (uint8) {
        return DECIMALS;
    }
}