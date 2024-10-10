// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IUniswapV2Pair {
    function getReserves() external view returns (uint reserve0, uint reserve1, uint32 blockTimestampLast);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
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
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract PresaleContract is Ownable {
    IERC20 public presaleToken;
    IERC20 public usdtToken;
    IUniswapV2Pair public uniswapPair;
    uint256 public ethRate; // Store the ETH rate in USDT
    uint256 public swapRate; // Number of presale tokens per USDT, adjusted for presale token decimals
    uint256 public bonusPercentage = 15; // Bonus percentage
    bool public presaleEnded = false;
    mapping(address => uint256) public tokensOwed; // Track how many tokens each participant can claim
    event EthRateUpdated(uint reserve0, uint reserve1);
    event DebugInfo(uint256 adjustedReserve0, uint256 reserve1, uint256 newEthRate);

    constructor(address _presaleToken, address _usdtToken, address _uniswapPair) {
        presaleToken = IERC20(_presaleToken);
        usdtToken = IERC20(_usdtToken);
        uniswapPair = IUniswapV2Pair(_uniswapPair);
        swapRate = 5 * 1e9;
    }

    function endPresale() external onlyOwner {
        presaleEnded = true;
    }
    function calculateBonus(uint256 tokens) private view returns (uint256) {
        return tokens * (100 + bonusPercentage) / 100;
    }
    function updateBonus(uint256 _bonusPercentage) external onlyOwner {
        bonusPercentage = _bonusPercentage;
    }
    function updateSwapRate(uint256 _swapRate) external onlyOwner {
        swapRate = _swapRate;
    }
    function updateUniswapPair(address _newUniswapPair) external onlyOwner {
        uniswapPair = IUniswapV2Pair(_newUniswapPair);
    }
    function updateEthRate() public {
        (uint reserve0, uint reserve1,) = uniswapPair.getReserves();
        require(reserve1 != 0, "Cannot divide by zero");
        uint256 adjustedReserve0 = reserve0 * 1e12;  // Scale USDT up to 18 decimals to match ETH
        // Debugging: Check the values before division
        emit DebugInfo(adjustedReserve0, reserve1, adjustedReserve0 / reserve1);
        ethRate = adjustedReserve0 / reserve1;  // Now both are scaled to 18 decimals
    }
    function swapWithETH() external payable {
        require(!presaleEnded, "Presale has ended");
        require(msg.value > 0, "No ETH sent");
        (bool sent, ) = owner().call{value: msg.value}("");
        require(sent, "Failed to send ETH");
        uint256 usdtEquivalent = msg.value * ethRate / 1e9; 
        uint256 tokensWithoutBonus = usdtEquivalent * swapRate / 1e9; 
        uint256 tokensToTransfer = calculateBonus(tokensWithoutBonus);
        tokensOwed[msg.sender] += tokensToTransfer;
    }
    function swapWithUSDT(uint256 usdtAmount) external {
        require(!presaleEnded, "Presale has ended");
        require(usdtAmount > 0, "Invalid USDT amount");
        require(usdtToken.transferFrom(msg.sender, owner(), usdtAmount), "Failed to transfer USDT");
        uint256 tokensWithoutBonus = usdtAmount * swapRate / 1e6; 
        uint256 tokensToTransfer = calculateBonus(tokensWithoutBonus);
        tokensOwed[msg.sender] += tokensToTransfer;
    }
    function claimTokens() external {
        require(presaleEnded, "Presale has not ended yet");
        uint256 amountOwed = tokensOwed[msg.sender];
        require(amountOwed > 0, "No tokens owed");   
        tokensOwed[msg.sender] = 0;
        require(presaleToken.transfer(msg.sender, amountOwed), "Failed to transfer tokens");
    }
    function withdrawETH(address to, uint256 amount) external onlyOwner {
        payable(to).transfer(amount);
    }
    function withdrawUSDT(address to, uint256 amount) external onlyOwner {
        require(usdtToken.transfer(to, amount), "Failed to transfer USDT");
    }
    function withdrawPresaleToken(address _recipient, uint256 _amount) external onlyOwner {
        require(presaleToken.transfer(_recipient, _amount), "Contract: Failed to transfer Presale Token");
    }
    receive() external payable {}
    fallback() external payable {}
}