{{
  "language": "Solidity",
  "sources": {
    "ForcePresale.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// Creator: twitter.com/0xNox_ETH\n\n//               .;::::::::::::::::::::::::::::::;.\n//               ;XMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMN:\n//               ;XWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMX;\n//               ;KNNNWMMWMMMMMMWWNNNNNNNNNWMMMMMN:\n//                .',oXMMMMMMMNk:''''''''';OMMMMMN:\n//                 ,xNMMMMMMNk;            l00000k,\n//               .lNMMMMMMNk;               .....\n//                'dXMMWNO;                .......\n//                  'd0k;.                .dXXXXX0;\n//               .,;;:lc;;;;;;;;;;;;;;;;;;c0MMMMMN:\n//               ;XMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMX:\n//               ;XMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMN:\n//               ;XWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWX:\n//               .,;,;;;;;;;;;;;;;;;;;;;;;;;,;;,;,.\n//               'dkxkkxxkkkkkkkkkkkkkkkkkkxxxkxkd'\n//               ;XMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMN:\n//               ;XMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMN:\n//               'xkkkOOkkkkkkkkkkkkkkkkkkkkkkkkkx'\n//                          .,,,,,,,,,,,,,,,,,,,,,.\n//                        .lKNWWWWWWWWWWWWWWWWWWWX;\n//                      .lKWMMMMMMMMMMMMMMMMMMMMMX;\n//                    .lKWMMMMMMMMMMMMMMMMMMMMMMMN:\n//                  .lKWMMMMMWKo:::::::::::::::::;.\n//                .lKWMMMMMWKl.\n//               .lNMMMMMWKl.\n//                 ;kNMWKl.\n//                   ;dl.\n//\n//               We vow to Protect\n//               Against the powers of Darkness\n//               To rain down Justice\n//               Against all who seek to cause Harm\n//               To heed the call of those in Need\n//               To offer up our Arms\n//               In body and name we give our Code\n//\n//               FOR THE BLOCKCHAIN ⚔️\n\npragma solidity ^0.8.24;\n\nimport {Ownable} from \"@openzeppelin/contracts/access/Ownable.sol\";\nimport {IERC20} from \"@openzeppelin/contracts/token/ERC20/IERC20.sol\";\nimport {ReentrancyGuard} from \"@openzeppelin/contracts/utils/ReentrancyGuard.sol\";\n\nstruct User {\n    uint ethDeposit;\n    uint usdDeposit;\n}\n\ninterface ForcePresaleEvents {\n    event Deposit(\n        address indexed user,\n        address indexed referrer,\n        string token,\n        uint amount,\n        uint timestamp\n    );\n}\n\ncontract ForcePresale is Ownable, ForcePresaleEvents, ReentrancyGuard {\n    uint public totalEthDeposited;\n    uint public totalUsdDeposited;\n    mapping(address => User) public users;\n\n    bool public presaleActive;\n\n    address public usdc;\n    address public usdt;\n    address public force;\n\n    uint public constant FORCE_USDC_PRICE_x_1e7 = 3013; // 1 FORCE = 0.0003013 USDC\n    uint public constant REFERRAL_BONUS_RATE = 5; // 5% bonus for referee\n    uint public constant REFERRER_PAYBACK_RATE = 10; // 10% payback for referrer\n    uint public constant FORCE_DEPOSIT_BONUS_RATE = 20; // 20% bonus for FORCE deposit\n\n    constructor(address _usdc, address _usdt, address _force) Ownable(msg.sender) {\n        usdc = _usdc;\n        usdt = _usdt;\n        force = _force;\n    }\n\n    function togglePresale(bool _presaleActive) external onlyOwner {\n        presaleActive = _presaleActive;\n    }\n\n    modifier presaleIsActive() {\n        require(presaleActive, \"ForcePresale: Presale is not active\");\n        _;\n    }\n\n    function depositEth(address referrer) external payable presaleIsActive nonReentrant {\n        require(msg.value >= 0.001 ether, \"ForcePresale: eth deposit must be at least 0.001\");\n\n        totalEthDeposited += msg.value;\n\n        User storage user = users[msg.sender];\n\n        if (referrer != address(0) && referrer != msg.sender) {\n            user.ethDeposit += msg.value + (msg.value * REFERRAL_BONUS_RATE) / 100;\n\n            uint referrerPaybackAmount = (msg.value * REFERRER_PAYBACK_RATE) / 100;\n            if (referrerPaybackAmount > 0.001 ether) {\n                // send referrer payback\n                payable(referrer).transfer(referrerPaybackAmount);\n            }\n        } else {\n            user.ethDeposit += msg.value;\n        }\n\n        emit Deposit(msg.sender, referrer, \"ETH\", msg.value, block.timestamp);\n    }\n\n    function depositUsd(\n        address token,\n        uint64 amount,\n        address referrer\n    ) external presaleIsActive nonReentrant {\n        require(token == usdc || token == usdt, \"ForcePresale: invalid token\");\n        require(amount >= 1e6, \"ForcePresale: usd deposit must be at least 1\");\n\n        if (token == usdt) {\n            // reverts on failure\n            IERC20(token).transferFrom(msg.sender, address(this), amount);\n        } else {\n            require(\n                IERC20(token).transferFrom(msg.sender, address(this), amount),\n                \"ForcePresale: failed to transfer usd\"\n            );\n        }\n\n        totalUsdDeposited += amount;\n\n        User storage user = users[msg.sender];\n\n        if (referrer != address(0) && referrer != msg.sender) {\n            user.usdDeposit += amount + (amount * REFERRAL_BONUS_RATE) / 100;\n\n            uint referrerPaybackAmount = (amount * REFERRER_PAYBACK_RATE) / 100;\n            if (referrerPaybackAmount > 1) {\n                // send referrer payback\n                if (token == usdt) {\n                    // reverts on failure\n                    IERC20(token).transfer(referrer, referrerPaybackAmount);\n                } else {\n                    require(\n                        IERC20(token).transfer(referrer, referrerPaybackAmount),\n                        \"ForcePresale: failed to send referrer payback\"\n                    );\n                }\n            }\n        } else {\n            user.usdDeposit += amount;\n        }\n\n        emit Deposit(msg.sender, referrer, \"USD\", amount, block.timestamp);\n    }\n\n    function depositForce(uint amount) external presaleIsActive nonReentrant {\n        require(amount >= 1e18, \"ForcePresale: $FORCE deposit must be at least 1\");\n\n        require(\n            IERC20(force).transferFrom(msg.sender, address(this), amount),\n            \"ForcePresale: failed to transfer $FORCE\"\n        );\n\n        // $FORCE is 1e18 decimals and USDC is 1e6 decimals, so we need to divide by 1e12 to get the correct value in USDC\n        uint usdcValue = ((amount / 1e12) * FORCE_USDC_PRICE_x_1e7) / 1e7;\n        uint bonus = (usdcValue * FORCE_DEPOSIT_BONUS_RATE) / 100;\n\n        User storage user = users[msg.sender];\n        user.usdDeposit += usdcValue + bonus;\n\n        emit Deposit(msg.sender, address(0), \"USD\", usdcValue, block.timestamp);\n    }\n\n    function withdrawEth(uint amount) external nonReentrant onlyOwner {\n        require(amount <= address(this).balance, \"ForcePresale: insufficient balance\");\n        payable(msg.sender).transfer(amount);\n    }\n\n    function withdrawUsd(address token) external nonReentrant onlyOwner {\n        uint balance = IERC20(token).balanceOf(address(this));\n        require(balance > 0, \"ForcePresale: insufficient balance\");\n\n        if (token == usdt) {\n            // reverts on failure\n            IERC20(token).transfer(msg.sender, balance);\n        } else {\n            require(\n                IERC20(token).transfer(msg.sender, balance),\n                \"ForcePresale: failed to transfer usd\"\n            );\n        }\n    }\n}\n"
    },
    "@openzeppelin/contracts/utils/ReentrancyGuard.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v5.0.0) (utils/ReentrancyGuard.sol)\n\npragma solidity ^0.8.20;\n\n/**\n * @dev Contract module that helps prevent reentrant calls to a function.\n *\n * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier\n * available, which can be applied to functions to make sure there are no nested\n * (reentrant) calls to them.\n *\n * Note that because there is a single `nonReentrant` guard, functions marked as\n * `nonReentrant` may not call one another. This can be worked around by making\n * those functions `private`, and then adding `external` `nonReentrant` entry\n * points to them.\n *\n * TIP: If you would like to learn more about reentrancy and alternative ways\n * to protect against it, check out our blog post\n * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].\n */\nabstract contract ReentrancyGuard {\n    // Booleans are more expensive than uint256 or any type that takes up a full\n    // word because each write operation emits an extra SLOAD to first read the\n    // slot's contents, replace the bits taken up by the boolean, and then write\n    // back. This is the compiler's defense against contract upgrades and\n    // pointer aliasing, and it cannot be disabled.\n\n    // The values being non-zero value makes deployment a bit more expensive,\n    // but in exchange the refund on every call to nonReentrant will be lower in\n    // amount. Since refunds are capped to a percentage of the total\n    // transaction's gas, it is best to keep them low in cases like this one, to\n    // increase the likelihood of the full refund coming into effect.\n    uint256 private constant NOT_ENTERED = 1;\n    uint256 private constant ENTERED = 2;\n\n    uint256 private _status;\n\n    /**\n     * @dev Unauthorized reentrant call.\n     */\n    error ReentrancyGuardReentrantCall();\n\n    constructor() {\n        _status = NOT_ENTERED;\n    }\n\n    /**\n     * @dev Prevents a contract from calling itself, directly or indirectly.\n     * Calling a `nonReentrant` function from another `nonReentrant`\n     * function is not supported. It is possible to prevent this from happening\n     * by making the `nonReentrant` function external, and making it call a\n     * `private` function that does the actual work.\n     */\n    modifier nonReentrant() {\n        _nonReentrantBefore();\n        _;\n        _nonReentrantAfter();\n    }\n\n    function _nonReentrantBefore() private {\n        // On the first call to nonReentrant, _status will be NOT_ENTERED\n        if (_status == ENTERED) {\n            revert ReentrancyGuardReentrantCall();\n        }\n\n        // Any calls to nonReentrant after this point will fail\n        _status = ENTERED;\n    }\n\n    function _nonReentrantAfter() private {\n        // By storing the original value once again, a refund is triggered (see\n        // https://eips.ethereum.org/EIPS/eip-2200)\n        _status = NOT_ENTERED;\n    }\n\n    /**\n     * @dev Returns true if the reentrancy guard is currently set to \"entered\", which indicates there is a\n     * `nonReentrant` function in the call stack.\n     */\n    function _reentrancyGuardEntered() internal view returns (bool) {\n        return _status == ENTERED;\n    }\n}\n"
    },
    "@openzeppelin/contracts/token/ERC20/IERC20.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)\n\npragma solidity ^0.8.20;\n\n/**\n * @dev Interface of the ERC20 standard as defined in the EIP.\n */\ninterface IERC20 {\n    /**\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\n     * another (`to`).\n     *\n     * Note that `value` may be zero.\n     */\n    event Transfer(address indexed from, address indexed to, uint256 value);\n\n    /**\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\n     * a call to {approve}. `value` is the new allowance.\n     */\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n\n    /**\n     * @dev Returns the value of tokens in existence.\n     */\n    function totalSupply() external view returns (uint256);\n\n    /**\n     * @dev Returns the value of tokens owned by `account`.\n     */\n    function balanceOf(address account) external view returns (uint256);\n\n    /**\n     * @dev Moves a `value` amount of tokens from the caller's account to `to`.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transfer(address to, uint256 value) external returns (bool);\n\n    /**\n     * @dev Returns the remaining number of tokens that `spender` will be\n     * allowed to spend on behalf of `owner` through {transferFrom}. This is\n     * zero by default.\n     *\n     * This value changes when {approve} or {transferFrom} are called.\n     */\n    function allowance(address owner, address spender) external view returns (uint256);\n\n    /**\n     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the\n     * caller's tokens.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\n     * that someone may use both the old and the new allowance by unfortunate\n     * transaction ordering. One possible solution to mitigate this race\n     * condition is to first reduce the spender's allowance to 0 and set the\n     * desired value afterwards:\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\n     *\n     * Emits an {Approval} event.\n     */\n    function approve(address spender, uint256 value) external returns (bool);\n\n    /**\n     * @dev Moves a `value` amount of tokens from `from` to `to` using the\n     * allowance mechanism. `value` is then deducted from the caller's\n     * allowance.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transferFrom(address from, address to, uint256 value) external returns (bool);\n}\n"
    },
    "@openzeppelin/contracts/access/Ownable.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)\n\npragma solidity ^0.8.20;\n\nimport {Context} from \"../utils/Context.sol\";\n\n/**\n * @dev Contract module which provides a basic access control mechanism, where\n * there is an account (an owner) that can be granted exclusive access to\n * specific functions.\n *\n * The initial owner is set to the address provided by the deployer. This can\n * later be changed with {transferOwnership}.\n *\n * This module is used through inheritance. It will make available the modifier\n * `onlyOwner`, which can be applied to your functions to restrict their use to\n * the owner.\n */\nabstract contract Ownable is Context {\n    address private _owner;\n\n    /**\n     * @dev The caller account is not authorized to perform an operation.\n     */\n    error OwnableUnauthorizedAccount(address account);\n\n    /**\n     * @dev The owner is not a valid owner account. (eg. `address(0)`)\n     */\n    error OwnableInvalidOwner(address owner);\n\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    /**\n     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.\n     */\n    constructor(address initialOwner) {\n        if (initialOwner == address(0)) {\n            revert OwnableInvalidOwner(address(0));\n        }\n        _transferOwnership(initialOwner);\n    }\n\n    /**\n     * @dev Throws if called by any account other than the owner.\n     */\n    modifier onlyOwner() {\n        _checkOwner();\n        _;\n    }\n\n    /**\n     * @dev Returns the address of the current owner.\n     */\n    function owner() public view virtual returns (address) {\n        return _owner;\n    }\n\n    /**\n     * @dev Throws if the sender is not the owner.\n     */\n    function _checkOwner() internal view virtual {\n        if (owner() != _msgSender()) {\n            revert OwnableUnauthorizedAccount(_msgSender());\n        }\n    }\n\n    /**\n     * @dev Leaves the contract without owner. It will not be possible to call\n     * `onlyOwner` functions. Can only be called by the current owner.\n     *\n     * NOTE: Renouncing ownership will leave the contract without an owner,\n     * thereby disabling any functionality that is only available to the owner.\n     */\n    function renounceOwnership() public virtual onlyOwner {\n        _transferOwnership(address(0));\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Can only be called by the current owner.\n     */\n    function transferOwnership(address newOwner) public virtual onlyOwner {\n        if (newOwner == address(0)) {\n            revert OwnableInvalidOwner(address(0));\n        }\n        _transferOwnership(newOwner);\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Internal function without access restriction.\n     */\n    function _transferOwnership(address newOwner) internal virtual {\n        address oldOwner = _owner;\n        _owner = newOwner;\n        emit OwnershipTransferred(oldOwner, newOwner);\n    }\n}\n"
    },
    "@openzeppelin/contracts/utils/Context.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)\n\npragma solidity ^0.8.20;\n\n/**\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes calldata) {\n        return msg.data;\n    }\n\n    function _contextSuffixLength() internal view virtual returns (uint256) {\n        return 0;\n    }\n}\n"
    }
  },
  "settings": {
    "optimizer": {
      "enabled": true,
      "runs": 1000
    },
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
  }
}}