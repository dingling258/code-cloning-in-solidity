// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

// File: contracts/HommiesStakeDev.sol


pragma solidity ^0.8.20;

interface hommies {
    function transferTax() external view returns (uint8);
}



contract HommiesStaking is Ownable {
    address public HommiesTokenAddress =
        0x8A370C951F34e295B2655B47bB0985dD08d8f718;
    IERC20 public hommiesToken;
    hommies public hommiesTokenHelper;
    uint256 public amountStakedFromUsers;
    uint256 public interestToBePaidFromHommies;

    struct Stake {
        uint256 amount;
        uint256 startTime;
        uint256 interestRate;
        uint256 duration;
        bool staked;
    }

    struct Plan {
        string name;
        uint256 interestRate;
        uint256 minAmount;
        uint256 maxAmount;
        uint256 duration;
        uint256 createdDate;
        bool inActive;
        uint256 totalActiveUsers;
    }

    struct StakingData {
        string planName;
        uint256 interestRate;
        uint256 minAmount;
        uint256 maxAmount;
        uint256 duration;
        Stake[] stakes;
    }

    mapping(address => mapping(string => Stake[])) public stakes;
    mapping(string => Plan) public plans;
    string[] public planIds;

    event PlanCreated(
        string name,
        uint256 interestRate,
        uint256 minAmount,
        uint256 maxAmount,
        uint256 duration,
        uint256 createdDate
    );
    event Staked(address indexed user, uint256 amount, string planName);
    event Unstaked(address indexed user, uint256 amount, string planName);

    constructor() Ownable(msg.sender) {
        hommiesToken = IERC20(HommiesTokenAddress); //Hommies Token Address
        hommiesTokenHelper = hommies(HommiesTokenAddress); //Hommies Token Address
    }

    function createPlan(
        string memory _name, //plan name
        uint256 _interestRate, //in percentage for the whole duration
        uint256 _minAmount, //in Hommies
        uint256 _maxAmount, //in Hommies
        uint256 _duration //in seconds
    ) public onlyOwner {
        require(plans[_name].interestRate == 0, "Plan already exists");
        require(
            _duration > 0,
            "Duration of a plan should be greater than zero"
        );
        require(
            _interestRate > 0,
            "Interest Rate of a plan should be greater than zero"
        );
        require(
            _maxAmount > _minAmount,
            "Max amount should be greater than min amount"
        );

        plans[_name] = Plan({
            name: _name,
            interestRate: _interestRate,
            minAmount: _minAmount,
            maxAmount: _maxAmount,
            duration: _duration,
            createdDate: block.timestamp,
            inActive: false,
            totalActiveUsers: 0
        });
        planIds.push(_name);
        emit PlanCreated(
            _name,
            _interestRate,
            _minAmount,
            _maxAmount,
            _duration,
            block.timestamp
        );
    }

    function stake(uint256 _amount, string memory _planName) external {
        Plan memory planDetails = plans[_planName];
        require(
            planDetails.inActive == false,
            "Currently plan is inactive or deleted"
        );
        require(
            _amount >= planDetails.minAmount,
            "Amount is less than minimum required for this plan"
        );
        require(
            _amount <= planDetails.maxAmount,
            "Amount is less than minimum required for this plan"
        );
        require(planDetails.interestRate > 0, "Plan does not exist");
        uint8 currentTransferTax = hommiesTokenHelper.transferTax();
        uint256 amountAfterTax = ((100 - currentTransferTax) * _amount) / 100;
        require(
            hommiesToken.transferFrom(msg.sender, address(this), _amount),
            "Transfer failed"
        );
        stakes[msg.sender][_planName].push(
            Stake({
                amount: amountAfterTax, //Amount of Hommies we got after tax deduction
                startTime: block.timestamp,
                interestRate: planDetails.interestRate,
                duration: planDetails.duration,
                staked: true
            })
        );
        uint256 interest = calculateInterest(
            amountAfterTax,
            planDetails.interestRate
        );
        planDetails.totalActiveUsers += 1;
        plans[_planName] = planDetails;
        amountStakedFromUsers += amountAfterTax;
        interestToBePaidFromHommies += interest;
        emit Staked(msg.sender, amountAfterTax, _planName);
    }

    function unstake(uint256 stake_index, uint256 plan_index) external {
        require(plan_index < planIds.length, "Invalid plan index");
        string memory planName = planIds[plan_index];
        Plan memory plan = plans[planName]; //in order to fetch active users
        Stake[] storage userStakesDetails = stakes[msg.sender][planName];
        require(userStakesDetails.length > 0, "No stakes found for this plan");

        require(
            userStakesDetails[stake_index].staked,
            "Stake already withdrawn"
        );
        require(
            block.timestamp >=
                userStakesDetails[stake_index].startTime +
                    userStakesDetails[stake_index].duration,
            "Stake has not yet matured according to plan duration"
        );
        uint256 interest = calculateInterest(
            userStakesDetails[stake_index].amount,
            userStakesDetails[stake_index].interestRate
        );
        uint256 totalAmount = userStakesDetails[stake_index].amount + interest;
        require(
            totalAmount <= hommiesToken.balanceOf(address(this)),
            "Insufficient funds in contract to perform transaction"
        );
        require(
            hommiesToken.transfer(msg.sender, totalAmount),
            "Unstake of Hommies failed"
        );

        userStakesDetails[stake_index].staked = false;
        plan.totalActiveUsers -= 1;
        plans[planName] = plan;
        amountStakedFromUsers -= userStakesDetails[stake_index].amount;
        interestToBePaidFromHommies -= interest;

        emit Unstaked(msg.sender, totalAmount, planName);
    }

    function deletePlan(string memory _planName) public onlyOwner {
        Plan memory plan = plans[_planName];
        require(
            plan.totalActiveUsers == 0,
            "Cannot delete the plan with active users "
        );
        delete plans[_planName];
        for (uint256 i = 0; i < planIds.length; i++) {
            if (keccak256(bytes(planIds[i])) == keccak256(bytes(_planName))) {
                planIds[i] = planIds[planIds.length - 1];
                planIds.pop();
                break;
            }
        }
    }

    function togglePlanState(string memory planName) public onlyOwner {
        require(bytes(plans[planName].name).length != 0, "Plan does not exist");
        plans[planName].inActive = !plans[planName].inActive;
    }

    function getTotalActiveUsersForPlan(string memory _planName)
        public
        view
        returns (uint256)
    {
        Plan memory plan = plans[_planName];
        return plan.totalActiveUsers;
    }

    function getAllStakingDataByAddress(address _user)
        public
        view
        returns (StakingData[] memory)
    {
        uint256 planCount = getPlanCount();
        StakingData[] memory allStakingData = new StakingData[](planCount);
        for (uint256 i = 0; i < planCount; i++) {
            string memory planName = planIds[i];
            Stake[] storage userStakes = stakes[_user][planName];
            Plan storage plan = plans[planName];
            allStakingData[i] = StakingData({
                planName: plan.name,
                interestRate: plan.interestRate,
                minAmount: plan.minAmount,
                maxAmount: plan.maxAmount,
                duration: plan.duration,
                stakes: userStakes
            });
        }
        return allStakingData;
    }

    function getAllPlans() public view returns (Plan[] memory) {
        uint256 planCount = getPlanCount();
        Plan[] memory allPlans = new Plan[](planCount);
        for (uint256 i = 0; i < planCount; i++) {
            allPlans[i] = plans[planIds[i]];
        }
        return allPlans;
    }

    function getTax(uint256 _amount) external view returns (uint256) {
        uint8 currentTransferTax = hommiesTokenHelper.transferTax();
        uint256 amountAfterTax = ((100 - currentTransferTax) * _amount) / 100;
        return amountAfterTax;
    }

    function calculateInterest(uint256 _amount, uint256 _interestRate)
        public
        pure
        returns (uint256)
    {
        return (_amount * _interestRate) / 1e20;
    }

    function getUserStakedInfo(
        address _user,
        string memory _planName,
        uint256 _index
    )
        public
        view
        returns (
            uint256 amount,
            uint256 startTime,
            uint256 interestRate,
            uint256 duration,
            bool staked
        )
    {
        Stake[] memory userStakes = stakes[_user][_planName];
        require(_index < userStakes.length, "Invalid stake index");
        Stake memory userStake = userStakes[_index];
        return (
            userStake.amount,
            userStake.startTime,
            userStake.interestRate,
            userStake.duration,
            userStake.staked
        );
    }

    function getPlanCount() public view returns (uint256) {
        return planIds.length;
    }

    function withdrawTokens(address tokenAddress) external onlyOwner {
        IERC20 token = IERC20(tokenAddress);
        uint256 tokenBalance = token.balanceOf(address(this));
        require(tokenBalance > 0, "Do not have contract balance to withdraw");
        if (tokenAddress == HommiesTokenAddress) {
            require(
                tokenBalance >
                    (amountStakedFromUsers + interestToBePaidFromHommies),
                "Can not withdraw the users staked amount"
            );
            uint256 amountCanWithdraw = tokenBalance -
                (amountStakedFromUsers + interestToBePaidFromHommies);
            require(
                token.transfer(msg.sender, amountCanWithdraw),
                "Transfer failed"
            );
        } else {
            require(
                token.transfer(msg.sender, tokenBalance),
                "Transfer failed"
            );
        }
    }

    function updateHommiesAddress(address tokenAddress)
        public
        onlyOwner
        returns (address)
    {
        require(tokenAddress != address(0), "Invalid token address");
        HommiesTokenAddress = tokenAddress;
        updateTokenInstance(); // for updating hommies token contract instance
        return HommiesTokenAddress;
    }

    function updateTokenInstance() internal {
        hommiesToken = IERC20(HommiesTokenAddress); // need to change hommies contract address
        hommiesTokenHelper = hommies(HommiesTokenAddress); // need to change hommies contract address
    }
}