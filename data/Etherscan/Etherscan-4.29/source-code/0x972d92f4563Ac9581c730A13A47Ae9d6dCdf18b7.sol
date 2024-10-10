// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.8.0;

// Sources flattened with hardhat v2.19.4 https://hardhat.org


// File contracts/Common/Context.sol

// Original license: SPDX_License_Identifier: MIT

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


// File contracts/Math/SafeMath.sol

// Original license: SPDX_License_Identifier: MIT

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     *
     * _Available since v2.4.0._
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


// File contracts/ERC20/IERC20.sol

// Original license: SPDX_License_Identifier: MIT


/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
}


// File contracts/Misc_AMOs/convex/IConvexStakingWrapperFrax.sol

// Original license: SPDX_License_Identifier: MIT

interface IConvexStakingWrapperFrax {
  function addRewards (  ) external;
  function addTokenReward ( address _token ) external;
  function allowance ( address owner, address spender ) external view returns ( uint256 );
  function approve ( address spender, uint256 amount ) external returns ( bool );
  function balanceOf ( address account ) external view returns ( uint256 );
  function collateralVault (  ) external view returns ( address );
  function convexBooster (  ) external view returns ( address );
  function convexPool (  ) external view returns ( address );
  function convexPoolId (  ) external view returns ( uint256 );
  function convexToken (  ) external view returns ( address );
  function crv (  ) external view returns ( address );
  function curveToken (  ) external view returns ( address );
  function cvx (  ) external view returns ( address );
  function decimals (  ) external view returns ( uint8 );
  function decreaseAllowance ( address spender, uint256 subtractedValue ) external returns ( bool );
  function deposit ( uint256 _amount, address _to ) external;
  function distroContract (  ) external view returns ( address );
  function distroImplementation (  ) external view returns ( address );
  function distroSealed (  ) external view returns ( bool );
  function earmarkRewards (  ) external returns ( bool );
  function factory (  ) external view returns ( address );
  function getReward ( address _account, address _forwardTo ) external;
  function getReward ( address _account ) external;
  function increaseAllowance ( address spender, uint256 addedValue ) external returns ( bool );
  function initialize ( uint256 _poolId ) external;
  function invalidateReward ( address _token ) external;
  function isInit (  ) external view returns ( bool );
  function isShutdown (  ) external view returns ( bool );
  function name (  ) external view returns ( string memory );
  function owner (  ) external view returns ( address );
  function proxyFactory (  ) external view returns ( address );
  function registeredRewards ( address ) external view returns ( uint256 );
  function renounceOwnership (  ) external;
  function rewardHook (  ) external view returns ( address );
  function rewardLength (  ) external view returns ( uint256 );
  function rewardRedirect ( address ) external view returns ( address );
  function rewards ( uint256 ) external view returns ( address reward_token, address reward_pool, uint256 reward_integral, uint256 reward_remaining );
  function sealDistributor (  ) external;
  function setApprovals (  ) external;
  function setDistributor ( address _distro ) external;
  function setHook ( address _hook ) external;
  function setRewardRedirect ( address _to ) external;
  function setVault ( address _vault ) external;
  function shutdown (  ) external;
  function stake ( uint256 _amount, address _to ) external;
  function symbol (  ) external view returns ( string memory );
  function totalBalanceOf ( address _account ) external view returns ( uint256 );
  function totalSupply (  ) external view returns ( uint256 );
  function transfer ( address recipient, uint256 amount ) external returns ( bool );
  function transferFrom ( address sender, address recipient, uint256 amount ) external returns ( bool );
  function transferOwnership ( address newOwner ) external;
  function user_checkpoint ( address _account ) external returns ( bool );
  function withdraw ( uint256 _amount ) external;
  function withdrawAndUnwrap ( uint256 _amount ) external;
}


// File contracts/Misc_AMOs/curve/ICurveStableSwapMetaNG.sol

// Original license: SPDX_License_Identifier: GPL-2.0-or-later

interface ICurveStableSwapMetaNG {
  function exchange ( int128 i, int128 j, uint256 _dx, uint256 _min_dy ) external returns ( uint256 );
  function exchange ( int128 i, int128 j, uint256 _dx, uint256 _min_dy, address _receiver ) external returns ( uint256 );
  function exchange_received ( int128 i, int128 j, uint256 _dx, uint256 _min_dy ) external returns ( uint256 );
  function exchange_received ( int128 i, int128 j, uint256 _dx, uint256 _min_dy, address _receiver ) external returns ( uint256 );
  function exchange_underlying ( int128 i, int128 j, uint256 _dx, uint256 _min_dy ) external returns ( uint256 );
  function exchange_underlying ( int128 i, int128 j, uint256 _dx, uint256 _min_dy, address _receiver ) external returns ( uint256 );
  function add_liquidity ( uint256[2] memory _amounts, uint256 _min_mint_amount ) external returns ( uint256 );
  function add_liquidity ( uint256[2] memory _amounts, uint256 _min_mint_amount, address _receiver ) external returns ( uint256 );
  function remove_liquidity_one_coin ( uint256 _burn_amount, int128 i, uint256 _min_received ) external returns ( uint256 );
  function remove_liquidity_one_coin ( uint256 _burn_amount, int128 i, uint256 _min_received, address _receiver ) external returns ( uint256 );
  function remove_liquidity_imbalance ( uint256[2] memory _amounts, uint256 _max_burn_amount ) external returns ( uint256 );
  function remove_liquidity_imbalance ( uint256[2] memory _amounts, uint256 _max_burn_amount, address _receiver ) external returns ( uint256 );
  function remove_liquidity ( uint256 _burn_amount, uint256[2] memory _min_amounts ) external returns ( uint256[2] memory );
  function remove_liquidity ( uint256 _burn_amount, uint256[2] memory _min_amounts, address _receiver ) external returns ( uint256[2] memory );
  function remove_liquidity ( uint256 _burn_amount, uint256[2] memory _min_amounts, address _receiver, bool _claim_admin_fees ) external returns ( uint256[2] memory );
  function withdraw_admin_fees (  ) external;
  function last_price ( uint256 i ) external view returns ( uint256 );
  function ema_price ( uint256 i ) external view returns ( uint256 );
  function get_p ( uint256 i ) external view returns ( uint256 );
  function price_oracle ( uint256 i ) external view returns ( uint256 );
  function D_oracle (  ) external view returns ( uint256 );
  function transfer ( address _to, uint256 _value ) external returns ( bool );
  function transferFrom ( address _from, address _to, uint256 _value ) external returns ( bool );
  function approve ( address _spender, uint256 _value ) external returns ( bool );
  function permit ( address _owner, address _spender, uint256 _value, uint256 _deadline, uint8 _v, bytes32 _r, bytes32 _s ) external returns ( bool );
  function DOMAIN_SEPARATOR (  ) external view returns ( bytes32 );
  function get_dx ( int128 i, int128 j, uint256 dy ) external view returns ( uint256 );
  function get_dx_underlying ( int128 i, int128 j, uint256 dy ) external view returns ( uint256 );
  function get_dy ( int128 i, int128 j, uint256 dx ) external view returns ( uint256 );
  function get_dy_underlying ( int128 i, int128 j, uint256 dx ) external view returns ( uint256 );
  function calc_withdraw_one_coin ( uint256 _burn_amount, int128 i ) external view returns ( uint256 );
  function totalSupply (  ) external view returns ( uint256 );
  function get_virtual_price (  ) external view returns ( uint256 );
  function calc_token_amount ( uint256[2] memory _amounts, bool _is_deposit ) external view returns ( uint256 );
  function A (  ) external view returns ( uint256 );
  function A_precise (  ) external view returns ( uint256 );
  function balances ( uint256 i ) external view returns ( uint256 );
  function get_balances (  ) external view returns ( uint256[] memory );
  function stored_rates (  ) external view returns ( uint256[] memory );
  function dynamic_fee ( int128 i, int128 j ) external view returns ( uint256 );
  function ramp_A ( uint256 _future_A, uint256 _future_time ) external;
  function stop_ramp_A (  ) external;
  function set_new_fee ( uint256 _new_fee, uint256 _new_offpeg_fee_multiplier ) external;
  function set_ma_exp_time ( uint256 _ma_exp_time, uint256 _D_ma_time ) external;
  function N_COINS (  ) external view returns ( uint256 );
  function BASE_POOL (  ) external view returns ( address );
  function BASE_N_COINS (  ) external view returns ( uint256 );
  function BASE_COINS ( uint256 arg0 ) external view returns ( address );
  function coins ( uint256 arg0 ) external view returns ( address );
  function fee (  ) external view returns ( uint256 );
  function offpeg_fee_multiplier (  ) external view returns ( uint256 );
  function admin_fee (  ) external view returns ( uint256 );
  function initial_A (  ) external view returns ( uint256 );
  function future_A (  ) external view returns ( uint256 );
  function initial_A_time (  ) external view returns ( uint256 );
  function future_A_time (  ) external view returns ( uint256 );
  function admin_balances ( uint256 arg0 ) external view returns ( uint256 );
  function ma_exp_time (  ) external view returns ( uint256 );
  function D_ma_time (  ) external view returns ( uint256 );
  function ma_last_time (  ) external view returns ( uint256 );
  function name (  ) external view returns ( string memory );
  function symbol (  ) external view returns ( string memory );
  function decimals (  ) external view returns ( uint8 );
  function version (  ) external view returns ( string memory );
  function balanceOf ( address arg0 ) external view returns ( uint256 );
  function allowance ( address arg0, address arg1 ) external view returns ( uint256 );
  function nonces ( address arg0 ) external view returns ( uint256 );
  function salt (  ) external view returns ( bytes32 );
}


// File contracts/Curve/IFraxGaugeController.sol

// Original license: SPDX_License_Identifier: GPL-2.0-or-later

// https://github.com/swervefi/swerve/edit/master/packages/swerve-contracts/interfaces/IGaugeController.sol

interface IFraxGaugeController {
    struct Point {
        uint256 bias;
        uint256 slope;
    }

    struct VotedSlope {
        uint256 slope;
        uint256 power;
        uint256 end;
    }

    // Public variables
    function admin() external view returns (address);
    function future_admin() external view returns (address);
    function token() external view returns (address);
    function voting_escrow() external view returns (address);
    function n_gauge_types() external view returns (int128);
    function n_gauges() external view returns (int128);
    function gauge_type_names(int128) external view returns (string memory);
    function gauges(uint256) external view returns (address);
    function vote_user_slopes(address, address)
        external
        view
        returns (VotedSlope memory);
    function vote_user_power(address) external view returns (uint256);
    function last_user_vote(address, address) external view returns (uint256);
    function points_weight(address, uint256)
        external
        view
        returns (Point memory);
    function time_weight(address) external view returns (uint256);
    function points_sum(int128, uint256) external view returns (Point memory);
    function time_sum(uint256) external view returns (uint256);
    function points_total(uint256) external view returns (uint256);
    function time_total() external view returns (uint256);
    function points_type_weight(int128, uint256)
        external
        view
        returns (uint256);
    function time_type_weight(uint256) external view returns (uint256);

    // Getter functions
    function gauge_types(address) external view returns (int128);
    function gauge_relative_weight(address) external view returns (uint256);
    function gauge_relative_weight(address, uint256) external view returns (uint256);
    function get_gauge_weight(address) external view returns (uint256);
    function get_type_weight(int128) external view returns (uint256);
    function get_total_weight() external view returns (uint256);
    function get_weights_sum_per_type(int128) external view returns (uint256);

    // External functions
    function commit_transfer_ownership(address) external;
    function apply_transfer_ownership() external;
    function add_gauge(
        address,
        int128,
        uint256
    ) external;
    function checkpoint() external;
    function checkpoint_gauge(address) external;
    function global_emission_rate() external view returns (uint256);
    function gauge_relative_weight_write(address)
        external
        returns (uint256);
    function gauge_relative_weight_write(address, uint256)
        external
        returns (uint256);
    function add_type(string memory, uint256) external;
    function change_type_weight(int128, uint256) external;
    function change_gauge_weight(address, uint256) external;
    function change_global_emission_rate(uint256) external;
    function vote_for_gauge_weights(address, uint256) external;
}


// File contracts/Curve/IFraxGaugeFXSRewardsDistributor.sol

// Original license: SPDX_License_Identifier: GPL-2.0-or-later

interface IFraxGaugeFXSRewardsDistributor {
  function acceptOwnership() external;
  function curator_address() external view returns(address);
  function currentReward(address gauge_address) external view returns(uint256 reward_amount);
  function distributeReward(address gauge_address) external returns(uint256 weeks_elapsed, uint256 reward_tally);
  function distributionsOn() external view returns(bool);
  function gauge_whitelist(address) external view returns(bool);
  function is_middleman(address) external view returns(bool);
  function last_time_gauge_paid(address) external view returns(uint256);
  function nominateNewOwner(address _owner) external;
  function nominatedOwner() external view returns(address);
  function owner() external view returns(address);
  function recoverERC20(address tokenAddress, uint256 tokenAmount) external;
  function setCurator(address _new_curator_address) external;
  function setGaugeController(address _gauge_controller_address) external;
  function setGaugeState(address _gauge_address, bool _is_middleman, bool _is_active) external;
  function setTimelock(address _new_timelock) external;
  function timelock_address() external view returns(address);
  function toggleDistributions() external;
}


// File contracts/Curve/IveFXS.sol

// Original license: SPDX_License_Identifier: GPL-2.0-or-later

interface IveFXS {

    struct LockedBalance {
        int128 amount;
        uint256 end;
    }

