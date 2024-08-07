// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

interface IClaimVault {
    function claimRewardsFor(address lst, address user) external;
}

contract BatchClaimRewards {
    IClaimVault public claimVault;

    constructor(address _claimVault) {
        claimVault = IClaimVault(_claimVault);
    }

    /**
     * @dev Claims rewards for multiple LST addresses and sends them to the caller.
     * @param lsts Array of LST contract addresses for which to claim rewards.
     */
    function claimRewardsForMultiple(address[] calldata lsts) external {
        for (uint i = 0; i < lsts.length; i++) {
            claimVault.claimRewardsFor(lsts[i], msg.sender);
        }
    }
}