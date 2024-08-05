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
    "contracts/BN254.sol": {
      "content": "// SPDX-License-Identifier: MIT\n// several functions are taken or adapted from https://github.com/HarryR/solcrypto/blob/master/contracts/altbn128.sol (MIT license):\n// Copyright 2017 Christian Reitwiessner\n// Permission is hereby granted, free of charge, to any person obtaining a copy\n// of this software and associated documentation files (the \"Software\"), to\n// deal in the Software without restriction, including without limitation the\n// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or\n// sell copies of the Software, and to permit persons to whom the Software is\n// furnished to do so, subject to the following conditions:\n// The above copyright notice and this permission notice shall be included in\n// all copies or substantial portions of the Software.\n// THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR\n// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,\n// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE\n// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER\n// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING\n// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS\n// IN THE SOFTWARE.\n\n// The remainder of the code in this library is written by LayrLabs Inc. and is also under an MIT license\n\npragma solidity =0.8.12;\n\n/**\n * @title Library for operations on the BN254 elliptic curve.\n * @author Layr Labs, Inc.\n * @notice Terms of Service: https://docs.eigenlayer.xyz/overview/terms-of-service\n * @notice Contains BN254 parameters, common operations (addition, scalar mul, pairing), and BLS signature functionality.\n */\nlibrary BN254 {\n    // modulus for the underlying field F_p of the elliptic curve\n    uint256 internal constant FP_MODULUS = 21888242871839275222246405745257275088696311157297823662689037894645226208583;\n    // modulus for the underlying field F_r of the elliptic curve\n    uint256 internal constant FR_MODULUS = 21888242871839275222246405745257275088548364400416034343698204186575808495617;\n\n    struct G1Point {\n        uint256 X;\n        uint256 Y;\n    }\n\n    // Encoding of field elements is: X[1] * i + X[0]\n    struct G2Point {\n        uint256[2] X;\n        uint256[2] Y;\n    }\n\n    function generatorG1() internal pure returns (G1Point memory) {\n        return G1Point(1, 2);\n    }\n\n    // generator of group G2\n    /// @dev Generator point in F_q2 is of the form: (x0 + ix1, y0 + iy1).\n    uint256 internal constant G2x1 = 11559732032986387107991004021392285783925812861821192530917403151452391805634;\n    uint256 internal constant G2x0 = 10857046999023057135944570762232829481370756359578518086990519993285655852781;\n    uint256 internal constant G2y1 = 4082367875863433681332203403145435568316851327593401208105741076214120093531;\n    uint256 internal constant G2y0 = 8495653923123431417604973247489272438418190587263600148770280649306958101930;\n\n    /// @notice returns the G2 generator\n    /// @dev mind the ordering of the 1s and 0s!\n    ///      this is because of the (unknown to us) convention used in the bn254 pairing precompile contract\n    ///      \"Elements a * i + b of F_p^2 are encoded as two elements of F_p, (a, b).\"\n    ///      https://github.com/ethereum/EIPs/blob/master/EIPS/eip-197.md#encoding\n    function generatorG2() internal pure returns (G2Point memory) {\n        return G2Point([G2x1, G2x0], [G2y1, G2y0]);\n    }\n\n    // negation of the generator of group G2\n    /// @dev Generator point in F_q2 is of the form: (x0 + ix1, y0 + iy1).\n    uint256 internal constant nG2x1 = 11559732032986387107991004021392285783925812861821192530917403151452391805634;\n    uint256 internal constant nG2x0 = 10857046999023057135944570762232829481370756359578518086990519993285655852781;\n    uint256 internal constant nG2y1 = 17805874995975841540914202342111839520379459829704422454583296818431106115052;\n    uint256 internal constant nG2y0 = 13392588948715843804641432497768002650278120570034223513918757245338268106653;\n\n    function negGeneratorG2() internal pure returns (G2Point memory) {\n        return G2Point([nG2x1, nG2x0], [nG2y1, nG2y0]);\n    }\n\n    bytes32 internal constant powersOfTauMerkleRoot = 0x22c998e49752bbb1918ba87d6d59dd0e83620a311ba91dd4b2cc84990b31b56f;\n\n    /**\n     * @param p Some point in G1.\n     * @return The negation of `p`, i.e. p.plus(p.negate()) should be zero.\n     */\n    function negate(G1Point memory p) internal pure returns (G1Point memory) {\n        // The prime q in the base field F_q for G1\n        if (p.X == 0 && p.Y == 0) {\n            return G1Point(0, 0);\n        } else {\n            return G1Point(p.X, FP_MODULUS - (p.Y % FP_MODULUS));\n        }\n    }\n\n    /**\n     * @return r the sum of two points of G1\n     */\n    function plus(G1Point memory p1, G1Point memory p2) internal view returns (G1Point memory r) {\n        uint256[4] memory input;\n        input[0] = p1.X;\n        input[1] = p1.Y;\n        input[2] = p2.X;\n        input[3] = p2.Y;\n        bool success;\n\n        // solium-disable-next-line security/no-inline-assembly\n        assembly {\n            success := staticcall(sub(gas(), 2000), 6, input, 0x80, r, 0x40)\n            // Use \"invalid\" to make gas estimation work\n            switch success\n            case 0 { invalid() }\n        }\n\n        require(success, \"ec-add-failed\");\n    }\n\n    /**\n     * @notice an optimized ecMul implementation that takes O(log_2(s)) ecAdds\n     * @param p the point to multiply\n     * @param s the scalar to multiply by\n     * @dev this function is only safe to use if the scalar is 9 bits or less\n     */\n    function scalar_mul_tiny(BN254.G1Point memory p, uint16 s) internal view returns (BN254.G1Point memory) {\n        require(s < 2 ** 9, \"scalar-too-large\");\n\n        // if s is 1 return p\n        if (s == 1) {\n            return p;\n        }\n\n        // the accumulated product to return\n        BN254.G1Point memory acc = BN254.G1Point(0, 0);\n        // the 2^n*p to add to the accumulated product in each iteration\n        BN254.G1Point memory p2n = p;\n        // value of most significant bit\n        uint16 m = 1;\n        // index of most significant bit\n        uint8 i = 0;\n\n        //loop until we reach the most significant bit\n        while (s >= m) {\n            unchecked {\n                // if the  current bit is 1, add the 2^n*p to the accumulated product\n                if ((s >> i) & 1 == 1) {\n                    acc = plus(acc, p2n);\n                }\n                // double the 2^n*p for the next iteration\n                p2n = plus(p2n, p2n);\n\n                // increment the index and double the value of the most significant bit\n                m <<= 1;\n                ++i;\n            }\n        }\n\n        // return the accumulated product\n        return acc;\n    }\n\n    /**\n     * @return r the product of a point on G1 and a scalar, i.e.\n     *         p == p.scalar_mul(1) and p.plus(p) == p.scalar_mul(2) for all\n     *         points p.\n     */\n    function scalar_mul(G1Point memory p, uint256 s) internal view returns (G1Point memory r) {\n        uint256[3] memory input;\n        input[0] = p.X;\n        input[1] = p.Y;\n        input[2] = s;\n        bool success;\n        // solium-disable-next-line security/no-inline-assembly\n        assembly {\n            success := staticcall(sub(gas(), 2000), 7, input, 0x60, r, 0x40)\n            // Use \"invalid\" to make gas estimation work\n            switch success\n            case 0 { invalid() }\n        }\n        require(success, \"ec-mul-failed\");\n    }\n\n    /**\n     *  @return The result of computing the pairing check\n     *         e(p1[0], p2[0]) *  .... * e(p1[n], p2[n]) == 1\n     *         For example,\n     *         pairing([P1(), P1().negate()], [P2(), P2()]) should return true.\n     */\n    function pairing(G1Point memory a1, G2Point memory a2, G1Point memory b1, G2Point memory b2)\n        internal\n        view\n        returns (bool)\n    {\n        G1Point[2] memory p1 = [a1, b1];\n        G2Point[2] memory p2 = [a2, b2];\n\n        uint256[12] memory input;\n\n        for (uint256 i = 0; i < 2; i++) {\n            uint256 j = i * 6;\n            input[j + 0] = p1[i].X;\n            input[j + 1] = p1[i].Y;\n            input[j + 2] = p2[i].X[0];\n            input[j + 3] = p2[i].X[1];\n            input[j + 4] = p2[i].Y[0];\n            input[j + 5] = p2[i].Y[1];\n        }\n\n        uint256[1] memory out;\n        bool success;\n\n        // solium-disable-next-line security/no-inline-assembly\n        assembly {\n            success := staticcall(sub(gas(), 2000), 8, input, mul(12, 0x20), out, 0x20)\n            // Use \"invalid\" to make gas estimation work\n            switch success\n            case 0 { invalid() }\n        }\n\n        require(success, \"pairing-opcode-failed\");\n\n        return out[0] != 0;\n    }\n\n    /**\n     * @notice This function is functionally the same as pairing(), however it specifies a gas limit\n     *         the user can set, as a precompile may use the entire gas budget if it reverts.\n     */\n    function safePairing(G1Point memory a1, G2Point memory a2, G1Point memory b1, G2Point memory b2, uint256 pairingGas)\n        internal\n        view\n        returns (bool, bool)\n    {\n        G1Point[2] memory p1 = [a1, b1];\n        G2Point[2] memory p2 = [a2, b2];\n\n        uint256[12] memory input;\n\n        for (uint256 i = 0; i < 2; i++) {\n            uint256 j = i * 6;\n            input[j + 0] = p1[i].X;\n            input[j + 1] = p1[i].Y;\n            input[j + 2] = p2[i].X[0];\n            input[j + 3] = p2[i].X[1];\n            input[j + 4] = p2[i].Y[0];\n            input[j + 5] = p2[i].Y[1];\n        }\n\n        uint256[1] memory out;\n        bool success;\n\n        // solium-disable-next-line security/no-inline-assembly\n        assembly {\n            success := staticcall(pairingGas, 8, input, mul(12, 0x20), out, 0x20)\n        }\n\n        //Out is the output of the pairing precompile, either 0 or 1 based on whether the two pairings are equal.\n        //Success is true if the precompile actually goes through (aka all inputs are valid)\n\n        return (success, out[0] != 0);\n    }\n\n    /// @return hashedG1 the keccak256 hash of the G1 Point\n    /// @dev used for BLS signatures\n    function hashG1Point(BN254.G1Point memory pk) internal pure returns (bytes32 hashedG1) {\n        assembly {\n            mstore(0, mload(pk))\n            mstore(0x20, mload(add(0x20, pk)))\n            hashedG1 := keccak256(0, 0x40)\n        }\n    }\n\n    /// @return the keccak256 hash of the G2 Point\n    /// @dev used for BLS signatures\n    function hashG2Point(BN254.G2Point memory pk) internal pure returns (bytes32) {\n        return keccak256(abi.encodePacked(pk.X[0], pk.X[1], pk.Y[0], pk.Y[1]));\n    }\n\n    /**\n     * @notice adapted from https://github.com/HarryR/solcrypto/blob/master/contracts/altbn128.sol\n     */\n    function hashToG1(bytes32 _x) internal view returns (G1Point memory) {\n        uint256 beta = 0;\n        uint256 y = 0;\n\n        uint256 x = uint256(_x) % FP_MODULUS;\n\n        while (true) {\n            (beta, y) = findYFromX(x);\n\n            // y^2 == beta\n            if (beta == mulmod(y, y, FP_MODULUS)) {\n                return G1Point(x, y);\n            }\n\n            x = addmod(x, 1, FP_MODULUS);\n        }\n        return G1Point(0, 0);\n    }\n\n    /**\n     * Given X, find Y\n     *\n     *   where y = sqrt(x^3 + b)\n     *\n     * Returns: (x^3 + b), y\n     */\n    function findYFromX(uint256 x) internal view returns (uint256, uint256) {\n        // beta = (x^3 + b) % p\n        uint256 beta = addmod(mulmod(mulmod(x, x, FP_MODULUS), x, FP_MODULUS), 3, FP_MODULUS);\n\n        // y^2 = x^3 + b\n        // this acts like: y = sqrt(beta) = beta^((p+1) / 4)\n        uint256 y = expMod(beta, 0xc19139cb84c680a6e14116da060561765e05aa45a1c72a34f082305b61f3f52, FP_MODULUS);\n\n        return (beta, y);\n    }\n\n    function expMod(uint256 _base, uint256 _exponent, uint256 _modulus) internal view returns (uint256 retval) {\n        bool success;\n        uint256[1] memory output;\n        uint256[6] memory input;\n        input[0] = 0x20; // baseLen = new(big.Int).SetBytes(getData(input, 0, 32))\n        input[1] = 0x20; // expLen  = new(big.Int).SetBytes(getData(input, 32, 32))\n        input[2] = 0x20; // modLen  = new(big.Int).SetBytes(getData(input, 64, 32))\n        input[3] = _base;\n        input[4] = _exponent;\n        input[5] = _modulus;\n        assembly {\n            success := staticcall(sub(gas(), 2000), 5, input, 0xc0, output, 0x20)\n            // Use \"invalid\" to make gas estimation work\n            switch success\n            case 0 { invalid() }\n        }\n        require(success, \"BN254.expMod: call failure\");\n        return output[0];\n    }\n}\n"
    },
    "contracts/eigendaoperatoridentifier.sol": {
      "content": "// SPDX-License-Identifier: MIT\npragma solidity 0.8.12;\n\nimport {BN254} from \"./BN254.sol\";\n// EigenYields 2024. https://eigenyields.xyz\n// This contract takes an EigenLayer operators pubkey and returns the operatorId and address of the operator.\n// Used to identity unsigned batches.\n\ninterface RegistryCoordinator {\n    function getOperatorFromId(bytes32 operatorId) external view returns (address);\n}\n\ncontract EigenDAOperatorIdentifier {\n    using BN254 for BN254.G1Point;\n\n    constructor() {\n        registry = RegistryCoordinator(opRegistry);\n    }\n\n    address public constant opRegistry = 0x0BAAc79acD45A023E19345c352d8a7a83C4e5656;\n\n    RegistryCoordinator public registry;\n\n    function pubKeyToHash(BN254.G1Point calldata Key) public pure returns (bytes32 operatorId) {\n        operatorId = BN254.hashG1Point(Key);\n    }\n\n    function IdToAddress(bytes32 operatorId) public view returns (address operatorAddress) {\n        return registry.getOperatorFromId(operatorId);\n    }\n\n    function getOperator(BN254.G1Point calldata Key) public view returns (address operatorAddress) {\n        return IdToAddress(pubKeyToHash(Key));\n    }\n}\n"
    }
  }
}}