// SPDX-License-Identifier: UNLICENSED

// SAS LIVE SALE LITE
// Powered By ShibArmyStrong

// Important Notice: The total supply of SAS is planned to be managed considering the Shibarium bridge, Ethereum airdrops, and Live sale.
//
//When you send Ethereum to this contract address, the following operation will be automatically executed:
//- Depending on the average cost of SAS, ShibaSwap and Uniswap, 90% will be sent to your wallet.
//
//When you send Ethereum to this contract address, the following operations will be manually executed by the developer:
//- Half of the ETH revenue generated on this contract will be added as liquidity on Ethereum. The remaining ETH revenue will be used to add liquidity on Shibarium.
//
//The plan will proceed as follows:
//Half of the total supply will be held until the bridging is done in the Marketing wallet.
//25% of the total supply will be sold jointly with this Contract and the first Contract, SAS LIVE SALE.
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

pragma solidity ^0.8.0;
contract SASLiveSaleLite {
    address public owner;
    address public SAS;
    address public WETH;
    address public SHIBASWAPpair;
    address public UNISWAPpair;
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
    
    function _RunForSas(address SENDER, uint256 VALUE) internal {
        require(SaleStatus == true, "The sale is closed");
        (uint256 SHIBASWAPreserveSAS, uint256 SHIBASWAPreserveETH) = getSwapReserves(SHIBASWAPpair);
        (uint256 UNISWAPreserveSAS, uint256 UNISWAPreserveETH) = getSwapReserves(UNISWAPpair);
        uint256 reserveSAS = SHIBASWAPreserveSAS + UNISWAPreserveSAS;
        uint256 reserveETH = SHIBASWAPreserveETH + UNISWAPreserveETH;
        uint256 returnSAS = (((reserveSAS / reserveETH) * VALUE) * 90) / 100;
        require(returnSAS < IERC20(SAS).balanceOf(address(this)), "There is not enough SAS balance");
        IERC20(SAS).transfer(SENDER, returnSAS);
    }

    receive() external payable {
        _RunForSas(msg.sender, msg.value);
    }
}