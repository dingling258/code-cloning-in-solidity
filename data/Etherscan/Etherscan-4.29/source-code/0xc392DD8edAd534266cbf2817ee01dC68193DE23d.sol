{{
  "language": "Solidity",
  "sources": {
    "repos/scalable-dex/contracts/src/interfaces/BlockDirectCall.sol": {
      "content": "/*\n  Copyright 2019-2024 StarkWare Industries Ltd.\n\n  Licensed under the Apache License, Version 2.0 (the \"License\").\n  You may not use this file except in compliance with the License.\n  You may obtain a copy of the License at\n\n  https://www.starkware.co/open-source-license/\n\n  Unless required by applicable law or agreed to in writing,\n  software distributed under the License is distributed on an \"AS IS\" BASIS,\n  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\n  See the License for the specific language governing permissions\n  and limitations under the License.\n*/\n// SPDX-License-Identifier: Apache-2.0.\npragma solidity ^0.6.12;\n\n/*\n  This contract provides means to block direct call of an external function.\n  A derived contract (e.g. MainDispatcherBase) should decorate sensitive functions with the\n  notCalledDirectly modifier, thereby preventing it from being called directly, and allowing only calling\n  using delegate_call.\n*/\nabstract contract BlockDirectCall {\n    address immutable this_;\n\n    constructor() internal {\n        this_ = address(this);\n    }\n\n    modifier notCalledDirectly() {\n        require(this_ != address(this), \"DIRECT_CALL_DISALLOWED\");\n        _;\n    }\n}\n"
    },
    "repos/scalable-dex/contracts/src/libraries/Common.sol": {
      "content": "/*\n  Copyright 2019-2024 StarkWare Industries Ltd.\n\n  Licensed under the Apache License, Version 2.0 (the \"License\").\n  You may not use this file except in compliance with the License.\n  You may obtain a copy of the License at\n\n  https://www.starkware.co/open-source-license/\n\n  Unless required by applicable law or agreed to in writing,\n  software distributed under the License is distributed on an \"AS IS\" BASIS,\n  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\n  See the License for the specific language governing permissions\n  and limitations under the License.\n*/\n// SPDX-License-Identifier: Apache-2.0.\npragma solidity ^0.6.12;\n\n/*\n  Common Utility librarries.\n  I. Addresses (extending address).\n*/\nlibrary Addresses {\n    function isContract(address account) internal view returns (bool) {\n        uint256 size;\n        assembly {\n            size := extcodesize(account)\n        }\n        return size > 0;\n    }\n\n    function performEthTransfer(address recipient, uint256 amount) internal {\n        (bool success, ) = recipient.call{value: amount}(\"\"); // NOLINT: low-level-calls.\n        require(success, \"ETH_TRANSFER_FAILED\");\n    }\n\n    /*\n      Safe wrapper around ERC20/ERC721 calls.\n      This is required because many deployed ERC20 contracts don't return a value.\n      See https://github.com/ethereum/solidity/issues/4116.\n    */\n    function safeTokenContractCall(address tokenAddress, bytes memory callData) internal {\n        require(isContract(tokenAddress), \"BAD_TOKEN_ADDRESS\");\n        // NOLINTNEXTLINE: low-level-calls.\n        (bool success, bytes memory returndata) = tokenAddress.call(callData);\n        require(success, string(returndata));\n\n        if (returndata.length > 0) {\n            require(abi.decode(returndata, (bool)), \"TOKEN_OPERATION_FAILED\");\n        }\n    }\n\n    /*\n      Validates that the passed contract address is of a real contract,\n      and that its id hash (as infered fromn identify()) matched the expected one.\n    */\n    function validateContractId(address contractAddress, bytes32 expectedIdHash) internal {\n        require(isContract(contractAddress), \"ADDRESS_NOT_CONTRACT\");\n        (bool success, bytes memory returndata) = contractAddress.call( // NOLINT: low-level-calls.\n            abi.encodeWithSignature(\"identify()\")\n        );\n        require(success, \"FAILED_TO_IDENTIFY_CONTRACT\");\n        string memory realContractId = abi.decode(returndata, (string));\n        require(\n            keccak256(abi.encodePacked(realContractId)) == expectedIdHash,\n            \"UNEXPECTED_CONTRACT_IDENTIFIER\"\n        );\n    }\n}\n\n/*\n  II. StarkExTypes - Common data types.\n*/\nlibrary StarkExTypes {\n    // Structure representing a list of verifiers (validity/availability).\n    // A statement is valid only if all the verifiers in the list agree on it.\n    // Adding a verifier to the list is immediate - this is used for fast resolution of\n    // any soundness issues.\n    // Removing from the list is time-locked, to ensure that any user of the system\n    // not content with the announced removal has ample time to leave the system before it is\n    // removed.\n    struct ApprovalChainData {\n        address[] list;\n        // Represents the time after which the verifier with the given address can be removed.\n        // Removal of the verifier with address A is allowed only in the case the value\n        // of unlockedForRemovalTime[A] != 0 and unlockedForRemovalTime[A] < (current time).\n        mapping(address => uint256) unlockedForRemovalTime;\n    }\n}\n"
    },
    "repos/scalable-dex/contracts/src/components/GovernanceStorage.sol": {
      "content": "/*\n  Copyright 2019-2024 StarkWare Industries Ltd.\n\n  Licensed under the Apache License, Version 2.0 (the \"License\").\n  You may not use this file except in compliance with the License.\n  You may obtain a copy of the License at\n\n  https://www.starkware.co/open-source-license/\n\n  Unless required by applicable law or agreed to in writing,\n  software distributed under the License is distributed on an \"AS IS\" BASIS,\n  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\n  See the License for the specific language governing permissions\n  and limitations under the License.\n*/\n// SPDX-License-Identifier: Apache-2.0.\npragma solidity ^0.6.12;\nimport \"../interfaces/MGovernance.sol\";\n\n/*\n  Holds the governance slots for ALL entities, including proxy and the main contract.\n*/\ncontract GovernanceStorage {\n    // A map from a Governor tag to its own GovernanceInfoStruct.\n    mapping(string => GovernanceInfoStruct) internal governanceInfo; //NOLINT uninitialized-state.\n}\n"
    },
    "repos/scalable-dex/contracts/src/interfaces/IDispatcherBase.sol": {
      "content": "/*\n  Copyright 2019-2024 StarkWare Industries Ltd.\n\n  Licensed under the Apache License, Version 2.0 (the \"License\").\n  You may not use this file except in compliance with the License.\n  You may obtain a copy of the License at\n\n  https://www.starkware.co/open-source-license/\n\n  Unless required by applicable law or agreed to in writing,\n  software distributed under the License is distributed on an \"AS IS\" BASIS,\n  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\n  See the License for the specific language governing permissions\n  and limitations under the License.\n*/\n// SPDX-License-Identifier: Apache-2.0.\npragma solidity ^0.6.12;\n\n/*\n  Interface for a generic dispatcher to use, which the concrete dispatcher must implement.\n  It contains the functions that are specific to the concrete dispatcher instance.\n  The interface is implemented as contract, because interface implies all methods external.\n*/\nabstract contract IDispatcherBase {\n    function getSubContract(bytes4 selector) public view virtual returns (address);\n\n    function setSubContractAddress(uint256 index, address subContract) internal virtual;\n\n    function getNumSubcontracts() internal pure virtual returns (uint256);\n\n    function validateSubContractIndex(uint256 index, address subContract) internal pure virtual;\n\n    /*\n      Ensures initializer can be called. Reverts otherwise.\n    */\n    function initializationSentinel() internal view virtual;\n}\n"
    },
    "repos/scalable-dex/contracts/src/interfaces/Identity.sol": {
      "content": "/*\n  Copyright 2019-2024 StarkWare Industries Ltd.\n\n  Licensed under the Apache License, Version 2.0 (the \"License\").\n  You may not use this file except in compliance with the License.\n  You may obtain a copy of the License at\n\n  https://www.starkware.co/open-source-license/\n\n  Unless required by applicable law or agreed to in writing,\n  software distributed under the License is distributed on an \"AS IS\" BASIS,\n  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\n  See the License for the specific language governing permissions\n  and limitations under the License.\n*/\n// SPDX-License-Identifier: Apache-2.0.\npragma solidity ^0.6.12;\n\ninterface Identity {\n    /*\n      Allows a caller, typically another contract,\n      to ensure that the provided address is of the expected type and version.\n    */\n    function identify() external pure returns (string memory);\n}\n"
    },
    "repos/scalable-dex/contracts/src/interfaces/MGovernance.sol": {
      "content": "/*\n  Copyright 2019-2024 StarkWare Industries Ltd.\n\n  Licensed under the Apache License, Version 2.0 (the \"License\").\n  You may not use this file except in compliance with the License.\n  You may obtain a copy of the License at\n\n  https://www.starkware.co/open-source-license/\n\n  Unless required by applicable law or agreed to in writing,\n  software distributed under the License is distributed on an \"AS IS\" BASIS,\n  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\n  See the License for the specific language governing permissions\n  and limitations under the License.\n*/\n// SPDX-License-Identifier: Apache-2.0.\npragma solidity ^0.6.12;\n\nstruct GovernanceInfoStruct {\n    mapping(address => bool) effectiveGovernors;\n    address candidateGovernor;\n    bool initialized;\n}\n\nabstract contract MGovernance {\n    function _isGovernor(address testGovernor) internal view virtual returns (bool);\n\n    /*\n      Allows calling the function only by a Governor.\n    */\n    modifier onlyGovernance() {\n        require(_isGovernor(msg.sender), \"ONLY_GOVERNANCE\");\n        _;\n    }\n}\n"
    },
    "repos/scalable-dex/contracts/src/interfaces/MainDispatcher.sol": {
      "content": "/*\n  Copyright 2019-2024 StarkWare Industries Ltd.\n\n  Licensed under the Apache License, Version 2.0 (the \"License\").\n  You may not use this file except in compliance with the License.\n  You may obtain a copy of the License at\n\n  https://www.starkware.co/open-source-license/\n\n  Unless required by applicable law or agreed to in writing,\n  software distributed under the License is distributed on an \"AS IS\" BASIS,\n  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\n  See the License for the specific language governing permissions\n  and limitations under the License.\n*/\n// SPDX-License-Identifier: Apache-2.0.\npragma solidity ^0.6.12;\n\nimport \"../components/MainStorage.sol\";\nimport \"./MainDispatcherBase.sol\";\n\nabstract contract MainDispatcher is MainStorage, MainDispatcherBase {\n    uint256 constant SUBCONTRACT_BITS = 4;\n\n    function magicSalt() internal pure virtual returns (uint256);\n\n    function handlerMapSection(uint256 section) internal pure virtual returns (uint256);\n\n    function expectedIdByIndex(uint256 index) internal pure virtual returns (string memory id);\n\n    function validateSubContractIndex(uint256 index, address subContract) internal pure override {\n        string memory id = SubContractor(subContract).identify();\n        bytes32 hashed_expected_id = keccak256(abi.encodePacked(expectedIdByIndex(index)));\n        require(\n            hashed_expected_id == keccak256(abi.encodePacked(id)),\n            \"MISPLACED_INDEX_OR_BAD_CONTRACT_ID\"\n        );\n\n        // Gets the list of critical selectors from the sub-contract and checks that the selector\n        // is mapped to that sub-contract.\n        bytes4[] memory selectorsToValidate = SubContractor(subContract).validatedSelectors();\n\n        for (uint256 i = 0; i < selectorsToValidate.length; i++) {\n            require(\n                getSubContractIndex(selectorsToValidate[i]) == index,\n                \"INCONSISTENT_DISPATCHER_MAP\"\n            );\n        }\n    }\n\n    function handlingContractId(bytes4 selector) external pure virtual returns (string memory id) {\n        uint256 index = getSubContractIndex(selector);\n        return expectedIdByIndex(index);\n    }\n\n    /*\n      Returns the index in subContracts where the address of the sub-contract implementing\n      the function with the queried selector is held.\n\n      Note: The nature of the sub-contracts handler map is such that all the required selectors\n      are mapped. However, other selectors, such that are not implemented in any subcontract,\n      may also return a sub-contract address.\n      This behavior is by-design, and not a problem.\n    */\n    function getSubContractIndex(bytes4 selector) internal pure returns (uint256) {\n        uint256 location = 0xFF & uint256(keccak256(abi.encodePacked(selector, magicSalt())));\n        uint256 offset = (SUBCONTRACT_BITS * location) % 256;\n\n        // We have 64 locations in each register, hence the >> 6 (i.e. location // 64).\n        return (handlerMapSection(location >> 6) >> offset) & 0xF;\n    }\n\n    /*\n      Returns the address of the sub-contract that would be delegated to handle a call\n      with the queried selector. (see note above).\n    */\n    function getSubContract(bytes4 selector) public view override returns (address) {\n        return subContracts[getSubContractIndex(selector)];\n    }\n\n    function setSubContractAddress(uint256 index, address subContractAddress) internal override {\n        subContracts[index] = subContractAddress;\n    }\n}\n"
    },
    "repos/scalable-dex/contracts/src/interfaces/MainDispatcherBase.sol": {
      "content": "/*\n  Copyright 2019-2024 StarkWare Industries Ltd.\n\n  Licensed under the Apache License, Version 2.0 (the \"License\").\n  You may not use this file except in compliance with the License.\n  You may obtain a copy of the License at\n\n  https://www.starkware.co/open-source-license/\n\n  Unless required by applicable law or agreed to in writing,\n  software distributed under the License is distributed on an \"AS IS\" BASIS,\n  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\n  See the License for the specific language governing permissions\n  and limitations under the License.\n*/\n// SPDX-License-Identifier: Apache-2.0.\npragma solidity ^0.6.12;\n\nimport \"./SubContractor.sol\";\nimport \"./IDispatcherBase.sol\";\nimport \"../interfaces/BlockDirectCall.sol\";\nimport \"../libraries/Common.sol\";\n\nabstract contract MainDispatcherBase is IDispatcherBase, BlockDirectCall {\n    using Addresses for address;\n\n    /*\n      This entry point serves only transactions with empty calldata. (i.e. pure value transfer tx).\n      We don't expect to receive such, thus block them.\n    */\n    receive() external payable {\n        revert(\"CONTRACT_NOT_EXPECTED_TO_RECEIVE\");\n    }\n\n    fallback() external payable {\n        address subContractAddress = getSubContract(msg.sig);\n        require(subContractAddress != address(0x0), \"NO_CONTRACT_FOR_FUNCTION\");\n\n        assembly {\n            // Copy msg.data. We take full control of memory in this inline assembly\n            // block because it will not return to Solidity code. We overwrite the\n            // Solidity scratch pad at memory position 0.\n            calldatacopy(0, 0, calldatasize())\n\n            // Call the implementation.\n            // out and outsize are 0 for now, as we don\"t know the out size yet.\n            let result := delegatecall(gas(), subContractAddress, 0, calldatasize(), 0, 0)\n\n            // Copy the returned data.\n            returndatacopy(0, 0, returndatasize())\n\n            switch result\n            // delegatecall returns 0 on error.\n            case 0 {\n                revert(0, returndatasize())\n            }\n            default {\n                return(0, returndatasize())\n            }\n        }\n    }\n\n    /*\n      1. Extract subcontracts.\n      2. Verify correct sub-contract initializer size.\n      3. Extract sub-contract initializer data.\n      4. Call sub-contract initializer.\n\n      The init data bytes passed to initialize are structed as following:\n      I. N slots (uin256 size) addresses of the deployed sub-contracts.\n      II. An address of an external initialization contract (optional, or ZERO_ADDRESS).\n      III. (Up to) N bytes sections of the sub-contracts initializers.\n\n      If already initialized (i.e. upgrade) we expect the init data to be consistent with this.\n      and if a different size of init data is expected when upgrading, the initializerSize should\n      reflect this.\n\n      If an external initializer contract is not used, ZERO_ADDRESS is passed in its slot.\n      If the external initializer contract is used, all the remaining init data is passed to it,\n      and internal initialization will not occur.\n\n      External Initialization Contract\n      --------------------------------\n      External Initialization Contract (EIC) is a hook for custom initialization.\n      Typically in an upgrade flow, the expected initialization contains only the addresses of\n      the sub-contracts. Normal initialization of the sub-contracts is such that is not needed\n      in an upgrade, and actually may be very dangerous, as changing of state on a working system\n      may corrupt it.\n\n      In the event that some state initialization is required, the EIC is a hook that allows this.\n      It may be deployed and called specifically for this purpose.\n\n      The address of the EIC must be provided (if at all) when a new implementation is added to\n      a Proxy contract (as part of the initialization vector).\n      Hence, it is considered part of the code open to reviewers prior to a time-locked upgrade.\n\n      When a custom initialization is performed using an EIC,\n      the main dispatcher initialize extracts and stores the sub-contracts addresses, and then\n      yields to the EIC, skipping the rest of its initialization code.\n\n\n      Flow of MainDispatcher initialize\n      ---------------------------------\n      1. Extraction and assignment of subcontracts addresses\n         Main dispatcher expects a valid and consistent set of addresses in the passed data.\n         It validates that, extracts the addresses from the data, and validates that the addresses\n         are of the expected type and order. Then those addresses are stored.\n\n      2. Extraction of EIC address\n         The address of the EIC is extracted from the data.\n         External Initializer Contract is optional. ZERO_ADDRESS indicates it is not used.\n\n      3a. EIC is used\n          Dispatcher calls the EIC initialize function with the remaining data.\n          Note - In this option 3b is not performed.\n\n      3b. EIC is not used\n          If there is additional initialization data then:\n          I. Sentitenl function is called to permit subcontracts initialization.\n          II. Dispatcher loops through the subcontracts and for each one it extracts the\n              initializing data and passes it to the subcontract's initialize function.\n\n    */\n    function initialize(bytes calldata data) external virtual notCalledDirectly {\n        // Number of sub-contracts.\n        uint256 nSubContracts = getNumSubcontracts();\n\n        // We support currently 4 bits per contract, i.e. 16, reserving 00 leads to 15.\n        require(nSubContracts <= 15, \"TOO_MANY_SUB_CONTRACTS\");\n\n        // Sum of subcontract initializers. Aggregated for verification near the end.\n        uint256 totalInitSizes = 0;\n\n        // Offset (within data) of sub-contract initializer vector.\n        // Just past the sub-contract+eic addresses.\n        uint256 initDataContractsOffset = 32 * (nSubContracts + 1);\n\n        // Init data MUST include addresses for all sub-contracts + EIC.\n        require(data.length >= initDataContractsOffset, \"SUB_CONTRACTS_NOT_PROVIDED\");\n\n        // Size of passed data, excluding sub-contract addresses.\n        uint256 additionalDataSize = data.length - initDataContractsOffset;\n\n        // Extract & update contract addresses.\n        for (uint256 nContract = 1; nContract <= nSubContracts; nContract++) {\n            // Extract sub-contract address.\n            address contractAddress = abi.decode(\n                data[32 * (nContract - 1):32 * nContract],\n                (address)\n            );\n\n            validateSubContractIndex(nContract, contractAddress);\n\n            // Contracts are indexed from 1 and 0 is not in use here.\n            setSubContractAddress(nContract, contractAddress);\n        }\n\n        // Check if we have an external initializer contract.\n        address externalInitializerAddr = abi.decode(\n            data[initDataContractsOffset - 32:initDataContractsOffset],\n            (address)\n        );\n\n        // 3(a). Yield to EIC initialization.\n        if (externalInitializerAddr != address(0x0)) {\n            callExternalInitializer(externalInitializerAddr, data[initDataContractsOffset:]);\n            return;\n        }\n\n        // 3(b). Subcontracts initialization.\n        // I. If no init data passed besides sub-contracts, return.\n        if (additionalDataSize == 0) {\n            return;\n        }\n\n        // Just to be on the safe side.\n        assert(externalInitializerAddr == address(0x0));\n\n        // II. Gate further initialization.\n        initializationSentinel();\n\n        // III. Loops through the subcontracts, extracts their data and calls their initializer.\n        for (uint256 nContract = 1; nContract <= nSubContracts; nContract++) {\n            // Extract sub-contract address.\n            address contractAddress = abi.decode(\n                data[32 * (nContract - 1):32 * nContract],\n                (address)\n            );\n\n            // The initializerSize is called via delegatecall, so that it can relate to the state,\n            // and not only to the new contract code. (e.g. return 0 if state-intialized else 192).\n            // NOLINTNEXTLINE: controlled-delegatecall low-level-calls calls-loop.\n            (bool success, bytes memory returndata) = contractAddress.delegatecall(\n                abi.encodeWithSelector(SubContractor(contractAddress).initializerSize.selector)\n            );\n            require(success, string(returndata));\n            uint256 initSize = abi.decode(returndata, (uint256));\n            require(initSize <= additionalDataSize, \"INVALID_INITIALIZER_SIZE\");\n            require(totalInitSizes + initSize <= additionalDataSize, \"INVALID_INITIALIZER_SIZE\");\n\n            if (initSize == 0) {\n                continue;\n            }\n\n            // Call sub-contract initializer.\n            // NOLINTNEXTLINE: controlled-delegatecall calls-loop.\n            (success, returndata) = contractAddress.delegatecall(\n                abi.encodeWithSelector(\n                    this.initialize.selector,\n                    data[initDataContractsOffset:initDataContractsOffset + initSize]\n                )\n            );\n            require(success, string(returndata));\n            totalInitSizes += initSize;\n            initDataContractsOffset += initSize;\n        }\n        require(additionalDataSize == totalInitSizes, \"MISMATCHING_INIT_DATA_SIZE\");\n    }\n\n    function callExternalInitializer(address externalInitializerAddr, bytes calldata extInitData)\n        private\n    {\n        require(externalInitializerAddr.isContract(), \"NOT_A_CONTRACT\");\n\n        // NOLINTNEXTLINE: low-level-calls, controlled-delegatecall.\n        (bool success, bytes memory returndata) = externalInitializerAddr.delegatecall(\n            abi.encodeWithSelector(this.initialize.selector, extInitData)\n        );\n        require(success, string(returndata));\n        require(returndata.length == 0, string(returndata));\n    }\n}\n"
    },
    "repos/scalable-dex/contracts/src/components/MainStorage.sol": {
      "content": "/*\n  Copyright 2019-2024 StarkWare Industries Ltd.\n\n  Licensed under the Apache License, Version 2.0 (the \"License\").\n  You may not use this file except in compliance with the License.\n  You may obtain a copy of the License at\n\n  https://www.starkware.co/open-source-license/\n\n  Unless required by applicable law or agreed to in writing,\n  software distributed under the License is distributed on an \"AS IS\" BASIS,\n  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\n  See the License for the specific language governing permissions\n  and limitations under the License.\n*/\n// SPDX-License-Identifier: Apache-2.0.\npragma solidity ^0.6.12;\n\nimport \"../upgrade/ProxyStorage.sol\";\nimport \"../libraries/Common.sol\";\n\n/*\n  Holds ALL the main contract state (storage) variables.\n*/\ncontract MainStorage is ProxyStorage {\n    uint256 internal constant LAYOUT_LENGTH = 2**64;\n\n    address escapeVerifierAddress; // NOLINT: constable-states.\n\n    // Global dex-frozen flag.\n    bool stateFrozen; // NOLINT: constable-states.\n\n    // Time when unFreeze can be successfully called (UNFREEZE_DELAY after freeze).\n    uint256 unFreezeTime; // NOLINT: constable-states.\n\n    // Pending deposits.\n    // A map STARK key => asset id => vault id => quantized amount.\n    mapping(uint256 => mapping(uint256 => mapping(uint256 => uint256))) pendingDeposits;\n\n    // Cancellation requests.\n    // A map STARK key => asset id => vault id => request timestamp.\n    mapping(uint256 => mapping(uint256 => mapping(uint256 => uint256))) cancellationRequests;\n\n    // Pending withdrawals.\n    // A map STARK key => asset id => quantized amount.\n    mapping(uint256 => mapping(uint256 => uint256)) pendingWithdrawals;\n\n    // vault_id => escape used boolean.\n    mapping(uint256 => bool) escapesUsed;\n\n    // Number of escapes that were performed when frozen.\n    uint256 escapesUsedCount; // NOLINT: constable-states.\n\n    // NOTE: fullWithdrawalRequests is deprecated, and replaced by forcedActionRequests.\n    // NOLINTNEXTLINE naming-convention.\n    mapping(uint256 => mapping(uint256 => uint256)) fullWithdrawalRequests_DEPRECATED;\n\n    // State sequence number.\n    uint256 sequenceNumber; // NOLINT: constable-states uninitialized-state.\n\n    // Validium Vaults Tree Root & Height.\n    uint256 validiumVaultRoot; // NOLINT: constable-states uninitialized-state.\n    uint256 validiumTreeHeight; // NOLINT: constable-states uninitialized-state.\n\n    // Order Tree Root & Height.\n    uint256 orderRoot; // NOLINT: constable-states uninitialized-state.\n    uint256 orderTreeHeight; // NOLINT: constable-states uninitialized-state.\n\n    // True if and only if the address is allowed to add tokens.\n    mapping(address => bool) tokenAdmins;\n\n    // This mapping is no longer in use, remains for backwards compatibility.\n    mapping(address => bool) userAdmins_DEPRECATED; // NOLINT: naming-convention.\n\n    // True if and only if the address is an operator (allowed to update state).\n    mapping(address => bool) operators; // NOLINT: uninitialized-state.\n\n    // Mapping of contract ID to asset data.\n    mapping(uint256 => bytes) assetTypeToAssetInfo; // NOLINT: uninitialized-state.\n\n    // Mapping of registered contract IDs.\n    mapping(uint256 => bool) registeredAssetType; // NOLINT: uninitialized-state.\n\n    // Mapping from contract ID to quantum.\n    mapping(uint256 => uint256) assetTypeToQuantum; // NOLINT: uninitialized-state.\n\n    // This mapping is no longer in use, remains for backwards compatibility.\n    mapping(address => uint256) starkKeys_DEPRECATED; // NOLINT: naming-convention.\n\n    // Mapping from STARK public key to the Ethereum public key of its owner.\n    mapping(uint256 => address) ethKeys; // NOLINT: uninitialized-state.\n\n    // Timelocked state transition and availability verification chain.\n    StarkExTypes.ApprovalChainData verifiersChain;\n    StarkExTypes.ApprovalChainData availabilityVerifiersChain;\n\n    // Batch id of last accepted proof.\n    uint256 lastBatchId; // NOLINT: constable-states uninitialized-state.\n\n    // Mapping between sub-contract index to sub-contract address.\n    mapping(uint256 => address) subContracts; // NOLINT: uninitialized-state.\n\n    mapping(uint256 => bool) permissiveAssetType_DEPRECATED; // NOLINT: naming-convention.\n    // ---- END OF MAIN STORAGE AS DEPLOYED IN STARKEX2.0 ----\n\n    // Onchain-data version configured for the system.\n    uint256 onchainDataVersion_DEPRECATED; // NOLINT: naming-convention constable-states.\n\n    // Counter of forced action request in block. The key is the block number.\n    mapping(uint256 => uint256) forcedRequestsInBlock;\n\n    // ForcedAction requests: actionHash => requestTime.\n    mapping(bytes32 => uint256) forcedActionRequests;\n\n    // Mapping for timelocked actions.\n    // A actionKey => activation time.\n    mapping(bytes32 => uint256) actionsTimeLock;\n\n    // Append only list of requested forced action hashes.\n    bytes32[] actionHashList;\n    // ---- END OF MAIN STORAGE AS DEPLOYED IN STARKEX3.0 ----\n    // ---- END OF MAIN STORAGE AS DEPLOYED IN STARKEX4.0 ----\n\n    // Rollup Vaults Tree Root & Height.\n    uint256 rollupVaultRoot; // NOLINT: constable-states uninitialized-state.\n    uint256 rollupTreeHeight; // NOLINT: constable-states uninitialized-state.\n\n    uint256 globalConfigCode; // NOLINT: constable-states uninitialized-state.\n\n    // Mapping of owner keys that are blocked from withdrawals.\n    mapping(uint256 => bool) internal blockListed;\n\n    // Reserved storage space for Extensibility.\n    // Every added MUST be added above the end gap, and the __endGap size must be reduced\n    // accordingly.\n    // NOLINTNEXTLINE: naming-convention.\n    uint256[LAYOUT_LENGTH - 41] private __endGap; // __endGap complements layout to LAYOUT_LENGTH.\n}\n"
    },
    "repos/scalable-dex/contracts/src/upgrade/ProxyStorage.sol": {
      "content": "/*\n  Copyright 2019-2024 StarkWare Industries Ltd.\n\n  Licensed under the Apache License, Version 2.0 (the \"License\").\n  You may not use this file except in compliance with the License.\n  You may obtain a copy of the License at\n\n  https://www.starkware.co/open-source-license/\n\n  Unless required by applicable law or agreed to in writing,\n  software distributed under the License is distributed on an \"AS IS\" BASIS,\n  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\n  See the License for the specific language governing permissions\n  and limitations under the License.\n*/\n// SPDX-License-Identifier: Apache-2.0.\npragma solidity ^0.6.12;\n\nimport \"../components/GovernanceStorage.sol\";\n\n/*\n  Holds the Proxy-specific state variables.\n  This contract is inherited by the GovernanceStorage (and indirectly by MainStorage)\n  to prevent collision hazard.\n*/\ncontract ProxyStorage is GovernanceStorage {\n    // NOLINTNEXTLINE: naming-convention uninitialized-state.\n    mapping(address => bytes32) internal initializationHash_DEPRECATED;\n\n    // The time after which we can switch to the implementation.\n    // Hash(implementation, data, finalize) => time.\n    mapping(bytes32 => uint256) internal enabledTime;\n\n    // A central storage of the flags whether implementation has been initialized.\n    // Note - it can be used flexibly enough to accommodate multiple levels of initialization\n    // (i.e. using different key salting schemes for different initialization levels).\n    mapping(bytes32 => bool) internal initialized;\n}\n"
    },
    "repos/scalable-dex/contracts/src/starkex/StarkExchange.sol": {
      "content": "/*\n  Copyright 2019-2024 StarkWare Industries Ltd.\n\n  Licensed under the Apache License, Version 2.0 (the \"License\").\n  You may not use this file except in compliance with the License.\n  You may obtain a copy of the License at\n\n  https://www.starkware.co/open-source-license/\n\n  Unless required by applicable law or agreed to in writing,\n  software distributed under the License is distributed on an \"AS IS\" BASIS,\n  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\n  See the License for the specific language governing permissions\n  and limitations under the License.\n*/\n// SPDX-License-Identifier: Apache-2.0.\npragma solidity ^0.6.12;\n\nimport \"../interfaces/MainDispatcher.sol\";\n\ncontract StarkExchange is MainDispatcher {\n    string public constant VERSION = \"4.5.2-bl\";\n\n    // Salt for a 8 bit unique spread of all relevant selectors. Pre-caclulated.\n    // ---------- The following code was auto-generated. PLEASE DO NOT EDIT. ----------\n    uint256 constant MAGIC_SALT = 3548735;\n    uint256 constant IDX_MAP_0 = 0x2002000001052120022000230001320000120003000005400010002000000225;\n    uint256 constant IDX_MAP_1 = 0x5303000002002010520200113001010101000000000130050030000020021050;\n    uint256 constant IDX_MAP_2 = 0x2100221120103200050010000000050000002006022030052200200020020003;\n    uint256 constant IDX_MAP_3 = 0x210003200050000000103520000201500240120000002000200300430020004;\n\n    // ---------- End of auto-generated code. ----------\n\n    function getNumSubcontracts() internal pure override returns (uint256) {\n        return 6;\n    }\n\n    function magicSalt() internal pure override returns (uint256) {\n        return MAGIC_SALT;\n    }\n\n    function handlerMapSection(uint256 section) internal pure override returns (uint256) {\n        if (section == 0) {\n            return IDX_MAP_0;\n        } else if (section == 1) {\n            return IDX_MAP_1;\n        } else if (section == 2) {\n            return IDX_MAP_2;\n        } else if (section == 3) {\n            return IDX_MAP_3;\n        }\n        revert(\"BAD_IDX_MAP_SECTION\");\n    }\n\n    function expectedIdByIndex(uint256 index) internal pure override returns (string memory id) {\n        if (index == 1) {\n            id = \"StarkWare_AllVerifiers_2022_2\";\n        } else if (index == 2) {\n            id = \"StarkWare_TokensAndRamping_2024_3\";\n        } else if (index == 3) {\n            id = \"StarkWare_StarkExState_2022_5\";\n        } else if (index == 4) {\n            id = \"StarkWare_ForcedActions_2022_3\";\n        } else if (index == 5) {\n            id = \"StarkWare_OnchainVaults_2022_2\";\n        } else if (index == 6) {\n            id = \"StarkWare_ProxyUtils_2022_2\";\n        } else {\n            revert(\"UNEXPECTED_INDEX\");\n        }\n    }\n\n    function initializationSentinel() internal view override {\n        string memory REVERT_MSG = \"INITIALIZATION_BLOCKED\";\n        // This initializer sets roots etc. It must not be applied twice.\n        // I.e. it can run only when the state is still empty.\n        require(validiumVaultRoot == 0, REVERT_MSG);\n        require(validiumTreeHeight == 0, REVERT_MSG);\n        require(rollupVaultRoot == 0, REVERT_MSG);\n        require(rollupTreeHeight == 0, REVERT_MSG);\n        require(orderRoot == 0, REVERT_MSG);\n        require(orderTreeHeight == 0, REVERT_MSG);\n    }\n}\n"
    },
    "repos/scalable-dex/contracts/src/interfaces/SubContractor.sol": {
      "content": "/*\n  Copyright 2019-2024 StarkWare Industries Ltd.\n\n  Licensed under the Apache License, Version 2.0 (the \"License\").\n  You may not use this file except in compliance with the License.\n  You may obtain a copy of the License at\n\n  https://www.starkware.co/open-source-license/\n\n  Unless required by applicable law or agreed to in writing,\n  software distributed under the License is distributed on an \"AS IS\" BASIS,\n  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\n  See the License for the specific language governing permissions\n  and limitations under the License.\n*/\n// SPDX-License-Identifier: Apache-2.0.\npragma solidity ^0.6.12;\n\nimport \"./Identity.sol\";\n\ninterface SubContractor is Identity {\n    function initialize(bytes calldata data) external;\n\n    function initializerSize() external view returns (uint256);\n\n    /*\n      Returns an array with selectors for validation.\n      These selectors are the critical ones for maintaining self custody and anti censorship.\n      During the upgrade process, as part of the sub-contract validation, the MainDispatcher\n      validates that the selectos are mapped to the correct sub-contract.\n    */\n    function validatedSelectors() external pure returns (bytes4[] memory);\n}\n"
    }
  },
  "settings": {
    "metadata": {
      "useLiteralContent": true
    },
    "libraries": {},
    "remappings": [],
    "optimizer": {
      "enabled": true,
      "runs": 100
    },
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
  }
}}