{{
  "language": "Solidity",
  "sources": {
    "sale-common/base/Manager.sol": {
      "content": "// SPDX-License-Identifier: BUSL-1.1\n\npragma solidity 0.8.21;\n\nimport \"../interfaces/IManager.sol\";\nimport \"../../interfaces/IRoles.sol\";\nimport \"../../interfaces/IDataLog.sol\";\nimport \"../../Constant.sol\";\n\ncontract Manager is IManager {\n\n    IRoles internal _roles;\n    IDataLog internal _logger;\n    address public daoMultiSig;\n    address public officialSigner;\n    \n    modifier onlyFactory() {\n        require(_factoryMap[msg.sender], \"Not Factory\");\n        _;\n    }\n    \n    modifier onlyAdmin() {\n        require(_roles.isAdmin(msg.sender), \"Not Admin\");\n        _;\n    }\n    \n    // Events\n    event FactoryRegistered(address indexed deployedAddress);\n    event DaoChanged(address oldDao, address newDao);\n    event OfficialSignerChanged(address oldSigner, address newSigner);\n    event EntryAdded(address indexed contractAddress, address indexed projectOwner);\n    \n    struct CampaignInfo {\n        address contractAddress;\n        address owner;\n    }\n    \n    // History & list of factories.\n    mapping(address => bool) private _factoryMap;\n    address[] private _factories;\n    \n    // History/list of all IDOs\n    mapping(uint => CampaignInfo) internal _indexCampaignMap; // Starts from 1. Zero is invalid //\n    mapping(address => uint) internal _addressIndexMap;  // Maps a campaign address to an index in _indexCampaignMap.\n    uint internal _count;\n    \n    constructor(IRoles roles,  IDataLog logger, address dao, address signer) \n    {\n        require(dao != Constant.ZERO && signer != Constant.ZERO, \"Invalid address\");\n        _roles = roles;\n        _logger = logger;\n        daoMultiSig = dao;\n        officialSigner = signer;\n    }\n    \n    // EXTERNAL FUNCTIONS\n    function getCampaignInfo(uint id) external view returns (CampaignInfo memory) {\n        return _indexCampaignMap[id];\n    }\n    \n    function getTotalCampaigns() external view returns (uint) {\n        return _count;\n    }\n    \n    function registerFactory(address newFactory) external onlyAdmin {\n        if ( _factoryMap[newFactory] == false) {\n            _factoryMap[newFactory] = true;\n            _factories.push(newFactory);\n            emit FactoryRegistered(newFactory);\n        }\n    }\n\n    function setDaoMultiSig(address newDao) external onlyAdmin {\n        if (newDao != Constant.ZERO && newDao != daoMultiSig) {\n            emit DaoChanged(daoMultiSig, newDao);\n            daoMultiSig = newDao;\n        }\n    }\n\n    function setOfficialSigner(address newSigner) external onlyAdmin {\n        if (newSigner != Constant.ZERO && newSigner != officialSigner) {\n            emit OfficialSignerChanged(officialSigner, newSigner);\n            officialSigner = newSigner;\n        }\n    }\n\n    function isFactory(address contractAddress) external view returns (bool) {\n        return _factoryMap[contractAddress];\n    }\n    \n    function getFactory(uint id) external view returns (address) {\n        return ((id < _factories.length) ? _factories[id] : Constant.ZERO );\n    }\n\n    // IMPLEMENTS IManager\n    function getRoles() external view override returns (IRoles) {\n        return _roles;\n    }\n\n    function getDaoMultiSig() external override view returns (address) {\n        return daoMultiSig;\n    }\n\n     function getOfficialSigner() external override view returns (address) {\n        return officialSigner;\n    }\n\n    function getLogger() external override view returns(IDataLog) {\n        return _logger;\n    }\n\n\n    function logData(address user, DataSource source, DataAction action, uint data1, uint data2) external override {\n\n        // From an official campaign ?\n        uint id = _addressIndexMap[msg.sender];\n        require(id > 0, \"Invalid camapign\");   \n\n        _logger.log(msg.sender, user, uint(source), uint(action), data1, data2);\n    }\n\n    function addEntry(address newContract, address owner) external override onlyFactory {\n        _count++;\n        _indexCampaignMap[_count] = CampaignInfo(newContract, owner);\n        _addressIndexMap[newContract] = _count;\n        emit EntryAdded(newContract, owner);\n    }\n}\n\n"
    },
    "Constant.sol": {
      "content": "// SPDX-License-Identifier: BUSL-1.1\n\n\npragma solidity 0.8.21;\n\nlibrary Constant {\n\n    address public constant ZERO                                = address(0);\n    uint    public constant E18                                 = 1e18;\n    uint    public constant PCNT_100                            = 1e18;\n    uint    public constant PCNT_50                             = 5e17;\n    uint    public constant PCNT_5                              = 5e16;\n    uint    public constant E12                                 = 1e12;\n    uint    public constant MAX_INSURANCE_DURATION              = 10 days; \n    uint    public constant MIN_QUALIFY_SV_LAUNCH               = 100e18;\n    bytes   public constant ETH_SIGN_PREFIX                     = \"\\x19Ethereum Signed Message:\\n32\";\n  \n}\n\n\n\n\n"
    },
    "interfaces/IDataLog.sol": {
      "content": "// SPDX-License-Identifier: BUSL-1.1\n\npragma solidity 0.8.21;\n\nenum DataSource {\n    Campaign,\n    SuperCerts,\n    Governance,\n    Referral,\n    Proposal,\n    MarketPlace,\n    SuperFarm,\n    EggPool,\n    Swap\n}\n\nenum DataAction {\n    Buy,\n    Refund,\n    ClaimCerts,\n    ClaimTokens,\n    ClaimTeamTokens,\n    List,\n    Unlist,\n    AddLp,\n    RemoveLp,\n    Rebate,\n    Revenue,\n    Swap,\n    ClaimNoCerts\n}\n\ninterface IDataLog {\n    \n    function log(address fromContract, address fromUser, uint source, uint action, uint data1, uint data2) external;\n\n}\n\n"
    },
    "interfaces/IRoles.sol": {
      "content": "// SPDX-License-Identifier: BUSL-1.1\n\npragma solidity 0.8.21;\n\ninterface IRoles {\n    function isAdmin(address user) view external returns (bool);\n    function isDeployer(address user) view external returns (bool);\n    function isConfigurator(address user) view external returns (bool);\n    function isApprover(address user) view external returns (bool);\n    function isTallyHandler(address user) view external returns (bool);\n    function isRole(string memory roleName, address user) view external returns (bool);\n}\n"
    },
    "sale-common/interfaces/IManager.sol": {
      "content": "// SPDX-License-Identifier: BUSL-1.1\n\npragma solidity 0.8.21;\n\nimport \"../../interfaces/IRoles.sol\";\nimport \"../../interfaces/IDataLog.sol\";\n\n\ninterface IManager {\n    function getRoles() external view returns (IRoles);\n    function getDaoMultiSig() external view returns (address);\n    function getOfficialSigner() external view returns (address);\n    function getLogger() external view returns(IDataLog);\n    function logData(address user, DataSource source, DataAction action, uint data1, uint data2) external;\n    function addEntry(address newContract, address owner) external;\n}\n\n"
    }
  },
  "settings": {
    "optimizer": {
      "enabled": true,
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