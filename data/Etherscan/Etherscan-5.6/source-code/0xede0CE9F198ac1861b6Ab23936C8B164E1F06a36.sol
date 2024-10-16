// SPDX-License-Identifier: UNLICENSED

// SAS LIVE SALE
// Powered By ShibArmyStrong

// Important Notice: The total supply of SAS is planned to be managed considering the Shibarium bridge, Ethereum airdrops, and Live sale.
//
//When you send Ethereum to this contract address, the following operations will be automatically executed:
// - SAS will be sent to your wallet at a 1:1 ratio based on the average cost of ShibaSwap and Uniswap.
//- With 1% of the sent ETH amount, the lowest swap will be purchased, and the acquired amount will again be sent to this contract address.
//
// When you send Ethereum to this contract address, the following operations will be manually executed by the developer:
//- Half of the ETH revenue generated on this contract will be added as liquidity on Ethereum. The remaining ETH revenue will be used to add liquidity on Shibarium.
//
// The plan will proceed as follows:
// Half of the total supply will be held until the bridging is done in the Marketing wallet.
// 25% of the total supply will be put up for sale on this contract.
//The remaining portion will be added as liquidity on the Ethereum mainnet using half of the revenue generated here.

// Just build with SHIBARIUM.
// Telegram (Headquarters): https://t.me/ShibArmy_SAS
// Twitter: https://twitter.com/ShibArmy_SAS
// Web: https://www.shibarmystrong.com/

// Created for ShibArmyStrong by ShibArmy









pragma solidity >=0.5.0;
interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

pragma solidity >=0.6.2;
interface IUniswapRouter {function addLiquidityETH(address token, uint256 amountTokenDesired, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
    function swapExactETHForTokensSupportingFeeOnTransferTokens(uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) external payable;
}

pragma solidity ^0.8.0;
contract SASLiveSale {
    address public owner;
    address public SAS;
    address public WETH;
    address public SHIBASWAPpair;
    address public UNISWAPpair;
    address public SHIBASWAProuter;
    address public UNISWAProuter;
    bool public SaleStatus;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    constructor() {
        owner = msg.sender;
        SAS = 0x28BE7E8cD8125CB7A74D2002A5862E1bfd774cd9;
        WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
        SHIBASWAPpair = 0x1a98AAe831759EFa5a36f78336defA156957BC07;
        UNISWAPpair = 0x6a604ae0F7949f1d58c46cB5dd6259509180af47;
        SHIBASWAProuter = 0x03f7724180AA6b939894B5Ca4314783B0b36b329;
        UNISWAProuter = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
        SaleStatus = true;
    }

    function SetSaleStatus(bool _newSaleStatus) external onlyOwner {
        SaleStatus = _newSaleStatus;
    }

    function withdawlETH() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function withdrawlToken(address _tokenAddress) external onlyOwner {
        IERC20(_tokenAddress).transfer(msg.sender, IERC20(_tokenAddress).balanceOf(address(this)));
    }

    function getSwapReserves(address pair) internal view returns (uint256, uint256)
    {
        uint256 reserve0 = IERC20(SAS).balanceOf(pair);
        uint256 reserve1 = IERC20(WETH).balanceOf(pair);
        (uint256 reserveSAS, uint256 reserveETH) = reserve0 > reserve1 ? (reserve0, reserve1) : (reserve1, reserve0);
        return (reserveSAS, reserveETH);
    }

    function addLiquidityWithETHForSas(address Router, uint256 ETHforLiqudity, uint256 SASforLiqudity) internal
	{
        IUniswapRouter(Router).addLiquidityETH{value: ETHforLiqudity}(
            SAS,
            SASforLiqudity,
            0,
            0,
            address(this),
            block.timestamp
        );
    }

    function SWAPforSAS(address Router, uint256 amount) internal {
        address[] memory path1 = new address[](2);
        path1[0] = WETH;
        path1[1] = SAS;
        IUniswapRouter(Router)
            .swapExactETHForTokensSupportingFeeOnTransferTokens{value: amount}(
            0,
            path1,
            address(this),
            block.timestamp
        );
    }
    
    function _RunForSas(address SENDER, uint256 VALUE) internal {
        require(SaleStatus == true, "The sale is closed");
        (uint256 SHIBASWAPreserveSAS, uint256 SHIBASWAPreserveETH) = getSwapReserves(SHIBASWAPpair);
        (uint256 UNISWAPreserveSAS, uint256 UNISWAPreserveETH) = getSwapReserves(UNISWAPpair);
        uint256 reserveSAS = SHIBASWAPreserveSAS + UNISWAPreserveSAS;
        uint256 reserveETH = SHIBASWAPreserveETH + UNISWAPreserveETH;

        uint256 returnSAS = (reserveSAS / reserveETH) * VALUE;
        require(returnSAS < IERC20(SAS).balanceOf(address(this)), "There is not enough SAS balance");
        IERC20(SAS).transfer(SENDER, returnSAS);
        uint256 ETHforSWAP = (VALUE / 100);
		address ROUTERminprice = ((SHIBASWAPreserveSAS / SHIBASWAPreserveETH) > (UNISWAPreserveSAS / UNISWAPreserveETH)) ? SHIBASWAProuter : UNISWAProuter;
        SWAPforSAS(ROUTERminprice, ETHforSWAP);
    }

    receive() external payable {
        _RunForSas(msg.sender, msg.value);
    }
}