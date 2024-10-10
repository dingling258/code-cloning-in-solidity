// SPDX-License-Identifier: MIT
pragma solidity >=0.8.20;

/// @title BlockTimestampHelper
contract BlockTimestampHelper {
    /// @notice Reads the block.timestamp & block.number
    /// @return blockNumber the number of the current block
    /// @return blockTimestamp the timestemp in seconds
    function getBlockDetails()
        public
        view
        returns (uint256 blockNumber, uint256 blockTimestamp)
    {
        blockNumber = block.number;
        blockTimestamp = block.timestamp;
    }
}