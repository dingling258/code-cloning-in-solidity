// SPDX-License-Identifier: MIT

// https://apetrain.org/ 

// WARNING: Do not trade this token if you don't understand how it works.
// Please read the website and docs to understand the functionality.

pragma solidity ^0.7.6;

interface ERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address who) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
    function transfer(address to, uint value) external returns (bool);
    function approve(address spender, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

interface ApproveAndCallFallBack {
    function receiveApproval(address from, uint tokens, address token, bytes calldata data) external;
}

contract ApeTrain is ERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private balances;
    mapping (address => mapping (address => uint256)) private allowed;
    string public constant name = "ApeTrain";
    string public constant symbol = "TRAIN";
    uint8 public constant decimals = 18;
    address deployer;
    uint256 _totalSupply = 1000000000 * 10**18;
    mapping (address => bool) private uniswapPair;
    uint256 public lastUpdatedBlock;
    uint256 public nextSalePermitBlock;
    uint256 public saleWindowBlocks = 10;

    constructor() {
        deployer = msg.sender;
        balances[deployer] = _totalSupply;
        emit Transfer(address(0), deployer, _totalSupply);
        uint256 currentBlock = block.number;
        lastUpdatedBlock = currentBlock;
        setNextSalePermitBlock();
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address addr) public view override returns (uint256) {
        return balances[addr];
    }

    function allowance(address addr, address spender) public view override returns (uint256) {
        return allowed[addr][spender];
    }

    function transfer(address to, uint256 value) public override returns (bool) {
        setNextSalePermitBlock();
        require(value <= balances[msg.sender], "Insufficient balance");
        require(to != address(0), "Invalid recipient");

        if (uniswapPair[to]) {
            require(block.number >= nextSalePermitBlock && block.number < (nextSalePermitBlock + saleWindowBlocks), "Not permitted until specified block");

            balances[msg.sender] = balances[msg.sender].sub(value);
            balances[to] = balances[to].add(value);

            emit Transfer(msg.sender, to, value);
            return true;
        } else {
            balances[msg.sender] = balances[msg.sender].sub(value);
            balances[to] = balances[to].add(value);

            emit Transfer(msg.sender, to, value);
            return true;
        }
    }

    function transferFrom(address from, address to, uint256 value) public override returns (bool) {
        setNextSalePermitBlock();
        require(value <= balances[from], "Insufficient balance");
        require(value <= allowed[from][msg.sender], "Allowance exceeded");
        require(to != address(0), "Invalid recipient");

        if (uniswapPair[to]) {
            require(block.number >= nextSalePermitBlock && block.number < (nextSalePermitBlock + saleWindowBlocks), "Not permitted until specified block");

            balances[from] = balances[from].sub(value);
            balances[to] = balances[to].add(value);

            allowed[from][msg.sender] = allowed[from][msg.sender].sub(value);

            emit Transfer(from, to, value);
            return true;
        } else {
            balances[from] = balances[from].sub(value);
            balances[to] = balances[to].add(value);

            allowed[from][msg.sender] = allowed[from][msg.sender].sub(value);

            emit Transfer(from, to, value);
            return true;
        }
    }

    function approve(address spender, uint256 value) public override returns (bool) {
        require(spender != address(0));
        allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        require(spender != address(0));
        allowed[msg.sender][spender] = allowed[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, allowed[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        require(spender != address(0));
        allowed[msg.sender][spender] = allowed[msg.sender][spender].sub(subtractedValue);
        emit Approval(msg.sender, spender, allowed[msg.sender][spender]);
        return true;
    }

    function setUniswapPair(address addr) public {
        require(msg.sender == deployer, "Only deployer can call this function");
        uniswapPair[addr] = true;
    }

    function setNextSalePermitBlock() public {
        if (block.number > (nextSalePermitBlock + saleWindowBlocks)) {
            // Generate a random number between 100 and 10000
            uint256 randomNumber = uint256(keccak256(abi.encodePacked(blockhash(block.number - 1))));
            uint256 _randomNumber = (randomNumber % 9901) + 100;  // 9901 is the range size (10000 - 100 + 1)
            
            // Update the last unblock block number
            lastUpdatedBlock = block.number;

            // Update the next unblock block number
            nextSalePermitBlock = block.number + _randomNumber;
        }
    }

    function changeDeployer(address newDeployer) public {
        require(msg.sender == deployer, "Only the current deployer can change the deployer address");
        deployer = newDeployer;
    }

}

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }

    function ceil(uint256 a, uint256 m) internal pure returns (uint256) {
        uint256 c = add(a, m);
        uint256 d = sub(c, 1);
        return mul(div(d, m), m);
    }
}