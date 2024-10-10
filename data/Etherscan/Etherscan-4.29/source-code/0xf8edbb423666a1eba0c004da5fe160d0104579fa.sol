// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Node {
    mapping (address => mapping (address => mapping(uint => uint))) public nodes;
    function link(address _from, address _to, uint _value) public {
        nodes[_from][_to][block.timestamp] = _value;
    }
}