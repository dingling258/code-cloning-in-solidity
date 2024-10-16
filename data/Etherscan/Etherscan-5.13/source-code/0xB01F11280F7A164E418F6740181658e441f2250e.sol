pragma solidity ^0.8.9;

interface IRevoTierContract{
    function getRealTimeTierWithDiamondHands(address _wallet) external view returns(Tier memory);
    
    struct Tier {
        uint256 index;
        uint256 minRevoToHold;
        uint256 stakingAPRBonus;
        string name;
        uint256 marketplaceFee;
    }
}

contract Context {
    constructor () { }

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; 
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;
    address public _owner2;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function getOwner2() public view returns (address) {
        return _owner2;
    }

    function setOwner2(address _owner) public onlyOwner{
        _owner2 = _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender() || _owner2 == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract RevoLandPreSale is Ownable {

    struct ReferalCode {
        uint count;
        uint amount;
    }

    // Map buyers addresses with private whitelist
    mapping(address => bool) privateSaleWhitelist;

    // Map buyers address with the price of each purchase
    mapping(address => uint[]) walletsSalesDone;

    // Map referals code with the count of each usage, and the amount currendy generated.
    mapping(string => ReferalCode) referals;

    uint public privateSalePriceInWei;
    uint public privateSaleMaxSalesCount;
    uint public privateSaleCurrentSalesCount;
    bool public isPrivateSaleRunning = false;
    uint public privateWhitelistCount;
    bool public allowEveryoneInPrivateSale = false;

    uint[] public publicSalePriceStages;
    uint public publicSaleMaxSalesCount;
    uint public publicSaleCurrentSalesCount;
    bool public isPublicSaleRunning = false;
    uint public publicSaleSecondsBetweenStages;
    uint public publicSaleLastSaleBlockTimestamp;
      
    uint public batchSize = 150;
    address[] presaleOwners;

    IRevoTierContract public revoTier;

    constructor(address _revoTier) {
        if(_revoTier != address(0))
            setRevoTier(_revoTier);
    }

    function setRevoTier(address _revoTier) public onlyOwner {
        revoTier = IRevoTierContract(_revoTier);
    }

    function isAddressPrivateSaleWhitelisted(address _address) public view returns(bool) {
        return privateSaleWhitelist[_address] || isAddressRevoTierWhitelited(_address) || allowEveryoneInPrivateSale;   
    }

    function isAddressRevoTierWhitelited(address _address) public view returns(bool) {
        if(address(revoTier) == address(0))
            return false;
        // Ranger index 2
        // Veteran index 3
        // Elite index 4
        // Master index 5
        IRevoTierContract.Tier memory userTier = revoTier.getRealTimeTierWithDiamondHands(_address);
        return userTier.index >= 2 && userTier.index <= 5;   
    }

    function addToPrivateSaleWhitelist(address _address) public onlyOwner {
        if(privateSaleWhitelist[_address] == true)
        {
            return;
        }
        privateWhitelistCount++;
        privateSaleWhitelist[_address] = true;
    }

    function addToPrivateSaleWhitelist(address[] memory addresses) public onlyOwner {
        for(uint i = 0; i < addresses.length; i++) {
            addToPrivateSaleWhitelist(addresses[i]);
        }
    }

    function removeFromPrivateSaleWhitelist(address _address) public onlyOwner {
        if(privateSaleWhitelist[_address] == false)
        {
            return;
        }
        privateWhitelistCount--;
        privateSaleWhitelist[_address] = false;
    }

    function startPrivateSale(uint _privateSaleMaxSalesCount, uint _privateSalePriceInWei, bool _isPrivateSaleRunning) public onlyOwner {
        isPrivateSaleRunning = _isPrivateSaleRunning;
        privateSalePriceInWei = _privateSalePriceInWei;
        privateSaleMaxSalesCount = _privateSaleMaxSalesCount;
        privateSaleCurrentSalesCount = 0;
    }

    function setAllowEveryoneInPrivateSale(bool _allowEveryoneInPrivateSale) public onlyOwner {
        allowEveryoneInPrivateSale = _allowEveryoneInPrivateSale;
    }

    function setPrivateSalePrice(uint _privateSalePriceInWei) public onlyOwner {
        privateSalePriceInWei = _privateSalePriceInWei;
    }

    function setPrivateSaleMaxCount(uint _privateSaleMaxSalesCount) public onlyOwner {
        privateSaleMaxSalesCount = _privateSaleMaxSalesCount;
    }

    function pausePrivateSale() public onlyOwner {
        isPrivateSaleRunning = false;
    }

    function resumePrivateSale() public onlyOwner {
        isPrivateSaleRunning = true;
    }

    function setPrivateSaleCurrentSalesCount(uint _privateSaleCurrentSalesCount) public onlyOwner {
        privateSaleCurrentSalesCount = _privateSaleCurrentSalesCount;
    }

    function startPublicSale(uint _publicSaleMaxSalesCount, uint[] memory _publicSalePriceStages, bool _isPublicSaleRunning, uint _publicSaleSecondsBetweenStages) public onlyOwner {
        publicSaleMaxSalesCount = _publicSaleMaxSalesCount;
        delete publicSalePriceStages;
        publicSalePriceStages = _publicSalePriceStages;
        isPublicSaleRunning = _isPublicSaleRunning;
        publicSaleCurrentSalesCount = 0;
        publicSaleLastSaleBlockTimestamp = block.timestamp;
        publicSaleSecondsBetweenStages = _publicSaleSecondsBetweenStages;
    }

    function setPublicSalePriceStages(uint[] memory _publicSalePriceStages) public onlyOwner {
        delete publicSalePriceStages;
        publicSalePriceStages = _publicSalePriceStages;
        publicSaleLastSaleBlockTimestamp = block.timestamp;
    }

    function setPublicSaleSecondsBetweenStages(uint _publicSaleSecondsBetweenStages) public onlyOwner {
        publicSaleSecondsBetweenStages = _publicSaleSecondsBetweenStages;
    }

    function setPublicSaleMaxCount(uint _publicSaleMaxSalesCount) public onlyOwner {
        publicSaleMaxSalesCount = _publicSaleMaxSalesCount;
    }

    function pausePublicSale() public onlyOwner {
        isPublicSaleRunning = false;
    }

    function resumePublicSale() public onlyOwner {
        isPublicSaleRunning = true;
    }

    function setPublicSaleCurrentSalesCount(uint _publicSaleCurrentSalesCount) public onlyOwner {
        publicSaleCurrentSalesCount = _publicSaleCurrentSalesCount;
    }

    function setBatchSize(uint _size) public onlyOwner {
        batchSize = _size;
    }

    function getTotalOwnersCount() public view returns (uint) {
        return presaleOwners.length;
    }

    function getOwnerAddressAtIndex(uint _index) public view returns (address) {
        return presaleOwners[_index];
    }

    function getOwnerAddressesByBatchAtIndex(uint _index) public view returns (address[] memory) {
        address[] memory presaleOwnersTemp = new address[](batchSize);
        uint j = 0;
        for(uint i = _index; i < presaleOwners.length && j < batchSize; i++)
        {
            presaleOwnersTemp[j] = presaleOwners[i];
            j++;
        }
        return presaleOwnersTemp;
    }

    function getAllOwnerAddresses() public view returns (address[] memory) {
        return presaleOwners;
    }

    function getWalletSaleDoneAtIndex(address _address, uint _index) public view returns (uint) {
        return walletsSalesDone[_address][_index];
    }

    function getWalletSalesCount(address _address) public view returns (uint) {
        return walletsSalesDone[_address].length;
    }

    function getWalletTotalSalesPrice(address _address) public view returns (uint) {
        uint total = 0;
        for(uint i = 0; i < walletsSalesDone[_address].length; i++)
        {
            total += walletsSalesDone[_address][i];
        }
        return total;
    }

    function getTotalSalesPrice() public view returns (uint) {
        uint total = 0;

        for(uint i = 0; i < presaleOwners.length; i++)
        {
            for(uint j = 0; j < walletsSalesDone[presaleOwners[i]].length; j++)
            {
                total += walletsSalesDone[presaleOwners[i]][j];
            }
        }
        
        return total;
    }

    function buyFromPrivateSale() public payable {
        require(isPrivateSaleRunning == true, "Private sale is closed.");
        require(isAddressPrivateSaleWhitelisted(msg.sender), "Address not whitelisted.");
        require(privateSaleCurrentSalesCount < privateSaleMaxSalesCount, "Private sale is sold out.");
        require(msg.value == privateSalePriceInWei, "Not the expected private sale price.");

        if(walletsSalesDone[msg.sender].length == 0)
        {
            presaleOwners.push(msg.sender);
        }

        walletsSalesDone[msg.sender].push(msg.value);
        privateSaleCurrentSalesCount++;
    }

    function buyFromPublicSale() public payable {
        require(isPublicSaleRunning == true, "Public sale is closed.");
        require(publicSaleCurrentSalesCount < publicSaleMaxSalesCount, "Public sale is sold out.");
        require(msg.value == getPublicCurrentStagePrice(), "Not the expected public sale price.");

        if(walletsSalesDone[msg.sender].length == 0)
        {
            presaleOwners.push(msg.sender);
        }

        walletsSalesDone[msg.sender].push(msg.value);
        publicSaleCurrentSalesCount++;
        publicSaleLastSaleBlockTimestamp = block.timestamp;
    }

    function buyFromPublicSaleWithReferal(string memory _referalCode) public payable {
        require(isPublicSaleRunning == true, "Public sale is closed.");
        require(publicSaleCurrentSalesCount < publicSaleMaxSalesCount, "Public sale is sold out.");
        require(msg.value == getPublicCurrentStagePrice(), "Not the expected public sale price.");

        if(walletsSalesDone[msg.sender].length == 0)
        {
            presaleOwners.push(msg.sender);
        }

        walletsSalesDone[msg.sender].push(msg.value);
        publicSaleCurrentSalesCount++;
        publicSaleLastSaleBlockTimestamp = block.timestamp;
        referals[_referalCode].count++;
        referals[_referalCode].amount += msg.value;
    }

    function getPublicCurrentStage() public view returns(uint) {
        uint stage = (block.timestamp - publicSaleLastSaleBlockTimestamp) / publicSaleSecondsBetweenStages;
        if(stage >= publicSalePriceStages.length)
        {
            stage = publicSalePriceStages.length - 1;
        }
        return stage;
    }

    function getPublicCurrentStagePrice() public view returns(uint) {
        uint stage = getPublicCurrentStage();
        return publicSalePriceStages[stage];
    }

    function getBalance() public view returns(uint) {
        return address(this).balance;
    }

    function withdrawFunds() public onlyOwner {
        payable(msg.sender).transfer(getBalance());
    }

    function getReferalInfo(string memory _referalCode) public view returns (uint, uint) {
        return (referals[_referalCode].count, referals[_referalCode].amount);
    }
}