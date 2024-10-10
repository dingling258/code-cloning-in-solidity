// SPDX-License-Identifier: MIT

// File: contracts/vert/UtilitiesLib.sol


pragma solidity ^0.8.0;

library UtilitiesLib {
    uint256 internal constant AMOUNT_PERCENTAGE = 2e17;
    uint256 internal constant TREASURY_PERCENTAGE = 5e16;
    uint256 internal constant MARKETING_PERCENTAGE = 12e16;
    uint256 internal constant BOOTSTRAP_PERCENTAGE = 13e16;
    uint256 internal constant REVENUE_SHARE_PERCENTAGE = 1e17;
    uint256 internal constant ANTI_WHALE_MAX_BALANCE = 1500000e18;
    uint256 internal constant ANTI_WHALE_MAX_TRANSFER = 750000e18;
}
// File: contracts/vert/IVestingContract.sol


pragma solidity ^0.8.0;

interface IVestingContract {
    function completeInitialization() external;
}
// File: contracts/vert/ITreasuryBootstrapRevenueShare.sol


pragma solidity ^0.8.0;


interface ITreasuryBootstrapRevenueShare {
    function completeInitialization(address treasuryAddress) external returns(address operatorAddress);
    function setTreasuryAddress(address newValue) external returns(address oldValue);
    function updatePositionOf(address account, uint256 amount, uint256 vestedAmount) external payable;
    function finalizePosition(uint256 treasuryBalance, uint256 additionalLiquidity, uint256 vestingEnds) external payable;
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
// File: contracts/model/IManageableFunctions.sol


pragma solidity ^0.8.0;

interface IManageableFunctions {

    function functionsManagers(string[] memory methods) external view returns(address[] memory values);

    function functionManager(string memory method) external view returns(address value);

    function functionManagerBySignature(bytes4 signature) external view returns(address value);
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
// File: contracts/model/IERC20Core.sol


pragma solidity ^0.8.0;

interface IERC20Core {