    function commit_transfer_ownership(address addr) external;
    function apply_transfer_ownership() external;
    function commit_smart_wallet_checker(address addr) external;
    function apply_smart_wallet_checker() external;
    function toggleEmergencyUnlock() external;
    function recoverERC20(address token_addr, uint256 amount) external;
    function get_last_user_slope(address addr) external view returns (int128);
    function user_point_history__ts(address _addr, uint256 _idx) external view returns (uint256);
    function locked__end(address _addr) external view returns (uint256);
    function checkpoint() external;
    function deposit_for(address _addr, uint256 _value) external;
    function create_lock(uint256 _value, uint256 _unlock_time) external;
    function increase_amount(uint256 _value) external;
    function increase_unlock_time(uint256 _unlock_time) external;
    function withdraw() external;
    function balanceOf(address addr) external view returns (uint256);
    function balanceOf(address addr, uint256 _t) external view returns (uint256);
    function balanceOfAt(address addr, uint256 _block) external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function totalSupply(uint256 t) external view returns (uint256);
    function totalSupplyAt(uint256 _block) external view returns (uint256);
    function totalFXSSupply() external view returns (uint256);
    function totalFXSSupplyAt(uint256 _block) external view returns (uint256);
    function changeController(address _newController) external;
    function token() external view returns (address);
    function supply() external view returns (uint256);
    function locked(address addr) external view returns (LockedBalance memory);
    function epoch() external view returns (uint256);
    function point_history(uint256 arg0) external view returns (int128 bias, int128 slope, uint256 ts, uint256 blk, uint256 fxs_amt);
    function user_point_history(address arg0, uint256 arg1) external view returns (int128 bias, int128 slope, uint256 ts, uint256 blk, uint256 fxs_amt);
    function user_point_epoch(address arg0) external view returns (uint256);
    function slope_changes(uint256 arg0) external view returns (int128);
    function controller() external view returns (address);
    function transfersEnabled() external view returns (bool);
    function emergencyUnlockActive() external view returns (bool);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function version() external view returns (string memory);
    function decimals() external view returns (uint256);
    function future_smart_wallet_checker() external view returns (address);
    function smart_wallet_checker() external view returns (address);
    function admin() external view returns (address);
    function future_admin() external view returns (address);
}


// File contracts/Math/Math.sol

// Original license: SPDX_License_Identifier: MIT

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}


// File contracts/Misc_AMOs/convex/IConvexBaseRewardPool.sol

// Original license: SPDX_License_Identifier: GPL-2.0-or-later

interface IConvexBaseRewardPool {
  function addExtraReward(address _reward) external returns (bool);
  function balanceOf(address account) external view returns (uint256);
  function clearExtraRewards() external;
  function currentRewards() external view returns (uint256);
  function donate(uint256 _amount) external returns (bool);
  function duration() external view returns (uint256);
  function earned(address account) external view returns (uint256);
  function extraRewards(uint256) external view returns (address);
  function extraRewardsLength() external view returns (uint256);
  function getReward() external returns (bool);
  function getReward(address _account, bool _claimExtras) external returns (bool);
  function historicalRewards() external view returns (uint256);
  function lastTimeRewardApplicable() external view returns (uint256);
  function lastUpdateTime() external view returns (uint256);
  function newRewardRatio() external view returns (uint256);
  function operator() external view returns (address);
  function periodFinish() external view returns (uint256);
  function pid() external view returns (uint256);
  function queueNewRewards(uint256 _rewards) external returns (bool);
  function queuedRewards() external view returns (uint256);
  function rewardManager() external view returns (address);
  function rewardPerToken() external view returns (uint256);
  function rewardPerTokenStored() external view returns (uint256);
  function rewardRate() external view returns (uint256);
  function rewardToken() external view returns (address);
  function rewards(address) external view returns (uint256);
  function stake(uint256 _amount) external returns (bool);
  function stakeAll() external returns (bool);
  function stakeFor(address _for, uint256 _amount) external returns (bool);
  function stakingToken() external view returns (address);
  function totalSupply() external view returns (uint256);
  function userRewardPerTokenPaid(address) external view returns (uint256);
  function withdraw(uint256 amount, bool claim) external returns (bool);
  function withdrawAll(bool claim) external;
  function withdrawAllAndUnwrap(bool claim) external;
  function withdrawAndUnwrap(uint256 amount, bool claim) external returns (bool);
}


// File contracts/Staking/Owned.sol

// Original license: SPDX_License_Identifier: GPL-2.0-or-later

// https://docs.synthetix.io/contracts/Owned
contract Owned {
    address public owner;
    address public nominatedOwner;

    constructor (address _owner) public {
        require(_owner != address(0), "Owner address cannot be 0");
        owner = _owner;
        emit OwnerChanged(address(0), _owner);
    }

    function nominateNewOwner(address _owner) external onlyOwner {
        nominatedOwner = _owner;
        emit OwnerNominated(_owner);
    }

    function acceptOwnership() external {
        require(msg.sender == nominatedOwner, "You must be nominated before you can accept ownership");
        emit OwnerChanged(owner, nominatedOwner);
        owner = nominatedOwner;
        nominatedOwner = address(0);
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Only the contract owner may perform this action");
        _;
    }

    event OwnerNominated(address newOwner);
    event OwnerChanged(address oldOwner, address newOwner);
}


// File contracts/Uniswap/TransferHelper.sol

// Original license: SPDX_License_Identifier: MIT

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}


// File contracts/Utils/ReentrancyGuard.sol

// Original license: SPDX_License_Identifier: MIT

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
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}


// File contracts/Staking/FraxUnifiedFarmTemplate.sol

// Original license: SPDX_License_Identifier: GPL-2.0-or-later

// ====================================================================
// |     ______                   _______                             |
// |    / _____________ __  __   / ____(_____  ____ _____  ________   |
// |   / /_  / ___/ __ `| |/_/  / /_  / / __ \/ __ `/ __ \/ ___/ _ \  |
// |  / __/ / /  / /_/ _>  <   / __/ / / / / / /_/ / / / / /__/  __/  |
// | /_/   /_/   \__,_/_/|_|  /_/   /_/_/ /_/\__,_/_/ /_/\___/\___/   |
// |                                                                  |
// ====================================================================
// ====================== FraxUnifiedFarmTemplate =====================
// ====================================================================
// Farming contract that accounts for veFXS
// Overrideable for UniV3, ERC20s, etc
// New for V2
//      - Multiple reward tokens possible
//      - Can add to existing locked stakes
//      - Contract is aware of proxied veFXS
//      - veFXS multiplier formula changed
// Apes together strong

// Frax Finance: https://github.com/FraxFinance

// Primary Author(s)
// Travis Moore: https://github.com/FortisFortuna

// Reviewer(s) / Contributor(s)
// Jason Huan: https://github.com/jasonhuan
// Sam Kazemian: https://github.com/samkazemian
// Dennis: github.com/denett

// Originally inspired by Synthetix.io, but heavily modified by the Frax team
// (Locked, veFXS, and UniV3 portions are new)
// https://raw.githubusercontent.com/Synthetixio/synthetix/develop/contracts/StakingRewards.sol








// Extra rewards
// Balancer
// ====================
// import "../Misc_AMOs/balancer/IAuraDeposit.sol";
// import "../Misc_AMOs/balancer/IAuraDepositVault.sol";

// BUNNI
// ====================
// import "../Misc_AMOs/bunni/IBunniGauge.sol";
// import "../Misc_AMOs/bunni/IBunniLens.sol";
// import "../Misc_AMOs/bunni/IBunniMinter.sol";

// CONVEX
// ====================

