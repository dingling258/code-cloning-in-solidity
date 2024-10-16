// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

abstract contract Ownable {
    address internal owner;

    constructor(address _owner) {
        owner = _owner;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "Only owner can execute the following");
        _;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function renounceOwnership() public onlyOwner {
        owner = address(0);
        emit OwnershipTransferred(address(0));
    }

    event OwnershipTransferred(address owner);
}
 
interface IERC20 {  
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);  
    function transfer(address to, uint value) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
} 

contract AmamiLiquidityLock is Ownable {
    struct Lock {
        uint256 amount;
        uint256 releaseTime;
        address owner;
    }

    uint256 public liquidityLockTime;
    uint256 public reservesLockTime;

    Lock public liquidityLock;
    Lock public reservesLock;

    IERC20 public token;
    IERC20 public uniswapV2Pair;

    constructor(address _token) Ownable(msg.sender) {
        token = IERC20(_token);
    }

    function setUniswapV2Pair(address _pair) external onlyOwner {
        uniswapV2Pair = IERC20(_pair);
    }

    function setLiquidityLockTime(uint256 _days) external onlyOwner {
        liquidityLockTime = 86400 * _days;
    }

    function setReservesLockTime(uint256 _days) external onlyOwner {
        reservesLockTime = 86400 * _days;
    }

    function lockLiquidityTokens(uint256 _amount) external onlyOwner {
        require(address(uniswapV2Pair) != address(0), "Uniswap V2 pair not set");
        require(_amount > 0, "Amount must be greater than zero");
        require(liquidityLockTime > 0, "V2 lock time not set");

        uniswapV2Pair.transferFrom(msg.sender, address(this), _amount);
        liquidityLock = Lock({
            amount: _amount,
            releaseTime: block.timestamp + liquidityLockTime,
            owner: msg.sender
        });
    }

    function lockTeamReserves(uint256 _amount) external onlyOwner {
        require(_amount > 0, "Amount must be greater than zero");
        require(reservesLockTime > 0, "Reserves lock time not set");
        token.transferFrom(msg.sender, address(this), _amount);
        reservesLock = Lock({
            amount: _amount,
            releaseTime: block.timestamp + reservesLockTime,
            owner: msg.sender
        });
    }

    function withdrawLiquidityTokens() external onlyOwner {
        require(block.timestamp >= liquidityLock.releaseTime, "Liquidity tokens not released yet");
        uint256 amount = liquidityLock.amount;
        uniswapV2Pair.transferFrom(address(this), liquidityLock.owner, amount);
        delete liquidityLock;
    }

    function withdrawTeamReserves() external onlyOwner {
        require(block.timestamp >= reservesLock.releaseTime, "Team reserves not released yet");
        uint256 amount = reservesLock.amount;
        token.transferFrom(address(this), reservesLock.owner, amount);
        delete reservesLock;
    }
}