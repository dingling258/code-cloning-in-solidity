{{
  "language": "Solidity",
  "settings": {
    "optimizer": {
      "enabled": true,
      "runs": 200
    },
    "viaIR": true,
    "outputSelection": {
      "*": {
        "*": [
          "evm.bytecode",
          "evm.deployedBytecode",
          "abi"
        ]
      }
    },
    "remappings": []
  },
  "sources": {
    "swap_contract/swap.sol": {
      "content": "// SPDX-License-Identifier: MIT\r\n\r\n// ░██████╗███╗░░██╗░█████╗░██╗██████╗░██████╗░░█████╗░████████╗\r\n// ██╔════╝████╗░██║██╔══██╗██║██╔══██╗██╔══██╗██╔══██╗╚══██╔══╝\r\n// ╚█████╗░██╔██╗██║███████║██║██████╔╝██████╦╝██║░░██║░░░██║░░░\r\n// ░╚═══██╗██║╚████║██╔══██║██║██╔═══╝░██╔══██╗██║░░██║░░░██║░░░\r\n// ██████╔╝██║░╚███║██║░░██║██║██║░░░░░██████╦╝╚█████╔╝░░░██║░░░\r\n// ╚═════╝░╚═╝░░╚══╝╚═╝░░╚═╝╚═╝╚═╝░░░░░╚═════╝░░╚════╝░░░░╚═╝░░░\r\n\r\n// Powered by: https://nalikes.com/\r\n\r\npragma solidity ^0.8.20;\r\n\r\nimport \"@openzeppelin/contracts/token/ERC20/IERC20.sol\";\r\nimport \"@openzeppelin/contracts/access/Ownable.sol\";\r\nimport \"@openzeppelin/contracts/utils/ReentrancyGuard.sol\";\r\nimport \"./Interfaces/ISwapRouter.sol\";\r\nimport \"./Interfaces/IFactory.sol\";\r\nimport \"./Interfaces/IPair.sol\";\r\n\r\ncontract SwapBot is Ownable, ReentrancyGuard {\r\n    uint256 public deadline = type(uint256).max;\r\n    uint256 public fee = 1;\r\n    address admin;\r\n\r\n    event AddLiquidityETH(\r\n        address token,\r\n        uint256 amountToken,\r\n        uint256 amountETH,\r\n        uint256 liquidity\r\n    );\r\n\r\n    event OnlyAdmin(address _caller, address _admin);\r\n\r\n    constructor() Ownable(msg.sender) {\r\n        admin = address(this);\r\n    }\r\n\r\n    function internalBuy(\r\n        address wtoken,\r\n        address swap,\r\n        address user,\r\n        address[] memory path,\r\n        uint256 amount,\r\n        uint256 slippage\r\n    ) internal nonReentrant {\r\n        address factoryAddr = ISwapRouter(swap).factory();\r\n        address pairAddr = IFactory(factoryAddr).getPair(path[0], path[1]);\r\n        (uint112 reserve0, uint112 reserve1, ) = IPair(pairAddr).getReserves();\r\n\r\n        (uint256 ethAmt, uint256 tokenAmt) = (reserve0, reserve1);\r\n        if (IPair(pairAddr).token0() != wtoken) {\r\n            (ethAmt, tokenAmt) = (reserve1, reserve0);\r\n        }\r\n\r\n        uint256 output = ISwapRouter(swap).getAmountOut(\r\n            amount,\r\n            ethAmt,\r\n            tokenAmt\r\n        );\r\n        uint256 expect = (amount * tokenAmt) / (ethAmt);\r\n\r\n        require(\r\n            expect > 0,\r\n            \"Expected output amount should be greater than zero\"\r\n        );\r\n        uint256 differ = ((expect - output) * (100)) / (expect);\r\n\r\n        require(\r\n            differ < slippage,\r\n            \"Trade output is less than minimum expected\"\r\n        );\r\n\r\n        uint256 ethAmount = amount * 1 wei;\r\n        ISwapRouter(swap).swapExactETHForTokens{value: ethAmount}(\r\n            0,\r\n            path,\r\n            user,\r\n            deadline\r\n        );\r\n    }\r\n\r\n    function buyToken(\r\n        address wtoken,\r\n        address swap,\r\n        address token,\r\n        uint256 amount,\r\n        uint256 slippage\r\n    ) external payable {\r\n        require(msg.value >= amount * (1 wei), \"Insufficient ether amount\");\r\n\r\n        address[] memory path = new address[](2);\r\n        path[0] = wtoken;\r\n        path[1] = token;\r\n\r\n        internalBuy(\r\n            wtoken,\r\n            swap,\r\n            payable(msg.sender),\r\n            path,\r\n            (amount * (100 - fee)) / (100),\r\n            slippage\r\n        );\r\n    }\r\n\r\n    function estimateBuyResult(\r\n        address wtoken,\r\n        address swap,\r\n        address token,\r\n        uint256 amount,\r\n        address factoryAddr\r\n    ) external view returns (uint256 output) {\r\n        address pairAddr = IFactory(factoryAddr).getPair(wtoken, token);\r\n        (uint112 reserve0, uint112 reserve1, ) = IPair(pairAddr).getReserves();\r\n\r\n        (uint256 ethAmt, uint256 tokenAmt) = (reserve0, reserve1);\r\n        if (IPair(pairAddr).token0() != wtoken) {\r\n            (ethAmt, tokenAmt) = (reserve1, reserve0);\r\n        }\r\n\r\n        output = ISwapRouter(swap).getAmountOut(\r\n            (amount * (100 - fee)) / (100),\r\n            ethAmt,\r\n            tokenAmt\r\n        );\r\n    }\r\n\r\n    function internalSell(\r\n        address wtoken,\r\n        address swap,\r\n        address payable user,\r\n        address[] memory path,\r\n        uint256 amount,\r\n        uint256 slippage\r\n    ) internal nonReentrant {\r\n        address factoryAddr = ISwapRouter(swap).factory();\r\n        address pairAddr = IFactory(factoryAddr).getPair(path[0], path[1]);\r\n        (uint112 reserve0, uint112 reserve1, ) = IPair(pairAddr).getReserves();\r\n\r\n        IERC20(path[0]).approve(swap, amount);\r\n\r\n        (uint256 ethAmt, uint256 tokenAmt) = (reserve0, reserve1);\r\n        if (IPair(pairAddr).token0() != wtoken) {\r\n            (ethAmt, tokenAmt) = (reserve1, reserve0);\r\n        }\r\n\r\n        uint256 output = ISwapRouter(swap).getAmountOut(\r\n            amount,\r\n            tokenAmt,\r\n            ethAmt\r\n        );\r\n        uint256 expect = (amount * (ethAmt)) / (tokenAmt);\r\n\r\n        require(\r\n            expect > 0,\r\n            \"Expected output amount should be greater than zero\"\r\n        );\r\n        uint256 differ = ((expect - output) * (100)) / (expect);\r\n\r\n        require(\r\n            differ < slippage,\r\n            \"Trade output is less than minimum expected\"\r\n        );\r\n\r\n        ISwapRouter(swap).swapExactTokensForETH(\r\n            amount,\r\n            0,\r\n            path,\r\n            address(this),\r\n            deadline\r\n        );\r\n        user.transfer((output / 100) * (100 - fee));\r\n    }\r\n\r\n    function sellToken(\r\n        address wtoken,\r\n        address swap,\r\n        address token,\r\n        uint256 amount,\r\n        uint256 slippage\r\n    ) external payable {\r\n        require(\r\n            IERC20(token).balanceOf(msg.sender) >= amount,\r\n            \"Insufficient token balance\"\r\n        );\r\n\r\n        IERC20(token).transferFrom(msg.sender, address(this), amount);\r\n\r\n        address[] memory path = new address[](2);\r\n        path[0] = token;\r\n        path[1] = wtoken;\r\n\r\n        internalSell(wtoken, swap, payable(msg.sender), path, amount, slippage);\r\n    }\r\n\r\n    function estimateSellResult(\r\n        address wtoken,\r\n        address swap,\r\n        address token,\r\n        uint256 amount,\r\n        address factoryAddr\r\n    ) external view returns (uint256 output) {\r\n        address pairAddr = IFactory(factoryAddr).getPair(token, wtoken);\r\n        (uint112 reserve0, uint112 reserve1, ) = IPair(pairAddr).getReserves();\r\n\r\n        (uint256 ethAmt, uint256 tokenAmt) = (reserve0, reserve1);\r\n        if (IPair(pairAddr).token0() != wtoken) {\r\n            (ethAmt, tokenAmt) = (reserve1, reserve0);\r\n        }\r\n\r\n        output =\r\n            (ISwapRouter(swap).getAmountOut(amount, tokenAmt, ethAmt) / 100) *\r\n            (100 - fee);\r\n    }\r\n\r\n    function addLiquidity(\r\n        address swapProtocol,\r\n        address token,\r\n        uint256 amountEthDesired,\r\n        uint256 amountTokenDesired,\r\n        uint256 amountTokenMin,\r\n        uint256 amountETHMin,\r\n        address to\r\n    )\r\n        external\r\n        payable\r\n        onlyOwner\r\n        returns (uint256 amountToken, uint256 amountETH, uint256 liquidity)\r\n    {\r\n        require(\r\n            msg.value >= amountEthDesired * (1 wei),\r\n            \"Insufficient ETH amount\"\r\n        );\r\n\r\n        uint256 etherAmount = amountEthDesired * (1 wei);\r\n        (amountToken, amountETH, liquidity) = ISwapRouter(swapProtocol)\r\n            .addLiquidityETH{value: etherAmount}(\r\n            token,\r\n            amountTokenDesired,\r\n            amountTokenMin,\r\n            amountETHMin,\r\n            to,\r\n            deadline\r\n        );\r\n\r\n        emit AddLiquidityETH(token, amountToken, amountETH, liquidity);\r\n    }\r\n\r\n    function setFee(uint256 _fee) external onlyOwner {\r\n        fee = _fee;\r\n    }\r\n\r\n    function withdraw(\r\n        uint256 _amount,\r\n        address payable _receiver\r\n    ) external onlyOwner {\r\n        _receiver.transfer(_amount);\r\n    }\r\n\r\n    receive() external payable {}\r\n    fallback() external payable {}\r\n}"
    },
    "swap_contract/Interfaces/IPair.sol": {
      "content": "// SPDX-License-Identifier: MIT\r\npragma solidity ^0.8.20;\r\n\r\ninterface IPair {\r\n    function getReserves()\r\n        external\r\n        view\r\n        returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);\r\n\r\n    function token0() external view returns (address);\r\n    function token1() external view returns (address);\r\n}\r\n"
    },
    "swap_contract/Interfaces/IFactory.sol": {
      "content": "// SPDX-License-Identifier: MIT\r\npragma solidity ^0.8.20;\r\n\r\ninterface IFactory {\r\n  event PairCreated(address indexed token0, address indexed token1, address pair, uint);\r\n\r\n  function getPair(address tokenA, address tokenB) external view returns (address pair);\r\n  function allPairs(uint) external view returns (address pair);\r\n  function allPairsLength() external view returns (uint);\r\n\r\n  function feeTo() external view returns (address);\r\n  function feeToSetter() external view returns (address);\r\n\r\n  function createPair(address tokenA, address tokenB) external returns (address pair);\r\n}\r\n"
    },
    "swap_contract/Interfaces/ISwapRouter.sol": {
      "content": "// SPDX-License-Identifier: MIT\r\npragma solidity ^0.8.20;\r\n\r\ninterface ISwapRouter {\r\n    function swapExactTokensForTokens(\r\n        uint256 amountIn,\r\n        uint256 amountOutMin,\r\n        address[] calldata path,\r\n        address to\r\n    ) external returns (uint256 amounts);\r\n\r\n    function swapExactETHForTokens(\r\n        uint amountOutMin,\r\n        address[] calldata path,\r\n        address to,\r\n        uint256 deadline\r\n    ) external payable returns (uint[] memory amounts);\r\n\r\n    function addLiquidityETH(\r\n        address token,\r\n        uint amountTokenDesired,\r\n        uint amountTokenMin,\r\n        uint amountETHMin,\r\n        address to,\r\n        uint deadline\r\n    )\r\n        external\r\n        payable\r\n        returns (uint amountToken, uint amountETH, uint liquidity);\r\n\r\n    function getAmountOut(\r\n        uint amountIn,\r\n        uint reserveIn,\r\n        uint reserveOut\r\n    ) external pure returns (uint amountOut);\r\n\r\n    function swapExactTokensForETH(\r\n        uint amountIn,\r\n        uint amountOutMin,\r\n        address[] calldata path,\r\n        address to,\r\n        uint deadline\r\n    ) external returns (uint[] memory amounts);\r\n\r\n    function factory() external returns (address factory);\r\n}\r\n"
    },
    "@openzeppelin/contracts/utils/ReentrancyGuard.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v5.0.0) (utils/ReentrancyGuard.sol)\n\npragma solidity ^0.8.20;\n\n/**\n * @dev Contract module that helps prevent reentrant calls to a function.\n *\n * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier\n * available, which can be applied to functions to make sure there are no nested\n * (reentrant) calls to them.\n *\n * Note that because there is a single `nonReentrant` guard, functions marked as\n * `nonReentrant` may not call one another. This can be worked around by making\n * those functions `private`, and then adding `external` `nonReentrant` entry\n * points to them.\n *\n * TIP: If you would like to learn more about reentrancy and alternative ways\n * to protect against it, check out our blog post\n * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].\n */\nabstract contract ReentrancyGuard {\n    // Booleans are more expensive than uint256 or any type that takes up a full\n    // word because each write operation emits an extra SLOAD to first read the\n    // slot's contents, replace the bits taken up by the boolean, and then write\n    // back. This is the compiler's defense against contract upgrades and\n    // pointer aliasing, and it cannot be disabled.\n\n    // The values being non-zero value makes deployment a bit more expensive,\n    // but in exchange the refund on every call to nonReentrant will be lower in\n    // amount. Since refunds are capped to a percentage of the total\n    // transaction's gas, it is best to keep them low in cases like this one, to\n    // increase the likelihood of the full refund coming into effect.\n    uint256 private constant NOT_ENTERED = 1;\n    uint256 private constant ENTERED = 2;\n\n    uint256 private _status;\n\n    /**\n     * @dev Unauthorized reentrant call.\n     */\n    error ReentrancyGuardReentrantCall();\n\n    constructor() {\n        _status = NOT_ENTERED;\n    }\n\n    /**\n     * @dev Prevents a contract from calling itself, directly or indirectly.\n     * Calling a `nonReentrant` function from another `nonReentrant`\n     * function is not supported. It is possible to prevent this from happening\n     * by making the `nonReentrant` function external, and making it call a\n     * `private` function that does the actual work.\n     */\n    modifier nonReentrant() {\n        _nonReentrantBefore();\n        _;\n        _nonReentrantAfter();\n    }\n\n    function _nonReentrantBefore() private {\n        // On the first call to nonReentrant, _status will be NOT_ENTERED\n        if (_status == ENTERED) {\n            revert ReentrancyGuardReentrantCall();\n        }\n\n        // Any calls to nonReentrant after this point will fail\n        _status = ENTERED;\n    }\n\n    function _nonReentrantAfter() private {\n        // By storing the original value once again, a refund is triggered (see\n        // https://eips.ethereum.org/EIPS/eip-2200)\n        _status = NOT_ENTERED;\n    }\n\n    /**\n     * @dev Returns true if the reentrancy guard is currently set to \"entered\", which indicates there is a\n     * `nonReentrant` function in the call stack.\n     */\n    function _reentrancyGuardEntered() internal view returns (bool) {\n        return _status == ENTERED;\n    }\n}\n"
    },
    "@openzeppelin/contracts/access/Ownable.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)\n\npragma solidity ^0.8.20;\n\nimport {Context} from \"../utils/Context.sol\";\n\n/**\n * @dev Contract module which provides a basic access control mechanism, where\n * there is an account (an owner) that can be granted exclusive access to\n * specific functions.\n *\n * The initial owner is set to the address provided by the deployer. This can\n * later be changed with {transferOwnership}.\n *\n * This module is used through inheritance. It will make available the modifier\n * `onlyOwner`, which can be applied to your functions to restrict their use to\n * the owner.\n */\nabstract contract Ownable is Context {\n    address private _owner;\n\n    /**\n     * @dev The caller account is not authorized to perform an operation.\n     */\n    error OwnableUnauthorizedAccount(address account);\n\n    /**\n     * @dev The owner is not a valid owner account. (eg. `address(0)`)\n     */\n    error OwnableInvalidOwner(address owner);\n\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    /**\n     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.\n     */\n    constructor(address initialOwner) {\n        if (initialOwner == address(0)) {\n            revert OwnableInvalidOwner(address(0));\n        }\n        _transferOwnership(initialOwner);\n    }\n\n    /**\n     * @dev Throws if called by any account other than the owner.\n     */\n    modifier onlyOwner() {\n        _checkOwner();\n        _;\n    }\n\n    /**\n     * @dev Returns the address of the current owner.\n     */\n    function owner() public view virtual returns (address) {\n        return _owner;\n    }\n\n    /**\n     * @dev Throws if the sender is not the owner.\n     */\n    function _checkOwner() internal view virtual {\n        if (owner() != _msgSender()) {\n            revert OwnableUnauthorizedAccount(_msgSender());\n        }\n    }\n\n    /**\n     * @dev Leaves the contract without owner. It will not be possible to call\n     * `onlyOwner` functions. Can only be called by the current owner.\n     *\n     * NOTE: Renouncing ownership will leave the contract without an owner,\n     * thereby disabling any functionality that is only available to the owner.\n     */\n    function renounceOwnership() public virtual onlyOwner {\n        _transferOwnership(address(0));\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Can only be called by the current owner.\n     */\n    function transferOwnership(address newOwner) public virtual onlyOwner {\n        if (newOwner == address(0)) {\n            revert OwnableInvalidOwner(address(0));\n        }\n        _transferOwnership(newOwner);\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Internal function without access restriction.\n     */\n    function _transferOwnership(address newOwner) internal virtual {\n        address oldOwner = _owner;\n        _owner = newOwner;\n        emit OwnershipTransferred(oldOwner, newOwner);\n    }\n}\n"
    },
    "@openzeppelin/contracts/token/ERC20/IERC20.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)\n\npragma solidity ^0.8.20;\n\n/**\n * @dev Interface of the ERC20 standard as defined in the EIP.\n */\ninterface IERC20 {\n    /**\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\n     * another (`to`).\n     *\n     * Note that `value` may be zero.\n     */\n    event Transfer(address indexed from, address indexed to, uint256 value);\n\n    /**\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\n     * a call to {approve}. `value` is the new allowance.\n     */\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n\n    /**\n     * @dev Returns the value of tokens in existence.\n     */\n    function totalSupply() external view returns (uint256);\n\n    /**\n     * @dev Returns the value of tokens owned by `account`.\n     */\n    function balanceOf(address account) external view returns (uint256);\n\n    /**\n     * @dev Moves a `value` amount of tokens from the caller's account to `to`.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transfer(address to, uint256 value) external returns (bool);\n\n    /**\n     * @dev Returns the remaining number of tokens that `spender` will be\n     * allowed to spend on behalf of `owner` through {transferFrom}. This is\n     * zero by default.\n     *\n     * This value changes when {approve} or {transferFrom} are called.\n     */\n    function allowance(address owner, address spender) external view returns (uint256);\n\n    /**\n     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the\n     * caller's tokens.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\n     * that someone may use both the old and the new allowance by unfortunate\n     * transaction ordering. One possible solution to mitigate this race\n     * condition is to first reduce the spender's allowance to 0 and set the\n     * desired value afterwards:\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\n     *\n     * Emits an {Approval} event.\n     */\n    function approve(address spender, uint256 value) external returns (bool);\n\n    /**\n     * @dev Moves a `value` amount of tokens from `from` to `to` using the\n     * allowance mechanism. `value` is then deducted from the caller's\n     * allowance.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transferFrom(address from, address to, uint256 value) external returns (bool);\n}\n"
    },
    "@openzeppelin/contracts/utils/Context.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)\n\npragma solidity ^0.8.20;\n\n/**\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes calldata) {\n        return msg.data;\n    }\n\n    function _contextSuffixLength() internal view virtual returns (uint256) {\n        return 0;\n    }\n}\n"
    }
  }
}}