contract FraxUnifiedFarmTemplate is Owned, ReentrancyGuard {


    // -------------------- VARIES --------------------

    // Balancer
    // IAuraDeposit public stakingToken;
    // IAuraDepositVault public aura_deposit_vault = IAuraDepositVault(0xE557658e3D13d074961265756dC2eFB6c903A763);

    // Bunni
    // IBunniGauge public stakingToken;
    // IBunniLens public lens = IBunniLens(0xb73F303472C4fD4FF3B9f59ce0F9b13E47fbfD19);
    // IBunniMinter public minter = IBunniMinter(0xF087521Ffca0Fa8A43F5C445773aB37C5f574DA0);

    /* ========== STATE VARIABLES ========== */

    // Instances
    IveFXS private constant veFXS = IveFXS(0xc8418aF6358FFddA74e09Ca9CC3Fe03Ca6aDC5b0);
    
    // Frax related
    address internal constant frax_address = 0x853d955aCEf822Db058eb8505911ED77F175b99e;
    /// @notice fraxPerLPToken is a public view function, although doesn't show the stored value
    uint256 public fraxPerLPStored;

    // Constant for various precisions
    uint256 internal constant MULTIPLIER_PRECISION = 1e18;

    // Time tracking
    /// @notice Ending timestamp for the current period
    uint256 public periodFinish;
    /// @notice Timestamp of the last update - when this period started
    uint256 public lastUpdateTime;

    // Lock time and multiplier settings
    uint256 public lock_max_multiplier = uint256(2e18); // E18. 1x = e18
    uint256 public lock_time_for_max_multiplier = 1 * 1095 * 86400; // 3 years
    // uint256 public lock_time_for_max_multiplier = 2 * 86400; // 2 days
    uint256 public lock_time_min = 1; // 1 seconds. If 0, calcCurrLockMultiplier could div by 0

    // veFXS related
    uint256 public vefxs_boost_scale_factor = uint256(4e18); // E18. 4x = 4e18; 100 / scale_factor = % vefxs supply needed for max boost
    uint256 public vefxs_max_multiplier = uint256(2e18); // E18. 1x = 1e18
    uint256 public vefxs_per_frax_for_max_boost = uint256(4e18); // E18. 2e18 means 2 veFXS must be held by the staker per 1 FRAX
    mapping(address => uint256) internal _vefxsMultiplierStored;
    mapping(address => bool) internal valid_vefxs_proxies;
    mapping(address => mapping(address => bool)) internal proxy_allowed_stakers;

    // Reward addresses, gauge addresses, reward rates, and reward managers
    /// @notice token addr -> manager addr
    mapping(address => address) public rewardManagers; 
    address[] internal rewardTokens;
    address[] internal gaugeControllers;
    address[] internal rewardDistributors;
    uint256[] internal rewardRatesManual;
    mapping(address => bool) internal isRewardToken;
    /// @notice token addr -> token index
    mapping(address => uint256) public rewardTokenAddrToIdx;
    
    // Reward period
    uint256 public constant rewardsDuration = 604800; // 7 * 86400  (7 days)

    // Reward tracking
    uint256[] private rewardsPerTokenStored;
    mapping(address => mapping(uint256 => uint256)) private userRewardsPerTokenPaid; // staker addr -> token id -> paid amount
    mapping(address => mapping(uint256 => uint256)) private rewards; // staker addr -> token id -> reward amount
    mapping(address => uint256) public lastRewardClaimTime; // staker addr -> timestamp
    
    // Gauge tracking
    uint256[] private last_gauge_relative_weights;
    uint256[] private last_gauge_time_totals;

    // Balance tracking
    uint256 internal _total_liquidity_locked;
    uint256 internal _total_combined_weight;
    mapping(address => uint256) internal _locked_liquidity;
    mapping(address => uint256) internal _combined_weights;
    /// @notice Keeps track of LP balances proxy-wide. Needed to make sure the proxy boost is kept in line
    mapping(address => uint256) public proxy_lp_balances; 


    /// @notice Stakers set which proxy(s) they want to use
    /// @dev Keep public so users can see on the frontend if they have a proxy
    mapping(address => address) public staker_designated_proxies;

    // Admin booleans for emergencies and overrides
    bool public stakesUnlocked; // Release locked stakes in case of emergency
    bool internal withdrawalsPaused; // For emergencies
    bool internal rewardsCollectionPaused; // For emergencies
    bool internal stakingPaused; // For emergencies

    // For emergencies if a token is overemitted or something else. Only callable once.
    // Bypasses certain logic, which will cause reward calculations to be off
    // But the goal is for the users to recover LP, and they couldn't claim the erroneous rewards anyways.
    // Reward reimbursement claims would be handled with pre-issue earned() snapshots and a claim contract, or similar.
    bool public withdrawalOnlyShutdown; 

    // Version
    string public version = "1.0.6";

    /* ========== STRUCTS ========== */
    // In children...


    /* ========== MODIFIERS ========== */

    modifier onlyByOwnGov() {
        require(msg.sender == owner || msg.sender == 0x8412ebf45bAC1B340BbE8F318b928C466c4E39CA, "Not owner or timelock");
        _;
    }

    modifier onlyTknMgrs(address reward_token_address) {
        require(msg.sender == owner || isTokenManagerFor(msg.sender, reward_token_address), "Not owner or tkn mgr");
        _;
    }

    modifier updateRewardAndBalanceMdf(address account, bool sync_too) {
        _updateRewardAndBalance(account, sync_too, false);
        _;
    }

    /* ========== CONSTRUCTOR ========== */

    constructor (
        address _owner,
        address[] memory _rewardTokens,
        address[] memory _rewardManagers,
        uint256[] memory _rewardRatesManual,
        address[] memory _gaugeControllers,
        address[] memory _rewardDistributors
    ) Owned(_owner) {

        // Address arrays
        rewardTokens = _rewardTokens;
        gaugeControllers = _gaugeControllers;
        rewardDistributors = _rewardDistributors;
        rewardRatesManual = _rewardRatesManual;

        for (uint256 i = 0; i < _rewardTokens.length; i++){ 
            // For fast token address -> token ID lookups later
            rewardTokenAddrToIdx[_rewardTokens[i]] = i;

            // Add to the mapping
            isRewardToken[_rewardTokens[i]] = true;

            // Initialize the stored rewards
            rewardsPerTokenStored.push(0);

            // Initialize the reward managers
            rewardManagers[_rewardTokens[i]] = _rewardManagers[i];

            // Push in empty relative weights to initialize the array
            last_gauge_relative_weights.push(0);

            // Push in empty time totals to initialize the array
            last_gauge_time_totals.push(0);
        }

        // Other booleans
        stakesUnlocked = false;

        // Initialization
        lastUpdateTime = block.timestamp;

        // Sync the first period finish here with the gauge's 
        // periodFinish = IFraxGaugeController(gaugeControllers[0]).time_total();
        periodFinish = IFraxGaugeController(0x3669C421b77340B2979d1A00a792CC2ee0FcE737).time_total();
        
    }

    /* ============= VIEWS ============= */

    // ------ REWARD RELATED ------

    /// @notice Checks if the caller is a manager for the reward token
    /// @param caller_addr The address of the caller
    /// @param reward_token_addr The address of the reward token
    /// @return bool True if the caller is a manager for the reward token
    function isTokenManagerFor(address caller_addr, address reward_token_addr) public view returns (bool){
        if (!isRewardToken[reward_token_addr]) return false;
        else if (caller_addr == address(0) || reward_token_addr == address(0)) return false;
        else if (caller_addr == owner) return true; // Contract owner
        else if (rewardManagers[reward_token_addr] == caller_addr) return true; // Reward manager
        return false; 
    }

    /// @notice Gets all the reward tokens this contract handles
    /// @return rewardTokens_ The reward tokens array
    function getAllRewardTokens() external view returns (address[] memory) {
        return rewardTokens;
    }

    // Last time the reward was applicable
    function lastTimeRewardApplicable() internal view returns (uint256) {
        return Math.min(block.timestamp, periodFinish);
    }

    /// @notice The amount of reward tokens being paid out per second this period
    /// @param token_idx The index of the reward token
    /// @return rwd_rate The reward rate
    function rewardRates(uint256 token_idx) public view returns (uint256 rwd_rate) {
        address gauge_controller_address = gaugeControllers[token_idx];
        if (gauge_controller_address != address(0)) {
            rwd_rate = (IFraxGaugeController(gauge_controller_address).global_emission_rate() * last_gauge_relative_weights[token_idx]) / 1e18;
        }
        else {
            rwd_rate = rewardRatesManual[token_idx];
        }
    }

    // Amount of reward tokens per LP token / liquidity unit
    function rewardsPerToken() public view returns (uint256[] memory newRewardsPerTokenStored) {
        if (_total_liquidity_locked == 0 || _total_combined_weight == 0) {
            return rewardsPerTokenStored;
        }
        else {
            newRewardsPerTokenStored = new uint256[](rewardTokens.length);
            for (uint256 i = 0; i < rewardsPerTokenStored.length; i++){ 
                newRewardsPerTokenStored[i] = rewardsPerTokenStored[i] + (
                    ((lastTimeRewardApplicable() - lastUpdateTime) * rewardRates(i) * 1e18) / _total_combined_weight
                );
            }
            return newRewardsPerTokenStored;
        }
    }

    /// @notice The amount of reward tokens an account has earned / accrued
    /// @dev In the edge-case of one of the account's stake expiring since the last claim, this will
    /// @param account The account to check
    /// @return new_earned Array of reward token amounts earned by the account
    function earned(address account) public view returns (uint256[] memory new_earned) {
        uint256[] memory reward_arr = rewardsPerToken();
        new_earned = new uint256[](rewardTokens.length);

        if (_combined_weights[account] > 0){
            for (uint256 i = 0; i < rewardTokens.length; i++){ 
                new_earned[i] = ((_combined_weights[account] * (reward_arr[i] - userRewardsPerTokenPaid[account][i])) / 1e18)
                                + rewards[account][i];
            }
        }
    }

    /// @notice The total reward tokens emitted in the given period
    /// @return rewards_per_duration_arr Array of reward token amounts emitted in the current period
    function getRewardForDuration() external view returns (uint256[] memory rewards_per_duration_arr) {
        rewards_per_duration_arr = new uint256[](rewardRatesManual.length);

        for (uint256 i = 0; i < rewardRatesManual.length; i++){ 
            rewards_per_duration_arr[i] = rewardRates(i) * rewardsDuration;
        }
    }


    // ------ LIQUIDITY AND WEIGHTS ------

    /// @notice The farm's total locked liquidity / LP tokens
    /// @return The total locked liquidity
    function totalLiquidityLocked() external view returns (uint256) {
        return _total_liquidity_locked;
    }

    /// @notice A user's locked liquidity / LP tokens
    /// @param account The address of the account
    /// @return The locked liquidity
    function lockedLiquidityOf(address account) external view returns (uint256) {
        return _locked_liquidity[account];
    }

    /// @notice The farm's total combined weight of all users
    /// @return The total combined weight
    function totalCombinedWeight() external view returns (uint256) {
        return _total_combined_weight;
    }

    /// @notice Total 'balance' used for calculating the percent of the pool the account owns
    /// @notice Takes into account the locked stake time multiplier and veFXS multiplier
    /// @param account The address of the account
    /// @return The combined weight
    function combinedWeightOf(address account) external view returns (uint256) {
        return _combined_weights[account];
    }

    /// @notice Calculates the combined weight for an account
    /// @notice Must be overriden by the child contract
    /// @dev account The address of the account
    function calcCurCombinedWeight(address account) public virtual view 
        returns (
            uint256 old_combined_weight,
            uint256 new_vefxs_multiplier,
            uint256 new_combined_weight
        )
    {
        revert("Need cCCW logic");
    }

    // ------ LOCK RELATED ------

    /// @notice Reads the lock boost multiplier for a given duration
    /// @param secs The duration of the lock in seconds
    /// @return The multiplier amount
    function lockMultiplier(uint256 secs) public view returns (uint256) {
        return Math.min(
            lock_max_multiplier,
            (secs * lock_max_multiplier) / lock_time_for_max_multiplier
        ) ;
    }

    // ------ FRAX RELATED ------

    /// @notice The amount of FRAX denominated value being boosted that an address has staked
    /// @param account The address to check
    /// @return The amount of FRAX value boosted
    function userStakedFrax(address account) public view returns (uint256) {
        return (fraxPerLPStored * _locked_liquidity[account]) / MULTIPLIER_PRECISION;
    }

    /// @notice The amount of FRAX denominated value being boosted that a proxy address has staked
    /// @param proxy_address The address to check
    /// @return The amount of FRAX value boosted
    function proxyStakedFrax(address proxy_address) public view returns (uint256) {
        return (fraxPerLPStored * proxy_lp_balances[proxy_address]) / MULTIPLIER_PRECISION;
    }

    /// @notice The maximum LP that can get max veFXS boosted for a given address at its current veFXS balance
    /// @param account The address to check
    /// @return The maximum LP that can get max veFXS boosted for a given address at its current veFXS balance
    function maxLPForMaxBoost(address account) external view returns (uint256) {
        return (veFXS.balanceOf(account) * MULTIPLIER_PRECISION * MULTIPLIER_PRECISION) / (vefxs_per_frax_for_max_boost * fraxPerLPStored);
    }

    /// @notice Must be overriden to return the current FRAX per LP token
    /// @return The current number of FRAX per LP token
    function fraxPerLPToken() public virtual view returns (uint256) {
        revert("Need fPLPT logic");
    }

    // ------ veFXS RELATED ------

    /// @notice The minimum veFXS required to get max boost for a given address
    /// @param account The address to check
    /// @return The minimum veFXS required to get max boost
    function minVeFXSForMaxBoost(address account) public view returns (uint256) {
        return (userStakedFrax(account) * vefxs_per_frax_for_max_boost) / MULTIPLIER_PRECISION;
    }

    /// @notice The minimum veFXS required to get max boost for a given proxy
    /// @param proxy_address The proxy address
    /// @return The minimum veFXS required to get max boost
    function minVeFXSForMaxBoostProxy(address proxy_address) public view returns (uint256) {
        return (proxyStakedFrax(proxy_address) * vefxs_per_frax_for_max_boost) / MULTIPLIER_PRECISION;
    }

    /// @notice Looks up a staker's proxy
    /// @param addr The address to check
    /// @return the_proxy The proxy address, or address(0)
    function getProxyFor(address addr) public view returns (address){
        if (valid_vefxs_proxies[addr]) {
            // If addr itself is a proxy, return that.
            // If it farms itself directly, it should use the shared LP tally in proxyStakedFrax
            return addr;
        }
        else {
            // Otherwise, return the proxy, or address(0)
            return staker_designated_proxies[addr];
        }
    }

    /// @notice The multiplier for a given account, based on veFXS
    /// @param account The account to check
    /// @return vefxs_multiplier The multiplier boost for the account
    function veFXSMultiplier(address account) public view returns (uint256 vefxs_multiplier) {
        // Use either the user's or their proxy's veFXS balance
        uint256 vefxs_bal_to_use = 0;
        address the_proxy = getProxyFor(account);
        vefxs_bal_to_use = (the_proxy == address(0)) ? veFXS.balanceOf(account) : veFXS.balanceOf(the_proxy);

        // First option based on fraction of total veFXS supply, with an added scale factor
        uint256 mult_optn_1 = (vefxs_bal_to_use * vefxs_max_multiplier * vefxs_boost_scale_factor) 
                            / (veFXS.totalSupply() * MULTIPLIER_PRECISION);
        
        // Second based on old method, where the amount of FRAX staked comes into play
        uint256 mult_optn_2;
        {
            uint256 veFXS_needed_for_max_boost;

            // Need to use proxy-wide FRAX balance if applicable, to prevent exploiting
            veFXS_needed_for_max_boost = (the_proxy == address(0)) ? minVeFXSForMaxBoost(account) : minVeFXSForMaxBoostProxy(the_proxy);

            if (veFXS_needed_for_max_boost > 0){ 
                uint256 user_vefxs_fraction = (vefxs_bal_to_use * MULTIPLIER_PRECISION) / veFXS_needed_for_max_boost;
                
                mult_optn_2 = (user_vefxs_fraction * vefxs_max_multiplier) / MULTIPLIER_PRECISION;
            }
            else mult_optn_2 = 0; // This will happen with the first stake, when user_staked_frax is 0
        }

        // Select the higher of the two
        vefxs_multiplier = (mult_optn_1 > mult_optn_2 ? mult_optn_1 : mult_optn_2);

        // Cap the boost to the vefxs_max_multiplier
        if (vefxs_multiplier > vefxs_max_multiplier) vefxs_multiplier = vefxs_max_multiplier;
    }

    /* =============== MUTATIVE FUNCTIONS =============== */

    /// @notice Toggle whether a staker can use the proxy's veFXS balance to boost yields
    /// @notice Proxy must call this first, then the staker must call stakerSetVeFXSProxy
    function proxyToggleStaker(address staker_address) external {
        require(valid_vefxs_proxies[msg.sender], "Invalid proxy");
        proxy_allowed_stakers[msg.sender][staker_address] = !proxy_allowed_stakers[msg.sender][staker_address]; 

        // Disable the staker's set proxy if it was the toggler and is currently on
        if (staker_designated_proxies[staker_address] == msg.sender){
            staker_designated_proxies[staker_address] = address(0); 

            // Remove the LP as well
            proxy_lp_balances[msg.sender] -= _locked_liquidity[staker_address];
        }
    }

    /// @notice After proxy toggles staker to true, staker must call and confirm this
    /// @param proxy_address The address of the veFXS proxy
    function stakerSetVeFXSProxy(address proxy_address) external {
        require(valid_vefxs_proxies[proxy_address], "Invalid proxy");
        require(proxy_allowed_stakers[proxy_address][msg.sender], "Proxy has not allowed you yet");
        
        // Corner case sanity check to make sure LP isn't double counted
        address old_proxy_addr = staker_designated_proxies[msg.sender];
        if (old_proxy_addr != address(0)) {
            // Remove the LP count from the old proxy
            proxy_lp_balances[old_proxy_addr] -= _locked_liquidity[msg.sender];
        }

        // Set the new proxy
        staker_designated_proxies[msg.sender] = proxy_address; 

        // Add the the LP as well
        proxy_lp_balances[proxy_address] += _locked_liquidity[msg.sender];
    }

    // ------ STAKING ------
    // In children...


    // ------ WITHDRAWING ------
    // In children...


    // ------ REWARDS SYNCING ------

    function _updateRewardAndBalance(address account, bool sync_too) internal {
        _updateRewardAndBalance(account, sync_too, false);
    }

    function _updateRewardAndBalance(address account, bool sync_too, bool pre_sync_vemxstored) internal {
        // Skip certain functions if we are in an emergency shutdown
        if (!withdrawalOnlyShutdown) {
            // Need to retro-adjust some things if the period hasn't been renewed, then start a new one
            if (sync_too){
                sync();
            }
        }
        
        // Used to make sure the veFXS multiplier is correct if a stake is increased, before calcCurCombinedWeight
        if (pre_sync_vemxstored){
            _vefxsMultiplierStored[account] = veFXSMultiplier(account);
        }
        
        if (account != address(0)) {
            // To keep the math correct, the user's combined weight must be recomputed to account for their
            // ever-changing veFXS balance.
            (   
                uint256 old_combined_weight,
                uint256 new_vefxs_multiplier,
                uint256 new_combined_weight
            ) = calcCurCombinedWeight(account);

            // Calculate the earnings first
            if (!withdrawalOnlyShutdown) _syncEarned(account);

            // Update the user's stored veFXS multipliers
            _vefxsMultiplierStored[account] = new_vefxs_multiplier;

            // Update the user's and the global combined weights
            if (new_combined_weight >= old_combined_weight) {
                uint256 weight_diff = new_combined_weight - old_combined_weight;
                _total_combined_weight = _total_combined_weight + weight_diff;
                _combined_weights[account] = old_combined_weight + weight_diff;
            } else {
                uint256 weight_diff = old_combined_weight - new_combined_weight;
                _total_combined_weight = _total_combined_weight - weight_diff;
                _combined_weights[account] = old_combined_weight - weight_diff;
            }

        }
    }

    function _syncEarned(address account) internal {
        if (account != address(0)) {
            // Calculate the earnings
            uint256[] memory earned_arr = earned(account);

            // Update the rewards array
            for (uint256 i = 0; i < earned_arr.length; i++){ 
                rewards[account][i] = earned_arr[i];
            }

            // Update the rewards paid array
            for (uint256 i = 0; i < earned_arr.length; i++){ 
                userRewardsPerTokenPaid[account][i] = rewardsPerTokenStored[i];
            }
        }
    }


    // ------ REWARDS CLAIMING ------

    /// @notice A function that can be overridden to add extra logic to the getReward function
    /// @param destination_address The address to send the rewards to
    function getRewardExtraLogic(address destination_address) public nonReentrant {
        require(!withdrawalOnlyShutdown, "Only withdrawals allowed");
        require(rewardsCollectionPaused == false, "Rewards collection paused");
        return _getRewardExtraLogic(msg.sender, destination_address);
    }

    function _getRewardExtraLogic(address rewardee, address destination_address) internal virtual {
        revert("Need gREL logic");
    }

    // Two different getReward functions are needed because of delegateCall and msg.sender issues
    // For backwards-compatibility
    /// @notice Claims rewards to destination address
    /// @param destination_address The address to send the rewards to
    /// @return rewards_before The rewards available before the claim
    function getReward(address destination_address) external nonReentrant returns (uint256[] memory) {
        return _getReward(msg.sender, destination_address, true);
    }

    /// @notice Claims rewards to destination address & wether to do extra logic
    /// @param destination_address The address to send the rewards to
    /// @param claim_extra_too Whether to do extra logic
    /// @return rewards_before The rewards available before the claim
    function getReward2(address destination_address, bool claim_extra_too) external nonReentrant returns (uint256[] memory) {
        return _getReward(msg.sender, destination_address, claim_extra_too);
    }

    // No withdrawer == msg.sender check needed since this is only internally callable
    function _getReward(address rewardee, address destination_address, bool do_extra_logic) internal updateRewardAndBalanceMdf(rewardee, true) returns (uint256[] memory rewards_before) {
        // Make sure you are not in shutdown
        require(!withdrawalOnlyShutdown, "Only withdrawals allowed");
        
        // Make sure rewards collection isn't paused
        require(rewardsCollectionPaused == false, "Rewards collection paused");

        // Update the last reward claim time first, as an extra reentrancy safeguard
        lastRewardClaimTime[rewardee] = block.timestamp;
        
        // Update the rewards array and distribute rewards
        rewards_before = new uint256[](rewardTokens.length);

        for (uint256 i = 0; i < rewardTokens.length; i++){ 
            rewards_before[i] = rewards[rewardee][i];
            rewards[rewardee][i] = 0;
            if (rewards_before[i] > 0) {
                TransferHelper.safeTransfer(rewardTokens[i], destination_address, rewards_before[i]);

                emit RewardPaid(rewardee, rewards_before[i], rewardTokens[i], destination_address);
            }
        }

        // Handle additional reward logic
        if (do_extra_logic) {
            _getRewardExtraLogic(rewardee, destination_address);
        }
    }


    // ------ FARM SYNCING ------

    // If the period expired, renew it
    function retroCatchUp() internal {
        // Catch up the old rewards first
        _updateStoredRewardsAndTime();

        // Pull in rewards from the rewards distributor, if applicable
        for (uint256 i = 0; i < rewardDistributors.length; i++){ 
            address reward_distributor_address = rewardDistributors[i];
            if (reward_distributor_address != address(0)) {
                IFraxGaugeFXSRewardsDistributor(reward_distributor_address).distributeReward(address(this));
            }
        }

        // Ensure the provided reward amount is not more than the balance in the contract.
        // This keeps the reward rate in the right range, preventing overflows due to
        // very high values of rewardRate in the earned and rewardsPerToken functions;
        // Reward + leftover must be less than 2^256 / 10^18 to avoid overflow.
        uint256 num_periods_elapsed = uint256(block.timestamp - periodFinish) / rewardsDuration; // Floor division to the nearest period
        
        // Make sure there are enough tokens to renew the reward period
        for (uint256 i = 0; i < rewardTokens.length; i++){ 
            require((rewardRates(i) * rewardsDuration * (num_periods_elapsed + 1)) <= IERC20(rewardTokens[i]).balanceOf(address(this)), string(abi.encodePacked("Not enough reward tokens available: ", rewardTokens[i])) );
        }
        
        // uint256 old_lastUpdateTime = lastUpdateTime;
        // uint256 new_lastUpdateTime = block.timestamp;

        // lastUpdateTime = periodFinish;
        periodFinish = periodFinish + ((num_periods_elapsed + 1) * rewardsDuration);

        // Aura & Balancer Gauge Rewards
        // ==========================================
        // Pull in rewards and set the reward rate for one week, based off of that
        // If the rewards get messed up for some reason, set this to 0 and it will skip
        // Should only be called once per week max
        // if (rewardRatesManual[1] != 0) {
        //     // AURA & BAL
        //     // ====================================
        //     uint256 aura_before = IERC20(rewardTokens[1]).balanceOf(address(this));
        //     uint256 bal_before = IERC20(rewardTokens[2]).balanceOf(address(this));
        //     aura_deposit_vault.getReward(address(this), true);
        //     uint256 aura_after = IERC20(rewardTokens[1]).balanceOf(address(this));
        //     uint256 bal_after = IERC20(rewardTokens[2]).balanceOf(address(this));

        //     // Set the new reward rates
        //     rewardRatesManual[1] = (aura_after - aura_before) / rewardsDuration; // AURA
        //     rewardRatesManual[2] = (bal_after - bal_before) / rewardsDuration; // BAL
        // }

        // Bunni oLIT rewards
        // ==========================================
        // Pull in rewards and set the reward rate for one week, based off of that
        // If the rewards get messed up for some reason, set this to 0 and it will skip
        // Should only be called once per week max
        // if (rewardRatesManual[1] != 0) {
        //     // oLIT
        //     // ====================================
        //     uint256 olit_before = IERC20(rewardTokens[1]).balanceOf(address(this));
        //     minter.mint(address(stakingToken));
        //     uint256 olit_after = IERC20(rewardTokens[1]).balanceOf(address(this));

        //     // Set the new reward rate
        //     rewardRatesManual[1] = (olit_after - olit_before) / rewardsDuration;
        // }

        // CONVEX EXTRA REWARDS (OLD METHOD)
        // ==========================================
        // Pull in rewards and set the reward rate for one week, based off of that
        // If the rewards get messed up for some reason, set this to 0 and it will skip
        // if (rewardRatesManual[1] != 0 && rewardRatesManual[2] != 0) {
        //     // CRV & CVX
        //     // ====================================
        //     uint256 crv_before = ERC20(rewardTokens[1]).balanceOf(address(this));
        //     uint256 cvx_before = ERC20(rewardTokens[2]).balanceOf(address(this));
        //     IConvexBaseRewardPool(0x329cb014b562d5d42927cfF0dEdF4c13ab0442EF).getReward(
        //         address(this),
        //         true
        //     );
        //     uint256 crv_after = ERC20(rewardTokens[1]).balanceOf(address(this));
        //     uint256 cvx_after = ERC20(rewardTokens[2]).balanceOf(address(this));

        //     // Set the new reward rate
        //     rewardRatesManual[1] = (crv_after - crv_before) / rewardsDuration;
        //     rewardRatesManual[2] = (cvx_after - cvx_before) / rewardsDuration;
        // }

        // Make sure everything is caught up again
        _updateStoredRewardsAndTime();
    }

    function _updateStoredRewardsAndTime() internal {
        // Get the rewards
        uint256[] memory rewards_per_token = rewardsPerToken();

        // Update the rewardsPerTokenStored
        for (uint256 i = 0; i < rewardsPerTokenStored.length; i++){ 
            rewardsPerTokenStored[i] = rewards_per_token[i];
        }

        // Update the last stored time
        lastUpdateTime = lastTimeRewardApplicable();
    }

    /// @notice Updates the gauge weights, if applicable
    /// @param force_update If true, will update the weights even if the time hasn't elapsed
    function sync_gauge_weights(bool force_update) public {
        // Loop through the gauge controllers
        for (uint256 i = 0; i < gaugeControllers.length; i++){ 
            address gauge_controller_address = gaugeControllers[i];
            if (gauge_controller_address != address(0)) {
                if (force_update || (block.timestamp > last_gauge_time_totals[i])){
                    // Update the gauge_relative_weight
                    last_gauge_relative_weights[i] = IFraxGaugeController(gauge_controller_address).gauge_relative_weight_write(address(this), block.timestamp);
                    last_gauge_time_totals[i] = IFraxGaugeController(gauge_controller_address).time_total();
                }
            }
        }
    }

    /// @notice Updates gauge weights, fraxPerLP, pulls in new rewards or updates rewards
    function sync() public {
        // Make sure you are not in shutdown
        require(!withdrawalOnlyShutdown, "Only withdrawals allowed");

        // Sync the gauge weight, if applicable
        sync_gauge_weights(false);

        // Update the fraxPerLPStored
        fraxPerLPStored = fraxPerLPToken();

        if (block.timestamp >= periodFinish) {
            retroCatchUp();
        }
        else {
            _updateStoredRewardsAndTime();
        }
    }

    /* ========== RESTRICTED FUNCTIONS - Curator callable ========== */
    
    // ------ FARM SYNCING ------
    // In children...

    // ------ PAUSES ------

    /// @notice Owner or governance can pause/unpause staking, withdrawals, rewards collection, and collectRewardsOnWithdrawal
    /// @param _stakingPaused Whether staking is paused
    /// @param _withdrawalsPaused Whether withdrawals are paused
    /// @param _rewardsCollectionPaused Whether rewards collection is paused
    /// @param _withdrawalOnlyShutdown Whether you can only withdraw. Only settable once
    function setPauses(
        bool _stakingPaused,
        bool _withdrawalsPaused,
        bool _rewardsCollectionPaused,
        bool _withdrawalOnlyShutdown
    ) external onlyByOwnGov {
        stakingPaused = _stakingPaused;
        withdrawalsPaused = _withdrawalsPaused;
        rewardsCollectionPaused = _rewardsCollectionPaused;

        // Only settable once. Rewards math will be permanently wrong afterwards, so only use
        // for recovering LP
        if(_withdrawalOnlyShutdown && !withdrawalOnlyShutdown) withdrawalOnlyShutdown = true;
    }

    /* ========== RESTRICTED FUNCTIONS - Owner or timelock only ========== */
    
    /// @notice Owner or governance can unlock stakes - irreversible!
    function unlockStakes() external onlyByOwnGov {
        stakesUnlocked = !stakesUnlocked;
    }

    /// @notice Owner or governance sets whether an address is a valid veFXS proxy
    /// @param _proxy_addr The address to set
    function toggleValidVeFXSProxy(address _proxy_addr) external onlyByOwnGov {
        valid_vefxs_proxies[_proxy_addr] = !valid_vefxs_proxies[_proxy_addr];
    }

    /// @notice Allows owner to recover any ERC20 or token manager to recover their reward token.
    /// @param tokenAddress The address of the token to recover
    /// @param tokenAmount The amount of the token to recover
    function recoverERC20(address tokenAddress, uint256 tokenAmount) external onlyTknMgrs(tokenAddress) {
        // Check if the desired token is a reward token
        bool isRewTkn = isRewardToken[tokenAddress];

        // Only the reward managers can take back their reward tokens
        // Also, other tokens, like the staking token, airdrops, or accidental deposits, can be withdrawn by the owner
        if (
                (isRewTkn && rewardManagers[tokenAddress] == msg.sender)
                || (!isRewTkn && (msg.sender == owner))
            ) {

            // // Aura & Balancer
            // // Withdraw the tokens from the Aura vault. Do not claim
            // // =========================================
            // if (tokenAddress == address(stakingToken)) aura_deposit_vault.withdraw(tokenAmount, false);

            TransferHelper.safeTransfer(tokenAddress, msg.sender, tokenAmount);
            return;
        }
        // If none of the above conditions are true
        else {
            revert("No valid tokens to recover");
        }
    }

    /// @notice Sets multiple variables at once
    /// @param _misc_vars The variables to set:
    /// [0]: uint256 _lock_max_multiplier,
    /// [1] uint256 _vefxs_max_multiplier,
    /// [2] uint256 _vefxs_per_frax_for_max_boost,
    /// [3] uint256 _vefxs_boost_scale_factor,
    /// [4] uint256 _lock_time_for_max_multiplier,
    /// [5] uint256 _lock_time_min
    /// [6] uint256 _max_stake_limit (must be at greater or equal to old value)
    function setMiscVariables(
        uint256[6] memory _misc_vars
        // [0]: uint256 _lock_max_multiplier, 
        // [1] uint256 _vefxs_max_multiplier, 
        // [2] uint256 _vefxs_per_frax_for_max_boost,
        // [3] uint256 _vefxs_boost_scale_factor,
        // [4] uint256 _lock_time_for_max_multiplier,
        // [5] uint256 _lock_time_min
    ) external onlyByOwnGov {
        require(_misc_vars[0] >= MULTIPLIER_PRECISION, "Must be >= MUL PREC");
        require((_misc_vars[1] >= 0) && (_misc_vars[2] >= 0) && (_misc_vars[3] >= 0), "Must be >= 0");
        require((_misc_vars[4] >= 1) && (_misc_vars[5] >= 1), "Must be >= 1");

        lock_max_multiplier = _misc_vars[0];
        vefxs_max_multiplier = _misc_vars[1];
        vefxs_per_frax_for_max_boost = _misc_vars[2];
        vefxs_boost_scale_factor = _misc_vars[3];
        lock_time_for_max_multiplier = _misc_vars[4];
        lock_time_min = _misc_vars[5];
    }

    // The owner or the reward token managers can set reward rates 
        /// @notice Allows owner or reward token managers to set the reward rate for a given reward token
    /// @param reward_token_address The address of the reward token
    /// @param _new_rate The new reward rate (token amount divided by reward period duration)
    /// @param _gauge_controller_address The address of the gauge controller for this reward token
    /// @param _rewards_distributor_address The address of the rewards distributor for this reward token
    function setRewardVars(address reward_token_address, uint256 _new_rate, address _gauge_controller_address, address _rewards_distributor_address) external onlyTknMgrs(reward_token_address) {
        rewardRatesManual[rewardTokenAddrToIdx[reward_token_address]] = _new_rate;
        gaugeControllers[rewardTokenAddrToIdx[reward_token_address]] = _gauge_controller_address;
        rewardDistributors[rewardTokenAddrToIdx[reward_token_address]] = _rewards_distributor_address;
    }

    // The owner or the reward token managers can change managers
    /// @notice Allows owner or reward token managers to change the reward manager for a given reward token
    /// @param reward_token_address The address of the reward token
    /// @param new_manager_address The new reward manager address
    function changeTokenManager(address reward_token_address, address new_manager_address) external onlyTknMgrs(reward_token_address) {
        rewardManagers[reward_token_address] = new_manager_address;
    }

    /* ========== EVENTS ========== */
    event RewardPaid(address indexed user, uint256 amount, address token_address, address destination_address);

    /* ========== A CHICKEN ========== */
    //
    //         ,~.
    //      ,-'__ `-,
    //     {,-'  `. }              ,')
    //    ,( a )   `-.__         ,',')~,
    //   <=.) (         `-.__,==' ' ' '}
    //     (   )                      /)
    //      `-'\   ,                    )
    //          |  \        `~.        /
    //          \   `._        \      /
    //           \     `._____,'    ,'
    //            `-.             ,'
    //               `-._     _,-'
    //                   77jj'
    //                  //_||
    //               __//--'/`
    //             ,--'/`  '
    //
    // [hjw] https://textart.io/art/vw6Sa3iwqIRGkZsN1BC2vweF/chicken
}


