//SPDX-License-Identifier: UNLICENSED
/*  
 * -- Welcome to Vision --
 *
 * CAREFUL, THIS CONTRACT IS ONLY A PROMOTIONAL CONTRACT. THE OFFICIAL VISION CONTRACT IS ALREADY OUT !
 * CHECK OUT OUR TG BELOW FOR MORE INFORMATION !
 *
 * Website: https://vision-scanner.com/
 * White paper:  https://vision-scanner.com/docs/
 * Twitter: https://twitter.com/Track_Vision_
 * Telegram:  https://t.me/VisionPublic => Join our TG to have access to the bot :)
 * Scam stat: https://vision-scanner.com/app/
 * 
 * VISION IS THE ULTIMATE SMART CONTRACT SCAM FILTER !
 * 
 * The only Telegram Bot that notifies you with safe & secure contracts on the ETH blockchain !
 * More than 90% of scams are filtered out !
 * Our team manually analyze new scams everyday and keep VISION up to date in order to protect your investements.
 * With unique features like our own backtesting algorithm, embrace security !
 * Stop losing money to rugpull and scams, use VISION bot now !
 */

pragma solidity ^0.8.1;

contract VISION {
    string public constant NAME = "Vision Bot";
    string public constant SYMBOL = "VISION";
    uint8 public constant DECIMALS = 18;
    uint256 public constant TOTAL_SUPPLY = 123456000 * (10 ** uint256(DECIMALS));

    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
        emit OwnershipTransferred(_owner, address(0));
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