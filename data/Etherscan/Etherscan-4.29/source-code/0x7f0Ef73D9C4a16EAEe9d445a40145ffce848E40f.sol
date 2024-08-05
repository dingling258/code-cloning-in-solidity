// SPDX-License-Identifier: MIT
pragma solidity =0.8.10;










interface IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint256 digits);
    function totalSupply() external view returns (uint256 supply);

    function balanceOf(address _owner) external view returns (uint256 balance);

    function transfer(address _to, uint256 _value) external returns (bool success);

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool success);

    function approve(address _spender, uint256 _value) external returns (bool success);

    function allowance(address _owner, address _spender) external view returns (uint256 remaining);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}






interface IAggregationExecutor {
  function callBytes(bytes calldata data) external payable; // 0xd9c45357

  // callbytes per swap sequence
  function swapSingleSequence(bytes calldata data) external;

  function finalTransactionProcessing(
    address tokenIn,
    address tokenOut,
    address to,
    bytes calldata destTokenFeeData
  ) external;
}







interface IMetaAggregationRouterV2 {
    struct SwapDescriptionV2 {
        IERC20 srcToken;
        IERC20 dstToken;
        address[] srcReceivers; // transfer src token to these addresses, default
        uint256[] srcAmounts;
        address[] feeReceivers;
        uint256[] feeAmounts;
        address dstReceiver;
        uint256 amount;
        uint256 minReturnAmount;
        uint256 flags;
        bytes permit;
    }

    /// @dev  use for swapGeneric and swap to avoid stack too deep
    struct SwapExecutionParams {
        address callTarget; // call this address
        address approveTarget; // approve this address if _APPROVE_FUND set
        bytes targetData;
        SwapDescriptionV2 desc;
        bytes clientData;
    }

    struct SimpleSwapData {
        address[] firstPools;
        uint256[] firstSwapAmounts;
        bytes[] swapDatas;
        uint256 deadline;
        bytes positiveSlippageData;
    }

    function swap(
        SwapExecutionParams calldata execution
    ) external payable returns (uint256, uint256);

    function swapSimpleMode(
        IAggregationExecutor caller,
        SwapDescriptionV2 memory desc,
        bytes calldata executorData,
        bytes calldata clientData
    ) external returns (uint256, uint256);
}






interface IExecutorHelper {
  struct Swap {
    bytes data;
    bytes32 selectorAndFlags; // [selector (32 bits) + flags (224 bits)]; selector is 4 most significant bytes; flags are stored in 4 least significant bytes.
  }

  struct SwapExecutorDescription {
    Swap[][] swapSequences;
    address tokenIn;
    address tokenOut;
    uint256 minTotalAmountOut;
    address to;
    uint256 deadline;
    bytes positiveSlippageData;
  }

  struct UniSwap {
    address pool;
    address tokenIn;
    address tokenOut;
    address recipient;
    uint256 collectAmount; // amount that should be transferred to the pool
    uint32 swapFee;
    uint32 feePrecision;
    uint32 tokenWeightInput;
  }

  struct StableSwap {
    address pool;
    address tokenFrom;
    address tokenTo;
    uint8 tokenIndexFrom;
    uint8 tokenIndexTo;
    uint256 dx;
    uint256 poolLength;
    address poolLp;
    bool isSaddle; // true: saddle, false: stable
  }

  struct CurveSwap {
    address pool;
    address tokenFrom;
    address tokenTo;
    int128 tokenIndexFrom;
    int128 tokenIndexTo;
    uint256 dx;
    bool usePoolUnderlying;
    bool useTriCrypto;
  }

  struct UniswapV3KSElastic {
    address recipient;
    address pool;
    address tokenIn;
    address tokenOut;
    uint256 swapAmount;
    uint160 sqrtPriceLimitX96;
    bool isUniV3; // true = UniV3, false = KSElastic
  }

  struct BalancerV2 {
    address vault;
    bytes32 poolId;
    address assetIn;
    address assetOut;
    uint256 amount;
  }

  struct DODO {
    address recipient;
    address pool;
    address tokenFrom;
    address tokenTo;
    uint256 amount;
    address sellHelper;
    bool isSellBase;
    bool isVersion2;
  }

  struct GMX {
    address vault;
    address tokenIn;
    address tokenOut;
    uint256 amount;
    address receiver;
  }

  struct Synthetix {
    address synthetixProxy;
    address tokenIn;
    address tokenOut;
    bytes32 sourceCurrencyKey;
    uint256 sourceAmount;
    bytes32 destinationCurrencyKey;
    bool useAtomicExchange;
  }

  struct Platypus {
    address pool;
    address tokenIn;
    address tokenOut;
    address recipient;
    uint256 collectAmount; // amount that should be transferred to the pool
  }

  struct PSM {
    address router;
    address tokenIn;
    address tokenOut;
    uint256 amountIn;
    address recipient;
  }

  struct WSTETH {
    address pool;
    uint256 amount;
    bool isWrapping;
  }

  struct Maverick {
    address pool;
    address tokenIn;
    address tokenOut;
    address recipient;
    uint256 swapAmount;
    uint256 sqrtPriceLimitD18;
  }

  struct SyncSwap {
    bytes _data;
    address vault;
    address tokenIn;
    address pool;
    uint256 collectAmount;
  }

  struct AlgebraV1 {
    address recipient;
    address pool;
    address tokenIn;
    address tokenOut;
    uint256 swapAmount;
    uint160 sqrtPriceLimitX96;
    uint256 senderFeeOnTransfer; // [ FoT_FLAG(1 bit) ... SENDER_ADDRESS(160 bits) ]
  }

  struct BalancerBatch {
    address vault;
    bytes32[] poolIds;
    address[] path; // swap path from assetIn to assetOut
    bytes[] userDatas;
    uint256 amountIn; // assetIn amount
  }

  struct Mantis {
    address pool;
    address tokenIn;
    address tokenOut;
    uint256 amount;
    address recipient;
  }

