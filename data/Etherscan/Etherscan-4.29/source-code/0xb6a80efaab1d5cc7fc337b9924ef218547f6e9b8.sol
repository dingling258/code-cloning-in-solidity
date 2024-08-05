{{
  "language": "Solidity",
  "sources": {
    "Deployments/src/CCTP/WrapperCCTP.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\n\n\nimport \"./ITokenMessenger.sol\"; // Import the interface for CCTP token messenger\nimport \"../openzeppelin/contracts/access/Ownable.sol\";\nimport \"../util/IERC20_.sol\";\n\n\n\ncontract CCTP_Wrapper is Ownable {\n    ITokenMessenger public tokenMessenger;\n    address public  CCTP_Token_Messenger;\n    uint fee; //Basis points fee\n    uint constant BASIS_POINTS = 10000;\n\n    event CCTPTrade(address sender, uint256 amount, address burnToken, uint32 destationDomain);\n\n    // Constructor to set the address of the tokenMessenger contract\n    constructor(address _token_messenger, address _usdc) {\n        CCTP_Token_Messenger=_token_messenger;\n        tokenMessenger = ITokenMessenger(CCTP_Token_Messenger);\n        approveCCTP(_usdc, _token_messenger, 100e18);\n    }\n\n    // Function to call depositForBurn on the tokenMessenger contract\n    function CCTP_Trade(\n        uint256 amount,\n        uint32 destinationDomain,\n        bytes32 mintRecipient,\n        address sell_token\n    ) external payable returns (uint64 nonce){\n        //Send in\n        transferFrom(sell_token, msg.sender, amount);\n        // Calling depositForBurn function of the tokenMessenger contract\n        nonce=tokenMessenger.depositForBurn(apply_fee(amount), destinationDomain, mintRecipient, sell_token);\n        transfer(sell_token, owner(), owner_fee(amount));\n        emit CCTPTrade(msg.sender, amount, sell_token, destinationDomain);\n        payable(owner()).transfer(msg.value);\n    }\n\n    // Function to call depositForBurn on the tokenMessenger contract\n    function CCTP_Pay_Stable(\n        uint256 amount,\n        uint32 destinationDomain,\n        bytes32 mintRecipient,\n        address sell_token, \n        uint256 usdc_gas_fee\n    ) external returns (uint64 nonce){\n        require(amount>usdc_gas_fee,\"!fees exceedes trade amount\");\n        //Send in\n        transferFrom(sell_token, msg.sender, amount+usdc_gas_fee);\n        transfer(sell_token, owner(), usdc_gas_fee);\n        // Calling depositForBurn function of the tokenMessenger contract\n        nonce=tokenMessenger.depositForBurn(apply_fee(amount), destinationDomain, mintRecipient, sell_token);\n        transfer(sell_token, owner(), owner_fee(amount));\n\n        emit CCTPTrade(msg.sender, amount, sell_token, destinationDomain);\n    }\n\n\n    function set_fee(uint _fee) public onlyOwner {\n      fee=_fee;\n    }\n    \n    function apply_fee(uint number) public view returns (uint) {    \n        return number-((fee*number)/BASIS_POINTS);\n    }\n\n    function owner_fee(uint number) public view returns (uint) {    \n        return (fee*number)/BASIS_POINTS;\n    }\n    \n    \n    function approveCCTP(address tkn, address to, uint amt)  internal returns (bool s) {\n        (s, ) = tkn.call(abi.encodeWithSelector(IERC20_.approve.selector, to, amt));\n    }\n    \n    function transfer (address tkn, address to, uint amt) internal returns (bool s) {\n        if (amt > 0) {\n            (s,) = tkn.call(abi.encodeWithSelector(IERC20_.transferFrom.selector, msg.sender, to, amt)); \n        }\n    }\n    \n    function transferFrom (address tkn, address from, uint amt) internal returns (bool s) { \n        (s,) = tkn.call(abi.encodeWithSelector(IERC20_.transferFrom.selector, from, address(this), amt)); \n    }\n\n\n}\n\n"
    },
    "Deployments/src/util/IERC20_.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)\n\npragma solidity >=0.4.22 <0.9.0;\n\n/**\n * @dev Interface of the ERC20 standard as defined in the EIP.\n */\ninterface IERC20_ {\n    /**\n     * @dev Emitted when `value` tokens are moved from one account (`from`) to\n     * another (`to`).\n     *\n     * Note that `value` may be zero.\n     */\n    event Transfer(address indexed from, address indexed to, uint256 value);\n\n    /**\n     * @dev Emitted when the allowance of a `spender` for an `owner` is set by\n     * a call to {approve}. `value` is the new allowance.\n     */\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n\n    /**\n     * @dev Returns the amount of tokens in existence.\n     */\n    function totalSupply() external view returns (uint256);\n\n    /**\n     * @dev Returns the amount of tokens owned by `account`.\n     */\n    function balanceOf(address account) external view returns (uint256);\n\n    /**\n     * @dev Moves `amount` tokens from the caller's account to `to`.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transfer(address to, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Returns the remaining number of tokens that `spender` will be\n     * allowed to spend on behalf of `owner` through {transferFrom}. This is\n     * zero by default.\n     *\n     * This value changes when {approve} or {transferFrom} are called.\n     */\n    function allowance(address owner, address spender) external view returns (uint256);\n\n    /**\n     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * IMPORTANT: Beware that changing an allowance with this method brings the risk\n     * that someone may use both the old and the new allowance by unfortunate\n     * transaction ordering. One possible solution to mitigate this race\n     * condition is to first reduce the spender's allowance to 0 and set the\n     * desired value afterwards:\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\n     *\n     * Emits an {Approval} event.\n     */\n    function approve(address spender, uint256 amount) external returns (bool);\n\n    /**\n     * @dev Moves `amount` tokens from `from` to `to` using the\n     * allowance mechanism. `amount` is then deducted from the caller's\n     * allowance.\n     *\n     * Returns a boolean value indicating whether the operation succeeded.\n     *\n     * Emits a {Transfer} event.\n     */\n    function transferFrom(address from, address to, uint256 amount) external returns (bool);\n\n        \n    /*\n     Returns the decimals of a given token address.\n     */\n    function decimals() external view returns (uint8);\n\n}\n"
    },
    "Deployments/src/openzeppelin/contracts/access/Ownable.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)\n\npragma solidity ^0.8.0;\n\nimport \"../utils/Context.sol\";\n\n/**\n * @dev Contract module which provides a basic access control mechanism, where\n * there is an account (an owner) that can be granted exclusive access to\n * specific functions.\n *\n * By default, the owner account will be the one that deploys the contract. This\n * can later be changed with {transferOwnership}.\n *\n * This module is used through inheritance. It will make available the modifier\n * `onlyOwner`, which can be applied to your functions to restrict their use to\n * the owner.\n */\nabstract contract Ownable is Context {\n    address private _owner;\n\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    /**\n     * @dev Initializes the contract setting the deployer as the initial owner.\n     */\n    constructor() {\n        _transferOwnership(_msgSender());\n    }\n\n    /**\n     * @dev Throws if called by any account other than the owner.\n     */\n    modifier onlyOwner() {\n        _checkOwner();\n        _;\n    }\n\n    /**\n     * @dev Returns the address of the current owner.\n     */\n    function owner() public view virtual returns (address) {\n        return _owner;\n    }\n\n    /**\n     * @dev Throws if the sender is not the owner.\n     */\n    function _checkOwner() internal view virtual {\n        require(owner() == _msgSender(), \"Ownable: caller is not the owner\");\n    }\n\n    /**\n     * @dev Leaves the contract without owner. It will not be possible to call\n     * `onlyOwner` functions. Can only be called by the current owner.\n     *\n     * NOTE: Renouncing ownership will leave the contract without an owner,\n     * thereby disabling any functionality that is only available to the owner.\n     */\n    function renounceOwnership() public virtual onlyOwner {\n        _transferOwnership(address(0));\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Can only be called by the current owner.\n     */\n    function transferOwnership(address newOwner) public virtual onlyOwner {\n        require(newOwner != address(0), \"Ownable: new owner is the zero address\");\n        _transferOwnership(newOwner);\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Internal function without access restriction.\n     */\n    function _transferOwnership(address newOwner) internal virtual {\n        address oldOwner = _owner;\n        _owner = newOwner;\n        emit OwnershipTransferred(oldOwner, newOwner);\n    }\n}\n"
    },
    "Deployments/src/CCTP/ITokenMessenger.sol": {
      "content": "// SPDX-License-Identifier: UNLICENSED\n\npragma solidity >=0.4.22 <0.9.0;\n\n// Interface for the CCTP tokenMessenger contract\ninterface ITokenMessenger {\n\n    function localMinter() external view returns (address);\n\n    function depositForBurn(\n        uint256 amount,\n        uint32 destinationDomain,\n        bytes32 mintRecipient,\n        address burnToken\n    ) external returns (uint64);\n\n    \n}\n"
    },
    "Deployments/src/openzeppelin/contracts/utils/Context.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes calldata) {\n        return msg.data;\n    }\n}\n"
    }
  },
  "settings": {
    "optimizer": {
      "enabled": false,
      "runs": 200
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