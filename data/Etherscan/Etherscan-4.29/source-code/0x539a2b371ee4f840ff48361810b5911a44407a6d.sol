// SPDX-License-Identifier: MIT

pragma solidity =0.8.19;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

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
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface AggregatorV3Interface {
  
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

contract MMLUPresale is Ownable {
    IERC20 public token;
    IERC20 public usdttoken;
    uint256 public tokenPrice; // doller price with 8 Decimals
    uint256 public totalToken;
    uint256 public totalSaleToken;
    uint256 public _raised;
    bool public paused;
    address public treasury;
    uint256 public minBuy; //in doller with 18 Decimals
    uint256 public maxBuy; //in doller with 18 Decimals
    uint256 public referralBonous;
    uint8 public round;
    uint256 private tokenDecimals;
    AggregatorV3Interface public ethFeed;
    

    struct Account {
        uint256 totalPurchased;
        address referrer;
        uint256 reward;
        uint256 referredCount;
    }

    mapping(address => Account) public accounts;
    receive() external payable {}
    event Purchase(uint256 amount,uint256 usdAmount,address userAddress,uint256 time);
    event PaidReferral(address from, address to, uint256 amount);

    constructor(address _treasuryWallet) {
        token = IERC20(0xE0D3D0Ede7b5E7567D51F7b4Be13eBc28E290f84);
        treasury = address(_treasuryWallet); 
        referralBonous = 500;
        usdttoken = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);
        ethFeed = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
        round = 1;
        tokenPrice = 200000000000000; // $0.0002
        minBuy = 20000000000000000000; // $20
        maxBuy = 1000000000000000000000; // $1000
    }

    function setTokenAddress(address _token) public onlyOwner {
        token = IERC20(_token);
    }

    function _getTokenAmount(uint256 weiAmount,uint _pid ) public view returns (uint256,uint256) {
        uint usd;
        uint totalUsd;
        uint total_token;
        if(_pid == 1){
            usd = getLatestPrice(_pid);
            totalUsd = (weiAmount * usd) / 10**8;
            total_token =  (totalUsd * 10**8) / tokenPrice;
        }
        else if(_pid == 2){
            totalUsd = weiAmount * (10**12);
            total_token =  (totalUsd * 10**8) / tokenPrice;
        }
        
        return (total_token,totalUsd);
    }

    //purchase token
    function purchaseToken(uint256 _amount, address _referrer , uint _pid) external payable {
        require(_pid == 1 || _pid == 2, "Currency not supported");
        
        if(_pid == 1){
            _amount = msg.value;
            (bool os,) = payable(treasury).call{value: _amount}("");
            require(os,"Transaction Failed");
        }
        else{
             IERC20(usdttoken).transferFrom(msg.sender, treasury, _amount);
        }
        (uint tokenAmount,uint totalUsd ) = _getTokenAmount(_amount,_pid);
        _preValidatePurchase(msg.sender,_amount , totalUsd);  

        payReferral(_referrer,tokenAmount);
        _raised += totalUsd;
        totalSaleToken += tokenAmount;
        accounts[msg.sender].totalPurchased += tokenAmount; 
        token.transfer(address(msg.sender), tokenAmount);
        emit Purchase(tokenAmount, totalUsd, msg.sender, block.timestamp);
    }

    function getLatestPrice(uint _pid) public view returns (uint256) {
        int price;
        if(_pid == 1){
            (,price,,,) = ethFeed.latestRoundData();
        }else{
            price = 1e8;
        } 

        return uint256(price);
    }

    function _preValidatePurchase(address beneficiary, uint256 weiAmount , uint _totalUsd) internal view {
        require(!paused, "Crowdsale: Paused!!");
        require(beneficiary != address(0),"Crowdsale: beneficiary is the zero address");
        require(weiAmount != 0, "Crowdsale: weiAmount is 0");
        require(_totalUsd >= minBuy , "amount lower than Minimum Limit");
        require(_totalUsd <= maxBuy , "User maximum limit exceeded" );
    }

    function setPauser(bool _status) external onlyOwner {
        require(paused != _status, "Status Not Changed!!");
        paused = _status;
    }

    function rescueFunds() external onlyOwner {
        (bool os, ) = payable(owner()).call{value: address(this).balance}("");
        require(os, "Transaction Failed");
    }

    function rescueTokens(IERC20 _token, uint256 _amount) external onlyOwner {
        _token.transfer(owner(), _amount);
    }

    function setTreasuryWallet(address _adr) external onlyOwner {
        treasury = _adr;
    }

    function setReferralBonous(uint _bonous) external  onlyOwner{
        referralBonous = _bonous;
    }

    function setTokenPrice(uint256 _rate) external onlyOwner {
        tokenPrice = _rate;
    }

    function setEthFeedAddress(address _feedAddress) external onlyOwner {
        ethFeed = AggregatorV3Interface(_feedAddress);
    }

   function payReferral(address _referral, uint256 _amount) internal {
    // Ensure referral is valid and not self-referral
        if (_referral != address(0) && accounts[msg.sender].referrer == address(0) && msg.sender != _referral) {
            accounts[msg.sender].referrer = _referral;
            accounts[_referral].referredCount++;
        }
        
        // Pay referral bonus if referrer exists and has made purchases
        address referrerAddress = accounts[msg.sender].referrer;
        if (referrerAddress != address(0) && accounts[referrerAddress].totalPurchased > 0) {
            uint256 bonus = (_amount * referralBonous) / 10000;
            accounts[referrerAddress].reward += bonus;
            token.transfer(referrerAddress, bonus);
            emit PaidReferral(msg.sender, referrerAddress, bonus);
        }
    }
    
    function setBuyLimit(uint _minbuy , uint _maxBuy) external onlyOwner{
        require(_maxBuy >= _minbuy , "Max buy must be greator than Min Buy Amount");
        minBuy = _minbuy;
        maxBuy = _maxBuy;
    }

    function setSaleInfo(uint8 _round , uint _price , uint _minLimit , uint _maxLimit ) external onlyOwner{
        round = _round;
        tokenPrice = _price;
        minBuy = _minLimit;
        maxBuy = _maxLimit;
    }
}