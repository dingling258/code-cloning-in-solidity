// File: contracts/Asset.sol


pragma solidity >=0.8.0 <0.9.0;

interface IERC20 {
    function balanceOf(address who) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

abstract contract StandardToken is IERC20 {
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;

    function balanceOf(
        address _owner
    ) public view override returns (uint256 balance) {
        return balances[_owner];
    }

    function _transfer(address _from, address _to, uint256 _value) internal {
        balances[_from] = balances[_from] - _value;
        balances[_to] = balances[_to] + _value;
        emit Transfer(_from, _to, _value);
    }

    function _transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) internal {
        uint256 _allowance = allowed[_from][msg.sender];
        allowed[_from][msg.sender] = _allowance - _value;
        _transfer(_from, _to, _value);
    }

    function approve(
        address _spender,
        uint256 _value
    ) public override returns (bool) {
        // To change the approve amount you first have to reduce the addresses`
        //  allowance to zero by calling `approve(_spender, 0)` if it is not
        //  already 0 to mitigate the race condition described here:
        //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        require(
            (_value == 0) || (allowed[msg.sender][_spender] == 0),
            "approve on a non-zero allowance"
        );
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(
        address _owner,
        address _spender
    ) public view override returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
}

contract Asset is StandardToken {
    string public name;
    string public symbol;
    uint256 public immutable totalSupply;
    uint8 public constant decimals = 8;

    constructor(string memory _symbol, string memory _name, uint256 _supply) {
        symbol = _symbol;
        name = _name;
        totalSupply = _supply;
        balances[msg.sender] = totalSupply;
    }

    function transfer(
        address to,
        uint256 value
    ) public override returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public override returns (bool) {
        _transferFrom(from, to, value);
        return true;
    }
}
// File: contracts/Factory.sol


pragma solidity >=0.8.0 <0.9.0;


contract Factory {
    event FactoryConstructed(bytes code);

    event AssetCreated(
        address indexed at,
        uint256 id,
        uint256 key
    );

    mapping(address => uint256) public assets;
    mapping(uint256 => address) public contracts;

    constructor() {
        bytes memory code = type(Asset).creationCode;
        emit FactoryConstructed(code);
    }

    function deploy(
        uint256 _id,
        string memory _symbol,
        string memory _name,
        uint256 _supply
    ) public returns (address) {
        bytes memory args = abi.encodePacked(_id, _symbol, _name, _supply);
        uint256 key = uint256(keccak256(args));
        address old = contracts[key];
        if (old != address(0)) {
            return old;
        }

        Asset asset = new Asset{salt: bytes32(key)}(_symbol, _name, _supply);
        asset.transfer(msg.sender, asset.totalSupply());
        address addr = address(asset);
        assets[addr] = _id;
        contracts[key] = addr;
        emit AssetCreated(addr, _id, key);
        return addr;
    }
}