// File contracts/Staking/FraxUnifiedFarm_ERC20.sol

// Original license: SPDX_License_Identifier: GPL-2.0-or-later

// ====================================================================
// |     ______                   _______                             |
// |    / _____________ __  __   / ____(_____  ____ _____  ________   |
// |   / /_  / ___/ __ `| |/_/  / /_  / / __ \/ __ `/ __ \/ ___/ _ \  |
// |  / __/ / /  / /_/ _>  <   / __/ / / / / / /_/ / / / / /__/  __/  |
// | /_/   /_/   \__,_/_/|_|  /_/   /_/_/ /_/\__,_/_/ /_/\___/\___/   |
// |                                                                  |
// ====================================================================
// ======================= FraxUnifiedFarm_ERC20 ======================
// ====================================================================
// For ERC20 Tokens
// Uses FraxUnifiedFarmTemplate.sol

// -------------------- VARIES --------------------

// Balancer
// import "../Misc_AMOs/balancer/IBalancerGauge.sol";

// Bunni
// import "../Misc_AMOs/bunni/IBunniGauge.sol";

// Convex wrappers
// import "../Curve/ICurvefrxETHETHPool.sol";

// import "../Misc_AMOs/convex/IDepositToken.sol";
// import "../Misc_AMOs/curve/I2pool.sol";
// import "../Misc_AMOs/curve/I2poolToken.sol";
// import "../Misc_AMOs/curve/I2poolTokenNoLending.sol";
// import "../Misc_AMOs/curve/ICurveStableSwapNG.sol";

