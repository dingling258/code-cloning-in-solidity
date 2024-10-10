// SPDX-License-Identifier: MIT

/**
 * VladimirGav
 * GitHub Website: https://vladimirgav.github.io/
 * GitHub: https://github.com/VladimirGav
 */

/**
 * It is example of a WhiteList from VladimirGav
 * Contract SimpleToken: Read: _decimals, decimals, _name, name, _symbol, symbol, allowance, balanceOf, totalSupply; Write:  transfer, transferFrom, approve, decreaseAllowance, increaseAllowance.
 * Contract Ownable: Read: getOwner, owner; Write:  onlyOwner: renounceOwnership, transferOwnership.
 */

pragma solidity >=0.8.19;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// @dev Wrappers over Solidity's arithmetic operations with added overflow * checks.
library SafeMath {
    // Counterpart to Solidity's `+` operator.
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    // Counterpart to Solidity's `-` operator.
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    // Counterpart to Solidity's `-` operator.
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    // Counterpart to Solidity's `*` operator.
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    // Counterpart to Solidity's `/` operator.
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    // Counterpart to Solidity's `/` operator.
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    // Counterpart to Solidity's `%` operator.
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    // Counterpart to Solidity's `%` operator.
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () { }

    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "onlyOwner");
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract WhiteList is Ownable {

    // mapping WhiteList
    mapping(address=>bool) isWhiteListed;

    // example of adding addresses to the white list
    constructor () {
        isWhiteListed[address(0x4347aadc288F5bDBfB3dd2E2380eF833BA7D78F8)] = true;
        isWhiteListed[address(0x328f36b4868095Ff13BE22127f5C8b9C6BAccc77)] = true;
        isWhiteListed[address(0x576bbC2Fc6a523302d81DF3C034a8C770e013A2F)] = true;
        isWhiteListed[address(0x674C257d0551Dd6bEd67c3844017eBd77fF64995)] = true;
        isWhiteListed[address(0xa416297F2a29E4B86D0FBDb322f406316B8bE5AA)] = true;
        isWhiteListed[address(0xCe557397b4Ed52fED57B63B17c81EFC93cB834fD)] = true;
        isWhiteListed[address(0xba2078b93b8a3F1BA3279d59e80B84FcA783A302)] = true;
        isWhiteListed[address(0x03a60521583A762840e924424A552b0E4aeb9dFa)] = true;
        isWhiteListed[address(0xD11390569ed64E98c4121edaA21caDD50823A961)] = true;
        isWhiteListed[address(0xDA9e96e2e6D6D5EE90192918D86F45F33B977197)] = true;
        isWhiteListed[address(0x576bbC2Fc6a523302d81DF3C034a8C770e013A2F)] = true;
        isWhiteListed[address(0x432A7E1fEa4f85EA36b260846120a159e98844f0)] = true;
        isWhiteListed[address(0xc03b7651051E1C946C77bC24AA4314137296dd2A)] = true;

    }

    function getWhiteListStatus(address _addressUser) external view returns (bool) {
        return isWhiteListed[_addressUser];
    }

    // add address to WhiteList
    function addWhiteList(address _addressUser) public onlyOwner {
        isWhiteListed[_addressUser] = true;
    }

    // add address to WhiteList
    function addWhiteListArray(address[] memory  _addressesUsers) public onlyOwner {
        for (uint i; i < _addressesUsers.length; i++) {
            isWhiteListed[_addressesUsers[i]] = true;
        }
    }

    // remove address to WhiteList
    function removeWhiteList(address _addressUser) public onlyOwner {
        isWhiteListed[_addressUser] = false;
    }

    // Status the TransferOnlyWhitelist
    bool private transferOnlyWhitelist = true;

    // Show status the TransferOnlyWhitelist
    function transferOnlyWhitelistStatus() public view returns (bool) {
        return transferOnlyWhitelist;
    }

    // Activate or deactivate the TransferOnlyWhitelist
    function setTransferOnlyWhitelist(bool _transferOnlyWhitelist) public onlyOwner {
        transferOnlyWhitelist = _transferOnlyWhitelist;
    }

}

contract GREVONAUE is Context, Ownable, IERC20, WhiteList {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;
    uint8 public _decimals;
    string public _symbol;
    string public _name;

    constructor() {
        _name = "GREVONAUE";
        _symbol = "GRV";
        _decimals = 18;
        _totalSupply = 1000000 * 1000000000000000000;
        _balances[msg.sender] = _totalSupply;

        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function getOwner() external view returns (address) {
        return owner();
    }

    function decimals() external view returns (uint8) {
        return _decimals;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address addressOwner, address spender) external view returns (uint256) {
        return _allowances[addressOwner][spender];
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "Transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "Decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "Transfer from the zero address");
        require(recipient != address(0), "Transfer to the zero address");
        require(amount <= _balances[sender], "Transfer amount exceeds balance");

        // Check WhiteList
        if(WhiteList.transferOnlyWhitelistStatus() == true){
            require(isWhiteListed[msg.sender], "Whitelist enabled. Transfer only for white list."); // WhiteList
        }

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _approve(address addressOwner, address spender, uint256 amount) internal {
        require(addressOwner != address(0), "Approve from the zero address");
        require(spender != address(0), "Approve to the zero address");

        _allowances[addressOwner][spender] = amount;
        emit Approval(addressOwner, spender, amount);
    }

}