//SPDX-License-Identifier: MIT Licensed
pragma solidity ^0.8.18;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 value) external;

    function transfer(address to, uint256 value) external;

    function transferFrom(address from, address to, uint256 value) external;

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);
}

interface AggregatorV3Interface {
    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function version() external view returns (uint256);

    function getRoundData(
        uint80 _roundId
    )
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );

    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );
}

contract Presale is Ownable {
    IERC20 public mainToken;
    IERC20 public USDT = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);
    IERC20 public USDC = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);

    AggregatorV3Interface public priceFeed;

    struct Phase {
        uint256 endTime;
        uint256 tokensToSell;
        uint256 totalSoldTokens;
        uint256 tokenPerUsdPrice;
    }
    mapping(uint256 => Phase) public phases;

    // Stats
    uint256 public totalStages;
    uint256 public currentStage;
    uint256 public totalUsers;
    uint256 public soldToken;
    uint256 public amountRaised;
    uint256 public amountRaisedUSDT;
    uint256 public amountRaisedUSDC;

    address payable public fundReceiver;


    uint256 public vestingDuration; // Vesting duration in seconds
    uint256 public vestingPercentage; // Percentage of tokens vested every period

    bool public presaleStatus;
    bool public isPresaleEnded;
    uint256 public claimStartTime;
    address[] public UsersAddresses;

    mapping(address => bool) public oldBuyer;
    struct User {
        uint256 native_balance;
        uint256 usdt_balance;
        uint256 usdc_balance;
        uint256 token_balance;
        uint256 claimed_tokens;
        uint256 last_claimed_at;
    }

    mapping(address => User) public users;

    event BuyToken(address indexed _user, uint256 indexed _amount);
    event ClaimToken(address indexed _user, uint256 indexed _amount);
    event UpdatePrice(uint256 _oldPrice, uint256 _newPrice);

    constructor(
        IERC20 _token,
        address _fundReceiver,
        uint256[] memory tokensToSell,
        uint256[] memory endTimestamps,
        uint256[] memory tokenPerUsdPrice
    ) {
        require(
            tokensToSell.length == endTimestamps.length &&
                endTimestamps.length == tokenPerUsdPrice.length,
            "tokens and duration length mismatch"
        );
        mainToken = _token;
        fundReceiver = payable(_fundReceiver);
        priceFeed = AggregatorV3Interface(
            0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        );

        for (uint256 i = 0; i < tokensToSell.length; i++) {
            phases[i].endTime = endTimestamps[i];
            phases[i].tokensToSell = tokensToSell[i];
            phases[i].tokenPerUsdPrice = tokenPerUsdPrice[i];
        }
        totalStages = tokensToSell.length;
    }

    // to get real time price of Eth
    function getLatestPrice() public view returns (uint256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        return uint256(price);
    }

    // to buy token during preSale time with Eth => for web3 use

    function buyToken() public payable {
        require(!isPresaleEnded, "Presale ended!");
        require(presaleStatus, " Presale is Paused, check back later");
        if (!oldBuyer[msg.sender]) {
            totalUsers += 1;
            UsersAddresses.push(msg.sender);
        }
        fundReceiver.transfer(msg.value);
        // Check active phase
        uint256 activePhase = activePhaseInd();
        if (activePhase != currentStage) {
            currentStage = activePhase;
        }

        uint256 numberOfTokens;
        numberOfTokens = nativeToToken(msg.value, activePhase);
        require(
            phases[currentStage].totalSoldTokens + numberOfTokens <=
                phases[currentStage].tokensToSell,
            "Phase Limit Reached"
        );
        soldToken = soldToken + (numberOfTokens);
        amountRaised = amountRaised + (msg.value);

        users[msg.sender].native_balance =
            users[msg.sender].native_balance +
            (msg.value);
        users[msg.sender].token_balance =
            users[msg.sender].token_balance +
            (numberOfTokens);
        phases[currentStage].totalSoldTokens += numberOfTokens;
        oldBuyer[msg.sender] = true;
    }

    // to buy token during preSale time with USDT => for web3 use
    function buyTokenUSDT(uint256 amount) public {
        require(!isPresaleEnded, "Presale ended!");
        require(presaleStatus, " Presale is Paused, check back later");
        if (!oldBuyer[msg.sender]) {
            totalUsers += 1;
            UsersAddresses.push(msg.sender);
        }
        USDT.transferFrom(msg.sender, fundReceiver, amount);
        // Check active phase
        uint256 activePhase = activePhaseInd();
        if (activePhase != currentStage) {
            currentStage = activePhase;
        }

        uint256 numberOfTokens;
        numberOfTokens = usdtToToken(amount, activePhase);
        require(
            phases[currentStage].totalSoldTokens + numberOfTokens <=
                phases[currentStage].tokensToSell,
            "Phase Limit Reached"
        );
        soldToken = soldToken + numberOfTokens;
        amountRaisedUSDT = amountRaisedUSDT + amount;

        users[msg.sender].usdt_balance += amount;

        users[msg.sender].token_balance =
            users[msg.sender].token_balance +
            numberOfTokens;
        phases[currentStage].totalSoldTokens += numberOfTokens;
        oldBuyer[msg.sender] = true;
    }

    // to buy token during preSale time with USDc => for web3 use
    function buyTokenUSDC(uint256 amount) public {
        require(!isPresaleEnded, "Presale ended!");
        require(presaleStatus, " Presale is Paused, check back later");
        if (!oldBuyer[msg.sender]) {
            totalUsers += 1;
            UsersAddresses.push(msg.sender);
        }
        USDC.transferFrom(msg.sender, fundReceiver, amount);
        // Check active phase
        uint256 activePhase = activePhaseInd();
        if (activePhase != currentStage) {
            currentStage = activePhase;
        }

        uint256 numberOfTokens;
        numberOfTokens = usdtToToken(amount, activePhase);
        require(
            phases[currentStage].totalSoldTokens + numberOfTokens <=
                phases[currentStage].tokensToSell,
            "Phase Limit Reached"
        );
        soldToken = soldToken + numberOfTokens;
        amountRaisedUSDC = amountRaisedUSDC + amount;

        users[msg.sender].usdc_balance += amount;

        users[msg.sender].token_balance =
            users[msg.sender].token_balance +
            (numberOfTokens);
        phases[currentStage].totalSoldTokens += numberOfTokens;
        oldBuyer[msg.sender] = true;
    }

    function activePhaseInd() public view returns (uint256) {
        if (block.timestamp < phases[currentStage].endTime) {
            if (
                phases[currentStage].totalSoldTokens <
                phases[currentStage].tokensToSell
            ) {
                return currentStage;
            } else {
                return currentStage + 1;
            }
        } else {
            return currentStage + 1;
        }
    }

    function getPhaseDetail(
        uint256 phaseInd
    )
        external
        view
        returns (
            uint256 tokenToSell,
            uint256 soldTokens,
            uint256 priceUsd,
            uint256 duration
        )
    {
        Phase memory phase = phases[phaseInd];
        return (
            phase.tokensToSell,
            phase.totalSoldTokens,
            phase.tokenPerUsdPrice,
            phase.endTime
        );
    }

    function claimTokens() external {
        require(isPresaleEnded, "Presale has not ended yet");
        User storage user = users[msg.sender];
        require(user.token_balance > 0, "No tokens purchased");
        uint256 claimableTokens = calculateClaimableTokens(msg.sender);
        require(claimableTokens > 0, "No tokens to claim");

        user.claimed_tokens += claimableTokens;
        user.last_claimed_at = block.timestamp;
        mainToken.transfer(msg.sender, claimableTokens);
        emit ClaimToken(msg.sender, claimableTokens);
    }

    function calculateClaimableTokens(
        address _usr
    ) public view returns (uint256) {
        User memory user = users[_usr];
        if (user.claimed_tokens < user.token_balance) {
            uint256 lastClaimTime = user.last_claimed_at == 0
                ? claimStartTime
                : user.last_claimed_at;
            uint256 periods = (block.timestamp - lastClaimTime) /
                vestingDuration;
            uint256 vestedTokens = (user.token_balance * vestingPercentage) /
                100;
            uint256 claimableTokens = vestedTokens * periods;
            if (user.claimed_tokens + claimableTokens > user.token_balance) {
                return user.token_balance - user.claimed_tokens;
            }
            return claimableTokens;
        }
        return 0;
    }

    function whitelistBSCAddresses(
        address[] memory _addresses,
        uint256[] memory _tokenAmount
    ) external onlyOwner {
        require(
            _addresses.length == _tokenAmount.length,
            "Addresses and amounts must be equal"
        );

        for (uint256 i = 0; i < _addresses.length; i++) {
            users[_addresses[i]].token_balance += _tokenAmount[i];
        }
    }

    function setPresaleStatus(bool _status) external onlyOwner {
        presaleStatus = _status;
    }

    function AdvanceStage(uint256 _currentStage) external onlyOwner {
        currentStage = _currentStage;
    }

    function endPresale() external onlyOwner {
        isPresaleEnded = true;
        claimStartTime = block.timestamp;
    }

    // to check number of token for given Eth
    function nativeToToken(
        uint256 _amount,
        uint256 phaseId
    ) public view returns (uint256) {
        uint256 ethToUsd = (_amount * (getLatestPrice())) / (1 ether);
        uint256 numberOfTokens = (ethToUsd * phases[phaseId].tokenPerUsdPrice) /
            (1e8);
        return numberOfTokens;
    }

    // to check number of token for given usdt
    function usdtToToken(
        uint256 _amount,
        uint256 phaseId
    ) public view returns (uint256) {
        uint256 numberOfTokens = (_amount * phases[phaseId].tokenPerUsdPrice) /
            (1e18);
        return numberOfTokens;
    }

    function updateInfos(
        uint256 _sold,
        uint256 _raised,
        uint256 _raisedInUsdt,
        uint256 _raisedInUsdc
    ) external onlyOwner {
        soldToken = _sold;
        amountRaised = _raised;
        amountRaisedUSDT = _raisedInUsdt;
        amountRaisedUSDC = _raisedInUsdc;
    }

    // change tokens
    function updateToken(address _token) external onlyOwner {
        mainToken = IERC20(_token);
    }

    function updateVestingDetail(
        uint256 _vestingDuration,
        uint256 _vestingPercentage
    ) external onlyOwner {
        vestingDuration = _vestingDuration;
        vestingPercentage = _vestingPercentage;
    }

    //change tokens for buy
    function updateStableTokens(IERC20 _USDT, IERC20 _USDC) external onlyOwner {
        USDT = IERC20(_USDT);
        USDC = IERC20(_USDC);
    }

    // to withdraw funds for liquidity
    function initiateTransfer(uint256 _value) external onlyOwner {
        fundReceiver.transfer(_value);
    }

    // to withdraw funds for liquidity
    function changeFundReciever(address _addr) external onlyOwner {
        fundReceiver = payable(_addr);
    }

    //live feed for ETH-USD
    function updatePriceFeed(
        AggregatorV3Interface _priceFeed
    ) external onlyOwner {
        priceFeed = _priceFeed;
    }

    // to withdraw out tokens
    function transferTokens(IERC20 token, uint256 _value) external onlyOwner {
        token.transfer(msg.sender, _value);
    }
}