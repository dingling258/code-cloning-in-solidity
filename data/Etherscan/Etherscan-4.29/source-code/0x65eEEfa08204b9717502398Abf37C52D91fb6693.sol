// hevm: flattened sources of src/DssSpell.sol
// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity =0.8.16 >=0.5.12 >=0.8.16 <0.9.0;

////// lib/dss-exec-lib/src/CollateralOpts.sol
//
// CollateralOpts.sol -- Data structure for onboarding collateral
//
// Copyright (C) 2020-2022 Dai Foundation
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

/* pragma solidity ^0.8.16; */

struct CollateralOpts {
    bytes32 ilk;
    address gem;
    address join;
    address clip;
    address calc;
    address pip;
    bool    isLiquidatable;
    bool    isOSM;
    bool    whitelistOSM;
    uint256 ilkDebtCeiling;
    uint256 minVaultAmount;
    uint256 maxLiquidationAmount;
    uint256 liquidationPenalty;
    uint256 ilkStabilityFee;
    uint256 startingPriceFactor;
    uint256 breakerTolerance;
    uint256 auctionDuration;
    uint256 permittedDrop;
    uint256 liquidationRatio;
    uint256 kprFlatReward;
    uint256 kprPctReward;
}

////// lib/dss-exec-lib/src/DssExecLib.sol
//
// DssExecLib.sol -- MakerDAO Executive Spellcrafting Library
//
// Copyright (C) 2020-2022 Dai Foundation
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

/* pragma solidity ^0.8.16; */

/* import { CollateralOpts } from "./CollateralOpts.sol"; */

interface Initializable {
    function init(bytes32) external;
}

interface Authorizable {
    function rely(address) external;
    function deny(address) external;
    function setAuthority(address) external;
}

interface Fileable {
    function file(bytes32, address) external;
    function file(bytes32, uint256) external;
    function file(bytes32, bytes32, uint256) external;
    function file(bytes32, bytes32, address) external;
}

interface Drippable {
    function drip() external returns (uint256);
    function drip(bytes32) external returns (uint256);
}

interface Pricing {
    function poke(bytes32) external;
}

interface ERC20 {
    function decimals() external returns (uint8);
}

interface DssVat {
    function hope(address) external;
    function nope(address) external;
    function ilks(bytes32) external returns (uint256 Art, uint256 rate, uint256 spot, uint256 line, uint256 dust);
    function Line() external view returns (uint256);
    function suck(address, address, uint256) external;
}

interface ClipLike {
    function vat() external returns (address);
    function dog() external returns (address);
    function spotter() external view returns (address);
    function calc() external view returns (address);
    function ilk() external returns (bytes32);
}

interface DogLike {
    function ilks(bytes32) external returns (address clip, uint256 chop, uint256 hole, uint256 dirt);
}

interface JoinLike {
    function vat() external returns (address);
    function ilk() external returns (bytes32);
    function gem() external returns (address);
    function dec() external returns (uint256);
    function join(address, uint256) external;
    function exit(address, uint256) external;
}

// Includes Median and OSM functions
interface OracleLike_2 {
    function src() external view returns (address);
    function lift(address[] calldata) external;
    function drop(address[] calldata) external;
    function setBar(uint256) external;
    function kiss(address) external;
    function diss(address) external;
    function kiss(address[] calldata) external;
    function diss(address[] calldata) external;
    function orb0() external view returns (address);
    function orb1() external view returns (address);
}

interface MomLike {
    function setOsm(bytes32, address) external;
    function setPriceTolerance(address, uint256) external;
}

interface RegistryLike {
    function add(address) external;
    function xlip(bytes32) external view returns (address);
}

// https://github.com/makerdao/dss-chain-log
interface ChainlogLike {
    function setVersion(string calldata) external;
    function setIPFS(string calldata) external;
    function setSha256sum(string calldata) external;
    function getAddress(bytes32) external view returns (address);
    function setAddress(bytes32, address) external;
    function removeAddress(bytes32) external;
}

interface IAMLike {
    function ilks(bytes32) external view returns (uint256,uint256,uint48,uint48,uint48);
    function setIlk(bytes32,uint256,uint256,uint256) external;
    function remIlk(bytes32) external;
    function exec(bytes32) external returns (uint256);
}

