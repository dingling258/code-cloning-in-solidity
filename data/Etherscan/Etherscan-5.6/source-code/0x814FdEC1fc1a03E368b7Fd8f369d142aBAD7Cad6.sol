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
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)\n\npragma solidity ^0.8.0;\n\nimport \"../utils/Context.sol\";\n\n/**\n * @dev Contract module which provides a basic access control mechanism, where\n * there is an account (an owner) that can be granted exclusive access to\n * specific functions.\n *\n * By default, the owner account will be the one that deploys the contract. This\n * can later be changed with {transferOwnership}.\n *\n * This module is used through inheritance. It will make available the modifier\n * `onlyOwner`, which can be applied to your functions to restrict their use to\n * the owner.\n */\nabstract contract Ownable is Context {\n    address private _owner;\n\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    /**\n     * @dev Initializes the contract setting the deployer as the initial owner.\n     */\n    constructor() {\n        _transferOwnership(_msgSender());\n    }\n\n    /**\n     * @dev Throws if called by any account other than the owner.\n     */\n    modifier onlyOwner() {\n        _checkOwner();\n        _;\n    }\n\n    /**\n     * @dev Returns the address of the current owner.\n     */\n    function owner() public view virtual returns (address) {\n        return _owner;\n    }\n\n    /**\n     * @dev Throws if the sender is not the owner.\n     */\n    function _checkOwner() internal view virtual {\n        require(owner() == _msgSender(), \"Ownable: caller is not the owner\");\n    }\n\n    /**\n     * @dev Leaves the contract without owner. It will not be possible to call\n     * `onlyOwner` functions. Can only be called by the current owner.\n     *\n     * NOTE: Renouncing ownership will leave the contract without an owner,\n     * thereby disabling any functionality that is only available to the owner.\n     */\n    function renounceOwnership() public virtual onlyOwner {\n        _transferOwnership(address(0));\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Can only be called by the current owner.\n     */\n    function transferOwnership(address newOwner) public virtual onlyOwner {\n        require(newOwner != address(0), \"Ownable: new owner is the zero address\");\n        _transferOwnership(newOwner);\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Internal function without access restriction.\n     */\n    function _transferOwnership(address newOwner) internal virtual {\n        address oldOwner = _owner;\n        _owner = newOwner;\n        emit OwnershipTransferred(oldOwner, newOwner);\n    }\n}\n"
    },
    "@openzeppelin/contracts/proxy/Clones.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.9.0) (proxy/Clones.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev https://eips.ethereum.org/EIPS/eip-1167[EIP 1167] is a standard for\n * deploying minimal proxy contracts, also known as \"clones\".\n *\n * > To simply and cheaply clone contract functionality in an immutable way, this standard specifies\n * > a minimal bytecode implementation that delegates all calls to a known, fixed address.\n *\n * The library includes functions to deploy a proxy using either `create` (traditional deployment) or `create2`\n * (salted deterministic deployment). It also includes functions to predict the addresses of clones deployed using the\n * deterministic method.\n *\n * _Available since v3.4._\n */\nlibrary Clones {\n    /**\n     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.\n     *\n     * This function uses the create opcode, which should never revert.\n     */\n    function clone(address implementation) internal returns (address instance) {\n        /// @solidity memory-safe-assembly\n        assembly {\n            // Cleans the upper 96 bits of the `implementation` word, then packs the first 3 bytes\n            // of the `implementation` address with the bytecode before the address.\n            mstore(0x00, or(shr(0xe8, shl(0x60, implementation)), 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000))\n            // Packs the remaining 17 bytes of `implementation` with the bytecode after the address.\n            mstore(0x20, or(shl(0x78, implementation), 0x5af43d82803e903d91602b57fd5bf3))\n            instance := create(0, 0x09, 0x37)\n        }\n        require(instance != address(0), \"ERC1167: create failed\");\n    }\n\n    /**\n     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.\n     *\n     * This function uses the create2 opcode and a `salt` to deterministically deploy\n     * the clone. Using the same `implementation` and `salt` multiple time will revert, since\n     * the clones cannot be deployed twice at the same address.\n     */\n    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {\n        /// @solidity memory-safe-assembly\n        assembly {\n            // Cleans the upper 96 bits of the `implementation` word, then packs the first 3 bytes\n            // of the `implementation` address with the bytecode before the address.\n            mstore(0x00, or(shr(0xe8, shl(0x60, implementation)), 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000))\n            // Packs the remaining 17 bytes of `implementation` with the bytecode after the address.\n            mstore(0x20, or(shl(0x78, implementation), 0x5af43d82803e903d91602b57fd5bf3))\n            instance := create2(0, 0x09, 0x37, salt)\n        }\n        require(instance != address(0), \"ERC1167: create2 failed\");\n    }\n\n    /**\n     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.\n     */\n    function predictDeterministicAddress(\n        address implementation,\n        bytes32 salt,\n        address deployer\n    ) internal pure returns (address predicted) {\n        /// @solidity memory-safe-assembly\n        assembly {\n            let ptr := mload(0x40)\n            mstore(add(ptr, 0x38), deployer)\n            mstore(add(ptr, 0x24), 0x5af43d82803e903d91602b57fd5bf3ff)\n            mstore(add(ptr, 0x14), implementation)\n            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73)\n            mstore(add(ptr, 0x58), salt)\n            mstore(add(ptr, 0x78), keccak256(add(ptr, 0x0c), 0x37))\n            predicted := keccak256(add(ptr, 0x43), 0x55)\n        }\n    }\n\n    /**\n     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.\n     */\n    function predictDeterministicAddress(\n        address implementation,\n        bytes32 salt\n    ) internal view returns (address predicted) {\n        return predictDeterministicAddress(implementation, salt, address(this));\n    }\n}\n"
    },
    "@openzeppelin/contracts/security/ReentrancyGuard.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Contract module that helps prevent reentrant calls to a function.\n *\n * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier\n * available, which can be applied to functions to make sure there are no nested\n * (reentrant) calls to them.\n *\n * Note that because there is a single `nonReentrant` guard, functions marked as\n * `nonReentrant` may not call one another. This can be worked around by making\n * those functions `private`, and then adding `external` `nonReentrant` entry\n * points to them.\n *\n * TIP: If you would like to learn more about reentrancy and alternative ways\n * to protect against it, check out our blog post\n * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].\n */\nabstract contract ReentrancyGuard {\n    // Booleans are more expensive than uint256 or any type that takes up a full\n    // word because each write operation emits an extra SLOAD to first read the\n    // slot's contents, replace the bits taken up by the boolean, and then write\n    // back. This is the compiler's defense against contract upgrades and\n    // pointer aliasing, and it cannot be disabled.\n\n    // The values being non-zero value makes deployment a bit more expensive,\n    // but in exchange the refund on every call to nonReentrant will be lower in\n    // amount. Since refunds are capped to a percentage of the total\n    // transaction's gas, it is best to keep them low in cases like this one, to\n    // increase the likelihood of the full refund coming into effect.\n    uint256 private constant _NOT_ENTERED = 1;\n    uint256 private constant _ENTERED = 2;\n\n    uint256 private _status;\n\n    constructor() {\n        _status = _NOT_ENTERED;\n    }\n\n    /**\n     * @dev Prevents a contract from calling itself, directly or indirectly.\n     * Calling a `nonReentrant` function from another `nonReentrant`\n     * function is not supported. It is possible to prevent this from happening\n     * by making the `nonReentrant` function external, and making it call a\n     * `private` function that does the actual work.\n     */\n    modifier nonReentrant() {\n        _nonReentrantBefore();\n        _;\n        _nonReentrantAfter();\n    }\n\n    function _nonReentrantBefore() private {\n        // On the first call to nonReentrant, _status will be _NOT_ENTERED\n        require(_status != _ENTERED, \"ReentrancyGuard: reentrant call\");\n\n        // Any calls to nonReentrant after this point will fail\n        _status = _ENTERED;\n    }\n\n    function _nonReentrantAfter() private {\n        // By storing the original value once again, a refund is triggered (see\n        // https://eips.ethereum.org/EIPS/eip-2200)\n        _status = _NOT_ENTERED;\n    }\n\n    /**\n     * @dev Returns true if the reentrancy guard is currently set to \"entered\", which indicates there is a\n     * `nonReentrant` function in the call stack.\n     */\n    function _reentrancyGuardEntered() internal view returns (bool) {\n        return _status == _ENTERED;\n    }\n}\n"
    },
    "@openzeppelin/contracts/utils/Address.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.9.0) (utils/Address.sol)\n\npragma solidity ^0.8.1;\n\n/**\n * @dev Collection of functions related to the address type\n */\nlibrary Address {\n    /**\n     * @dev Returns true if `account` is a contract.\n     *\n     * [IMPORTANT]\n     * ====\n     * It is unsafe to assume that an address for which this function returns\n     * false is an externally-owned account (EOA) and not a contract.\n     *\n     * Among others, `isContract` will return false for the following\n     * types of addresses:\n     *\n     *  - an externally-owned account\n     *  - a contract in construction\n     *  - an address where a contract will be created\n     *  - an address where a contract lived, but was destroyed\n     *\n     * Furthermore, `isContract` will also return true if the target contract within\n     * the same transaction is already scheduled for destruction by `SELFDESTRUCT`,\n     * which only has an effect at the end of a transaction.\n     * ====\n     *\n     * [IMPORTANT]\n     * ====\n     * You shouldn't rely on `isContract` to protect against flash loan attacks!\n     *\n     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets\n     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract\n     * constructor.\n     * ====\n     */\n    function isContract(address account) internal view returns (bool) {\n        // This method relies on extcodesize/address.code.length, which returns 0\n        // for contracts in construction, since the code is only stored at the end\n        // of the constructor execution.\n\n        return account.code.length > 0;\n    }\n\n    /**\n     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to\n     * `recipient`, forwarding all available gas and reverting on errors.\n     *\n     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost\n     * of certain opcodes, possibly making contracts go over the 2300 gas limit\n     * imposed by `transfer`, making them unable to receive funds via\n     * `transfer`. {sendValue} removes this limitation.\n     *\n     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].\n     *\n     * IMPORTANT: because control is transferred to `recipient`, care must be\n     * taken to not create reentrancy vulnerabilities. Consider using\n     * {ReentrancyGuard} or the\n     * https://solidity.readthedocs.io/en/v0.8.0/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].\n     */\n    function sendValue(address payable recipient, uint256 amount) internal {\n        require(address(this).balance >= amount, \"Address: insufficient balance\");\n\n        (bool success, ) = recipient.call{value: amount}(\"\");\n        require(success, \"Address: unable to send value, recipient may have reverted\");\n    }\n\n    /**\n     * @dev Performs a Solidity function call using a low level `call`. A\n     * plain `call` is an unsafe replacement for a function call: use this\n     * function instead.\n     *\n     * If `target` reverts with a revert reason, it is bubbled up by this\n     * function (like regular Solidity function calls).\n     *\n     * Returns the raw returned data. To convert to the expected return value,\n     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].\n     *\n     * Requirements:\n     *\n     * - `target` must be a contract.\n     * - calling `target` with `data` must not revert.\n     *\n     * _Available since v3.1._\n     */\n    function functionCall(address target, bytes memory data) internal returns (bytes memory) {\n        return functionCallWithValue(target, data, 0, \"Address: low-level call failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with\n     * `errorMessage` as a fallback revert reason when `target` reverts.\n     *\n     * _Available since v3.1._\n     */\n    function functionCall(\n        address target,\n        bytes memory data,\n        string memory errorMessage\n    ) internal returns (bytes memory) {\n        return functionCallWithValue(target, data, 0, errorMessage);\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\n     * but also transferring `value` wei to `target`.\n     *\n     * Requirements:\n     *\n     * - the calling contract must have an ETH balance of at least `value`.\n     * - the called Solidity function must be `payable`.\n     *\n     * _Available since v3.1._\n     */\n    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {\n        return functionCallWithValue(target, data, value, \"Address: low-level call with value failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but\n     * with `errorMessage` as a fallback revert reason when `target` reverts.\n     *\n     * _Available since v3.1._\n     */\n    function functionCallWithValue(\n        address target,\n        bytes memory data,\n        uint256 value,\n        string memory errorMessage\n    ) internal returns (bytes memory) {\n        require(address(this).balance >= value, \"Address: insufficient balance for call\");\n        (bool success, bytes memory returndata) = target.call{value: value}(data);\n        return verifyCallResultFromTarget(target, success, returndata, errorMessage);\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\n     * but performing a static call.\n     *\n     * _Available since v3.3._\n     */\n    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {\n        return functionStaticCall(target, data, \"Address: low-level static call failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],\n     * but performing a static call.\n     *\n     * _Available since v3.3._\n     */\n    function functionStaticCall(\n        address target,\n        bytes memory data,\n        string memory errorMessage\n    ) internal view returns (bytes memory) {\n        (bool success, bytes memory returndata) = target.staticcall(data);\n        return verifyCallResultFromTarget(target, success, returndata, errorMessage);\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\n     * but performing a delegate call.\n     *\n     * _Available since v3.4._\n     */\n    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {\n        return functionDelegateCall(target, data, \"Address: low-level delegate call failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],\n     * but performing a delegate call.\n     *\n     * _Available since v3.4._\n     */\n    function functionDelegateCall(\n        address target,\n        bytes memory data,\n        string memory errorMessage\n    ) internal returns (bytes memory) {\n        (bool success, bytes memory returndata) = target.delegatecall(data);\n        return verifyCallResultFromTarget(target, success, returndata, errorMessage);\n    }\n\n    /**\n     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling\n     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.\n     *\n     * _Available since v4.8._\n     */\n    function verifyCallResultFromTarget(\n        address target,\n        bool success,\n        bytes memory returndata,\n        string memory errorMessage\n    ) internal view returns (bytes memory) {\n        if (success) {\n            if (returndata.length == 0) {\n                // only check isContract if the call was successful and the return data is empty\n                // otherwise we already know that it was a contract\n                require(isContract(target), \"Address: call to non-contract\");\n            }\n            return returndata;\n        } else {\n            _revert(returndata, errorMessage);\n        }\n    }\n\n    /**\n     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the\n     * revert reason or using the provided one.\n     *\n     * _Available since v4.3._\n     */\n    function verifyCallResult(\n        bool success,\n        bytes memory returndata,\n        string memory errorMessage\n    ) internal pure returns (bytes memory) {\n        if (success) {\n            return returndata;\n        } else {\n            _revert(returndata, errorMessage);\n        }\n    }\n\n    function _revert(bytes memory returndata, string memory errorMessage) private pure {\n        // Look for revert reason and bubble it up if present\n        if (returndata.length > 0) {\n            // The easiest way to bubble the revert reason is using memory via assembly\n            /// @solidity memory-safe-assembly\n            assembly {\n                let returndata_size := mload(returndata)\n                revert(add(32, returndata), returndata_size)\n            }\n        } else {\n            revert(errorMessage);\n        }\n    }\n}\n"
    },
    "@openzeppelin/contracts/utils/Context.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.9.4) (utils/Context.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes calldata) {\n        return msg.data;\n    }\n\n    function _contextSuffixLength() internal view virtual returns (uint256) {\n        return 0;\n    }\n}\n"
    },
    "contracts/factories/BabyTokenFactory.sol": {
      "content": "// SPDX-License-Identifier: UNLICENSED\npragma solidity ^0.8.0;\n\n/**\n *  ____  _______  _______           _     \n * |  _ \\| ____\\ \\/ /_   _|__   ___ | |___ \n * | | | |  _|  \\  /  | |/ _ \\ / _ \\| / __|\n * | |_| | |___ /  \\  | | (_) | (_) | \\__ \\\n * |____/|_____/_/\\_\\ |_|\\___/ \\___/|_|___/\n *\n * This smart contract was created effortlessly using the DEXTools Token Creator.\n * \n * 🌐 Website: https://www.dextools.io/\n * 🐦 Twitter: https://twitter.com/DEXToolsApp\n * 💬 Telegram: https://t.me/DEXToolsCommunity\n * \n * 🚀 Unleash the power of decentralized finances and tokenization with DEXTools Token Creator. Customize your token seamlessly. Manage your created tokens conveniently from your user panel - start creating your dream token today!\n */\nimport { Clones } from \"@openzeppelin/contracts/proxy/Clones.sol\";\nimport { Address } from \"@openzeppelin/contracts/utils/Address.sol\";\nimport { TokenFactoryBase } from \"./TokenFactoryBase.sol\";\nimport { IBabyToken } from \"../interfaces/IBabyToken.sol\";\n\ncontract BabyTokenFactory is TokenFactoryBase {\n    using Address for address payable;\n\n    constructor(\n        address factoryManager_,\n        address implementation_,\n        address feeTo_,\n        uint256 flatFee_,\n        uint256 maxFee_\n    )\n        TokenFactoryBase(\n            factoryManager_,\n            implementation_,\n            feeTo_,\n            flatFee_,\n            maxFee_\n        )\n    {}\n\n    function create(\n        string memory name,\n        string memory symbol,\n        uint256 totalSupply,\n        address[5] memory addrs, // reward, router, marketing wallet, dividendTracker, antibot\n        uint256[3] memory feeSettings, // rewards, liquidity, marketing\n        uint256 minimumTokenBalanceForDividends,\n        bool enableAntiBot\n    ) external payable enoughFee nonReentrant returns (address token) {\n        refundExcessiveFee();\n        payable(feeTo).sendValue(flatFee);\n        token = Clones.clone(implementation);\n        IBabyToken(token).initialize(\n            msg.sender,\n            name,\n            symbol,\n            totalSupply,\n            addrs,\n            feeSettings,\n            minimumTokenBalanceForDividends,\n            enableAntiBot\n        );\n        assignTokenToOwner(msg.sender, token, 5);\n        emit TokenCreated(msg.sender, token, 5, implementationVersion);\n    }\n}\n"
    },
    "contracts/factories/TokenFactoryBase.sol": {
      "content": "// SPDX-License-Identifier: UNLICENSED\npragma solidity ^0.8.0;\n\n/**\n *  ____  _______  _______           _     \n * |  _ \\| ____\\ \\/ /_   _|__   ___ | |___ \n * | | | |  _|  \\  /  | |/ _ \\ / _ \\| / __|\n * | |_| | |___ /  \\  | | (_) | (_) | \\__ \\\n * |____/|_____/_/\\_\\ |_|\\___/ \\___/|_|___/\n *\n * This smart contract was created effortlessly using the DEXTools Token Creator.\n * \n * 🌐 Website: https://www.dextools.io/\n * 🐦 Twitter: https://twitter.com/DEXToolsApp\n * 💬 Telegram: https://t.me/DEXToolsCommunity\n * \n * 🚀 Unleash the power of decentralized finances and tokenization with DEXTools Token Creator. Customize your token seamlessly. Manage your created tokens conveniently from your user panel - start creating your dream token today!\n */\nimport { Ownable } from \"@openzeppelin/contracts/access/Ownable.sol\";\nimport { Address } from \"@openzeppelin/contracts/utils/Address.sol\";\nimport { ReentrancyGuard } from \"@openzeppelin/contracts/security/ReentrancyGuard.sol\";\nimport { IFactoryManager } from \"../interfaces/IFactoryManager.sol\";\n\ncontract TokenFactoryBase is Ownable, ReentrancyGuard {\n    using Address for address payable;\n\n    address public immutable FACTORY_MANAGER;\n    address public implementation;\n    uint96 public implementationVersion; // Max value: 79228162514264337593543950335\n    address public feeTo;\n    uint256 public flatFee;\n    uint256 public immutable MAX_FEE;\n\n    event TokenCreated(\n        address indexed owner,\n        address indexed token,\n        uint8 tokenType,\n        uint96 tokenVersion\n    );\n\n    error InvalidFactoryManager(address implementation);\n    error InvalidImplementation(address factoryManager);\n    error InvalidFeeReceiver(address receiver);\n    error InvalidFee(uint256 fee);\n    error InvalidMaxFee(uint256 maxFee);\n    error InsufficientFee(uint256 fee);\n\n    modifier enoughFee() {\n        if (msg.value < flatFee) revert InsufficientFee(msg.value);\n        _;\n    }\n\n    constructor(\n        address factoryManager_,\n        address implementation_,\n        address feeTo_,\n        uint256 flatFee_,\n        uint256 maxFee_\n    ) {\n        if (factoryManager_ == address(0))\n            revert InvalidFactoryManager(factoryManager_);\n        if (implementation_ == address(0))\n            revert InvalidImplementation(implementation_);\n        if (feeTo_ == address(0)) revert InvalidFeeReceiver(feeTo_);\n        if (flatFee_ >= maxFee_) revert InvalidFee(flatFee_);\n        if (flatFee_ == 0) revert InvalidMaxFee(maxFee_);\n\n        FACTORY_MANAGER = factoryManager_;\n        implementation = implementation_;\n        implementationVersion = 1;\n        feeTo = feeTo_;\n        flatFee = flatFee_;\n        MAX_FEE = maxFee_;\n    }\n\n    function setImplementation(address implementation_) external onlyOwner {\n        if (implementation_ == address(0) || implementation_ == address(this))\n            revert InvalidImplementation(implementation_);\n        implementation = implementation_;\n        ++implementationVersion;\n    }\n\n    function setFeeTo(address feeReceivingAddress) external onlyOwner {\n        if (\n            feeReceivingAddress == address(0) ||\n            feeReceivingAddress == address(this)\n        ) revert InvalidFeeReceiver(feeReceivingAddress);\n        feeTo = feeReceivingAddress;\n    }\n\n    function setFlatFee(uint256 fee) external onlyOwner {\n        if (fee >= MAX_FEE) revert InvalidFee(fee);\n        flatFee = fee;\n    }\n\n    function assignTokenToOwner(\n        address owner,\n        address token,\n        uint8 tokenType\n    ) internal {\n        IFactoryManager(FACTORY_MANAGER).assignTokensToOwner(\n            owner,\n            token,\n            tokenType\n        );\n    }\n\n    function refundExcessiveFee() internal {\n        uint256 refund = msg.value - flatFee;\n        if (refund > 0) {\n            payable(msg.sender).sendValue(refund);\n        }\n    }\n}\n"
    },
    "contracts/interfaces/IBabyToken.sol": {
      "content": "// SPDX-License-Identifier: UNLICENSED\npragma solidity ^0.8.0;\n\n/**\n *  ____  _______  _______           _     \n * |  _ \\| ____\\ \\/ /_   _|__   ___ | |___ \n * | | | |  _|  \\  /  | |/ _ \\ / _ \\| / __|\n * | |_| | |___ /  \\  | | (_) | (_) | \\__ \\\n * |____/|_____/_/\\_\\ |_|\\___/ \\___/|_|___/\n *\n * This smart contract was created effortlessly using the DEXTools Token Creator.\n * \n * 🌐 Website: https://www.dextools.io/\n * 🐦 Twitter: https://twitter.com/DEXToolsApp\n * 💬 Telegram: https://t.me/DEXToolsCommunity\n * \n * 🚀 Unleash the power of decentralized finances and tokenization with DEXTools Token Creator. Customize your token seamlessly. Manage your created tokens conveniently from your user panel - start creating your dream token today!\n */\ninterface IBabyToken {\n    function initialize(\n        address owner_,\n        string memory name_,\n        string memory symbol_,\n        uint256 totalSupply_,\n        address[5] memory addrs, // reward, router, marketing wallet, dividendTracker, anitbot\n        uint256[3] memory feeSettings, // rewards, liquidity, marketing\n        uint256 minimumTokenBalanceForDividends_,\n        bool enableAntiBot_\n    ) external;\n}\n"
    },
    "contracts/interfaces/IFactoryManager.sol": {
      "content": "// SPDX-License-Identifier: UNLICENSED\npragma solidity ^0.8.0;\n\n/**\n *  ____  _______  _______           _     \n * |  _ \\| ____\\ \\/ /_   _|__   ___ | |___ \n * | | | |  _|  \\  /  | |/ _ \\ / _ \\| / __|\n * | |_| | |___ /  \\  | | (_) | (_) | \\__ \\\n * |____/|_____/_/\\_\\ |_|\\___/ \\___/|_|___/\n *\n * This smart contract was created effortlessly using the DEXTools Token Creator.\n * \n * 🌐 Website: https://www.dextools.io/\n * 🐦 Twitter: https://twitter.com/DEXToolsApp\n * 💬 Telegram: https://t.me/DEXToolsCommunity\n * \n * 🚀 Unleash the power of decentralized finances and tokenization with DEXTools Token Creator. Customize your token seamlessly. Manage your created tokens conveniently from your user panel - start creating your dream token today!\n */\ninterface IFactoryManager {\n    function assignTokensToOwner(\n        address owner,\n        address token,\n        uint8 tokenType\n    ) external;\n}\n"
    }
  }
}}