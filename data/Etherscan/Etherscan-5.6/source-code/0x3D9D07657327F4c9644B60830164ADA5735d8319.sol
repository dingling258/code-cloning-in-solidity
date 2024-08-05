{{
  "language": "Solidity",
  "settings": {
    "evmVersion": "london",
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
    "@openzeppelin/contracts/utils/Context.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v4.9.4) (utils/Context.sol)\n\npragma solidity ^0.8.0;\n\n/**\n * @dev Provides information about the current execution context, including the\n * sender of the transaction and its data. While these are generally available\n * via msg.sender and msg.data, they should not be accessed in such a direct\n * manner, since when dealing with meta-transactions the account sending and\n * paying for execution may not be the actual sender (as far as an application\n * is concerned).\n *\n * This contract is only required for intermediate, library-like contracts.\n */\nabstract contract Context {\n    function _msgSender() internal view virtual returns (address) {\n        return msg.sender;\n    }\n\n    function _msgData() internal view virtual returns (bytes calldata) {\n        return msg.data;\n    }\n\n    function _contextSuffixLength() internal view virtual returns (uint256) {\n        return 0;\n    }\n}\n"
    },
    "contracts/BTRUDailyReadings.sol": {
      "content": "// SPDX-License-Identifier: MIT\r\n\r\n// Website: www.biblicaltruth.io\r\n// Twitter / X: https://twitter.com/Bible316Truth\r\n// Telegram: https://t.me/biblicaltruthtoken\r\n// Discord: https://discord.gg/xqAkUBMf\r\n\r\n// Built with Love by: Decentral Bro's: https://www.decentralbros.xyz/\r\n\r\n//███████████████████████████████████████████████████████████████████\r\n//█░░░░░░░░░░░░░░███░░░░░░░░░░░░░░█░░░░░░░░░░░░░░░░███░░░░░░██░░░░░░█\r\n//█░░▄▀▄▀▄▀▄▀▄▀░░███░░▄▀▄▀▄▀▄▀▄▀░░█░░▄▀▄▀▄▀▄▀▄▀▄▀░░███░░▄▀░░██░░▄▀░░█\r\n//█░░▄▀░░░░░░▄▀░░███░░░░░░▄▀░░░░░░█░░▄▀░░░░░░░░▄▀░░███░░▄▀░░██░░▄▀░░█\r\n//█░░▄▀░░██░░▄▀░░███████░░▄▀░░█████░░▄▀░░████░░▄▀░░███░░▄▀░░██░░▄▀░░█\r\n//█░░▄▀░░░░░░▄▀░░░░█████░░▄▀░░█████░░▄▀░░░░░░░░▄▀░░███░░▄▀░░██░░▄▀░░█\r\n//█░░▄▀▄▀▄▀▄▀▄▀▄▀░░█████░░▄▀░░█████░░▄▀▄▀▄▀▄▀▄▀▄▀░░███░░▄▀░░██░░▄▀░░█\r\n//█░░▄▀░░░░░░░░▄▀░░█████░░▄▀░░█████░░▄▀░░░░░░▄▀░░░░███░░▄▀░░██░░▄▀░░█\r\n//█░░▄▀░░████░░▄▀░░█████░░▄▀░░█████░░▄▀░░██░░▄▀░░█████░░▄▀░░██░░▄▀░░█\r\n//█░░▄▀░░░░░░░░▄▀░░█████░░▄▀░░█████░░▄▀░░██░░▄▀░░░░░░█░░▄▀░░░░░░▄▀░░█\r\n//█░░▄▀▄▀▄▀▄▀▄▀▄▀░░█████░░▄▀░░█████░░▄▀░░██░░▄▀▄▀▄▀░░█░░▄▀▄▀▄▀▄▀▄▀░░█\r\n//█░░░░░░░░░░░░░░░░█████░░░░░░█████░░░░░░██░░░░░░░░░░█░░░░░░░░░░░░░░█\r\n//███████████████████████████████████████████████████████████████████\r\n\r\n\r\n//████████████████████████████████████████████████████████████████████████████\r\n//█░░░░░░░░░░░░███░░░░░░░░░░░░░░█░░░░░░░░░░█░░░░░░█████████░░░░░░░░██░░░░░░░░█\r\n//█░░▄▀▄▀▄▀▄▀░░░░█░░▄▀▄▀▄▀▄▀▄▀░░█░░▄▀▄▀▄▀░░█░░▄▀░░█████████░░▄▀▄▀░░██░░▄▀▄▀░░█\r\n//█░░▄▀░░░░▄▀▄▀░░█░░▄▀░░░░░░▄▀░░█░░░░▄▀░░░░█░░▄▀░░█████████░░░░▄▀░░██░░▄▀░░░░█\r\n//█░░▄▀░░██░░▄▀░░█░░▄▀░░██░░▄▀░░███░░▄▀░░███░░▄▀░░███████████░░▄▀▄▀░░▄▀▄▀░░███\r\n//█░░▄▀░░██░░▄▀░░█░░▄▀░░░░░░▄▀░░███░░▄▀░░███░░▄▀░░███████████░░░░▄▀▄▀▄▀░░░░███\r\n//█░░▄▀░░██░░▄▀░░█░░▄▀▄▀▄▀▄▀▄▀░░███░░▄▀░░███░░▄▀░░█████████████░░░░▄▀░░░░█████\r\n//█░░▄▀░░██░░▄▀░░█░░▄▀░░░░░░▄▀░░███░░▄▀░░███░░▄▀░░███████████████░░▄▀░░███████\r\n//█░░▄▀░░██░░▄▀░░█░░▄▀░░██░░▄▀░░███░░▄▀░░███░░▄▀░░███████████████░░▄▀░░███████\r\n//█░░▄▀░░░░▄▀▄▀░░█░░▄▀░░██░░▄▀░░█░░░░▄▀░░░░█░░▄▀░░░░░░░░░░███████░░▄▀░░███████\r\n//█░░▄▀▄▀▄▀▄▀░░░░█░░▄▀░░██░░▄▀░░█░░▄▀▄▀▄▀░░█░░▄▀▄▀▄▀▄▀▄▀░░███████░░▄▀░░███████\r\n//█░░░░░░░░░░░░███░░░░░░██░░░░░░█░░░░░░░░░░█░░░░░░░░░░░░░░███████░░░░░░███████\r\n//████████████████████████████████████████████████████████████████████████████\r\n\r\n\r\n//█████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████\r\n//█░░░░░░░░░░░░░░░░███░░░░░░░░░░░░░░█░░░░░░░░░░░░░░█░░░░░░░░░░░░███░░░░░░░░░░█░░░░░░██████████░░░░░░█░░░░░░░░░░░░░░█░░░░░░░░░░░░░░█\r\n//█░░▄▀▄▀▄▀▄▀▄▀▄▀░░███░░▄▀▄▀▄▀▄▀▄▀░░█░░▄▀▄▀▄▀▄▀▄▀░░█░░▄▀▄▀▄▀▄▀░░░░█░░▄▀▄▀▄▀░░█░░▄▀░░░░░░░░░░██░░▄▀░░█░░▄▀▄▀▄▀▄▀▄▀░░█░░▄▀▄▀▄▀▄▀▄▀░░█\r\n//█░░▄▀░░░░░░░░▄▀░░███░░▄▀░░░░░░░░░░█░░▄▀░░░░░░▄▀░░█░░▄▀░░░░▄▀▄▀░░█░░░░▄▀░░░░█░░▄▀▄▀▄▀▄▀▄▀░░██░░▄▀░░█░░▄▀░░░░░░░░░░█░░▄▀░░░░░░░░░░█\r\n//█░░▄▀░░████░░▄▀░░███░░▄▀░░█████████░░▄▀░░██░░▄▀░░█░░▄▀░░██░░▄▀░░███░░▄▀░░███░░▄▀░░░░░░▄▀░░██░░▄▀░░█░░▄▀░░█████████░░▄▀░░█████████\r\n//█░░▄▀░░░░░░░░▄▀░░███░░▄▀░░░░░░░░░░█░░▄▀░░░░░░▄▀░░█░░▄▀░░██░░▄▀░░███░░▄▀░░███░░▄▀░░██░░▄▀░░██░░▄▀░░█░░▄▀░░█████████░░▄▀░░░░░░░░░░█\r\n//█░░▄▀▄▀▄▀▄▀▄▀▄▀░░███░░▄▀▄▀▄▀▄▀▄▀░░█░░▄▀▄▀▄▀▄▀▄▀░░█░░▄▀░░██░░▄▀░░███░░▄▀░░███░░▄▀░░██░░▄▀░░██░░▄▀░░█░░▄▀░░██░░░░░░█░░▄▀▄▀▄▀▄▀▄▀░░█\r\n//█░░▄▀░░░░░░▄▀░░░░███░░▄▀░░░░░░░░░░█░░▄▀░░░░░░▄▀░░█░░▄▀░░██░░▄▀░░███░░▄▀░░███░░▄▀░░██░░▄▀░░██░░▄▀░░█░░▄▀░░██░░▄▀░░█░░░░░░░░░░▄▀░░█\r\n//█░░▄▀░░██░░▄▀░░█████░░▄▀░░█████████░░▄▀░░██░░▄▀░░█░░▄▀░░██░░▄▀░░███░░▄▀░░███░░▄▀░░██░░▄▀░░░░░░▄▀░░█░░▄▀░░██░░▄▀░░█████████░░▄▀░░█\r\n//█░░▄▀░░██░░▄▀░░░░░░█░░▄▀░░░░░░░░░░█░░▄▀░░██░░▄▀░░█░░▄▀░░░░▄▀▄▀░░█░░░░▄▀░░░░█░░▄▀░░██░░▄▀▄▀▄▀▄▀▄▀░░█░░▄▀░░░░░░▄▀░░█░░░░░░░░░░▄▀░░█\r\n//█░░▄▀░░██░░▄▀▄▀▄▀░░█░░▄▀▄▀▄▀▄▀▄▀░░█░░▄▀░░██░░▄▀░░█░░▄▀▄▀▄▀▄▀░░░░█░░▄▀▄▀▄▀░░█░░▄▀░░██░░░░░░░░░░▄▀░░█░░▄▀▄▀▄▀▄▀▄▀░░█░░▄▀▄▀▄▀▄▀▄▀░░█\r\n//█░░░░░░██░░░░░░░░░░█░░░░░░░░░░░░░░█░░░░░░██░░░░░░█░░░░░░░░░░░░███░░░░░░░░░░█░░░░░░██████████░░░░░░█░░░░░░░░░░░░░░█░░░░░░░░░░░░░░█\r\n//█████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████\r\n\r\n\r\n// John 3:16\r\n// “For God so loved the world, that he gave his only begotten Son, that whosoever believeth in him should not perish, \r\n//  but have everlasting life.”\r\n\r\npragma solidity ^0.8.17;\r\n\r\n//Imports:\r\n//Ownable.sol: This is the OpenZeppelin contract providing ownership control functionalities.\r\nimport \"@openzeppelin/contracts/access/Ownable.sol\";\r\n\r\n//Contract Variables:\r\n//readings: An array of DailyReadingsDetails structs to store daily readings information.\r\ncontract BTRUDailyReadings is Ownable {\r\n    struct DailyReadingsDetails {\r\n        string name;\r\n        string description;\r\n        string ipfsImageHash;\r\n        string readings;\r\n        string date;\r\n    }\r\n\r\n    DailyReadingsDetails[] public readings;\r\n\r\n    //Events:\r\n    //DailyReadingsUpdated: Triggered when daily readings are updated.\r\n    event DailyReadingsUpdated(\r\n        string name,\r\n        string description,\r\n        string ipfsImageHash,\r\n        string readings,\r\n        string date\r\n    );\r\n\r\n    //Struct:\r\n    //DailyReadingsDetails: Struct to store details of daily readings including name, description, image hash, readings content, and date.\r\n    //Constructor:\r\n    //The contract doesn't have a constructor as it inherits from Ownable, which handles owner initialization.\r\n    function dailyReadingsUpdate(\r\n        string memory _name,\r\n        string memory _description,\r\n        string memory _ipfsImageHash,\r\n        string memory _readings,\r\n        string memory _date\r\n    ) public onlyOwner {\r\n        readings.push(DailyReadingsDetails({\r\n            name: _name,\r\n            description: _description,\r\n            ipfsImageHash: _ipfsImageHash,\r\n            readings: _readings,\r\n            date: _date\r\n        }));\r\n\r\n        emit DailyReadingsUpdated(_name, _description, _ipfsImageHash, _readings, _date);\r\n    }\r\n\r\n    //Functions:\r\n    //dailyReadingsUpdate: Allows the owner to update daily readings by adding new entries to the readings array.\r\n    //getDailyReadingsCount: Returns the number of daily readings entries.\r\n    //getDailyReadingsDetails: Returns the details of a specific daily readings entry based on its index in the readings array.\r\n    //getDailyReadingsDetailsRange: Returns a range of daily readings entries based on start and end indices.\r\n    //Modifiers:\r\n    //onlyOwner: Restricts access to functions only to the contract owner.\r\n    function getDailyReadingsCount() public view returns (uint256) {\r\n        return readings.length;\r\n    }\r\n\r\n    function getDailyReadingsDetails(uint256 index) public view returns (DailyReadingsDetails memory) {\r\n        require(index < readings.length, \"Readings index out of bounds\");\r\n        return readings[index];\r\n    }\r\n\r\n    // Function to get a range of readings details from mapping index array.\r\n    function getDailyReadingsDetailsRange(uint256 startIndex, uint256 endIndex) public view returns (DailyReadingsDetails[] memory) {\r\n        require(endIndex >= startIndex, \"End index must be greater or equal to start index\");\r\n        require(endIndex < readings.length, \"End index out of bounds\");\r\n\r\n        uint256 rangeSize = endIndex - startIndex + 1;\r\n        DailyReadingsDetails[] memory detailsRange = new DailyReadingsDetails[](rangeSize);\r\n\r\n        for (uint256 i = 0; i < rangeSize; i++) {\r\n            detailsRange[i] = readings[startIndex + i];\r\n        }\r\n\r\n        return detailsRange;\r\n    }\r\n}"
    }
  }
}}