// import "../Misc_AMOs/curve/ICurveTricryptoOptimizedWETH.sol";

// Convex FXB
// import "../Misc_AMOs/curve/ICurveStableSwapNG.sol";
// import '../FXB/IFXB.sol';

// Fraxlend
// import '../Fraxlend/IFraxlendPair.sol';

// Fraxswap
// import '../Fraxswap/core/interfaces/IFraxswapPair.sol';

// G-UNI
// import "../Misc_AMOs/gelato/IGUniPool.sol";

// KyberSwap Elastic KyberSwapFarmingToken (KS-FT)
// import "../Misc_AMOs/kyberswap/elastic/IKyberSwapFarmingToken.sol";

// mStable
// import '../Misc_AMOs/mstable/IFeederPool.sol';

// StakeDAO sdETH-FraxPut
// import '../Misc_AMOs/stakedao/IOpynPerpVault.sol';

// StakeDAO Vault
// import '../Misc_AMOs/stakedao/IStakeDaoVault.sol';

// Uniswap V2
// import '../Uniswap/Interfaces/IUniswapV2Pair.sol';

// Vesper
// import '../Misc_AMOs/vesper/IVPool.sol';

// ------------------------------------------------

contract FraxUnifiedFarm_ERC20 is FraxUnifiedFarmTemplate {

    /* ========== STATE VARIABLES ========== */

    // -------------------- COMMON -------------------- 
    bool internal frax_is_token0;

    // -------------------- VARIES --------------------

    // Bunni
    // Declared in FraxUnifiedFarmTemplate.sol

    // Balancer
    // Declared in FraxUnifiedFarmTemplate.sol

    // Convex crvUSD/FRAX
    IConvexStakingWrapperFrax public stakingToken;
    // I2poolTokenNoLending public curveToken;
    // ICurvefrxETHETHPool public curvePool;

    // Convex stkcvxFPIFRAX, stkcvxFRAXBP, etc
    // IConvexStakingWrapperFrax public stakingToken;
    // I2poolToken public curveToken;
    // ICurveStableSwapNG public curveToken;
    ICurveStableSwapMetaNG public curveToken;
    // ICurveTricryptoOptimizedWETH public curveToken;
    // I2pool public curvePool;
    // ICurvefrxETHETHPool public curvePool;
    // ICurveStableSwapNG public curvePool;
    ICurveStableSwapMetaNG public curvePool;
    // ICurveTricryptoOptimizedWETH public curvePool;

    // Fraxswap
    // IFraxswapPair public stakingToken;

    // Fraxlend
    // IFraxlendPair public stakingToken;

    // G-UNI
    // IGUniPool public stakingToken;

    // KyberSwap Elastic KyberSwapFarmingToken (KS-FT)
    // IKyberSwapFarmingToken public stakingToken;
    
    // mStable
    // IFeederPool public stakingToken;

    // sdETH-FraxPut Vault
    // IOpynPerpVault public stakingToken;

    // StakeDAO Vault
    // IStakeDaoVault public stakingToken;

    // Uniswap V2
    // IUniswapV2Pair public stakingToken;

    // Vesper
    // IVPool public stakingToken;

    // ------------------------------------------------

    // Stake tracking
    mapping(address => LockedStake[]) public lockedStakes;

    /* ========== STRUCTS ========== */

    // Struct for the stake
    struct LockedStake {
        bytes32 kek_id;
        uint256 start_timestamp;
        uint256 liquidity;
        uint256 ending_timestamp;
        uint256 lock_multiplier; // 6 decimals of precision. 1x = 1000000
    }
    
    /* ========== CONSTRUCTOR ========== */

    constructor (
        address _owner,
        address[] memory _rewardTokens,
        address[] memory _rewardManagers,
        uint256[] memory _rewardRatesManual,
        address[] memory _gaugeControllers,
        address[] memory _rewardDistributors,
        address _stakingToken
    ) 
    FraxUnifiedFarmTemplate(_owner, _rewardTokens, _rewardManagers, _rewardRatesManual, _gaugeControllers, _rewardDistributors)
    {

        // -------------------- VARIES (USE CHILD FOR LOGIC) --------------------

        // Bunni
        // USE CHILD

        // Convex stkcvxFPIFRAX, stkcvxFRAXBP, etc
        // USE CHILD

        // Fraxlend
        // USE CHILD

        // Fraxswap
        // USE CHILD

        // G-UNI
        // stakingToken = IGUniPool(_stakingToken);
        // address token0 = address(stakingToken.token0());
        // frax_is_token0 = (token0 == frax_address);

        // KyberSwap Elastic KyberSwapFarmingToken (KS-FT)
        // stakingToken = IKyberSwapFarmingToken(_stakingToken);

        // mStable
        // stakingToken = IFeederPool(_stakingToken);

        // StakeDAO sdETH-FraxPut Vault
        // stakingToken = IOpynPerpVault(_stakingToken);

        // StakeDAO Vault
        // stakingToken = IStakeDaoVault(_stakingToken);

        // Uniswap V2
        // stakingToken = IUniswapV2Pair(_stakingToken);
        // address token0 = stakingToken.token0();
        // if (token0 == frax_address) frax_is_token0 = true;
        // else frax_is_token0 = false;

        // Vesper
        // stakingToken = IVPool(_stakingToken);
    }

    /* ============= VIEWS ============= */

    // ------ FRAX RELATED ------

    function fraxPerLPToken() public virtual view override returns (uint256) {
        // Get the amount of FRAX 'inside' of the lp tokens
        uint256 frax_per_lp_token;

        // Balancer
        // ============================================
        // USE CHILD

        // Bunni
        // ============================================
        // USE CHILD

        // Convex stkcvxFPIFRAX and stkcvxFRAXBP only
        // ============================================
        // USE CHILD

        // Convex Stable/FRAXBP
        // ============================================
        // USE CHILD

        // Convex Volatile/FRAXBP
        // ============================================
        // USE CHILD

        // Fraxlend
        // ============================================
        // USE CHILD

        // Fraxswap
        // ============================================
        // USE CHILD

        // G-UNI
        // ============================================
        // {
        //     (uint256 reserve0, uint256 reserve1) = stakingToken.getUnderlyingBalances();
        //     uint256 total_frax_reserves = frax_is_token0 ? reserve0 : reserve1;

        //     frax_per_lp_token = (total_frax_reserves * 1e18) / stakingToken.totalSupply();
        // }

        // KyberSwap Elastic KyberSwapFarmingToken (KS-FT)
        // ============================================
        // USE CHILD

        // mStable
        // ============================================
        // {
        //     uint256 total_frax_reserves;
        //     (, IFeederPool.BassetData memory vaultData) = (stakingToken.getBasset(frax_address));
        //     total_frax_reserves = uint256(vaultData.vaultBalance);
        //     frax_per_lp_token = (total_frax_reserves * 1e18) / stakingToken.totalSupply();
        // }

        // StakeDAO sdETH-FraxPut Vault
        // ============================================
        // {
        //    uint256 frax3crv_held = stakingToken.totalUnderlyingControlled();
        
        //    // Optimistically assume 50/50 FRAX/3CRV ratio in the metapool to save gas
        //    frax_per_lp_token = ((frax3crv_held * 1e18) / stakingToken.totalSupply()) / 2;
        // }

        // StakeDAO Vault
        // ============================================
        // {
        //    uint256 frax3crv_held = stakingToken.balance();
        
        //    // Optimistically assume 50/50 FRAX/3CRV ratio in the metapool to save gas
        //    frax_per_lp_token = ((frax3crv_held * 1e18) / stakingToken.totalSupply()) / 2;
        // }

        // Uniswap V2
        // ============================================
        // {
        //     uint256 total_frax_reserves;
        //     (uint256 reserve0, uint256 reserve1, ) = (stakingToken.getReserves());
        //     if (frax_is_token0) total_frax_reserves = reserve0;
        //     else total_frax_reserves = reserve1;

        //     frax_per_lp_token = (total_frax_reserves * 1e18) / stakingToken.totalSupply();
        // }

        // Vesper
        // ============================================
        // frax_per_lp_token = stakingToken.pricePerShare();

        return frax_per_lp_token;
    }

    // ------ LIQUIDITY AND WEIGHTS ------
    function calcCurrLockMultiplier(address account, uint256 stake_idx) public view returns (uint256 midpoint_lock_multiplier) {
        // Get the stake
        LockedStake memory thisStake = lockedStakes[account][stake_idx];

        // Handles corner case where user never claims for a new stake
        // Don't want the multiplier going above the max
        uint256 accrue_start_time;
        if (lastRewardClaimTime[account] < thisStake.start_timestamp) {
            accrue_start_time = thisStake.start_timestamp;
        }
        else {
            accrue_start_time = lastRewardClaimTime[account];
        }
        
        // If the lock is expired
        if (thisStake.ending_timestamp <= block.timestamp) {
            // If the lock expired in the time since the last claim, the weight needs to be proportionately averaged this time
            if (lastRewardClaimTime[account] < thisStake.ending_timestamp){
                uint256 time_before_expiry = thisStake.ending_timestamp - accrue_start_time;
                uint256 time_after_expiry = block.timestamp - thisStake.ending_timestamp;

                // Average the pre-expiry lock multiplier
                uint256 pre_expiry_avg_multiplier = lockMultiplier(time_before_expiry / 2);

                // Get the weighted-average lock_multiplier
                // uint256 numerator = (pre_expiry_avg_multiplier * time_before_expiry) + (MULTIPLIER_PRECISION * time_after_expiry);
                uint256 numerator = (pre_expiry_avg_multiplier * time_before_expiry) + (0 * time_after_expiry);
                midpoint_lock_multiplier = numerator / (time_before_expiry + time_after_expiry);
            }
            else {
                // Otherwise, it needs to just be 1x
                // midpoint_lock_multiplier = MULTIPLIER_PRECISION;

                // Otherwise, it needs to just be 0x
                midpoint_lock_multiplier = 0;
            }
        }
        // If the lock is not expired
        else {
            // Decay the lock multiplier based on the time left
            uint256 avg_time_left;
            {
                uint256 time_left_p1 = thisStake.ending_timestamp - accrue_start_time;
                uint256 time_left_p2 = thisStake.ending_timestamp - block.timestamp;
                avg_time_left = (time_left_p1 + time_left_p2) / 2;
            }
            midpoint_lock_multiplier = lockMultiplier(avg_time_left);
        }

        // Sanity check: make sure it never goes above the initial multiplier
        if (midpoint_lock_multiplier > thisStake.lock_multiplier) midpoint_lock_multiplier = thisStake.lock_multiplier;
    }

    // Calculate the combined weight for an account
    function calcCurCombinedWeight(address account) public override view
        returns (
            uint256 old_combined_weight,
            uint256 new_vefxs_multiplier,
            uint256 new_combined_weight
        )
    {
        // Get the old combined weight
        old_combined_weight = _combined_weights[account];

        // Get the veFXS multipliers
        // For the calculations, use the midpoint (analogous to midpoint Riemann sum)
        new_vefxs_multiplier = veFXSMultiplier(account);

        uint256 midpoint_vefxs_multiplier;
        if (
            (_locked_liquidity[account] == 0 && _combined_weights[account] == 0) || 
            (new_vefxs_multiplier >= _vefxsMultiplierStored[account])
        ) {
            // This is only called for the first stake to make sure the veFXS multiplier is not cut in half
            // Also used if the user increased or maintained their position
            midpoint_vefxs_multiplier = new_vefxs_multiplier;
        }
        else {
            // Handles natural decay with a non-increased veFXS position
            midpoint_vefxs_multiplier = (new_vefxs_multiplier + _vefxsMultiplierStored[account]) / 2;
        }

        // Loop through the locked stakes, first by getting the liquidity * lock_multiplier portion
        new_combined_weight = 0;
        for (uint256 i = 0; i < lockedStakes[account].length; i++) {
            LockedStake memory thisStake = lockedStakes[account][i];

            // Calculate the midpoint lock multiplier
            uint256 midpoint_lock_multiplier = calcCurrLockMultiplier(account, i);

            // Calculate the combined boost
            uint256 liquidity = thisStake.liquidity;
            uint256 combined_boosted_amount = liquidity + ((liquidity * (midpoint_lock_multiplier + midpoint_vefxs_multiplier)) / MULTIPLIER_PRECISION);
            new_combined_weight += combined_boosted_amount;
        }
    }

    // ------ LOCK RELATED ------

    // All the locked stakes for a given account
    function lockedStakesOf(address account) external view returns (LockedStake[] memory) {
        return lockedStakes[account];
    }

    // Returns the length of the locked stakes for a given account
    function lockedStakesOfLength(address account) external view returns (uint256) {
        return lockedStakes[account].length;
    }

    // // All the locked stakes for a given account [old-school method]
    // function lockedStakesOfMultiArr(address account) external view returns (
    //     bytes32[] memory kek_ids,
    //     uint256[] memory start_timestamps,
    //     uint256[] memory liquidities,
    //     uint256[] memory ending_timestamps,
    //     uint256[] memory lock_multipliers
    // ) {
    //     for (uint256 i = 0; i < lockedStakes[account].length; i++){ 
    //         LockedStake memory thisStake = lockedStakes[account][i];
    //         kek_ids[i] = thisStake.kek_id;
    //         start_timestamps[i] = thisStake.start_timestamp;
    //         liquidities[i] = thisStake.liquidity;
    //         ending_timestamps[i] = thisStake.ending_timestamp;
    //         lock_multipliers[i] = thisStake.lock_multiplier;
    //     }
    // }

    /* =============== MUTATIVE FUNCTIONS =============== */

    // ------ STAKING ------

    function _updateLiqAmts(address staker_address, uint256 amt, bool is_add) internal {
        // Get the proxy address
        address the_proxy = getProxyFor(staker_address);

        if (is_add) {
            // Update total liquidities
            _total_liquidity_locked += amt;
            _locked_liquidity[staker_address] += amt;

            // Update the proxy
            if (the_proxy != address(0)) proxy_lp_balances[the_proxy] += amt;
        }
        else {
            // Update total liquidities
            _total_liquidity_locked -= amt;
            _locked_liquidity[staker_address] -= amt;

            // Update the proxy
            if (the_proxy != address(0)) proxy_lp_balances[the_proxy] -= amt;
        }

        // Need to call to update the combined weights
        _updateRewardAndBalance(staker_address, false, true);
    }

    function _getStake(address staker_address, bytes32 kek_id) internal view returns (LockedStake memory locked_stake, uint256 arr_idx) {
        if (kek_id != 0) {
            for (uint256 i = 0; i < lockedStakes[staker_address].length; i++){ 
                if (kek_id == lockedStakes[staker_address][i].kek_id){
                    locked_stake = lockedStakes[staker_address][i];
                    arr_idx = i;
                    break;
                }
            }
        }
        require(kek_id != 0 && locked_stake.kek_id == kek_id, "Stake not found");
        
    }

    // Add additional LPs to an existing locked stake
    function lockAdditional(bytes32 kek_id, uint256 addl_liq) nonReentrant public {
        // Make sure staking isn't paused
        require(!stakingPaused, "Staking paused");

        // Make sure you are not in shutdown
        require(!withdrawalOnlyShutdown, "Only withdrawals allowed");

        // Claim rewards at the old balance first
        _getReward(msg.sender, msg.sender, true);
        
        // Get the stake and its index
        (LockedStake memory thisStake, uint256 theArrayIndex) = _getStake(msg.sender, kek_id);

        // Calculate the new amount
        uint256 new_amt = thisStake.liquidity + addl_liq;

        // Checks
        require(addl_liq >= 0, "Must be positive");

        // Pull the tokens from the sender
        TransferHelper.safeTransferFrom(address(stakingToken), msg.sender, address(this), addl_liq);

        // // Aura & Balancer
        // // Deposit the tokens into the Aura vault
        // // =========================================
        // stakingToken.approve(address(aura_deposit_vault), addl_liq);
        // aura_deposit_vault.stake(addl_liq);

        // Update the stake
        lockedStakes[msg.sender][theArrayIndex] = LockedStake(
            kek_id,
            thisStake.start_timestamp,
            new_amt,
            thisStake.ending_timestamp,
            thisStake.lock_multiplier
        );

        // Update liquidities
        _updateLiqAmts(msg.sender, addl_liq, true);

        emit LockedAdditional(msg.sender, kek_id, addl_liq);
    }

    // Extends the lock of an existing stake
    function lockLonger(bytes32 kek_id, uint256 new_ending_ts) nonReentrant public {
        // Make sure staking isn't paused
        require(!stakingPaused, "Staking paused");

        // Make sure you are not in shutdown
        require(!withdrawalOnlyShutdown, "Only withdrawals allowed");

        // Claim rewards at the old balance first
        _getReward(msg.sender, msg.sender, true);
        
        // Get the stake and its index
        (LockedStake memory thisStake, uint256 theArrayIndex) = _getStake(msg.sender, kek_id);

        // Check
        require(new_ending_ts > block.timestamp, "Must be in the future");

        // Calculate some times
        uint256 time_left = (thisStake.ending_timestamp > block.timestamp) ? thisStake.ending_timestamp - block.timestamp : 0;
        uint256 new_secs = new_ending_ts - block.timestamp;

        // Checks
        // require(time_left > 0, "Already expired");
        require(new_secs > time_left, "Cannot shorten lock time");
        require(new_secs >= lock_time_min, "Minimum stake time not met");
        require(new_secs <= lock_time_for_max_multiplier, "Trying to lock for too long");

        // Update the stake
        lockedStakes[msg.sender][theArrayIndex] = LockedStake(
            kek_id,
            block.timestamp,
            thisStake.liquidity,
            new_ending_ts,
            lockMultiplier(new_secs)
        );

        // Need to call to update the combined weights
        _updateRewardAndBalance(msg.sender, false, true);

        emit LockedLonger(msg.sender, kek_id, new_secs, block.timestamp, new_ending_ts);
    }

    

    // Two different stake functions are needed because of delegateCall and msg.sender issues (important for proxies)
    function stakeLocked(uint256 liquidity, uint256 secs) nonReentrant external returns (bytes32) {
        return _stakeLocked(msg.sender, msg.sender, liquidity, secs, block.timestamp);
    }

    // If this were not internal, and source_address had an infinite approve, this could be exploitable
    // (pull funds from source_address and stake for an arbitrary staker_address)
    function _stakeLocked(
        address staker_address,
        address source_address,
        uint256 liquidity,
        uint256 secs,
        uint256 start_timestamp
    ) internal updateRewardAndBalanceMdf(staker_address, true) returns (bytes32) {
        require(!withdrawalOnlyShutdown, "Only withdrawals allowed");
        require(!stakingPaused, "Staking paused");
        require(secs >= lock_time_min, "Minimum stake time not met");
        require(secs <= lock_time_for_max_multiplier,"Trying to lock for too long");

        // Pull in the required token(s)
        // Varies per farm
        TransferHelper.safeTransferFrom(address(stakingToken), source_address, address(this), liquidity);

        // // Aura & Balancer
        // // Deposit the tokens into the Aura vault
        // // =========================================
        // stakingToken.approve(address(aura_deposit_vault), liquidity);
        // aura_deposit_vault.stake(liquidity);

        // Get the lock multiplier and kek_id
        uint256 lock_multiplier = lockMultiplier(secs);
        bytes32 kek_id = keccak256(abi.encodePacked(staker_address, start_timestamp, liquidity, _locked_liquidity[staker_address]));
        
        // Create the locked stake
        lockedStakes[staker_address].push(LockedStake(
            kek_id,
            start_timestamp,
            liquidity,
            start_timestamp + secs,
            lock_multiplier
        ));

        // Update liquidities
        _updateLiqAmts(staker_address, liquidity, true);

        emit StakeLocked(staker_address, liquidity, secs, kek_id, source_address);

        return kek_id;
    }

    // ------ WITHDRAWING ------

    /// @notice Withdraw a stake. 
    /// @param kek_id The id for the stake
    /// @param claim_rewards_deprecated DEPRECATED, has no effect (always claims rewards regardless)
    /// @dev Two different withdrawLocked functions are needed because of delegateCall and msg.sender issues (important for migration)
    function withdrawLocked(bytes32 kek_id, address destination_address, bool claim_rewards_deprecated) nonReentrant external returns (uint256) {
        require(withdrawalsPaused == false, "Withdrawals paused");
        return _withdrawLocked(msg.sender, destination_address, kek_id, claim_rewards_deprecated);
    }

    /// @notice No withdrawer == msg.sender check needed since this is only internally callable and the checks are done in the wrapper functions like withdraw(), migrator_withdraw_unlocked() and migrator_withdraw_locked()
    /// @param staker_address The address of the staker
    /// @param destination_address Destination address for the withdrawn LP
    /// @param kek_id The id for the stake
    /// @param claim_rewards_deprecated DEPRECATED, has no effect (always claims rewards regardless)
    function _withdrawLocked(
        address staker_address,
        address destination_address,
        bytes32 kek_id,
        bool claim_rewards_deprecated
    ) internal returns (uint256) {
        // Collect rewards first and then update the balances
        // withdrawalOnlyShutdown to be used in an emergency situation if reward is overemitted or not available
        // and the user can forfeit rewards to get their principal back. 
        if (withdrawalOnlyShutdown) {
            // Do nothing.
        }
        else {
            // Get the reward
            _getReward(staker_address, destination_address, true);
        }

        // Get the stake and its index
        (LockedStake memory thisStake, uint256 theArrayIndex) = _getStake(staker_address, kek_id);
        require(block.timestamp >= thisStake.ending_timestamp || stakesUnlocked == true, "Stake is still locked!");
        uint256 liquidity = thisStake.liquidity;

        if (liquidity > 0) {

            // // Aura & Balancer
            // // Withdraw the tokens from the Aura vault. Do not claim
            // // =========================================
            // aura_deposit_vault.withdraw(liquidity, false);

            // Give the tokens to the destination_address
            // Should throw if insufficient balance
            TransferHelper.safeTransfer(address(stakingToken), destination_address, liquidity);

            // Remove the stake from the array
            delete lockedStakes[staker_address][theArrayIndex];

            // Update liquidities
            _updateLiqAmts(staker_address, liquidity, false);

            emit WithdrawLocked(staker_address, liquidity, kek_id, destination_address);
        }

        return liquidity;
    }


    function _getRewardExtraLogic(address rewardee, address destination_address) internal override {
        // Do nothing
    }

    /* ========== RESTRICTED FUNCTIONS - Owner or timelock only ========== */

    // Inherited...

    /* ========== EVENTS ========== */
    event LockedAdditional(address indexed user, bytes32 kek_id, uint256 amount);
    event LockedLonger(address indexed user, bytes32 kek_id, uint256 new_secs, uint256 new_start_ts, uint256 new_end_ts);
    event StakeLocked(address indexed user, uint256 amount, uint256 secs, bytes32 kek_id, address source_address);
    event WithdrawLocked(address indexed user, uint256 liquidity, bytes32 kek_id, address destination_address);
}


