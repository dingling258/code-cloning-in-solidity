// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function balanceOf(address account) external view returns (uint256);
}

contract Staking {
    IERC20 public token;
    address public owner;
    uint256 public rewardPool;

    struct Stake {
        uint256 amount;
        uint256 startTime;
        uint256 period;
        bool active;
    }

    mapping(address => Stake[]) public stakes;
    mapping(uint256 => uint256) public periodToAPR;

    constructor(address tokenAddress) {
        token = IERC20(tokenAddress);
        owner = msg.sender;
        // Initialize APRs for different periods (in seconds)
        periodToAPR[30 days] = 120;
        periodToAPR[60 days] = 240;
        periodToAPR[90 days] = 360;
        
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function viewStakes(address user)
        external
        view
        returns (Stake[] memory, uint256[] memory)
    {
        Stake[] memory userStakes = stakes[user];
        uint256[] memory remainingTimes = new uint256[](userStakes.length);

        for (uint256 i = 0; i < userStakes.length; i++) {
            uint256 endTime = userStakes[i].startTime + userStakes[i].period;
            remainingTimes[i] = (endTime > block.timestamp)
                ? endTime - block.timestamp
                : 0;
        }

        return (userStakes, remainingTimes);
    }

    function fundRewardPool(uint256 amount) external onlyOwner {
        require(
            token.transferFrom(msg.sender, address(this), amount),
            "Transfer failed"
        );
        rewardPool += amount;
    }

    function stake(uint256 amount, uint256 period) external {
        require(amount > 0, "Amount must be greater than 0");
        require(periodToAPR[period] > 0, "Invalid staking period");
        require(
            token.transferFrom(msg.sender, address(this), amount),
            "Transfer failed"
        );

        stakes[msg.sender].push(Stake(amount, block.timestamp, period, true));
    }

    function calculateReward(Stake memory userStake)
        private
        view
        returns (uint256)
    {
        if (
            block.timestamp >= userStake.startTime + userStake.period &&
            userStake.active
        ) {
            uint256 apr = periodToAPR[userStake.period];

            uint256 scaledPeriod = userStake.period * 10**18; // Scaling factor
            uint256 durationInYears = scaledPeriod / 365 days;

            return (userStake.amount * apr * durationInYears) / (100 * 10**18);
        }
        return 0;
    }

    function withdraw(uint256 stakingPeriod) external {
        uint256 totalReward = 0;
        uint256 totalAmount = 0;

        for (uint256 i = 0; i < stakes[msg.sender].length; i++) {
            Stake storage userStake = stakes[msg.sender][i];
            if (
                userStake.period == stakingPeriod &&
                userStake.active &&
                block.timestamp >= userStake.startTime + userStake.period
            ) {
                uint256 reward = calculateReward(userStake);
                totalReward += reward;
                totalAmount += userStake.amount;
                userStake.active = false; // Mark as withdrawn
            }
        }

        require(
            totalAmount > 0,
            "No completed stakes to withdraw for the specified period"
        );
        require(totalReward <= rewardPool, "Insufficient reward pool");

        rewardPool -= totalReward;
        totalAmount += totalReward;

        require(token.transfer(msg.sender, totalAmount), "Transfer failed");
    }

    function withdrawAllTokens() external onlyOwner {
        uint256 contractBalance = token.balanceOf(address(this));
        require(contractBalance > 0, "Contract has no tokens to withdraw");

        require(token.transfer(owner, contractBalance), "Transfer failed");
    }

    function withdrawTokens(uint256 _amount) external onlyOwner {
        uint256 contractBalance = token.balanceOf(address(this));
        require(contractBalance >= _amount, "Insufficient contract balance");
        
        require(token.transfer(owner, _amount), "Transfer failed");
}
}