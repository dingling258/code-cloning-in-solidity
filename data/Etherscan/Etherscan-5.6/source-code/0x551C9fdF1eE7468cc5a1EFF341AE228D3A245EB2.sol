{"IERC165.sol":{"content":"// SPDX-License-Identifier: MIT\npragma solidity \u003e=0.8.20;\n\n// ERC-165 allows for detection of methods in smart contracts\n// (Seeks 4 bytes of a Keccack hash of the method\u0027s name to exist.)\ninterface IERC165 {\n    function supportsInterface(bytes4 interfaceID) external view returns (bool);\n}\n"},"IERC721.sol":{"content":"// SPDX-License-Identifier: MIT\npragma solidity \u003e=0.8.20;\n\n// ERC-721 interface built with information from here:\n// https://eips.ethereum.org/EIPS/eip-721\n// Only the methods needed must be present here so that \"type()\" can work properly, or...\n// .. we use this: 0x80ac58cd.\ninterface IERC721 {\n    // return the number of tokens owned by account\n    function balanceOf(address owner) external view returns (uint256);\n    // return owner\u0027s address for specific token\n    function ownerOf(uint256 tokenId) external view returns (address);\n    // transfers token while checking from/to addresses being non-zero\n    // (token must be owned by\"from\" and Tx sender must be \"from\" or authorized)\n    function safeTransferFrom(address fromAddr, address toAddr, uint256 tokenID) external returns (bool);\n    // same as safe transfer with no addr!=zero checks\n    function transferFrom(address fromAddr, address toAddr, uint256 tokenID) external returns (bool);\n    // stores an approval for \"operatorAddr\" to be able to send \"tokenID\" to anyone\n    function approve(address operatorAddr, uint256 tokenID) external returns (bool);\n    // returns the address that is approved to send a tokenID (a pressumed \"operatorAddr\")\n    function getApproved(uint256 tokenID) external view returns (address);\n    // function that sets approval for all tokens owned by an address to be maanged by an operator\n    function setApprovalForAll(address operatorAddr, bool _approved) external returns (bool);\n    // function that checks if an operator is approved for managing all tokens\n    function isApprovedForAll(address ownerAddr, address operatorAddr) external view returns (bool);\n    // function similar to safe-transfer with a payload added\n    function safeTransferFrom(address fromAddr, address toAddr, uint256 tokenId, bytes calldata data) external returns (bool);\n\n    event Transfer(address indexed fromAddr, address indexed toAddr, uint256 tokenID);\n    event Approval(address indexed ownerAddr, address indexed operatorAddr, uint256 indexed tokeID);\n    event ApprovalForAll(address indexed ownerAddr, address indexed operatorAddr, bool approved);\n}\n\n// This is needed for the \"safeTransfer\" methods (a type-cast is done)\ninterface IERC721Receiver {\n    function onERC721Received(\n        address operatorAddr,\n        address fromAddr,\n        uint256 tokenId,\n        bytes calldata data\n    ) external returns (bytes4);\n}\n\n// Only the methods needed must be present here so that \"type()\" can work properly, or...\n// .. we use this: 0x5b5e139f. No query of this type is expected. The token I am building\n// has automatic getters for the name and the symbol.\ninterface IERC721Metadata {\n    function name() external view returns (string memory);\n\n    function symbol() external view returns (string memory);\n\n    // @notice A distinct Uniform Resource Identifier (URI) for a given asset.\n    // @dev Throws if `_tokenId` is not a valid NFT. URIs are defined in RFC\n    //  3986. The URI may point to a JSON file that conforms to the \"ERC721\n    //  Metadata JSON Schema\".\n    function tokenURI(uint256 _tokenId) external view returns (string memory);\n}\n"},"INcard.sol":{"content":"// SPDX-License-Identifier: MIT\npragma solidity \u003e=0.8.20;\n\nimport \"./IERC721.sol\"; \nimport \"./IERC165.sol\";\n\ncontract INbusinesscard is IERC721, IERC721Metadata, IERC165 {\n    using SafeMath for uint256;\n\n    string public name;\n    string public symbol;\n    uint256 public num;\n    string uri;\n    address private inAddr;\n    address private opAddr;\n    bool private lock;\n\n    mapping(address =\u003e uint) balances;\n    mapping(uint256 =\u003e address) owners;\n    mapping(uint256 =\u003e address) approvals;\n    mapping(address =\u003e mapping(address =\u003e bool)) allApprovals;\n\n    //event Log(string message);\n    //event ContractDestroyed(string message);\n\n    constructor()  {\n        inAddr = 0x27c579aa6E1835f448616728a0eF1a86275b5aB7; // nompelis.eth\n        opAddr = 0xAC557bBf7C4A729Bc27CAf1aD7c4b4289acaeF92;\n        lock = false;\n        name = \"Ioannis Nompelis\";\n        symbol = \"INETH\";\n        uri = \"http://nobelware.com/~nompelis/ethereum_card.json\";\n        num = 0;\n    }\n\n    // decorators to guard against bad behaviour\n    modifier guardReentrancy() {\n        require(lock == false,\"No re-entrancy!\");\n        lock = true;\n        _;\n        lock = false;\n        //emit Log(\"UNLOCKED\");\n    }\n\n    modifier isOwner() {\n        require(msg.sender == inAddr,\"Only the owner can do this!\");\n        //emit Log(\"ISMYSELF Passed\");\n        _;\n    }\n\n    modifier isOperator() {\n        require(msg.sender == opAddr,\"Only the operator can do this!\");\n        //emit Log(\"OPERATORSHIP Passed\");\n        _;\n    }\n\n    modifier isTokenOwner(address addr, uint256 tokenId) {\n        require(addr == owners[tokenId],\"Sender is not this token\u0027s owner!\");\n        //emit Log(\"OWNERSHIP Passed\");\n        _;\n    }\n\n    modifier addressSafety(address addr) {\n        require(addr != address(0),\"Address is zero\");\n        //emit Log(\"ADDRESS SAFETY Passed\");\n        _;\n    }\n\n    modifier validityCheck(address fromAddr, address toAddr, uint256 tokenId) {\n        require(tokenId \u003e 0 \u0026\u0026 tokenId \u003c= num,\"Token index out of range\");\n        address tokenOwner = owners[tokenId];\n        require(tokenOwner == fromAddr,\"Incorrect owner\");\n        if(msg.sender != tokenOwner ) {\n            if(allApprovals[tokenOwner][msg.sender] != true) {\n                require(approvals[tokenId] == msg.sender,\"No approval\");\n            }\n        }\n        //emit Log(\"VALIDITY CHECK Passed\");\n        _;\n    }\n\n    // method of IERC-165\n    function supportsInterface(bytes4 interfaceId) external pure returns (bool) {\n        return interfaceId == type(IERC721).interfaceId ||\n               interfaceId == type(IERC165).interfaceId;\n    }\n\n    // getter for the ERC token metadata URI\n    function tokenURI(uint256 tokenId) external view returns (string memory) {\n        return uri;\n    }\n\n    // getters of ERC-721\n    function balanceOf(address owner) external override view returns (uint256) {\n        return balances[owner];\n    }\n\n    function ownerOf(uint256 tokenID) external override view returns (address) {\n        return owners[tokenID];\n    }\n\n    function isApprovedForAll(address ownerAddr, address approvedAddr) external view returns (bool) {\n        return allApprovals[ownerAddr][approvedAddr];\n    }\n\n    function getApproved(uint256 tokenId) external view returns (address) {\n        require(tokenId \u003e 0 \u0026\u0026 tokenId \u003c= num,\"Token index out of range\");\n        require(owners[tokenId] != address(0), \"Black holed!\");\n        return approvals[tokenId];\n    }\n\n    // transfers and approvals (of ERC-721)\n    function safeTransferFrom(address fromAddr, address toAddr, uint256 tokenId) external override\n    guardReentrancy()\n    addressSafety(toAddr)\n    validityCheck(fromAddr,toAddr,tokenId) returns (bool) {\n        require(toAddr.code.length == 0 ||\n                   IERC721Receiver(toAddr).onERC721Received(msg.sender,fromAddr,tokenId,\"\") ==\n                   IERC721Receiver.onERC721Received.selector,\n               \"Recipient issue\");\n        insideTransfer(fromAddr,toAddr,tokenId);\n        return true;\n    }\n\n    function safeTransferFrom(address fromAddr, address toAddr, uint256 tokenId, bytes calldata data) external override\n    guardReentrancy()\n    addressSafety(toAddr)\n    validityCheck(fromAddr,toAddr,tokenId) returns (bool) {\n        require(toAddr.code.length == 0 ||\n                   IERC721Receiver(toAddr).onERC721Received(msg.sender,fromAddr,tokenId,data) ==\n                   IERC721Receiver.onERC721Received.selector,\n               \"Recipient issue\");\n        insideTransfer(fromAddr,toAddr,tokenId);\n        return true;\n    }\n\n    function transferFrom(address fromAddr, address toAddr, uint256 tokenId) external override\n    guardReentrancy()\n    validityCheck(fromAddr,toAddr,tokenId) returns (bool) {\n        insideTransfer(fromAddr,toAddr,tokenId);\n        return true;\n    }\n\n    function approve(address approvedAddr, uint256 tokenId) external override returns (bool) {\n        require(tokenId \u003e 0 \u0026\u0026 tokenId \u003c= num,\"Token index out of range\");\n        address tokenOwner = owners[tokenId];\n        if(msg.sender != tokenOwner ) {\n            if(allApprovals[tokenOwner][msg.sender] != true) {\n                require(approvals[tokenId] == msg.sender,\"No approval\");\n            }\n        }\n        approvals[tokenId] = approvedAddr;\n        emit Approval(tokenOwner, approvedAddr, tokenId);\n        return true;\n    }\n\n    function setApprovalForAll(address approvedAddr, bool _approved) external returns (bool) {\n        require(approvedAddr != address(0),\"No delagating to 0!\");\n        if(_approved == true) {\n            allApprovals[msg.sender][approvedAddr] = true;\n        } else {\n            if(allApprovals[msg.sender][approvedAddr] ) delete allApprovals[msg.sender][approvedAddr];\n        }\n        emit ApprovalForAll(msg.sender, approvedAddr, _approved);\n        return true;\n    }\n\n    // functions to manage this contract\n    function changeOperator(address newAddr) external virtual isOwner() {\n        // require(newAddr != address(0),\"Invalid address\"); // not going to fuck this up myself\n        opAddr = newAddr;\n    }\n\n    function changeMetadata(string calldata metadata) external virtual isOwner() {\n        uri = metadata;\n    }\n\n    function withdraw() external virtual isOwner() { // just in case\n         require(address(this).balance \u003e 0, \"No ETH to withdraw\");\n         payable(inAddr).transfer(address(this).balance);\n    }\n\n    // functions to create and recycle tokens\n    function mint(uint256 numTokens) external virtual\n    guardReentrancy() isOwner() {\n        for (uint i = 0; i \u003c numTokens; i++) {\n            owners[++num] = opAddr;\n        }\n        balances[opAddr] = balances[opAddr].addSafe(numTokens);\n        //emit Transfer(address(0), opAddr, numTokens);\n    }\n\n    function recycle(uint256 tokenId) external payable virtual\n    guardReentrancy() isTokenOwner(msg.sender,tokenId) {\n        insideTransfer(msg.sender,inAddr,tokenId);\n    }\n\n//    function destroyContract(address payable recipient) public isOwner() {\n//        emit ContractDestroyed(\"Contract has been destroyed.\");\n//        selfdestruct(recipient);\n//    }\n\n    function insideTransfer(address fromAddr, address toAddr, uint256 tokenId) private {\n        balances[fromAddr] = balances[fromAddr].subSafe(1);\n        balances[toAddr] = balances[toAddr].addSafe(1);\n        owners[tokenId] = toAddr;\n        delete approvals[tokenId];\n        emit Transfer(fromAddr, toAddr, 1);\n    }\n\n    fallback() external guardReentrancy() {\n        revert(\"No!\");\n    }\n}\n\nlibrary SafeMath {\n    function subSafe( uint256 a, uint256 b ) internal pure returns (uint256) {\n      assert(b \u003c= a);\n      return a - b;\n    }\n\n    function addSafe( uint256 a, uint256 b ) internal pure returns (uint256) {\n      uint256 c = a + b;\n      assert(c \u003e= a);\n      return c;\n    }\n}\n"}}