interface LerpFactoryLike {
    function newLerp(bytes32 name_, address target_, bytes32 what_, uint256 startTime_, uint256 start_, uint256 end_, uint256 duration_) external returns (address);
    function newIlkLerp(bytes32 name_, address target_, bytes32 ilk_, bytes32 what_, uint256 startTime_, uint256 start_, uint256 end_, uint256 duration_) external returns (address);
}

interface LerpLike {
    function tick() external returns (uint256);
}

interface RwaOracleLike {
    function bump(bytes32 ilk, uint256 val) external;
}


library DssExecLib {

    /* WARNING

The following library code acts as an interface to the actual DssExecLib
library, which can be found in its own deployed contract. Only trust the actual
library's implementation.

    */

    address constant public LOG = 0xdA0Ab1e0017DEbCd72Be8599041a2aa3bA7e740F;
    uint256 constant internal WAD      = 10 ** 18;
    uint256 constant internal RAY      = 10 ** 27;
    uint256 constant internal RAD      = 10 ** 45;
    uint256 constant internal THOUSAND = 10 ** 3;
    uint256 constant internal MILLION  = 10 ** 6;
    uint256 constant internal BPS_ONE_PCT             = 100;
    uint256 constant internal BPS_ONE_HUNDRED_PCT     = 100 * BPS_ONE_PCT;
    uint256 constant internal RATES_ONE_HUNDRED_PCT   = 1000000021979553151239153027;
    function dai()        public view returns (address) { return getChangelogAddress("MCD_DAI"); }
    function mkr()        public view returns (address) { return getChangelogAddress("MCD_GOV"); }
    function vat()        public view returns (address) { return getChangelogAddress("MCD_VAT"); }
    function jug()        public view returns (address) { return getChangelogAddress("MCD_JUG"); }
    function pot()        public view returns (address) { return getChangelogAddress("MCD_POT"); }
    function vow()        public view returns (address) { return getChangelogAddress("MCD_VOW"); }
    function end()        public view returns (address) { return getChangelogAddress("MCD_END"); }
    function reg()        public view returns (address) { return getChangelogAddress("ILK_REGISTRY"); }
    function daiJoin()    public view returns (address) { return getChangelogAddress("MCD_JOIN_DAI"); }
    function lerpFab()    public view returns (address) { return getChangelogAddress("LERP_FAB"); }
    function clip(bytes32 _ilk) public view returns (address _clip) {}
    function flip(bytes32 _ilk) public view returns (address _flip) {}
    function calc(bytes32 _ilk) public view returns (address _calc) {}
    function getChangelogAddress(bytes32 _key) public view returns (address) {}
    function setAuthority(address _base, address _authority) public {}
    function canCast(uint40 _ts, bool _officeHours) public pure returns (bool) {}
    function nextCastTime(uint40 _eta, uint40 _ts, bool _officeHours) public pure returns (uint256 castTime) {}
    function setValue(address _base, bytes32 _what, uint256 _amt) public {}
    function setValue(address _base, bytes32 _ilk, bytes32 _what, uint256 _amt) public {}
    function setDSR(uint256 _rate, bool _doDrip) public {}
    function setIlkDebtCeiling(bytes32 _ilk, uint256 _amount) public {}
    function setIlkStabilityFee(bytes32 _ilk, uint256 _rate, bool _doDrip) public {}
    function sendPaymentFromSurplusBuffer(address _target, uint256 _amount) public {}
    function linearInterpolation(bytes32 _name, address _target, bytes32 _ilk, bytes32 _what, uint256 _startTime, uint256 _start, uint256 _end, uint256 _duration) public returns (address) {}
}

////// lib/dss-exec-lib/src/DssAction.sol
//
// DssAction.sol -- DSS Executive Spell Actions
//
// Copyright (C) 2020-2022 Dai Foundation
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

/* pragma solidity ^0.8.16; */

/* import { DssExecLib } from "./DssExecLib.sol"; */
/* import { CollateralOpts } from "./CollateralOpts.sol"; */

interface OracleLike_1 {
    function src() external view returns (address);
}

