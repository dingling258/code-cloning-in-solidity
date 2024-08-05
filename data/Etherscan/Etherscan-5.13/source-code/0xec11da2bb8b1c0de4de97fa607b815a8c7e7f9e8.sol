{{
  "language": "Solidity",
  "sources": {
    "contracts/feeCollect.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity ^0.8.0;\n\nimport \"@openzeppelin/contracts/utils/cryptography/ECDSA.sol\";\n\n\ninterface IERC20 {\n    function balanceOf(address account) external view returns (uint256);\n    function transfer(address to, uint256 amount) external returns (bool);\n}\n\ncontract FeeCollect {\n    using ECDSA for bytes32;\n\n    address public alice;\n    address public bob;\n    address public feeSigner;\n\n    uint256 public currIndex;\n\n    bool public status;\n\n    mapping (bytes => uint256) public claimed;\n\n    struct EIP712Domain {\n        string  name;\n        string  version;\n        uint256 chainId;\n        address verifyingContract;\n    }\n    \n\n    struct Claim {\n        address account;\n        uint256 amount;\n        uint256 index;\n        bytes sign;\n    }\n    \n    bytes32 constant EIP712DOMAIN_TYPEHASH = 0x8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f;\n    bytes32 constant CLAIM_TYPEHASH = 0x605e3732079ecbae80f59d8b4bc8974bca6694cf40f83bc393b51679a388913b;\n    bytes32 private DOMAIN_SEPARATOR;\n\n    event eveClaimCommissionFee(address indexed account,uint256 amount,uint256 index);\n\n\n    modifier onlyPartner() {\n        require(msg.sender == alice || msg.sender == bob, \"401\");\n        _;\n    }\n\n    receive() external payable {\n       \n    }\n     \n    constructor(address alice_, address bob_,address feeSigner_) {\n        alice = alice_;\n        bob = bob_;\n        feeSigner = feeSigner_;\n\n        status = true;\n\n        DOMAIN_SEPARATOR = hash(EIP712Domain({\n            name: \"FeeCollect\",\n            version: '1.0.0',\n            chainId: block.chainid,\n            verifyingContract: address(this)\n        }));\n    }\n    function hash(EIP712Domain memory eip712Domain) internal pure returns (bytes32) {\n        return keccak256(\n        abi.encode(\n            EIP712DOMAIN_TYPEHASH,\n            keccak256(bytes(eip712Domain.name)),\n            keccak256(bytes(eip712Domain.version)),\n            eip712Domain.chainId,\n            eip712Domain.verifyingContract\n        ));\n    }\n\n    function hash(Claim memory param) private pure returns (bytes32) {\n        return keccak256(abi.encode(\n            CLAIM_TYPEHASH,\n            param.account,\n            param.amount,\n            param.index\n        ));\n    }\n//1 Err: status is not available\n//2 Err: already claimed\n//3 Err: owner is not available\n//4 Err: sign invalid\n//5 Err: amount invalid\n\n    function claimCommissionFee(Claim memory param) external  {\n        require(\n            status,\n            \"1\"\n        );\n       \n        require(\n            claimed[param.sign] ==0,\n            \"2\"\n        );\n\n        require(\n            param.account == msg.sender,\n            \"3\"\n        );\n       \n        bytes32 digest = keccak256(abi.encodePacked(\n                \"\\x19\\x01\",\n                DOMAIN_SEPARATOR,\n                hash(param)\n        ));\n        require(\n            digest.recover(param.sign) == feeSigner,\n            \"4\"\n        );\n\n        uint256 totalBalance = address(this).balance;\n\n        require(\n            param.amount <= totalBalance,\n            \"5\"\n        );\n\n        claimed[param.sign] = param.amount;\n        payable(msg.sender).transfer(param.amount);\n\n        emit eveClaimCommissionFee(msg.sender,param.amount,param.index);\n    }\n //11 index not available\n //12 invalid signatures\n //13 amount not available  \n    function withdrawFee(uint256 index,address target, uint256 amount, bytes memory signAlice, bytes memory signBob) external  onlyPartner {\n        require(index == currIndex, \"11\");\n        require(verifyWithdrawFee(alice, bob, index,target,amount, signAlice, signBob), \"12\");\n        uint256 totalBalance;\n        if (target == address(0)) {\n            totalBalance = address(this).balance;\n        }else{\n            totalBalance = IERC20(target).balanceOf(address(this));\n        }       \n        require(amount <= totalBalance, \"13\");\n        uint256 perAmount = amount / 2;\n        if (target == address(0)) {\n            payable(alice).transfer(perAmount);\n            payable(bob).transfer(perAmount);\n        }else{\n            IERC20(target).transfer(alice,perAmount);\n            IERC20(target).transfer(bob,perAmount);\n        }\n       \n        currIndex++;\n    }\n//21 index not available\n//22 address not available\n//23 invalid signatures\n    function changePartner(uint256 index,address newAlice, address newBob, bytes memory signAlice, bytes memory signBob) external onlyPartner {\n        require(index == currIndex, \"21\");\n        require(newAlice != address(0) && newBob != address(0) && newAlice != newBob, \"22\");\n        require(verifyChangePartner(alice, bob, index,newAlice,newBob, signAlice, signBob), \"23\");\n        alice = newAlice;\n        bob = newBob;\n        currIndex++;\n    }\n\n\n    function verifyWithdrawFee(address signerAlice, address signerBob, \n        uint256 index,address target,uint256 amount, \n        bytes memory sigAlice, bytes memory sigBob)\n    internal pure returns (bool) {\n        bytes32 message = keccak256(abi.encodePacked(signerAlice,signerBob,index,target,amount));\n        return (message.recover(sigAlice) == signerAlice && message.recover(sigBob) == signerBob);\n    }\n\n    function verifyChangePartner(address signerAlice, address signerBob, \n        uint256 index,address newAlice,address newBob, \n        bytes memory sigAlice, bytes memory sigBob)\n    internal pure returns (bool) {\n        bytes32 message = keccak256(abi.encodePacked(signerAlice,signerBob,index,newAlice,newBob));\n        return (message.recover(sigAlice) == signerAlice && message.recover(sigBob) == signerBob);\n    }\n\n    function setSigner(address signer_) public onlyPartner  {\n        feeSigner = signer_;\n    }\n\n    function setStatus(bool status_) public onlyPartner  {\n        status = status_;\n    }\n}"
    },
    "@openzeppelin/contracts/utils/cryptography/ECDSA.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// OpenZeppelin Contracts (last updated v5.0.0) (utils/cryptography/ECDSA.sol)\n\npragma solidity ^0.8.20;\n\n/**\n * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.\n *\n * These functions can be used to verify that a message was signed by the holder\n * of the private keys of a given address.\n */\nlibrary ECDSA {\n    enum RecoverError {\n        NoError,\n        InvalidSignature,\n        InvalidSignatureLength,\n        InvalidSignatureS\n    }\n\n    /**\n     * @dev The signature derives the `address(0)`.\n     */\n    error ECDSAInvalidSignature();\n\n    /**\n     * @dev The signature has an invalid length.\n     */\n    error ECDSAInvalidSignatureLength(uint256 length);\n\n    /**\n     * @dev The signature has an S value that is in the upper half order.\n     */\n    error ECDSAInvalidSignatureS(bytes32 s);\n\n    /**\n     * @dev Returns the address that signed a hashed message (`hash`) with `signature` or an error. This will not\n     * return address(0) without also returning an error description. Errors are documented using an enum (error type)\n     * and a bytes32 providing additional information about the error.\n     *\n     * If no error is returned, then the address can be used for verification purposes.\n     *\n     * The `ecrecover` EVM precompile allows for malleable (non-unique) signatures:\n     * this function rejects them by requiring the `s` value to be in the lower\n     * half order, and the `v` value to be either 27 or 28.\n     *\n     * IMPORTANT: `hash` _must_ be the result of a hash operation for the\n     * verification to be secure: it is possible to craft signatures that\n     * recover to arbitrary addresses for non-hashed data. A safe way to ensure\n     * this is by receiving a hash of the original message (which may otherwise\n     * be too long), and then calling {MessageHashUtils-toEthSignedMessageHash} on it.\n     *\n     * Documentation for signature generation:\n     * - with https://web3js.readthedocs.io/en/v1.3.4/web3-eth-accounts.html#sign[Web3.js]\n     * - with https://docs.ethers.io/v5/api/signer/#Signer-signMessage[ethers]\n     */\n    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError, bytes32) {\n        if (signature.length == 65) {\n            bytes32 r;\n            bytes32 s;\n            uint8 v;\n            // ecrecover takes the signature parameters, and the only way to get them\n            // currently is to use assembly.\n            /// @solidity memory-safe-assembly\n            assembly {\n                r := mload(add(signature, 0x20))\n                s := mload(add(signature, 0x40))\n                v := byte(0, mload(add(signature, 0x60)))\n            }\n            return tryRecover(hash, v, r, s);\n        } else {\n            return (address(0), RecoverError.InvalidSignatureLength, bytes32(signature.length));\n        }\n    }\n\n    /**\n     * @dev Returns the address that signed a hashed message (`hash`) with\n     * `signature`. This address can then be used for verification purposes.\n     *\n     * The `ecrecover` EVM precompile allows for malleable (non-unique) signatures:\n     * this function rejects them by requiring the `s` value to be in the lower\n     * half order, and the `v` value to be either 27 or 28.\n     *\n     * IMPORTANT: `hash` _must_ be the result of a hash operation for the\n     * verification to be secure: it is possible to craft signatures that\n     * recover to arbitrary addresses for non-hashed data. A safe way to ensure\n     * this is by receiving a hash of the original message (which may otherwise\n     * be too long), and then calling {MessageHashUtils-toEthSignedMessageHash} on it.\n     */\n    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {\n        (address recovered, RecoverError error, bytes32 errorArg) = tryRecover(hash, signature);\n        _throwError(error, errorArg);\n        return recovered;\n    }\n\n    /**\n     * @dev Overload of {ECDSA-tryRecover} that receives the `r` and `vs` short-signature fields separately.\n     *\n     * See https://eips.ethereum.org/EIPS/eip-2098[EIP-2098 short signatures]\n     */\n    function tryRecover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address, RecoverError, bytes32) {\n        unchecked {\n            bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);\n            // We do not check for an overflow here since the shift operation results in 0 or 1.\n            uint8 v = uint8((uint256(vs) >> 255) + 27);\n            return tryRecover(hash, v, r, s);\n        }\n    }\n\n    /**\n     * @dev Overload of {ECDSA-recover} that receives the `r and `vs` short-signature fields separately.\n     */\n    function recover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address) {\n        (address recovered, RecoverError error, bytes32 errorArg) = tryRecover(hash, r, vs);\n        _throwError(error, errorArg);\n        return recovered;\n    }\n\n    /**\n     * @dev Overload of {ECDSA-tryRecover} that receives the `v`,\n     * `r` and `s` signature fields separately.\n     */\n    function tryRecover(\n        bytes32 hash,\n        uint8 v,\n        bytes32 r,\n        bytes32 s\n    ) internal pure returns (address, RecoverError, bytes32) {\n        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature\n        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines\n        // the valid range for s in (301): 0 < s < secp256k1n ÷ 2 + 1, and for v in (302): v ∈ {27, 28}. Most\n        // signatures from current libraries generate a unique signature with an s-value in the lower half order.\n        //\n        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value\n        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or\n        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept\n        // these malleable signatures as well.\n        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {\n            return (address(0), RecoverError.InvalidSignatureS, s);\n        }\n\n        // If the signature is valid (and not malleable), return the signer address\n        address signer = ecrecover(hash, v, r, s);\n        if (signer == address(0)) {\n            return (address(0), RecoverError.InvalidSignature, bytes32(0));\n        }\n\n        return (signer, RecoverError.NoError, bytes32(0));\n    }\n\n    /**\n     * @dev Overload of {ECDSA-recover} that receives the `v`,\n     * `r` and `s` signature fields separately.\n     */\n    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {\n        (address recovered, RecoverError error, bytes32 errorArg) = tryRecover(hash, v, r, s);\n        _throwError(error, errorArg);\n        return recovered;\n    }\n\n    /**\n     * @dev Optionally reverts with the corresponding custom error according to the `error` argument provided.\n     */\n    function _throwError(RecoverError error, bytes32 errorArg) private pure {\n        if (error == RecoverError.NoError) {\n            return; // no error: do nothing\n        } else if (error == RecoverError.InvalidSignature) {\n            revert ECDSAInvalidSignature();\n        } else if (error == RecoverError.InvalidSignatureLength) {\n            revert ECDSAInvalidSignatureLength(uint256(errorArg));\n        } else if (error == RecoverError.InvalidSignatureS) {\n            revert ECDSAInvalidSignatureS(errorArg);\n        }\n    }\n}\n"
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