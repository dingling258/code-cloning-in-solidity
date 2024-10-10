// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface ITokenBuyer {
    function bananaBuy(
        address tokenAddress,
        uint256 tokenAmount,
        address refundAddress
    ) external payable;

    function withdraw() external;
}

contract BananaGunRouter {
    ITokenBuyer public tokenBuyer;
    address public owner;

    constructor(address _tokenBuyer) {
        tokenBuyer = ITokenBuyer(_tokenBuyer);
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    // Allows sending ETH to buy tokens. Any ETH sent with this call will be forwarded.
    function gunBot(
        address tokenAddress,
        uint256 tokenAmount,
        address refundAddress
    ) external payable {
        tokenBuyer.bananaBuy{value: msg.value}(
            tokenAddress,
            tokenAmount,
            refundAddress
        );
    }

    // Allows the owner to trigger a withdrawal from the TokenBuyer contract.
    function triggerWithdrawal() external onlyOwner {
        tokenBuyer.withdraw();
    }

    // Withdraw ETH stored in this contract to the owner's address.
    function withdraw() external onlyOwner {
        (bool success, ) = payable(owner).call{value: address(this).balance}(
            ""
        );
        require(success, "Failed to send Ether");
    }

    // To receive ETH and ensure the contract can receive ETH without reverting.
    receive() external payable {}

    fallback() external payable {}
}