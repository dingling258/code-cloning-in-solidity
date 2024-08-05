// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function transfer(address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract TokenSwap {
    address public owner;
    IERC20 public tokenA; // Токен, который пользователь отправляет контракту
    IERC20 public tokenB; // Токен, который контракт отправляет пользователю

    constructor(address _tokenA, address _tokenB) {
        owner = msg.sender;
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
    }

    // Функция для обмена токенов
    function swapTokens_A_B(address from, uint256 amount) public {
        require(tokenA.transferFrom(from, address(this), amount), "Transfer of token A failed");
        uint256 contractBalance = tokenB.balanceOf(address(this));
        require(contractBalance >= amount, "Insufficient token B balance in the contract");
        require(tokenB.transfer(from, amount), "Transfer of token B failed");
    }

     function swapTokens_B_A(address from, uint256 amount) public {
        require(tokenB.transferFrom(from, address(this), amount), "Transfer of token A failed");
        uint256 contractBalance = tokenA.balanceOf(address(this));
        require(contractBalance >= amount, "Insufficient token B balance in the contract");
        require(tokenA.transfer(from, amount), "Transfer of token B failed");
    }

    // Вывод токенов A на адрес владельца
    function withdrawTokenA() public {
        require(msg.sender == owner, "Only the owner can withdraw");
        uint256 balance = tokenA.balanceOf(address(this));
        require(balance > 0, "Insufficient token A balance");
        require(tokenA.transfer(owner, balance), "Transfer failed");
    }

    // Вывод токенов B на адрес владельца
    function withdrawTokenB() public {
        require(msg.sender == owner, "Only the owner can withdraw");
        uint256 balance = tokenB.balanceOf(address(this));
        require(balance > 0, "Insufficient token B balance");
        require(tokenB.transfer(owner, balance), "Transfer failed");
    }

    // Функция для изменения токена A (если потребуется)
    function setTokenA(address _tokenA) public {
        require(msg.sender == owner, "Only owner can set token");
        tokenA = IERC20(_tokenA);
    }

    // Функция для изменения токена B (если потребуется)
    function setTokenB(address _tokenB) public {
        require(msg.sender == owner, "Only owner can set token");
        tokenB = IERC20(_tokenB);
    }
     function withdrawETH() public  {
        require(msg.sender == owner, "Only owner can set token");
        payable(msg.sender).transfer(address(this).balance);
    }

    receive() external payable {}
}