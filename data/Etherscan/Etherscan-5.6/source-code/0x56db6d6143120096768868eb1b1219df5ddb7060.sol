// SPDX-License-Identifier: MIT
// UNKNOWN METAVERSE
// https://ShadowShark.xyz
// ShadowShark Mail: help@shadowshark.xyz
// All Rights Reserved © ShadowShark.
//███████╗██╗  ██╗ █████╗ ██████╗  ██████╗ ██╗    ██╗███████╗██╗  ██╗ █████╗ ██████╗ ██╗  ██╗
//██╔════╝██║  ██║██╔══██╗██╔══██╗██╔═══██╗██║    ██║██╔════╝██║  ██║██╔══██╗██╔══██╗██║ ██╔╝
//███████╗███████║███████║██║  ██║██║   ██║██║ █╗ ██║███████╗███████║███████║██████╔╝█████╔╝ 
//╚════██║██╔══██║██╔══██║██║  ██║██║   ██║██║███╗██║╚════██║██╔══██║██╔══██║██╔══██╗██╔═██╗ 
//███████║██║  ██║██║  ██║██████╔╝╚██████╔╝╚███╔███╔╝███████║██║  ██║██║  ██║██║  ██║██║  ██╗
pragma solidity ^0.7.0;
interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721.sol)
pragma solidity ^0.7.0;
interface IERC721 is IERC165 {
    event Transfer(address indexed from,address indexed to,uint256 indexed tokenId);
    event Approval(address indexed owner,address indexed approved,uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner,address indexed operator,bool approved);
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(address from,address to,uint256 tokenId) external;
    function safeTransferFrom(address from,address to,uint256 tokenId,bytes calldata data) external;
    function transferFrom(address from,address to,uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function setApprovalForAll(address operator, bool _approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}
// OpenZeppelin Contracts v4.4.1 (token/ERC721/IERC721Receiver.sol)
pragma solidity ^0.7.0;
interface IERC721Receiver {
    function onERC721Received(address operator,address from,uint256 tokenId,bytes calldata data) external returns (bytes4);
}
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Metadata.sol)
pragma solidity ^0.7.0;
interface IERC721Metadata is IERC721 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)
pragma solidity ^0.7.0;
abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)
pragma solidity ^0.7.0;
library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;assembly {size := extcodesize(account)}
        return size > 0;
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount);
        (bool success, ) = recipient.call{value: amount}("");
        require(success);
    }
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data);
    }
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }
    function functionCallWithValue(address target,bytes memory data,uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target,data,value);
    }
    function functionCallWithValue(address target,bytes memory data,uint256 value,string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value);
        require(isContract(target));
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target,data);
    }
    function functionStaticCall(address target,bytes memory data,string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target));
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionDelegateCall(target,data);
    }
    function functionDelegateCall(address target,bytes memory data,string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target));
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function verifyCallResult(bool success,bytes memory returndata,string memory errorMessage) internal pure returns (bytes memory) {
        if (success) {return returndata;} else {
            if (returndata.length > 0) {assembly {
            let returndata_size := mload(returndata)
            revert(add(32, returndata), returndata_size)}
            } else {revert(errorMessage);}}}
}
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)
pragma solidity ^0.7.0;
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)
pragma solidity ^0.7.0;
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    function toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {return "0";}
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {digits++;temp /= 10;}
        bytes memory buffer = new bytes(digits);
        while (value != 0) {digits -= 1;buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));value /= 10;}
        return string(buffer);
    }
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {return "0x00";}
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {length++;temp >>= 8;}
        return toHexString(value, length);
    }
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory)
    {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}
