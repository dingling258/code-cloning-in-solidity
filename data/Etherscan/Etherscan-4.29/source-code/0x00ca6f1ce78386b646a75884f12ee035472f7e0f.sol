pragma solidity 0.5.17;

contract MNTHBN {

    function hellowolrd() external pure returns(string memory) {
        return "hellowolrd";
    }

    function release() external {
        selfdestruct( (msg.sender));
    } 
    
}