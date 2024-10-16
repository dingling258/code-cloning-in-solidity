// File: https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.9/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
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
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

// File: contracts/MSN_STAKE.sol


pragma solidity ^0.8.0;


contract MSN_STAKE {
    address public msn_contract_address;

    constructor(address _msn_contract_addr) {
        msn_contract_address = _msn_contract_addr;
    }

    uint256 private total_credit;

    function get_total_credit() external view returns (uint256) {
        return total_credit;
    }

    mapping(address => uint256) private credit_map;

    function get_credit(address addr) external view returns (uint256) {
        return credit_map[addr];
    }

    mapping(address => uint256) private stake_token_map;

    function get_stake_token(address addr) external view returns (uint256) {
        return stake_token_map[addr];
    }

    mapping(address => uint256) private stake_last_time_map;

    function get_stake_last_time(address addr) external view returns (uint256) {
        return stake_last_time_map[addr];
    }

    function cal_credit_reward(address addr) public view returns (uint256) {
        return get_credit_reward_speed(addr) * (block.timestamp - stake_last_time_map[addr]);
    }

    function get_credit_reward_speed(address addr) public view returns (uint256) {
        return stake_token_map[addr] / 1000;
    }

    function harvest() public {
        uint256 credit_reward = cal_credit_reward(msg.sender);
        require(credit_reward >= 0, "credit_reward smaller then 0 err in harvest");
        stake_last_time_map[msg.sender] = block.timestamp;
        credit_map[msg.sender] = credit_map[msg.sender] + credit_reward;
        total_credit += credit_reward;
        require(total_credit >= 0, "total_credit overflow err");
    }

    event stake_EVENT(address trigger_user_addr, uint256 amount);

    function stake(uint256 amount) external {
        require(amount > 0, "stake amount must bigger then 0");

        uint256 allowance = IERC20(msn_contract_address).allowance(msg.sender, address(this));

        require(allowance > 0, "please approve tokens before staking");
        require(allowance >= amount, "please approve more tokens");

        harvest();

        bool t_result = IERC20(msn_contract_address).transferFrom(msg.sender, address(this), amount);
        require(t_result == true, "transfer error");

        stake_token_map[msg.sender] += amount;

        emit stake_EVENT(msg.sender, amount);
    }

    event unstake_EVENT(address trigger_user_addr, uint256 amount);

    function unstake(uint256 amount) external {
        require(stake_token_map[msg.sender] >= amount, "not enough balance");

        harvest();

        stake_token_map[msg.sender] -= amount;

        //transfer
        bool t_result = IERC20(msn_contract_address).transfer(msg.sender, amount);
        require(t_result == true, "transfer error");

        emit unstake_EVENT(msg.sender, amount);
    }
}