// OpenZeppelin Contracts v4.4.1 (token/ERC721/extensions/IERC721Enumerable.sol)
pragma solidity ^0.7.0;
interface IERC721Enumerable is IERC721 {
    function totalSupply() external view returns (uint256);    
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);
    function tokenByIndex(uint256 index) external view returns (uint256);
}
pragma solidity ^0.7.0;
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b);
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {return 0;}
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b);
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b);
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}
pragma solidity ^0.7.0;
library Counters {
    using SafeMath for uint256;
    struct Counter {
        uint256 _value; // default: 0
    }
    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }
    function increment(Counter storage counter) internal {
        counter._value += 1;
    }
    function decrement(Counter storage counter) internal {
        counter._value = counter._value.sub(1);
    }
    function amount(Counter storage counter, uint256 _value) internal {
        counter._value += _value;
    }
}
pragma solidity ^0.7.0;
contract ERC721U is Context,ERC165,IERC721,IERC721Metadata,IERC721Enumerable {
  using Address for address;
  using Strings for uint256;

  struct TokenOwnership {
    address addr;
    uint64 startTimestamp;
  }

  struct AddressData {
    uint128 balance;
    uint128 numberMinted;
  }

  uint256 private currentIndex = 0;
  uint256 internal immutable collectionSize;
  uint256 internal immutable maxBatchSize;
  string private _name;
  string private _symbol;
  mapping(uint256 => TokenOwnership) private _ownerships;
  mapping(address => AddressData) private _addressData;
  mapping(uint256 => address) private _tokenApprovals;
  mapping(address => mapping(address => bool)) private _operatorApprovals;

constructor(string memory name_,string memory symbol_,uint256 maxBatchSize_,uint256 collectionSize_) {
    require(collectionSize_ > 0);
    require(maxBatchSize_ > 0);
    _name = name_;
    _symbol = symbol_;
    maxBatchSize = maxBatchSize_;
    collectionSize = collectionSize_;
  }

  function totalSupply() public view override returns (uint256) {
    return currentIndex;
  }
  function tokenByIndex(uint256 index) public view override returns (uint256) {
    require(index < totalSupply());
    return index;
  }
  function tokenOfOwnerByIndex(address owner, uint256 index) public view override returns (uint256) {
    require(index < balanceOf(owner));
    uint256 numMintedSoFar = totalSupply();
    uint256 tokenIdsIdx = 0;
    address currOwnershipAddr = address(0);
    for (uint256 i = 0; i < numMintedSoFar; i++) {
      TokenOwnership memory ownership = _ownerships[i];
      if (ownership.addr != address(0)) {
        currOwnershipAddr = ownership.addr;
      }
      if (currOwnershipAddr == owner) {
        if (tokenIdsIdx == index) {
          return i;
        }
        tokenIdsIdx++;
      }
    }
    revert("unable to get token of owner by index");
  }
  function tokenIdsOfOwner(address owner) public view returns (uint256[] memory) {
    uint256 balance = balanceOf(owner);
    uint256[] memory tokenIds = new uint256[](balance);
    uint256 tokenIndex = 0;
    for (uint256 i = 0; i < totalSupply(); i++) {
        uint256 tokenId = tokenByIndex(i);
        if (ownerOf(tokenId) == owner) {
            tokenIds[tokenIndex] = tokenId;
            tokenIndex++;
        }
    }

    return tokenIds;
}
  function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165)
    returns (bool)
  {
    return
      interfaceId == type(IERC721).interfaceId ||
      interfaceId == type(IERC721Metadata).interfaceId ||
      interfaceId == type(IERC721Enumerable).interfaceId ||
      super.supportsInterface(interfaceId);
  }
  function balanceOf(address owner) public view override returns (uint256) {
    require(owner != address(0));
    return uint256(_addressData[owner].balance);
  }
  function _numberMinted(address owner) internal view returns (uint256) {
    require(owner != address(0));
    return uint256(_addressData[owner].numberMinted);
  }
  function ownershipOf(uint256 tokenId) internal view returns (TokenOwnership memory)
  {
    require(_exists(tokenId));
    uint256 lowestTokenToCheck;
    if (tokenId >= maxBatchSize) {
      lowestTokenToCheck = tokenId - maxBatchSize + 1;
    }

    for (uint256 curr = tokenId; curr >= lowestTokenToCheck; curr--) {
      TokenOwnership memory ownership = _ownerships[curr];
      if (ownership.addr != address(0)) {
        return ownership;
      }
    }
    revert("ERC721A: unable to determine the owner of token");
  }
  function ownerOf(uint256 tokenId) public view override returns (address) {
    return ownershipOf(tokenId).addr;
  }
  function name() public view virtual override returns (string memory) {
    return _name;
  }
  function symbol() public view virtual override returns (string memory) {
    return _symbol;
  }
  function tokenURI(uint256 tokenId) public view virtual override
    returns (string memory) {
    require(_exists(tokenId));
    string memory baseURI = _baseURI();
    return
      bytes(baseURI).length > 0
        ? string(abi.encodePacked(baseURI, tokenId.toString(), ".json"))
        : "";
  }
  function _baseURI() internal view virtual returns (string memory) {
    return "";
  }
  function approve(address to, uint256 tokenId) public override {
    address owner = ownerOf(tokenId);
    require(to != owner);
    require(_msgSender() == owner || isApprovedForAll(owner, _msgSender()));
    _approve(to, tokenId, owner);
  }
  function getApproved(uint256 tokenId) public view override returns (address) {
    require(_exists(tokenId));
    return _tokenApprovals[tokenId];
  }
  function setApprovalForAll(address operator, bool approved) public override {
    require(operator != _msgSender());
    _operatorApprovals[_msgSender()][operator] = approved;
    emit ApprovalForAll(_msgSender(), operator, approved);
  }
  function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
    return _operatorApprovals[owner][operator];
  }
  function transferFrom(address from,address to,uint256 tokenId) public override {
    _transferAssetbyOrder(from, to, tokenId);
  }
  function safeTransferFrom(address from,address to,uint256 tokenId) public override {
    safeTransferFrom(from, to, tokenId, "");
  }
  function safeTransferFrom(address from,address to,uint256 tokenId,bytes memory _data) public override {
    _transferAssetbyOrder(from, to, tokenId);
    require(_checkOnERC721Received(from, to, tokenId, _data));
  }
  function _exists(uint256 tokenId) internal view returns (bool) {
    return tokenId < currentIndex;
  }
  function _safeMint(address to, uint256 quantity) internal {
    _safeMint(to, quantity, "");
  }
  function _safeMint(address to,uint256 quantity,bytes memory _data) internal {
    uint256 startTokenId = currentIndex;
    require(to != address(0), "ERC721A: mint to the zero address");
    require(!_exists(startTokenId), "ERC721A: token already minted");
    _beforeTokenTransfers(address(0), to, startTokenId, quantity);
    AddressData memory addressData = _addressData[to];
    _addressData[to] = AddressData(
      addressData.balance + uint128(quantity),
      addressData.numberMinted + uint128(quantity)
    );
    _ownerships[startTokenId] = TokenOwnership(to, uint64(block.timestamp));
    uint256 updatedIndex = startTokenId;
    for (uint256 i = 0; i < quantity; i++) {
      emit Transfer(address(0), to, updatedIndex);
      require(
        _checkOnERC721Received(address(0), to, updatedIndex, _data),
        "ERC721A: transfer to non ERC721Receiver implementer"
      );
      updatedIndex++;
    }
    currentIndex = updatedIndex;
    _afterTokenTransfers(address(0), to, startTokenId, quantity);
  }
  function _transferAssetbyOrder(address from,address to,uint256 tokenId) private {
    TokenOwnership memory prevOwnership = ownershipOf(tokenId);
    bool isApprovedOrOwner = (_msgSender() == prevOwnership.addr ||
      getApproved(tokenId) == _msgSender() ||
      isApprovedForAll(prevOwnership.addr, _msgSender()));
    require(isApprovedOrOwner);
    require(prevOwnership.addr == from);
    require(to != address(0));
    _beforeTokenTransfers(from, to, tokenId, 1);
    _approve(address(to), tokenId, prevOwnership.addr);
    _addressData[from].balance -= 1;
    _addressData[to].balance += 1;
    _ownerships[tokenId] = TokenOwnership(to, uint64(block.timestamp));
    uint256 nextTokenId = tokenId + 1;
    if (_ownerships[nextTokenId].addr == address(0)) {
      if (_exists(nextTokenId)) {
        _ownerships[nextTokenId] = TokenOwnership(
          prevOwnership.addr,
          prevOwnership.startTimestamp
        );
      }
    }
    emit Transfer(from, to, tokenId);
    _afterTokenTransfers(from, to, tokenId, 1);
  }
  function _approve(address to,uint256 tokenId,address owner) private {
    _tokenApprovals[tokenId] = to;
    emit Approval(owner, to, tokenId);
  }

  uint256 public nextOwnerToExplicitlySet = 0;

  function _setOwnersExplicit(uint256 quantity) internal {
    uint256 oldNextOwnerToSet = nextOwnerToExplicitlySet;
    require(quantity > 0);
    uint256 endIndex = oldNextOwnerToSet + quantity - 1;
    if (endIndex > collectionSize - 1) {
      endIndex = collectionSize - 1;
    }
    require(_exists(endIndex));
    for (uint256 i = oldNextOwnerToSet; i <= endIndex; i++) {
      if (_ownerships[i].addr == address(0)) {
        TokenOwnership memory ownership = ownershipOf(i);
        _ownerships[i] = TokenOwnership(
          ownership.addr,
          ownership.startTimestamp
        );
      }
    }
    nextOwnerToExplicitlySet = endIndex + 1;
  }
  function _checkOnERC721Received(address from,address to,uint256 tokenId,bytes memory _data) private returns (bool) {
    if (to.isContract()) {
      try
        IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data)
      returns (bytes4 retval) {
        return retval == IERC721Receiver(to).onERC721Received.selector;
      } catch (bytes memory reason) {
        if (reason.length == 0) {
          revert("ERC721A: transfer to non ERC721Receiver implementer");
        } else {
          assembly {
            revert(add(32, reason), mload(reason))
          }
        }
      }
    } else {
      return true;
    }
  }
  function _beforeTokenTransfers(address from,address to,uint256 startTokenId,uint256 quantity) internal virtual {}
  function _afterTokenTransfers(address from,address to,uint256 startTokenId,uint256 quantity) internal virtual {}
