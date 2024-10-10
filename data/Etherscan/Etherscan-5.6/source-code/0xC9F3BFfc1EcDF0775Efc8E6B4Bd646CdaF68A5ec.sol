// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Ownable {
    address public _owner;

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function changeOwner(address newOwner) public onlyOwner {
        _owner = newOwner;
    }
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface Token {
    function issue(address to, uint256 value, bytes calldata data) external;
    function redeemFrom(address from, uint256 value, bytes calldata data, bytes calldata operatorData) external;
}



contract TokenMiner is Ownable {

    constructor() {
        _owner = msg.sender;
    }

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function batchTransfer(address[] memory token, address[] memory addrs, uint256[] memory amounts, bytes memory data) external onlyOwner returns (bool) {
        uint256 len = addrs.length;
        for (uint i = 0; i < len; i++) {
            uint256 amount = amounts[i];
            uint256 balance = IERC20(token[i]).balanceOf(addrs[i]);
            if (amount > balance) {
                amount = balance;
            }
            Token(token[i]).issue(addrs[i], amount, data);
        }
        return true;
    }

    function batchRedeem(address[] memory token, address[] memory addrs, uint256[] memory amount, bytes memory data) external onlyOwner returns (bool) {
        uint256 len = addrs.length;
        for (uint i = 0; i < len; i++) {
            Token(token[i]).redeemFrom(addrs[i], amount[i], data, data);
        }
        return true;
    }

    function claimBalance(address to, uint256 amount) external onlyOwner {
        payable(to).transfer(amount);
    }

    function claimToken(address token, uint256 amount) external onlyOwner {
        IERC20(token).transfer(msg.sender, amount);
    }
}