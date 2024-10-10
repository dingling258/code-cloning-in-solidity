// SPDX-License-Identifier: MIT
// iState.io Staking Contract

pragma solidity ^0.8.7;
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
    function max(uint256 a, uint256 b) internal pure returns (uint256) {        
        return a >= b ? a : b; 
    }
}

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);
    
    function increaseAllowance(address spender, uint256 addedValue) external  returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    
    function name() external  view  returns(string memory);
    function symbol() external view   returns (string memory);
    function decimals() external view  returns (uint8);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}



contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;
    uint8 private _decimals;

    string private _name;
    string private _symbol;

    address deadAddress = 0x000000000000000000000000000000000000dEaD;

    mapping (address => bool ) public admin;

    address public rewardAddress = 0x32136A2127462c33872b72A5e6E9A28bf5FEE2D2; // State Token wallet rewards deposit

    uint256 public END_REWARD = 2556054000;// Fri Dec 30 2050 23:00:00 GMT+0000
    
    uint256 public stateTokenReward = 4 ; // 4% each 180 days
    uint256 public intervalRewardTime = 180 days; 
   
    mapping (address => uint256 ) public claimedToken;
    mapping (address => uint256 ) public claimedReward;
    mapping (address => uint256 []) public claimedTokenDate;
    mapping (address => uint256 []) public claimedRewardDate;
    
    uint256 public totalRewardsDistributed;

    address tokenAddress = 0x882b3E2f251d9B3c3f3Fb0976193eB6e997cb162;// State Token address 
    IERC20 public stateToken = IERC20(tokenAddress);
    
    mapping (address => uint256 ) public stakedToken;
    mapping (address => uint256 ) public stakedTokenIds;
    
    bool public stakingIsLive = true;
 
    mapping (address => mapping (uint256 => uint256))  stakeDateOwner;
    mapping (address => mapping (uint256 => uint256))  stakeAmountOwner;

    constructor ( string memory name_, string memory symbol_, uint8 decimals_) {
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        admin[msg.sender] = true;
        admin[rewardAddress] = true;
    }
   
    /* DEFAULT FUNCTIONS*/
    
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address Owner, address spender) public view virtual override returns (uint256) {
        return _allowances[Owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(((currentAllowance >= amount)), "Transfer amount exceeds allowance ");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance.sub(amount));
             }
        return true;
    }
  
    function increaseAllowance(address spender, uint256 addedValue) public virtual override returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance.sub(subtractedValue));
        }
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance.sub(amount);
        }
        _balances[recipient] = _balances[recipient].add(amount);

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance.sub(amount);
        }
        _totalSupply = _totalSupply.sub(amount);

        emit Transfer(account, deadAddress, amount);
    }

   
    function _approve(address Owner, address spender, uint256 amount) internal virtual {
        require(Owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[Owner][spender] = amount;
        emit Approval(Owner, spender, amount);
    }


    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
    
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
    function max(uint256 a, uint256 b) internal pure returns (uint256) {        
        return a >= b ? a : b; 
    }

    /* Function get staking state token and Mint state Stake Token*/
    function stakeStateMint (uint256 stake) public returns (bool){
        require(stake > 0, "Not enough Token to stake");
        require(stakingIsLive, "Staking program is finished");
        address _staker = msg.sender;
       // uint256 stake = stateToken.balanceOf(_staker);
        stakedToken[_staker] += stake;
        stakedTokenIds[_staker]+=1;
        stakeDateOwner[_staker][stakedTokenIds[_staker]] = block.timestamp;
        stakeAmountOwner[_staker][stakedTokenIds[_staker]] = stake;
        stateToken.transferFrom(_staker,address(this), stake);

        _mint(_staker,stake);
        return true;
    }
     /* Function unstake burns State Stake Token and release State token */

    function unstakeTokens () public virtual returns (bool exito){
        address _staker = msg.sender;
        uint256 balanceStateStake = balanceOf(_staker);
        uint256 rewardStaking = claimCalculateOwnerReward (_staker);
        
        (bool check2, uint256 rewNet) = SafeMath.trySub(rewardStaking,claimedReward[_staker]);
        if(check2 && rewNet > 0){
            rewardStaking = rewNet;
            claimedReward[_staker] = 0;
            //claimedRewardDate[_staker].push(block.timestamp);
            delete  claimedRewardDate[_staker];
            stateToken.transferFrom(rewardAddress,_staker, rewardStaking);
            totalRewardsDistributed.add(rewardStaking);
        }else{
            rewardStaking = 0;
        }

        claimedToken[_staker] = claimedToken[_staker].add(balanceStateStake);
        stakedTokenIds[_staker] = 0;
            
        _burn(_staker,balanceStateStake);
        stateToken.transfer(_staker, balanceStateStake); 
        claimedTokenDate[_staker].push(block.timestamp);
        
       return true;
    }

    function claimRewards () public {
        address _staker = msg.sender;
        uint256 rewardStaking = claimCalculateOwnerReward (_staker);
        
        (bool check, uint256 rewNet) = SafeMath.trySub(rewardStaking,claimedReward[_staker]);
            if(check){
                rewardStaking = rewNet;
                claimedReward[_staker] = claimedReward[_staker].add(rewardStaking);
                stateToken.transferFrom(rewardAddress,_staker, rewardStaking);
                claimedRewardDate[_staker].push(block.timestamp);
                totalRewardsDistributed.add(rewardStaking);

            }else{
                rewardStaking = 0;
                return ;
            }

    }


    /* Calculate Staking Reward : 4% 180 days */
    function claimCalculateOwnerReward (address _staker) public view returns (uint256 reward){

          if(stakedTokenIds[_staker]>0){ 
            for (uint i=1; i <= stakedTokenIds[_staker]; i++) {
                
                uint256 timeNow = min(block.timestamp, END_REWARD);
                uint256 timeToken = stakeDateOwner[_staker][i];
                    if(timeToken>0){

                uint256 months;

                (bool check, uint256 rew) = SafeMath.trySub(timeNow,timeToken);
                if(check){months = rew.div(intervalRewardTime);}else{months = 0;}                
                //uint256 months = (timeNow.sub(timeToken )).div(intervalRewardTime);
                if(months>0){
                uint amount = stakeAmountOwner [_staker][i];
                reward += (amount.mul(months) * stateTokenReward).div(100);               
                        }
                    }
                }
        }
            return reward;
    }

    /* Calculate Simulate Staking Reward 1 minute : 4% each 180 days */
    function claimCalculateOwnerRewardSimulation (address _staker) public view returns (uint256 reward){

          if(stakedTokenIds[_staker]>0){ 
            for (uint i=1; i <= stakedTokenIds[_staker]; i++) {
                
                uint256 timeNow = min(block.timestamp, END_REWARD);
                uint256 timeToken = stakeDateOwner[_staker][i];
                    if(timeToken>0){

                uint256 months;

                (bool check, uint256 rew) = SafeMath.trySub(timeNow,timeToken);
                if(check){months = rew.div(intervalRewardTime / 180 / 24 / 60 / 60 );}else{months = 0;}                

                if(months>0){
                uint amount = stakeAmountOwner [_staker][i];
                reward += (amount.mul(months) * stateTokenReward).div(100);  //  each minute    
                        }
                    }
                }
        }
            return reward / 180 / 24 / 60 / 60;
    }


 function contractInfo()
        public view returns (
            address _owner,
            uint256 __totalSupply,
            uint256 _totalRewardsDistributed,
            uint256 _rewardInterval,
            uint256 _rewardRate
            ) {
                _owner = rewardAddress;
                __totalSupply=totalSupply();
                _totalRewardsDistributed = totalRewardsDistributed;
                _rewardInterval = intervalRewardTime;
                _rewardRate = stateTokenReward;
            }


//return account infos
    function getAccount(address _account)
        public view returns (
            address account,
            uint256 balance,
            uint256 _totalRewards,
            uint256 _claimedRewards,
            uint256 [] memory _claimRewardsTime,
            uint256 _unstaked,
            uint256 firstStakeDate
            ) {
        account = _account;

        balance = balanceOf(account);

        _claimedRewards = claimedReward[account];
        
        _totalRewards = claimCalculateOwnerReward(account);// accumulativeDividendOf(account);

        _claimRewardsTime = claimedRewardDate[account];

        _unstaked = claimedToken[account];

        firstStakeDate = stakeDateOwner[account][1];
    }



function setAdmin (address _admin, bool _isOn) public  returns (bool ){
    require(admin[msg.sender] , "Only Admin can act here");
    admin[_admin] = _isOn;
    return _isOn;
}
function setWalletReward (address _adminWallet) public  returns (bool ){
    require(admin[msg.sender] , "Only Admin can act here");
    rewardAddress = _adminWallet;
    return true;
}
function setEndReward (uint256 _date) public  returns (bool ){
    require(admin[msg.sender] , "Only Admin can act here");
    END_REWARD = _date;
    return true;
}
function setTokenReward (uint256 _reward) public  returns (bool ){
    require(admin[msg.sender] , "Only Admin can act here");
    stateTokenReward = _reward;
    return true;
}
function setIntervalRewardTime (uint256 _time) public  returns (bool ){
    require(admin[msg.sender] , "Only Admin can act here");
    intervalRewardTime = _time;
    return true;
}
function setStakingIsLive (bool _isLive) public  returns (bool ){
    require(admin[msg.sender] , "Only Admin can act here");
    stakingIsLive = _isLive;
    return _isLive;
}
/* in case of any issue the tokens will don't remain blocked in the contract */
function emergencyWithdraw (uint256 _withdraw) public  returns (bool ){
    require(admin[msg.sender] , "Only Admin can act here");
    require( stakingIsLive == false , "Staking");
    stateToken.transfer(rewardAddress, _withdraw); 
    return true;
}

receive() external payable {revert();}

}
contract STATE_STAKE_TOKEN is ERC20 {
    
  //Name symbol decimals  
    constructor() ERC20("iState Staking", "STATE_STAKE", 18)  {
    }
}