// Burns the  UAsset token when wear is 100%    
  function _burn(uint256 tokenId) internal virtual {
   TokenOwnership memory prevOwnership = ownershipOf(tokenId);
   bool isApprovedOrOwner = (_msgSender() == prevOwnership.addr ||
      getApproved(tokenId) == _msgSender() ||
      isApprovedForAll(prevOwnership.addr, _msgSender()));
    require(isApprovedOrOwner);
     _beforeTokenTransfers(prevOwnership.addr, address(0), tokenId, 1);
    // Clear approvals from the previous owner
     _approve(address(0), tokenId, prevOwnership.addr);
    // Ensure the balance and numberBurned cannot underflow
     require(_addressData[prevOwnership.addr].balance >= 1, "ERC721: balance underflow");
    // Decrement the balance and numberBurned
     _addressData[prevOwnership.addr].balance -= 1;
    // Keep track of who burnt the token, and when is it burned.
     _ownerships[tokenId].addr = prevOwnership.addr;
     _ownerships[tokenId].startTimestamp = uint64(block.timestamp);
    // If the ownership slot of tokenId+1 is not explicitly set, that means the burn initiator owns it.
    // Set the slot of tokenId+1 explicitly in storage to maintain correctness for ownerOf(tokenId+1) calls.
     uint256 nextTokenId = tokenId + 1;
    if (_ownerships[nextTokenId].addr == address(0)) {
        if (_exists(nextTokenId)) {
            _ownerships[nextTokenId].addr = prevOwnership.addr;
            _ownerships[nextTokenId].startTimestamp = prevOwnership.startTimestamp;
        }
    }
        emit Transfer(prevOwnership.addr, address(0), tokenId);
        _afterTokenTransfers(prevOwnership.addr, address(0), tokenId, 1);
    }
}
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)
pragma solidity ^0.7.0;
abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    constructor() {
        _transferOwnership(_msgSender());
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "You not the Owner!");
        _;
    }
    function renounceOwnership() internal virtual onlyOwner {
        _transferOwnership(address(0));
    }
    function transferOwnership(address newOwner) external virtual onlyOwner {
        require(newOwner != address(0));
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
// U.Asset Contract.
pragma solidity 0.7.0;
contract UAssets is ERC721U, Ownable {
    using Counters for Counters.Counter;
    using Strings for uint256;
    uint256 public MAX_SUPPLY = 1000000; // Max Assets of smart contract.
    uint256 public MAX_MINTS = 1; // Max Mint on PublicMint.
    string public baseURI = "https://shadowshark.xyz/nft/";
    string public baseExtension = ".json";
    bool public paused = true; // Public mint Pause. This function for collections creators.
// Mappings Shop & MoneyGame Controllers.        
    mapping(address => bool) private shopControllers;
    Counters.Counter private _totalTokens;
// Shop Controller modifer for in game NFT marketplace.    
    modifier onlyShopController() {
        require(isShopController(msg.sender), "Restricted to ShopController");
        _;
    }
// Pause / Unpuse Modifirs.
    modifier whenNotPaused() {
        require(paused, "Public Mint not paused");
        _;
    }
    modifier whenPaused() {
        require(!paused, "Public Mint is paused");
        _;
    }
// Events.
    event Paused(); // Paused Public Mint event.
    event Unpaused(); // Unpaused Public Mint event.
    event OrderInitialized(address BuyerAddress, uint256 DepositAmount, address seller, uint256 AssetPrice, uint256 tokenId, bool paid);
    event Orderfullfilled(address Seller, address Buyer, uint256 price, uint256 AssetId, bool OrderSuccess);
    event PaidOrder(address Seller, uint256 price, uint256 AssetId, bool paid);
    event ShopControllerAdded(address indexed account);
    event ShopControllerRemoved(address indexed account);    
// Constructor ERC721U.shark
constructor() ERC721U("Unknwon_Assets", "U.Assets", 1000000, 1) {}
// adminMint Functions. Gas price optimization for multiple mints.
    function adminMint(uint256 numTokens) public payable onlyOwner {
        _safeMint(msg.sender, numTokens);
    }
// Public Mint Function. Gas price optimization for multiple mints if required.
    function PublicMint(uint256 numTokens) public payable {
        require(!paused, "Public Mint paused");
        require(MAX_MINTS >= numTokens, "Excess max per paid tx");
        _safeMint(msg.sender, numTokens);
    }    
// Buy Asset from shop.
    function initializeOrder(address seller, uint256 price, uint256 tokenId) external payable {
        require(msg.value >= price);
        bool Paid = true;
        emit OrderInitialized(msg.sender, msg.value, seller, price, tokenId, Paid);     
    }    
// Execute order function.
    function execOrder(address payable seller, address buyer, uint256 amount, uint256 tokenId) external onlyShopController {
        seller.transfer(amount);
        bool paid = true;
        emit PaidOrder(seller, amount, tokenId, paid);
        transferFrom(seller, buyer, tokenId);
        bool OrderSuccess = true;
        emit Orderfullfilled(seller, buyer, amount, tokenId, OrderSuccess);
    }                
// Add Shop controller (wallet). onlyShopController*
    function addShopController(address account) external onlyOwner {
        require(account != address(0));
        shopControllers[account] = true;
        emit ShopControllerAdded(account);
    }
// Remove Shop controller (wallet).
    function removeShopController(address account) external onlyOwner {
        require(account != address(0));
        shopControllers[account] = false;
        emit ShopControllerRemoved(account);
    }
// check if address is Shop Controller.
    function isShopController(address account) public view returns (bool) {
        return shopControllers[account];
    }
// Full Balance function. return full balance of this contract
    function FullBalance() external view returns (uint256) {
        return address(this).balance;
    }
// Set token URI function. set uri to specific token by id.
    function setTokenURI(uint256 tokenId, string memory _tokenURI) public onlyOwner {
        require(_exists(tokenId));
        setTokenURI(tokenId, _tokenURI);
    }
// Set Base URI. example : https://shadowshark.xyz/
    function setBaseURI(string memory newBaseURI) public onlyOwner {
        baseURI = newBaseURI;
    }
// Return Base URI.
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }
// Pause PublicMint Function.
    function pausePublicMint() public onlyOwner whenPaused {
        paused = true;
        emit Paused();
    }
// Unpaused PublicMint Function.
    function unpausePublicMint() public onlyOwner whenNotPaused {
        paused = false;
        emit Unpaused();
    }
    function BurnUAsset(uint256 tokenId) public onlyOwner {  
       _burn(tokenId);
    }
    function SharkPay(uint256 amount) public onlyOwner {  
    msg.sender.transfer(amount);
}
}