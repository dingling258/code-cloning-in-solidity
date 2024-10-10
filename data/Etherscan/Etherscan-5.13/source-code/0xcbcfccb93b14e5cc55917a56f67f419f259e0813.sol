{{
  "language": "Solidity",
  "sources": {
    "src/MultiSig.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.20;\n\ncontract SecureMultiWallet {\n    event FundsDeposited(address indexed depositor, uint amount, uint newBalance);\n    event TransactionSubmitted(\n        address indexed initiator,\n        uint indexed txID,\n        address indexed target,\n        uint amount,\n        bytes payload\n    );\n    event TransactionConfirmed(address indexed approver, uint indexed txID);\n    event ConfirmationRevoked(address indexed approver, uint indexed txID);\n    event TransactionExecuted(address indexed executor, uint indexed txID);\n\n    address[] public authorizedUsers;\n    mapping(address => bool) public isAuthorized;\n    uint public requiredApprovals;\n\n    struct PendingTransaction {\n        address target;\n        uint amount;\n        bytes payload;\n        bool hasBeenExecuted;\n        uint approvalCount;\n    }\n\n    // mapping from tx ID => approver => bool\n    mapping(uint => mapping(address => bool)) public hasConfirmed;\n\n    PendingTransaction[] public pendingTransactions;\n\n    modifier onlyAuthorized() {\n        require(isAuthorized[msg.sender], \"Unauthorized\");\n        _;\n    }\n\n    modifier transactionExists(uint _txID) {\n        require(_txID < pendingTransactions.length, \"Transaction not found\");\n        _;\n    }\n\n    modifier notYetExecuted(uint _txID) {\n        require(!pendingTransactions[_txID].hasBeenExecuted, \"Transaction already executed\");\n        _;\n    }\n\n    modifier notYetConfirmed(uint _txID) {\n        require(!hasConfirmed[_txID][msg.sender], \"Transaction already approved\");\n        _;\n    }\n\n    constructor(address[] memory _users, uint _requiredApprovals) {\n        require(_users.length > 0, \"Users required\");\n        require(\n            _requiredApprovals > 0 &&\n                _requiredApprovals <= _users.length,\n            \"Invalid approval count\"\n        );\n\n        for (uint i = 0; i < _users.length; i++) {\n            address user = _users[i];\n\n            require(user != address(0), \"Invalid user\");\n            require(!isAuthorized[user], \"Duplicate user\");\n\n            isAuthorized[user] = true;\n            authorizedUsers.push(user);\n        }\n\n        requiredApprovals = _requiredApprovals;\n    }\n\n    receive() external payable {\n        emit FundsDeposited(msg.sender, msg.value, address(this).balance);\n    }\n\n    function addTransaction(\n        address _target,\n        uint _amount,\n        bytes memory _payload\n    ) public onlyAuthorized {\n        uint txID = pendingTransactions.length;\n\n        pendingTransactions.push(\n            PendingTransaction({\n                target: _target,\n                amount: _amount,\n                payload: _payload,\n                hasBeenExecuted: false,\n                approvalCount: 0\n            })\n        );\n\n        emit TransactionSubmitted(msg.sender, txID, _target, _amount, _payload);\n    }\n\n    function approveTransaction(\n        uint _txID\n    ) public onlyAuthorized transactionExists(_txID) notYetExecuted(_txID) notYetConfirmed(_txID) {\n        PendingTransaction storage pendingTx = pendingTransactions[_txID];\n        pendingTx.approvalCount += 1;\n        hasConfirmed[_txID][msg.sender] = true;\n\n        emit TransactionConfirmed(msg.sender, _txID);\n    }\n\n    function runTransaction(\n        uint _txID\n    ) public onlyAuthorized transactionExists(_txID) notYetExecuted(_txID) {\n        PendingTransaction storage pendingTx = pendingTransactions[_txID];\n\n        require(\n            pendingTx.approvalCount >= requiredApprovals,\n            \"Insufficient approvals\"\n        );\n\n        pendingTx.hasBeenExecuted = true;\n\n        (bool success, ) = pendingTx.target.call{value: pendingTx.amount}(\n            pendingTx.payload\n        );\n        require(success, \"Transaction execution failed\");\n\n        emit TransactionExecuted(msg.sender, _txID);\n    }\n\n    function retractApproval(\n        uint _txID\n    ) public onlyAuthorized transactionExists(_txID) notYetExecuted(_txID) {\n        PendingTransaction storage pendingTx = pendingTransactions[_txID];\n\n        require(hasConfirmed[_txID][msg.sender], \"No prior approval found\");\n\n        pendingTx.approvalCount -= 1;\n        hasConfirmed[_txID][msg.sender] = false;\n\n        emit ConfirmationRevoked(msg.sender, _txID);\n    }\n\n    function listUsers() public view returns (address[] memory) {\n        return authorizedUsers;\n    }\n\n    function countTransactions() public view returns (uint) {\n        return pendingTransactions.length;\n    }\n\n    function fetchTransaction(\n        uint _txID\n    )\n        public\n        view\n        returns (\n            address target,\n            uint amount,\n            bytes memory payload,\n            bool hasBeenExecuted,\n            uint approvalCount\n        )\n    {\n        PendingTransaction storage pendingTx = pendingTransactions[_txID];\n\n        return (\n            pendingTx.target,\n            pendingTx.amount,\n            pendingTx.payload,\n            pendingTx.hasBeenExecuted,\n            pendingTx.approvalCount\n        );\n    }\n}"
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
    "evmVersion": "cancun",
    "viaIR": true
  }
}}