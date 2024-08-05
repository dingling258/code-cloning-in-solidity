{{
  "language": "Solidity",
  "settings": {
    "evmVersion": "paris",
    "libraries": {},
    "metadata": {
      "bytecodeHash": "none",
      "useLiteralContent": true
    },
    "optimizer": {
      "enabled": true,
      "runs": 800
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
    "contracts/primitive/boolean_verifier.sol": {
      "content": "\n// SPDX-License-Identifier: GPL-3.0\n/*\n    Copyright (c) 2021 0KIMS association.\n    Copyright (c) [2024] Galxe.com.\n\n    Modifications to this file are part of the Galxe Identity Protocol SDK,\n    which is built using the snarkJS template and is subject to the GNU\n    General Public License v3.0.\n\n    snarkJS is free software: you can redistribute it and/or modify it\n    under the terms of the GNU General Public License as published by\n    the Free Software Foundation, either version 3 of the License, or\n    (at your option) any later version.\n\n    This program is distributed in the hope that it will be useful,\n    but WITHOUT ANY WARRANTY; without even the implied warranty of\n    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\n    GNU General Public License for more details.\n\n    You should have received a copy of the GNU General Public License\n    along with this program. If not, see <https://www.gnu.org/licenses/>.\n*/\n\npragma solidity >=0.8.4 <0.9.0;\n\ncontract BabyZKGroth16BooleanVerifier {\n    error AliasedPublicSignal();\n\n    // Scalar field size\n    uint256 constant r   = 21888242871839275222246405745257275088548364400416034343698204186575808495617;\n    // Base field size\n    uint256 constant q   = 21888242871839275222246405745257275088696311157297823662689037894645226208583;\n\n    // Verification Key data\n    uint256 constant alphax  = 20491192805390485299153009773594534940189261866228447918068658471970481763042;\n    uint256 constant alphay  = 9383485363053290200918347156157836566562967994039712273449902621266178545958;\n    uint256 constant betax1  = 4252822878758300859123897981450591353533073413197771768651442665752259397132;\n    uint256 constant betax2  = 6375614351688725206403948262868962793625744043794305715222011528459656738731;\n    uint256 constant betay1  = 21847035105528745403288232691147584728191162732299865338377159692350059136679;\n    uint256 constant betay2  = 10505242626370262277552901082094356697409835680220590971873171140371331206856;\n    uint256 constant gammax1 = 11559732032986387107991004021392285783925812861821192530917403151452391805634;\n    uint256 constant gammax2 = 10857046999023057135944570762232829481370756359578518086990519993285655852781;\n    uint256 constant gammay1 = 4082367875863433681332203403145435568316851327593401208105741076214120093531;\n    uint256 constant gammay2 = 8495653923123431417604973247489272438418190587263600148770280649306958101930;\n    uint256 constant deltax1 = 18281420389139490670240572462309728931069762758666384847478890846556477812965;\n    uint256 constant deltax2 = 13401048439837810951017914211936278660216063821494073603722338220435396604496;\n    uint256 constant deltay1 = 21202874041022648331698980994305693341595566632225027482785352902129485264727;\n    uint256 constant deltay2 = 18936150877052652216308940020674055541483409091516037105694618299681834990474;\n\n    uint256 constant IC0x = 11708618300626501124421915901735889591197446563131571476394569301508043971365;\n    uint256 constant IC0y = 5667514267789447089323739319302611763465078048052662562196140462383395872508;\n    uint256 constant IC1x = 15195705616700521012127976013459675996720680873721938174087344817064767499959;\n    uint256 constant IC1y = 10672412375348497688974862364812884221172587257800457800668811962573422720732;\n    uint256 constant IC2x = 4469767714974381441038544382870449937983870305031160934495947295783672104013;\n    uint256 constant IC2y = 4361256855208731585297541461256540828791924499734176154562126034217325411934;\n    uint256 constant IC3x = 4065007474830663054201212769345725643214519104637863460251326998261224908568;\n    uint256 constant IC3y = 6722062532354494177039541269624640687683302797177341622876247091615420138062;\n    uint256 constant IC4x = 1608339021418891675882917683154745444281045012507703357182246989049514310802;\n    uint256 constant IC4y = 8128620874671164172824065936832829796083958521475019452105747777459375950633;\n    uint256 constant IC5x = 5257146532344065012887276372955246831140342551839377880655400784457099064055;\n    uint256 constant IC5y = 7978844236199995179937224040162027377080018126978522079920482177471499890762;\n    uint256 constant IC6x = 10919099488333612709240051641143996285651554605790292501117844479164219585395;\n    uint256 constant IC6y = 635941112977521509791637454846079128545601403436336522285604528441058883176;\n    uint256 constant IC7x = 705061730669005706983263006435004752941196689804428750178681337792905619800;\n    uint256 constant IC7y = 18860749750051025290426084402442253763575791772481148599856400050650550936756;\n    uint256 constant IC8x = 11127748386585527685549602598855629727831492527374704844754329658052519779790;\n    uint256 constant IC8y = 21812178917568511189373133106334498782516965982617079750055782729466471342097;\n    uint256 constant IC9x = 14606668935673508299530739594649429081565836775860125129151272617815996710514;\n    uint256 constant IC9y = 17331858016265809439561525313334479042500557416338688182261061090557648779826;\n    // Memory data\n    uint16 constant pVk = 0;\n    uint16 constant pPairing = 128;\n\n    uint16 constant pLastMem = 896;\n\n    uint16 constant proofLength = 8;\n    uint32 constant pubSignalLength = 9;\n\n    /// @dev returns the verification keys in the order that the verifier expects them:\n    /// alpha, beta, gamma, delta, ICs..\n    function getVerificationKeys() public pure returns (uint[] memory) {\n        uint[] memory vks = new uint[](16 + pubSignalLength * 2);\n        vks[0] = 20491192805390485299153009773594534940189261866228447918068658471970481763042;\n        vks[1] = 9383485363053290200918347156157836566562967994039712273449902621266178545958;\n        vks[2] = 4252822878758300859123897981450591353533073413197771768651442665752259397132;\n        vks[3] = 6375614351688725206403948262868962793625744043794305715222011528459656738731;\n        vks[4] = 21847035105528745403288232691147584728191162732299865338377159692350059136679;\n        vks[5] = 10505242626370262277552901082094356697409835680220590971873171140371331206856;\n        vks[6] = 11559732032986387107991004021392285783925812861821192530917403151452391805634;\n        vks[7] = 10857046999023057135944570762232829481370756359578518086990519993285655852781;\n        vks[8] = 4082367875863433681332203403145435568316851327593401208105741076214120093531;\n        vks[9] = 8495653923123431417604973247489272438418190587263600148770280649306958101930;\n        vks[10] = 18281420389139490670240572462309728931069762758666384847478890846556477812965;\n        vks[11] = 13401048439837810951017914211936278660216063821494073603722338220435396604496;\n        vks[12] = 21202874041022648331698980994305693341595566632225027482785352902129485264727;\n        vks[13] = 18936150877052652216308940020674055541483409091516037105694618299681834990474;\n        vks[14] = 11708618300626501124421915901735889591197446563131571476394569301508043971365;\n        vks[15] = 5667514267789447089323739319302611763465078048052662562196140462383395872508;\n        vks[16] = 15195705616700521012127976013459675996720680873721938174087344817064767499959;\n        vks[17] = 10672412375348497688974862364812884221172587257800457800668811962573422720732;\n        vks[18] = 4469767714974381441038544382870449937983870305031160934495947295783672104013;\n        vks[19] = 4361256855208731585297541461256540828791924499734176154562126034217325411934;\n        vks[20] = 4065007474830663054201212769345725643214519104637863460251326998261224908568;\n        vks[21] = 6722062532354494177039541269624640687683302797177341622876247091615420138062;\n        vks[22] = 1608339021418891675882917683154745444281045012507703357182246989049514310802;\n        vks[23] = 8128620874671164172824065936832829796083958521475019452105747777459375950633;\n        vks[24] = 5257146532344065012887276372955246831140342551839377880655400784457099064055;\n        vks[25] = 7978844236199995179937224040162027377080018126978522079920482177471499890762;\n        vks[26] = 10919099488333612709240051641143996285651554605790292501117844479164219585395;\n        vks[27] = 635941112977521509791637454846079128545601403436336522285604528441058883176;\n        vks[28] = 705061730669005706983263006435004752941196689804428750178681337792905619800;\n        vks[29] = 18860749750051025290426084402442253763575791772481148599856400050650550936756;\n        vks[30] = 11127748386585527685549602598855629727831492527374704844754329658052519779790;\n        vks[31] = 21812178917568511189373133106334498782516965982617079750055782729466471342097;\n        vks[32] = 14606668935673508299530739594649429081565836775860125129151272617815996710514;\n        vks[33] = 17331858016265809439561525313334479042500557416338688182261061090557648779826;\n        return vks;\n    }\n\n    /// @dev return true if the public signal is aliased\n    function isAliased(uint[] calldata _pubSignals) public pure returns (bool) {\n        // Alias check\n        if (_pubSignals[0] >= 1461501637330902918203684832716283019655932542976) { return true; }\n        if (_pubSignals[1] >= 1461501637330902918203684832716283019655932542976) { return true; }\n        if (_pubSignals[2] >= 21888242871839275222246405745257275088548364400416034343698204186575808495617) { return true; }\n        if (_pubSignals[3] >= 1461501637330902918203684832716283019655932542976) { return true; }\n        if (_pubSignals[4] >= 452312848583266388373324160190187140051835877600158453279131187530910662656) { return true; }\n        if (_pubSignals[5] >= 18446744073709551616) { return true; }\n        if (_pubSignals[6] >= 21888242871839275222246405745257275088548364400416034343698204186575808495617) { return true; }\n        if (_pubSignals[7] >= 904625697166532776746648320380374280103671755200316906558262375061821325312) { return true; }\n        if (_pubSignals[8] >= 4) { return true; }\n        return false;\n    }\n\n    function verifyProof(uint[] calldata _proofs, uint[] calldata _pubSignals) public view returns (bool) {\n        // Check Argument\n        require(_proofs.length == proofLength, \"Invalid proof\");\n        require(_pubSignals.length == pubSignalLength, \"Invalid public signal\");\n        if (isAliased(_pubSignals)) { return false; }\n        assembly {\n            // G1 function to multiply a G1 value(x,y) to value in an address\n            function g1_mulAccC(pR, x, y, s) {\n                let success\n                let mIn := mload(0x40)\n                mstore(mIn, x)\n                mstore(add(mIn, 32), y)\n                mstore(add(mIn, 64), s)\n\n                success := staticcall(sub(gas(), 2000), 7, mIn, 96, mIn, 64)\n\n                if iszero(success) {\n                    mstore(0, 0)\n                    return(0, 0x20)\n                }\n\n                mstore(add(mIn, 64), mload(pR))\n                mstore(add(mIn, 96), mload(add(pR, 32)))\n\n                success := staticcall(sub(gas(), 2000), 6, mIn, 128, pR, 64)\n\n                if iszero(success) {\n                    mstore(0, 0)\n                    return(0, 0x20)\n                }\n            }\n\n            function checkPairing(pA, pB, pC, pubSignals, pMem) -> isOk {\n                let _pPairing := add(pMem, pPairing)\n                let _pVk := add(pMem, pVk)\n\n                mstore(_pVk, IC0x)\n                mstore(add(_pVk, 32), IC0y)\n\n                // Compute the linear combination it.vkey.vk_x\n                g1_mulAccC(_pVk, IC1x, IC1y, calldataload(add(pubSignals, 0)))\n                g1_mulAccC(_pVk, IC2x, IC2y, calldataload(add(pubSignals, 32)))\n                g1_mulAccC(_pVk, IC3x, IC3y, calldataload(add(pubSignals, 64)))\n                g1_mulAccC(_pVk, IC4x, IC4y, calldataload(add(pubSignals, 96)))\n                g1_mulAccC(_pVk, IC5x, IC5y, calldataload(add(pubSignals, 128)))\n                g1_mulAccC(_pVk, IC6x, IC6y, calldataload(add(pubSignals, 160)))\n                g1_mulAccC(_pVk, IC7x, IC7y, calldataload(add(pubSignals, 192)))\n                g1_mulAccC(_pVk, IC8x, IC8y, calldataload(add(pubSignals, 224)))\n                g1_mulAccC(_pVk, IC9x, IC9y, calldataload(add(pubSignals, 256)))\n                // -A\n                mstore(_pPairing, calldataload(pA))\n                mstore(add(_pPairing, 32), mod(sub(q, calldataload(add(pA, 32))), q))\n\n                // B\n                mstore(add(_pPairing, 64), calldataload(pB))\n                mstore(add(_pPairing, 96), calldataload(add(pB, 32)))\n                mstore(add(_pPairing, 128), calldataload(add(pB, 64)))\n                mstore(add(_pPairing, 160), calldataload(add(pB, 96)))\n\n                // alpha1\n                mstore(add(_pPairing, 192), alphax)\n                mstore(add(_pPairing, 224), alphay)\n\n                // beta2\n                mstore(add(_pPairing, 256), betax1)\n                mstore(add(_pPairing, 288), betax2)\n                mstore(add(_pPairing, 320), betay1)\n                mstore(add(_pPairing, 352), betay2)\n\n                // it.vkey.vk_x\n                mstore(add(_pPairing, 384), mload(add(pMem, pVk)))\n                mstore(add(_pPairing, 416), mload(add(pMem, add(pVk, 32))))\n\n                // gamma2\n                mstore(add(_pPairing, 448), gammax1)\n                mstore(add(_pPairing, 480), gammax2)\n                mstore(add(_pPairing, 512), gammay1)\n                mstore(add(_pPairing, 544), gammay2)\n\n                // C\n                mstore(add(_pPairing, 576), calldataload(pC))\n                mstore(add(_pPairing, 608), calldataload(add(pC, 32)))\n\n                // delta2\n                mstore(add(_pPairing, 640), deltax1)\n                mstore(add(_pPairing, 672), deltax2)\n                mstore(add(_pPairing, 704), deltay1)\n                mstore(add(_pPairing, 736), deltay2)\n\n                let success := staticcall(sub(gas(), 2000), 8, _pPairing, 768, _pPairing, 0x20)\n\n                isOk := and(success, mload(_pPairing))\n            }\n\n            let pMem := mload(0x40)\n            mstore(0x40, add(pMem, pLastMem))\n\n            // Validate all evaluations\n            let isValid := checkPairing(_proofs.offset, add(_proofs.offset, 64), add(_proofs.offset, 192), _pubSignals.offset, pMem)\n\n            mstore(0, isValid)\n            return(0, 0x20)\n        }\n    }\n}\n"
    }
  }
}}