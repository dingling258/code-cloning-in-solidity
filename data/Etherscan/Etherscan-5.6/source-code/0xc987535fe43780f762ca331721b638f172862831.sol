// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

contract Ownable is Context {
    using SafeMath for uint256;

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
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

contract SwapTokenETH is Ownable {

    using SafeMath for uint256;

    uint256 public usdRate = 0.000009e18;
    uint256 public taxRate = 1;
    uint256 public maxBuyLimitETH = 0.064 ether;

    AggregatorV3Interface public priceFeedETH = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);

    event TokensPurchased(address indexed buyer, uint256 amountPaid, uint256 tokenAmount, string currency);
    event RateSet(uint256 newRate, address indexed owner);
    event TokensRecovered(address indexed sender, address indexed tokenAddress, uint256 amount);

    function buyTokensWithETH() external payable {
        require(msg.value > 0, "Amount must be greater than zero");

        uint256 ethAmount = msg.value;
        require(ethAmount <= maxBuyLimitETH, "Purchase amount exceeds the maximum buy limit");

        uint256 taxAmount = ethAmount.mul(taxRate).div(100);
        uint256 amountAfterTax = ethAmount.sub(taxAmount);

        uint256 amount = getTokenAmountETH(amountAfterTax);
        require(amount > 0, "Amount must be greater than zero");

        (bool ethTransferSuccess, ) = payable(owner()).call{value: amountAfterTax}("");
        require(ethTransferSuccess, "ETH transfer failed");

        (bool taxTransferSuccess, ) = payable(owner()).call{value: taxAmount}("");
        require(taxTransferSuccess, "Tax transfer failed");
        
        emit TokensPurchased(msg.sender, amountAfterTax, amount, "ETH");
    }

    function setTaxRate(uint256 _newTaxRate) external onlyOwner {
        require(_newTaxRate >= 0 && _newTaxRate <= 100, "Tax rate must be between 0 and 100");
        taxRate = _newTaxRate;
    }

    function setMaxBuyAmountETH(uint256 _newMaxBuyAmount) external onlyOwner {
        maxBuyLimitETH = _newMaxBuyAmount;
    }

    function getTokenAmountETH(uint256 amountETH) public view returns (uint256) {
        uint256 lastETHPriceByUSD = getLatestPriceETHPerUSD();
        return amountETH.mul(lastETHPriceByUSD).div(getPriceInUSD());
    }

    function getLatestPriceETHPerUSD() public view returns (uint256) {
        (, int256 price, , , ) = priceFeedETH.latestRoundData();
        price = (price * (10**10));
        return uint256(price);
    }

    function getPriceInUSD() public view returns (uint256) {
        return usdRate;
    }

    function setUsdRate(uint256 _newUsdRate) external onlyOwner {
        require(_newUsdRate > 0, "USD rate must be greater than zero");
        usdRate = _newUsdRate;
        emit RateSet(_newUsdRate, msg.sender);
    }

    function updateContractAddresses(address _newPriceFeedETH) external onlyOwner {
        require(_newPriceFeedETH != address(0), "ETH price feed address cannot be zero");
        priceFeedETH = AggregatorV3Interface(_newPriceFeedETH);
    }

    function withdrawWrongETH() external onlyOwner {
        uint256 ethBalance = address(this).balance;
        (bool success, ) = payable(msg.sender).call{value: ethBalance}("");
        require(success, "ETH withdrawal failed");
    }
    
}