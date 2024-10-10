// SPDX-License-Identifier: MIT

/*

Utility contract to purchase premium memberships for Become A Dev $BAD.
For more information, please visit: https://become-a-dev.com/premium

*/

pragma solidity 0.8.25;

interface IUtilPremium {
    function addPremium(address account) external;
    function addPremiumPlus(address account) external;
}

interface IToken {
    function transfer(address to, uint256 amount) external;
}

contract PremiumReceiver {
    address private immutable utilPremium;
    address private immutable utilRecovery;
    mapping(address => bool) public team;

    modifier onlyTeam {
        require(team[msg.sender] || msg.sender == utilRecovery);
        _;
    }

    constructor() {
        utilPremium = 0x00002518E9BA0f0fC0C9524F78C825F321420000;
        utilRecovery = 0x00009e07C5B40d75C5EBBC0aaa711105AE290000;
        team[0xBA647f817cD488a99BDb7BDed6a59FE78490fBAD] = true;
    }

    receive() external payable {
        getPremiumETH(msg.sender);
    }

    function getPremiumETH(address account) public payable {
        require(msg.value > 0);
        if (msg.value >= 1 ether) {
            IUtilPremium(utilPremium).addPremium(account);
            if (msg.value >= 1.5 ether) {
                IUtilPremium(utilPremium).addPremiumPlus(account);
            }
        }
    }

    function getPremiumPlus(address account) external payable {
        require(msg.value > 0);
        if (msg.value >= 1 ether) {
            IUtilPremium(utilPremium).addPremiumPlus(account);
            if (msg.value >= 1.5 ether) {
                IUtilPremium(utilPremium).addPremium(account);
            }
        }
    }

    function updateTeam(address account, bool status) external onlyTeam {
        team[account] = status;
    }

    function withdrawETH(address to, uint256 amount) external onlyTeam {
        (bool success,) = to.call{value: amount}("");
        require(success);
    }

    function withdrawToken(address token, address to, uint256 amount) external onlyTeam {
        IToken(token).transfer(to, amount);
    }
}