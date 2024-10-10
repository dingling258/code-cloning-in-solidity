// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.25;

contract A {
    function storeBlobHash(uint256 index) external {
        assembly {
            sstore(0, blobhash(index))
        }
    }
}