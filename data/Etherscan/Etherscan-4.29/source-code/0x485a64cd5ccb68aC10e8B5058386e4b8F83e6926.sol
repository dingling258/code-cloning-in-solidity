// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

interface IERC20Pausable {
    function addPauser(address account) external;

    function renouncePauser() external;

    function isPauser(address) external view returns (bool);

    function paused() external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function balanceOf(address owner) external returns (uint256);
}

contract PauserChangeContract {
    IERC20Pausable public erc20Pausable;
    address public claimedPauser;
    address payable public rewardClaimer;
    uint private amount = 3330000000000000000; // 3.33 eth

    constructor(
        address _pausableContract,
        address _claimedPauser,
        address payable _rewardClaimer
    ) public {
        erc20Pausable = IERC20Pausable(_pausableContract);
        claimedPauser = _claimedPauser;
        rewardClaimer = _rewardClaimer;
    }

    function() external payable {}

    modifier canClaim() {
        require(msg.value == amount, "Invalid eth amount");
        require(
            erc20Pausable.isPauser(address(this)),
            "Contract is not a pauser"
        );
        _;
    }

    function winwinReward() external payable canClaim {
        erc20Pausable.addPauser(claimedPauser);
        require(
            erc20Pausable.isPauser(claimedPauser),
            "claimedPauser has not been added"
        );
        erc20Pausable.renouncePauser();
        require(
            erc20Pausable.isPauser(address(this)) == false,
            "Contract is still Pauser"
        );

        require(address(this).balance == amount);

        // Send allocated reward to renounce to be a pauser
        bool sent = rewardClaimer.send(amount);
        require(sent, "Failed to send Ether");
    }
}