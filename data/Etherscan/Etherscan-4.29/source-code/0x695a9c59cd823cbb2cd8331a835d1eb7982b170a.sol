/* 
* OpenGPU Network World's Leading Decentralized GPU Ecosystem
* 
* Website:      https://opengpu.network/
* Staking:      https://stake.opengpu.network/
* Telegram:     https://t.me/opengpuportal
* Twitter:      https://x.com/opengpunetwork
* Whitepaper:   https://opengpu.network/docs/whitepaper.pdf
* Yellowpaper:  https://opengpu.network/docs/yellowpaper.pdf
*
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If EIP-1153 (transient storage) is available on the chain you're deploying at,
 * consider using {ReentrancyGuardTransient} instead.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    uint256 private _status;

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

    constructor() {
        _status = NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        if (_status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        _status = ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == ENTERED;
    }
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router02 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract oGPUStaking is Ownable, ReentrancyGuard {
    IERC20  public oGPU;
    uint256 public gpuId;

    struct UserInfo {
        address user;           // User address
        uint256 poolId;         // Pool ID
        uint256 amount;         // How many oGPU tokens the user has provided.
        uint256 stakeTime;      // Time when user staked
        uint256 points;         // How many points the user has, accumulated.
        uint256 gpuId;          // GPU gpuId
        bool    claimed;        // default false
        uint256 lastBoostTime;  // Last time user boosted
        uint256 claimedETH;     // Claimed ETH
        uint256 claimedoGPU;    // Claimed oGPU
    }

    struct UserInfoWithShares {
        address user;           // User address
        uint256 poolId;         // Pool ID
        uint256 amount;         // How many oGPU tokens the user has provided.
        uint256 stakeTime;      // Time when user staked
        uint256 points;         // How many points the user has, accumulated.
        uint256 gpuId;          // GPU gpuId
        bool    claimed;        // default false
        uint256 lastBoostTime;  // Last time user boosted
        uint256 claimedETH;     // Claimed ETH
        uint256 claimedoGPU;    // Claimed oGPU
        uint256 share;          // User share of ETH
    }

    struct PoolInfo {
        uint256 poolId;             // Pool ID
        uint256 totalPoints;        // Total points accumulated by all users
        uint256 totalAmount;        // Total amount of oGPU tokens staked
        uint256 totalETHStaked;      // Total ETH share
        uint256 startTime;          // Start time of the pool
        uint256 duration;           // Duration of the pool
        uint256 endTime;            // End time of the pools
        bool    ended;              // default false
    }

    PoolInfo[] public poolInfo;
    mapping (uint256 => mapping (address => UserInfo)) public userInfoMap;
    mapping (uint256 => UserInfo[]) public poolUsers;
    mapping (address => mapping (uint256 => uint256)) public userPoolIndex;

    event EmergencyWithdraw(address indexed user, uint256 poolId, uint256 amount);
    event Claimed(address indexed user, uint256 poolId, uint256 amount);
    event PoolEnded(uint256 poolId, uint256 endTime);
    event Staked(address indexed user, uint256 amount, uint256 gpuType);
    event PoolCreated(uint256 stakeID, uint256 stakingStartTimestamp, uint256 duration, uint256 stakingEndTimestamp);

    constructor(IERC20 _oGPU) {
        oGPU = _oGPU;
    }

    receive() external payable {
    }

    function createPool(uint256 _duration) external onlyOwner {
        require(_duration <= 90 days, "Staking: duration should be less than 90 days");
        uint256 _poolId = poolInfo.length;
        uint256 _startTime = block.timestamp;
        uint256 _endTime = _startTime + _duration;


        poolInfo.push(PoolInfo({
            poolId: _poolId,
            totalPoints: 0,
            totalAmount: 0,
            totalETHStaked: 0,
            startTime: _startTime,
            duration: _duration,
            endTime: _endTime,
            ended: false
        }));
        emit PoolCreated(_poolId, _startTime, _duration, _endTime);
    }

    function stake(uint256 _poolId, uint256 _amount, uint256 _gpuID) external nonReentrant {
        require(_amount > 0, "Staking: amount must be greater than 0");
        require(_poolId < poolInfo.length, "Staking: invalid pool id");
        PoolInfo storage pool = poolInfo[_poolId];
        require(block.timestamp >= pool.startTime, "Staking: pool not started");
        require(block.timestamp < pool.endTime, "Staking: pool ended");
        require(!pool.ended, "Staking: pool ended");
        oGPU.transferFrom(msg.sender, address(this), _amount);
        UserInfo storage user = userInfoMap[_poolId][msg.sender];
        // if user.amount is zero and userpoolindex is zero, then user is new
        if (user.amount == 0 && userPoolIndex[msg.sender][_poolId] == 0) {
            user.user = msg.sender;
            user.stakeTime = block.timestamp;
            user.poolId = _poolId;
            user.lastBoostTime = block.timestamp;
            user.gpuId = _gpuID;
            user.amount = _amount;
            uint256 totalStakeTime = pool.endTime - block.timestamp;
            uint256 _points = _amount * (totalStakeTime / 2 days + 1);
            pool.totalAmount = pool.totalAmount + _amount;
            if (_gpuID < 130) {
                _points += (_points * 15) / 100;
            } else if (_gpuID < 360) {
                _points += (_points * 10) / 100; 
            } else {
                _points += (_points * 5) / 100;
            }
            user.points = _points;
            pool.totalPoints = pool.totalPoints + user.points;
            uint256 userLength = poolUsers[_poolId].length;
            poolUsers[_poolId].push(user);
            userPoolIndex[msg.sender][_poolId] = userLength;

        } else {
            user.gpuId = _gpuID;
            user.amount = user.amount + _amount;
            uint256 totalStakeTime = pool.endTime - block.timestamp;
            uint256 _points = _amount * (totalStakeTime / 2 days + 1);

            if (_gpuID < 130) {
                _points += (_points * 15) / 100;
            } else if (_gpuID < 360) {
                _points += (_points * 10) / 100; 
            } else {
                _points += (_points * 5) / 100;
            }
            user.points += _points;
            pool.totalAmount = pool.totalAmount + _amount;
            pool.totalPoints = pool.totalPoints +  _points;
            uint256 userIndex = userPoolIndex[msg.sender][_poolId];
            poolUsers[_poolId][userIndex] = user;
        }
        emit Staked(msg.sender, _poolId, _amount);
    }

    function boostGPU(uint256 _poolId) external nonReentrant{
        require(_poolId < poolInfo.length, "Staking: invalid pool id");
        UserInfo storage user = userInfoMap[_poolId][msg.sender];
        require(user.amount > 0, "Staking: user has no stake");
        require(block.timestamp < poolInfo[_poolId].endTime, "Staking: pool ended");
        require(!user.claimed, "Staking: user already claimed");
        require(!poolInfo[_poolId].ended, "Staking: pool ended");
        // user can boost once every 24 hours
        require(block.timestamp - user.lastBoostTime >= 1 days, "Staking: user can boost once every 24 hours");
        user.lastBoostTime = block.timestamp;
        // update pool points
        PoolInfo storage pool = poolInfo[_poolId];
        pool.totalPoints -= user.points;
        uint256 _gpuID = user.gpuId;
        if (_gpuID < 130) {
            user.points += (user.points * 3) / 100;
        } else if (_gpuID < 360) {
            user.points += (user.points * 2) / 100; 
        } else {
            user.points += user.points / 100;
        }

        pool.totalPoints += user.points;
        uint256 userIndex = userPoolIndex[msg.sender][_poolId];
        poolUsers[_poolId][userIndex] = user;
    }

    function claim(uint256 _poolId) external nonReentrant {
        require(_poolId < poolInfo.length, "Staking: invalid pool id");
        PoolInfo storage pool = poolInfo[_poolId];
        UserInfo storage user = userInfoMap[_poolId][msg.sender];
        require(pool.ended, "Staking: claim period is not started");
        require(user.amount > 0, "Staking: user has no stake");
        require(block.timestamp >= pool.endTime, "Staking: pool not ended");
        require(!user.claimed, "Staking: user already claimed");

        user.claimed = true;
        uint256 _amount = user.amount;
        user.claimedoGPU = _amount;
        user.amount = 0;
        oGPU.transfer(msg.sender, _amount);
        uint256 _points = user.points;
        user.points = 0;
        // userpoolindex
        uint256 userIndex = userPoolIndex[msg.sender][_poolId];
        uint256 _share = (_points * pool.totalETHStaked) / pool.totalPoints;
        user.claimedETH = _share;
        poolUsers[_poolId][userIndex] = user;
        payable(msg.sender).transfer(_share);
        emit Claimed(msg.sender, _poolId, _amount);
    }

    function emergencyWithdraw(uint256 _poolId) external nonReentrant {
        require(_poolId < poolInfo.length, "Staking: invalid pool id");
        PoolInfo storage pool = poolInfo[_poolId];
        UserInfo storage user = userInfoMap[_poolId][msg.sender];
        require(user.amount > 0, "Staking: user has no stake");
        require(block.timestamp < pool.endTime, "Staking: pool ended");
        uint256 _amount = user.amount;
        pool.totalAmount -= _amount;
        pool.totalPoints -= user.points;
        user.amount = 0;
        user.points = 0;
        uint256 userIndex = userPoolIndex[msg.sender][_poolId];
        poolUsers[_poolId][userIndex] = user;
        oGPU.transfer(msg.sender, (_amount * 90) / 100);
        oGPU.transfer(address(owner()),(_amount * 10)/ 100);
        emit EmergencyWithdraw(msg.sender, _poolId, _amount);
    }

    function endPool(uint256 _poolId) external onlyOwner {
        require(_poolId < poolInfo.length, "Staking: invalid pool id");
        PoolInfo storage pool = poolInfo[_poolId];
        require(block.timestamp >= pool.endTime, "Staking: pool not ended");
        pool.ended = true;
        emit PoolEnded(_poolId, block.timestamp);
    }

    function getAllPools() external view returns (PoolInfo[] memory) {
        return poolInfo;
    }

    function getUserInfo(uint256 _poolId, address _user) external view returns (UserInfo memory) {
        require(_poolId < poolInfo.length, "Staking: invalid pool id");
        return userInfoMap[_poolId][_user];
    }

    function getPoolUsers(uint256 _poolId) external view returns (UserInfo[] memory) {
        require(_poolId < poolInfo.length, "Staking: invalid pool id");
        return poolUsers[_poolId];
    }

    function getPoolUsersWithShares(uint256 _poolId) external view returns (UserInfoWithShares[] memory) {
        require(_poolId < poolInfo.length, "Staking: invalid pool id");
        if (poolInfo[_poolId].totalPoints == 0) {
            return new UserInfoWithShares[](0);
        }
        UserInfo[] memory users = poolUsers[_poolId];
        UserInfoWithShares[] memory usersWithShares = new UserInfoWithShares[](users.length);
        for (uint256 i = 0; i < users.length; i++) {
            UserInfo memory user = users[i];
            usersWithShares[i] = UserInfoWithShares({
                user: user.user,
                poolId: user.poolId,
                amount: user.amount,
                stakeTime: user.stakeTime,
                points: user.points,
                gpuId: user.gpuId,
                claimed: user.claimed,
                lastBoostTime: user.lastBoostTime,
                claimedETH: user.claimedETH,
                claimedoGPU: user.claimedoGPU,
                share: (user.points * poolInfo[_poolId].totalETHStaked) / poolInfo[_poolId].totalPoints
            });
        }
        return usersWithShares;
    }

    function getPoolUsersWithSharesRange(uint256 _poolId, uint256 _start, uint256 _end) external view returns (UserInfoWithShares[] memory) {
        require(_poolId < poolInfo.length, "Staking: invalid pool id");
        require(_start < poolUsers[_poolId].length, "Staking: invalid start index");
        require(_end < poolUsers[_poolId].length, "Staking: invalid end index");
        UserInfo[] memory users = poolUsers[_poolId];
        UserInfoWithShares[] memory usersWithShares = new UserInfoWithShares[](_end - _start + 1);
        for (uint256 i = _start; i <= _end; i++) {
            UserInfo memory user = users[i];
            usersWithShares[i - _start] = UserInfoWithShares({
                user: user.user,
                poolId: user.poolId,
                amount: user.amount,
                stakeTime: user.stakeTime,
                points: user.points,
                gpuId: user.gpuId,
                claimed: user.claimed,
                lastBoostTime: user.lastBoostTime,
                claimedETH: user.claimedETH,
                claimedoGPU: user.claimedoGPU,
                share: (user.points * poolInfo[_poolId].totalETHStaked) / poolInfo[_poolId].totalPoints
            });
        }
        return usersWithShares;
    }

    function getPoolUser(uint256 _poolId, address _user) external view returns (UserInfo memory) {
        require(_poolId < poolInfo.length, "Staking: invalid pool id");
        return userInfoMap[_poolId][_user];
    }

    function getPoolUsersLength(uint256 _poolId) external view returns (uint256) {
        require(_poolId < poolInfo.length, "Staking: invalid pool id");
        return poolUsers[_poolId].length;
    }

    function getPoolUserReward(uint256 _poolId, address _user) external view returns (uint256) {
        require(_poolId < poolInfo.length, "Staking: invalid pool id");
        UserInfo storage user = userInfoMap[_poolId][_user];
        PoolInfo storage pool = poolInfo[_poolId];

        // Reward on ETH is calculated based on the points
        uint256 _points = user.points;
        uint256 _share = (_points * pool.totalETHStaked) / pool.totalPoints;
        return _share;
    }

    function addETHToPool(uint256 _poolId, uint256 _amount) external payable onlyOwner {
        require(_amount > 0, "Staking: amount must be greater than 0");
        require(_amount == msg.value, "Staking: invalid amount");
        require(_poolId < poolInfo.length, "Staking: invalid pool id");
        PoolInfo storage pool = poolInfo[_poolId];
        require(block.timestamp >= pool.startTime, "Staking: pool not started");
        require(block.timestamp < pool.endTime, "Staking: pool ended");
        require(!pool.ended, "Staking: pool ended");
        pool.totalETHStaked += _amount;
    }

    // retrieve all ETH from the contract
    function retrieveETH() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    // retrieve all oGPU from the contract
    function retrieveoGPU() external onlyOwner {
        oGPU.transfer(msg.sender, oGPU.balanceOf(address(this)));
    }

}