// File contracts/FPI/IFPI.sol

// Original license: SPDX_License_Identifier: Unlicense

interface IFPI {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function fpi_pools(address ) external view returns (bool);
    function fpi_pools_array(uint256 ) external view returns (address);

    function pool_burn_from(address b_address, uint256 b_amount ) external;
    function pool_mint(address m_address, uint256 m_amount ) external;
}


// File contracts/Misc_AMOs/convex/IDepositToken.sol

// Original license: SPDX_License_Identifier: GPL-2.0-or-later

interface IDepositToken {
  function allowance(address owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function balanceOf(address account) external view returns (uint256);
  function burn(address _from, uint256 _amount) external;
  function decimals() external view returns (uint8);
  function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);
  function increaseAllowance(address spender, uint256 addedValue) external returns (bool);
  function mint(address _to, uint256 _amount) external;
  function name() external view returns (string memory);
  function operator() external view returns (address);
  function symbol() external view returns (string memory);
  function totalSupply() external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}


// File contracts/Misc_AMOs/curve/I2pool.sol

// Original license: SPDX_License_Identifier: GPL-2.0-or-later

interface I2pool {
    function decimals() external view returns (uint256);
    function transfer(address _to, uint256 _value) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
    function approve(address _spender, uint256 _value) external returns (bool);
    function A() external view returns (uint256);
    function A_precise() external view returns (uint256);
    function get_virtual_price() external view returns (uint256);
    function lp_price() external view returns (uint256);
    function price_oracle() external view returns (uint256);
    function calc_token_amount(uint256[2] memory _amounts, bool _is_deposit) external view returns (uint256);
    function add_liquidity(uint256[2] memory _amounts, uint256 _min_mint_amount) external returns (uint256);
    function get_dy(int128 i, int128 j, uint256 _dx) external view returns (uint256);
    function exchange(int128 i, int128 j, uint256 _dx, uint256 _min_dy) external returns (uint256);
    function remove_liquidity(uint256 _amount, uint256[2] memory _min_amounts) external returns (uint256[2] memory);
    function remove_liquidity_imbalance(uint256[2] memory _amounts, uint256 _max_burn_amount) external returns (uint256);
    function calc_withdraw_one_coin(uint256 _token_amount, int128 i) external view returns (uint256);
    function remove_liquidity_one_coin(uint256 _token_amount, int128 i, uint256 _min_amount) external returns (uint256);
    function ramp_A(uint256 _future_A, uint256 _future_time) external;
    function stop_ramp_A() external;
    function commit_new_fee(uint256 _new_fee, uint256 _new_admin_fee) external;
    function apply_new_fee() external;
    function revert_new_parameters() external;
    function commit_transfer_ownership(address _owner) external;
    function apply_transfer_ownership() external;
    function revert_transfer_ownership() external;
    function admin_balances(uint256 i) external view returns (uint256);
    function withdraw_admin_fees() external;
    function donate_admin_fees() external;
    function kill_me() external;
    function unkill_me() external;
    function coins(uint256 arg0) external view returns (address);
    function balances(uint256 arg0) external view returns (uint256);
    function fee() external view returns (uint256);
    function admin_fee() external view returns (uint256);
    function owner() external view returns (address);
    function initial_A() external view returns (uint256);
    function future_A() external view returns (uint256);
    function initial_A_time() external view returns (uint256);
    function future_A_time() external view returns (uint256);
    function admin_actions_deadline() external view returns (uint256);
    function transfer_ownership_deadline() external view returns (uint256);
    function future_fee() external view returns (uint256);
    function future_admin_fee() external view returns (uint256);
    function future_owner() external view returns (address);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function balanceOf(address arg0) external view returns (uint256);
    function allowance(address arg0, address arg1) external view returns (uint256);
    function totalSupply() external view returns (uint256);
}


