{{
  "language": "Solidity",
  "settings": {
    "evmVersion": "paris",
    "libraries": {},
    "metadata": {
      "bytecodeHash": "ipfs",
      "useLiteralContent": true
    },
    "optimizer": {
      "enabled": true,
      "runs": 200
    },
    "remappings": [],
    "outputSelection": {
      "*": {
        "*": [
          "evm.bytecode",
          "evm.deployedBytecode",
          "devdoc",
          "userdoc",
          "metadata",
          "abi"
        ]
      }
    }
  },
  "sources": {
    "@openzeppelin/contracts/access/Ownable.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)\n\npragma solidity ^0.8.20;\n\nimport {Context} from \"../utils/Context.sol\";\n\n/**\n * @dev Contract module which provides a basic access control mechanism, where\n * there is an account (an owner) that can be granted exclusive access to\n * specific functions.\n *\n * The initial owner is set to the address provided by the deployer. This can\n * later be changed with {transferOwnership}.\n *\n * This module is used through inheritance. It will make available the modifier\n * `onlyOwner`, which can be applied to your functions to restrict their use to\n * the owner.\n */\nabstract contract Ownable is Context {\n    address private _owner;\n\n    /**\n     * @dev The caller account is not authorized to perform an operation.\n     */\n    error OwnableUnauthorizedAccount(address account);\n\n    /**\n     * @dev The owner is not a valid owner account. (eg. `address(0)`)\n     */\n    error OwnableInvalidOwner(address owner);\n\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    /**\n     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.\n     */\n    constructor(address initialOwner) {\n        if (initialOwner == address(0)) {\n            revert OwnableInvalidOwner(address(0));\n        }\n        _transferOwnership(initialOwner);\n    }\n\n    /**\n     * @dev Throws if called by any account other than the owner.\n     */\n    modifier onlyOwner() {\n        _checkOwner();\n        _;\n    }\n\n    /**\n     * @dev Returns the address of the current owner.\n     */\n    function owner() public view virtual returns (address) {\n        return _owner;\n    }\n\n    /**\n     * @dev Throws if the sender is not the owner.\n     */\n    function _checkOwner() internal view virtual {\n        if (owner() != _msgSender()) {\n            revert OwnableUnauthorizedAccount(_msgSender());\n        }\n    }\n\n    /**\n     * @dev Leaves the contract without owner. It will not be possible to call\n     * `onlyOwner` functions. Can only be called by the current owner.\n     *\n     * NOTE: Renouncing ownership will leave the contract without an owner,\n     * thereby disabling any functionality that is only available to the owner.\n     */\n    function renounceOwnership() public virtual onlyOwner {\n        _transferOwnership(address(0));\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Can only be called by the current owner.\n     */\n    function transferOwnership(address newOwner) public virtual onlyOwner {\n        if (newOwner == address(0)) {\n            revert OwnableInvalidOwner(address(0));\n        }\n        _transferOwnership(newOwner);\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Internal function without access restriction.\n     */\n    function _transferOwnership(address newOwner) internal virtual {\n        address oldOwner = _owner;\n        _owner = newOwner;\n        emit OwnershipTransferred(oldOwner, newOwner);\n    }\n}\n"
    },
    "@openzeppelin/contracts/utils/Context.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)\n\npragma solidity ^0.8.20;\n\n/**\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes calldata) {\n        return msg.data;\n    }\n\n    function _contextSuffixLength() internal view virtual returns (uint256) {\n        return 0;\n    }\n}\n"
    },
    "@openzeppelin/contracts/utils/Pausable.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v5.0.0) (utils/Pausable.sol)\n\npragma solidity ^0.8.20;\n\nimport {Context} from \"../utils/Context.sol\";\n\n/**\n * @dev Contract module which allows children to implement an emergency stop\n * mechanism that can be triggered by an authorized account.\n *\n * This module is used through inheritance. It will make available the\n * modifiers `whenNotPaused` and `whenPaused`, which can be applied to\n * the functions of your contract. Note that they will not be pausable by\n * simply including this module, only once the modifiers are put in place.\n */\nabstract contract Pausable is Context {\n    bool private _paused;\n\n    /**\n     * @dev Emitted when the pause is triggered by `account`.\n     */\n    event Paused(address account);\n\n    /**\n     * @dev Emitted when the pause is lifted by `account`.\n     */\n    event Unpaused(address account);\n\n    /**\n     * @dev The operation failed because the contract is paused.\n     */\n    error EnforcedPause();\n\n    /**\n     * @dev The operation failed because the contract is not paused.\n     */\n    error ExpectedPause();\n\n    /**\n     * @dev Initializes the contract in unpaused state.\n     */\n    constructor() {\n        _paused = false;\n    }\n\n    /**\n     * @dev Modifier to make a function callable only when the contract is not paused.\n     *\n     * Requirements:\n     *\n     * - The contract must not be paused.\n     */\n    modifier whenNotPaused() {\n        _requireNotPaused();\n        _;\n    }\n\n    /**\n     * @dev Modifier to make a function callable only when the contract is paused.\n     *\n     * Requirements:\n     *\n     * - The contract must be paused.\n     */\n    modifier whenPaused() {\n        _requirePaused();\n        _;\n    }\n\n    /**\n     * @dev Returns true if the contract is paused, and false otherwise.\n     */\n    function paused() public view virtual returns (bool) {\n        return _paused;\n    }\n\n    /**\n     * @dev Throws if the contract is paused.\n     */\n    function _requireNotPaused() internal view virtual {\n        if (paused()) {\n            revert EnforcedPause();\n        }\n    }\n\n    /**\n     * @dev Throws if the contract is not paused.\n     */\n    function _requirePaused() internal view virtual {\n        if (!paused()) {\n            revert ExpectedPause();\n        }\n    }\n\n    /**\n     * @dev Triggers stopped state.\n     *\n     * Requirements:\n     *\n     * - The contract must not be paused.\n     */\n    function _pause() internal virtual whenNotPaused {\n        _paused = true;\n        emit Paused(_msgSender());\n    }\n\n    /**\n     * @dev Returns to normal state.\n     *\n     * Requirements:\n     *\n     * - The contract must be paused.\n     */\n    function _unpause() internal virtual whenPaused {\n        _paused = false;\n        emit Unpaused(_msgSender());\n    }\n}\n"
    },
    "@openzeppelin/contracts/utils/ReentrancyGuard.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v5.0.0) (utils/ReentrancyGuard.sol)\n\npragma solidity ^0.8.20;\n\n/**\n * @dev Contract module that helps prevent reentrant calls to a function.\n *\n * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier\n * available, which can be applied to functions to make sure there are no nested\n * (reentrant) calls to them.\n *\n * Note that because there is a single `nonReentrant` guard, functions marked as\n * `nonReentrant` may not call one another. This can be worked around by making\n * those functions `private`, and then adding `external` `nonReentrant` entry\n * points to them.\n *\n * TIP: If you would like to learn more about reentrancy and alternative ways\n * to protect against it, check out our blog post\n * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].\n */\nabstract contract ReentrancyGuard {\n    // Booleans are more expensive than uint256 or any type that takes up a full\n    // word because each write operation emits an extra SLOAD to first read the\n    // slot's contents, replace the bits taken up by the boolean, and then write\n    // back. This is the compiler's defense against contract upgrades and\n    // pointer aliasing, and it cannot be disabled.\n\n    // The values being non-zero value makes deployment a bit more expensive,\n    // but in exchange the refund on every call to nonReentrant will be lower in\n    // amount. Since refunds are capped to a percentage of the total\n    // transaction's gas, it is best to keep them low in cases like this one, to\n    // increase the likelihood of the full refund coming into effect.\n    uint256 private constant NOT_ENTERED = 1;\n    uint256 private constant ENTERED = 2;\n\n    uint256 private _status;\n\n    /**\n     * @dev Unauthorized reentrant call.\n     */\n    error ReentrancyGuardReentrantCall();\n\n    constructor() {\n        _status = NOT_ENTERED;\n    }\n\n    /**\n     * @dev Prevents a contract from calling itself, directly or indirectly.\n     * Calling a `nonReentrant` function from another `nonReentrant`\n     * function is not supported. It is possible to prevent this from happening\n     * by making the `nonReentrant` function external, and making it call a\n     * `private` function that does the actual work.\n     */\n    modifier nonReentrant() {\n        _nonReentrantBefore();\n        _;\n        _nonReentrantAfter();\n    }\n\n    function _nonReentrantBefore() private {\n        // On the first call to nonReentrant, _status will be NOT_ENTERED\n        if (_status == ENTERED) {\n            revert ReentrancyGuardReentrantCall();\n        }\n\n        // Any calls to nonReentrant after this point will fail\n        _status = ENTERED;\n    }\n\n    function _nonReentrantAfter() private {\n        // By storing the original value once again, a refund is triggered (see\n        // https://eips.ethereum.org/EIPS/eip-2200)\n        _status = NOT_ENTERED;\n    }\n\n    /**\n     * @dev Returns true if the reentrancy guard is currently set to \"entered\", which indicates there is a\n     * `nonReentrant` function in the call stack.\n     */\n    function _reentrancyGuardEntered() internal view returns (bool) {\n        return _status == ENTERED;\n    }\n}\n"
    },
    "contracts/presale/TokenDistribute.sol": {
      "content": "// SPDX-License-Identifier: UNLICENSED\npragma solidity ^0.8.23;\n\nimport \"@openzeppelin/contracts/access/Ownable.sol\";\nimport \"@openzeppelin/contracts/utils/Pausable.sol\";\nimport \"@openzeppelin/contracts/utils/ReentrancyGuard.sol\";\n\n\ninterface ITokenHolder {\n    function transfer(address _erc20, address _receiver, uint256 _amount) external;\n    function transferETH(address payable receiver_, uint amount_) external;\n}\n\ninterface IPresale {\n\n    function userInvested(address user_) external view returns (uint);\n\n}\n\ncontract TokenDistribute is Ownable, Pausable, ReentrancyGuard {\n\n    mapping (address => bool) claimed;\n\n    address public presaleAddress;\n    address public tokenAddress;\n    address public tokenHolder;\n\n    uint public rate;\n    uint public timeStart;\n    bool public isSetting;\n\n    event ClaimToken(address user, uint ethAmount, uint tokenAmount, uint time);\n\n    constructor(address presaleAddress_, address tokenAddress_, address tokenHolder_) Ownable(msg.sender) {\n        presaleAddress = presaleAddress_;\n        tokenAddress = tokenAddress_;\n        tokenHolder = tokenHolder_;\n    }\n\n    // -------------- Internal fucntion\n\n    function _getToken(address user_, uint amount_) internal {\n        uint tokenAmount = amount_ * rate;\n        ITokenHolder(tokenHolder).transfer(tokenAddress, user_, tokenAmount);\n\n        emit ClaimToken(user_, amount_, tokenAmount, block.timestamp);\n    }\n\n    // --------------- External fucmntion\n\n    function initSetting(uint rate_, uint timeStart_) external onlyOwner {\n        require(rate_ > 0, \"ERR: Value rate error\");\n        require(timeStart_ > block.timestamp, \"ERR: Value time start error\");\n\n        rate = rate_;\n        timeStart = timeStart_;\n        isSetting = true;\n    }\n\n    function changeSetting(uint rate_, uint timeStart_) external onlyOwner whenPaused {\n        require(rate_ > 0, \"ERR: Value rate error\");\n        require(timeStart_ > block.timestamp, \"ERR: Value time start error\");\n\n        rate = rate_;\n        timeStart = timeStart_;\n    }\n\n    function changeAddress(address presaleAddress_, address tokenAddress_, address tokenHolder_) external onlyOwner whenPaused {\n        presaleAddress = presaleAddress_;\n        tokenAddress = tokenAddress_;\n        tokenHolder = tokenHolder_;\n    }\n\n    // external fucntions\n    function claim() external nonReentrant whenNotPaused {\n        // Check init setting\n        require(isSetting, \"ERR: Not init\");\n        // Check time start\n        require(block.timestamp > timeStart, \"ERR: Not open\");\n        // Check is claimed\n        require(!claimed[msg.sender], \"ERR: Claimed\");\n\n        // Set claim status\n        claimed[msg.sender] = true;\n        // Check invested amount\n        uint amountInvested = IPresale(presaleAddress).userInvested(msg.sender);\n        require(amountInvested > 0, \"ERR: Amount invested is 0\");\n\n        _getToken(msg.sender, amountInvested);\n    }\n\n    function pause() external whenNotPaused onlyOwner {\n        _pause();\n    }\n\n    function unpause() external whenPaused onlyOwner {\n        _unpause();\n    }\n\n    function getTokenClaim(address user_) external view returns(uint) {\n        uint amountInvested = IPresale(presaleAddress).userInvested(user_);\n        return amountInvested * rate;\n    }\n}\n\n"
    }
  }
}}