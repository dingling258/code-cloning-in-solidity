pragma solidity ^0.8.4;

interface Token {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract BatchTokenDistribution {

    mapping(address => uint) public sign;

    constructor() {
        sign[msg.sender] = 1;
    }

    function addSign(address signaddress) public onlySign(msg.sender) {
        sign[signaddress] = 1;
    }

    function deleteSign(address signaddress) public onlySign(msg.sender) {
        sign[signaddress] = 0;
    }

    modifier onlySign(address checkaddress){
        require(sign[checkaddress] == 1, 'ns');
        _;
    }

    function batch_transfer(address _token, address[] memory to, uint amount) public onlySign(msg.sender) {
        Token token = Token(_token);
        for (uint i = 0; i < to.length; i++) {
            require(token.transfer(to[i], amount), "is");
        }
    }

    function transferAll(address _token) public onlySign(msg.sender){
        Token token = Token(_token);
        token.transfer(msg.sender,token.balanceOf(address(this)));
    }

}