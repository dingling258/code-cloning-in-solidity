//SPDX-License-Identifier: MIT
// File: contracts/impl/OwnableView.sol


pragma solidity ^0.8.0;

abstract contract OwnableView {

    bytes32 internal constant OWNER_KEY = 0xdc6edb7e21c7d6802c30a4249460696aa4c6ef3b5aee9c59996f8fedc7fbaefe;

    modifier onlyOwner() {
        require(msg.sender == _owner(), "Unauthorized");
        _;
    }

    function _owner() internal view returns (address value) {
        assembly {
            value := sload(OWNER_KEY)
        }
    }
}
// File: contracts/model/IOwnable.sol


pragma solidity ^0.8.0;

interface IOwnable {

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function owner() external view returns (address);

    function renounceOwnership() external;

    function transferOwnership(address newOwner) external;
}
// File: contracts/impl/Ownable.sol


pragma solidity ^0.8.0;



abstract contract Ownable is IOwnable, OwnableView {

    constructor(address initialOwner) {
        _transferOwnership(initialOwner);
    }

    function owner() override external view returns (address) {
        return _owner();
    }

    function renounceOwnership() override external onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) override external onlyOwner {
        require(newOwner != address(0), "Invalid");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) private {
        address oldOwner = _owner();
        assembly {
            sstore(OWNER_KEY, newOwner)
        }
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
// File: contracts/model/IERC20Approve.sol


pragma solidity ^0.8.0;

interface IERC20Approve {

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);
}
// File: contracts/vert/uniswapV3/IPoolInitializer.sol

pragma solidity ^0.8.0;

interface IPoolInitializer {
    function createAndInitializePoolIfNecessary(
        address token0,
        address token1,
        uint24 fee,
        uint160 sqrtPriceX96
    ) external payable returns (address pool);
}
// File: contracts/vert/uniswapV3/IUniswapV3Factory.sol

pragma solidity ^0.8.0;

interface IUniswapV3Factory {
    event OwnerChanged(address indexed oldOwner, address indexed newOwner);

    event PoolCreated(
        address indexed token0,
        address indexed token1,
        uint24 indexed fee,
        int24 tickSpacing,
        address pool
    );

    event FeeAmountEnabled(uint24 indexed fee, int24 indexed tickSpacing);

    function owner() external view returns (address);

    function feeAmountTickSpacing(uint24 fee) external view returns (int24);

    function getPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external view returns (address pool);

    function createPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external returns (address pool);

    function setOwner(address _owner) external;

    function enableFeeAmount(uint24 fee, int24 tickSpacing) external;
}
// File: contracts/vert/uniswapV3/IPeripheryPayments.sol

//License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPeripheryPayments {

    function unwrapWETH9(uint256 amountMinimum, address recipient) external payable;

    function refundETH() external payable;

    function sweepToken(
        address token,
        uint256 amountMinimum,
        address recipient
    ) external payable;
}

// File: contracts/vert/uniswapV3/IMulticall.sol

//License-Identifier: MIT
pragma solidity ^0.8.0;

interface IMulticall {
    function multicall(bytes[] calldata data) external payable returns (bytes[] memory results);
}

// File: contracts/vert/uniswapV3/IPeripheryImmutableState.sol

//License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPeripheryImmutableState {
    function factory() external view returns (address);

    function WETH9() external view returns (address);
}

// File: contracts/vert/uniswapV3/ISwapRouter.sol

//License-Identifier: MIT
pragma solidity ^0.8.0;




interface ISwapRouter is IMulticall, IPeripheryImmutableState, IPeripheryPayments {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);

    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    function exactInput(ExactInputParams calldata params) external payable returns (uint256 amountOut);

    struct ExactOutputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
        uint160 sqrtPriceLimitX96;
    }

    function exactOutputSingle(ExactOutputSingleParams calldata params) external payable returns (uint256 amountIn);

    struct ExactOutputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
    }

    function exactOutput(ExactOutputParams calldata params) external payable returns (uint256 amountIn);
}
// File: contracts/vert/uniswapV3/INonfungiblePositionManager.sol


pragma solidity ^0.8.0;




