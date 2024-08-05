// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.18 <0.8.20;

/*
AuctionMaster, intDeedMaster, extDeedMaster, IntDeedProxy, BiddingProxy ( by pepihasenfuss.eth, copyright (c) 2024, based on ENS 1.0 Temporary Hash Registrar, a Vickrey Auction introduced by Nick Johnson and the ENS team )
A Vickrey auction or sealed-bid second-price auction (SBSPA) is a type of sealed-bid auction.

ungravel.eth, GroupWalletFactory, GroupWalletMaster, GroupWallet, ProxyWallet, TokenMaster, ProxyToken, PrePaidContract, AuctionMaster, BiddingProxy, intDeedMaster, extDeedMaster, IntDeedProxy by pepihasenfuss.eth 2017-2024, Copyright (c) 2024

========================

//   ENS, ENSRegistryWithFallback, PublicResolver, Resolver, FIFS-Registrar, Registrar, AuctionRegistrar, BaseRegistrar, ReverseRegistrar, DefaultReverseResolver, ETHRegistrarController,
//   PriceOracle, SimplePriceOracle, StablePriceOracle, ENSMigrationSubdomainRegistrar, CustomRegistrar, Root, RegistrarMigration are contracts of "ENS", by Nick Johnson and team.
//
//   Copyright (c) 2018, True Names Limited / ENS Labs Limited
//
//   Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//   The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

interface Abstract_ENS {
  function owner(bytes32 node) external view  returns(address);
  function resolver(bytes32 node) external view  returns(address);
  function ttl(bytes32 node) external view  returns(uint64);
  function setOwner(bytes32 node, address ensowner)  external;
  function setSubnodeOwner(bytes32 node, bytes32 label, address ensowner)  external;
  function setResolver(bytes32 node, address ensresolver)  external;
  function setTTL(bytes32 node, uint64 ensttl)  external;
  function recordExists(bytes32 nodeENS) external view returns (bool);

  event NewOwner(bytes32 indexed node, bytes32 indexed label, address ensowner);
  event Transfer(bytes32 indexed node, address ensowner);
  event NewResolver(bytes32 indexed node, address ensresolver);
  event NewTTL(bytes32 indexed node, uint64 ensttl);
}

abstract contract ABS_Resolver {
  mapping(bytes32=>bytes) hashes;

  event AddrChanged(bytes32 indexed node, address a);
  event AddressChanged(bytes32 indexed node, uint coinType, bytes newAddress);
  event NameChanged(bytes32 indexed node, string name);
  event ABIChanged(bytes32 indexed node, uint256 indexed contentType);
  event PubkeyChanged(bytes32 indexed node, bytes32 x, bytes32 y);
  event TextChanged(bytes32 indexed node, string indexed indexedKey, string key);
  event ContenthashChanged(bytes32 indexed node, bytes hash);

  function name(bytes32 node) external virtual view returns (string memory);
  function addr(bytes32 node) external virtual view returns (address payable);

  function setABI(bytes32 node, uint256 contentType, bytes calldata data) external virtual;
  function setAddr(bytes32 node, address r_addr) external virtual;
  function setAddr(bytes32 node, uint coinType, bytes calldata a) external virtual;
  function setName(bytes32 node, string calldata _name) external virtual;
  function setText(bytes32 node, string calldata key, string calldata value) external virtual;
  function setAuthorisation(bytes32 node, address target, bool isAuthorised) external virtual;
  function supportsInterface(bytes4 interfaceId) external virtual view returns (bool);
}

contract AbstractGWMBaseReg {
  event NameMigrated(uint256 indexed id, address indexed owner, uint expires);
  event NameRegistered(uint256 indexed id, address indexed owner, uint expires);
  event NameRenewed(uint256 indexed id, uint expires);

  bytes32 public baseNode;   // The namehash of the TLD this registrar owns (eg, .eth)
}

abstract contract Abstract_Resolver {
  mapping (bytes32 => string) public name;
}

abstract contract ABS_ReverseRegistrar {
  Abstract_Resolver public defaultResolver;
  function node(address addr) external virtual pure returns (bytes32);
}

abstract contract AbstractETHRegCntrl {
  event NameRegistered(string name, bytes32 indexed label, address indexed owner, uint cost, uint expires);
  event NameRenewed(string name, bytes32 indexed label, uint cost, uint expires);

  function rentPrice(string memory name, uint duration) view external virtual returns(uint);
  function registerWithConfig(string memory name, address owner, uint duration, bytes32 secret, address resolver, address addr) external virtual payable;
}

abstract contract NmWrapper {
  function setSubnodeRecord(bytes32 parentNode,string memory label,address owner,address resolver,uint64 ttl,uint32 fuses,uint64 expiry) external virtual returns (bytes32 node);
  function setSubnodeOwner(bytes32 node,string calldata label,address newOwner,uint32 fuses,uint64 expiry) external virtual returns (bytes32);
  function ownerOf(uint256 id) external virtual view returns (address);
  function setApprovalForAll(address operator,bool approved) external virtual;
}

abstract contract ABS_Reg {
  function state_pln(bytes32 _hash) public view virtual returns (uint);
  function saveExtDeedCntr_gm9(address _sender,bytes32 _hash,uint _value) public payable virtual;
  function unsealExternalBid_qfG(bytes32 _hash) public payable virtual;
  function finalizeExternalAuction_WmS(bytes32 _hash) public payable virtual;
  function cancelExternalBid_9ig(bytes32 seal, bytes32 hash) public payable virtual;
}

bytes32 constant kkk = 0x4db45745d63e3d3fca02d388bb6d96a256b72fa6a5ca7e7b2c10c90c84130f3b;


// ******************************* EXT DEED MASTER CONTRACT ********************
// An external bidder is unknown, anonymous and not a member of the group. A proxy bidding contract is deployed
// for each external bidder beeing invited to participate in a Funding Auction.
pragma solidity ^0.8.18 <0.8.20;
contract extDeedMaster {
  address internal masterCopy;
  address public  owner;
  uint64  public  creationDate;
  ABS_Reg public  registrar;
  bytes32 public  lhash;

  event DeedCreated(address indexed,bytes32 indexed);
  event NewBid(address indexed);
  event RevealBid(address indexed);
  event CancelBid(address indexed);

  constructor(address _masterCopy) payable
  {
    masterCopy   = _masterCopy;
    owner        = tx.origin;
    registrar    = ABS_Reg(msg.sender);
    creationDate = uint64(block.timestamp);
  }

  function getMasterCopy() public view returns (address) {
    return masterCopy;
  }

  function adjustBal_1k3(uint newValue) public payable {                        // 0x0000f6a6
    if (address(this).balance<=newValue) return;
    require(msg.sender==address(registrar)&&address(this).balance>0&&payable(address(uint160(owner))).send(address(this).balance-newValue),"aSd");
  }

  function closeDeed_igk(address receiver) public payable {                     // 0x00004955
    require(msg.sender==address(registrar)&&payable(address( (receiver!=address(0x0)) ? receiver : owner )).send(address(this).balance),"exD");
  }
  
  receive() external payable {                                                  // receiving fallback function, catches all extDeedProxy calls
    uint lstate = registrar.state_pln(lhash);
    
    if (lstate==1) {                                                                      // OPEN for bidding
      require(lhash!=0x0&&msg.value>0&&address(this).balance==msg.value,"extDeedMaster failed");
      owner = msg.sender;
      registrar.saveExtDeedCntr_gm9(msg.sender,lhash,msg.value);
      emit NewBid(msg.sender);
    } else
    {

      require(lhash!=0x0&&msg.value==0&&owner==msg.sender,"extDeedMaster illegal"); // only Deed owner calls without ETH

      if (lstate==4) {                                                      
        registrar.unsealExternalBid_qfG(lhash);                                 // REVEAL phase
        emit RevealBid(msg.sender);
      } else
      {
        if (lstate==2) {                                                                            // FINALIZE phase
          registrar.finalizeExternalAuction_WmS(lhash);
        } else
        {
          if (lstate==6) {                                                                         // CANCEL - auction done, no time-out
            registrar.cancelExternalBid_9ig(keccak256(abi.encode(lhash,owner,address(this).balance,kkk)),lhash);
            emit CancelBid(msg.sender);
          } else
          {
            if (lstate==0) {                                                    // TIMEOUT - auction done, no bidding revealed and finalized
              require(payable(owner).send(address(this).balance),"extDeedMaster payback failed");
              emit CancelBid(msg.sender);
            } else
            {                                                                                              // unknown state --> throw an error and revert
              require(false,"extDeedMaster FB");                                // fallback - unknown auction state
            }
          }
        }
      }
    }
  }
}