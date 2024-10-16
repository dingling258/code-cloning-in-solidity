// SPDX-License-Identifier: MIT

// File: contracts/model/IERC20ReadableData.sol


pragma solidity ^0.8.0;

interface IERC20ReadableData {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);
}
// File: contracts/model/IERC20Permit.sol


pragma solidity ^0.8.0;

interface IERC20Permit {

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function nonces(address owner) external view returns (uint256);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function permitInfo() external view returns(string memory typeHash, string memory name, string memory version);
}
// File: contracts/impl/OwnableView.sol


pragma solidity ^0.8.0;

abstract contract OwnableView {

    bytes32 internal constant OWNER_KEY = 0xdc6edb7e21c7d6802c30a4249460696aa4c6ef3b5aee9c59996f8fedc7fbaefe;

    modifier onlyOwner() {
        require(msg.sender == _owner(), "Unauthorized");
        _;
    }

    function _owner() internal view returns (address value) {
        assembly {
            value := sload(OWNER_KEY)
        }
    }
}
// File: contracts/model/IOwnable.sol


pragma solidity ^0.8.0;

interface IOwnable {

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function owner() external view returns (address);

    function renounceOwnership() external;

    function transferOwnership(address newOwner) external;
}
// File: contracts/impl/Ownable.sol


pragma solidity ^0.8.0;