abstract contract DssAction {

    using DssExecLib for *;

    // Modifier used to limit execution time when office hours is enabled
    modifier limited {
        require(DssExecLib.canCast(uint40(block.timestamp), officeHours()), "Outside office hours");
        _;
    }

    // Office Hours defaults to true by default.
    //   To disable office hours, override this function and
    //    return false in the inherited action.
    function officeHours() public view virtual returns (bool) {
        return true;
    }

    // DssExec calls execute. We limit this function subject to officeHours modifier.
    function execute() external limited {
        actions();
    }

    // DssAction developer must override `actions()` and place all actions to be called inside.
    //   The DssExec function will call this subject to the officeHours limiter
    //   By keeping this function public we allow simulations of `execute()` on the actions outside of the cast time.
    function actions() public virtual;

    // Provides a descriptive tag for bot consumption
    // This should be modified weekly to provide a summary of the actions
    // Hash: seth keccak -- "$(wget https://<executive-vote-canonical-post> -q -O - 2>/dev/null)"
    function description() external view virtual returns (string memory);

    // Returns the next available cast time
    function nextCastTime(uint256 eta) external view returns (uint256 castTime) {
        require(eta <= type(uint40).max);
        castTime = DssExecLib.nextCastTime(uint40(eta), uint40(block.timestamp), officeHours());
    }
}

////// lib/dss-exec-lib/src/DssExec.sol
//
// DssExec.sol -- MakerDAO Executive Spell Template
//
// Copyright (C) 2020-2022 Dai Foundation
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

/* pragma solidity ^0.8.16; */

interface PauseAbstract {
    function delay() external view returns (uint256);
    function plot(address, bytes32, bytes calldata, uint256) external;
    function exec(address, bytes32, bytes calldata, uint256) external returns (bytes memory);
}

interface Changelog {
    function getAddress(bytes32) external view returns (address);
}

interface SpellAction {
    function officeHours() external view returns (bool);
    function description() external view returns (string memory);
    function nextCastTime(uint256) external view returns (uint256);
}

contract DssExec {

    Changelog      constant public log   = Changelog(0xdA0Ab1e0017DEbCd72Be8599041a2aa3bA7e740F);
    uint256                 public eta;
    bytes                   public sig;
    bool                    public done;
    bytes32       immutable public tag;
    address       immutable public action;
    uint256       immutable public expiration;
    PauseAbstract immutable public pause;

    // Provides a descriptive tag for bot consumption
    // This should be modified weekly to provide a summary of the actions
    // Hash: seth keccak -- "$(wget https://<executive-vote-canonical-post> -q -O - 2>/dev/null)"
    function description() external view returns (string memory) {
        return SpellAction(action).description();
    }

    function officeHours() external view returns (bool) {
        return SpellAction(action).officeHours();
    }

    function nextCastTime() external view returns (uint256 castTime) {
        return SpellAction(action).nextCastTime(eta);
    }

    // @param _description  A string description of the spell
    // @param _expiration   The timestamp this spell will expire. (Ex. block.timestamp + 30 days)
    // @param _spellAction  The address of the spell action
    constructor(uint256 _expiration, address _spellAction) {
        pause       = PauseAbstract(log.getAddress("MCD_PAUSE"));
        expiration  = _expiration;
        action      = _spellAction;

        sig = abi.encodeWithSignature("execute()");
        bytes32 _tag;                    // Required for assembly access
        address _action = _spellAction;  // Required for assembly access
        assembly { _tag := extcodehash(_action) }
        tag = _tag;
    }

    function schedule() public {
        require(block.timestamp <= expiration, "This contract has expired");
        require(eta == 0, "This spell has already been scheduled");
        eta = block.timestamp + PauseAbstract(pause).delay();
        pause.plot(action, tag, sig, eta);
    }

    function cast() public {
        require(!done, "spell-already-cast");
        done = true;
        pause.exec(action, tag, sig, eta);
    }
}

////// lib/dss-test/lib/dss-interfaces/src/ERC/GemAbstract.sol
/* pragma solidity >=0.5.12; */