  struct IziSwap {
    address pool;
    address tokenIn;
    address tokenOut;
    address recipient;
    uint256 swapAmount;
    int24 limitPoint;
  }

  struct TraderJoeV2 {
    address recipient;
    address pool;
    address tokenIn;
    address tokenOut;
    uint256 collectAmount; // most significant 1 bit is to determine whether pool is v2.1, else v2.0
  }

  struct LevelFiV2 {
    address pool;
    address fromToken;
    address toToken;
    uint256 amountIn;
    uint256 minAmountOut;
    address recipient; // receive token out
  }

  struct GMXGLP {
    address rewardRouter;
    address stakedGLP;
    address glpManager;
    address yearnVault;
    address tokenIn;
    address tokenOut;
    uint256 swapAmount;
    address recipient;
  }

  struct Vooi {
    address pool;
    address fromToken;
    address toToken;
    uint256 fromID;
    uint256 toID;
    uint256 fromAmount;
    address to;
  }

  struct VelocoreV2 {
    address vault;
    uint256 amount;
    address tokenIn;
    address tokenOut;
    address stablePool; // if not empty then use stable pool
    address wrapToken;
    bool isConvertFirst;
  }

  struct MaticMigrate {
    address pool;
    address tokenAddress; // should be POL
    uint256 amount;
    address recipient; // empty if migrate
  }

  struct Kokonut {
    address pool;
    uint256 dx;
    uint256 tokenIndexFrom;
    address fromToken;
    address toToken;
  }

  struct BalancerV1 {
    address pool;
    address tokenIn;
    address tokenOut;
    uint256 amount;
  }

  struct SwaapV2 {
    address router;
    uint256 amount;
    bytes data;
    address tokenIn;
    address tokenOut;
    address recipient;
  }

  struct ArbswapStable {
    address pool;
    uint256 dx;
    uint256 tokenIndexFrom;
    address tokenIn;
    address tokenOut;
  }

  struct BancorV2 {
    address pool;
    address[] swapPath;
    uint256 amount;
    address recipient;
  }

  struct Ambient {
    address pool;
    uint128 qty;
    address base;
    address quote;
    uint256 poolIdx;
    uint8 settleFlags;
  }

  struct UniV1 {
    address pool;
    uint256 amount;
    address tokenIn;
    address tokenOut;
    address recipient;
  }

  struct LighterV2 {
    address orderBook;
    uint256 amount;
    bool isAsk; // isAsk = orderBook.isAskOrder(orderId);
    address tokenIn;
    address tokenOut;
    address recipient;
  }

  struct EtherFiWeETH {
    uint256 amount;
    bool isWrapping;
  }

  struct Kelp {
    uint256 amount;
    address tokenIn;
  }

  struct EthenaSusde {
    uint256 amount;
    address recipient;
  }

  struct RocketPool {
    address pool;
    uint256 isDepositAndAmount; // 1 isDeposit + 127 empty + 128 amount token in
  }

  struct MakersDAI {
    uint256 isRedeemAndAmount; // 1 isRedeem + 127 empty + 128 amount token in
    address recipient;
  }

  struct Renzo {
    address pool;
    uint256 amount;
    address tokenIn;
    address tokenOut;
  }

  struct FrxETH {
    address pool;
    uint256 amount;
    address tokenOut;
  }

  struct SfrxETH {
    address pool;
    uint256 amount;
    address tokenOut;
    address recipient;
  }

  struct SfrxETHConvertor {
    address pool;
    uint256 isDepositAndAmount; // 1 isDeposit + 127 empty + 128 amount token in
    address tokenIn;
    address tokenOut;
    address recipient;
  }

  struct OriginETH {
    address pool;
    uint256 amount;
  }

  function executeUniswap(
    bytes memory data,
    uint256 flagsAndPrevAmountOut
  ) external payable returns (uint256);

  function executeStableSwap(
    bytes memory data,
    uint256 flagsAndPrevAmountOut
  ) external payable returns (uint256);

  function executeCurve(
    bytes memory data,
    uint256 flagsAndPrevAmountOut
  ) external payable returns (uint256);

  function executeKSClassic(
    bytes memory data,
    uint256 flagsAndPrevAmountOut
  ) external payable returns (uint256);

  function executeUniV3KSElastic(
    bytes memory data,
    uint256 flagsAndPrevAmountOut
  ) external payable returns (uint256);

  function executeRfq(
    bytes memory data,
    uint256 flagsAndPrevAmountOut
  ) external payable returns (uint256);

  function executeBalV2(
    bytes memory data,
    uint256 flagsAndPrevAmountOut
  ) external payable returns (uint256);

  function executeDODO(
    bytes memory data,
    uint256 flagsAndPrevAmountOut
  ) external payable returns (uint256);

  function executeVelodrome(
    bytes memory data,
    uint256 flagsAndPrevAmountOut
  ) external payable returns (uint256);

  function executeGMX(
    bytes memory data,
    uint256 flagsAndPrevAmountOut
  ) external payable returns (uint256);

  function executePlatypus(
    bytes memory data,
    uint256 flagsAndPrevAmountOut
  ) external payable returns (uint256);

  function executeWrappedstETH(
    bytes memory data,
    uint256 flagsAndPrevAmountOut
  ) external payable returns (uint256);

  function executeStEth(
    bytes memory data,
    uint256 flagsAndPrevAmountOut
  ) external payable returns (uint256);

  function executeSynthetix(
    bytes memory data,
    uint256 flagsAndPrevAmountOut
  ) external payable returns (uint256);

  function executeHashflow(
    bytes memory data,
    uint256 flagsAndPrevAmountOut
  ) external payable returns (uint256);

  function executePSM(
    bytes memory data,
    uint256 flagsAndPrevAmountOut
  ) external payable returns (uint256);

  function executeFrax(
    bytes memory data,
    uint256 flagsAndPrevAmountOut
  ) external payable returns (uint256);