abstract contract Ownable is IOwnable, OwnableView {

    constructor(address initialOwner) {
        _transferOwnership(initialOwner);
    }

    function owner() override external view returns (address) {
        return _owner();
    }

    function renounceOwnership() override external onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) override external onlyOwner {
        require(newOwner != address(0), "Invalid");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) private {
        address oldOwner = _owner();
        assembly {
            sstore(OWNER_KEY, newOwner)
        }
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
// File: contracts/model/IERC20Mintable.sol


pragma solidity ^0.8.0;

interface IERC20Mintable {

    function mint(address account, uint256 amount) external returns (bool);
}
// File: contracts/model/IERC20Metadata.sol


pragma solidity ^0.8.0;

interface IERC20Metadata {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}
// File: contracts/model/IManageableFunctions.sol


pragma solidity ^0.8.0;

interface IManageableFunctions {

    function functionsManagers(string[] memory methods) external view returns(address[] memory values);

    function functionManager(string memory method) external view returns(address value);

    function functionManagerBySignature(bytes4 signature) external view returns(address value);
}
// File: contracts/model/IERC20Core.sol


pragma solidity ^0.8.0;

interface IERC20Core {

    function transfer(address recipient, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}
// File: contracts/model/IERC20Burnable.sol


pragma solidity ^0.8.0;

interface IERC20Burnable {

    function burn(uint256 amount) external;
    function burnFrom(address account, uint256 amount) external;
}
// File: contracts/util/Libraries.sol


pragma solidity ^0.8.0;
library BalanceMathLib {
    function _update(bytes32 key, uint256 amount, bool add) internal returns(uint256 oldValue, uint256 newValue) {

        assembly {
            oldValue := sload(key)
        }

        newValue = oldValue;

        if(amount != 0) {
            if(add) {
                newValue += amount;
            } else {
                require(amount <= newValue, "math");
                newValue -= amount;
            }
            assembly {
                sstore(key, newValue)
            }
        }
    }
}

library TotalSupplyLib {
    bytes32 internal constant _totalSupplyKey = 0x3b199c13f2f664dd6072f28dca68234bfe807e2c585d7f2c2dd6ca130425f7f4;

    function _totalSupply() internal view returns(uint256 value) {
        assembly {
            value := sload(_totalSupplyKey)
        }
    }

    function _updateTotalSupply(uint256 amount, bool add) internal returns(uint256 oldValue, uint256 newValue) {
        return BalanceMathLib._update(_totalSupplyKey, amount, add);
    }
}

library BalanceLib {
    function _balanceKey(address owner) internal pure returns(bytes32) {
        return keccak256(abi.encodePacked(bytes32(0x8c711c71c841a0b57e9c348e630100ef0388c980ef7833ea525f8a88be9c528b), owner));
    }

    function _balanceOf(address owner) internal view returns(uint256 value) {
        bytes32 key = _balanceKey(owner);
        assembly {
            value := sload(key)
        }
    }

    function _updateBalanceOf(address owner, uint256 amount, bool add) internal returns(uint256 oldValue, uint256 newValue) {
        return BalanceMathLib._update(_balanceKey(owner), amount, add);
    }
}

library ManageableFunctionsLib {
    address internal constant DEAD_ADDRESS = 0x000000000000000000000000000000000000dEaD;

    function _functionManagerKey(string memory method) internal pure returns(bytes32 key, bytes4 signature) {
        key = _functionManagerKey(signature = bytes(method).length == 0 ? signature : bytes4(keccak256(abi.encodePacked(method))));
    }

    function _functionManagerKey(bytes4 signature) internal pure returns(bytes32) {
        return keccak256(abi.encodePacked(bytes32(0xd3b8e69b943f0b5cdf78676605268bb628a1252c7ee2b027a749c87ba9c2bf96), signature));
    }

    event FunctionManager(bytes4 indexed signature, address indexed oldValue, address indexed newValue, string method);

    function _setFunctionManager(string memory method, address newValue) internal returns(address oldValue) {
        (bytes32 key, bytes4 signature) = _functionManagerKey(method);
        assembly {
            oldValue := sload(key)
            sstore(key, newValue)
        }
        emit FunctionManager(signature, oldValue, newValue, method);
    }

    function _setFunctionManagers(string[] memory methods, address[] memory values) internal returns(address[] memory oldValues) {
        if(methods.length == 0) {
            return oldValues;
        }
        oldValues = new address[](methods.length);
        address defaultValue = values.length == 0 ? address(0) : values[0];
        for(uint256 i = 0; i < methods.length; i++) {
            oldValues[i] = _setFunctionManager(methods[i], i < values.length ? values[i] : defaultValue);
        }
    }
}

library AllowanceKeyLib {

    function _allowanceKey(address owner, address spender) internal pure returns(bytes32) {
        return keccak256(abi.encodePacked(bytes32(0x4e43e5fe43c3de8144818a4355e4e23384113a1cdc7e4b106dc8f6506b022692), owner, spender));
    }
}

library AllowanceLib {
    using AllowanceKeyLib for address;

    function _allowance(address owner, address spender) internal view returns (uint256 value) {
        bytes32 key = owner._allowanceKey(spender);
        assembly {
            value := sload(key)
        }
    }
}

library ApproveLib {
    using AllowanceKeyLib for address;

    function _approve(address owner, address spender, uint256 value, bool alsoEvent) internal returns (bool) {
        bytes32 key = owner._allowanceKey(spender);
        assembly {
            sstore(key, value)
        }
        if(alsoEvent) {
            emit ERC20Events.Approval(owner, spender, value);
        }
        return true;
    }
}

library ERC20Events {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
}
// File: contracts/impl/ERC20ReadableData.sol


pragma solidity ^0.8.0;



abstract contract ERC20ReadableData is IERC20ReadableData {

    function totalSupply() override public view returns (uint256) {
        return TotalSupplyLib._totalSupply();
    }

    function balanceOf(address account) override public view returns (uint256) {
        return BalanceLib._balanceOf(account);
    }
}
// File: contracts/impl/ERC20Permit.sol


pragma solidity ^0.8.0;



abstract contract ERC20Permit is IERC20Permit {
    using ApproveLib for address;

    bytes32 override public immutable DOMAIN_SEPARATOR;

    constructor() {
        (,string memory domainSeparatorName, string memory domainSeparatorVersion) = permitInfo();
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes(domainSeparatorName)),
                keccak256(bytes(domainSeparatorVersion)),
                block.chainid,
                address(this)
            )
        );
    }

    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) override external {
        require(block.timestamp <= deadline, "ERC20Permit: expired deadline");
        (string memory permitSignature,,) = permitInfo();
        bytes32 digest = keccak256(
            abi.encodePacked(
                '\x19\x01',
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(keccak256(bytes(permitSignature)), owner, spender, value, _increaseNonces(owner), deadline))
            )
        );
        address recoveredAddress = ecrecover(digest, v, r, s);
        require(recoveredAddress != address(0) && recoveredAddress == owner, 'INVALID_SIGNATURE');
        owner._approve(spender, value, true);
    }

    function permitInfo() public override pure returns(string memory permitSignature, string memory domainSeparatorName, string memory domainSeparatorVersion) {
        permitSignature = "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)";
        domainSeparatorName = "SoS Token";
        domainSeparatorVersion = "1";
    }

    function nonces(address owner) override external view returns (uint256 value) {
        (value,) = _nonces(owner);
    }

    function _nonces(address owner) private view returns(uint256 value, bytes32 key) {
        key = keccak256(abi.encodePacked("nonces", owner));
        assembly {
            value := sload(key)
        }
    }

    function _increaseNonces(address owner) private returns(uint256 oldValue) {
        (uint256 value, bytes32 key) = _nonces(owner);
        oldValue = value++;
        assembly {
            sstore(key, value)
        }
    }
}
// File: contracts/impl/ManageableFunctions.sol