interface INonfungiblePositionManager is IMulticall, IPeripheryImmutableState, IPeripheryPayments {
    function setApprovalForAll(address operator, bool _approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function transferFrom(address from, address to, uint256 tokenId) external;
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
    function positions(uint256 tokenId)
        external
        view
        returns (
            uint96 nonce,
            address operator,
            address token0,
            address token1,
            uint24 fee,
            int24 tickLower,
            int24 tickUpper,
            uint128 liquidity,
            uint256 feeGrowthInside0LastX128,
            uint256 feeGrowthInside1LastX128,
            uint128 tokensOwed0,
            uint128 tokensOwed1
        );

    struct MintParams {
        address token0;
        address token1;
        uint24 fee;
        int24 tickLower;
        int24 tickUpper;
        uint256 amount0Desired;
        uint256 amount1Desired;
        uint256 amount0Min;
        uint256 amount1Min;
        address recipient;
        uint256 deadline;
    }

    function mint(MintParams calldata params)
        external
        payable
        returns (
            uint256 tokenId,
            uint128 liquidity,
            uint256 amount0,
            uint256 amount1
        );

    struct IncreaseLiquidityParams {
        uint256 tokenId;
        uint256 amount0Desired;
        uint256 amount1Desired;
        uint256 amount0Min;
        uint256 amount1Min;
        uint256 deadline;
    }

    function increaseLiquidity(IncreaseLiquidityParams calldata params)
        external
        payable
        returns (
            uint128 liquidity,
            uint256 amount0,
            uint256 amount1
        );

    struct DecreaseLiquidityParams {
        uint256 tokenId;
        uint128 liquidity;
        uint256 amount0Min;
        uint256 amount1Min;
        uint256 deadline;
    }

    function decreaseLiquidity(DecreaseLiquidityParams calldata params)
        external
        payable
        returns (uint256 amount0, uint256 amount1);

    struct CollectParams {
        uint256 tokenId;
        address recipient;
        uint128 amount0Max;
        uint128 amount1Max;
    }

    function collect(CollectParams calldata params) external payable returns (uint256 amount0, uint256 amount1);

    function burn(uint256 tokenId) external payable;
}
// File: contracts/vert/UtilitiesLib.sol


pragma solidity ^0.8.0;

library UtilitiesLib {
    uint256 internal constant AMOUNT_PERCENTAGE = 2e17;
    uint256 internal constant TREASURY_PERCENTAGE = 5e16;
    uint256 internal constant MARKETING_PERCENTAGE = 12e16;
    uint256 internal constant BOOTSTRAP_PERCENTAGE = 13e16;
    uint256 internal constant REVENUE_SHARE_PERCENTAGE = 1e17;
    uint256 internal constant ANTI_WHALE_MAX_BALANCE = 1500000e18;
    uint256 internal constant ANTI_WHALE_MAX_TRANSFER = 750000e18;
}
// File: @ethereansos/farming-base/contracts/BaseFarming.sol

///License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20Token {
    function balanceOf(address owner) external view returns (uint);
    function transfer(address to, uint value) external returns (bool);
}

library SafeMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, 'ds-math-add-overflow');
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, 'ds-math-sub-underflow');
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow');
    }
}

interface IFarmingLiquidityProvider {
    function totalFarmingLiquidity() external view returns(uint256);
    function setNextRebalanceEvent(uint256 nextRebalanceEvent) external;
}