  function executeCamelot(
    bytes memory data,
    uint256 flagsAndPrevAmountOut
  ) external payable returns (uint256);

  function executeKyberLimitOrder(
    bytes memory data,
    uint256 flagsAndPrevAmountOut
  ) external payable returns (uint256);

  function executeMaverick(
    bytes memory data,
    uint256 flagsAndPrevAmountOut
  ) external payable returns (uint256);

  function executeSyncSwap(
    bytes memory data,
    uint256 flagsAndPrevAmountOut
  ) external payable returns (uint256);

  function executeAlgebraV1(
    bytes memory data,
    uint256 flagsAndPrevAmountOut
  ) external payable returns (uint256);

  function executeBalancerBatch(
    bytes memory data,
    uint256 flagsAndPrevAmountOut
  ) external payable returns (uint256);

  function executeWombat(
    bytes memory data,
    uint256 flagsAndPrevAmountOut
  ) external payable returns (uint256);

  function executeMantis(
    bytes memory data,
    uint256 flagsAndPrevAmountOut
  ) external payable returns (uint256);

  function executeIziSwap(
    bytes memory data,
    uint256 flagsAndPrevAmountOut
  ) external payable returns (uint256);

  function executeWooFiV2(
    bytes memory data,
    uint256 flagsAndPrevAmountOut
  ) external payable returns (uint256);

  function executeTraderJoeV2(
    bytes memory data,
    uint256 flagsAndPrevAmountOut
  ) external payable returns (uint256);

  function executePancakeStableSwap(
    bytes memory data,
    uint256 flagsAndPrevAmountOut
  ) external payable returns (uint256);

  function executeLevelFiV2(
    bytes memory data,
    uint256 flagsAndPrevAmountOut
  ) external payable returns (uint256);

  function executeGMXGLP(
    bytes memory data,
    uint256 flagsAndPrevAmountOut
  ) external payable returns (uint256);

  function executeVooi(
    bytes memory data,
    uint256 flagsAndPrevAmountOut
  ) external payable returns (uint256);

  function executeVelocoreV2(
    bytes memory data,
    uint256 flagsAndPrevAmountOut
  ) external payable returns (uint256);

  function executeMaticMigrate(
    bytes memory data,
    uint256 flagsAndPrevAmountOut
  ) external payable returns (uint256);

  function executeSmardex(
    bytes memory data,
    uint256 flagsAndPrevAmountOut
  ) external payable returns (uint256);

  function executeSolidlyV2(
    bytes memory data,
    uint256 flagsAndPrevAmountOut
  ) external payable returns (uint256);

  function executeKokonut(
    bytes memory data,
    uint256 flagsAndPrevAmountOut
  ) external payable returns (uint256);

  function executeBalancerV1(
    bytes memory data,
    uint256 flagsAndPrevAmountOut
  ) external payable returns (uint256);

  function executeSwaapV2(
    bytes memory data,
    uint256 flagsAndPrevAmountOut
  ) external payable returns (uint256);

  function executeNomiswapStable(
    bytes memory data,
    uint256 flagsAndPrevAmountOut
  ) external payable returns (uint256);

  function executeArbswapStable(
    bytes memory data,
    uint256 flagsAndPrevAmountOut
  ) external payable returns (uint256);

  function executeBancorV2(
    bytes memory data,
    uint256 flagsAndPrevAmountOut
  ) external payable returns (uint256);

  function executeBancorV3(
    bytes memory data,
    uint256 flagsAndPrevAmountOut
  ) external payable returns (uint256);

  function executeAmbient(
    bytes memory data,
    uint256 flagsAndPrevAmountOut
  ) external payable returns (uint256);

  function executeUniV1(
    bytes memory data,
    uint256 flagsAndPrevAmountOut
  ) external payable returns (uint256);

  function executeNative(
    bytes memory data,
    uint256 flagsAndPrevAmountOut
  ) external payable returns (uint256);

  function executeBebop(
    bytes memory data,
    uint256 flagsAndPrevAmountOut
  ) external payable returns (uint256);

  function executeLighterV2(
    bytes memory data,
    uint256 flagsAndPrevAmountOut
  ) external payable returns (uint256);

  function executeEtherFieETH(
    bytes memory data,
    uint256 flagsAndPrevAmountOut
  ) external payable returns (uint256);

  function executeEtherFiWeETH(
    bytes memory data,
    uint256 flagsAndPrevAmountOut
  ) external payable returns (uint256);

  function executeKelp(
    bytes memory data,
    uint256 flagsAndPrevAmountOut
  ) external payable returns (uint256);

  function executeRocketPool(
    bytes memory data,
    uint256 flagsAndPrevAmountOut
  ) external payable returns (uint256);

  function executeEthenaSusde(
    bytes memory data,
    uint256 flagsAndPrevAmountOut
  ) external payable returns (uint256);

  function executeMakersDAI(
    bytes memory data,
    uint256 flagsAndPrevAmountOut
  ) external payable returns (uint256);

  function executeRenzo(
    bytes memory data,
    uint256 flagsAndPrevAmountOut
  ) external payable returns (uint256);

  function executeWBETH(
    bytes memory data,
    uint256 flagsAndPrevAmountOut
  ) external payable returns (uint256);

  function executeMantleETH(
    bytes memory data,
    uint256 flagsAndPrevAmountOut
  ) external payable returns (uint256);

  function executeFrxETH(
    bytes memory data,
    uint256 flagsAndPrevAmountOut
  ) external payable returns (uint256);

  function executeSfrxETH(
    bytes memory data,
    uint256 flagsAndPrevAmountOut
  ) external payable returns (uint256);

  function executeSfrxETHConvertor(
    bytes memory data,
    uint256 flagsAndPrevAmountOut
  ) external payable returns (uint256);

  function executeSwellETH(
    bytes memory data,
    uint256 flagsAndPrevAmountOut
  ) external payable returns (uint256);

  function executeRswETH(
    bytes memory data,
    uint256 flagsAndPrevAmountOut
  ) external payable returns (uint256);