pragma solidity ^0.8.0;



abstract contract ManageableFunctions is IManageableFunctions {
    using ManageableFunctionsLib for string;
    using ManageableFunctionsLib for bytes4;
    using ManageableFunctionsLib for string[];

    event FunctionManager(bytes4 indexed signature, address indexed oldValue, address indexed newValue, string method);

    address internal immutable _this = address(this);

    constructor(string[] memory methods, address[] memory values) {
        methods._setFunctionManagers(values);
    }

    function _tryInitialize() internal {
        string memory method = "initialize()";
        address delegate = functionManager(method);
        if(delegate != address(0) && delegate != _this && delegate != ManageableFunctionsLib.DEAD_ADDRESS) {
            (bool result, bytes memory response) = delegate.delegatecall(abi.encodeWithSignature(method));
            if(!result) {
                assembly {
                    revert(add(0x20, response), mload(response))
                }
            }
            method._setFunctionManager(address(0));
        }
    }

    function functionsManagers(string[] memory methods) override public view returns(address[] memory values) {
        values = new address[](methods.length);
        for(uint256 i = 0; i < methods.length; i++) {
            values[i] = functionManager(methods[i]);
        }
    }

    function functionManager(string memory method) override public view returns(address value) {
        (bytes32 key, ) = method._functionManagerKey();
        assembly {
            value := sload(key)
        }
    }

    function functionManagerBySignature(bytes4 signature) override public view returns(address value) {
        bytes32 key = signature._functionManagerKey();
        assembly {
            value := sload(key)
        }
    }

    receive() virtual external payable {
        _delegateCall(functionManagerBySignature(bytes4(0)));
    }

    fallback() external payable {
        _delegateCall(functionManagerBySignature(msg.sig));
    }

    modifier delegable() {
        address delegate = functionManagerBySignature(msg.sig);
        if(delegate == address(0) || delegate == _this) {
            _;
        } else {
            _delegateCall(delegate);
        }
    }

    function _delegateCall(address delegate) private {
        require(delegate != address(0) && delegate != _this && delegate != ManageableFunctionsLib.DEAD_ADDRESS);
        assembly {
            calldatacopy(0, 0, calldatasize())
            let success := delegatecall(gas(), delegate, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch success
                case 0 {revert(0, returndatasize())}
                default { return(0, returndatasize())}
        }
    }

    function _tryStaticCall() internal view returns(bool) {
        address delegate = functionManagerBySignature(msg.sig);
        if(delegate == address(0) || delegate == _this) {
            return false;
        }
        require(delegate != ManageableFunctionsLib.DEAD_ADDRESS);
        assembly {
            calldatacopy(0, 0, calldatasize())
            let success := staticcall(gas(), delegate, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch success
                case 0 {revert(0, returndatasize())}
                default { return(0, returndatasize())}
        }
    }
}
// File: contracts/impl/ERC20Mintable.sol


pragma solidity ^0.8.0;





abstract contract ERC20Mintable is IERC20Mintable, Ownable, ManageableFunctions {
    function mint(address account, uint256 amount) override external onlyOwner delegable returns (bool) {
        _mint(account, amount);
        return true;
    }

    function _mint(address account, uint256 amount) internal virtual {
        BalanceLib._updateBalanceOf(account, amount, true);
        TotalSupplyLib._updateTotalSupply(amount, true);
        emit ERC20Events.Transfer(address(0), account, amount);
    }
}
// File: contracts/impl/ERC20Metadata.sol


pragma solidity ^0.8.0;



abstract contract ERC20Metadata is IERC20Metadata, ManageableFunctions {

    bytes32 private immutable _name;
    bytes32 private immutable _symbol;
    uint8 override public immutable decimals;

    constructor(string memory __name, string memory __symbol, uint8 __decimals) {
        _name = bytes32(abi.encodePacked(__name));
        _symbol = bytes32(abi.encodePacked(__symbol));
        decimals = __decimals;
    }

    function name() override external view returns (string memory value) {
        if(!_tryStaticCall()) {
            return _asString(_name);
        }
    }

    function symbol() override external view returns (string memory value) {
        if(!_tryStaticCall()) {
            return _asString(_symbol);
        }
    }

    function _asString(bytes32 value) private pure returns (string memory) {
        uint8 i = 0;
        while(i < 32 && value[i] != 0) {
            i++;
        }
        bytes memory bytesArray = new bytes(i);
        for (i = 0; i < 32 && value[i] != 0; i++) {
            bytesArray[i] = value[i];
        }
        return string(bytesArray);
    }
}
// File: contracts/impl/ERC20Core.sol


pragma solidity ^0.8.0;




abstract contract ERC20Core is IERC20Core, ManageableFunctions {

    function transfer(address recipient, uint256 amount) override public virtual delegable returns (bool) {
        if(amount == 0) {
            return true;
        }
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) override public virtual delegable returns (bool) {
        if(amount == 0) {
            return true;
        }
        uint256 oldAllowance = AllowanceLib._allowance(sender, msg.sender);
        require(oldAllowance >= amount, "ERC20: amount exeeds allowance");
        ApproveLib._approve(sender, msg.sender, oldAllowance - amount, false);
        _transfer(sender, recipient, amount);
        return true;
    }

    function _transfer(address from, address to, uint256 amount) internal virtual {
        BalanceLib._updateBalanceOf(from, amount, false);
        BalanceLib._updateBalanceOf(to, amount, true);
        emit ERC20Events.Transfer(from, to, amount);
    }
}
// File: contracts/impl/ERC20Burnable.sol


pragma solidity ^0.8.0;



abstract contract ERC20Burnable is IERC20Burnable {

    function burn(uint256 amount) override external {
        BalanceLib._updateBalanceOf(msg.sender, amount, false);
        TotalSupplyLib._updateTotalSupply(amount, false);
        emit ERC20Events.Transfer(msg.sender, address(0), amount);
    }

    function burnFrom(address account, uint256 amount) override external {
        uint256 oldAllowance = AllowanceLib._allowance(account, msg.sender);
        require(oldAllowance >= amount, "ERC20: amount exeeds allowance");
        ApproveLib._approve(account, msg.sender, oldAllowance - amount, false);
        BalanceLib._updateBalanceOf(account, amount, false);
        TotalSupplyLib._updateTotalSupply(amount, false);
        emit ERC20Events.Transfer(account, address(0), amount);
    }
}
// File: contracts/model/IERC20Approve.sol


pragma solidity ^0.8.0;

interface IERC20Approve {

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);
}
// File: contracts/impl/ERC20Approve.sol


pragma solidity ^0.8.0;



abstract contract ERC20Approve is IERC20Approve {
    using AllowanceLib for address;
    using ApproveLib for address;

    function allowance(address owner, address spender) override public view returns (uint256 value) {
        return owner._allowance(spender);
    }

    function approve(address spender, uint256 amount) override external returns (bool) {
        return msg.sender._approve(spender, amount, true);
    }
}
// File: contracts/vert/Token.sol


pragma solidity ^0.8.0;








contract Token is ERC20Approve, ERC20Burnable, ERC20Core, ERC20Metadata, ERC20Mintable, ERC20Permit, ERC20ReadableData {

    constructor(address initialOwner, string[] memory methods, address[] memory values) Ownable(initialOwner) ManageableFunctions(methods, values) ERC20Metadata("Codename: Kaiten", "KAI", 18) {
    }
}