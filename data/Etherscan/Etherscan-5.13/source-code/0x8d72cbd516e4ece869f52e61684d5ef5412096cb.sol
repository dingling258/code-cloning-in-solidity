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

abstract contract ABS_Reg {
  function state_pln(bytes32 _hash) public view virtual returns (uint);
  function saveExtDeedCntr_gm9(address _sender,bytes32 _hash,uint _value) public payable virtual;
  function unsealExternalBid_qfG(bytes32 _hash) public payable virtual;
  function finalizeExternalAuction_WmS(bytes32 _hash) public payable virtual;
  function cancelExternalBid_9ig(bytes32 seal, bytes32 hash) public payable virtual;
}

abstract contract ABS_IntDeedMaster {
  address public  masterCopy;
  ABS_Reg public  theRegistrar;
}

// ******************************* DEED MASTER CONTRACT ************************
pragma solidity ^0.8.18 <0.8.20;
contract intDeedMaster {
  address internal masterCopy;
  bytes32 public  lhash;
  address public  owner;
  uint64  public  creationDate;
  event DeedCreated(address indexed);
  
  ABS_Reg public  theRegistrar;

  constructor(address _masterCopy) payable
  {
    masterCopy   = _masterCopy;
    owner        = tx.origin;
    theRegistrar = ABS_Reg(msg.sender);
    creationDate = uint64(block.timestamp);
  }

  function getMasterCopy() public view returns (address) {
    return masterCopy;
  }
  
  function registrar() public payable returns (ABS_Reg) {
    return ABS_IntDeedMaster(masterCopy).theRegistrar();
  }
  
  function adjustBal_1k3(uint newValue) public payable {                        // 0x0000f6a6
    if (address(this).balance<newValue) return;
    require(msg.sender==address(registrar())&&payable(address(uint160(owner))).send(address(this).balance-newValue),"aBl");
  }

  function closeDeed_igk(address receiver) public payable {                     // 0x00004955
    address l_rcv = owner;
    require(owner!=address(0x0),'owner=0x0');
    
    if (uint160(receiver)>0) l_rcv = receiver;
    require(msg.sender==address(registrar())&&l_rcv!=address(0x0)&&payable(l_rcv).send(address(this).balance),"iclD");
  }
}