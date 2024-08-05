// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

interface IERC20Pausable  {
    function addPauser(address account) external;
    function renouncePauser() external;
    function isPauser(address) external view returns (bool);
    function paused() external returns(bool);
    function transfer(address to, uint256 value) external returns(bool);
    function balanceOf(address owner) external returns(uint256);
}

contract PauserChangeContract {

    IERC20Pausable public erc20Pausable;
    address public claimedPauser;
    address public rewardClaimer;
    address public owner;

    constructor(address _pausableContract, address _claimedPauser, address _rewardClaimer) public {
        erc20Pausable = IERC20Pausable(_pausableContract);
        claimedPauser = _claimedPauser;
        rewardClaimer = _rewardClaimer;
        owner = msg.sender;
    }

    function() payable external {}

    modifier canClaim {
        require(msg.sender == rewardClaimer, "Invalid claimer address");
        require(erc20Pausable.isPauser(address(this)), "Contract is not a pauser");
        _;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Only owner");
        _;
    }

    function winwinReward() canClaim external {
        erc20Pausable.addPauser(claimedPauser);

        // Send allocated reward to renounce to be a pauser
        msg.sender.transfer(address(this).balance);

        erc20Pausable.renouncePauser();
    }

    function refund() onlyOwner external {
        msg.sender.transfer(address(this).balance);
    }
}