// File contracts/Misc_AMOs/curve/I2poolToken.sol

// Original license: SPDX_License_Identifier: GPL-2.0-or-later

interface I2poolToken {
  function decimals() external view returns (uint256);
  function transfer(address _to, uint256 _value) external returns (bool);
  function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
  function approve(address _spender, uint256 _value) external returns (bool);
  function increaseAllowance(address _spender, uint256 _added_value) external returns (bool);
  function decreaseAllowance(address _spender, uint256 _subtracted_value) external returns (bool);
  function mint(address _to, uint256 _value) external returns (bool);
  function burnFrom(address _to, uint256 _value) external returns (bool);
  function set_minter(address _minter) external;
  function set_name(string memory _name, string memory _symbol) external;
  function name() external view returns (string memory);
  function symbol() external view returns (string memory);
  function balanceOf(address arg0) external view returns (uint256);
  function allowance(address arg0, address arg1) external view returns (uint256);
  function totalSupply() external view returns (uint256);
  function minter() external view returns (address);
}


// File contracts/Misc_AMOs/curve/ICurveStableSwapNG.sol

// Original license: SPDX_License_Identifier: GPL-2.0-or-later

interface ICurveStableSwapNG {
  function exchange ( int128 i, int128 j, uint256 _dx, uint256 _min_dy ) external returns ( uint256 );
  function exchange ( int128 i, int128 j, uint256 _dx, uint256 _min_dy, address _receiver ) external returns ( uint256 );
  function exchange_received ( int128 i, int128 j, uint256 _dx, uint256 _min_dy ) external returns ( uint256 );
  function exchange_received ( int128 i, int128 j, uint256 _dx, uint256 _min_dy, address _receiver ) external returns ( uint256 );
  function add_liquidity ( uint256[] memory _amounts, uint256 _min_mint_amount ) external returns ( uint256 );
  function add_liquidity ( uint256[] memory _amounts, uint256 _min_mint_amount, address _receiver ) external returns ( uint256 );
  function remove_liquidity_one_coin ( uint256 _burn_amount, int128 i, uint256 _min_received ) external returns ( uint256 );
  function remove_liquidity_one_coin ( uint256 _burn_amount, int128 i, uint256 _min_received, address _receiver ) external returns ( uint256 );
  function remove_liquidity_imbalance ( uint256[] memory _amounts, uint256 _max_burn_amount ) external returns ( uint256 );
  function remove_liquidity_imbalance ( uint256[] memory _amounts, uint256 _max_burn_amount, address _receiver ) external returns ( uint256 );
  function remove_liquidity ( uint256 _burn_amount, uint256[] memory _min_amounts ) external returns ( uint256[] memory );
  function remove_liquidity ( uint256 _burn_amount, uint256[] memory _min_amounts, address _receiver ) external returns ( uint256[] memory );
  function remove_liquidity ( uint256 _burn_amount, uint256[] memory _min_amounts, address _receiver, bool _claim_admin_fees ) external returns ( uint256[] memory );
  function withdraw_admin_fees (  ) external;
  function last_price ( uint256 i ) external view returns ( uint256 );
  function ema_price ( uint256 i ) external view returns ( uint256 );
  function get_p ( uint256 i ) external view returns ( uint256 );
  function price_oracle ( uint256 i ) external view returns ( uint256 );
  function D_oracle (  ) external view returns ( uint256 );
  function transfer ( address _to, uint256 _value ) external returns ( bool );
  function transferFrom ( address _from, address _to, uint256 _value ) external returns ( bool );
  function approve ( address _spender, uint256 _value ) external returns ( bool );
  function permit ( address _owner, address _spender, uint256 _value, uint256 _deadline, uint8 _v, bytes32 _r, bytes32 _s ) external returns ( bool );
  function DOMAIN_SEPARATOR (  ) external view returns ( bytes32 );
  function get_dx ( int128 i, int128 j, uint256 dy ) external view returns ( uint256 );
  function get_dy ( int128 i, int128 j, uint256 dx ) external view returns ( uint256 );
  function calc_withdraw_one_coin ( uint256 _burn_amount, int128 i ) external view returns ( uint256 );
  function totalSupply (  ) external view returns ( uint256 );
  function get_virtual_price (  ) external view returns ( uint256 );
  function calc_token_amount ( uint256[] memory _amounts, bool _is_deposit ) external view returns ( uint256 );
  function A (  ) external view returns ( uint256 );
  function A_precise (  ) external view returns ( uint256 );
  function balances ( uint256 i ) external view returns ( uint256 );
  function get_balances (  ) external view returns ( uint256[] memory );
  function stored_rates (  ) external view returns ( uint256[] memory );
  function dynamic_fee ( int128 i, int128 j ) external view returns ( uint256 );
  function ramp_A ( uint256 _future_A, uint256 _future_time ) external;
  function stop_ramp_A (  ) external;
  function set_new_fee ( uint256 _new_fee, uint256 _new_offpeg_fee_multiplier ) external;
  function set_ma_exp_time ( uint256 _ma_exp_time, uint256 _D_ma_time ) external;
  function N_COINS (  ) external view returns ( uint256 );
  function coins ( uint256 arg0 ) external view returns ( address );
  function fee (  ) external view returns ( uint256 );
  function offpeg_fee_multiplier (  ) external view returns ( uint256 );
  function admin_fee (  ) external view returns ( uint256 );
  function initial_A (  ) external view returns ( uint256 );
  function future_A (  ) external view returns ( uint256 );
  function initial_A_time (  ) external view returns ( uint256 );
  function future_A_time (  ) external view returns ( uint256 );
  function admin_balances ( uint256 arg0 ) external view returns ( uint256 );
  function ma_exp_time (  ) external view returns ( uint256 );
  function D_ma_time (  ) external view returns ( uint256 );
  function ma_last_time (  ) external view returns ( uint256 );
  function name (  ) external view returns ( string memory );
  function symbol (  ) external view returns ( string memory );
  function decimals (  ) external view returns ( uint8 );
  function version (  ) external view returns ( string memory );
  function balanceOf ( address arg0 ) external view returns ( uint256 );
  function allowance ( address arg0, address arg1 ) external view returns ( uint256 );
  function nonces ( address arg0 ) external view returns ( uint256 );
  function salt (  ) external view returns ( bytes32 );
}


// File contracts/Misc_AMOs/curve/ICurveTricryptoOptimizedWETH.sol

// Original license: SPDX_License_Identifier: GPL-2.0-or-later