  function executeStaderETHx(
    bytes memory data,
    uint256 flagsAndPrevAmountOut
  ) external payable returns (uint256);

  function executeOriginETH(
    bytes memory data,
    uint256 flagsAndPrevAmountOut
  ) external payable returns (uint256);

  function executePrimeETH(
    bytes memory data,
    uint256 flagsAndPrevAmountOut
  ) external payable returns (uint256);

  function executeMantleUsd(
    bytes memory data,
    uint256 flagsAndPrevAmountOut
  ) external payable returns (uint256);

  function executeBedrockUniETH(
    bytes memory data,
    uint256 flagsAndPrevAmountOut
  ) external payable returns (uint256);

  function executeMaiPSM(
    bytes memory data,
    uint256 flagsAndPrevAmountOut
  ) external payable returns (uint256);
}







contract KyberInputScalingHelper {
    uint256 private constant _PARTIAL_FILL = 0x01;
    uint256 private constant _REQUIRES_EXTRA_ETH = 0x02;
    uint256 private constant _SHOULD_CLAIM = 0x04;
    uint256 private constant _BURN_FROM_MSG_SENDER = 0x08;
    uint256 private constant _BURN_FROM_TX_ORIGIN = 0x10;
    uint256 private constant _SIMPLE_SWAP = 0x20;

    // fee data in case taking in dest token
    struct PositiveSlippageFeeData {
        uint256 partnerPSInfor; // [partnerReceiver (160 bit) + partnerPercent(96bits)]
        uint256 expectedReturnAmount;
    }

    struct Swap {
        bytes data;
        bytes32 selectorAndFlags; // [selector (32 bits) + flags (224 bits)]; selector is 4 most significant bytes; flags are stored in 4 least significant bytes.
    }

    struct SimpleSwapData {
        address[] firstPools;
        uint256[] firstSwapAmounts;
        bytes[] swapDatas;
        uint256 deadline;
        bytes positiveSlippageData;
    }

    struct SwapExecutorDescription {
        Swap[][] swapSequences;
        address tokenIn;
        address tokenOut;
        address to;
        uint256 deadline;
        bytes positiveSlippageData;
    }

    function getScaledInputData(
        bytes calldata inputData,
        uint256 newAmount
    ) public pure returns (bytes memory) {
        bytes4 selector = bytes4(inputData[:4]);
        bytes calldata dataToDecode = inputData[4:];

        if (selector == IMetaAggregationRouterV2.swap.selector) {
            IMetaAggregationRouterV2.SwapExecutionParams memory params = abi.decode(
                dataToDecode,
                (IMetaAggregationRouterV2.SwapExecutionParams)
            );

            (params.desc, params.targetData) = _getScaledInputDataV2(
                params.desc,
                params.targetData,
                newAmount,
                _flagsChecked(params.desc.flags, _SIMPLE_SWAP)
            );
            return abi.encodeWithSelector(selector, params);
        } else if (selector == IMetaAggregationRouterV2.swapSimpleMode.selector) {
            (
                address callTarget,
                IMetaAggregationRouterV2.SwapDescriptionV2 memory desc,
                bytes memory targetData,
                bytes memory clientData
            ) = abi.decode(
                    dataToDecode,
                    (address, IMetaAggregationRouterV2.SwapDescriptionV2, bytes, bytes)
                );

            (desc, targetData) = _getScaledInputDataV2(desc, targetData, newAmount, true);
            return abi.encodeWithSelector(selector, callTarget, desc, targetData, clientData);
        } else revert("InputScalingHelper: Invalid selector");
    }

    function _getScaledInputDataV2(
        IMetaAggregationRouterV2.SwapDescriptionV2 memory desc,
        bytes memory executorData,
        uint256 newAmount,
        bool isSimpleMode
    ) internal pure returns (IMetaAggregationRouterV2.SwapDescriptionV2 memory, bytes memory) {
        uint256 oldAmount = desc.amount;
        if (oldAmount == newAmount) {
            return (desc, executorData);
        }

        // simple mode swap
        if (isSimpleMode) {
            return (
                _scaledSwapDescriptionV2(desc, oldAmount, newAmount),
                _scaledSimpleSwapData(executorData, oldAmount, newAmount)
            );
        }

        //normal mode swap
        return (
            _scaledSwapDescriptionV2(desc, oldAmount, newAmount),
            _scaledExecutorCallBytesData(executorData, oldAmount, newAmount)
        );
    }

    /// @dev Scale the swap description
    function _scaledSwapDescriptionV2(
        IMetaAggregationRouterV2.SwapDescriptionV2 memory desc,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (IMetaAggregationRouterV2.SwapDescriptionV2 memory) {
        desc.minReturnAmount = (desc.minReturnAmount * newAmount) / oldAmount;
        if (desc.minReturnAmount == 0) desc.minReturnAmount = 1;
        desc.amount = newAmount;

        uint256 nReceivers = desc.srcReceivers.length;
        for (uint256 i = 0; i < nReceivers; ) {
            desc.srcAmounts[i] = (desc.srcAmounts[i] * newAmount) / oldAmount;
            unchecked {
                ++i;
            }
        }
        return desc;
    }

    /// @dev Scale the executorData in case swapSimpleMode
    function _scaledSimpleSwapData(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        SimpleSwapData memory swapData = abi.decode(data, (SimpleSwapData));

        uint256 nPools = swapData.firstPools.length;
        for (uint256 i = 0; i < nPools; ) {
            swapData.firstSwapAmounts[i] = (swapData.firstSwapAmounts[i] * newAmount) / oldAmount;
            unchecked {
                ++i;
            }
        }
        swapData.positiveSlippageData = _scaledPositiveSlippageFeeData(
            swapData.positiveSlippageData,
            oldAmount,
            newAmount
        );
        return abi.encode(swapData);
    }

    function _scaledExecutorCallBytesData(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        SwapExecutorDescription memory executorDesc = abi.decode(data, (SwapExecutorDescription));

        executorDesc.positiveSlippageData = _scaledPositiveSlippageFeeData(
            executorDesc.positiveSlippageData,
            oldAmount,
            newAmount
        );

        uint256 nSequences = executorDesc.swapSequences.length;
        for (uint256 i = 0; i < nSequences; ) {
            Swap memory swap = executorDesc.swapSequences[i][0];
            bytes4 functionSelector = bytes4(swap.selectorAndFlags);

            if (functionSelector == IExecutorHelper.executeUniswap.selector) {
                swap.data = newUniSwap(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeStableSwap.selector) {
                swap.data = newStableSwap(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeCurve.selector) {
                swap.data = newCurveSwap(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeKSClassic.selector) {
                swap.data = newKyberDMM(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeUniV3KSElastic.selector) {
                swap.data = newUniV3ProMM(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeRfq.selector) {
                revert("InputScalingHelper: Can not scale RFQ swap");
            } else if (functionSelector == IExecutorHelper.executeBalV2.selector) {
                swap.data = newBalancerV2(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeWrappedstETH.selector) {
                swap.data = newWrappedstETHSwap(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeStEth.selector) {
                swap.data = newStETHSwap(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeDODO.selector) {
                swap.data = newDODO(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeVelodrome.selector) {
                swap.data = newVelodrome(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeGMX.selector) {
                swap.data = newGMX(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeSynthetix.selector) {
                swap.data = newSynthetix(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeHashflow.selector) {
                revert("InputScalingHelper: Can not scale Hasflow swap");
            } else if (functionSelector == IExecutorHelper.executeCamelot.selector) {
                swap.data = newCamelot(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeKyberLimitOrder.selector) {
                revert("InputScalingHelper: Can not scale KyberLO swap");
            } else if (functionSelector == IExecutorHelper.executePSM.selector) {
                swap.data = newPSM(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeFrax.selector) {
                swap.data = newFrax(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executePlatypus.selector) {
                swap.data = newPlatypus(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeMaverick.selector) {
                swap.data = newMaverick(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeSyncSwap.selector) {
                swap.data = newSyncSwap(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeAlgebraV1.selector) {
                swap.data = newAlgebraV1(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeBalancerBatch.selector) {
                swap.data = newBalancerBatch(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeWombat.selector) {
                swap.data = newMantis(swap.data, oldAmount, newAmount); // @dev struct Mantis is used for both Wombat and Mantis because of same fields
            } else if (functionSelector == IExecutorHelper.executeMantis.selector) {
                swap.data = newMantis(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeIziSwap.selector) {
                swap.data = newIziSwap(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeWooFiV2.selector) {
                swap.data = newMantis(swap.data, oldAmount, newAmount); // @dev using Mantis struct because WooFiV2 and Mantis have same fields
            } else if (functionSelector == IExecutorHelper.executeTraderJoeV2.selector) {
                swap.data = newTraderJoeV2(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executePancakeStableSwap.selector) {
                swap.data = newCurveSwap(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeLevelFiV2.selector) {
                swap.data = newLevelFiV2(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeGMXGLP.selector) {
                swap.data = newGMXGLP(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeVooi.selector) {
                swap.data = newVooi(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeVelocoreV2.selector) {
                swap.data = newVelocoreV2(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeMaticMigrate.selector) {
                swap.data = newMaticMigrate(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeSmardex.selector) {
                swap.data = newMantis(swap.data, oldAmount, newAmount); // @dev using Mantis struct because Smardex and Mantis have same fields
            } else if (functionSelector == IExecutorHelper.executeSolidlyV2.selector) {
                swap.data = newMantis(swap.data, oldAmount, newAmount); // @dev using Mantis struct because Solidly V2 and Mantis have same fields
            } else if (functionSelector == IExecutorHelper.executeKokonut.selector) {
                swap.data = newKokonut(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeBalancerV1.selector) {
                swap.data = newBalancerV1(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeSwaapV2.selector) {
                revert("InputScalingHelper: Can not scale SwaapV2 swap");
            } else if (functionSelector == IExecutorHelper.executeNomiswapStable.selector) {
                swap.data = newMantis(swap.data, oldAmount, newAmount); // @dev using Mantis struct because NomiswapV2 and Mantis have same fields
            } else if (functionSelector == IExecutorHelper.executeArbswapStable.selector) {
                swap.data = newArbswapStable(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeBancorV2.selector) {
                swap.data = newBancorV2(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeBancorV3.selector) {
                swap.data = newMantis(swap.data, oldAmount, newAmount); // @dev using Mantis struct because Bancor V3 and Mantis have same fields
            } else if (functionSelector == IExecutorHelper.executeAmbient.selector) {
                swap.data = newAmbient(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeNative.selector) {
                revert("InputScalingHelper: Can not scale Native swap");
            } else if (functionSelector == IExecutorHelper.executeLighterV2.selector) {
                swap.data = newLighterV2(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeBebop.selector) {
                revert("InputScalingHelper: Can not scale Bebop swap");
            } else if (functionSelector == IExecutorHelper.executeUniV1.selector) {
                swap.data = newUniV1(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeEtherFieETH.selector) {
                swap.data = newEtherFieETH(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeEtherFiWeETH.selector) {
                swap.data = newEtherFiWeETH(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeKelp.selector) {
                swap.data = newKelp(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeEthenaSusde.selector) {
                swap.data = newEthenaSusde(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeRocketPool.selector) {
                swap.data = newRocketPool(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeMakersDAI.selector) {
                swap.data = newMakersDAI(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeRenzo.selector) {
                swap.data = newRenzo(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeWBETH.selector) {
                swap.data = newEtherFieETH(swap.data, oldAmount, newAmount); // same etherfi eETH
            } else if (functionSelector == IExecutorHelper.executeMantleETH.selector) {
                swap.data = newEtherFieETH(swap.data, oldAmount, newAmount); // same etherfi eETH
            } else if (functionSelector == IExecutorHelper.executeFrxETH.selector) {
                swap.data = newFrxETH(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeSfrxETH.selector) {
                swap.data = newSfrxETH(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeSfrxETHConvertor.selector) {
                swap.data = newSfrxETHConvertor(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeSwellETH.selector) {
                swap.data = newEtherFieETH(swap.data, oldAmount, newAmount); // same etherfi eETH
            } else if (functionSelector == IExecutorHelper.executeRswETH.selector) {
                swap.data = newEtherFieETH(swap.data, oldAmount, newAmount); // same etherfi eETH
            } else if (functionSelector == IExecutorHelper.executeStaderETHx.selector) {
                swap.data = newEthenaSusde(swap.data, oldAmount, newAmount); // same ethena susde
            } else if (functionSelector == IExecutorHelper.executeOriginETH.selector) {
                swap.data = newOriginETH(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executePrimeETH.selector) {
                swap.data = newOriginETH(swap.data, oldAmount, newAmount); // same originETH
            } else if (functionSelector == IExecutorHelper.executeMantleUsd.selector) {
                swap.data = newMantleUsd(swap.data, oldAmount, newAmount);
            } else if (functionSelector == IExecutorHelper.executeBedrockUniETH.selector) {
                swap.data = newEtherFieETH(swap.data, oldAmount, newAmount); // same etherfi eETH
            } else if (functionSelector == IExecutorHelper.executeMaiPSM.selector) {
                swap.data = newFrxETH(swap.data, oldAmount, newAmount); // same frxeth
            } else {
                revert("AggregationExecutor: Dex type not supported");
            }
            unchecked {
                ++i;
            }
        }
        return abi.encode(executorDesc);
    }

    function newUniSwap(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        IExecutorHelper.UniSwap memory uniSwap = abi.decode(data, (IExecutorHelper.UniSwap));
        uniSwap.collectAmount = (uniSwap.collectAmount * newAmount) / oldAmount;
        return abi.encode(uniSwap);
    }

    function newStableSwap(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        IExecutorHelper.StableSwap memory stableSwap = abi.decode(
            data,
            (IExecutorHelper.StableSwap)
        );
        stableSwap.dx = (stableSwap.dx * newAmount) / oldAmount;
        return abi.encode(stableSwap);
    }

    function newCurveSwap(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        IExecutorHelper.CurveSwap memory curveSwap = abi.decode(data, (IExecutorHelper.CurveSwap));
        curveSwap.dx = (curveSwap.dx * newAmount) / oldAmount;
        return abi.encode(curveSwap);
    }

    function newKyberDMM(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        IExecutorHelper.UniSwap memory kyberDMMSwap = abi.decode(data, (IExecutorHelper.UniSwap));
        kyberDMMSwap.collectAmount = (kyberDMMSwap.collectAmount * newAmount) / oldAmount;
        return abi.encode(kyberDMMSwap);
    }

    function newUniV3ProMM(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        IExecutorHelper.UniswapV3KSElastic memory uniSwapV3ProMM = abi.decode(
            data,
            (IExecutorHelper.UniswapV3KSElastic)
        );
        uniSwapV3ProMM.swapAmount = (uniSwapV3ProMM.swapAmount * newAmount) / oldAmount;

        return abi.encode(uniSwapV3ProMM);
    }

    function newBalancerV2(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        IExecutorHelper.BalancerV2 memory balancerV2 = abi.decode(
            data,
            (IExecutorHelper.BalancerV2)
        );
        balancerV2.amount = (balancerV2.amount * newAmount) / oldAmount;
        return abi.encode(balancerV2);
    }

    function newDODO(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        IExecutorHelper.DODO memory dodo = abi.decode(data, (IExecutorHelper.DODO));
        dodo.amount = (dodo.amount * newAmount) / oldAmount;
        return abi.encode(dodo);
    }

    function newVelodrome(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        IExecutorHelper.UniSwap memory velodrome = abi.decode(data, (IExecutorHelper.UniSwap));
        velodrome.collectAmount = (velodrome.collectAmount * newAmount) / oldAmount;
        return abi.encode(velodrome);
    }

    function newGMX(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        IExecutorHelper.GMX memory gmx = abi.decode(data, (IExecutorHelper.GMX));
        gmx.amount = (gmx.amount * newAmount) / oldAmount;
        return abi.encode(gmx);
    }

    function newSynthetix(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        IExecutorHelper.Synthetix memory synthetix = abi.decode(data, (IExecutorHelper.Synthetix));
        synthetix.sourceAmount = (synthetix.sourceAmount * newAmount) / oldAmount;
        return abi.encode(synthetix);
    }

    function newCamelot(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        IExecutorHelper.UniSwap memory camelot = abi.decode(data, (IExecutorHelper.UniSwap));
        camelot.collectAmount = (camelot.collectAmount * newAmount) / oldAmount;
        return abi.encode(camelot);
    }

    function newPlatypus(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        IExecutorHelper.Platypus memory platypus = abi.decode(data, (IExecutorHelper.Platypus));
        platypus.collectAmount = (platypus.collectAmount * newAmount) / oldAmount;
        return abi.encode(platypus);
    }

    function newWrappedstETHSwap(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        IExecutorHelper.WSTETH memory wstEthData = abi.decode(data, (IExecutorHelper.WSTETH));
        wstEthData.amount = (wstEthData.amount * newAmount) / oldAmount;
        return abi.encode(wstEthData);
    }

    function newPSM(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        IExecutorHelper.PSM memory psm = abi.decode(data, (IExecutorHelper.PSM));
        psm.amountIn = (psm.amountIn * newAmount) / oldAmount;
        return abi.encode(psm);
    }

    function newFrax(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        IExecutorHelper.UniSwap memory frax = abi.decode(data, (IExecutorHelper.UniSwap));
        frax.collectAmount = (frax.collectAmount * newAmount) / oldAmount;
        return abi.encode(frax);
    }

    function newStETHSwap(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        uint256 amount = abi.decode(data, (uint256));
        amount = (amount * newAmount) / oldAmount;
        return abi.encode(amount);
    }

    function newMaverick(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        IExecutorHelper.Maverick memory maverick = abi.decode(data, (IExecutorHelper.Maverick));
        maverick.swapAmount = (maverick.swapAmount * newAmount) / oldAmount;
        return abi.encode(maverick);
    }

    function newSyncSwap(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        IExecutorHelper.SyncSwap memory syncSwap = abi.decode(data, (IExecutorHelper.SyncSwap));
        syncSwap.collectAmount = (syncSwap.collectAmount * newAmount) / oldAmount;
        return abi.encode(syncSwap);
    }

    function newAlgebraV1(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        IExecutorHelper.AlgebraV1 memory algebraV1Swap = abi.decode(
            data,
            (IExecutorHelper.AlgebraV1)
        );
        algebraV1Swap.swapAmount = (algebraV1Swap.swapAmount * newAmount) / oldAmount;
        return abi.encode(algebraV1Swap);
    }

    function newBalancerBatch(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        IExecutorHelper.BalancerBatch memory balancerBatch = abi.decode(
            data,
            (IExecutorHelper.BalancerBatch)
        );
        balancerBatch.amountIn = (balancerBatch.amountIn * newAmount) / oldAmount;
        return abi.encode(balancerBatch);
    }

    function newMantis(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        IExecutorHelper.Mantis memory mantis = abi.decode(data, (IExecutorHelper.Mantis));
        mantis.amount = (mantis.amount * newAmount) / oldAmount;
        return abi.encode(mantis);
    }

    function newIziSwap(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        IExecutorHelper.IziSwap memory iZi = abi.decode(data, (IExecutorHelper.IziSwap));
        iZi.swapAmount = (iZi.swapAmount * newAmount) / oldAmount;
        return abi.encode(iZi);
    }

    function newTraderJoeV2(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        IExecutorHelper.TraderJoeV2 memory traderJoe = abi.decode(
            data,
            (IExecutorHelper.TraderJoeV2)
        );

        // traderJoe.collectAmount; // most significant 1 bit is to determine whether pool is v2.1, else v2.0
        traderJoe.collectAmount =
            (traderJoe.collectAmount & (1 << 255)) |
            ((uint256((traderJoe.collectAmount << 1) >> 1) * newAmount) / oldAmount);
        return abi.encode(traderJoe);
    }

    function newLevelFiV2(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        IExecutorHelper.LevelFiV2 memory levelFiV2 = abi.decode(data, (IExecutorHelper.LevelFiV2));
        levelFiV2.amountIn = (levelFiV2.amountIn * newAmount) / oldAmount;
        return abi.encode(levelFiV2);
    }

    function newGMXGLP(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        IExecutorHelper.GMXGLP memory swapData = abi.decode(data, (IExecutorHelper.GMXGLP));
        swapData.swapAmount = (swapData.swapAmount * newAmount) / oldAmount;
        return abi.encode(swapData);
    }

    function newVooi(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        IExecutorHelper.Vooi memory vooi = abi.decode(data, (IExecutorHelper.Vooi));
        vooi.fromAmount = (vooi.fromAmount * newAmount) / oldAmount;
        return abi.encode(vooi);
    }

    function newVelocoreV2(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        IExecutorHelper.VelocoreV2 memory velocorev2 = abi.decode(
            data,
            (IExecutorHelper.VelocoreV2)
        );
        velocorev2.amount = (velocorev2.amount * newAmount) / oldAmount;
        return abi.encode(velocorev2);
    }

    function newMaticMigrate(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        IExecutorHelper.MaticMigrate memory maticMigrate = abi.decode(
            data,
            (IExecutorHelper.MaticMigrate)
        );
        maticMigrate.amount = (maticMigrate.amount * newAmount) / oldAmount;
        return abi.encode(maticMigrate);
    }

    function newKokonut(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        IExecutorHelper.Kokonut memory kokonut = abi.decode(data, (IExecutorHelper.Kokonut));
        kokonut.dx = (kokonut.dx * newAmount) / oldAmount;
        return abi.encode(kokonut);
    }

    function newBalancerV1(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        IExecutorHelper.BalancerV1 memory balancerV1 = abi.decode(
            data,
            (IExecutorHelper.BalancerV1)
        );
        balancerV1.amount = (balancerV1.amount * newAmount) / oldAmount;
        return abi.encode(balancerV1);
    }

    function newArbswapStable(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        IExecutorHelper.ArbswapStable memory arbswapStable = abi.decode(
            data,
            (IExecutorHelper.ArbswapStable)
        );
        arbswapStable.dx = (arbswapStable.dx * newAmount) / oldAmount;
        return abi.encode(arbswapStable);
    }

    function newBancorV2(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        IExecutorHelper.BancorV2 memory bancorV2 = abi.decode(data, (IExecutorHelper.BancorV2));
        bancorV2.amount = (bancorV2.amount * newAmount) / oldAmount;
        return abi.encode(bancorV2);
    }

    function newAmbient(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        IExecutorHelper.Ambient memory ambient = abi.decode(data, (IExecutorHelper.Ambient));
        ambient.qty = uint128((uint256(ambient.qty) * newAmount) / oldAmount);
        return abi.encode(ambient);
    }

    function newLighterV2(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        IExecutorHelper.LighterV2 memory structData = abi.decode(data, (IExecutorHelper.LighterV2));
        structData.amount = uint128((uint256(structData.amount) * newAmount) / oldAmount);
        return abi.encode(structData);
    }

    function newUniV1(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        IExecutorHelper.UniV1 memory structData = abi.decode(data, (IExecutorHelper.UniV1));
        structData.amount = uint128((uint256(structData.amount) * newAmount) / oldAmount);
        return abi.encode(structData);
    }

    function newEtherFieETH(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        uint256 depositAmount = abi.decode(data, (uint256));
        depositAmount = uint128((depositAmount * newAmount) / oldAmount);
        return abi.encode(depositAmount);
    }

    function newEtherFiWeETH(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        IExecutorHelper.EtherFiWeETH memory structData = abi.decode(
            data,
            (IExecutorHelper.EtherFiWeETH)
        );
        structData.amount = uint128((uint256(structData.amount) * newAmount) / oldAmount);
        return abi.encode(structData);
    }

    function newKelp(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        IExecutorHelper.Kelp memory structData = abi.decode(data, (IExecutorHelper.Kelp));
        structData.amount = uint128((uint256(structData.amount) * newAmount) / oldAmount);
        return abi.encode(structData);
    }

    function newEthenaSusde(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        IExecutorHelper.EthenaSusde memory structData = abi.decode(
            data,
            (IExecutorHelper.EthenaSusde)
        );
        structData.amount = uint128((uint256(structData.amount) * newAmount) / oldAmount);
        return abi.encode(structData);
    }

    function newRocketPool(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        IExecutorHelper.RocketPool memory structData = abi.decode(
            data,
            (IExecutorHelper.RocketPool)
        );

        uint128 _amount = uint128(
            (uint256(uint128(structData.isDepositAndAmount)) * newAmount) / oldAmount
        );

        bool _isDeposit = (structData.isDepositAndAmount >> 255) == 1;

        // reset and create new variable for isDeposit and amount
        structData.isDepositAndAmount = 0;
        structData.isDepositAndAmount |= uint256(uint128(_amount));
        structData.isDepositAndAmount |= uint256(_isDeposit ? 1 : 0) << 255;

        return abi.encode(structData);
    }

    function newMakersDAI(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        IExecutorHelper.MakersDAI memory structData = abi.decode(data, (IExecutorHelper.MakersDAI));
        uint128 _amount = uint128(
            (uint256(uint128(structData.isRedeemAndAmount)) * newAmount) / oldAmount
        );

        bool _isRedeem = (structData.isRedeemAndAmount >> 255) == 1;

        // reset and create new variable for isRedeem and amount
        structData.isRedeemAndAmount = 0;
        structData.isRedeemAndAmount |= uint256(uint128(_amount));
        structData.isRedeemAndAmount |= uint256(_isRedeem ? 1 : 0) << 255;

        return abi.encode(structData);
    }

    function newRenzo(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        IExecutorHelper.Renzo memory structData = abi.decode(data, (IExecutorHelper.Renzo));
        structData.amount = uint128((uint256(structData.amount) * newAmount) / oldAmount);
        return abi.encode(structData);
    }

    function newFrxETH(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        IExecutorHelper.FrxETH memory structData = abi.decode(data, (IExecutorHelper.FrxETH));
        structData.amount = uint128((uint256(structData.amount) * newAmount) / oldAmount);
        return abi.encode(structData);
    }

    function newSfrxETH(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        IExecutorHelper.SfrxETH memory structData = abi.decode(data, (IExecutorHelper.SfrxETH));
        structData.amount = uint128((uint256(structData.amount) * newAmount) / oldAmount);
        return abi.encode(structData);
    }

    function newSfrxETHConvertor(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        IExecutorHelper.SfrxETHConvertor memory structData = abi.decode(
            data,
            (IExecutorHelper.SfrxETHConvertor)
        );

        uint128 _amount = uint128(
            (uint256(uint128(structData.isDepositAndAmount)) * newAmount) / oldAmount
        );

        bool _isDeposit = (structData.isDepositAndAmount >> 255) == 1;

        // reset and create new variable for isDeposit and amount
        structData.isDepositAndAmount = 0;
        structData.isDepositAndAmount |= uint256(uint128(_amount));
        structData.isDepositAndAmount |= uint256(_isDeposit ? 1 : 0) << 255;

        return abi.encode(structData);
    }

    function newOriginETH(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        IExecutorHelper.OriginETH memory structData = abi.decode(data, (IExecutorHelper.OriginETH));
        structData.amount = uint128((uint256(structData.amount) * newAmount) / oldAmount);
        return abi.encode(structData);
    }

    function newMantleUsd(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory) {
        uint256 isWrapAndAmount = abi.decode(data, (uint256));

        uint128 _amount = uint128((uint256(uint128(isWrapAndAmount)) * newAmount) / oldAmount);

        bool _isWrap = (isWrapAndAmount >> 255) == 1;

        // reset and create new variable for isWrap and amount
        isWrapAndAmount = 0;
        isWrapAndAmount |= uint256(uint128(_amount));
        isWrapAndAmount |= uint256(_isWrap ? 1 : 0) << 255;

        return abi.encode(isWrapAndAmount);
    }

    function _scaledPositiveSlippageFeeData(
        bytes memory data,
        uint256 oldAmount,
        uint256 newAmount
    ) internal pure returns (bytes memory newData) {
        if (data.length > 32) {
            PositiveSlippageFeeData memory psData = abi.decode(data, (PositiveSlippageFeeData));
            uint256 left = uint256(psData.expectedReturnAmount >> 128);
            uint256 right = (uint256(uint128(psData.expectedReturnAmount)) * newAmount) / oldAmount;
            require(right <= type(uint128).max, "Exceeded type range");
            psData.expectedReturnAmount = right | (left << 128);
            data = abi.encode(psData);
        } else if (data.length == 32) {
            uint256 expectedReturnAmount = abi.decode(data, (uint256));
            uint256 left = uint256(expectedReturnAmount >> 128);
            uint256 right = (uint256(uint128(expectedReturnAmount)) * newAmount) / oldAmount;
            require(right <= type(uint128).max, "Exceeded type range");
            expectedReturnAmount = right | (left << 128);
            data = abi.encode(expectedReturnAmount);
        }
        return data;
    }

    function _flagsChecked(uint256 number, uint256 flag) internal pure returns (bool) {
        return number & flag != 0;
    }
}
