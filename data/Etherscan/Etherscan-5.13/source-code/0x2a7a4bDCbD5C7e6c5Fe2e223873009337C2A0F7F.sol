// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.18 <0.8.20;

// ungravel.eth, GroupWalletFactory, GroupWalletMaster, GroupWallet, ProxyWallet, TokenMaster, ProxyToken, PrePaidContract, AuctionMaster, BiddingProxy, intDeedMaster, extDeedMaster, IntDeedProxy by pepihasenfuss.eth 2017-2024, Copyright (c) 2024

// GroupWallet and ungravel is entirely based on Ethereum Name Service, "ENS", the domain name registry.

//   ENS, ENSRegistryWithFallback, PublicResolver, Resolver, FIFS-Registrar, Registrar, AuctionRegistrar, BaseRegistrar, ReverseRegistrar, DefaultReverseResolver, ETHRegistrarController,
//   PriceOracle, SimplePriceOracle, StablePriceOracle, ENSMigrationSubdomainRegistrar, CustomRegistrar, Root, RegistrarMigration are contracts of "ENS", by Nick Johnson and team.
//
//   Copyright (c) 2018, True Names Limited / ENS Labs Limited
//
//   Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//   The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


abstract contract AbstractGWF_ReverseRegistrar {
  function claim(address owner) external virtual returns (bytes32);
  function claimWithResolver(address owner, address resolver) external virtual returns (bytes32);
  function setName(string memory name) external virtual returns (bytes32);
  function node(address addr) external virtual pure returns (bytes32);
}


interface Abstract_GWPC {
  function getMasterCopy() external view returns (address);
}

/// @title Proxy - Generic proxy contract allows to execute all transactions applying the code of a master contract.
/// @author Stefan George - <stefan@gnosis.pm> /// ProxyGroupWallet adapted and applied for GroupWallet by pepihasenfuss.eth
pragma solidity ^0.8.18 <0.8.20;

contract ProxyGroupWallet {
    address internal masterCopy;

    mapping(uint256 => uint256) private tArr;
    address[]                   private owners;
    
    address internal GWF;                                                       // GWF - GroupWalletFactory contract
    mapping(uint256 => bytes)   private structures;
  
    // *************************************************************************
    event Deposit(address dep_from, uint256 dep_value);
    
    constructor(address _masterCopy, string memory _domain, AbstractGWF_ReverseRegistrar _reverse) payable
    { 
      masterCopy = _masterCopy;
      if (block.chainid!=1) _reverse.setName(_domain);
    }
    
    fallback () external payable
    {   
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            let master := and(sload(0), 0xffffffffffffffffffffffffffffffffffffffff)
            if eq(calldataload(0), 0xa619486e00000000000000000000000000000000000000000000000000000000) {
                mstore(0, master)
                return(0, 0x20)
            }

            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())
            let success := delegatecall(gas(), master, ptr, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            if eq(success, 0) { 
              if eq(returndatasize(),0) { revert(0, 0x504) }
              revert(0, returndatasize())
            }
            return(0, returndatasize())
        }
    }
    
    function upgrade(address master) external payable {
      require(Abstract_GWPC(masterCopy).getMasterCopy()==Abstract_GWPC(master).getMasterCopy()," gwp gwpc owner!");
      masterCopy = master;
    }
    
    receive() external payable { emit Deposit(msg.sender, msg.value); }         // *** GWP can sell common shares to TokenProxy, thus reveiving payment ***
}