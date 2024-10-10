{{
  "language": "Solidity",
  "settings": {
    "evmVersion": "london",
    "libraries": {},
    "metadata": {
      "bytecodeHash": "none",
      "useLiteralContent": true
    },
    "optimizer": {
      "enabled": true,
      "runs": 10
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
    "contracts/common/diamonds/DiamondImplementation.sol": {
      "content": "\n// SPDX-License-Identifier: MIT\npragma solidity 0.8.23;\n\ncontract DiamondImplementation {\n  \n\n    struct Tuple6871229 {\n        address facetAddress;\n        uint8 action;\n        bytes4[] functionSelectors;\n    }\n\n    struct Tuple1236461 {\n        address facetAddress;\n        bytes4[] functionSelectors;\n    }\n\n    struct Tuple3833798 {\n        uint8 launchPadType;\n        Tuple031699 launchPadInfo;\n        Tuple4286722[] releaseSchedule;\n        Tuple6673812 createErc20Input;\n        address referrer;\n        uint8 paymentMethod;\n    }\n\n    struct Tuple031699 {\n        address owner;\n        address tokenAddress;\n        address paymentTokenAddress;\n        uint256 price;\n        Tuple632674 fundTarget;\n        uint256 maxInvestPerWallet;\n        uint256 startTimestamp;\n        uint256 duration;\n        uint256 tokenCreationDeadline;\n        Tuple0343533 refundInfo;\n        Tuple9075317 idoInfo;\n    }\n\n    struct Tuple632674 {\n        uint256 softCap;\n        uint256 hardCap;\n    }\n\n    struct Tuple0343533 {\n        uint256 penaltyFeePercent;\n        uint256 expireDuration;\n    }\n\n    struct Tuple9075317 {\n        bool enabled;\n        address dexRouter;\n        address pairToken;\n        uint256 price;\n        uint256 amountToList;\n    }\n\n    struct Tuple4286722 {\n        uint256 timestamp;\n        uint256 percent;\n    }\n\n    struct Tuple6673812 {\n        string name;\n        string symbol;\n        string logo;\n        uint8 decimals;\n        uint256 maxSupply;\n        address owner;\n        uint256 treasuryReserved;\n    }\n\n    struct Tuple000541 {\n        address referrer;\n        uint256 usdPrice;\n        address user;\n        uint8 paymentMethod;\n    }\n      \n\n   function DEFAULT_ADMIN_ROLE() external pure returns (bytes32 ) {}\n\n   function WHITELISTED_ROLE() external pure returns (bytes32 ) {}\n\n   function WHITELIST_ADMIN_ROLE() external pure returns (bytes32 ) {}\n\n   function getRoleAdmin(bytes32  role) external view returns (bytes32 ) {}\n\n   function getRoleMember(bytes32  role, uint256  index) external view returns (address ) {}\n\n   function getRoleMemberCount(bytes32  role) external view returns (uint256 ) {}\n\n   function grantRole(bytes32  role, address  account) external {}\n\n   function hasRole(bytes32  role, address  account) external view returns (bool ) {}\n\n   function renounceRole(bytes32  role) external {}\n\n   function revokeRole(bytes32  role, address  account) external {}\n\n   function diamondCut(Tuple6871229[] memory _diamondCut, address  _init, bytes memory _calldata) external {}\n\n   function facetAddress(bytes4  _functionSelector) external view returns (address  facetAddress_) {}\n\n   function facetAddresses() external view returns (address[] memory facetAddresses_) {}\n\n   function facetFunctionSelectors(address  _facet) external view returns (bytes4[] memory facetFunctionSelectors_) {}\n\n   function facets() external view returns (Tuple1236461[] memory facets_) {}\n\n   function supportsInterface(bytes4  _interfaceId) external view returns (bool ) {}\n\n   function implementation() external view returns (address ) {}\n\n   function setDummyImplementation(address  _implementation) external {}\n\n   function addInvestorToLaunchPad(address  investor) external {}\n\n   function createLaunchPad(Tuple3833798 memory storeInput) external payable {}\n\n   function createTokenAfterICO(address  launchPad) external payable {}\n\n   function createV2LiquidityPool(address  launchPad) external payable {}\n\n   function getLaunchPadCountByOwner(address  owner) external view returns (uint256 ) {}\n\n   function getLaunchPadsByInvestorPaginated(address  investor, uint256  quantity, uint256  page) external view returns (address[] memory) {}\n\n   function getLaunchPadsByOwnerPaginated(address  owner, uint256  quantity, uint256  page) external view returns (address[] memory) {}\n\n   function getLaunchPadsPaginated(uint256  quantity, uint256  page) external view returns (address[] memory) {}\n\n   function getMaxTokenCreationDeadline() external view returns (uint256 ) {}\n\n   function launchPadTokenInfo(address  launchPadAddress) external view returns (Tuple6673812 memory createErc20Input) {}\n\n   function tokenLauncherERC20() external view returns (address ) {}\n\n   function updateLaunchPadOwner(address  launchPadAddress, address  newOwner) external {}\n\n   function updateMaxTokenCreationDeadline(uint256  newMaxTokenCreationDeadline) external {}\n\n   function adminWithdraw(address  tokenAddress, uint256  amount) external {}\n\n   function getRouterAddress() external view returns (address ) {}\n\n   function getTokenFiToken() external view returns (address ) {}\n\n   function getTreasury() external view returns (address ) {}\n\n   function getUsdToken() external view returns (address ) {}\n\n   function isContract(address  addr) external view returns (bool ) {}\n\n   function processPayment(Tuple000541 memory input) external payable {}\n\n   function setTreasury(address  newTreasury) external {}\n\n   function addDiscountNFTs(address[] memory newDiscountNFTs) external {}\n\n   function getFeePercentage() external view returns (uint256 ) {}\n\n   function getPrice(address  user, uint8  launchPadType) external view returns (uint256 ) {}\n\n   function setDeployLaunchPadPrice(uint256  newPrice, uint8  launchPadType) external {}\n\n   function setFeePercentage(uint256  newFeePercentage) external {}\n\n   function pause() external {}\n\n   function paused() external view returns (bool  status) {}\n\n   function unpause() external {}\n\n   function setWhitelistEnabled(bool  enabled, bytes32  productId) external {}\n}\n  "
    }
  }
}}