contract BaseFarming {
    using SafeMath for uint256;

    struct FarmingPosition {
        uint256 rewardTokenToRedeem;
        uint256 rewardPerTokenPaid;
        uint256 lastLiquidityBalance;
    }

    uint256 public constant FULL_PRECISION = 1e18;
    uint256 public constant TIME_SLOT_IN_SECONDS = 15;

    address public farmingLiquidityProvider;
    address public rewardToken;
    uint256 public rebalanceIntervalInEventSlots;
    uint256 public startEvent;
    uint256 public lastUpdateEvent;
    uint256 public nextRebalanceEvent;

    uint256 private _rewardPerEvent;
    uint256 private _rewardPerTokenStored;
    uint256 private _reservedBalance;
    uint256 private _previousLiquidityPoolTotalSupply;

    bool internal _resetOnly;
    bool internal _inhibitCallback;

    uint256 public totalFarmingLiquidity;

    mapping(address => FarmingPosition) private _positions;

    /// @notice Get the reward per event for the current season
    /// divided by the farming additional precision
    function rewardPerEvent() public view returns(uint256) {
        return _rewardPerEvent / FULL_PRECISION;
    }

    /// @notice Get the reserved balance for the current season
    /// divided by the farming additional precision
    function reservedBalance() public view returns(uint256) {
        return _reservedBalance / FULL_PRECISION;
    }

    function _increaseReservedBalance(uint256 amount) internal {
        _reservedBalance = _reservedBalance.add(amount * FULL_PRECISION);
    }

    function _decreaseReservedBalance(uint256 amount) internal {
        _reservedBalance = _reservedBalance.sub(amount * FULL_PRECISION);
    }

    function calculateIfThereIsMoreReward() external view returns(uint256 seasonReward) {
        return _calculateIfThereIsMoreReward(_resetOnly);
    }

    function _claimReward(address account, address[] memory rewardReceivers, uint256[] memory rewardReceiversPercentage) internal returns(uint256 claimedReward, uint256 _nextRebalanceEvent, uint256 rewardPerEvent_) {
        uint lastLiquidityBalance = _positions[account].lastLiquidityBalance;
        (_nextRebalanceEvent, rewardPerEvent_) = _tryRebalance(_totalSupply(), lastLiquidityBalance == 0, false);
        claimedReward = _syncPosition(
            account,
            lastLiquidityBalance,
            rewardReceivers,
            rewardReceiversPercentage
        );
    }

    /// @notice Sync positions and try to rebalance and start farming seasons
    function _sync(
        address from,
        address to,
        uint256 fromLiquidityPoolTokenBalance,
        uint256 toLiquidityPoolTokenBalance,
        uint256 liquidityPoolTotalSupply
    ) internal returns(uint256 _nextRebalanceEvent) {

        (_nextRebalanceEvent,) = _tryRebalance(liquidityPoolTotalSupply, false, false);

        address[] memory voidRewardReceivers = new address[](0);
        uint256[] memory voidRewardReceiversPercentage = new uint256[](0);

        if (from != address(0)) _syncPosition(from, fromLiquidityPoolTokenBalance, voidRewardReceivers, voidRewardReceiversPercentage);
        if (to != address(0)) _syncPosition(to, toLiquidityPoolTokenBalance, voidRewardReceivers, voidRewardReceiversPercentage);
    }

    /// @notice Start and stop the farming perpetual seasons. If the season is started compute the _rewardPerTokenStored
    /// @param _nextRebalanceEvent is updated after season is started (or stopped)
    /// @param rewardPerEvent_ is returned in his correct precision, so is divided by PRECISION
    function _tryRebalance(uint256 liquidityPoolTotalSupply, bool inhibit, bool reset) internal returns(uint256 _nextRebalanceEvent, uint256 rewardPerEvent_) {
        /// @dev Gas savings for Optimism L1 blocks static call
        /// and variables that are loaded from storage
        uint256 blockEventstamp = block.timestamp;
        uint256 previousLiquidityPoolTotalSupply = _previousLiquidityPoolTotalSupply;
        uint256 _startEvent = startEvent;
        uint256 _lastUpdateEvent = lastUpdateEvent;

        /// @dev Gas savings reusing output variables
        _nextRebalanceEvent = nextRebalanceEvent;
        rewardPerEvent_ = _rewardPerEvent;

        /// @notice Compute the rewards for the time interval (if the season is started)
        if(_nextRebalanceEvent != 0) {
            uint256 currentEvent = blockEventstamp < _nextRebalanceEvent ? blockEventstamp : _nextRebalanceEvent;

            /// @dev Inhibit the _rewardPerTokenStored update when inhibit variable is true.
            /// This is used for bypass incorrect _rewardPerTokenStored updates in the _tryRebalance function.
            if(!inhibit && previousLiquidityPoolTotalSupply != 0) {
                uint256 computedLastUpdateEvent = _lastUpdateEvent < _startEvent ? _startEvent : _lastUpdateEvent;
                _rewardPerTokenStored = _rewardPerTokenStored.add(((((currentEvent.sub(computedLastUpdateEvent)))).mul(rewardPerEvent_)) / previousLiquidityPoolTotalSupply);
                lastUpdateEvent = currentEvent;
            }
        }

        _previousLiquidityPoolTotalSupply = liquidityPoolTotalSupply;

        /// @notice Start (or stop) the new season
        if(reset || blockEventstamp >= _nextRebalanceEvent || liquidityPoolTotalSupply == 0) {
            uint256 reservedBalance_ = _reservedBalance;

            if (_nextRebalanceEvent > blockEventstamp) {
                reservedBalance_ = reservedBalance_.sub((((_nextRebalanceEvent.sub(blockEventstamp))).mul(rewardPerEvent_)));
            }

            /// @dev Using lastUpdateEvent storage variable to store the value
            lastUpdateEvent = 0;

            /// @dev Gas savings using memory variables
            _startEvent = 0;
            _nextRebalanceEvent = 0;
            rewardPerEvent_ = 0;

            uint256 seasonReward = _calculateIfThereIsMoreReward(reset);

            /// @notice Update the _nextRebalanceEvent, _rewardPerEvent, _reservedBalance
            /// for the new starting season
            if(seasonReward > 0 && liquidityPoolTotalSupply != 0) {
                uint256 _rebalanceIntervalInEvents = rebalanceIntervalInEventSlots.mul(TIME_SLOT_IN_SECONDS);

                _startEvent = blockEventstamp;
                reservedBalance_ = reservedBalance_.add(seasonReward);
                _nextRebalanceEvent = blockEventstamp.add(_rebalanceIntervalInEvents);
                rewardPerEvent_ = seasonReward / _rebalanceIntervalInEvents;
            }

            /// @dev Update storage output variables after changing values
            startEvent = _startEvent;
            _reservedBalance = reservedBalance_;
            nextRebalanceEvent = _nextRebalanceEvent;
            _rewardPerEvent = rewardPerEvent_;

            _tryNotifyNewRebalanceEvent(_nextRebalanceEvent);

        }

        /// @notice Output variables
        /// _rewardPerEvent is returned in his correct precision, so is divided by PRECISION
        /// nextRebalanceEvent is updated after season is started (or stopped)
        rewardPerEvent_ = rewardPerEvent_ / FULL_PRECISION;

    }

    /// @notice Calculate the reward for the `account` position
    function _calculateRewardUntilNow(address account) private view returns(uint256 reward) {
        reward = (_rewardPerTokenStored.sub(_positions[account].rewardPerTokenPaid)).mul(_positions[account].lastLiquidityBalance);
    }

    /// @notice Sync `account` position and eventually claim the accrued reward
    function _syncPosition(address account, uint256 liquidityPoolTokenBalance, address[] memory rewardReceivers, uint256[] memory rewardReceiversPercentage) private returns (uint256 claimedReward) {
        FarmingPosition memory position = _positions[account];

        /// @dev Inline definitions for gas savings
        position.rewardTokenToRedeem = position.rewardTokenToRedeem.add(_calculateRewardUntilNow(account));
        position.lastLiquidityBalance = liquidityPoolTokenBalance;
        position.rewardPerTokenPaid = _rewardPerTokenStored;

        /// @dev Claim the accrued reward
        if (_checkRewardParameters(rewardReceivers, rewardReceiversPercentage)) {
            /// @dev claimedReward is divided by PRECISION to transfer the correct amount
            claimedReward = position.rewardTokenToRedeem / FULL_PRECISION;

            if (claimedReward > 0) {
                uint256 rebuiltReward;
                /// @dev Decrement accrued reward (rebuiltReward) from _reservedBalance and position.rewardTokenToRedeem in 10**18 precision
                _reservedBalance = _reservedBalance.sub(rebuiltReward = claimedReward.mul(FULL_PRECISION));
                position.rewardTokenToRedeem = position.rewardTokenToRedeem.sub(rebuiltReward);

                /// @dev Send reward tokens to the reward receivers
                _transferReward(claimedReward, rewardReceivers, rewardReceiversPercentage);
            }
        }

        /// @dev Reassign memory position to storage _positions
        _positions[account] = position;
    }

    function _transferReward(uint256 claimedReward, address[] memory rewardReceivers, uint256[] memory rewardReceiversPercentage) private {
        address _rewardToken = rewardToken;
        uint256 remainingAmount = claimedReward;
        for(uint256 i = 0; i < rewardReceiversPercentage.length; i++) {
            uint256 value = _calculatePercentage(claimedReward, rewardReceiversPercentage[i]);
            _safeTransfer(_rewardToken, rewardReceivers[i], value);
            remainingAmount -= value;
        }
        _safeTransfer(_rewardToken, rewardReceivers[rewardReceivers.length - 1], remainingAmount);
    }

    function _checkRewardParameters(address[] memory rewardReceivers, uint256[] memory rewardReceiversPercentage) private pure returns(bool) {
        if(rewardReceivers.length == 0) {
            return false;
        }
        require(rewardReceiversPercentage.length == (rewardReceivers.length - 1), "percentage");
        uint256 availableAmount = FULL_PRECISION;
        for(uint256 i = 0; i < rewardReceiversPercentage.length; i++) {
            uint256 percentage = rewardReceiversPercentage[i];
            require(percentage != 0 && percentage < availableAmount, "percentage");
            availableAmount -= percentage;
        }
        require(availableAmount != 0, "percentage");
        return true;
    }

    function _calculatePercentage(uint256 total, uint256 percentage) internal pure returns (uint256) {
        return (total * ((percentage * 1e18) / FULL_PRECISION)) / 1e18;
    }

    function _safeTransfer(address tokenAddress, address to, uint256 value) internal {
        if(value == 0) {
            return;
        }
        if(to == address(this)) {
            return;
        }
        if(tokenAddress == address(0)) {
            require(_sendETH(to, value), 'FARMING: TRANSFER_FAILED');
            return;
        }
        if(to == address(0)) {
            return _safeBurn(tokenAddress, value);
        }
        (bool success, bytes memory data) = tokenAddress.call(abi.encodeWithSelector(IERC20Token(address(0)).transfer.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'FARMING: TRANSFER_FAILED');
    }

    function _safeBurn(address erc20TokenAddress, uint256 value) internal {
        (bool result, bytes memory returnData) = erc20TokenAddress.call(abi.encodeWithSelector(0x42966c68, value));//burn(uint256)
        result = result && (returnData.length == 0 || abi.decode(returnData, (bool)));
        if(!result) {
            (result, returnData) = erc20TokenAddress.call(abi.encodeWithSelector(IERC20Token(erc20TokenAddress).transfer.selector, address(0), value));
            result = result && (returnData.length == 0 || abi.decode(returnData, (bool)));
        }
        if(!result) {
            (result, returnData) = erc20TokenAddress.call(abi.encodeWithSelector(IERC20Token(erc20TokenAddress).transfer.selector, 0x000000000000000000000000000000000000dEaD, value));
            result = result && (returnData.length == 0 || abi.decode(returnData, (bool)));
        }
        if(!result) {
            (result, returnData) = erc20TokenAddress.call(abi.encodeWithSelector(IERC20Token(erc20TokenAddress).transfer.selector, 0xdeaDDeADDEaDdeaDdEAddEADDEAdDeadDEADDEaD, value));
            result = result && (returnData.length == 0 || abi.decode(returnData, (bool)));
        }
    }

    function _sendETH(address to, uint256 value) private returns(bool) {
        assembly {
            let res := call(gas(), to, value, 0, 0, 0, 0)
        }
        return true;
    }

    function _balanceOf(address tokenAddress) private view returns(uint256) {
        return tokenAddress == address(0) ? address(this).balance : IERC20Token(tokenAddress).balanceOf(address(this));
    }

    function _tryNotifyNewRebalanceEvent(uint256 _nextRebalanceEvent) private {
        if(_inhibitCallback) {
            return;
        }
        /// @dev Gas savings to avoid multiple storage loads
        address _farmingLiquidityProvider = farmingLiquidityProvider;

        /// @notice Set the new _nextRebalanceEvent to the farmingliquidityprovider if the caller is not the farmingliquidityprovider
        if(msg.sender != _farmingLiquidityProvider) {
            IFarmingLiquidityProvider(_farmingLiquidityProvider).setNextRebalanceEvent(_nextRebalanceEvent);
        }
    }

    function _totalSupply() internal view returns(uint256) {
        address _farmingLiquidityProvider = farmingLiquidityProvider;
        return _farmingLiquidityProvider == address(this) ? totalFarmingLiquidity : IFarmingLiquidityProvider(_farmingLiquidityProvider).totalFarmingLiquidity();
    }

    function _calculateIfThereIsMoreReward(bool reset) private view returns(uint256 seasonReward) {
        seasonReward = _resetOnly && !reset ? 0 : (_balanceOf(rewardToken).mul(FULL_PRECISION)).sub(_reservedBalance);
    }

    function _initialize(address _farmingLiquidityProvider, uint256 _rebalanceIntervalInEvents) internal {
        require(farmingLiquidityProvider == address(0), 'Farming: ALREADY_INITIALIZED');
        require((farmingLiquidityProvider =_farmingLiquidityProvider) != address(0), 'Farming: LIQUIDITY_PROVIDER');
        rebalanceIntervalInEventSlots = _rebalanceIntervalInEvents / TIME_SLOT_IN_SECONDS;
    }

    function _receive() internal view {
        require(rewardToken == address(0));
        require(msg.sig == bytes4(0));
        require(keccak256(msg.data) == keccak256(""));
    }
}
// File: contracts/vert/IVestingContract.sol


pragma solidity ^0.8.0;

interface IVestingContract {
    function completeInitialization() external;
}
// File: contracts/vert/ITreasuryBootstrapRevenueShare.sol


pragma solidity ^0.8.0;


interface ITreasuryBootstrapRevenueShare {
    function completeInitialization(address treasuryAddress) external returns(address operatorAddress);
    function setTreasuryAddress(address newValue) external returns(address oldValue);
    function updatePositionOf(address account, uint256 amount, uint256 vestedAmount) external payable;
    function finalizePosition(uint256 treasuryBalance, uint256 additionalLiquidity, uint256 vestingEnds) external payable;
}
// File: contracts/vert/TreasuryBootstrapRevenueShare.sol


pragma solidity ^0.8.0;











library TreasuryBootstrapRevenueShareLib {

    function collectFees(bytes memory conversionInput, address uniswapV3NonfungiblePositionsManager, address token, address WETH, uint256 tokenId, address conversionAddress, uint24 fee, address uniswapV3SwapRouter) external returns(uint256 collectedAmount0, uint256 collectedAmount1, bytes memory conversionOutput) {
        bytes[] memory data = new bytes[](3);
        INonfungiblePositionManager nonfungiblePositionManager = INonfungiblePositionManager(uniswapV3NonfungiblePositionsManager);
        data[0] = abi.encodeWithSelector(nonfungiblePositionManager.collect.selector, INonfungiblePositionManager.CollectParams({
            tokenId: tokenId,
            recipient: address(0),
            amount0Max: 0xffffffffffffffffffffffffffffffff,
            amount1Max: 0xffffffffffffffffffffffffffffffff
        }));
        data[1] = abi.encodeWithSelector(nonfungiblePositionManager.unwrapWETH9.selector, 0, address(this));
        data[2] = abi.encodeWithSelector(nonfungiblePositionManager.sweepToken.selector, token, 0, conversionAddress != address(0) ? conversionAddress : address(this));
        (collectedAmount0, collectedAmount1) = abi.decode(IMulticall(uniswapV3NonfungiblePositionsManager).multicall(data)[0], (uint256, uint256));

        uint256 amount = token < WETH ? collectedAmount0 : collectedAmount1;

        if(amount > 0) {
            conversionOutput = _convertAmountInETH(amount, conversionInput, token, WETH, conversionAddress, fee, uniswapV3SwapRouter);
        }
    }

    function _convertAmountInETH(uint256 amount, bytes memory conversionInput, address token, address WETH, address conversionAddress, uint24 fee, address uniswapV3SwapRouter) private returns(bytes memory conversionOutput) {

        if(conversionAddress != address(0)) {
            uint256 codeLength;
            assembly {
                codeLength := extcodesize(conversionAddress)
            }
            if(codeLength > 0) {
                return IConvertInETH(conversionAddress).convert(token, amount, conversionInput);
            } else {
                return "";
            }
        }

        (uint24 _fee, uint256 amountOutMinimum) = abi.decode(conversionInput, (uint24, uint256));

        ISwapRouter swapRouter = ISwapRouter(uniswapV3SwapRouter);

        IERC20Approve(token).approve(address(swapRouter), amount);

        bytes[] memory data = new bytes[](2);
        data[0] = abi.encodeWithSelector(swapRouter.exactInput.selector, ISwapRouter.ExactInputParams({
            path : abi.encodePacked(token, _fee == 0 ? fee : _fee, WETH),
            recipient : address(0),
            deadline : block.timestamp + 10000,
            amountIn : amount,
            amountOutMinimum : amountOutMinimum
        }));
        data[1] = abi.encodeWithSelector(swapRouter.unwrapWETH9.selector, 0, address(this));
        conversionOutput = swapRouter.multicall(data)[0];
    }

    function _safeTransfer(address tokenAddress, address to, uint256 value) internal {
        if(value == 0) {
            return;
        }
        if(to == address(this)) {
            return;
        }
        if(tokenAddress == address(0)) {
            require(_sendETH(to, value), 'FARMING: TRANSFER_FAILED');
            return;
        }
        if(to == address(0)) {
            return _safeBurn(tokenAddress, value);
        }
        (bool success, bytes memory data) = tokenAddress.call(abi.encodeWithSelector(IERC20Token(address(0)).transfer.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'FARMING: TRANSFER_FAILED');
    }

    function _safeBurn(address erc20TokenAddress, uint256 value) internal {
        (bool result, bytes memory returnData) = erc20TokenAddress.call(abi.encodeWithSelector(0x42966c68, value));//burn(uint256)
        result = result && (returnData.length == 0 || abi.decode(returnData, (bool)));
        if(!result) {
            (result, returnData) = erc20TokenAddress.call(abi.encodeWithSelector(IERC20Token(erc20TokenAddress).transfer.selector, address(0), value));
            result = result && (returnData.length == 0 || abi.decode(returnData, (bool)));
        }
        if(!result) {
            (result, returnData) = erc20TokenAddress.call(abi.encodeWithSelector(IERC20Token(erc20TokenAddress).transfer.selector, 0x000000000000000000000000000000000000dEaD, value));
            result = result && (returnData.length == 0 || abi.decode(returnData, (bool)));
        }
        if(!result) {
            (result, returnData) = erc20TokenAddress.call(abi.encodeWithSelector(IERC20Token(erc20TokenAddress).transfer.selector, 0xdeaDDeADDEaDdeaDdEAddEADDEAdDeadDEADDEaD, value));
            result = result && (returnData.length == 0 || abi.decode(returnData, (bool)));
        }
    }

    function _sendETH(address to, uint256 value) private returns(bool) {
        assembly {
            let res := call(gas(), to, value, 0, 0, 0, 0)
        }
        return true;
    }
}

contract TreasuryBootstrapRevenueShare is ITreasuryBootstrapRevenueShare, Ownable, BaseFarming {

    uint256 public constant MONTH_IN_SECONDS = 2628000;

    struct AccountPosition {
        uint256 vestedAmount;
        uint256 ethAmount;
        uint128 positionLiquidity;
        uint256 farmingBalance;
    }
    uint256 public accounts;

    address public immutable destinationAddress;
    address public immutable uniswapV3NonfungiblePositionsManager;
    address public immutable uniswapV3SwapRouter;
    address public immutable WETH;

    address public pool;

    uint24 public immutable fee;
    uint160 public immutable sqrtPriceX96;
    int24 public tickLower;
    int24 public tickUpper;
    uint256 public vestingEnds;
    uint256 public priceSlippagePercentage;

    mapping(address => AccountPosition) public positionOf;

    uint256 public farmingDuration;

    address public token;

    address public treasuryAddress;

    uint256 public treasuryFarmingBalance;

    uint256 public tokenId;

    address public conversionAddress;

    uint256 public redeemableETH;

    constructor(address initialOwner, address _destinationAddress, address _conversionAddress, uint256 _farmingDuration, address _uniswapV3NonfungiblePositionsManager, address _uniswapV3SwapRouter, uint24 _fee, uint160 _sqrtPriceX96, uint256 _priceSlippagePercentage, int24 _tickLower, int24 _tickUpper) Ownable(initialOwner) {
        _inhibitCallback = true;
        _initialize(address(this), MONTH_IN_SECONDS * (farmingDuration = _farmingDuration));
        destinationAddress = _destinationAddress;
        conversionAddress = _conversionAddress;
        WETH = IPeripheryImmutableState(uniswapV3NonfungiblePositionsManager = _uniswapV3NonfungiblePositionsManager).WETH9();
        uniswapV3SwapRouter = _uniswapV3SwapRouter;
        tickLower = _tickLower;
        tickUpper = _tickUpper;
        fee = _fee;
        sqrtPriceX96 = _sqrtPriceX96;
        priceSlippagePercentage = _priceSlippagePercentage;
    }

    receive() external payable {
        _receive();
    }

    function onERC721Received(address,address,uint256,bytes calldata) external view returns (bytes4) {
        require(tokenId == 0);
        return this.onERC721Received.selector;
    }

    function setPriceSlippagePercentage(uint256 newValue) external onlyOwner {
        priceSlippagePercentage = newValue;
    }

    function setConversionAddress(address newValue) external onlyOwner returns(address oldValue) {
        oldValue = conversionAddress;
        conversionAddress = newValue;
    }

    function completeInitialization(address _treasuryAddress) override external returns(address operatorAddress) {
        require(token == address(0));
        treasuryAddress = _treasuryAddress;
        uint256 tokenPosition = (token = msg.sender) < WETH ? 0 : 1;
        return pool = IPoolInitializer(uniswapV3NonfungiblePositionsManager).createAndInitializePoolIfNecessary(
            tokenPosition == 0 ? msg.sender : WETH,
            tokenPosition == 1 ? msg.sender : WETH,
            fee,
            sqrtPriceX96
        );
    }

    function updatePositionOf(address account, uint256 amount, uint256 vestedAmount) override external payable {

        require(msg.sender == token);

        _increaseReservedBalance(msg.value);
        redeemableETH += msg.value;

        AccountPosition storage _accountPosition = positionOf[account];
        if(_accountPosition.ethAmount == 0) {
            accounts++;
        }

        _accountPosition.ethAmount += msg.value;

        (uint128 liquidity, uint256 remainingAmount) = _mintOrIncreaseLiquidity(amount);

        amount += vestedAmount;

        _accountPosition.vestedAmount += vestedAmount + remainingAmount;
        _accountPosition.positionLiquidity += liquidity;

        _accountPosition.farmingBalance += amount;
        totalFarmingLiquidity += amount;
        require(_accountPosition.farmingBalance <= UtilitiesLib.ANTI_WHALE_MAX_BALANCE, "Anti-whale system active");

        _sync(address(0), account, 0, _accountPosition.farmingBalance, totalFarmingLiquidity);
    }

    function finalizePosition(uint256 treasuryBalance, uint256 additionalLiquidity, uint256 _vestingEnds) external payable {
        require(msg.sender == token);
        vestingEnds = _vestingEnds;
        (,uint256 remainingAmount) = _mintOrIncreaseLiquidity(treasuryBalance + additionalLiquidity);
        if(remainingAmount > 0) {
            _safeBurn(token, remainingAmount);
        }

        treasuryFarmingBalance += treasuryBalance;
        totalFarmingLiquidity += treasuryBalance;
        address[] memory rewardReceivers = new address[](1);
        _sync(address(0), rewardReceivers[0] = treasuryAddress, 0, treasuryFarmingBalance, totalFarmingLiquidity);
        _claimReward(rewardReceivers[0], rewardReceivers, new uint256[](0));
    }

    function redeemVestingResult() external {
        AccountPosition storage _accountPosition = positionOf[msg.sender];
        uint256 vestedAmount = _accountPosition.vestedAmount;
        uint256 ethAmount = _accountPosition.ethAmount;
        require(vestedAmount != 0 && ethAmount != 0, "unknown account");
        _accountPosition.vestedAmount = 0;
        _accountPosition.ethAmount = 0;
        address[] memory rewardReceivers = new address[](1);
        if(vestingEnds == 0 || block.timestamp < vestingEnds) {
            _decreaseReservedBalance(ethAmount);
            redeemableETH -= ethAmount;
            _safeTransfer(address(0), msg.sender, ethAmount);
            _safeBurn(token, vestedAmount);
            totalFarmingLiquidity -= _accountPosition.farmingBalance;
            _sync(msg.sender, address(0), _accountPosition.farmingBalance = 0, 0, totalFarmingLiquidity);
            rewardReceivers[0] = treasuryAddress;
            delete positionOf[msg.sender];
            accounts--;
        } else {
            _safeTransfer(token, rewardReceivers[0] = msg.sender, vestedAmount);
            sendRemainingETH();
        }
        _claimReward(msg.sender, rewardReceivers, new uint256[](0));
    }

    modifier afterVestingPeriod() {
        _afterVestingPeriod();
        _;
    }

    function sendRemainingETH() public afterVestingPeriod {
        _sendRemainingETH();
    }

    function setTreasuryAddress(address newValue) external afterVestingPeriod returns(address oldValue) {
        require((oldValue = treasuryAddress) == msg.sender, "unauthorized");
        treasuryAddress = newValue;
        _sync(oldValue, newValue, 0, treasuryFarmingBalance, totalFarmingLiquidity);
        address[] memory rewardReceivers = new address[](1);
        rewardReceivers[0] = newValue;
        _claimReward(oldValue, rewardReceivers, new uint256[](0));
    }

    function claimReward(address[] memory rewardReceivers, uint256[] memory rewardReceiversPercentage) external afterVestingPeriod  returns(uint256 claimedReward, uint256 _nextRebalanceEvent, uint256 rewardPerEvent_) {
        return _claimReward(msg.sender, rewardReceivers, rewardReceiversPercentage);
    }

    function claimRewardOf(address account) external afterVestingPeriod returns(uint256 claimedReward, uint256 _nextRebalanceEvent, uint256 rewardPerEvent_) {
        address[] memory rewardReceivers = new address[](1);
        return _claimReward(rewardReceivers[0] = account, rewardReceivers, new uint256[](0));
    }

    function redeemRevenueSharePositionForever(uint256 amount0Min, uint256 amount1Min) external afterVestingPeriod returns (uint256 amount0, uint256 amount1) {
        AccountPosition storage _accountPosition = positionOf[msg.sender];
        require(_accountPosition.positionLiquidity != 0, "unknown account");
        uint256 vestedAmount = _accountPosition.vestedAmount;
        _accountPosition.vestedAmount = 0;
        _accountPosition.ethAmount = 0;
        if(vestedAmount != 0) {
            _safeTransfer(token, msg.sender, vestedAmount);
        }
        address to = address(0);
        uint256 toBalance = 0;
        if(farmingDuration == 1) {
            to = treasuryAddress;
            treasuryFarmingBalance += _accountPosition.farmingBalance;
            toBalance = treasuryFarmingBalance;
        } else {
            totalFarmingLiquidity -= _accountPosition.farmingBalance;
        }
        _sync(msg.sender, to, _accountPosition.farmingBalance = 0, toBalance, totalFarmingLiquidity);
        address[] memory rewardReceivers = new address[](1);
        rewardReceivers[0] = msg.sender;
        _claimReward(msg.sender, rewardReceivers, new uint256[](0));

        bytes[] memory data = new bytes[](3);
        INonfungiblePositionManager nonfungiblePositionManager = INonfungiblePositionManager(uniswapV3NonfungiblePositionsManager);

        (amount0, amount1) = nonfungiblePositionManager.decreaseLiquidity(INonfungiblePositionManager.DecreaseLiquidityParams({
            tokenId: tokenId,
            liquidity: _accountPosition.positionLiquidity,
            amount0Min: amount0Min,
            amount1Min: amount1Min,
            deadline : block.timestamp + 1000
        }));

        delete positionOf[msg.sender];
        accounts--;

        data[0] = abi.encodeWithSelector(nonfungiblePositionManager.collect.selector, INonfungiblePositionManager.CollectParams({
            tokenId: tokenId,
            recipient: address(0),
            amount0Max: uint128(amount0),
            amount1Max: uint128(amount1)
        }));
        data[1] = abi.encodeWithSelector(nonfungiblePositionManager.unwrapWETH9.selector, 0, msg.sender);
        data[2] = abi.encodeWithSelector(nonfungiblePositionManager.sweepToken.selector, token, 0, msg.sender);
        (amount0, amount1) = abi.decode(IMulticall(uniswapV3NonfungiblePositionsManager).multicall(data)[0], (uint256, uint256));
    }

    function collectFees(bytes memory conversionInput) external returns(uint256 collectedAmount0, uint256 collectedAmount1, bytes memory conversionOutput) {
        (collectedAmount0, collectedAmount1, conversionOutput) = TreasuryBootstrapRevenueShareLib.collectFees(conversionInput, uniswapV3NonfungiblePositionsManager, token, WETH, tokenId, conversionAddress, fee, uniswapV3SwapRouter);
        _afterVestingPeriod();
    }

    function _mintOrIncreaseLiquidity(uint256 amount) private returns(uint128 liquidity, uint256 remainingAmount) {

        uint256 tokenPosition = token < WETH ? 0 : 1;

        IERC20Approve(token).approve(uniswapV3NonfungiblePositionsManager, amount);

        (uint256 amount0, uint256 amount1) = tokenPosition == 0 ? (amount, uint256(0)) : (uint256(0), amount);

        if(tokenId == 0) {
            (tokenId, liquidity, amount0, amount1) = INonfungiblePositionManager(uniswapV3NonfungiblePositionsManager).mint(INonfungiblePositionManager.MintParams({
                token0: tokenPosition == 0 ? token : WETH,
                token1: tokenPosition == 1 ? token : WETH,
                fee: fee,
                tickLower: tickLower,
                tickUpper: tickUpper,
                amount0Desired: amount0,
                amount1Desired: amount1,
                amount0Min: _calculatePercentage(amount0, FULL_PRECISION - priceSlippagePercentage),
                amount1Min: _calculatePercentage(amount1, FULL_PRECISION - priceSlippagePercentage),
                recipient: address(this),
                deadline: block.timestamp + 10000
            }));
        } else {
            (liquidity, amount0, amount1) = INonfungiblePositionManager(uniswapV3NonfungiblePositionsManager).increaseLiquidity(INonfungiblePositionManager.IncreaseLiquidityParams({
                tokenId: tokenId,
                amount0Desired: amount0,
                amount1Desired: amount1,
                amount0Min: _calculatePercentage(amount0, FULL_PRECISION - priceSlippagePercentage),
                amount1Min: _calculatePercentage(amount1, FULL_PRECISION - priceSlippagePercentage),
                deadline: block.timestamp + 10000
            }));
        }
        remainingAmount = (amount - (tokenPosition == 0 ? amount0 : amount1));
    }

    function _sendRemainingETH() private {
        uint256 _redeemableETH = redeemableETH;
        if(_redeemableETH != 0) {
            redeemableETH = 0;
            _decreaseReservedBalance(_redeemableETH);
            _safeTransfer(address(0), destinationAddress, _redeemableETH);
        }
    }

    function _afterVestingPeriod() private {
        require(vestingEnds != 0 && block.timestamp >= vestingEnds, "in vesting period");
        _sendRemainingETH();
        if(nextRebalanceEvent != 0 && block.timestamp >= nextRebalanceEvent && farmingDuration != 1) {
            rebalanceIntervalInEventSlots = (MONTH_IN_SECONDS * (farmingDuration = (farmingDuration /= 2) == 0 ? 1 : farmingDuration)) / TIME_SLOT_IN_SECONDS;
        }
        address[] memory rewardReceivers = new address[](1);
        _claimReward(rewardReceivers[0] = treasuryAddress, rewardReceivers, new uint256[](0));
    }
}

interface IConvertInETH {
    function convert(address tokenAddress, uint256 amount, bytes calldata conversionInput) external returns(bytes memory conversionOutput);
}