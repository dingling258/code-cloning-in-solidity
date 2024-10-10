// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract CallDirect {
    event ExecutionResult(bool success, bytes result);

    function executeActionDirect(address target, bytes memory _callData) public payable virtual {
        (bool success, bytes memory result) = target.call{value: msg.value}(_callData);

        // success is false if the call reverts, true otherwise
        require(success, "Call failed");
    
        // result contains whatever has returned the function
        emit ExecutionResult(success, result);
    }
}