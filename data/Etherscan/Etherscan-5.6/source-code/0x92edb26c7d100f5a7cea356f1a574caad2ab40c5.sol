// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface ISwapRouter02 {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    function exactInputSingle(
        ExactInputSingleParams calldata params
    ) external payable returns (uint256 amountOut);

    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    function exactInput(
        ExactInputParams calldata params
    ) external payable returns (uint256 amountOut);
}

interface IUniswapV2Router02 {
    // Uniswap V2 swap function
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

contract MaxBuyBackV1 {
    error NothingToWithdraw();
    error FailedToWithdrawEth(address owner, address target, uint256 value);
    ISwapRouter02 public swapRouter02;
    IUniswapV2Router02 public uniswapV2Router;

    address public usdc;
    address public weth;
    address public buyBackToken;
    address public owner;
    address public multisigWallet;
    address public finalDestination;
    uint256 private totalUSDCSwapped;
    uint256 private totalTokensBoughtBack;
    uint24 private poolFeeIn = 500;

    event TokensSwapped(
        address indexed tokenIn,
        address indexed tokenOut,
        uint256 amountIn,
        uint256 amountOut
    );

    constructor() {
        owner = msg.sender;
        multisigWallet = msg.sender;
    }

    modifier onlyAdmin() {
        require(
            msg.sender == owner || msg.sender == multisigWallet,
            "Caller is not an admin"
        );
        _;
    }

    modifier onlyMultisig() {
        require(msg.sender == multisigWallet, "Caller is not the multisig");
        _;
    }

    function getUsdcSwaps() public view returns (uint256) {
        return totalUSDCSwapped;
    }

    function getTokensSwap() public view returns (uint256) {
        return totalTokensBoughtBack;
    }

    function setMultisig(address _multisig) external onlyMultisig {
        require(_multisig != address(0), "Multisig cannot be the zero address");
        multisigWallet = _multisig;
    }

    function setUniswapV3Router(address _v3Router) external onlyAdmin {
        swapRouter02 = ISwapRouter02(_v3Router);
    }

    function setUniswapV2Router(address _v2Router) external onlyAdmin {
        uniswapV2Router = IUniswapV2Router02(_v2Router);
    }

    function setFinalDestination(address _finalDestination) external onlyAdmin {
        finalDestination = _finalDestination;
    }

    function setTokenAddresses(
        address _usdc,
        address _weth,
        address _buyBackToken
    ) external onlyAdmin {
        usdc = _usdc;
        weth = _weth;
        buyBackToken = _buyBackToken;
    }

    function updateBuyBackToken(address _newToken) external onlyAdmin {
        buyBackToken = _newToken;
        totalUSDCSwapped = 0;
        totalTokensBoughtBack = 0;
    }

    function _swapAllUSDCToWETH() internal returns (uint256 amountOut) {
        uint256 usdcBalance = IERC20(usdc).balanceOf(address(this));
        require(usdcBalance > 0, "Insufficient USDC in contract");

        IERC20(usdc).approve(address(swapRouter02), usdcBalance);

        ISwapRouter02.ExactInputSingleParams memory params = ISwapRouter02
            .ExactInputSingleParams({
                tokenIn: address(usdc),
                tokenOut: address(weth),
                fee: poolFeeIn,
                recipient: address(this),
                amountIn: usdcBalance,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

        amountOut = swapRouter02.exactInputSingle(params);
        IERC20(usdc).approve(address(swapRouter02), 0);
        totalUSDCSwapped += usdcBalance;
        return amountOut;
    }

    function _swapWETHForBuybackToken(uint256 wethAmount) internal {
        require(wethAmount > 0, "Amount must be greater than zero");
        require(
            IERC20(weth).balanceOf(address(this)) >= wethAmount,
            "Not enough WETH"
        );

        IERC20(weth).approve(address(uniswapV2Router), wethAmount);

        address[] memory path = new address[](2);
        path[0] = weth;
        path[1] = buyBackToken;

        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            wethAmount,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 tokenBalance = IERC20(buyBackToken).balanceOf(address(this));
        IERC20(weth).approve(address(uniswapV2Router), 0);
        totalTokensBoughtBack += tokenBalance;
        IERC20(buyBackToken).transfer(finalDestination, tokenBalance);
        emit TokensSwapped(weth, buyBackToken, wethAmount, tokenBalance);
    }

    function swapAllUsdcForWeth() external onlyAdmin {
        _swapAllUSDCToWETH();
    }

    function swapWethForBuybackToken(uint256 amount) external onlyAdmin {
        _swapWETHForBuybackToken(amount);
    }

    function _swapUSDCToWETH(
        uint256 amount
    ) internal returns (uint256 amountOut) {
        uint256 usdcBalance = IERC20(usdc).balanceOf(address(this));
        require(usdcBalance > 0, "Insufficient USDC in contract");
        require(amount > 0, "Insufficient USDC in contract");

        IERC20(usdc).approve(address(swapRouter02), amount);

        ISwapRouter02.ExactInputSingleParams memory params = ISwapRouter02
            .ExactInputSingleParams({
                tokenIn: address(usdc),
                tokenOut: address(weth),
                fee: poolFeeIn,
                recipient: address(this),
                amountIn: amount,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

        amountOut = swapRouter02.exactInputSingle(params);
        IERC20(usdc).approve(address(swapRouter02), 0);
        totalUSDCSwapped += amount;
        return amountOut;
    }

    function swapAndBurn(uint256 _amountUSDC) external onlyAdmin {
        uint256 ethOut = _swapUSDCToWETH(_amountUSDC);
        _swapWETHForBuybackToken(ethOut);
    }

    function withdraw(address _beneficiary) public onlyMultisig {
        uint256 amount = address(this).balance;
        if (amount == 0) revert NothingToWithdraw();
        (bool sent, ) = _beneficiary.call{value: amount}("");
        if (!sent) revert FailedToWithdrawEth(msg.sender, _beneficiary, amount);
    }

    function withdrawToken(
        address _beneficiary,
        address _token
    ) public onlyMultisig {
        uint256 amount = IERC20(_token).balanceOf(address(this));
        if (amount == 0) revert NothingToWithdraw();
        IERC20(_token).transfer(_beneficiary, amount);
    }
}