interface ICurveTricryptoOptimizedWETH {
  function exchange ( uint256 i, uint256 j, uint256 dx, uint256 min_dy ) external returns ( uint256 );
  function exchange ( uint256 i, uint256 j, uint256 dx, uint256 min_dy, bool use_eth ) external returns ( uint256 );
  function exchange ( uint256 i, uint256 j, uint256 dx, uint256 min_dy, bool use_eth, address receiver ) external returns ( uint256 );
  function exchange_underlying ( uint256 i, uint256 j, uint256 dx, uint256 min_dy ) external returns ( uint256 );
  function exchange_underlying ( uint256 i, uint256 j, uint256 dx, uint256 min_dy, address receiver ) external returns ( uint256 );
  function exchange_extended ( uint256 i, uint256 j, uint256 dx, uint256 min_dy, bool use_eth, address sender, address receiver, bytes32 cb ) external returns ( uint256 );
  function add_liquidity ( uint256[3] memory amounts, uint256 min_mint_amount ) external returns ( uint256 );
  function add_liquidity ( uint256[3] memory amounts, uint256 min_mint_amount, bool use_eth ) external returns ( uint256 );
  function add_liquidity ( uint256[3] memory amounts, uint256 min_mint_amount, bool use_eth, address receiver ) external returns ( uint256 );
  function remove_liquidity ( uint256 _amount, uint256[3] memory min_amounts ) external returns ( uint256[3] memory );
  function remove_liquidity ( uint256 _amount, uint256[3] memory min_amounts, bool use_eth ) external returns ( uint256[3] memory );
  function remove_liquidity ( uint256 _amount, uint256[3] memory min_amounts, bool use_eth, address receiver ) external returns ( uint256[3] memory );
  function remove_liquidity ( uint256 _amount, uint256[3] memory min_amounts, bool use_eth, address receiver, bool claim_admin_fees ) external returns ( uint256[3] memory );
  function remove_liquidity_one_coin ( uint256 token_amount, uint256 i, uint256 min_amount ) external returns ( uint256 );
  function remove_liquidity_one_coin ( uint256 token_amount, uint256 i, uint256 min_amount, bool use_eth ) external returns ( uint256 );
  function remove_liquidity_one_coin ( uint256 token_amount, uint256 i, uint256 min_amount, bool use_eth, address receiver ) external returns ( uint256 );
  function claim_admin_fees (  ) external;
  function transferFrom ( address _from, address _to, uint256 _value ) external returns ( bool );
  function transfer ( address _to, uint256 _value ) external returns ( bool );
  function approve ( address _spender, uint256 _value ) external returns ( bool );
  function increaseAllowance ( address _spender, uint256 _add_value ) external returns ( bool );
  function decreaseAllowance ( address _spender, uint256 _sub_value ) external returns ( bool );
  function permit ( address _owner, address _spender, uint256 _value, uint256 _deadline, uint8 _v, bytes32 _r, bytes32 _s ) external returns ( bool );
  function fee_receiver (  ) external view returns ( address );
  function calc_token_amount ( uint256[3] memory amounts, bool deposit ) external view returns ( uint256 );
  function get_dy ( uint256 i, uint256 j, uint256 dx ) external view returns ( uint256 );
  function get_dx ( uint256 i, uint256 j, uint256 dy ) external view returns ( uint256 );
  function lp_price (  ) external view returns ( uint256 );
  function get_virtual_price (  ) external view returns ( uint256 );
  function price_oracle ( uint256 k ) external view returns ( uint256 );
  function last_prices ( uint256 k ) external view returns ( uint256 );
  function price_scale ( uint256 k ) external view returns ( uint256 );
  function fee (  ) external view returns ( uint256 );
  function calc_withdraw_one_coin ( uint256 token_amount, uint256 i ) external view returns ( uint256 );
  function calc_token_fee ( uint256[3] memory amounts, uint256[3] memory xp ) external view returns ( uint256 );
  function A (  ) external view returns ( uint256 );
  function gamma (  ) external view returns ( uint256 );
  function mid_fee (  ) external view returns ( uint256 );
  function out_fee (  ) external view returns ( uint256 );
  function fee_gamma (  ) external view returns ( uint256 );
  function allowed_extra_profit (  ) external view returns ( uint256 );
  function adjustment_step (  ) external view returns ( uint256 );
  function ma_time (  ) external view returns ( uint256 );
  function precisions (  ) external view returns ( uint256[3] memory );
  function fee_calc ( uint256[3] memory xp ) external view returns ( uint256 );
  function DOMAIN_SEPARATOR (  ) external view returns ( bytes32 );
  function ramp_A_gamma ( uint256 future_A, uint256 future_gamma, uint256 future_time ) external;
  function stop_ramp_A_gamma (  ) external;
  function commit_new_parameters ( uint256 _new_mid_fee, uint256 _new_out_fee, uint256 _new_fee_gamma, uint256 _new_allowed_extra_profit, uint256 _new_adjustment_step, uint256 _new_ma_time ) external;
  function apply_new_parameters (  ) external;
  function revert_new_parameters (  ) external;
  function WETH20 (  ) external view returns ( address );
  function MATH (  ) external view returns ( address );
  function coins ( uint256 arg0 ) external view returns ( address );
  function factory (  ) external view returns ( address );
  function last_prices_timestamp (  ) external view returns ( uint256 );
  function initial_A_gamma (  ) external view returns ( uint256 );
  function initial_A_gamma_time (  ) external view returns ( uint256 );
  function future_A_gamma (  ) external view returns ( uint256 );
  function future_A_gamma_time (  ) external view returns ( uint256 );
  function balances ( uint256 arg0 ) external view returns ( uint256 );
  function D (  ) external view returns ( uint256 );
  function xcp_profit (  ) external view returns ( uint256 );
  function xcp_profit_a (  ) external view returns ( uint256 );
  function virtual_price (  ) external view returns ( uint256 );
  function packed_rebalancing_params (  ) external view returns ( uint256 );
  function packed_fee_params (  ) external view returns ( uint256 );
  function ADMIN_FEE (  ) external view returns ( uint256 );
  function admin_actions_deadline (  ) external view returns ( uint256 );
  function name (  ) external view returns ( string memory );
  function symbol (  ) external view returns ( string memory );
  function decimals (  ) external view returns ( uint8 );
  function version (  ) external view returns ( string memory );
  function balanceOf ( address arg0 ) external view returns ( uint256 );
  function allowance ( address arg0, address arg1 ) external view returns ( uint256 );
  function totalSupply (  ) external view returns ( uint256 );
  function nonces ( address arg0 ) external view returns ( uint256 );
  function salt (  ) external view returns ( bytes32 );
}


// File contracts/Oracle/AggregatorV3Interface.sol

// Original license: SPDX_License_Identifier: MIT

interface AggregatorV3Interface {

  function decimals() external view returns (uint8);
  function description() external view returns (string memory);
  function version() external view returns (uint256);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

}


// File contracts/Oracle/ICPITrackerOracle.sol

// Original license: SPDX_License_Identifier: GPL-2.0-or-later

interface ICPITrackerOracle {
  function acceptOwnership (  ) external;
  function bot_address (  ) external view returns ( address );
  function cancelRequest ( bytes32 _requestId, uint256 _payment, bytes4 _callbackFunc, uint256 _expiration ) external;
  function cpi_last (  ) external view returns ( uint256 );
  function cpi_observations ( uint256 ) external view returns ( uint256 result_year, uint256 result_month, uint256 cpi_target, uint256 peg_price_target, uint256 timestamp );
  function cpi_target (  ) external view returns ( uint256 );
  function currDeltaFracAbsE6 (  ) external view returns ( uint256 );
  function currDeltaFracE6 (  ) external view returns ( int256 );
  function currPegPrice (  ) external view returns ( uint256 );
  function fee (  ) external view returns ( uint256 );
  function fulfill ( bytes32 _requestId, uint256 result ) external;
  function fulfill_ready_day (  ) external view returns ( uint256 );
  function future_ramp_period (  ) external view returns ( uint256 );
  function jobId (  ) external view returns ( bytes32 );
  function lastUpdateTime (  ) external view returns ( uint256 );
  function max_delta_frac (  ) external view returns ( uint256 );
  function month_names ( uint256 ) external view returns ( string memory );
  function nominateNewOwner ( address _owner ) external;
  function nominatedOwner (  ) external view returns ( address );
  function oracle (  ) external view returns ( address );
  function owner (  ) external view returns ( address );
  function peg_price_last (  ) external view returns ( uint256 );
  function peg_price_target (  ) external view returns ( uint256 );
  function ramp_period (  ) external view returns ( uint256 );
  function recoverERC20 ( address tokenAddress, uint256 tokenAmount ) external;
  function requestCPIData (  ) external returns ( bytes32 requestId );
  function setBot ( address _new_bot_address ) external;
  function setFulfillReadyDay ( uint256 _fulfill_ready_day ) external;
  function setFutureRampPeriod ( uint256 _future_ramp_period ) external;
  function setMaxDeltaFrac ( uint256 _max_delta_frac ) external;
  function setOracleInfo ( address _oracle, bytes32 _jobId, uint256 _fee ) external;
  function setTimelock ( address _new_timelock_address ) external;
  function stored_month (  ) external view returns ( uint256 );
  function stored_year (  ) external view returns ( uint256 );
  function time_contract (  ) external view returns ( address );
  function timelock_address (  ) external view returns ( address );
  function upcomingCPIParams (  ) external view returns ( uint256 upcoming_year, uint256 upcoming_month, uint256 upcoming_timestamp );
  function upcomingSerie (  ) external view returns ( string memory serie_name );
}


// File contracts/Staking/Variants/FraxUnifiedFarm_ERC20_Convex_Generic.sol

// Original license: SPDX_License_Identifier: GPL-2.0-or-later


// import '../../FXB/IFXB.sol';










contract FraxUnifiedFarm_ERC20_Convex_Generic is FraxUnifiedFarm_ERC20 {

    string public farm_type = "ERC20_Convex_Generic";

    // IFPI public FPI = IFPI(0x5Ca135cB8527d76e932f34B5145575F9d8cbE08E);
    // ICPITrackerOracle public FPI_ORACLE = ICPITrackerOracle(0x66B7DFF2Ac66dc4d6FBB3Db1CB627BBb01fF3146);

    // // Convex tricryptoFRAX
    // // ============================================
    // AggregatorV3Interface internal priceFeedETHUSD = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);

    constructor (
        address _owner,
        address[] memory _rewardTokens,
        address[] memory _rewardManagers,
        uint256[] memory _rewardRates,
        address[] memory _gaugeControllers,
        address[] memory _rewardDistributors,
        address _stakingToken 
    ) 
    FraxUnifiedFarm_ERC20(_owner , _rewardTokens, _rewardManagers, _rewardRates, _gaugeControllers, _rewardDistributors, _stakingToken)
    {
        // COMMENTED OUT SO COMPILER DOESNT COMPLAIN. UNCOMMENT WHEN DEPLOYING

        // Convex crvUSD/FRAX
        // ============================================
        // stakingToken = IConvexStakingWrapperFrax(_stakingToken);
        // curveToken = I2poolTokenNoLending(stakingToken.curveToken());

        // Convex FRAX/PYUSD & NG pools
        // ============================================
        // stakingToken = IConvexStakingWrapperFrax(_stakingToken);
        // curveToken = ICurveStableSwapNG(stakingToken.curveToken());
        // curvePool = ICurveStableSwapNG(curveToken);

        // Convex DOLA/FRAXPYUSD
        // ============================================
        stakingToken = IConvexStakingWrapperFrax(_stakingToken);
        curveToken = ICurveStableSwapMetaNG(stakingToken.curveToken());
        curvePool = ICurveStableSwapMetaNG(curveToken);

        // Convex FRAX/USDP
        // ============================================
        // stakingToken = IConvexStakingWrapperFrax(_stakingToken);
        // curveToken = I2poolToken(stakingToken.curveToken());
        // curvePool = I2pool(curveToken.minter());

        // Convex FRAX/FXB
        // ============================================
        // stakingToken = IConvexStakingWrapperFrax(_stakingToken);
        // curveToken = ICurveStableSwapNG(stakingToken.curveToken());
        // curvePool = ICurveStableSwapNG(curveToken);

        // Convex tricryptoFRAX & Convex triSDT
        // ============================================
        // stakingToken = IConvexStakingWrapperFrax(_stakingToken);
        // curveToken = ICurveTricryptoOptimizedWETH(address(stakingToken.curveToken()));
        // curvePool = ICurveTricryptoOptimizedWETH(address(stakingToken.curveToken()));

    }

    // // Convex tricryptoFRAX 
    // // ============================================
    // function getLatestETHPriceE8() public view returns (int) {
    //     // Returns in E8
    //     (uint80 roundID, int price, , uint256 updatedAt, uint80 answeredInRound) = priceFeedETHUSD.latestRoundData();
    //     require(price >= 0 && updatedAt!= 0 && answeredInRound >= roundID, "Invalid chainlink price");
        
    //     return price;
    // }

    // function setETHUSDOracle(address _eth_usd_oracle_address) public onlyByOwnGov {
    //     require(_eth_usd_oracle_address != address(0), "Zero address detected");

    //     priceFeedETHUSD = AggregatorV3Interface(_eth_usd_oracle_address);
    // }

    function fraxPerLPToken() public view override returns (uint256 frax_per_lp_token) {
        // COMMENTED OUT SO COMPILER DOESNT COMPLAIN. UNCOMMENT WHEN DEPLOYING
        
        // Convex crvUSD/FRAX
        // ============================================
        // {
        //     // Half of the LP should be FRAX
        //     // Using 0.50 * virtual price for gas savings
        //     frax_per_lp_token = curvePool.get_virtual_price() / 2; 
        // }

        // Convex FRAX/PYUSD
        // ============================================
        // {
        //     // Half of the LP should be FRAX
        //     // Using 0.50 * virtual price for gas savings
        //     frax_per_lp_token = curvePool.get_virtual_price() / 2; 
        // }

        // Convex DOLA/FRAXPYUSD
        // ============================================
        {
            // One quarter of the LP should be FRAX
            // Using 0.25 * virtual price for gas savings
            frax_per_lp_token = curvePool.get_virtual_price() / 4; 
        }

        // Convex FRAX/sDAI
        // ============================================
        // {
        //     // Special calculation because FRAX != sDAI
        //     frax_per_lp_token = (IERC20(frax_address).balanceOf(address(curvePool)) * 1e18) / curvePool.totalSupply(); 
        // }

        // Convex FRAX/FPI NG
        // ============================================
        // {
        //     // Count both FRAX and FPI as both are beneficial
        //     uint256 frax_balance = IERC20(frax_address).balanceOf(address(curvePool));
        //     uint256 fpi_value_e36 = FPI.balanceOf(address(curvePool)) * FPI_ORACLE.currPegPrice();
        //     frax_per_lp_token = ((frax_balance * 1e18) + fpi_value_e36) / curvePool.totalSupply(); 
        // }

        // Convex FRAX/FXB
        // ============================================
        // {
        //     // Count both FRAX and FXB as both are beneficial
        //     frax_per_lp_token = curvePool.get_virtual_price(); 
        // }

        // Convex triSDT
        // ============================================
        // {
        //     // One third of the LP should be frxETH
        //     // Using lp_price / 3 for gas savings
        //     frax_per_lp_token = curvePool.lp_price() / 3; 
        // }

        // Convex tricryptoFRAX
        // ============================================
        // {
        //     // Get the value of frxETH in the pool
        //     uint256 frxETH_in_pool = IERC20(0x5E8422345238F34275888049021821E8E08CAa1f).balanceOf(address(curvePool));
        //     uint256 frxETH_usd_val = (frxETH_in_pool * uint256(getLatestETHPriceE8())) / (1e8);
            
        //     // Get the value of FRAX in the pool, assuming it is $1
        //     uint256 frax_balance = IERC20(frax_address).balanceOf(address(curvePool));

        //     // Add both FRAX and frxETH $ values since both are beneficial
        //     frax_per_lp_token = ((frax_balance + frxETH_usd_val) * 1e18) / curvePool.totalSupply();
        // }
    }
}