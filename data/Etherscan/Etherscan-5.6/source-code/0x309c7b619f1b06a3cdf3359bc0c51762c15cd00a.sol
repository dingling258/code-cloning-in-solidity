// SPDX-License-Identifier: MIT

pragma solidity =0.8.4;

abstract contract Initializable
{
    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer()
    {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall)
        {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall)
        {
            _initializing = false;
        }
    }
}

interface IToken
{
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

struct StakeInfo
{
    uint256 date;
    uint256 amount;
}

struct UserStakes
{
    StakeInfo[] stakes;
    uint256 headIndex;
}

contract StakingAnytimeForPeriod is Initializable
{
    address public admin_;
    bool public isPaused_;

    IToken public token_;
    uint256 public maxStakeLimit_;  // may be zero here
    uint256 public maxStakesPerUser_;
    uint256 public apy_;            // in basis points
    uint256 public period_;         // seconds

    uint256 public totalBalance_;   // total balance of all users
    mapping (address => UserStakes) public stakes_;
    
    string private constant ERR_ZERO_ADDRESS = "Zero address provided";
    string private constant ERR_ALREADY_DONE = "Already done";
    string private constant ERR_ADMIN_ONLY = "Available for admin only";
    string private constant ERR_ZERO_APY = "Zero APY is not allowed";
    string private constant ERR_PERIOD_INVALID = "Period too small";
    string private constant ERR_MAX_STAKE_LIMIT_TOO_SMALL = "Stake limit too small";
    string private constant ERR_ZERO_LIMIT = "Zero limit";
    string private constant ERR_ZERO_DEPOSIT_AMOUNT = "Zero deposit amount";
    string private constant ERR_COLLATERAL_LIMIT_REACHED = "Collateral limit reached";
    string private constant ERR_USER_STAKES_LIMIT_REACHED = "User stakes limit reached";
    string private constant ERR_NOTHING_TO_WITHDRAW = "Nothing to withdraw";
    string private constant ERR_TRANSFER_FAILURE = "Token transfer fail";
    string private constant ERR_ZERO_WITHDRAW_AMOUNT = "Zero withdraw amount";
    string private constant ERR_NOT_PAUSED = "Not paused";
    string private constant ERR_PAUSED = "Paused";
    string private constant ERR_CONTRACT_ALREADY_IN_USE = "Contact already in use";

    event Pause();
    event Resume();

    event SetMaxStakeLimit(uint256 oldValue, uint256 newValue);
    event SetMaxStakesPerUser(uint256 oldValue, uint256 newValue);

    event Deposit(address indexed caller, uint256 amount, address indexed receiver);
    event Withdrawal(address indexed caller, uint256 amount, address indexed receiver, uint256 newMaxStakeLimit);

    modifier onlyAdmin()
    {
        require(admin_ == msg.sender, ERR_ADMIN_ONLY);
        _;
    }

    // constructor and initializer

    function version() external pure returns (string memory) { return "StakingAnytimeForPeriod v8"; }
    
    constructor() initializer {}

    function initialize
    (
        address _admin,
        IToken _token,
        uint256 _maxStakeLimit, // may be zero here
        uint256 _maxStakesPerUser,
        uint256 _apy,           // % in basis points
        uint256 _period         // seconds
    ) external initializer
    {
        require(_admin != address(0), ERR_ZERO_ADDRESS);
        require(address(_token) != address(0), ERR_ZERO_ADDRESS);
        //require(_apy != 0, ERR_ZERO_APY);
        require(_period >= 60, ERR_PERIOD_INVALID);

        admin_ = _admin;
        token_ = _token;
        period_ = _period;
        apy_ = _apy;
        
        _setMaxStakesPerUser(_maxStakesPerUser);
        
        if(_maxStakeLimit != 0) _setMaxStakeLimit(_maxStakeLimit);
    }

    // setters

    function setPeriod(uint256 _newPeriod) external onlyAdmin
    {
        require(totalBalance_ == 0, ERR_CONTRACT_ALREADY_IN_USE);
        period_ = _newPeriod;
    }

    function setApy(uint256 _newPeriod) external onlyAdmin
    {
        require(totalBalance_ == 0, ERR_CONTRACT_ALREADY_IN_USE);
        period_ = _newPeriod;
    }

    function setMaxStakeLimit(uint256 _newMaxStakeLimit) external onlyAdmin
    {
        _setMaxStakeLimit(_newMaxStakeLimit);
    }

    function increaseMaxStakeLimit(uint256 _incrementValue) external onlyAdmin
    {
        _setMaxStakeLimit(maxStakeLimit_ + _incrementValue);
    }

    function _setMaxStakeLimit(uint256 _newMaxStakeLimit) private
    {
        require(maxStakeLimit_ != _newMaxStakeLimit, ERR_ALREADY_DONE);
        require(_newMaxStakeLimit >= totalBalance_, ERR_MAX_STAKE_LIMIT_TOO_SMALL);
        
        emit SetMaxStakeLimit(maxStakeLimit_, _newMaxStakeLimit);
        
        maxStakeLimit_ = _newMaxStakeLimit;

        uint256 currentBalance = token_.balanceOf(address(this));
        uint256 requiredBalance = _earnedAmount(_newMaxStakeLimit) + totalBalance_;
        
        if(currentBalance > requiredBalance)
        {
            require(token_.transfer(msg.sender, currentBalance - requiredBalance), ERR_TRANSFER_FAILURE);
        }
        else if(currentBalance < requiredBalance)
        {
            require(token_.transferFrom(msg.sender, address(this), requiredBalance - currentBalance), ERR_TRANSFER_FAILURE);
        }
    }

    function setMaxStakesPerUser(uint256 _newMaxStakesPerUser) external onlyAdmin
    {
        _setMaxStakesPerUser(_newMaxStakesPerUser);
    }
    
    function _setMaxStakesPerUser(uint256 _newMaxStakesPerUser) private
    {
        require(maxStakesPerUser_ != _newMaxStakesPerUser, ERR_ALREADY_DONE);
        require(_newMaxStakesPerUser > 0, ERR_ZERO_LIMIT);

        emit SetMaxStakesPerUser(maxStakesPerUser_, _newMaxStakesPerUser);

        maxStakesPerUser_ = _newMaxStakesPerUser;
    }

    // staking

    function canDeposit() external view returns (bool)
    {
        return !isPaused_ && totalBalance_ < maxStakeLimit_;
    }

    function canDeposit(address _wallet) external view returns (bool)
    {
        if(_wallet == address(0) || isPaused_ || totalBalance_ >= maxStakeLimit_)
        {
            return false;
        }
        
        UserStakes storage userStakes = stakes_[_wallet];
        return (userStakes.stakes.length - userStakes.headIndex) < maxStakesPerUser_;
    }

    function availableDepositAmount() external view returns (uint256)
    {
        if(isPaused_) return 0;
        
        return totalBalance_ >= maxStakeLimit_ ? 0 : maxStakeLimit_ - totalBalance_;
    }

    function depositToken(uint256 _amount) external
    {
        depositToken(_amount, msg.sender);
    }

    function depositToken(uint256 _amount, address _receiver) whenNotPaused public
    {
        require(totalBalance_ + _amount <= maxStakeLimit_, ERR_COLLATERAL_LIMIT_REACHED);
        require(_amount != 0, ERR_ZERO_DEPOSIT_AMOUNT);
        require(_receiver != address(0), ERR_ZERO_ADDRESS);

        UserStakes storage userStakes = stakes_[_receiver];
        require(userStakes.stakes.length - userStakes.headIndex < maxStakesPerUser_, ERR_USER_STAKES_LIMIT_REACHED);
        
        require(token_.transferFrom(msg.sender, address(this), _amount), ERR_TRANSFER_FAILURE);

        totalBalance_ += _amount;

        userStakes.stakes.push(StakeInfo({date: block.timestamp, amount: _amount}));

        emit Deposit(msg.sender, _amount, _receiver);
    }

    function availableWithdrawAmount(address _wallet) external view returns (uint256 withdrawAmount)
    {
        if(isPaused_) return 0;
        
        UserStakes storage userStakes = stakes_[_wallet];

        if(userStakes.stakes.length <= userStakes.headIndex) return 0;
        
        uint256 lastProcessed = _min(userStakes.stakes.length, userStakes.headIndex + maxStakesPerUser_);
        for(uint256 i = userStakes.headIndex; i < lastProcessed; ++i)
        {
            if(block.timestamp >= userStakes.stakes[i].date + period_)
            {
                withdrawAmount += userStakes.stakes[i].amount;
            }
            else
            {
                break;
            }
        }

        withdrawAmount += _earnedAmount(withdrawAmount);
    }

    function withdrawToken() external
    {
        withdrawToken(msg.sender);
    }

    function withdrawToken(address _receiver) whenNotPaused public
    {
        require(_receiver != address(0), ERR_ZERO_ADDRESS);

        UserStakes storage userStakes = stakes_[msg.sender];
        require(userStakes.stakes.length != 0, ERR_NOTHING_TO_WITHDRAW);

        uint256 depositedAmount = 0;
        uint256 withdrawAmount = 0;

        uint256 lastProcessed = _min(userStakes.stakes.length, userStakes.headIndex + maxStakesPerUser_);
        for(uint256 i = userStakes.headIndex; i < lastProcessed; ++i)
        {
            if(block.timestamp >= userStakes.stakes[i].date + period_)
            {
                depositedAmount = userStakes.stakes[i].amount;
                userStakes.stakes[i].amount = 0;
                userStakes.headIndex++;

                withdrawAmount += depositedAmount;
            }
            else
            {
                break;
            }
        }
        
        require(withdrawAmount != 0, ERR_ZERO_WITHDRAW_AMOUNT);

        totalBalance_ -= withdrawAmount;
        maxStakeLimit_ -= withdrawAmount;
        withdrawAmount += _earnedAmount(withdrawAmount);

        require(token_.transfer(_receiver, withdrawAmount), ERR_TRANSFER_FAILURE);

        emit Withdrawal(msg.sender, withdrawAmount, _receiver, maxStakeLimit_);
    }

    function withdrawUnusedCollateral() external onlyAdmin
    {
        uint256 currentBalance = token_.balanceOf(address(this));
        uint256 requiredBalance = _earnedAmount(maxStakeLimit_) + totalBalance_;
        
        require(currentBalance > requiredBalance, ERR_ZERO_WITHDRAW_AMOUNT);
        require(token_.transfer(msg.sender, currentBalance - requiredBalance), ERR_TRANSFER_FAILURE);
    }

    function balance(address _wallet) external view returns (StakeInfo[] memory)
    {
        return balance(_wallet, 0, maxStakesPerUser_);
    }

    function balance(address _wallet, uint256 _startPos, uint256 _limit) public view returns (StakeInfo[] memory)
    {
        if(_wallet != address(0) && _limit != 0)
        {
            UserStakes storage userStakes = stakes_[_wallet];
            _startPos += userStakes.headIndex;
            if(_startPos < userStakes.stakes.length) 
            {
                uint256 lastProcessed = _min(userStakes.stakes.length, _startPos + _limit);
    
                StakeInfo[] memory result = new StakeInfo[](lastProcessed - _startPos);
            
                for(uint256 i = _startPos; i < lastProcessed; ++i)
                {
                    result[i - _startPos] = userStakes.stakes[i];
                }
                return result;
            }
        }
        return new StakeInfo[](0);
    }
    
    // pausable
    
    modifier whenPaused()
    {
        require(isPaused_, ERR_NOT_PAUSED);
        _;
    }

    modifier whenNotPaused()
    {
        require(!isPaused_, ERR_PAUSED);
        _;
    }

    function pause() onlyAdmin whenNotPaused external
    {
        isPaused_ = true;
        emit Pause();
    }

    function resume() onlyAdmin whenPaused external
    {
        isPaused_ = false;
        emit Resume();
    }
    
    // heplers
    
    function earnedAmount(
        uint256 _amount,
        uint256 _apy,
        uint256 _period) external pure returns (uint256) {

        return _amount * _apy * _period / (10_000 * 365 days);
    }

    function calcMaxStakeLimit(
        uint256 _rewardAmount,
        uint256 _apy,
        uint256 _period) external pure returns (uint256) {

        return (_rewardAmount * 10_000 * 365 days) / (_apy * _period);
    }
    
    function _earnedAmount(uint256 _amount) private view returns (uint256)
    {
        return _amount * apy_ * period_ / (10_000 * 365 days);
    }

    function _min(uint256 _a, uint256 _b) private pure returns (uint256)
    {
        return _a <= _b ? _a : _b;
    }
}