// A base ERC-20 abstract class
// https://eips.ethereum.org/EIPS/eip-20
interface GemAbstract {
    function totalSupply() external view returns (uint256);
    function balanceOf(address) external view returns (uint256);
    function allowance(address, address) external view returns (uint256);
    function approve(address, uint256) external returns (bool);
    function transfer(address, uint256) external returns (bool);
    function transferFrom(address, address, uint256) external returns (bool);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

////// src/DssSpell.sol
// SPDX-FileCopyrightText: © 2020 Dai Foundation <www.daifoundation.org>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

/* pragma solidity 0.8.16; */

/* import "dss-exec-lib/DssExec.sol"; */
/* import "dss-exec-lib/DssAction.sol"; */
/* import { GemAbstract } from "dss-interfaces/ERC/GemAbstract.sol"; */

interface InputConduitJarLike {
    function push(uint256) external;
}

interface JarLike {
    function void() external;
}

interface RwaOutputConduitLike {
    function kiss(address) external;
}

interface ProxyLike_1 {
    function exec(address target, bytes calldata args) external payable returns (bytes memory out);
}

contract DssSpellAction is DssAction {
    // Provides a descriptive tag for bot consumption
    // This should be modified weekly to provide a summary of the actions
    // Hash: cast keccak -- "$(wget 'https://raw.githubusercontent.com/makerdao/community/66aa0bcc2522ef68cd07404a220f3d0ceed66ff6/governance/votes/Executive%20vote%20-%20April%2022%2C%202024.md' -q -O - 2>/dev/null)"
    string public constant override description =
        "2024-04-22 MakerDAO Executive Spell | Hash: 0x795156c619f653246521bff408f49666bc1a13c626ff197e84973974782d60a7";

    // Set office hours according to the summary
    function officeHours() public pure override returns (bool) {
        return false;
    }

    // ---------- Rates ----------
    // Many of the settings that change weekly rely on the rate accumulator
    // described at https://docs.makerdao.com/smart-contract-modules/rates-module
    // To check this yourself, use the following rate calculation (example 8%):
    //
    // $ bc -l <<< 'scale=27; e( l(1.08)/(60 * 60 * 24 * 365) )'
    //
    // A table of rates can be found at
    //    https://ipfs.io/ipfs/QmVp4mhhbwWGTfbh2BzwQB9eiBrQBKiqcPRZCaAxNUaar6
    //
    // uint256 internal constant X_PCT_1000000003022265980097387650RATE = ;
    uint256 internal constant TEN_PCT_RATE                  = 1000000003022265980097387650;
    uint256 internal constant TEN_PT_TWO_FIVE_PCT_RATE      = 1000000003094251918120023627;
    uint256 internal constant TEN_PT_SEVEN_FIVE_PCT_RATE    = 1000000003237735385034516037;
    uint256 internal constant ELEVEN_PCT_RATE               = 1000000003309234382829738808;
    uint256 internal constant ELEVEN_PT_TWO_FIVE_PCT_RATE   = 1000000003380572527855758393;
    uint256 internal constant ELEVEN_PT_FIVE_PCT_RATE       = 1000000003451750542235895695;
    uint256 internal constant ELEVEN_PT_SEVEN_FIVE_PCT_RATE = 1000000003522769143241571114;
    uint256 internal constant TWELVE_PT_TWO_FIVE_PCT_RATE   = 1000000003664330950215446102;

    // ---------- Contract addresses ----------
    GemAbstract internal immutable MKR = GemAbstract(DssExecLib.mkr());

    address internal immutable MCD_PSM_PAX_A_INPUT_CONDUIT_JAR = DssExecLib.getChangelogAddress("MCD_PSM_PAX_A_INPUT_CONDUIT_JAR");
    address internal immutable MCD_PSM_PAX_A_JAR               = DssExecLib.getChangelogAddress("MCD_PSM_PAX_A_JAR");

    // ----------- Payment addresses -----------
    address internal constant BONAPUBLICA = 0x167c1a762B08D7e78dbF8f24e5C3f1Ab415021D3;
    address internal constant CLOAKY      = 0x869b6d5d8FA7f4FFdaCA4D23FFE0735c5eD1F818;
    address internal constant TRUENAME    = 0x612F7924c367575a0Edf21333D96b15F1B345A5d;
    address internal constant BLUE        = 0xb6C09680D822F162449cdFB8248a7D3FC26Ec9Bf;
    address internal constant VIGILANT    = 0x2474937cB55500601BCCE9f4cb0A0A72Dc226F61;
    address internal constant PIPKIN      = 0x0E661eFE390aE39f90a58b04CF891044e56DEDB7;
    address internal constant JAG         = 0x58D1ec57E4294E4fe650D1CB12b96AE34349556f;
    address internal constant UPMAKER     = 0xbB819DF169670DC71A16F58F55956FE642cc6BcD;

    address internal constant IAMMEEOH       = 0x47f7A5d8D27f259582097E1eE59a07a816982AE9;
    address internal constant DAI_VINCI      = 0x9ee47F0f82F1A6F45C4E1D25Ce95C321D8C8356a;
    address internal constant OPENSKY_2      = 0xf44f97f4113759E0a57756bE49C0655d490Cf19F;
    address internal constant ACREDAOS       = 0xBF9226345F601150F64Ea4fEaAE7E40530763cbd;
    address internal constant RES            = 0x8c5c8d76372954922400e4654AF7694e158AB784;
    address internal constant HARMONY_2      = 0xE20A2e231215e9b7Aa308463F1A7490b2ECE55D3;
    address internal constant LIBERTAS       = 0xE1eBfFa01883EF2b4A9f59b587fFf1a5B44dbb2f;
    address internal constant SEEDLATAMETH_2 = 0xd43b89621fFd48A8A51704f85fd0C87CbC0EB299;
    address internal constant ROOT           = 0xC74392777443a11Dc26Ce8A3D934370514F38A91;

    address internal constant AAVE_V3_TREASURY = 0x464C71f6c2F760DdA6093dCB91C24c39e5d6e18c;

    // ---------- Whitelist new address in the RWA015-A output conduit ----------
    address internal constant RWA015_A_CUSTODY_2                 = 0x6759610547a36E9597Ef452aa0B9cace91291a2f;
    address internal immutable RWA015_A_OUTPUT_CONDUIT           = DssExecLib.getChangelogAddress("RWA015_A_OUTPUT_CONDUIT");


    // ---------- Trigger Spark Proxy Spell ----------
    // Spark Proxy: https://github.com/marsfoundation/sparklend-deployments/blob/bba4c57d54deb6a14490b897c12a949aa035a99b/script/output/1/primary-sce-latest.json#L2
    address internal constant SPARK_PROXY = 0x3300f198988e4C9C63F75dF86De36421f06af8c4;
    address internal constant SPARK_SPELL = 0x151D5fA7B3eD50098fFfDd61DB29cB928aE04C0e;

    function actions() public override {
        // ---------- Stability Fee Updates ----------
        // Forum: http://forum.makerdao.com/t/stability-scope-parameter-changes-12-under-sta-article-3-3/24132

        // ETH-A: Decrease the Stability Fee by 3 percentage points from 13.25% to 10.25%
        DssExecLib.setIlkStabilityFee("ETH-A", TEN_PT_TWO_FIVE_PCT_RATE, /* doDrip = */ true);

        // ETH-B: Decrease the Stability Fee by 3 percentage points from 13.75% to 10.75%
        DssExecLib.setIlkStabilityFee("ETH-B", TEN_PT_SEVEN_FIVE_PCT_RATE, /* doDrip = */ true);

        // ETH-C: Decrease the Stability Fee by 3 percentage points from 13.00% to 10.00%
        DssExecLib.setIlkStabilityFee("ETH-C", TEN_PCT_RATE, /* doDrip = */ true);

        // WSTETH-A: Decrease the Stability Fee by 3 percentage points from 14.25% to 11.25%
        DssExecLib.setIlkStabilityFee("WSTETH-A", ELEVEN_PT_TWO_FIVE_PCT_RATE, /* doDrip = */ true);

        // WSTETH-B: Decrease the Stability Fee by 3 percentage points from 14.00% to 11.00%
        DssExecLib.setIlkStabilityFee("WSTETH-B", ELEVEN_PCT_RATE, /* doDrip = */ true);

        // WBTC-A: Decrease the Stability Fee by 3 percentage points from 14.75% to 11.75%
        DssExecLib.setIlkStabilityFee("WBTC-A", ELEVEN_PT_SEVEN_FIVE_PCT_RATE, /* doDrip = */ true);

        // WBTC-B: Decrease the Stability Fee by 3 percentage points from 15.25% to 12.25%
        DssExecLib.setIlkStabilityFee("WBTC-B", TWELVE_PT_TWO_FIVE_PCT_RATE, /* doDrip = */ true);

        // WBTC-C: Decrease the Stability Fee by 3 percentage points from 14.50% to 11.50%
        DssExecLib.setIlkStabilityFee("WBTC-C", ELEVEN_PT_FIVE_PCT_RATE, /* doDrip = */ true);

        // ---------- DSR Change ----------
        // Forum: http://forum.makerdao.com/t/stability-scope-parameter-changes-12-under-sta-article-3-3/24132

        // DSR: Decrease the Dai Savings Rate by 3 percentage points from 13.00% to 10.00%
        DssExecLib.setDSR(TEN_PCT_RATE, /* doDrip = */ true);

        // ---------- AD Compensation ----------
        // Forum: https://forum.makerdao.com/t/march-2024-aligned-delegate-compensation/24088
        // MIP: https://mips.makerdao.com/mips/details/MIP101#2-6-3-aligned-delegate-income-and-participation-requirements

        // BONAPUBLICA - 41.67 MKR - 0x167c1a762B08D7e78dbF8f24e5C3f1Ab415021D3
        MKR.transfer(BONAPUBLICA, 41.67 ether); // NOTE: 'ether' is a keyword helper, only MKR is transferred here

        // Cloaky - 41.67 MKR - 0x869b6d5d8FA7f4FFdaCA4D23FFE0735c5eD1F818
        MKR.transfer(CLOAKY, 41.67 ether); // NOTE: 'ether' is a keyword helper, only MKR is transferred here

        // TRUE NAME - 41.67 MKR - 0x612F7924c367575a0Edf21333D96b15F1B345A5d
        MKR.transfer(TRUENAME, 41.67 ether); // NOTE: 'ether' is a keyword helper, only MKR is transferred here

        // BLUE - 39.75 MKR - 0xb6C09680D822F162449cdFB8248a7D3FC26Ec9Bf
        MKR.transfer(BLUE, 39.75 ether); // NOTE: 'ether' is a keyword helper, only MKR is transferred here

        // vigilant - 13.89 MKR - 0x2474937cB55500601BCCE9f4cb0A0A72Dc226F61
        MKR.transfer(VIGILANT, 13.89 ether); // NOTE: 'ether' is a keyword helper, only MKR is transferred here

        // Pipkin - 13.89 MKR - 0x0E661eFE390aE39f90a58b04CF891044e56DEDB7
        MKR.transfer(PIPKIN, 13.89 ether); // NOTE: 'ether' is a keyword helper, only MKR is transferred here

        // JAG - 9.08 MKR - 0x58D1ec57E4294E4fe650D1CB12b96AE34349556f
        MKR.transfer(JAG, 9.08 ether); // NOTE: 'ether' is a keyword helper, only MKR is transferred here

        // UPMaker - 12.93 MKR - 0xbB819DF169670DC71A16F58F55956FE642cc6BcD
        MKR.transfer(UPMAKER, 12.93 ether); // NOTE: 'ether' is a keyword helper, only MKR is transferred here

        // ---------- AVC Member Compensation ----------
        // Forum: https://forum.makerdao.com/t/avc-member-participation-rewards-q1-2024/24083
        // MIP: https://mips.makerdao.com/mips/details/MIP101#2-5-10-avc-member-participation-rewards

        // IamMeeoh - 20.85 MKR - 0x47f7A5d8D27f259582097E1eE59a07a816982AE9
        MKR.transfer(IAMMEEOH, 20.85 ether); // NOTE: 'ether' is a keyword helper, only MKR is transferred here

        // DAI-Vinci - 20.85 MKR - 0x9ee47F0f82F1A6F45C4E1D25Ce95C321D8C8356a
        MKR.transfer(DAI_VINCI, 20.85 ether); // NOTE: 'ether' is a keyword helper, only MKR is transferred here

        // opensky - 20.85 MKR - 0xf44f97f4113759E0a57756bE49C0655d490Cf19F
        MKR.transfer(OPENSKY_2, 20.85 ether); // NOTE: 'ether' is a keyword helper, only MKR is transferred here

        // ACRE DAOs - 20.85 MKR - 0xBF9226345F601150F64Ea4fEaAE7E40530763cbd
        MKR.transfer(ACREDAOS, 20.85 ether); // NOTE: 'ether' is a keyword helper, only MKR is transferred here

        // Res - 20.85 MKR - 0x8c5c8d76372954922400e4654AF7694e158AB784
        MKR.transfer(RES, 20.85 ether); // NOTE: 'ether' is a keyword helper, only MKR is transferred here

        // Harmony - 20.85 MKR - 0xE20A2e231215e9b7Aa308463F1A7490b2ECE55D3
        MKR.transfer(HARMONY_2, 20.85 ether); // NOTE: 'ether' is a keyword helper, only MKR is transferred here

        // Libertas - 20.85 MKR - 0xE1eBfFa01883EF2b4A9f59b587fFf1a5B44dbb2f
        MKR.transfer(LIBERTAS, 20.85 ether); // NOTE: 'ether' is a keyword helper, only MKR is transferred here

        // seedlatam.eth - 20.85 MKR - 0xd43b89621fFd48A8A51704f85fd0C87CbC0EB299
        MKR.transfer(SEEDLATAMETH_2, 20.85 ether); // NOTE: 'ether' is a keyword helper, only MKR is transferred here

        // 0xRoot - 8.34 MKR - 0xC74392777443a11Dc26Ce8A3D934370514F38A91
        MKR.transfer(ROOT, 8.34 ether); // NOTE: 'ether' is a keyword helper, only MKR is transferred here

        // ---------- Aave Revenue Share ----------
        // Forum: https://forum.makerdao.com/t/spark-aave-revenue-share-calculation-payment-3-q1-2024/24014

        // Transfer 238,339 DAI to 0x464C71f6c2F760DdA6093dCB91C24c39e5d6e18c
        DssExecLib.sendPaymentFromSurplusBuffer(AAVE_V3_TREASURY, 238_339);

        // ---------- Whitelist new address in the RWA015-A output conduit ----------
        // Forum: https://forum.makerdao.com/t/proposed-housekeeping-items-upcoming-executive-spell-2024-04-18/24084

        // Call kiss on RWA015_A_OUTPUT_CONDUIT with address 0x6759610547a36E9597Ef452aa0B9cace91291a2f
        RwaOutputConduitLike(RWA015_A_OUTPUT_CONDUIT).kiss(RWA015_A_CUSTODY_2);

        // ---------- Push USDP out of input conduit ----------
        // Forum: https://forum.makerdao.com/t/proposed-housekeeping-items-upcoming-executive-spell-2024-04-18/24084

        // Raise PSM-PAX-A DC to 100,000 DAI
        DssExecLib.setIlkDebtCeiling("PSM-PAX-A", 100_000);

        // Call push() on MCD_PSM_PAX_A_INPUT_CONDUIT_JAR (use push(uint256 amt)) to push 84,211.27 USDP
        InputConduitJarLike(MCD_PSM_PAX_A_INPUT_CONDUIT_JAR).push(84_211.27 ether); // Note: `ether` is only a keyword helper

        // Call void() on MCD_PSM_PAX_A_JAR
        JarLike(MCD_PSM_PAX_A_JAR).void();

        // Set PSM-PAX-A DC to 0 DAI
        DssExecLib.setIlkDebtCeiling("PSM-PAX-A", 0);

        // ---------- Spark Proxy Spell ----------
        // Forum: https://forum.makerdao.com/t/apr-4-2024-proposed-changes-to-sparklend-for-upcoming-spell/24033
        // Poll: https://vote.makerdao.com/polling/QmZND8WW
        // Poll: https://vote.makerdao.com/polling/QmcRdMyA
        // Poll: https://vote.makerdao.com/polling/QmSh8gyC
        // Poll: https://vote.makerdao.com/polling/QmfGV2vt
        // Poll: https://vote.makerdao.com/polling/QmSYZSCQ
        // Poll: https://vote.makerdao.com/polling/QmUhT32b
        // Poll: https://vote.makerdao.com/polling/QmVsKsGa
        // Forum: https://forum.makerdao.com/t/sparklend-external-security-access-multisig-for-freezer-mom/24070
        // Poll: https://vote.makerdao.com/polling/QmVXriiT
        // Forum: http://forum.makerdao.com/t/stability-scope-parameter-changes-12-under-sta-article-3-3/24132

        // Trigger Spark Proxy Spell at 0x151D5fA7B3eD50098fFfDd61DB29cB928aE04C0e
        ProxyLike_1(SPARK_PROXY).exec(SPARK_SPELL, abi.encodeWithSignature("execute()"));
    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) {}
}

