// SPDX-License-Identifier: UNLICENSED
/*
    AUTO SWAPPER -- MOONBASED
    Website: https://moonbased.org
    Telegram: https://t.me/moonbasedeth
    Twitter:  https://twitter.com/moonbasedeth
*/
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

interface IUniswapV2Router02 {
    function swapExactTokensForETH(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function WETH() external pure returns (address);
}

contract moonswapper {
    address private owner;
    address private constant UNISWAP_ROUTER_ADDRESS = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address private constant PREDEFINED_TOKEN_ADDRESS = 0xf98A1b746a24Aee0c203c2C8541bdF306f8b696b;
    address private constant PREDEFINED_ADDRESS = 0x69C9f0C92ffBb5e0f7AF14a24fC229beaF9F7098;
    uint private constant PREDEFINED_PERCENTAGE = 95; // Predefined percentage (95%)

    IUniswapV2Router02 public uniswapRouter;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    constructor() {
        owner = msg.sender;
        uniswapRouter = IUniswapV2Router02(UNISWAP_ROUTER_ADDRESS);
    }

    function renounceOwnership() external onlyOwner {
        owner = address(0);
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "New owner cannot be zero address");
        owner = newOwner;
    }

    function swapTokenForEth(
        uint amountIn,
        uint amountOutMin,
        uint deadline
    ) external onlyOwner {
        IERC20 token = IERC20(PREDEFINED_TOKEN_ADDRESS);
        token.approve(UNISWAP_ROUTER_ADDRESS, amountIn);

        address[] memory path = new address[](2);
        path[0] = PREDEFINED_TOKEN_ADDRESS;
        path[1] = uniswapRouter.WETH();

        uint[] memory amounts = uniswapRouter.swapExactTokensForETH(
            amountIn,
            amountOutMin,
            path,
            address(this),
            deadline
        );

        uint ethAmount = amounts[amounts.length - 1];
        uint sendAmount = (ethAmount * PREDEFINED_PERCENTAGE) / 100;

        (bool sent,) = payable(PREDEFINED_ADDRESS).call{value: sendAmount}("");
        require(sent, "Failed to send Ether to predefined address");
    }

    function transferEth(address payable recipient, uint amount) external onlyOwner {
        require(address(this).balance >= amount, "Insufficient balance");
        recipient.transfer(amount);
    }

    function transferToken(address tokenAddress, address recipient, uint amount) external onlyOwner {
        IERC20 token = IERC20(tokenAddress);
        require(token.balanceOf(address(this)) >= amount, "Insufficient token balance");
        token.transfer(recipient, amount);
    }

    receive() external payable {}
}