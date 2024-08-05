{{
  "language": "Solidity",
  "settings": {
    "evmVersion": "shanghai",
    "libraries": {},
    "metadata": {
      "bytecodeHash": "ipfs",
      "useLiteralContent": true
    },
    "optimizer": {
      "enabled": true,
      "runs": 1000000
    },
    "remappings": [],
    "viaIR": true,
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
    "contracts/AtomicWethDepositor.sol": {
      "content": "// SPDX-License-Identifier: GPL-3.0-only\npragma solidity ^0.8.0;\n\ninterface Weth {\n    function withdraw(uint256 _wad) external;\n\n    function transferFrom(address _from, address _to, uint256 _wad) external;\n}\n\ninterface OvmL1Bridge {\n    function depositETHTo(address _to, uint32 _l2Gas, bytes calldata _data) external payable;\n}\n\ninterface PolygonL1Bridge {\n    function depositEtherFor(address _to) external payable;\n}\n\ninterface ZkSyncL1Bridge {\n    function requestL2Transaction(\n        address _contractL2,\n        uint256 _l2Value,\n        bytes calldata _calldata,\n        uint256 _l2GasLimit,\n        uint256 _l2GasPerPubdataByteLimit,\n        bytes[] calldata _factoryDeps,\n        address _refundRecipient\n    ) external payable;\n\n    function l2TransactionBaseCost(\n        uint256 _gasPrice,\n        uint256 _l2GasLimit,\n        uint256 _l2GasPerPubdataByteLimit\n    ) external pure returns (uint256);\n}\n\ninterface LineaL1MessageService {\n    function sendMessage(address _to, uint256 _fee, bytes calldata _calldata) external payable;\n}\n\n/**\n * @notice Contract deployed on Ethereum helps relay bots atomically unwrap and bridge WETH over the canonical chain\n * bridges for Optimism, Base, Boba, ZkSync, Linea, and Polygon. Needed as these chains only support bridging of ETH,\n * not WETH.\n */\n\ncontract AtomicWethDepositor {\n    Weth public immutable weth = Weth(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);\n    OvmL1Bridge public immutable optimismL1Bridge = OvmL1Bridge(0x99C9fc46f92E8a1c0deC1b1747d010903E884bE1);\n    OvmL1Bridge public immutable bobaL1Bridge = OvmL1Bridge(0xdc1664458d2f0B6090bEa60A8793A4E66c2F1c00);\n    OvmL1Bridge public immutable baseL1Bridge = OvmL1Bridge(0x3154Cf16ccdb4C6d922629664174b904d80F2C35);\n    PolygonL1Bridge public immutable polygonL1Bridge = PolygonL1Bridge(0xA0c68C638235ee32657e8f720a23ceC1bFc77C77);\n    ZkSyncL1Bridge public immutable zkSyncL1Bridge = ZkSyncL1Bridge(0x32400084C286CF3E17e7B677ea9583e60a000324);\n    LineaL1MessageService public immutable lineaL1MessageService =\n        LineaL1MessageService(0xd19d4B5d358258f05D7B411E21A1460D11B0876F);\n\n    event ZkSyncEthDepositInitiated(address indexed from, address indexed to, uint256 amount);\n    event LineaEthDepositInitiated(address indexed from, address indexed to, uint256 amount);\n\n    function bridgeWethToOvm(address to, uint256 amount, uint32 l2Gas, uint256 chainId) public {\n        weth.transferFrom(msg.sender, address(this), amount);\n        weth.withdraw(amount);\n\n        if (chainId == 10) {\n            optimismL1Bridge.depositETHTo{ value: amount }(to, l2Gas, \"\");\n        } else if (chainId == 8453) {\n            baseL1Bridge.depositETHTo{ value: amount }(to, l2Gas, \"\");\n        } else if (chainId == 288) {\n            bobaL1Bridge.depositETHTo{ value: amount }(to, l2Gas, \"\");\n        } else {\n            revert(\"Invalid OVM chainId\");\n        }\n    }\n\n    function bridgeWethToPolygon(address to, uint256 amount) public {\n        weth.transferFrom(msg.sender, address(this), amount);\n        weth.withdraw(amount);\n        polygonL1Bridge.depositEtherFor{ value: amount }(to);\n    }\n\n    function bridgeWethToLinea(address to, uint256 amount) public payable {\n        weth.transferFrom(msg.sender, address(this), amount);\n        weth.withdraw(amount);\n        lineaL1MessageService.sendMessage{ value: amount + msg.value }(to, msg.value, \"\");\n        // Emit an event that we can easily track in the Linea-related adapters/finalizers\n        emit LineaEthDepositInitiated(msg.sender, to, amount);\n    }\n\n    function bridgeWethToZkSync(\n        address to,\n        uint256 amount,\n        uint256 l2GasLimit,\n        uint256 l2GasPerPubdataByteLimit,\n        address refundRecipient\n    ) public {\n        // The ZkSync Mailbox contract checks that the msg.value of the transaction is enough to cover the transaction base\n        // cost. The transaction base cost can be queried from the Mailbox by passing in an L1 \"executed\" gas price,\n        // which is the priority fee plus base fee. This is the same as calling tx.gasprice on-chain as the Mailbox\n        // contract does here:\n        // https://github.com/matter-labs/era-contracts/blob/3a4506522aaef81485d8abb96f5a6394bd2ba69e/ethereum/contracts/zksync/facets/Mailbox.sol#L287\n        uint256 l2TransactionBaseCost = zkSyncL1Bridge.l2TransactionBaseCost(\n            tx.gasprice,\n            l2GasLimit,\n            l2GasPerPubdataByteLimit\n        );\n        uint256 valueToSubmitXChainMessage = l2TransactionBaseCost + amount;\n        weth.transferFrom(msg.sender, address(this), valueToSubmitXChainMessage);\n        weth.withdraw(valueToSubmitXChainMessage);\n        zkSyncL1Bridge.requestL2Transaction{ value: valueToSubmitXChainMessage }(\n            to,\n            amount,\n            \"\",\n            l2GasLimit,\n            l2GasPerPubdataByteLimit,\n            new bytes[](0),\n            refundRecipient\n        );\n\n        // Emit an event that we can easily track in the ZkSyncAdapter because otherwise there is no easy event to\n        // track ETH deposit initiations.\n        emit ZkSyncEthDepositInitiated(msg.sender, to, amount);\n    }\n\n    fallback() external payable {}\n\n    // Included to remove a compilation warning.\n    // NOTE: this should not affect behavior.\n    receive() external payable {}\n}\n"
    }
  }
}}