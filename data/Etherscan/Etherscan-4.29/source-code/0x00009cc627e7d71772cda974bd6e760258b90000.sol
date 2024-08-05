// SPDX-License-Identifier: MIT

/*

Utility contract to deploy standard tokens by Become A Dev $BAD.
For more information, please visit: https://become-a-dev.com/deployer

*/

pragma solidity 0.8.25;

interface IUtilFactory {
    function deploy(
        address owner,
        string calldata name,
        string calldata symbol,
        uint256 totalSupply,
        uint256 liquiditySupply,
        uint256 maxWallet,
        uint256 buyFee,
        uint256 sellFee,
        uint256 lockDays
    ) external payable;
    function deployerMode() external view returns (uint256);
    function getFactory(uint256 utility) external view returns (address);
}

interface IUtilPremium {
    function premium(address account) external view returns (bool);
}

contract DeployerStandard {
    address private immutable utilPremium;
    address private immutable utilFactory;

    constructor() {
        utilPremium = 0x00002518E9BA0f0fC0C9524F78C825F321420000;
        utilFactory = 0x0000664249B16CcBC8D72876EFEDdCF013C60000;
    }

    function deploy(
        address owner,
        string calldata name,
        string calldata symbol,
        uint256 totalSupply,
        uint256 liquiditySupply,
        uint256 maxWallet,
        uint256 buyFee,
        uint256 sellFee,
        uint256 lockDays
    )
        external payable
    {
        IUtilFactory(IUtilFactory(utilFactory).getFactory(1)).deploy{value: msg.value}(
            owner,
            name,
            symbol,
            totalSupply,
            liquiditySupply,
            maxWallet,
            buyFee,
            sellFee,
            lockDays
        );
    }

    function checkPremium(address account) external view returns (bool) {
        if (IUtilFactory(IUtilFactory(utilFactory).getFactory(1)).deployerMode() != 3) {
            return IUtilPremium(utilPremium).premium(account);
        } else {
            return true;
        }
    }
}