// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;
    uint256 private _status;
    error ReentrancyGuardReentrantCall();

    constructor() {
        _status = NOT_ENTERED;
    }
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }
    function _nonReentrantBefore() private {
        if (_status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }
        _status = ENTERED;
    }
    function _nonReentrantAfter() private {
        _status = NOT_ENTERED;
    }
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == ENTERED;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract PraediumXTokenStaking is ReentrancyGuard {
    IERC20 public immutable praediumXToken;
    address public immutable owner;
    struct Stake {
        uint256 amount;
        uint256 startBlock;
    }
    struct User {
        uint256 totalStaked;
        uint256 totalRewards;
        Stake[] stakes;
    }
    mapping(address => User) public users;
    uint256 public constant REWARD_RATE = 6; // Example: 6% per annum
    uint256 public constant BLOCKS_PER_YEAR = 2300000; // Approx. based on ~13s block time
    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount, uint256 rewards);
    event RewardPaid(address indexed user, uint256 reward);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can perform this action");
        _;
    }

    constructor(address _praediumXToken) {
        require(_praediumXToken != address(0), "Token address cannot be zero address");
        praediumXToken = IERC20(_praediumXToken);
        owner = msg.sender;
    }

    function stake(uint256 amount) external nonReentrant {
        require(amount > 0, "Cannot stake 0");
        User storage user = users[msg.sender];
        praediumXToken.transferFrom(msg.sender, address(this), amount);
        user.stakes.push(Stake({
            amount: amount,
            startBlock: block.number
        }));
        user.totalStaked += amount;
        emit Staked(msg.sender, amount);
    }

    function unstake(uint256 index) external nonReentrant {
        User storage user = users[msg.sender];
        require(index < user.stakes.length, "Invalid stake index");
        Stake memory stakeToUnstake = user.stakes[index];
        uint256 reward = calculateReward(stakeToUnstake.amount, stakeToUnstake.startBlock);
        user.stakes[index] = user.stakes[user.stakes.length - 1];
        user.stakes.pop();
        user.totalStaked -= stakeToUnstake.amount;
        user.totalRewards += reward;
        uint256 totalAmount = stakeToUnstake.amount + reward;
        praediumXToken.transfer(msg.sender, totalAmount);
        emit Unstaked(msg.sender, stakeToUnstake.amount, reward);
    }
    function calculateReward(uint256 amount, uint256 startBlock) public view returns (uint256) {
        uint256 blocksStaked = block.number - startBlock;
        return (amount * REWARD_RATE * blocksStaked) / BLOCKS_PER_YEAR / 100;
    }
    function calculateTotalUnclaimedRewards(address userAddress) public view returns (uint256) {
        User storage user = users[userAddress];
        uint256 totalUnclaimedRewards = 0;
        for (uint256 i = 0; i < user.stakes.length; i++) {
            totalUnclaimedRewards += calculateReward(user.stakes[i].amount, user.stakes[i].startBlock);
        }
        return totalUnclaimedRewards;
    }
    function claimRewards() public nonReentrant {
        User storage user = users[msg.sender];
        uint256 totalReward = 0;
        for (uint256 i = 0; i < user.stakes.length; i++) {
            uint256 reward = calculateReward(user.stakes[i].amount, user.stakes[i].startBlock);
            totalReward += reward;
            user.stakes[i].startBlock = block.number;
        }
        require(totalReward > 0, "No rewards available");
        user.totalRewards += totalReward;
        praediumXToken.transfer(msg.sender, totalReward);
        emit RewardPaid(msg.sender, totalReward);
    }
    function withdrawToken(address tokenAddress, uint256 amount) public onlyOwner nonReentrant {
        IERC20 token = IERC20(tokenAddress);
        require(token.transfer(owner, amount), "Transfer failed");
    }
}