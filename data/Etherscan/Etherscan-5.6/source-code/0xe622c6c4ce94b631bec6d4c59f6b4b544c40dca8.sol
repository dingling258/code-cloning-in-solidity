// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;
/**
* getcig.eth
* version 0.0.2 - returns back excess ETH if over 1 ETH, instead of failing.
*
* Send a small amount of ETH to getcig.eth and you will get
* some Cigarettes back.
*
* https://www.coingecko.com/en/coins/cigarette
*
* The contract will swap the ETH and send you the CIG.
*
* DO NOT SEND MORE THAN 1 ETH.
*
* DO NOT SEND WETH TO THIS CONTRACT - ONLY ETH.
*
* DO NOT SEND FROM AN EXCHANGE
*
* Previous version deployed to 0x3d6A70DC23bdC3047536F00815a8AFC4c5A0E7B5
*
*/
//import "hardhat/console.sol";

contract GetCigBasic {
    address constant public weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address constant public cig = 0xCB56b52316041A62B6b5D0583DcE4A8AE7a3C629;
    IV2Router constant public sushiRouter  = IV2Router(0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F);
    constructor() {
        IWETH(weth).approve(
            0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F,
            type(uint256).max
        );                                     // allow Sushi spend our ETH
    }
    receive() external payable {
        uint256 v = msg.value;
        require(v > 0, "need ETH");
        if (v > 1 ether) {
            uint256 d = v - 1 ether;
            (bool success, ) = msg.sender.call{value: d}("");
            require(success, "unable to send excess eth");
            v = 1 ether;
        }
        IWETH(weth).deposit{value:v}();        // wrap ETH to WETH
        address[] memory path;
        path = new address[](2);
        path[0] = weth;
        path[1] = address(cig);
        sushiRouter.swapExactTokensForTokens(  // do the swap
            v,
            1,
            path,
            msg.sender,
            block.timestamp
        );
    }
}

interface IWETH {
    function deposit() external payable;
    function approve(address spender, uint256 amount) external returns (bool);
}

interface IV2Router {
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}