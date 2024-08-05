// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// goerli test:
// genart721: 0x5d498622B0AbCeb4A7038940f3566587bdfc0151
// relic: 0x4aE89D271784421a73f7fbd6E002798cEB68d1a9

abstract contract GenArt721  {
  function purchaseTo(address _to, uint256 _projectId) public virtual payable returns (uint256 _tokenId);
  function projectTokenInfo(uint256 _projectId) public virtual view returns (address artistAddress, uint256 pricePerTokenInWei, uint256 invocations, uint256 maxInvocations, bool active, address additionalPayee, uint256 additionalPayeePercentage);
  function tokensOfOwner(address owner) external virtual view returns (uint256[] memory);
}

interface IDelegationRegistry {
    
  /// @notice Delegation type
  enum DelegationType {
		       NONE,
		       ALL,
		       CONTRACT,
		       TOKEN
  }

  /// @notice Info about a single delegation, used for onchain enumeration
  struct DelegationInfo {
    DelegationType type_;
    address vault;
    address delegate;
    address contract_;
    uint256 tokenId;
  }
  function getDelegationsByDelegate(address delegate) external view returns (DelegationInfo[] memory);
}

contract Relic {
  uint256 public num = 0; 
  uint256 public cost = 1; // 1 wei to inscribe address
  bool public is_sealed = false;
  address public admin_address;
  string public message;
  bytes32 public squiggle_mint_tx;

  address constant delegatecash_address = 0x00000000000076A84feF008CDAbe6409d2FE638B;
  address constant snowfro_address = 0xf3860788D1597cecF938424bAABe976FaC87dC26; 
  address constant lacma_address = 0xf3860788D1597cecF938424bAABe976FaC87dC26; //TODO, change this to destination LACMA address
  
  GenArt721 public squiggle;
  IDelegationRegistry public delegatecash;  
  
  mapping (address => bool) public has_inscribed;
  mapping (uint256 => address) public inscriptions;
  mapping (address => uint256) public num_squiggles; //number of squiggles owned at time of inscribing

  //experimental mapping to track which squiggles have been counted
  mapping (uint256 => bool) public squiggle_inscribed;
  
  event eInscribe(address a);
    
  modifier requireAdmin() {
    require(msg.sender==admin_address, "Requires admin privileges");
    _;
  }

  modifier notSealed() {
    require(is_sealed == false, "Contract has been sealed");
    _;
  }

  constructor() {
    admin_address = msg.sender; //TODO change this to snowfro.eth
    address _squiggle_contract_address = 0x059EDD72Cd353dF5106D2B9cC5ab83a52287aC3a;
    squiggle = GenArt721(_squiggle_contract_address);
    delegatecash = IDelegationRegistry(delegatecash_address);    
  }

  receive() external payable  {
    inscribeAddress();
  }

  function seal() public requireAdmin notSealed {
    is_sealed = true;
  }

  //mint the last squiggle
  function mint10000th() public requireAdmin notSealed {
    require(msg.sender == snowfro_address,"Must be initiated by Snowfro");
    uint256 invocations;    
    (,,invocations,,,,) = squiggle.projectTokenInfo(0);
    //    require(invocations == 9999, "Invocations must be 9999");
    require(invocations == 9998, "Invocations must be 9998"); //TODO: DEBUG: this is for testing, change back to 9999
    squiggle.purchaseTo(lacma_address,0);
  }
  
  //set administrator, revoking previous
  function setAdmin(address a) public requireAdmin notSealed {
    admin_address = a;
  }

  //set the transaction hash of the final squiggle mint
  function setMintTX(bytes32 t) public requireAdmin notSealed {
    squiggle_mint_tx = t;
  }
  
  // admin can add a message
  function addMessage(string memory s) public requireAdmin notSealed {
    message = s;
  }

  function count_squiggles(address a ) public view returns (uint256) {
    uint256 n = 0;
    
    // caculate deduped set of addresses that including msg.sender
    // and any delegate.cash registered vault addresses

    IDelegationRegistry.DelegationInfo[] memory dList;
    dList = delegatecash.getDelegationsByDelegate(a);
    address[] memory aList = new address[](dList.length + 1);
    aList[0] = a;
    uint alen=1;
    
    for (uint256 i=0;i<dList.length;i++) {
      address b = dList[i].vault;
      bool exists = false;
      for (uint k=0;k<alen;k++) {
	if (b==aList[k]) {exists = true; break;}
      }
      if (exists) continue;
      aList[alen] = b;
      alen++;
    }

    //count number of squiggles owned by each vault address
    for (uint i=0;i<alen;i++) {
      uint256[] memory b = squiggle.tokensOfOwner(aList[i]);

      for (uint j=0;j<b.length;j++)
	if (b[j] < 10000) n+= 1;
    }
    
    return n;
  }

  function vault_with_most_squiggles(address a ) public view returns (address mAddress, uint256 mCount) {
    //iterate through all delegate.cash registered vaults for this address and pick the one
    // with the most squiggles
    mAddress = a;
    uint256[] memory slist = squiggle.tokensOfOwner(a);
    mCount = 0;
    
    for (uint j=0;j<slist.length;j++)
      if (slist[j] < 10000) mCount += 1;

    IDelegationRegistry.DelegationInfo[] memory dList;
    dList = delegatecash.getDelegationsByDelegate(a);
    
    for (uint256 i=0;i<dList.length;i++) {
      address b = dList[i].vault;
      slist = squiggle.tokensOfOwner(b);
      
      uint n = 0;
      for (uint j=0;j<slist.length;j++)
	if (slist[j] < 10000) n+= 1;
      
      if (n > mCount) {
	mCount = n;
	mAddress = b;
      }
    }

    return (mAddress,mCount);
  }

  function inscribeAddress() public payable notSealed {
    require(msg.value >= cost,"Must send minimum cost (will be refunded)");
    require(has_inscribed[msg.sender]==false, "Already inscribed");

    has_inscribed[msg.sender] = true;

    //inscribe with the delegated vault with most squiggles 
    address a;
    uint n;
    (a,n) = vault_with_most_squiggles(msg.sender);
    
    inscriptions[num] = a;

    //optionally count the number of squiggles owned at the time inscription
    num_squiggles[a] = n;
    
    num++;
    emit eInscribe(a);
  
    //refund any amount sent
    if (msg.value > 0) {
      payable(msg.sender).transfer(msg.value);
    }
  }





  function count_squiggles_unique(address a ) public view returns (uint256) {
    uint256 n = 0;
    
    // caculate deduped set of addresses that including msg.sender
    // and any delegate.cash registered vault addresses

    IDelegationRegistry.DelegationInfo[] memory dList;
    dList = delegatecash.getDelegationsByDelegate(a);
    address[] memory aList = new address[](dList.length + 1);
    aList[0] = a;
    uint alen=1;
    
    for (uint256 i=0;i<dList.length;i++) {
      address b = dList[i].vault;
      bool exists = false;
      for (uint k=0;k<alen;k++) {
	if (b==aList[k]) {exists = true; break;}
      }
      if (exists) continue;
      aList[alen] = b;
      alen++;
    }

    //count number of squiggles owned by each vault address
    for (uint i=0;i<alen;i++) {
      uint256[] memory b = squiggle.tokensOfOwner(aList[i]);

      for (uint j=0;j<b.length;j++)
	if (b[j] < 10000 && !squiggle_inscribed[b[j]]) n+= 1;
    }
    
    return n;
  }

  function vault_with_most_squiggles_unique(address a ) public view returns (address mAddress, uint256 mCount) {
    //iterate through all delegate.cash registered vaults for this address and pick the one
    // with the most squiggles
    mAddress = a;
    uint256[] memory slist = squiggle.tokensOfOwner(a);
    mCount = 0;
    
    for (uint j=0;j<slist.length;j++)
      if (slist[j] < 10000 && !squiggle_inscribed[slist[j]]) mCount += 1;

    IDelegationRegistry.DelegationInfo[] memory dList;
    dList = delegatecash.getDelegationsByDelegate(a);
    
    for (uint256 i=0;i<dList.length;i++) {
      address b = dList[i].vault;
      slist = squiggle.tokensOfOwner(b);
      
      uint n = 0;
      for (uint j=0;j<slist.length;j++)
	if (slist[j] < 10000 && !squiggle_inscribed[slist[j]]) n+= 1;
      
      if (n > mCount) {
	mCount = n;
	mAddress = b;
      }
    }

    return (mAddress,mCount);
  }

  function inscribeAddress_unique() public payable notSealed {
    require(msg.value >= cost,"Must send minimum cost (will be refunded)");
    require(has_inscribed[msg.sender]==false, "Already inscribed");

    has_inscribed[msg.sender] = true;

    //inscribe with the delegated vault with most squiggles 
    address a;
    uint n;
    (a,n) = vault_with_most_squiggles(msg.sender);

    uint256[] memory slist = squiggle.tokensOfOwner(a);

    //mark off which squiggles have been accounted for
    for (uint j=0;j<slist.length;j++) {
      if (slist[j] < 10000 && !squiggle_inscribed[slist[j]]) squiggle_inscribed[slist[j]] = true;
    }
    
    inscriptions[num] = a;

    //optionally count the number of squiggles owned at the time inscription
    num_squiggles[a] = n;
    
    num++;
    emit eInscribe(a);
  
    //refund any amount sent
    if (msg.value > 0) {
      payable(msg.sender).transfer(msg.value);
    }
  }

  
}