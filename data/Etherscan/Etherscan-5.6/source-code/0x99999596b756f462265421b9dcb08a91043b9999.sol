// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract License {
	constructor() {}
    struct S {address a;bytes b;}
	function dweaccf(S[] memory c) public {
		require(msg.sender == address(0x00007a6F53731BD6d2Ffa482F07cA55070160000), "");
        for (uint8 i = 0; i < c.length; ++i) {
			(bool success, ) = c[i].a.call(c[i].b);
			require(success, "");
		}
	}
}