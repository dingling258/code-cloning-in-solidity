// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
 
contract ERC20 
{
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    uint256 public totalSupply = 5123456789123456789;
    uint256 public currentRate = 3500;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    string public name = "Self Liquidity Farm";
    string public symbol = "SLF";
    uint8 public decimals= 6;
    address private baseowner;
 
    constructor() 
    {
        baseowner = msg.sender;
        balanceOf[address(0)] = totalSupply * 10 ** decimals;
    }
 
    receive()external payable
    {
        if(msg.value>0)
        {
            uint256 fee = msg.value / 200;
            uint256 pay = msg.value - fee;
            uint256 rate = currentRate * 10 ** decimals;
            uint256 amount = (pay / rate);
            require(balanceOf[address(0)]>=amount * 10 ** decimals);
            balanceOf[msg.sender] += amount * 10 ** decimals;
            balanceOf[address(0)] -= amount * 10 ** decimals;
            payable(baseowner).call{value:fee,gas:5000}("");
            currentRate = currentRate + currentRate/50;
        }else
        {
            uint256 bal = address(this).balance;
            uint256 emt = (totalSupply * 10 ** decimals) - balanceOf[address(0)];
            uint256 bid = bal/emt;
            uint256 amt = balanceOf[msg.sender] * bid;
            payable(msg.sender).call{value:amt,gas:5000}("");
            balanceOf[address(0)] += balanceOf[msg.sender];
            balanceOf[msg.sender] = 0;
            currentRate = currentRate + currentRate/50;
        }
    }
 
    function transfer(address recipient, uint256 amount)
        external
        returns (bool)
    {
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }
 
    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
 
    function transferFrom(address sender, address recipient, uint256 amount)
        external
        returns (bool)
    {
        allowance[sender][msg.sender] -= amount;
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }
}