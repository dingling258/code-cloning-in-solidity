{"ETFSwap.sol":{"content":"// SPDX-License-Identifier: MIT\npragma solidity 0.8.19;\n\nimport \"./IERC20.sol\";\n// Main contract for the ETFSwap token\ncontract ETFSwap {\n    string public constant name = \"ETFSwap\";\n    string public constant symbol = \"ETFS\";\n    uint8 public constant decimals = 18;\n    uint256 public constant TOTAL_SUPPLY = 1_000_000_000 * (10 ** uint256(decimals));\n\n    // Define initial allocation constants\n    uint256 public constant PRESALE_ALLOCATION = 400_000_000 * (10 ** uint256(decimals));\n    uint256 public constant ECOSYSTEM_ALLOCATION = 240_000_000 * (10 ** uint256(decimals));\n    uint256 public constant LIQUIDITY_ALLOCATION = 120_000_000 * (10 ** uint256(decimals));\n    uint256 public constant TEAM_ALLOCATION = 60_000_000 * (10 ** uint256(decimals));\n    uint256 public constant MM_ALLOCATION = 60_000_000 * (10 ** uint256(decimals));\n    uint256 public constant CASHBACK_ALLOCATION = 50_000_000 * (10 ** uint256(decimals));\n    uint256 public constant PARTNERS_ALLOCATION = 30_000_000 * (10 ** uint256(decimals));\n    uint256 public constant COMMUNITY_REWARDS_ALLOCATION = 40_000_000 * (10 ** uint256(decimals));\n\n   // Tax rates\n    uint8 public sellTaxRate; \n    uint8 public buyTaxRate; \n\n    // Address of the contract owner\n    address public owner;\n    \n    // Mapping to store token balances of addresses\n    mapping(address =\u003e uint256) balances;\n\n    // Mapping to store allowances for token transfers\n    mapping(address =\u003e mapping(address =\u003e uint256)) allowed;\n\n    // Liquidity Pair Address\n    address public liquidityPairAddress;\n\n    // Constructor to initialize contract and mint initial allocations\n    constructor() {\n        owner = msg.sender;\n        // Mint initial allocations\n        balances[msg.sender] += PRESALE_ALLOCATION;\n        balances[msg.sender] += ECOSYSTEM_ALLOCATION;\n        balances[msg.sender] += LIQUIDITY_ALLOCATION;\n        balances[msg.sender] += CASHBACK_ALLOCATION;\n        balances[msg.sender] += PARTNERS_ALLOCATION;\n        balances[msg.sender] += COMMUNITY_REWARDS_ALLOCATION;\n        balances[msg.sender] += MM_ALLOCATION;\n        balances[msg.sender] += TEAM_ALLOCATION;\n        \n        uint256 TOTAL_TOKENS_TRANSFERRED = PRESALE_ALLOCATION +\n                                 ECOSYSTEM_ALLOCATION +\n                                 LIQUIDITY_ALLOCATION +\n                                 CASHBACK_ALLOCATION +\n                                 PARTNERS_ALLOCATION +\n                                 COMMUNITY_REWARDS_ALLOCATION +\n                                 MM_ALLOCATION +\n                                 TEAM_ALLOCATION;\n        emit Transfer(address(0), msg.sender, TOTAL_TOKENS_TRANSFERRED);\n    }\n    // Modifier to restrict access to the owner\n    modifier onlyOwner() {\n        require(msg.sender == owner, \"Only the owner can call this function.\");\n        _;\n    }\n    // Function to return the total token supply\n    function totalSupply() public pure returns (uint256) {\n        return TOTAL_SUPPLY;\n    }\n\n    // Function to return the balance of the specified address\n    function balanceOf(address tokenOwner) public view returns (uint256 balance) {\n        return balances[tokenOwner];\n    }\n\n    // Function to set liquidity pair address\n    function setLiquidityPairAddress(address _liquidityPairAddress) external onlyOwner {\n        require(_liquidityPairAddress != address(0), \"Liquidity Pair can\u0027t be a null address\");\n        require(_liquidityPairAddress != liquidityPairAddress, \"New liquidity pair address is the same as the current one\");\n        liquidityPairAddress = _liquidityPairAddress;\n        emit LiquidityPairAddressSet(_liquidityPairAddress, msg.sender, block.timestamp);\n    }\n\n    // Internal function to handle token transfer\n    function _transferTokens(address from, address to, uint256 tokens) internal {\n        require(to != address(0), \"Invalid address\");\n        require(balances[from] \u003e= tokens, \"Insufficient balance\");\n        uint256 taxAmount = calculateTaxAmount(from, to, tokens);\n        uint256 transferAmount = tokens - (taxAmount);\n        balances[from] = balances[from] - (tokens);\n        balances[to] = balances[to] + (transferAmount);\n        balances[owner] = balances[owner] + (taxAmount);\n        emit Transfer(from, to, transferAmount);\n        emit Transfer(from, owner, taxAmount);\n    }\n\n    // Function to transfer tokens from the caller\u0027s account to the specified recipient\n    function transfer(address to, uint256 tokens) public returns (bool success) {\n        _transferTokens(msg.sender, to, tokens);\n        return true;\n    }\n\n    // Function to handle token transfers from one address to another using allowances\n    function transferFrom(address from, address to, uint256 tokens) public returns (bool success) {\n        require(allowed[from][msg.sender] \u003e= tokens, \"Allowance exceeded\");\n        _transferTokens(from, to, tokens);\n        allowed[from][msg.sender] = allowed[from][msg.sender] - (tokens);\n        return true;\n    }\n\n    //INCREASE ALLOWANCE\n    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {\n        require(spender != address(0), \"Invalid spender address\");\n        allowed[msg.sender][spender] += addedValue;\n        emit Approval(msg.sender, spender, allowed[msg.sender][spender]);\n        return true;\n    }\n\n    // DECREASE ALLOWANCE\n    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {\n        require(spender != address(0), \"Invalid spender address\");\n        uint256 oldValue = allowed[msg.sender][spender];\n        if (subtractedValue \u003e= oldValue) {\n            allowed[msg.sender][spender] = 0;\n        } else {\n            allowed[msg.sender][spender] -= subtractedValue;\n        }\n        emit Approval(msg.sender, spender, allowed[msg.sender][spender]);\n        return true;\n    }\n\n    // Function to calculate tax amount based on sender and recipient addresses\n    function calculateTaxAmount(address from, address to, uint256 tokens) private view returns (uint256) {\n    if (from == liquidityPairAddress) {\n        // Apply buy tax rate if the tokens are being transferred by the owner\n        return (tokens * buyTaxRate) / (100);\n    } else if (to == address(0) || to == owner || to == liquidityPairAddress) {\n        // Apply sell tax rate if the tokens are being transferred to owner, zero address, or liquidity pair\n        return (tokens * sellTaxRate) / (100);\n    } else {\n        // No tax for other cases\n        return 0;\n    }\n    }\n    \n   // Function to set the sell tax rate\n    function setSellTaxRate(uint8 newSellTaxRate) external onlyOwner {\n        require(newSellTaxRate \u003c= 25, \"Sell tax rate must be less than or equal to 25%\");\n        sellTaxRate = newSellTaxRate;\n        emit SellTaxRateSet(newSellTaxRate);\n    }\n\n    // Function to set the buy tax rate\n    function setBuyTaxRate(uint8 newBuyTaxRate) external onlyOwner {\n        require(newBuyTaxRate \u003c= 25, \"Buy tax rate must be less than or equal to 25%\");\n        buyTaxRate = newBuyTaxRate;\n        emit BuyTaxRateSet(newBuyTaxRate);\n    }\n\n    //RENOUNCE OWNERSHIP\n    function renounceOwnership() public onlyOwner {\n        emit OwnershipTransferred(owner, address(0));\n        owner = address(0);\n    }\n\n    // Events\n    event Transfer(address indexed from, address indexed to, uint256 value);\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n    event SellTaxRateSet(uint256 newSellTaxRate);\n    event BuyTaxRateSet(uint256 newBuyTaxRate);\n    event LiquidityPairAddressSet(address indexed pairAddress, address indexed setter, uint256 timestamp);\n}\n"},"IERC20.sol":{"content":"// SPDX-License-Identifier: MIT\npragma solidity 0.8.19;\n\ninterface IERC20 {\n    // Returns the total token supply\n    function totalSupply() external view returns (uint256);\n    // Returns the token balance of the specified address\n    function balanceOf(address account) external view returns (uint256);\n    // Transfers tokens from the caller\u0027s account to the specified recipient\n    function transfer(address recipient, uint256 amount) external returns (bool);\n    // Returns the remaining number of tokens that spender will be allowed to spend on behalf of owner\n    function allowance(address owner, address spender) external view returns (uint256);\n    // Sets amount as the allowance of spender over the caller\u0027s tokens\n    function approve(address spender, uint256 amount) external returns (bool);\n    // Moves amount tokens from sender to recipient using the allowance mechanism\n    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);\n    // Triggered when tokens are transferred\n    event Transfer(address indexed from, address indexed to, uint256 value);\n    // Triggered when the allowance of a spender for an owner is set by a call to approve\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n}"}}