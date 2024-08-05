// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ezETHOracle {
  /// @notice Retrieve RWA price data
  function getRate()
    external
    view
    returns (uint256 price);
}

/// @title An immutable contract used to read the ezETH/ETH Price
/// This contract functions as an interface for dAPI users enabling them to read
/// the price using the existing dAPI proxy interface.


contract Api3ezETHAdapter {
    
    address public immutable api3ServerV1;
    address public immutable ezETHContract;

    constructor(address _ezETHContract, address _api3ServerV1) {
        api3ServerV1 = _api3ServerV1;
        ezETHContract = _ezETHContract;
    }

    /// @notice Reads the dAPI that this proxy maps to
    /// @return value dAPI value
    /// @return timestamp dAPI timestamp
    function read()
        external
        view
        virtual
        returns (int224 value, uint32 timestamp)
    {
        (uint256 value_uint256) = ezETHOracle(ezETHContract)
            .getRate();
        value = int224(int256(value_uint256));
        timestamp = uint32(block.timestamp);
    }
}