    function transfer(address recipient, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
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
// File: contracts/vert/TreasuryBootstrap.sol


pragma solidity ^0.8.0;







contract TreasuryBootstrap is OwnableView, ERC20Core, ERC20Mintable {
    using ManageableFunctionsLib for string[];

    uint256 private constant ONE_HUNDRED = 1e18;

    struct StorageContainer {
        bool loaded;
        Storage content;
    }

    struct Storage {
        uint256 bootstrapStarts;
        address marketingAddress;
        address bootstrapAddress;
        address treasuryAddress;
        uint256 actualPriceWindow;
        uint256[] availableTokensPerWindow;
        uint256[] pricesPerWindow;
        address treasuryBootstrapRevenueShareAddress;
        uint256 treasuryBootstrapFirstRevenueShareAmount;
        uint256 treasuryBalance;
        uint256 treasuryBootstrapAdditionalLiquidity;
        address treasuryBootstrapRevenueShareOperator;
        uint256 bootstrapEnds;
        uint256 antiWhaleSystemEnds;
        uint256 mintReleaseStarts;
        uint256 collectedETH;
        uint256 purchasedSupply;
    }

    constructor(Storage memory __storage) Ownable(address(0)) ManageableFunctions(new string[](0), new address[](0)) {
        StorageContainer storage container = _container();
        container.loaded = true;
        container.content = __storage;
    }

    function _storage() external returns(Storage memory) {
        return _container().content;
    }

    receive() override external payable {
        require(msg.value > 0);
        Storage storage $ = _container().content;
        require(block.timestamp > $.bootstrapStarts && $.treasuryAddress != address(0));
        if(tryFinalizeBootstrapAndEnableAntiWhaleSystem()) {
            msg.sender.call{value : msg.value}("");
            return;
        }

        (uint256[] memory liquidity, uint256 ethToGiveBack) = _calculateLiquidityAndUpdateBootstrapStatus();

        if(ethToGiveBack > 0) {
            msg.sender.call{value : ethToGiveBack}("");
        }

        uint256 total = msg.value - ethToGiveBack;

        $.collectedETH += total;

        uint256 remainingValue = total;

        uint256 amount = _calculatePercentage(total, UtilitiesLib.TREASURY_PERCENTAGE);
        require(amount > 0);
        $.treasuryAddress.call{value : amount}("");
        remainingValue -= amount;

        amount = _calculatePercentage(total, UtilitiesLib.MARKETING_PERCENTAGE);
        require(amount > 0);
        $.marketingAddress.call{value : amount}("");
        remainingValue -= amount;

        amount = _calculatePercentage(total, UtilitiesLib.BOOTSTRAP_PERCENTAGE);
        require(amount > 0);
        $.bootstrapAddress.call{value : amount}("");
        remainingValue -= amount;

        amount = _calculatePercentage(total, UtilitiesLib.REVENUE_SHARE_PERCENTAGE);
        require(amount > 0);
        $.treasuryBootstrapFirstRevenueShareAmount += amount;
        remainingValue -= amount;

        _updatePosition(liquidity, remainingValue);
        tryFinalizeBootstrapAndEnableAntiWhaleSystem();
    }

    function _calculateLiquidityAndUpdateBootstrapStatus() private returns(uint256[] memory liquidity, uint256 ethToGiveBack) {
        Storage storage $ = _container().content;
        liquidity = new uint256[]($.pricesPerWindow.length);
        ethToGiveBack = msg.value;

        while(true) {
            uint256 actualPriceWindow = $.actualPriceWindow;
            if(actualPriceWindow == liquidity.length || ethToGiveBack == 0  || ethToGiveBack < $.pricesPerWindow[actualPriceWindow]) {
                require(ethToGiveBack != msg.value);
                break;
            }
            uint256 pricePerWindow = $.pricesPerWindow[actualPriceWindow];
            uint256 tokens = (ethToGiveBack / pricePerWindow) * 1e18;
            if(tokens == 0) {
                break;
            }
            if(tokens > $.availableTokensPerWindow[actualPriceWindow]) {
                tokens = $.availableTokensPerWindow[actualPriceWindow];
                $.actualPriceWindow++;
            }
            liquidity[actualPriceWindow] = tokens;
            $.availableTokensPerWindow[actualPriceWindow] -= tokens;
            ethToGiveBack -= (pricePerWindow * (tokens / 1e18));
        }
    }

    function _updatePosition(uint256[] memory boughtLiquidity, uint256 value) private {
        Storage storage $ = _container().content;
        uint256 amount;
        uint256 walletAmount;
        for(uint256 i = 0; i < boughtLiquidity.length; i++) {
            if(boughtLiquidity[i] == 0) {
                continue;
            }
            uint256 _walletAmount = _calculatePercentage(boughtLiquidity[i], UtilitiesLib.AMOUNT_PERCENTAGE);
            require(_walletAmount > 0 && boughtLiquidity[i] > _walletAmount);
            amount += (boughtLiquidity[i] - _walletAmount);
            walletAmount += _walletAmount;
        }
        $.purchasedSupply += (amount + walletAmount);
        address treasuryBootstrapRevenueShareAddress = $.treasuryBootstrapRevenueShareAddress;
        super._transfer(address(this), treasuryBootstrapRevenueShareAddress, amount + walletAmount);
        ITreasuryBootstrapRevenueShare(treasuryBootstrapRevenueShareAddress).updatePositionOf{value : value}(msg.sender, amount, walletAmount);
    }

    function tryFinalizeBootstrapAndEnableAntiWhaleSystem() public returns(bool disable) {
        Storage storage $ = _container().content;
        disable = $.treasuryBalance != 0 && functionManagerBySignature(bytes4(0)) != address(0) && (block.timestamp > $.bootstrapEnds || $.actualPriceWindow == $.pricesPerWindow.length);
        if(disable) {
            _finalizePosition();
            _disableBootstrapAndEnableAntiWhaleSystem();
        }
    }

    function _finalizePosition() private {
        Storage storage $ = _container().content;
        uint256 amount = $.treasuryBalance;
        if(amount == 0) {
            return;
        }
        $.treasuryBalance = 0;
        uint256[] memory amounts = $.availableTokensPerWindow;
        for(uint256 i = 0; i < amounts.length; i++) {
            amount += amounts[i];
        }
        address treasuryBootstrapRevenueShareAddress = $.treasuryBootstrapRevenueShareAddress;
        super._transfer(address(this), treasuryBootstrapRevenueShareAddress, amount + $.treasuryBootstrapAdditionalLiquidity);
        ITreasuryBootstrapRevenueShare(treasuryBootstrapRevenueShareAddress).finalizePosition{value : $.treasuryBootstrapFirstRevenueShareAmount}(amount, $.treasuryBootstrapAdditionalLiquidity, ($.antiWhaleSystemEnds += block.timestamp));
    }

    function _disableBootstrapAndEnableAntiWhaleSystem() private {
        string[] memory methods = new string[](4);
        address[] memory values = new address[](methods.length);

        methods[1] = "tryFinalizeBootstrapAndEnableAntiWhaleSystem()";

        methods[2] = "tryDisableAntiWhaleSystem()";
        values[2] = _this;
        methods[3] = "disableAntiWhaleSystem()";
        values[3] = _this;

        methods._setFunctionManagers(values);
    }

    function increaseMintOwnershipReleaseTime(uint256 _seconds) external onlyOwner {
        _container().content.mintReleaseStarts += _seconds;
    }

    function completeInitialization(address treasuryAddress, address[] calldata receivers, uint256[] calldata amounts) external onlyOwner {
        Storage storage $ = _container().content;
        $.treasuryAddress = treasuryAddress;
        $.treasuryBootstrapRevenueShareOperator = ITreasuryBootstrapRevenueShare($.treasuryBootstrapRevenueShareAddress).completeInitialization(treasuryAddress);
        super._mint(address(this), 100000000e18);
        for(uint256 i = 0; i < receivers.length; i++) {
            address receiver = receivers[i];
            uint256 amount = amounts[i];
            super._transfer(address(this), receiver, amount);
            uint256 codeLength;
            assembly {
                codeLength := extcodesize(receiver)
            }
            if(codeLength > 0) {
                receiver.call(abi.encodeWithSelector(IVestingContract(receiver).completeInitialization.selector));
            }
        }
        ManageableFunctionsLib._setFunctionManager("completeInitialization(address,address[],uint256[])", address(0));
    }

    function setFinalNameAndSymbol(address location) external onlyOwner {
        string[] memory methods = new string[](3);
        address[] memory values = new address[](methods.length);

        methods[0] = "name()";
        methods[1] = "symbol()";
        methods[2] = "setFinalNameAndSymbol(address)";

        values[0] = location;
        values[1] = location;

        methods._setFunctionManagers(values);
    }

    function tryDisableAntiWhaleSystem() external {
        require(block.timestamp > _container().content.antiWhaleSystemEnds);
        _disableAntiWhaleSystem();
    }

    function disableAntiWhaleSystem() external onlyOwner {
        _disableAntiWhaleSystem();
    }

    function _disableAntiWhaleSystem() private {
        string[] memory methods = new string[](5);
        address[] memory values = new address[](methods.length);

        methods[0] = "transfer(address,uint256)";
        methods[1] = "transferFrom(address,address,uint256)";

        methods[2] = "tryDisableAntiWhaleSystem()";
        methods[3] = "disableAntiWhaleSystem()";

        methods[4] = "increaseMintOwnershipReleaseTime(uint256)";
        values[4] = _this;

        methods._setFunctionManagers(values);
    }

    function _container() private returns(StorageContainer storage $) {
        assembly {
            $.slot := 0x534aee03e33f141a9b
        }
        if(!$.loaded && _this != address(this)) {
            $.content = TreasuryBootstrap(payable(_this))._storage();
            $.loaded = true;
        }
    }

    function _calculatePercentage(uint256 totalAmount, uint256 percentage) private pure returns (uint256) {
        return (totalAmount * ((percentage * 1e18) / ONE_HUNDRED)) / 1e18;
    }

    function _mint(address account, uint256 amount) internal override {
        StorageContainer storage container = _container();
        require(block.timestamp > container.content.mintReleaseStarts, "Mint still not available");
        super._mint(account, amount);
        string[] memory methods = new string[](3);
        address[] memory values = new address[](methods.length);

        methods[0] = "increaseMintOwnershipReleaseTime(uint256)";
        methods[1] = "mint(address,uint256)";
        methods[2] = "_storage()";

        methods._setFunctionManagers(values);

        delete container.loaded;
        delete container.content;
    }

    function _transfer(address from, address to, uint256 amount) internal override {
        super._transfer(from, to, amount);
        Storage storage $ = _container().content;
        if($.bootstrapEnds >= block.timestamp) {
            require(from == $.treasuryBootstrapRevenueShareAddress, "Transfers locked");
        } else {
            tryFinalizeBootstrapAndEnableAntiWhaleSystem();
            if(block.timestamp > $.antiWhaleSystemEnds) {
                _disableAntiWhaleSystem();
                return;
            }
            require(to == $.treasuryBootstrapRevenueShareOperator || to == $.treasuryBootstrapRevenueShareAddress || (amount <= UtilitiesLib.ANTI_WHALE_MAX_TRANSFER && BalanceLib._balanceOf(to) <= UtilitiesLib.ANTI_WHALE_MAX_BALANCE), "Anti-whale system active");
        }
    }
}