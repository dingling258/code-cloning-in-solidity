{"Context.sol":{"content":"// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)\n\npragma solidity ^0.8.20;\n\n/**\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes calldata) {\n        return msg.data;\n    }\n\n    function _contextSuffixLength() internal view virtual returns (uint256) {\n        return 0;\n    }\n}\n"},"DropsTier01.sol":{"content":"//SPDX-Lisence-Identifier: MIT\n\n/*⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀.⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀\n⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣾⣷⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀\n⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣼⣿⣿⣧⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀\n⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣾⣿⣿⣿⣿⣷⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀\n⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣾⣿⣿⣿⣿⣿⣿⣷⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀\n⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣾⣿⣿⣿⣿⣿⣿⣿⣿⣷⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀\n⠀⠀⠀⠀⠀⠀⠀⠀⢠⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⡄⠀⠀⠀⠀⠀⠀⠀⠀\n⠀⠀⠀⠀⠀⠀⠀⢠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡄⠀⠀⠀⠀⠀⠀⠀\n⠀⠀⠀⠀⠀⠀⢠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡄⠀⠀⠀⠀⠀⠀\n⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀\n⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀\n⠀⠀⠀⠀⠀⠀⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⠀⠀⠀⠀⠀⠀\n⠀⠀⠀⠀⠀⠀⠈⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⠁⠀⠀⠀⠀\n⠀⠀⠀⠀⠀⠀⠀⠀⠙⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⠋⠀⠀⠀⠀⠀⠀⠀⠀\n⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠙⠛⠛⠛⠛⠋⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀ \n\nDrops Lock Marketplace is the first locked liquidity marketplace.\nThis is the Drops Tier 01 Earning Center smart contract.\n\nhttps://drops.site\nhttps://t.me/dropserc\nhttps://x.com/dropserc\n\n$DROPS token address -\u003e 0xA562912e1328eEA987E04c2650EfB5703757850C\n\n*/\n\nimport \"./Ownable.sol\";\nimport \"./IERC20.sol\";\nimport \"./ReentrancyGuard.sol\";\nimport \"./IUniswapV2Router02.sol\";\n\npragma solidity 0.8.20;\n\ncontract DropsTier01 is Ownable, ReentrancyGuard {\n    \n    IUniswapV2Router02 public hashSwapRouter;\n    address public hashSwapPair;\n    // The address of the smart chef factory\n    address public SMART_CHEF_FACTORY;\n\n    // Fee wallet\n    address public feeAddress = 0xcdB94D75b5522B0440f638a17bE7f8d70a7745f6; //Change Fee Address\n\n    // Whether a limit is set for users\n    bool public hasUserLimit;\n\n    // Whether contract is initialized\n    bool public isInitialized;\n\n    // Accrued token per share\n    uint256 public accTokenPerShare;\n  \n    uint256 public bonusEndBlock;\n    \n    uint256 public startBlock;\n\n    // The block number of the last pool update\n    uint256 public lastRewardBlock;\n\n    // The pool limit (0 if none)\n    uint256 public poolLimitPerUser;\n    \n    uint256 public rewardPerBlock;\n\n    // Deposit Fee.\n    uint256 public depositFeeBP;\n\n    // Withdraw Fee.\n    uint256 public withdrawFeeBP;\n\n    uint256 public contractLockPeriod; // 6-month in seconds\n\n\n    // The precision factor\n    uint256 public PRECISION_FACTOR;\n\n    // The reward token\n    IERC20 public rewardToken;\n\n    // The staked token\n    IERC20 public stakedToken;\n    // The total staked amount\n    uint256 public totalstakedAmount = 0;\n   \n    uint256 public withdrawalFeeInterval;\n    uint256 public withdrawalFeeDeadline; \n\n    mapping(address =\u003e UserInfo) public userInfo;\n\n    struct UserInfo {\n        uint256 amount; // How many staked tokens the user has provided\n        uint256 rewardDebt; // Reward debt\n        uint256 noWithdrawalFeeAfter;\n        uint256 depositTime;\n        uint256 rewardLockedUp;  // Reward locked up.\n    }\n\n    event AdminTokenRecovery(address tokenRecovered, uint256 amount);\n    event Deposit(address indexed user, uint256 amount);\n    event EmergencyWithdraw(address indexed user, uint256 amount);\n    event NewStartAndEndBlocks(uint256 startBlock, uint256 endBlock);\n    event NewRewardPerBlock(uint256 rewardPerBlock);\n    event NewPoolLimit(uint256 poolLimitPerUser);\n    event RewardsStop(uint256 blockNumber);\n    event Withdraw(address indexed user, uint256 amount);\n    event NewFees(uint256 newDepositFeeBP, uint256 newWithdrawFeeBP);\n    event UpdatedFeeAddress(address oldfeeaddress, address newfeeaddress);\n\n    constructor() public Ownable(msg.sender) {\n        SMART_CHEF_FACTORY = msg.sender;\n    } \n    \n    receive() external payable {}\n\n    /// @notice Initialize the contract\n    /// @param _stakedToken Staked token address\n    /// @param _rewardToken Reward token address\n    /// @param _rewardPerBlock Reward per block (in rewardToken)\n    /// @param _startBlock Start block\n    /// @param _bonusEndBlock End block\n    /// @param _poolLimitPerUser Pool limit per user in stakedToken (if any, else 0)\n    function initialize(\n        IERC20 _stakedToken,\n        IERC20 _rewardToken,\n        uint256 _rewardPerBlock,\n        uint256 _startBlock,\n        uint256 _bonusEndBlock,\n        uint256 _poolLimitPerUser,\n        uint256 _depositFeeBP,\n        uint256 _withdrawFeeBP,\n        uint256 _withdrawalFeeInterval,\n        uint256 _withdrawalFeeDeadline,\n        uint256 _contractLockPeriod\n    ) external {\n        require(!isInitialized, \"Already initialized\");\n        require(msg.sender == SMART_CHEF_FACTORY, \"Not factory\");\n        require(_depositFeeBP \u003c= 10000, \"Cannot be bigger than 100\");\n        require(_withdrawFeeBP \u003c= 10000, \"Cannot be bigger than 100\");\n        \n        isInitialized = true;\n\n        stakedToken = _stakedToken;\n        rewardToken = _rewardToken;\n        rewardPerBlock = _rewardPerBlock;\n        startBlock = _startBlock;\n        bonusEndBlock = _bonusEndBlock;\n        depositFeeBP = _depositFeeBP;\n        withdrawFeeBP = _withdrawFeeBP;\n        withdrawalFeeInterval = _withdrawalFeeInterval;\n        withdrawalFeeDeadline = _withdrawalFeeDeadline;\n        contractLockPeriod = _contractLockPeriod;\n        if (_poolLimitPerUser \u003e 0) {\n            hasUserLimit = true;\n            poolLimitPerUser = _poolLimitPerUser;\n        }\n\n        uint256 decimalsRewardToken = 10**18;\n        require(decimalsRewardToken \u003c 30, \"Must be inferior to 30\");\n\n        PRECISION_FACTOR = 10**(30-decimalsRewardToken);\n\n        // Set the lastRewardBlock as the startBlock\n        lastRewardBlock = startBlock;\n\n    }\n\n    function remainLockTime(address _user) \n        public\n        view\n        returns (uint256)\n    {\n        UserInfo storage user = userInfo[_user];\n        uint256 timeElapsed = block.timestamp - (user.depositTime);\n        uint256 remainingLockTime = 0;\n        if (user.depositTime == 0) {\n            remainingLockTime = 0;\n        } else if(timeElapsed \u003c contractLockPeriod) {\n            remainingLockTime = (contractLockPeriod - (timeElapsed)) \u003e bonusEndBlock ? bonusEndBlock : (contractLockPeriod - (timeElapsed));\n        }\n\n        return remainingLockTime;\n    }\n\n    /// @notice Deposit staked tokens and collect reward tokens (if any)\n    /// @param _amount Amount to withdraw (in rewardToken)\n    function deposit(uint256 _amount) external nonReentrant {\n        UserInfo storage user = userInfo[msg.sender];\n        uint256 remainLock = remainLockTime(msg.sender);\n        uint256 depositAmount = _amount;\n        if (hasUserLimit) {\n            require(_amount + user.amount \u003c= poolLimitPerUser, \"User amount above limit\");\n        }\n\n        _updatePool();\n        if (user.amount \u003e 0) {\n            uint256 pending = (user.amount * accTokenPerShare) / PRECISION_FACTOR - user.rewardDebt;\n             if (pending \u003e 0 || user.rewardLockedUp \u003e 0) {\n                  if (remainLock \u003c= 0) {\n                      pending = pending + user.rewardLockedUp;\n                      rewardToken.transfer(address(msg.sender), pending);\n                      user.rewardLockedUp = 0;\n            } else if (pending \u003e 0) {\n                    user.rewardLockedUp = user.rewardLockedUp + pending;\n                }\n        } }\n\n        if (_amount \u003e 0) {\n            require(stakedToken.balanceOf(address(msg.sender)) \u003e= _amount);\n            uint256 beforeStakedTokenTotalBalance = stakedToken.balanceOf(address(this));\n            if(depositFeeBP \u003e 0) {\n                uint256 depositFee = _amount * depositFeeBP /10000;\n                stakedToken.transferFrom(address(msg.sender), address(this), _amount - depositFee);\n                stakedToken.transferFrom(address(msg.sender), feeAddress, depositFee);\n            } else {\n                stakedToken.transferFrom(address(msg.sender), address(this), _amount);\n            }\n            uint256 depositedAmount = stakedToken.balanceOf(address(this)) - beforeStakedTokenTotalBalance;\n            user.amount = user.amount + depositedAmount;\n            depositAmount = depositedAmount;\n            totalstakedAmount = totalstakedAmount + depositedAmount;\n            uint256 shouldNotWithdrawBefore = block.timestamp + withdrawalFeeInterval;\n            if (shouldNotWithdrawBefore \u003e withdrawalFeeDeadline) {\n                shouldNotWithdrawBefore = withdrawalFeeDeadline;\n            }\n            user.noWithdrawalFeeAfter = shouldNotWithdrawBefore;\n            user.depositTime = block.timestamp;\n        }\n\n        user.rewardDebt = user.amount * accTokenPerShare / PRECISION_FACTOR;\n        emit Deposit(msg.sender, depositAmount);\n    }\n\n    /// @notice Withdraw staked tokens and collect reward tokens\n    /// @param _amount Amount to withdraw (in rewardToken)\n    function withdraw(uint256 _amount) external nonReentrant {\n        UserInfo storage user = userInfo[msg.sender];\n        uint256 remainLock = remainLockTime(msg.sender);\n        require(user.amount \u003e= _amount, \"Amount to withdraw too high\");\n        require(remainLock \u003c= 0, \"withdraw: locktime remains!\");\n        _updatePool();\n\n        uint256 pending = user.amount * accTokenPerShare / PRECISION_FACTOR - user.rewardDebt + user.rewardLockedUp;\n\n        if (_amount \u003e 0) {\n            uint256 beforestakedtokentotalsupply = stakedToken.balanceOf(address(this));\n            if(withdrawFeeBP \u003e 0) {\n                uint256 withdrawFee = _amount * withdrawFeeBP / 10000;\n                stakedToken.transfer(address(msg.sender), _amount - withdrawFee);\n                stakedToken.transfer(feeAddress, withdrawFee);\n            } else {\n                stakedToken.transfer(address(msg.sender), _amount);\n            }\n            uint256 withdrawamount = beforestakedtokentotalsupply - stakedToken.balanceOf(address(this));\n            totalstakedAmount = totalstakedAmount - withdrawamount;\n            user.amount = user.amount - withdrawamount;\n            user.noWithdrawalFeeAfter = block.timestamp + withdrawalFeeInterval;\n        }\n\n        if (pending \u003e 0) {\n            rewardToken.transfer(address(msg.sender), pending);\n        }\n\n        user.rewardDebt = user.amount * accTokenPerShare / PRECISION_FACTOR;\n        user.rewardLockedUp = 0;\n        emit Withdraw(msg.sender, _amount);\n    }\n\n    /// @notice Withdraw staked tokens without caring about rewards rewards\n    /// @dev Needs to be for emergency.\n    function emergencyWithdraw() external nonReentrant {\n        UserInfo storage user = userInfo[msg.sender];\n        uint256 amountToTransfer = user.amount;\n        user.amount = 0;\n        user.rewardDebt = 0;\n        user.rewardLockedUp = 0;\n\n        if (amountToTransfer \u003e 0) {\n            totalstakedAmount = totalstakedAmount - amountToTransfer;\n            stakedToken.transfer(address(msg.sender), amountToTransfer);\n        }\n\n        emit EmergencyWithdraw(msg.sender, user.amount);\n    }\n\n    /// @notice Stop rewards\n    /// @dev Only callable by owner. Needs to be for emergency.\n    function emergencyRewardWithdraw(uint256 _amount) external onlyOwner {\n        rewardToken.transfer(address(msg.sender), _amount);\n    }\n  \n    function recoverWrongTokens(address _tokenAddress, uint256 _tokenAmount) external onlyOwner {\n        IERC20(_tokenAddress).transfer(address(msg.sender), _tokenAmount);\n        emit AdminTokenRecovery(_tokenAddress, _tokenAmount);\n    }\n\n    function clearStuckBalance(uint256 amountPercentage, address _walletAddress) external onlyOwner {\n        require(_walletAddress != address(this));\n        uint256 amountETH = address(this).balance;\n        payable(_walletAddress).transfer(amountETH * amountPercentage / 100);\n    }\n    \n    /// @notice Stop rewards\n    /// @dev Only callable by owner\n    function stopReward() external onlyOwner {\n        bonusEndBlock = block.number;\n    }\n\n    /// @notice Update pool limit per user\n    /// @dev Only callable by owner.\n    /// @param _hasUserLimit Whether the limit remains forced\n    /// @param _poolLimitPerUser New pool limit per user\n    function updatePoolLimitPerUser(bool _hasUserLimit, uint256 _poolLimitPerUser) external onlyOwner {\n        require(hasUserLimit, \"Must be set\");\n        if (_hasUserLimit) {\n            require(_poolLimitPerUser \u003e poolLimitPerUser, \"New limit must be higher\");\n            poolLimitPerUser = _poolLimitPerUser;\n        } else {\n            hasUserLimit = _hasUserLimit;\n            poolLimitPerUser = 0;\n        }\n        emit NewPoolLimit(poolLimitPerUser);\n    }\n\n    /// @notice Update reward per block\n    /// @dev Only callable by owner.\n    /// @param _rewardPerBlock The reward per block\n    function updateRewardPerBlock(uint256 _rewardPerBlock) external onlyOwner {\n        rewardPerBlock = _rewardPerBlock;\n        emit NewRewardPerBlock(_rewardPerBlock);\n    }\n\n    function updateFees(uint256 _newDepositFeeBP, uint256 _newWithdrawFeeBP) external onlyOwner {        \n        require(_newDepositFeeBP \u003c= 10000, \"Cannot be bigger than 100\");\n        require(_newWithdrawFeeBP \u003c= 10000, \"Cannot be bigger than 100\");\n        depositFeeBP = _newDepositFeeBP;\n        withdrawFeeBP = _newWithdrawFeeBP;\n        emit NewFees(depositFeeBP, withdrawFeeBP);\n    }\n\n    function updateFeeAddress(address newFeeAddress) external {\n        require(msg.sender == feeAddress, \"Set: You do not have right permission\");\n        emit UpdatedFeeAddress(feeAddress, newFeeAddress);\n        feeAddress = newFeeAddress;\n    }\n\n    /// @notice It allows the admin to update start and end blocks\n    /// @dev This function is only callable by owner.\n    /// @param _startBlock The new start block\n    /// @param _bonusEndBlock The new end block\n    function updateStartAndEndBlocks(\n        uint256 _startBlock,\n        uint256 _bonusEndBlock,\n        uint256 _withdrawalFeeInterval,\n        uint256 _withdrawalFeeDeadline,\n        uint256 _contractLockPeriod\n        ) external onlyOwner {\n        require(_startBlock \u003c _bonusEndBlock, \"New startBlock must be lower than new endBlock\");\n        require(block.number \u003c _startBlock, \"New startBlock must be higher than current block\");\n\n        startBlock = _startBlock;\n        bonusEndBlock = _bonusEndBlock;\n        withdrawalFeeInterval = _withdrawalFeeInterval;\n        withdrawalFeeDeadline = _withdrawalFeeDeadline;\n        contractLockPeriod = _contractLockPeriod;\n\n        // Set the lastRewardBlock as the startBlock\n        lastRewardBlock = startBlock;\n\n        emit NewStartAndEndBlocks(_startBlock, _bonusEndBlock);\n    }\n\n    /// @notice View function to see pending reward on frontend.\n    /// @param _user User address\n    /// @return uint256 Reward for a given user\n    function pendingReward(address _user) external view returns (uint256) {\n        UserInfo storage user = userInfo[_user];\n        if (block.number \u003e lastRewardBlock \u0026\u0026 totalstakedAmount != 0) {\n            uint256 multiplier = _getMultiplier(lastRewardBlock, block.number);\n            uint256 vivReward = multiplier * rewardPerBlock;\n            uint256 adjustedTokenPerShare =\n                accTokenPerShare + (vivReward * PRECISION_FACTOR / totalstakedAmount);\n            return user.amount * adjustedTokenPerShare / PRECISION_FACTOR - user.rewardDebt;\n        } else {\n            return user.amount * accTokenPerShare / PRECISION_FACTOR - user.rewardDebt;\n        }\n    }\n\n    /// @notice Update reward variables of the given pool to be up-to-date.\n    function _updatePool() internal {\n        if (block.number \u003c= lastRewardBlock) {\n            return;\n        }\n\n        if (totalstakedAmount == 0) {\n            lastRewardBlock = block.number;\n            return;\n        }\n\n        uint256 multiplier = _getMultiplier(lastRewardBlock, block.number);\n        uint256 vivReward = multiplier * rewardPerBlock;\n        accTokenPerShare = accTokenPerShare + (vivReward * PRECISION_FACTOR / totalstakedAmount);\n        lastRewardBlock = block.number;\n    }\n\n    /// @notice Return reward multiplier over the given _from to _to block.\n    /// @param _from Block to start\n    /// @param _to Block to finish\n    function _getMultiplier(uint256 _from, uint256 _to) internal view returns (uint256) {\n        if (_to \u003c= bonusEndBlock) {\n            return _to - _from;\n        } else if (_from \u003e= bonusEndBlock) {\n            return 0;\n        } else {\n            return bonusEndBlock - _from;\n        }\n    }\n\n    function rewardDuration() public view returns (uint256) {\n        return bonusEndBlock - startBlock;\n    }\n\n    function calcRewardPerBlock() public onlyOwner {\n        require(block.number \u003c startBlock, \"Pool has started\");\n        uint256 rewardBal = rewardToken.balanceOf(address(this));\n        rewardPerBlock = rewardBal / rewardDuration();\n    }\n}"},"IERC20.sol":{"content":"// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)\n\npragma solidity ^0.8.20;\n\n/**\n * @dev Interface of the ERC-20 standard as defined in the ERC.\n */\ninterface IERC20 {\n    /**\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\n     * another (`to`).\n     *\n     * Note that `value` may be zero.\n     */\n    event Transfer(address indexed from, address indexed to, uint256 value);\n\n    /**\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\n     * a call to {approve}. `value` is the new allowance.\n     */\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n\n    /**\n     * @dev Returns the value of tokens in existence.\n     */\n    function totalSupply() external view returns (uint256);\n\n    /**\n     * @dev Returns the value of tokens owned by `account`.\n     */\n    function balanceOf(address account) external view returns (uint256);\n\n    /**\n     * @dev Moves a `value` amount of tokens from the caller\u0027s account to `to`.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transfer(address to, uint256 value) external returns (bool);\n\n    /**\n     * @dev Returns the remaining number of tokens that `spender` will be\n     * allowed to spend on behalf of `owner` through {transferFrom}. This is\n     * zero by default.\n     *\n     * This value changes when {approve} or {transferFrom} are called.\n     */\n    function allowance(address owner, address spender) external view returns (uint256);\n\n    /**\n     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the\n     * caller\u0027s tokens.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\n     * that someone may use both the old and the new allowance by unfortunate\n     * transaction ordering. One possible solution to mitigate this race\n     * condition is to first reduce the spender\u0027s allowance to 0 and set the\n     * desired value afterwards:\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\n     *\n     * Emits an {Approval} event.\n     */\n    function approve(address spender, uint256 value) external returns (bool);\n\n    /**\n     * @dev Moves a `value` amount of tokens from `from` to `to` using the\n     * allowance mechanism. `value` is then deducted from the caller\u0027s\n     * allowance.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transferFrom(address from, address to, uint256 value) external returns (bool);\n}\n"},"IUniswapV2Router01.sol":{"content":"pragma solidity \u003e=0.6.2;\n\ninterface IUniswapV2Router01 {\n    function factory() external pure returns (address);\n    function WETH() external pure returns (address);\n\n    function addLiquidity(\n        address tokenA,\n        address tokenB,\n        uint amountADesired,\n        uint amountBDesired,\n        uint amountAMin,\n        uint amountBMin,\n        address to,\n        uint deadline\n    ) external returns (uint amountA, uint amountB, uint liquidity);\n    function addLiquidityETH(\n        address token,\n        uint amountTokenDesired,\n        uint amountTokenMin,\n        uint amountETHMin,\n        address to,\n        uint deadline\n    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);\n    function removeLiquidity(\n        address tokenA,\n        address tokenB,\n        uint liquidity,\n        uint amountAMin,\n        uint amountBMin,\n        address to,\n        uint deadline\n    ) external returns (uint amountA, uint amountB);\n    function removeLiquidityETH(\n        address token,\n        uint liquidity,\n        uint amountTokenMin,\n        uint amountETHMin,\n        address to,\n        uint deadline\n    ) external returns (uint amountToken, uint amountETH);\n    function removeLiquidityWithPermit(\n        address tokenA,\n        address tokenB,\n        uint liquidity,\n        uint amountAMin,\n        uint amountBMin,\n        address to,\n        uint deadline,\n        bool approveMax, uint8 v, bytes32 r, bytes32 s\n    ) external returns (uint amountA, uint amountB);\n    function removeLiquidityETHWithPermit(\n        address token,\n        uint liquidity,\n        uint amountTokenMin,\n        uint amountETHMin,\n        address to,\n        uint deadline,\n        bool approveMax, uint8 v, bytes32 r, bytes32 s\n    ) external returns (uint amountToken, uint amountETH);\n    function swapExactTokensForTokens(\n        uint amountIn,\n        uint amountOutMin,\n        address[] calldata path,\n        address to,\n        uint deadline\n    ) external returns (uint[] memory amounts);\n    function swapTokensForExactTokens(\n        uint amountOut,\n        uint amountInMax,\n        address[] calldata path,\n        address to,\n        uint deadline\n    ) external returns (uint[] memory amounts);\n    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)\n        external\n        payable\n        returns (uint[] memory amounts);\n    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)\n        external\n        returns (uint[] memory amounts);\n    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)\n        external\n        returns (uint[] memory amounts);\n    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)\n        external\n        payable\n        returns (uint[] memory amounts);\n\n    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);\n    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);\n    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);\n    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);\n    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);\n}\n"},"IUniswapV2Router02.sol":{"content":"pragma solidity \u003e=0.6.2;\n\nimport \u0027./IUniswapV2Router01.sol\u0027;\n\ninterface IUniswapV2Router02 is IUniswapV2Router01 {\n    function removeLiquidityETHSupportingFeeOnTransferTokens(\n        address token,\n        uint liquidity,\n        uint amountTokenMin,\n        uint amountETHMin,\n        address to,\n        uint deadline\n    ) external returns (uint amountETH);\n    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(\n        address token,\n        uint liquidity,\n        uint amountTokenMin,\n        uint amountETHMin,\n        address to,\n        uint deadline,\n        bool approveMax, uint8 v, bytes32 r, bytes32 s\n    ) external returns (uint amountETH);\n\n    function swapExactTokensForTokensSupportingFeeOnTransferTokens(\n        uint amountIn,\n        uint amountOutMin,\n        address[] calldata path,\n        address to,\n        uint deadline\n    ) external;\n    function swapExactETHForTokensSupportingFeeOnTransferTokens(\n        uint amountOutMin,\n        address[] calldata path,\n        address to,\n        uint deadline\n    ) external payable;\n    function swapExactTokensForETHSupportingFeeOnTransferTokens(\n        uint amountIn,\n        uint amountOutMin,\n        address[] calldata path,\n        address to,\n        uint deadline\n    ) external;\n}\n"},"Ownable.sol":{"content":"// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)\n\npragma solidity ^0.8.20;\n\nimport {Context} from \"./Context.sol\";\n\n/**\n * @dev Contract module which provides a basic access control mechanism, where\n * there is an account (an owner) that can be granted exclusive access to\n * specific functions.\n *\n * The initial owner is set to the address provided by the deployer. This can\n * later be changed with {transferOwnership}.\n *\n * This module is used through inheritance. It will make available the modifier\n * `onlyOwner`, which can be applied to your functions to restrict their use to\n * the owner.\n */\nabstract contract Ownable is Context {\n    address private _owner;\n\n    /**\n     * @dev The caller account is not authorized to perform an operation.\n     */\n    error OwnableUnauthorizedAccount(address account);\n\n    /**\n     * @dev The owner is not a valid owner account. (eg. `address(0)`)\n     */\n    error OwnableInvalidOwner(address owner);\n\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    /**\n     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.\n     */\n    constructor(address initialOwner) {\n        if (initialOwner == address(0)) {\n            revert OwnableInvalidOwner(address(0));\n        }\n        _transferOwnership(initialOwner);\n    }\n\n    /**\n     * @dev Throws if called by any account other than the owner.\n     */\n    modifier onlyOwner() {\n        _checkOwner();\n        _;\n    }\n\n    /**\n     * @dev Returns the address of the current owner.\n     */\n    function owner() public view virtual returns (address) {\n        return _owner;\n    }\n\n    /**\n     * @dev Throws if the sender is not the owner.\n     */\n    function _checkOwner() internal view virtual {\n        if (owner() != _msgSender()) {\n            revert OwnableUnauthorizedAccount(_msgSender());\n        }\n    }\n\n    /**\n     * @dev Leaves the contract without owner. It will not be possible to call\n     * `onlyOwner` functions. Can only be called by the current owner.\n     *\n     * NOTE: Renouncing ownership will leave the contract without an owner,\n     * thereby disabling any functionality that is only available to the owner.\n     */\n    function renounceOwnership() public virtual onlyOwner {\n        _transferOwnership(address(0));\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Can only be called by the current owner.\n     */\n    function transferOwnership(address newOwner) public virtual onlyOwner {\n        if (newOwner == address(0)) {\n            revert OwnableInvalidOwner(address(0));\n        }\n        _transferOwnership(newOwner);\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Internal function without access restriction.\n     */\n    function _transferOwnership(address newOwner) internal virtual {\n        address oldOwner = _owner;\n        _owner = newOwner;\n        emit OwnershipTransferred(oldOwner, newOwner);\n    }\n}\n"},"ReentrancyGuard.sol":{"content":"// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v5.0.0) (utils/ReentrancyGuard.sol)\n\npragma solidity ^0.8.20;\n\n/**\n * @dev Contract module that helps prevent reentrant calls to a function.\n *\n * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier\n * available, which can be applied to functions to make sure there are no nested\n * (reentrant) calls to them.\n *\n * Note that because there is a single `nonReentrant` guard, functions marked as\n * `nonReentrant` may not call one another. This can be worked around by making\n * those functions `private`, and then adding `external` `nonReentrant` entry\n * points to them.\n *\n * TIP: If you would like to learn more about reentrancy and alternative ways\n * to protect against it, check out our blog post\n * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].\n */\nabstract contract ReentrancyGuard {\n    // Booleans are more expensive than uint256 or any type that takes up a full\n    // word because each write operation emits an extra SLOAD to first read the\n    // slot\u0027s contents, replace the bits taken up by the boolean, and then write\n    // back. This is the compiler\u0027s defense against contract upgrades and\n    // pointer aliasing, and it cannot be disabled.\n\n    // The values being non-zero value makes deployment a bit more expensive,\n    // but in exchange the refund on every call to nonReentrant will be lower in\n    // amount. Since refunds are capped to a percentage of the total\n    // transaction\u0027s gas, it is best to keep them low in cases like this one, to\n    // increase the likelihood of the full refund coming into effect.\n    uint256 private constant NOT_ENTERED = 1;\n    uint256 private constant ENTERED = 2;\n\n    uint256 private _status;\n\n    /**\n     * @dev Unauthorized reentrant call.\n     */\n    error ReentrancyGuardReentrantCall();\n\n    constructor() {\n        _status = NOT_ENTERED;\n    }\n\n    /**\n     * @dev Prevents a contract from calling itself, directly or indirectly.\n     * Calling a `nonReentrant` function from another `nonReentrant`\n     * function is not supported. It is possible to prevent this from happening\n     * by making the `nonReentrant` function external, and making it call a\n     * `private` function that does the actual work.\n     */\n    modifier nonReentrant() {\n        _nonReentrantBefore();\n        _;\n        _nonReentrantAfter();\n    }\n\n    function _nonReentrantBefore() private {\n        // On the first call to nonReentrant, _status will be NOT_ENTERED\n        if (_status == ENTERED) {\n            revert ReentrancyGuardReentrantCall();\n        }\n\n        // Any calls to nonReentrant after this point will fail\n        _status = ENTERED;\n    }\n\n    function _nonReentrantAfter() private {\n        // By storing the original value once again, a refund is triggered (see\n        // https://eips.ethereum.org/EIPS/eip-2200)\n        _status = NOT_ENTERED;\n    }\n\n    /**\n     * @dev Returns true if the reentrancy guard is currently set to \"entered\", which indicates there is a\n     * `nonReentrant` function in the call stack.\n     */\n    function _reentrancyGuardEntered() internal view returns (bool) {\n        return _status == ENTERED;\n    }\n}\n"}}