// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;










contract MainnetActionsUtilAddresses {
    address internal constant DFS_REG_CONTROLLER_ADDR = 0xF8f8B3C98Cf2E63Df3041b73f80F362a4cf3A576;
    address internal constant REGISTRY_ADDR = 0x287778F121F134C66212FB16c9b53eC991D32f5b;
    address internal constant DFS_LOGGER_ADDR = 0xcE7a977Cac4a481bc84AC06b2Da0df614e621cf3;
    address internal constant SUB_STORAGE_ADDR = 0x1612fc28Ee0AB882eC99842Cde0Fc77ff0691e90;
    address internal constant PROXY_AUTH_ADDR = 0x149667b6FAe2c63D1B4317C716b0D0e4d3E2bD70;
    address internal constant LSV_PROXY_REGISTRY_ADDRESS = 0xa8a3c86c4A2DcCf350E84D2b3c46BDeBc711C16e;
    address internal constant TRANSIENT_STORAGE = 0x2F7Ef2ea5E8c97B8687CA703A0e50Aa5a49B7eb2;
}







contract ActionsUtilHelper is MainnetActionsUtilAddresses {
}







contract MainnetAuthAddresses {
    address internal constant ADMIN_VAULT_ADDR = 0xCCf3d848e08b94478Ed8f46fFead3008faF581fD;
    address internal constant DSGUARD_FACTORY_ADDRESS = 0x5a15566417e6C1c9546523066500bDDBc53F88C7;
    address internal constant ADMIN_ADDR = 0x25eFA336886C74eA8E282ac466BdCd0199f85BB9; // USED IN ADMIN VAULT CONSTRUCTOR
    address internal constant PROXY_AUTH_ADDRESS = 0x149667b6FAe2c63D1B4317C716b0D0e4d3E2bD70;
    address internal constant MODULE_AUTH_ADDRESS = 0x7407974DDBF539e552F1d051e44573090912CC3D;
}







contract AuthHelper is MainnetAuthAddresses {
}








contract AdminVault is AuthHelper {
    address public owner;
    address public admin;

    error SenderNotAdmin();

    constructor() {
        owner = msg.sender;
        admin = ADMIN_ADDR;
    }

    /// @notice Admin is able to change owner
    /// @param _owner Address of new owner
    function changeOwner(address _owner) public {
        if (admin != msg.sender){
            revert SenderNotAdmin();
        }
        owner = _owner;
    }

    /// @notice Admin is able to set new admin
    /// @param _admin Address of multisig that becomes new admin
    function changeAdmin(address _admin) public {
        if (admin != msg.sender){
            revert SenderNotAdmin();
        }
        admin = _admin;
    }

}







interface IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint256 digits);
    function totalSupply() external view returns (uint256 supply);

    function balanceOf(address _owner) external view returns (uint256 balance);

    function transfer(address _to, uint256 _value) external returns (bool success);

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool success);

    function approve(address _spender, uint256 _value) external returns (bool success);

    function allowance(address _owner, address _spender) external view returns (uint256 remaining);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}







library Address {
    //insufficient balance
    error InsufficientBalance(uint256 available, uint256 required);
    //unable to send value, recipient may have reverted
    error SendingValueFail();
    //insufficient balance for call
    error InsufficientBalanceForCall(uint256 available, uint256 required);
    //call to non-contract
    error NonContractCall();
    
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        uint256 balance = address(this).balance;
        if (balance < amount){
            revert InsufficientBalance(balance, amount);
        }

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}("");
        if (!(success)){
            revert SendingValueFail();
        }
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        uint256 balance = address(this).balance;
        if (balance < value){
            revert InsufficientBalanceForCall(balance, value);
        }
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        if (!(isContract(target))){
            revert NonContractCall();
        }

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: weiValue}(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}











library SafeERC20 {
    using Address for address;

    /**
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Compatible with tokens that require the approval to be set to
     * 0 before setting it to a non-zero value.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeWithSelector(token.approve.selector, spender, value);

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, 0));
            _callOptionalReturn(token, approvalCall);
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        require(returndata.length == 0 || abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturn} that silents catches all reverts and returns a bool instead.
     */
    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We cannot use {Address-functionCall} here since this should return false
        // and not revert is the subcall reverts.

        (bool success, bytes memory returndata) = address(token).call(data);
        return success && (returndata.length == 0 || abi.decode(returndata, (bool))) && address(token).code.length > 0;
    }
}










contract AdminAuth is AuthHelper {
    using SafeERC20 for IERC20;

    AdminVault public constant adminVault = AdminVault(ADMIN_VAULT_ADDR);

    error SenderNotOwner();
    error SenderNotAdmin();

    modifier onlyOwner() {
        if (adminVault.owner() != msg.sender){
            revert SenderNotOwner();
        }
        _;
    }

    modifier onlyAdmin() {
        if (adminVault.admin() != msg.sender){
            revert SenderNotAdmin();
        }
        _;
    }

    /// @notice withdraw stuck funds
    function withdrawStuckFunds(address _token, address _receiver, uint256 _amount) public onlyOwner {
        if (_token == 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE) {
            payable(_receiver).transfer(_amount);
        } else {
            IERC20(_token).safeTransfer(_receiver, _amount);
        }
    }

    /// @notice Destroy the contract
    /// @dev Deprecated method, selfdestruct will soon just send eth
    function kill() public onlyAdmin {
        selfdestruct(payable(msg.sender));
    }
}








contract DFSRegistry is AdminAuth {
    error EntryAlreadyExistsError(bytes4);
    error EntryNonExistentError(bytes4);
    error EntryNotInChangeError(bytes4);
    error ChangeNotReadyError(uint256,uint256);
    error EmptyPrevAddrError(bytes4);
    error AlreadyInContractChangeError(bytes4);
    error AlreadyInWaitPeriodChangeError(bytes4);

    event AddNewContract(address,bytes4,address,uint256);
    event RevertToPreviousAddress(address,bytes4,address,address);
    event StartContractChange(address,bytes4,address,address);
    event ApproveContractChange(address,bytes4,address,address);
    event CancelContractChange(address,bytes4,address,address);
    event StartWaitPeriodChange(address,bytes4,uint256);
    event ApproveWaitPeriodChange(address,bytes4,uint256,uint256);
    event CancelWaitPeriodChange(address,bytes4,uint256,uint256);

    struct Entry {
        address contractAddr;
        uint256 waitPeriod;
        uint256 changeStartTime;
        bool inContractChange;
        bool inWaitPeriodChange;
        bool exists;
    }

    mapping(bytes4 => Entry) public entries;
    mapping(bytes4 => address) public previousAddresses;

    mapping(bytes4 => address) public pendingAddresses;
    mapping(bytes4 => uint256) public pendingWaitTimes;

    /// @notice Given an contract id returns the registered address
    /// @dev Id is keccak256 of the contract name
    /// @param _id Id of contract
    function getAddr(bytes4 _id) public view returns (address) {
        return entries[_id].contractAddr;
    }

    /// @notice Helper function to easily query if id is registered
    /// @param _id Id of contract
    function isRegistered(bytes4 _id) public view returns (bool) {
        return entries[_id].exists;
    }

    /////////////////////////// OWNER ONLY FUNCTIONS ///////////////////////////

    /// @notice Adds a new contract to the registry
    /// @param _id Id of contract
    /// @param _contractAddr Address of the contract
    /// @param _waitPeriod Amount of time to wait before a contract address can be changed
    function addNewContract(
        bytes4 _id,
        address _contractAddr,
        uint256 _waitPeriod
    ) public onlyOwner {
        if (entries[_id].exists){
            revert EntryAlreadyExistsError(_id);
        }

        entries[_id] = Entry({
            contractAddr: _contractAddr,
            waitPeriod: _waitPeriod,
            changeStartTime: 0,
            inContractChange: false,
            inWaitPeriodChange: false,
            exists: true
        });

        emit AddNewContract(msg.sender, _id, _contractAddr, _waitPeriod);
    }

    /// @notice Reverts to the previous address immediately
    /// @dev In case the new version has a fault, a quick way to fallback to the old contract
    /// @param _id Id of contract
    function revertToPreviousAddress(bytes4 _id) public onlyOwner {
        if (!(entries[_id].exists)){
            revert EntryNonExistentError(_id);
        }
        if (previousAddresses[_id] == address(0)){
            revert EmptyPrevAddrError(_id);
        }

        address currentAddr = entries[_id].contractAddr;
        entries[_id].contractAddr = previousAddresses[_id];

        emit RevertToPreviousAddress(msg.sender, _id, currentAddr, previousAddresses[_id]);
    }

    /// @notice Starts an address change for an existing entry
    /// @dev Can override a change that is currently in progress
    /// @param _id Id of contract
    /// @param _newContractAddr Address of the new contract
    function startContractChange(bytes4 _id, address _newContractAddr) public onlyOwner {
        if (!entries[_id].exists){
            revert EntryNonExistentError(_id);
        }
        if (entries[_id].inWaitPeriodChange){
            revert AlreadyInWaitPeriodChangeError(_id);
        }

        entries[_id].changeStartTime = block.timestamp; // solhint-disable-line
        entries[_id].inContractChange = true;

        pendingAddresses[_id] = _newContractAddr;

        emit StartContractChange(msg.sender, _id, entries[_id].contractAddr, _newContractAddr);
    }

    /// @notice Changes new contract address, correct time must have passed
    /// @param _id Id of contract
    function approveContractChange(bytes4 _id) public onlyOwner {
        if (!entries[_id].exists){
            revert EntryNonExistentError(_id);
        }
        if (!entries[_id].inContractChange){
            revert EntryNotInChangeError(_id);
        }
        if (block.timestamp < (entries[_id].changeStartTime + entries[_id].waitPeriod)){// solhint-disable-line
            revert ChangeNotReadyError(block.timestamp, (entries[_id].changeStartTime + entries[_id].waitPeriod));
        }

        address oldContractAddr = entries[_id].contractAddr;
        entries[_id].contractAddr = pendingAddresses[_id];
        entries[_id].inContractChange = false;
        entries[_id].changeStartTime = 0;

        pendingAddresses[_id] = address(0);
        previousAddresses[_id] = oldContractAddr;

        emit ApproveContractChange(msg.sender, _id, oldContractAddr, entries[_id].contractAddr);
    }

    /// @notice Cancel pending change
    /// @param _id Id of contract
    function cancelContractChange(bytes4 _id) public onlyOwner {
        if (!entries[_id].exists){
            revert EntryNonExistentError(_id);
        }
        if (!entries[_id].inContractChange){
            revert EntryNotInChangeError(_id);
        }

        address oldContractAddr = pendingAddresses[_id];

        pendingAddresses[_id] = address(0);
        entries[_id].inContractChange = false;
        entries[_id].changeStartTime = 0;

        emit CancelContractChange(msg.sender, _id, oldContractAddr, entries[_id].contractAddr);
    }

    /// @notice Starts the change for waitPeriod
    /// @param _id Id of contract
    /// @param _newWaitPeriod New wait time
    function startWaitPeriodChange(bytes4 _id, uint256 _newWaitPeriod) public onlyOwner {
        if (!entries[_id].exists){
            revert EntryNonExistentError(_id);
        }
        if (entries[_id].inContractChange){
            revert AlreadyInContractChangeError(_id);
        }

        pendingWaitTimes[_id] = _newWaitPeriod;

        entries[_id].changeStartTime = block.timestamp; // solhint-disable-line
        entries[_id].inWaitPeriodChange = true;

        emit StartWaitPeriodChange(msg.sender, _id, _newWaitPeriod);
    }

    /// @notice Changes new wait period, correct time must have passed
    /// @param _id Id of contract
    function approveWaitPeriodChange(bytes4 _id) public onlyOwner {
        if (!entries[_id].exists){
            revert EntryNonExistentError(_id);
        }
        if (!entries[_id].inWaitPeriodChange){
            revert EntryNotInChangeError(_id);
        }
        if (block.timestamp < (entries[_id].changeStartTime + entries[_id].waitPeriod)){ // solhint-disable-line
            revert ChangeNotReadyError(block.timestamp, (entries[_id].changeStartTime + entries[_id].waitPeriod));
        }

        uint256 oldWaitTime = entries[_id].waitPeriod;
        entries[_id].waitPeriod = pendingWaitTimes[_id];
        
        entries[_id].inWaitPeriodChange = false;
        entries[_id].changeStartTime = 0;

        pendingWaitTimes[_id] = 0;

        emit ApproveWaitPeriodChange(msg.sender, _id, oldWaitTime, entries[_id].waitPeriod);
    }

    /// @notice Cancel wait period change
    /// @param _id Id of contract
    function cancelWaitPeriodChange(bytes4 _id) public onlyOwner {
        if (!entries[_id].exists){
            revert EntryNonExistentError(_id);
        }
        if (!entries[_id].inWaitPeriodChange){
            revert EntryNotInChangeError(_id);
        }

        uint256 oldWaitPeriod = pendingWaitTimes[_id];

        pendingWaitTimes[_id] = 0;
        entries[_id].inWaitPeriodChange = false;
        entries[_id].changeStartTime = 0;

        emit CancelWaitPeriodChange(msg.sender, _id, oldWaitPeriod, entries[_id].waitPeriod);
    }
}







abstract contract DSAuthority {
    function canCall(
        address src,
        address dst,
        bytes4 sig
    ) public view virtual returns (bool);
}







contract DSAuthEvents {
    event LogSetAuthority(address indexed authority);
    event LogSetOwner(address indexed owner);
}

contract DSAuth is DSAuthEvents {
    DSAuthority public authority;
    address public owner;

    constructor() {
        owner = msg.sender;
        emit LogSetOwner(msg.sender);
    }

    function setOwner(address owner_) public auth {
        owner = owner_;
        emit LogSetOwner(owner);
    }

    function setAuthority(DSAuthority authority_) public auth {
        authority = authority_;
        emit LogSetAuthority(address(authority));
    }

    modifier auth {
        require(isAuthorized(msg.sender, msg.sig), "Not authorized");
        _;
    }

    function isAuthorized(address src, bytes4 sig) internal view returns (bool) {
        if (src == address(this)) {
            return true;
        } else if (src == owner) {
            return true;
        } else if (authority == DSAuthority(address(0))) {
            return false;
        } else {
            return authority.canCall(src, address(this), sig);
        }
    }
}







contract DSNote {
    event LogNote(
        bytes4 indexed sig,
        address indexed guy,
        bytes32 indexed foo,
        bytes32 indexed bar,
        uint256 wad,
        bytes fax
    ) anonymous;

    modifier note {
        bytes32 foo;
        bytes32 bar;

        assembly {
            foo := calldataload(4)
            bar := calldataload(36)
        }

        emit LogNote(msg.sig, msg.sender, foo, bar, msg.value, msg.data);

        _;
    }
}








abstract contract DSProxy is DSAuth, DSNote {
    DSProxyCache public cache; // global cache for contracts

    constructor(address _cacheAddr) {
        if (!(setCache(_cacheAddr))){
            require(isAuthorized(msg.sender, msg.sig), "Not authorized");
        }
    }

    // solhint-disable-next-line no-empty-blocks
    receive() external payable {}

    // use the proxy to execute calldata _data on contract _code
    function execute(bytes memory _code, bytes memory _data)
        public
        payable
        virtual
        returns (address target, bytes32 response);

    function execute(address _target, bytes memory _data)
        public
        payable
        virtual
        returns (bytes32 response);

    //set new cache
    function setCache(address _cacheAddr) public payable virtual returns (bool);
}

contract DSProxyCache {
    mapping(bytes32 => address) cache;

    function read(bytes memory _code) public view returns (address) {
        bytes32 hash = keccak256(_code);
        return cache[hash];
    }

    function write(bytes memory _code) public returns (address target) {
        assembly {
            target := create(0, add(_code, 0x20), mload(_code))
            switch iszero(extcodesize(target))
                case 1 {
                    // throw if contract failed to deploy
                    revert(0, 0)
                }
        }
        bytes32 hash = keccak256(_code);
        cache[hash] = target;
    }
}







interface ISafe {
    enum Operation {
        Call,
        DelegateCall
    }

    function setup(
        address[] calldata _owners,
        uint256 _threshold,
        address to,
        bytes calldata data,
        address fallbackHandler,
        address paymentToken,
        uint256 payment,
        address payable paymentReceiver
    ) external;

    function execTransaction(
        address to,
        uint256 value,
        bytes calldata data,
        Operation operation,
        uint256 safeTxGas,
        uint256 baseGas,
        uint256 gasPrice,
        address gasToken,
        address payable refundReceiver,
        bytes memory signatures
    ) external payable returns (bool success);

    function execTransactionFromModule(
        address to,
        uint256 value,
        bytes memory data,
        Operation operation
    ) external returns (bool success);

    function checkSignatures(
        bytes32 dataHash,
        bytes memory data,
        bytes memory signatures
    ) external view;

    function checkNSignatures(
        address executor,
        bytes32 dataHash,
        bytes memory /* data */,
        bytes memory signatures,
        uint256 requiredSignatures
    ) external view;

    function approveHash(bytes32 hashToApprove) external;

    function domainSeparator() external view returns (bytes32);

    function getTransactionHash(
        address to,
        uint256 value,
        bytes calldata data,
        Operation operation,
        uint256 safeTxGas,
        uint256 baseGas,
        uint256 gasPrice,
        address gasToken,
        address refundReceiver,
        uint256 _nonce
    ) external view returns (bytes32);

    function nonce() external view returns (uint256);

    function setFallbackHandler(address handler) external;

    function getOwners() external view returns (address[] memory);

    function isOwner(address owner) external view returns (bool);

    function getThreshold() external view returns (uint256);

    function enableModule(address module) external;

    function isModuleEnabled(address module) external view returns (bool);

    function disableModule(address prevModule, address module) external;

    function getModulesPaginated(
        address start,
        uint256 pageSize
    ) external view returns (address[] memory array, address next);
}







interface IDSProxyFactory {
    function isProxy(address _proxy) external view returns (bool);
}







contract MainnetProxyFactoryAddresses {
    address internal constant PROXY_FACTORY_ADDR = 0xA26e15C895EFc0616177B7c1e7270A4C7D51C997;
}







contract DSProxyFactoryHelper is MainnetProxyFactoryAddresses {
}









contract CheckWalletType is DSProxyFactoryHelper {
    function isDSProxy(address _proxy) public view returns (bool) {
        return IDSProxyFactory(PROXY_FACTORY_ADDR).isProxy(_proxy);
    }
}







contract DefisaverLogger {
    event RecipeEvent(
        address indexed caller,
        string indexed logName
    );

    event ActionDirectEvent(
        address indexed caller,
        string indexed logName,
        bytes data
    );

    function logRecipeEvent(
        string memory _logName
    ) public {
        emit RecipeEvent(msg.sender, _logName);
    }

    function logActionDirectEvent(
        string memory _logName,
        bytes memory _data
    ) public {
        emit ActionDirectEvent(msg.sender, _logName, _data);
    }
}













abstract contract ActionBase is AdminAuth, ActionsUtilHelper, CheckWalletType {
    event ActionEvent(
        string indexed logName,
        bytes data
    );

    DFSRegistry public constant registry = DFSRegistry(REGISTRY_ADDR);

    DefisaverLogger public constant logger = DefisaverLogger(
        DFS_LOGGER_ADDR
    );

    //Wrong sub index value
    error SubIndexValueError();
    //Wrong return index value
    error ReturnIndexValueError();

    /// @dev Subscription params index range [128, 255]
    uint8 public constant SUB_MIN_INDEX_VALUE = 128;
    uint8 public constant SUB_MAX_INDEX_VALUE = 255;

    /// @dev Return params index range [1, 127]
    uint8 public constant RETURN_MIN_INDEX_VALUE = 1;
    uint8 public constant RETURN_MAX_INDEX_VALUE = 127;

    /// @dev If the input value should not be replaced
    uint8 public constant NO_PARAM_MAPPING = 0;

    /// @dev We need to parse Flash loan actions in a different way
    enum ActionType { FL_ACTION, STANDARD_ACTION, FEE_ACTION, CHECK_ACTION, CUSTOM_ACTION }

    /// @notice Parses inputs and runs the implemented action through a user wallet
    /// @dev Is called by the RecipeExecutor chaining actions together
    /// @param _callData Array of input values each value encoded as bytes
    /// @param _subData Array of subscribed vales, replaces input values if specified
    /// @param _paramMapping Array that specifies how return and subscribed values are mapped in input
    /// @param _returnValues Returns values from actions before, which can be injected in inputs
    /// @return Returns a bytes32 value through user wallet, each actions implements what that value is
    function executeAction(
        bytes memory _callData,
        bytes32[] memory _subData,
        uint8[] memory _paramMapping,
        bytes32[] memory _returnValues
    ) public payable virtual returns (bytes32);

    /// @notice Parses inputs and runs the single implemented action through a user wallet
    /// @dev Used to save gas when executing a single action directly
    function executeActionDirect(bytes memory _callData) public virtual payable;

    /// @notice Returns the type of action we are implementing
    function actionType() public pure virtual returns (uint8);


    //////////////////////////// HELPER METHODS ////////////////////////////

    /// @notice Given an uint256 input, injects return/sub values if specified
    /// @param _param The original input value
    /// @param _mapType Indicated the type of the input in paramMapping
    /// @param _subData Array of subscription data we can replace the input value with
    /// @param _returnValues Array of subscription data we can replace the input value with
    function _parseParamUint(
        uint _param,
        uint8 _mapType,
        bytes32[] memory _subData,
        bytes32[] memory _returnValues
    ) internal pure returns (uint) {
        if (isReplaceable(_mapType)) {
            if (isReturnInjection(_mapType)) {
                _param = uint(_returnValues[getReturnIndex(_mapType)]);
            } else {
                _param = uint256(_subData[getSubIndex(_mapType)]);
            }
        }

        return _param;
    }


    /// @notice Given an addr input, injects return/sub values if specified
    /// @param _param The original input value
    /// @param _mapType Indicated the type of the input in paramMapping
    /// @param _subData Array of subscription data we can replace the input value with
    /// @param _returnValues Array of subscription data we can replace the input value with
    function _parseParamAddr(
        address _param,
        uint8 _mapType,
        bytes32[] memory _subData,
        bytes32[] memory _returnValues
    ) internal view returns (address) {
        if (isReplaceable(_mapType)) {
            if (isReturnInjection(_mapType)) {
                _param = address(bytes20((_returnValues[getReturnIndex(_mapType)])));
            } else {
                /// @dev The last two values are specially reserved for proxy addr and owner addr
                if (_mapType == 254) return address(this); // wallet address
                if (_mapType == 255) return fetchOwnersOrWallet(); // owner if 1/1 wallet or the wallet itself

                _param = address(uint160(uint256(_subData[getSubIndex(_mapType)])));
            }
        }

        return _param;
    }

    /// @notice Given an bytes32 input, injects return/sub values if specified
    /// @param _param The original input value
    /// @param _mapType Indicated the type of the input in paramMapping
    /// @param _subData Array of subscription data we can replace the input value with
    /// @param _returnValues Array of subscription data we can replace the input value with
    function _parseParamABytes32(
        bytes32 _param,
        uint8 _mapType,
        bytes32[] memory _subData,
        bytes32[] memory _returnValues
    ) internal pure returns (bytes32) {
        if (isReplaceable(_mapType)) {
            if (isReturnInjection(_mapType)) {
                _param = (_returnValues[getReturnIndex(_mapType)]);
            } else {
                _param = _subData[getSubIndex(_mapType)];
            }
        }

        return _param;
    }

    /// @notice Checks if the paramMapping value indicated that we need to inject values
    /// @param _type Indicated the type of the input
    function isReplaceable(uint8 _type) internal pure returns (bool) {
        return _type != NO_PARAM_MAPPING;
    }

    /// @notice Checks if the paramMapping value is in the return value range
    /// @param _type Indicated the type of the input
    function isReturnInjection(uint8 _type) internal pure returns (bool) {
        return (_type >= RETURN_MIN_INDEX_VALUE) && (_type <= RETURN_MAX_INDEX_VALUE);
    }

    /// @notice Transforms the paramMapping value to the index in return array value
    /// @param _type Indicated the type of the input
    function getReturnIndex(uint8 _type) internal pure returns (uint8) {
        if (!(isReturnInjection(_type))){
            revert SubIndexValueError();
        }

        return (_type - RETURN_MIN_INDEX_VALUE);
    }

    /// @notice Transforms the paramMapping value to the index in sub array value
    /// @param _type Indicated the type of the input
    function getSubIndex(uint8 _type) internal pure returns (uint8) {
        if (_type < SUB_MIN_INDEX_VALUE){
            revert ReturnIndexValueError();
        }
        return (_type - SUB_MIN_INDEX_VALUE);
    }

    function fetchOwnersOrWallet() internal view returns (address) {
        if (isDSProxy(address(this))) 
            return DSProxy(payable(address(this))).owner();

        // if not DSProxy, we assume we are in context of Safe
        address[] memory owners = ISafe(address(this)).getOwners();
        return owners.length == 1 ? owners[0] : address(this);
    }
}






contract DSMath {
    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x + y;
    }

    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x - y;
    }

    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x * y;
    }

    function div(uint256 x, uint256 y) internal pure returns (uint256 z) {
        return x / y;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        return x <= y ? x : y;
    }

    function max(uint256 x, uint256 y) internal pure returns (uint256 z) {
        return x >= y ? x : y;
    }

    function imin(int256 x, int256 y) internal pure returns (int256 z) {
        return x <= y ? x : y;
    }

    function imax(int256 x, int256 y) internal pure returns (int256 z) {
        return x >= y ? x : y;
    }

    uint256 constant WAD = 10**18;
    uint256 constant RAY = 10**27;

    function wmul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = add(mul(x, y), WAD / 2) / WAD;
    }

    function rmul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = add(mul(x, y), RAY / 2) / RAY;
    }

    function wdiv(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = add(mul(x, WAD), y / 2) / y;
    }

    function rdiv(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = add(mul(x, RAY), y / 2) / y;
    }

    // This famous algorithm is called "exponentiation by squaring"
    // and calculates x^n with x as fixed-point and n as regular unsigned.
    //
    // It's O(log n), instead of O(n) for naive repeated multiplication.
    //
    // These facts are why it works:
    //
    //  If n is even, then x^n = (x^2)^(n/2).
    //  If n is odd,  then x^n = x * x^(n-1),
    //   and applying the equation for even x gives
    //    x^n = x * (x^2)^((n-1) / 2).
    //
    //  Also, EVM division is flooring and
    //    floor[(n-1) / 2] = floor[n / 2].
    //
    function rpow(uint256 x, uint256 n) internal pure returns (uint256 z) {
        z = n % 2 != 0 ? x : RAY;

        for (n /= 2; n != 0; n /= 2) {
            x = rmul(x, x);

            if (n % 2 != 0) {
                z = rmul(z, x);
            }
        }
    }
}






contract DFSExchangeData {

    struct OffchainData {
        address wrapper; // dfs wrapper address for the aggregator (must be in WrapperExchangeRegistry)
        address exchangeAddr; // exchange address we are calling to execute the order (must be in ExchangeAggregatorRegistry)
        address allowanceTarget; // exchange aggregator contract we give allowance to
        uint256 price; // expected price that the aggregator sent us
        uint256 protocolFee; // deprecated (used as a separate fee amount for 0x v1)
        bytes callData; // 0ff-chain calldata the aggregator gives to perform the swap
    }

    struct ExchangeData {
        address srcAddr; // source token address (which we're selling)
        address destAddr; // destination token address (which we're buying)
        uint256 srcAmount; // amount of source token in token decimals
        uint256 destAmount; // amount of bought token in token decimals
        uint256 minPrice; // minPrice we are expecting (checked in DFSExchangeCore)
        uint256 dfsFeeDivider; // service fee divider
        address user; // currently deprecated (used to check custom fees for the user)
        address wrapper; // on-chain wrapper address (must be in WrapperExchangeRegistry)
        bytes wrapperData; // on-chain additional data for on-chain (uniswap route for example)
        OffchainData offchainData; // offchain aggregator order
    }
}







contract Discount is AdminAuth{
    mapping(address => bool) public serviceFeesDisabled;

    function reenableServiceFee(address _wallet) public onlyOwner{
        serviceFeesDisabled[_wallet] = false;
    }

    function disableServiceFee(address _wallet) public onlyOwner{
        serviceFeesDisabled[_wallet] = true;
    }
}







abstract contract IWETH {
    function allowance(address, address) public virtual view returns (uint256);

    function balanceOf(address) public virtual view returns (uint256);

    function approve(address, uint256) public virtual;

    function transfer(address, uint256) public virtual returns (bool);

    function transferFrom(
        address,
        address,
        uint256
    ) public virtual returns (bool);

    function deposit() public payable virtual;

    function withdraw(uint256) public virtual;
}








library TokenUtils {
    using SafeERC20 for IERC20;

    address public constant WETH_ADDR = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public constant ETH_ADDR = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    /// @dev Only approves the amount if allowance is lower than amount, does not decrease allowance
    function approveToken(
        address _tokenAddr,
        address _to,
        uint256 _amount
    ) internal {
        if (_tokenAddr == ETH_ADDR) return;

        if (IERC20(_tokenAddr).allowance(address(this), _to) < _amount) {
            IERC20(_tokenAddr).safeApprove(_to, _amount);
        }
    }

    function pullTokensIfNeeded(
        address _token,
        address _from,
        uint256 _amount
    ) internal returns (uint256) {
        // handle max uint amount
        if (_amount == type(uint256).max) {
            _amount = getBalance(_token, _from);
        }

        if (_from != address(0) && _from != address(this) && _token != ETH_ADDR && _amount != 0) {
            IERC20(_token).safeTransferFrom(_from, address(this), _amount);
        }

        return _amount;
    }

    function withdrawTokens(
        address _token,
        address _to,
        uint256 _amount
    ) internal returns (uint256) {
        if (_amount == type(uint256).max) {
            _amount = getBalance(_token, address(this));
        }

        if (_to != address(0) && _to != address(this) && _amount != 0) {
            if (_token != ETH_ADDR) {
                IERC20(_token).safeTransfer(_to, _amount);
            } else {
                (bool success, ) = _to.call{value: _amount}("");
                require(success, "Eth send fail");
            }
        }

        return _amount;
    }

    function depositWeth(uint256 _amount) internal {
        IWETH(WETH_ADDR).deposit{value: _amount}();
    }

    function withdrawWeth(uint256 _amount) internal {
        IWETH(WETH_ADDR).withdraw(_amount);
    }

    function getBalance(address _tokenAddr, address _acc) internal view returns (uint256) {
        if (_tokenAddr == ETH_ADDR) {
            return _acc.balance;
        } else {
            return IERC20(_tokenAddr).balanceOf(_acc);
        }
    }

    function getTokenDecimals(address _token) internal view returns (uint256) {
        if (_token == ETH_ADDR) return 18;

        return IERC20(_token).decimals();
    }
}








contract DFSExchangeHelper {
    
    using TokenUtils for address;
    
    error InvalidOffchainData();
    error OutOfRangeSlicingError();
    //Order success but amount 0
    error ZeroTokensSwapped();

    using SafeERC20 for IERC20;

    function sendLeftover(
        address _srcAddr,
        address _destAddr,
        address payable _to
    ) internal {
        // clean out any eth leftover
        TokenUtils.ETH_ADDR.withdrawTokens(_to, type(uint256).max);

        _srcAddr.withdrawTokens(_to, type(uint256).max);
        _destAddr.withdrawTokens(_to, type(uint256).max);
    }

    function sliceUint(bytes memory bs, uint256 start) internal pure returns (uint256) {
        if (bs.length < start + 32){
            revert OutOfRangeSlicingError();
        }

        uint256 x;
        assembly {
            x := mload(add(bs, add(0x20, start)))
        }

        return x;
    }

    function writeUint256(
        bytes memory _b,
        uint256 _index,
        uint256 _input
    ) internal pure {
        if (_b.length < _index + 32) {
            revert InvalidOffchainData();
        }

        bytes32 input = bytes32(_input);

        _index += 32;

        // Read the bytes32 from array memory
        assembly {
            mstore(add(_b, _index), input)
        }
    }
}







contract MainnetExchangeAddresses {

    address internal constant FEE_RECIPIENT_ADDRESS = 0x39C4a92Dc506300c3Ea4c67ca4CA611102ee6F2A;
    address internal constant DISCOUNT_ADDRESS = 0x84fE6D4aaD0CA1ce3af7153eecd11729fa7a74f0;
    address internal constant WRAPPER_EXCHANGE_REGISTRY = 0x653893375dD1D942D2C429caB51641F2bf14d426;
    address internal constant EXCHANGE_AGGREGATOR_REGISTRY_ADDR = 0x7b67D9D7993A258C4b2C31CDD9E6cbD5Fb674985;
    address internal constant ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address internal constant TOKEN_GROUP_REGISTRY = 0xcA49e64FE1FE8be40ED30F682edA1b27a6c8611c;
}







contract ExchangeHelper is MainnetExchangeAddresses {
}







contract ExchangeAggregatorRegistry is AdminAuth {
    mapping(address => bool) public exchangeTargetAddresses;

    error EmptyAddrError();

    function setExchangeTargetAddr(address _exchangeAddr, bool _state) public onlyOwner {
        if(_exchangeAddr == address(0)) {
			revert EmptyAddrError();
		}

        exchangeTargetAddresses[_exchangeAddr] = _state;
    }

    function isExchangeAggregatorAddr(address _exchangeAddr) public view returns (bool) {
        return exchangeTargetAddresses[_exchangeAddr];
    }
}






contract WrapperExchangeRegistry is AdminAuth {
	mapping(address => bool) private wrappers;

	error EmptyAddrError();

	function addWrapper(address _wrapper) public onlyOwner {
		if(_wrapper == address(0)) {
			revert EmptyAddrError();
		}

		wrappers[_wrapper] = true;
	}

	function removeWrapper(address _wrapper) public onlyOwner {
		wrappers[_wrapper] = false;
	}

	function isWrapper(address _wrapper) public view returns(bool) {
		return wrappers[_wrapper];
	}
}







interface IExchangeV3 {
    function sell(address _srcAddr, address _destAddr, uint _srcAmount, bytes memory _additionalData) external returns (uint);
    function getSellRate(address _srcAddr, address _destAddr, uint _srcAmount, bytes memory _additionalData) external returns (uint);
}







abstract contract IOffchainWrapper is DFSExchangeData {
    function takeOrder(
        ExchangeData memory _exData
    ) virtual public payable returns (bool success, uint256);
}








contract FeeRecipient is AdminAuth {

    address public wallet;

    constructor(address _newWallet) {
        wallet = _newWallet;
    }

    function getFeeAddr() public view returns (address) {
        return wallet;
    }

    function changeWalletAddr(address _newWallet) public onlyOwner {
        wallet = _newWallet;
    }
}















contract DFSExchangeCore is DFSExchangeHelper, DSMath, DFSExchangeData, ExchangeHelper {
    using SafeERC20 for IERC20;
    using TokenUtils for address;

    error SlippageHitError(uint256 amountBought, uint256 amountExpected);
    error InvalidWrapperError(address wrapperAddr);

    ExchangeAggregatorRegistry internal constant exchangeAggRegistry = ExchangeAggregatorRegistry(EXCHANGE_AGGREGATOR_REGISTRY_ADDR);
    WrapperExchangeRegistry internal constant wrapperRegistry = WrapperExchangeRegistry(WRAPPER_EXCHANGE_REGISTRY);

    /// @notice Internal method that performs a sell on offchain aggregator/on-chain
    /// @dev Useful for other DFS contract to integrate for exchanging
    /// @param exData Exchange data struct
    /// @return (address, uint) Address of the wrapper used and destAmount
    function _sell(ExchangeData memory exData) internal returns (address, uint256) {
        uint256 amountWithoutFee = exData.srcAmount;
        address wrapperAddr = exData.offchainData.wrapper;
        bool offChainSwapSuccess;

        uint256 destBalanceBefore = exData.destAddr.getBalance(address(this));

        // Takes DFS exchange fee
        if (exData.dfsFeeDivider != 0) {
            exData.srcAmount = sub(exData.srcAmount, getFee(
                exData.srcAmount,
                address(this),
                exData.srcAddr,
                exData.dfsFeeDivider
            ));
        }

        // Try offchain aggregator first and then fallback on specific wrapper
        if (exData.offchainData.price > 0) {
            (offChainSwapSuccess, ) = offChainSwap(exData);
        }

        // fallback to desired wrapper if offchain aggregator failed
        if (!offChainSwapSuccess) {
            onChainSwap(exData);
            wrapperAddr = exData.wrapper;
        }

        uint256 destBalanceAfter = exData.destAddr.getBalance(address(this));
        uint256 amountBought = destBalanceAfter - destBalanceBefore;

        // check slippage
        if (amountBought < wmul(exData.minPrice, exData.srcAmount)){
            revert SlippageHitError(amountBought, wmul(exData.minPrice, exData.srcAmount));
        }

        // revert back exData changes to keep it consistent
        exData.srcAmount = amountWithoutFee;

        return (wrapperAddr, amountBought);
    }

    /// @notice Takes order from exchange aggregator and returns bool indicating if it is successful
    /// @param _exData Exchange data
    function offChainSwap(ExchangeData memory _exData)
        internal
        returns (bool success, uint256)
    {
        /// @dev Check if exchange address is in our registry to not call an untrusted contract
        if (!exchangeAggRegistry.isExchangeAggregatorAddr(_exData.offchainData.exchangeAddr)) {
            return (false, 0);
        }

        /// @dev Check if we have the address is a registered wrapper
        if (!wrapperRegistry.isWrapper(_exData.offchainData.wrapper)) {
            return (false, 0);
        }

        // send src amount
        IERC20(_exData.srcAddr).safeTransfer(_exData.offchainData.wrapper, _exData.srcAmount);

        return IOffchainWrapper(_exData.offchainData.wrapper).takeOrder(_exData);
    }

    /// @notice Calls wrapper contract for exchange to preform an on-chain swap
    /// @param _exData Exchange data struct
    /// @return swappedTokens Dest amount of tokens we get after sell
    function onChainSwap(ExchangeData memory _exData)
        internal
        returns (uint256 swappedTokens)
    {
        if (!(WrapperExchangeRegistry(WRAPPER_EXCHANGE_REGISTRY).isWrapper(_exData.wrapper))){
            revert InvalidWrapperError(_exData.wrapper);
        }

        IERC20(_exData.srcAddr).safeTransfer(_exData.wrapper, _exData.srcAmount);

        swappedTokens = IExchangeV3(_exData.wrapper).sell(
            _exData.srcAddr,
            _exData.destAddr,
            _exData.srcAmount,
            _exData.wrapperData
        );
    }

    /// @notice Takes a feePercentage and sends it to wallet
    /// @param _amount Amount of the whole trade
    /// @param _wallet Address of the users wallet (safe or dsproxy)
    /// @param _token Address of the token
    /// @param _dfsFeeDivider Dfs fee divider
    /// @return feeAmount Amount owner earned on the fee
    function getFee(
        uint256 _amount,
        address _wallet,
        address _token,
        uint256 _dfsFeeDivider
    ) internal returns (uint256 feeAmount) {
        if (_dfsFeeDivider != 0 && Discount(DISCOUNT_ADDRESS).serviceFeesDisabled(_wallet)) {
            _dfsFeeDivider = 0;
        }

        if (_dfsFeeDivider == 0) {
            feeAmount = 0;
        } else {
            feeAmount = _amount / _dfsFeeDivider;
            address walletAddr = FeeRecipient(FEE_RECIPIENT_ADDRESS).getFeeAddr();
            _token.withdrawTokens(walletAddr, feeAmount);
        }
    }
}







contract TokenGroupRegistry is AdminAuth {
    /// @dev 0.25% fee as we divide the amount with this number
    uint256 public constant STANDARD_FEE_DIVIDER = 400;

    uint256 public constant STABLE_FEE_DIVIDER = 1000;
    uint256 public constant MAX_FEE_DIVIDER = 50;

    /// @dev maps token address to a registered group it belongs to
    mapping(address => uint256) public groupIds;

    /// @dev Array of groups where the index is the grouped id and the value is the fee
    uint256[] public feesPerGroup;

    enum Groups { NOT_LISTED, BANNED, STABLECOIN, ETH_BASED, BTC_BASED}

    error FeeTooHigh(uint256 fee);
    error GroupNonExistent(uint256 groupId);

    constructor() {
        feesPerGroup.push(STANDARD_FEE_DIVIDER); // NOT_LISTED
        feesPerGroup.push(0);                    // BANNED
        feesPerGroup.push(STABLE_FEE_DIVIDER);   // STABLECOIN
        feesPerGroup.push(STABLE_FEE_DIVIDER);   // ETH_BASED
        feesPerGroup.push(STABLE_FEE_DIVIDER);   // BTC_BASED
    }

    /// @notice Checks if 2 tokens are in the same group and returns the correct exchange fee for the pair
    function getFeeForTokens(address _sellToken, address _buyToken) public view returns (uint256) {
        uint256 firstId = groupIds[_sellToken];
        uint256 secondId = groupIds[_buyToken];

        // check if in the ban list, can just check the first token as we take fee from it
        if (firstId == uint8(Groups.BANNED)) {
            return 0;
        }
    
        if (firstId == secondId) {
            return feesPerGroup[secondId];
        }

        return STANDARD_FEE_DIVIDER;
    }

    /////////////////////////////// ONLY OWNER FUNCTIONS ///////////////////////////////

    /// @notice Adds token to an existing group
    /// @dev This will overwrite if token is part of a different group
    /// @dev Groups needs to exist to add to it
    function addTokenInGroup(address _tokenAddr, uint256 _groupId) public onlyOwner {
        if (_groupId > feesPerGroup.length) revert GroupNonExistent(_groupId);

        groupIds[_tokenAddr] = _groupId;
    }

    /// @notice Add multiple tokens to a group
    function addTokensInGroup(address[] memory _tokensAddr, uint256 _groupId) public onlyOwner {
        if (_groupId > feesPerGroup.length) revert GroupNonExistent(_groupId);

        for (uint256 i; i < _tokensAddr.length; ++i) {
            groupIds[_tokensAddr[i]] = _groupId;
        }
    }

    /// @notice Create new group and add tokens
    /// @dev Divider has to gte 50, which means max fee is 2%
    function addNewGroup(address[] memory _tokensAddr, uint256 _feeDivider) public onlyOwner {
        if(_feeDivider < MAX_FEE_DIVIDER) revert FeeTooHigh(_feeDivider);

        feesPerGroup.push(_feeDivider);

        addTokensInGroup(_tokensAddr, feesPerGroup.length - 1);
    }

    /// @notice Change existing group fee
    /// @dev Divider has to be gte 50, which means max fee is 2%
    function changeGroupFee(uint256 _groupId, uint256 _newFeeDivider) public onlyOwner {
        if(_newFeeDivider < MAX_FEE_DIVIDER) revert FeeTooHigh(_newFeeDivider);

        feesPerGroup[_groupId] = _newFeeDivider;
    }

}











contract DFSSell is ActionBase, DFSExchangeCore {

    using TokenUtils for address;

    uint256 internal constant RECIPE_FEE = 400;

    struct Params {
        ExchangeData exchangeData;
        address from;
        address to;
    }

    /// @inheritdoc ActionBase
    function executeAction(
        bytes memory _callData,
        bytes32[] memory _subData,
        uint8[] memory _paramMapping,
        bytes32[] memory _returnValues
    ) public virtual override payable returns (bytes32) {
        Params memory params = parseInputs(_callData);

        params.exchangeData.srcAddr = _parseParamAddr(
            params.exchangeData.srcAddr,
            _paramMapping[0],
            _subData,
            _returnValues
        );
        params.exchangeData.destAddr = _parseParamAddr(
            params.exchangeData.destAddr,
            _paramMapping[1],
            _subData,
            _returnValues
        );

        params.exchangeData.srcAmount = _parseParamUint(
            params.exchangeData.srcAmount,
            _paramMapping[2],
            _subData,
            _returnValues
        );
        params.from = _parseParamAddr(params.from, _paramMapping[3], _subData, _returnValues);
        params.to = _parseParamAddr(params.to, _paramMapping[4], _subData, _returnValues);

        (uint256 exchangedAmount, bytes memory logData) = _dfsSell(params.exchangeData, params.from, params.to, false);
        emit ActionEvent("DFSSell", logData);
        return bytes32(exchangedAmount);
    }

    /// @inheritdoc ActionBase
    function executeActionDirect(bytes memory _callData) public virtual override payable   {
        Params memory params = parseInputs(_callData);
        (, bytes memory logData) = _dfsSell(params.exchangeData, params.from, params.to, true);
        logger.logActionDirectEvent("DFSSell", logData);
    }

    /// @inheritdoc ActionBase
    function actionType() public virtual override pure returns (uint8) {
        return uint8(ActionType.STANDARD_ACTION);
    }


    //////////////////////////// ACTION LOGIC ////////////////////////////

    /// @notice Sells a specified srcAmount for the dest token
    /// @param _exchangeData DFS Exchange data struct
    /// @param _from Address from which we'll pull the srcTokens
    /// @param _to Address where we'll send the _to token
    /// @param _isDirect True if it's just one sell action, false if part of recipe
    function _dfsSell(
        ExchangeData memory _exchangeData,
        address _from,
        address _to,
        bool _isDirect
    ) internal returns (uint256, bytes memory) {
        // if we set srcAmount to max, take the whole user's wallet balance
        if (_exchangeData.srcAmount == type(uint256).max) {
            _exchangeData.srcAmount = _exchangeData.srcAddr.getBalance(address(this));
        }

        // if source and destination address are same we want to skip exchanging and take no fees
        if (_exchangeData.srcAddr == _exchangeData.destAddr){
            bytes memory sameAssetLogData = abi.encode(
                address(0),
                _exchangeData.srcAddr,
                _exchangeData.destAddr,
                _exchangeData.srcAmount,
                _exchangeData.srcAmount,
                0
        );
            return (_exchangeData.srcAmount, sameAssetLogData);
        }

        // Wrap eth if sent directly
        if (_exchangeData.srcAddr == TokenUtils.ETH_ADDR) {
            TokenUtils.depositWeth(_exchangeData.srcAmount);
            _exchangeData.srcAddr = TokenUtils.WETH_ADDR;
        } else {
            _exchangeData.srcAddr.pullTokensIfNeeded(_from, _exchangeData.srcAmount);
        }

        // We always swap with weth, convert token addr when eth sent for unwrapping later
        bool isEthDest;
        if (_exchangeData.destAddr == TokenUtils.ETH_ADDR) {
            _exchangeData.destAddr = TokenUtils.WETH_ADDR;
            isEthDest = true;
        } 

        /// @dev only check for custom fee if a non standard fee is sent
        if (!_isDirect) {
            if (_exchangeData.dfsFeeDivider != RECIPE_FEE) {
                _exchangeData.dfsFeeDivider = TokenGroupRegistry(TOKEN_GROUP_REGISTRY).getFeeForTokens(
                    _exchangeData.srcAddr,
                    _exchangeData.destAddr
                );
            }
        } else {
            _exchangeData.dfsFeeDivider = 0;
        }
        

        (address wrapper, uint256 exchangedAmount) = _sell(_exchangeData);

        if (isEthDest) {
            TokenUtils.withdrawWeth(exchangedAmount);

            (bool success, ) = _to.call{value: exchangedAmount}("");
            require(success, "Eth send failed");
        } else {
             _exchangeData.destAddr.withdrawTokens(_to, exchangedAmount);
        }

        bytes memory logData = abi.encode(
            wrapper,
            _exchangeData.srcAddr,
            _exchangeData.destAddr,
            _exchangeData.srcAmount,
            exchangedAmount,
            _exchangeData.dfsFeeDivider
        );
        return (exchangedAmount, logData);
    }

    function parseInputs(bytes memory _callData) public pure returns (Params memory params) {
        params = abi.decode(_callData, (Params));
    }
}







interface ILendingPoolAddressesProviderV2 {
  event LendingPoolUpdated(address indexed newAddress);
  event ConfigurationAdminUpdated(address indexed newAddress);
  event EmergencyAdminUpdated(address indexed newAddress);
  event LendingPoolConfiguratorUpdated(address indexed newAddress);
  event LendingPoolCollateralManagerUpdated(address indexed newAddress);
  event PriceOracleUpdated(address indexed newAddress);
  event LendingRateOracleUpdated(address indexed newAddress);
  event ProxyCreated(bytes32 id, address indexed newAddress);
  event AddressSet(bytes32 id, address indexed newAddress, bool hasProxy);

  function setAddress(bytes32 id, address newAddress) external;

  function setAddressAsProxy(bytes32 id, address impl) external;

  function getAddress(bytes32 id) external view returns (address);

  function getLendingPool() external view returns (address);

  function setLendingPoolImpl(address pool) external;

  function getLendingPoolConfigurator() external view returns (address);

  function setLendingPoolConfiguratorImpl(address configurator) external;

  function getLendingPoolCollateralManager() external view returns (address);

  function setLendingPoolCollateralManager(address manager) external;

  function getPoolAdmin() external view returns (address);

  function setPoolAdmin(address admin) external;

  function getEmergencyAdmin() external view returns (address);

  function setEmergencyAdmin(address admin) external;

  function getPriceOracle() external view returns (address);

  function setPriceOracle(address priceOracle) external;

  function getLendingRateOracle() external view returns (address);

  function setLendingRateOracle(address lendingRateOracle) external;
}







abstract contract IPriceOracleGetterAave {
    function getAssetPrice(address _asset) external virtual view returns (uint256);
    function getAssetsPrices(address[] calldata _assets) external virtual view returns(uint256[] memory);
    function getSourceOfAsset(address _asset) external virtual view returns(address);
    function getFallbackOracle() external virtual view returns(address);
}






interface IAggregatorV3 {
    function decimals() external view returns (uint8);

    function description() external view returns (string memory);

    function version() external view returns (uint256);

    // getRoundData and latestRoundData should both raise "No data present"
    // if they do not have data to report, instead of returning unset values
    // which could be misinterpreted as actual reported values.
    function getRoundData(uint80 _roundId)
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        );

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

    function latestAnswer() external view returns (uint256);

    function getTimestamp(uint256 _roundId) external view returns (uint256);

    function phaseId() external view returns (uint16);

    function phaseAggregators(uint16 _phaseId) external view returns (address);
}






interface IFeedRegistry {
  struct Phase {
    uint16 phaseId;
    uint80 startingAggregatorRoundId;
    uint80 endingAggregatorRoundId;
  }

  event FeedProposed(
    address indexed asset,
    address indexed denomination,
    address indexed proposedAggregator,
    address currentAggregator,
    address sender
  );
  event FeedConfirmed(
    address indexed asset,
    address indexed denomination,
    address indexed latestAggregator,
    address previousAggregator,
    uint16 nextPhaseId,
    address sender
  );

  // V3 AggregatorV3Interface

  function decimals(
    address base,
    address quote
  )
    external
    view
    returns (
      uint8
    );

  function description(
    address base,
    address quote
  )
    external
    view
    returns (
      string memory
    );

  function version(
    address base,
    address quote
  )
    external
    view
    returns (
      uint256
    );

  function latestRoundData(
    address base,
    address quote
  )
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function getRoundData(
    address base,
    address quote,
    uint80 _roundId
  )
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  // V2 AggregatorInterface

  function latestAnswer(
    address base,
    address quote
  )
    external
    view
    returns (
      int256 answer
    );

  function latestTimestamp(
    address base,
    address quote
  )
    external
    view
    returns (
      uint256 timestamp
    );

  function latestRound(
    address base,
    address quote
  )
    external
    view
    returns (
      uint256 roundId
    );

  function getAnswer(
    address base,
    address quote,
    uint256 roundId
  )
    external
    view
    returns (
      int256 answer
    );

  function getTimestamp(
    address base,
    address quote,
    uint256 roundId
  )
    external
    view
    returns (
      uint256 timestamp
    );


  function isFeedEnabled(
    address aggregator
  )
    external
    view
    returns (
      bool
    );

  function getPhase(
    address base,
    address quote,
    uint16 phaseId
  )
    external
    view
    returns (
      Phase memory phase
    );

  // Round helpers


  function getPhaseRange(
    address base,
    address quote,
    uint16 phaseId
  )
    external
    view
    returns (
      uint80 startingRoundId,
      uint80 endingRoundId
    );

  function getPreviousRoundId(
    address base,
    address quote,
    uint80 roundId
  ) external
    view
    returns (
      uint80 previousRoundId
    );

  function getNextRoundId(
    address base,
    address quote,
    uint80 roundId
  ) external
    view
    returns (
      uint80 nextRoundId
    );

  // Feed management

  function proposeFeed(
    address base,
    address quote,
    address aggregator
  ) external;

  function confirmFeed(
    address base,
    address quote,
    address aggregator
  ) external;

  // Proposed aggregator

  function proposedGetRoundData(
    address base,
    address quote,
    uint80 roundId
  )
    external
    view
    returns (
      uint80 id,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function proposedLatestRoundData(
    address base,
    address quote
  )
    external
    view
    returns (
      uint80 id,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  // Phases
  function getCurrentPhaseId(
    address base,
    address quote
  )
    external
    view
    returns (
      uint16 currentPhaseId
    );

    function getFeed(address base, address quote) external view returns (address);
}








interface IWStEth {
    function wrap(uint256 _stETHAmount) external returns (uint256);
    function unwrap(uint256 _wstETHAmount) external returns (uint256);
    function stEthPerToken() external view returns (uint256);
    function tokensPerStEth() external view returns (uint256);
}







library Denominations {
  address public constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
  address public constant BTC = 0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB;

  // Fiat currencies follow https://en.wikipedia.org/wiki/ISO_4217
  address public constant USD = address(840);
  address public constant GBP = address(826);
  address public constant EUR = address(978);
  address public constant JPY = address(392);
  address public constant KRW = address(410);
  address public constant CNY = address(156);
  address public constant AUD = address(36);
  address public constant CAD = address(124);
  address public constant CHF = address(756);
  address public constant ARS = address(32);
  address public constant PHP = address(608);
  address public constant NZD = address(554);
  address public constant SGD = address(702);
  address public constant NGN = address(566);
  address public constant ZAR = address(710);
  address public constant RUB = address(643);
  address public constant INR = address(356);
  address public constant BRL = address(986);
}







contract MainnetUtilAddresses {
    address internal refillCaller = 0x33fDb79aFB4456B604f376A45A546e7ae700e880;
    address internal feeAddr = 0x76720aC2574631530eC8163e4085d6F98513fb27;

    address internal constant BOT_REGISTRY_ADDRESS = 0x637726f8b08a7ABE3aE3aCaB01A80E2d8ddeF77B;
    address internal constant UNI_V2_ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address internal constant MKR_PROXY_REGISTRY = 0x4678f0a6958e4D2Bc4F1BAF7Bc52E8F3564f3fE4;
    address internal constant AAVE_MARKET = 0xB53C1a33016B2DC2fF3653530bfF1848a515c8c5;
    address internal constant AAVE_V3_MARKET = 0x2f39d218133AFaB8F2B819B1066c7E434Ad94E9e;
    address internal constant SPARK_MARKET = 0x02C3eA4e34C0cBd694D2adFa2c690EECbC1793eE;

    address internal constant DFS_PROXY_REGISTRY_ADDR = 0x29474FdaC7142f9aB7773B8e38264FA15E3805ed;

    address internal constant WETH_ADDR = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address internal constant ETH_ADDR = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address internal constant WSTETH_ADDR = 0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0;
    address internal constant STETH_ADDR = 0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84;
    address internal constant WBTC_ADDR = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
    address internal constant CHAINLINK_WBTC_ADDR = 0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB;
    address internal constant DAI_ADDR = 0x6B175474E89094C44Da98b954EedeAC495271d0F;

    address internal constant FEE_RECEIVER_ADMIN_ADDR = 0xA74e9791D7D66c6a14B2C571BdA0F2A1f6D64E06;

    address internal constant UNI_V3_ROUTER = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
    address internal constant UNI_V3_QUOTER = 0xb27308f9F90D607463bb33eA1BeBb41C27CE5AB6;

    address internal constant FEE_RECIPIENT = 0x39C4a92Dc506300c3Ea4c67ca4CA611102ee6F2A;

    // not needed on mainnet
    address internal constant DEFAULT_BOT = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    address public constant CHAINLINK_FEED_REGISTRY = 0x47Fb2585D2C56Fe188D0E6ec628a38b74fCeeeDf;
}







contract UtilHelper is MainnetUtilAddresses{
}















contract TokenPriceHelper is DSMath, UtilHelper {
    IFeedRegistry public constant feedRegistry = IFeedRegistry(CHAINLINK_FEED_REGISTRY);

    /// @dev Helper function that returns chainlink price data
    /// @param _inputTokenAddr Token address we are looking the usd price for
    /// @param _roundId Chainlink roundId, if 0 uses the latest
    function getRoundInfo(address _inputTokenAddr, uint80 _roundId, IAggregatorV3 aggregator)
        public
        view
        returns (uint256, uint256 updateTimestamp)
    {
        int256 price;

        /// @dev Price staleness not checked, the risk has been deemed acceptable
        if (_roundId == 0) {
            (, price, , updateTimestamp, ) = aggregator.latestRoundData();
        } else {
            (, price, , updateTimestamp, ) = aggregator.getRoundData(_roundId);
        }

        // no price for wsteth, can calculate from steth
        if (_inputTokenAddr == WSTETH_ADDR) price = getWStEthPrice(price);

        return (uint256(price), updateTimestamp);
    }

    /// @dev Helper function that returns chainlink price data
    /// @param _inputTokenAddr Token address we are looking the usd price for
    /// @param _roundId Chainlink roundId, if 0 uses the latest
    function getRoundInfo(address _inputTokenAddr, uint80 _roundId)
        public
        view
        returns (uint256, uint256 updateTimestamp)
    {
        address tokenAddr = getAddrForChainlinkOracle(_inputTokenAddr);
        IAggregatorV3 aggregator = IAggregatorV3(feedRegistry.getFeed(tokenAddr, Denominations.USD));

        return getRoundInfo(_inputTokenAddr, _roundId, aggregator);
    }

    /// @dev helper function that returns latest token price in USD
    /// @dev 1. Chainlink USD feed
    /// @dev 2. Chainlink ETH feed
    /// @dev 3. Aave feed
    /// @dev if no price found return 0
    function getPriceInUSD(address _inputTokenAddr) public view returns (uint256) {
        address chainlinkTokenAddr = getAddrForChainlinkOracle(_inputTokenAddr);

        int256 price;
        price = getChainlinkPriceInUSD(chainlinkTokenAddr, true);
        if (price == 0){
            price = int256(getAaveTokenPriceInUSD(_inputTokenAddr));
        }
        if (price == 0){
            price = int256(getAaveV3TokenPriceInUSD(_inputTokenAddr));
        }
        if (price == 0){
            price = int256(getSparkTokenPriceInUSD(_inputTokenAddr));
        }
        if (price == 0){
            return 0;
        }

        if (_inputTokenAddr == WSTETH_ADDR) price = getWStEthPrice(price);
        if (_inputTokenAddr == WBTC_ADDR) price = getWBtcPrice(price);
        return uint256(price);
    }

    /// @dev helper function that returns latest token price in USD
    /// @dev 1. Chainlink USD feed
    /// @dev 2. Chainlink ETH feed
    /// @dev 3. Aave feed
    /// @dev if no price found return 0
    /// @dev expect WBTC and WSTETH to have chainlink USD price
    function getPriceInETH(address _inputTokenAddr) public view returns (uint256) {
        address chainlinkTokenAddr = getAddrForChainlinkOracle(_inputTokenAddr);

        uint256 chainlinkPriceInUSD = uint256(getChainlinkPriceInUSD(chainlinkTokenAddr, false));
        if (chainlinkPriceInUSD != 0){
            uint256 chainlinkETHPriceInUSD = uint256(getChainlinkPriceInUSD(ETH_ADDR, false));
            uint256 priceInEth = wdiv(chainlinkPriceInUSD, chainlinkETHPriceInUSD);
            if (_inputTokenAddr == WSTETH_ADDR) return uint256(getWStEthPrice(int256(priceInEth)));
            if (_inputTokenAddr == WBTC_ADDR) return uint256(getWBtcPrice(int256(priceInEth)));
            return priceInEth;
        }

        uint256 chainlinkPriceInETH = uint256(getChainlinkPriceInETH(chainlinkTokenAddr));
        if (chainlinkPriceInETH != 0) return chainlinkPriceInETH;

        uint256 aavePriceInETH = getAaveTokenPriceInETH(_inputTokenAddr);
        if (aavePriceInETH != 0) return aavePriceInETH;

        uint256 aaveV3PriceInETH = getAaveV3TokenPriceInETH(_inputTokenAddr);
        if (aaveV3PriceInETH != 0) return aaveV3PriceInETH;

        uint256 sparkPriceInETH = getSparkTokenPriceInETH(_inputTokenAddr);
        if (sparkPriceInETH != 0) return sparkPriceInETH;
        
        return 0;
    }

    /// @dev If there's no USD price feed can fallback to ETH price feed, if there's no USD or ETH price feed return 0
    function getChainlinkPriceInUSD(address _inputTokenAddr, bool _useFallback) public view returns (int256 chainlinkPriceInUSD) {
        try feedRegistry.latestRoundData(_inputTokenAddr, Denominations.USD) returns (uint80, int256 answer, uint256, uint256, uint80){
            chainlinkPriceInUSD = answer;
        } catch {
            if (_useFallback){
                uint256 chainlinkPriceInETH = uint256(getChainlinkPriceInETH(_inputTokenAddr));
                uint256 chainlinkETHPriceInUSD = uint256(getChainlinkPriceInUSD(ETH_ADDR, false));
                chainlinkPriceInUSD = int256(wmul(chainlinkPriceInETH, chainlinkETHPriceInUSD));
            } else {
                chainlinkPriceInUSD = 0;
            }
        }
    }

    /// @dev If there's no ETH price feed returns 0
    function getChainlinkPriceInETH(address _inputTokenAddr) public view returns (int256 chainlinkPriceInETH) {
        try feedRegistry.latestRoundData(_inputTokenAddr, Denominations.ETH) returns (uint80, int256 answer, uint256, uint256, uint80){
            chainlinkPriceInETH = answer;
        } catch {
            chainlinkPriceInETH = 0;
        }
    }
    
    /// @dev chainlink uses different addresses for WBTC and ETH
    /// @dev there is only STETH price feed so we use that for WSTETH and handle later 
    function getAddrForChainlinkOracle(address _inputTokenAddr)
        public
        pure
        returns (address tokenAddrForChainlinkUsage)
    {
        if (_inputTokenAddr == WETH_ADDR) {
            tokenAddrForChainlinkUsage = ETH_ADDR;
        } else if (_inputTokenAddr == WSTETH_ADDR) {
            tokenAddrForChainlinkUsage = STETH_ADDR;
        } else if (_inputTokenAddr == WBTC_ADDR) {
            tokenAddrForChainlinkUsage = CHAINLINK_WBTC_ADDR;
        } else {
            tokenAddrForChainlinkUsage = _inputTokenAddr;
        }
    }

    function getWStEthPrice(int256 _stEthPrice) public view returns (int256 wStEthPrice) {
        wStEthPrice = int256(wmul(uint256(_stEthPrice), IWStEth(WSTETH_ADDR).stEthPerToken()));
    }

    function getWBtcPrice(int256 _btcPrice) public view returns (int256 wBtcPrice) {
        (, int256 wBtcPriceToPeg, , , ) = feedRegistry.latestRoundData(WBTC_ADDR, CHAINLINK_WBTC_ADDR);
        wBtcPrice = (_btcPrice * wBtcPriceToPeg + 1e8 / 2) / 1e8;
    }

    /// @dev if price isn't found this returns 0
    function getAaveTokenPriceInETH(address _tokenAddr) public view returns (uint256 price) {
        address priceOracleAddress = ILendingPoolAddressesProviderV2(AAVE_MARKET).getPriceOracle();

        try IPriceOracleGetterAave(priceOracleAddress).getAssetPrice(_tokenAddr) returns (uint256 tokenPrice){
            price = tokenPrice;
        } catch {
            price = 0;
        }
    }

    /// @dev if price isn't found this returns 0
    function getAaveTokenPriceInUSD(address _tokenAddr) public view returns (uint256) {
        uint256 tokenAavePriceInETH = getAaveTokenPriceInETH(_tokenAddr);
        uint256 ethPriceInUSD = uint256(getChainlinkPriceInUSD(ETH_ADDR, false));

        return wmul(tokenAavePriceInETH, ethPriceInUSD);
    }

    function getAaveV3TokenPriceInUSD(address _tokenAddr) public view returns (uint256 price) {
        address priceOracleAddress = ILendingPoolAddressesProviderV2(AAVE_V3_MARKET).getPriceOracle();

        try IPriceOracleGetterAave(priceOracleAddress).getAssetPrice(_tokenAddr) returns (uint256 tokenPrice) {
            price = tokenPrice;
        } catch {
            price = 0;
        }
    }

    /// @dev if price isn't found this returns 0
    function getAaveV3TokenPriceInETH(address _tokenAddr) public view returns (uint256) {
        uint256 tokenAavePriceInUSD = getAaveV3TokenPriceInUSD(_tokenAddr);
        uint256 ethPriceInUSD = uint256(getChainlinkPriceInUSD(ETH_ADDR, false));

        return wdiv(tokenAavePriceInUSD, ethPriceInUSD);
    }

    function getSparkTokenPriceInUSD(address _tokenAddr) public view returns (uint256 price) {
        address priceOracleAddress = ILendingPoolAddressesProviderV2(SPARK_MARKET).getPriceOracle();

        try IPriceOracleGetterAave(priceOracleAddress).getAssetPrice(_tokenAddr) returns (uint256 tokenPrice) {
            price = tokenPrice;
        } catch {
            price = 0;
        }
    }

    /// @dev if price isn't found this returns 0
    function getSparkTokenPriceInETH(address _tokenAddr) public view returns (uint256) {
        uint256 tokenSparkPriceInUSD = getSparkTokenPriceInUSD(_tokenAddr);
        uint256 ethPriceInUSD = uint256(getChainlinkPriceInUSD(ETH_ADDR, false));

        return wdiv(tokenSparkPriceInUSD, ethPriceInUSD);
    }
}










contract GasFeeHelper is DSMath, TokenPriceHelper {
    using TokenUtils for address;

    FeeRecipient public constant feeRecipient = FeeRecipient(FEE_RECIPIENT);

    uint256 public constant SANITY_GAS_PRICE = 1000 gwei;

    /// @dev Divider for input amount, 5 bps
    uint256 public constant MAX_DFS_FEE = 2000;

    function calcGasCost(uint256 _gasUsed, address _feeToken, uint256 _l1GasCostInEth) public view returns (uint256 txCost) {
        uint256 gasPrice = tx.gasprice;

        // gas price must be in a reasonable range
        if (tx.gasprice > SANITY_GAS_PRICE) {
            gasPrice = SANITY_GAS_PRICE;
        }

        // can't use more gas than the block gas limit
        if (_gasUsed > block.gaslimit) {
            _gasUsed = block.gaslimit;
        }

        // calc gas used
        txCost = (_gasUsed * gasPrice) + _l1GasCostInEth;

        // convert to token amount
        if (_feeToken != TokenUtils.WETH_ADDR) {
            uint256 price = getPriceInETH(_feeToken);
            uint256 tokenDecimals = _feeToken.getTokenDecimals();

            require(tokenDecimals <= 18, "Token decimal too big");

            if (price > 0) {
                txCost = wdiv(txCost, uint256(price)) / (10**(18 - tokenDecimals));
            } else {
                txCost = 0;
            }
        }
    }
}










contract GasFeeTaker is ActionBase, GasFeeHelper {
    using TokenUtils for address;

    struct GasFeeTakerParams {
        uint256 gasUsed;
        address feeToken;
        uint256 availableAmount;
        uint256 dfsFeeDivider;
    }

    /// @inheritdoc ActionBase
    function executeAction(
        bytes memory _callData,
        bytes32[] memory _subData,
        uint8[] memory _paramMapping,
        bytes32[] memory _returnValues
    ) public payable virtual override returns (bytes32) {
        GasFeeTakerParams memory inputData = parseInputsGasFeeTaker(_callData);

        inputData.feeToken = _parseParamAddr(inputData.feeToken, _paramMapping[0], _subData, _returnValues);
        inputData.availableAmount = _parseParamUint(inputData.availableAmount, _paramMapping[1], _subData, _returnValues);
        inputData.dfsFeeDivider = _parseParamUint(inputData.dfsFeeDivider, _paramMapping[2], _subData, _returnValues);

        /// @dev This means inputData.availableAmount is not being piped into
        /// @dev To stop sender from sending any value here, if not piped take user's wallet balance
        if (_paramMapping[1] == 0) {
            inputData.availableAmount = inputData.feeToken.getBalance(address(this));
        }

        uint256 amountLeft = _takeFee(inputData);

        emit ActionEvent("GasFeeTaker", abi.encode(inputData, amountLeft));
        return bytes32(amountLeft);
    }

    function _takeFee(GasFeeTakerParams memory _inputData) internal returns (uint256 amountLeft) {
        uint256 txCost = calcGasCost(_inputData.gasUsed, _inputData.feeToken, 0);

        // cap at 20% of the max amount
        if (txCost >= (_inputData.availableAmount / 5)) {
            txCost = _inputData.availableAmount / 5;
        }

        if (_inputData.dfsFeeDivider != 0) {
            /// @dev If divider is lower the fee is greater, should be max 5 bps
            if (_inputData.dfsFeeDivider < MAX_DFS_FEE) {
                _inputData.dfsFeeDivider = MAX_DFS_FEE;
            }

            // add amount we take for dfs fee as well
            txCost += _inputData.availableAmount / _inputData.dfsFeeDivider;
        }

        amountLeft = sub(_inputData.availableAmount, txCost);
        _inputData.feeToken.withdrawTokens(feeRecipient.getFeeAddr(), txCost);
    }

    /// @inheritdoc ActionBase
    // solhint-disable-next-line no-empty-blocks
    function executeActionDirect(bytes memory _callData) public payable virtual override {}

    /// @inheritdoc ActionBase
    function actionType() public pure virtual override returns (uint8) {
        return uint8(ActionType.FEE_ACTION);
    }

    function parseInputsGasFeeTaker(bytes memory _callData) public pure returns (GasFeeTakerParams memory inputData) {
        inputData = abi.decode(_callData, (GasFeeTakerParams));
    }
}







contract MainnetMcdAddresses {
    address internal constant POT_ADDR = 0x197E90f9FAD81970bA7976f33CbD77088E5D7cf7;
    address internal constant VAT_ADDR = 0x35D1b3F3D7966A1DFe207aa4514C12a259A0492B;
    address internal constant DAI_JOIN_ADDR = 0x9759A6Ac90977b93B58547b4A71c78317f391A28;
    address internal constant JUG_ADDRESS = 0x19c0976f590D67707E62397C87829d896Dc0f1F1;
    address internal constant SPOTTER_ADDRESS = 0x65C79fcB50Ca1594B025960e539eD7A9a6D434A3;
    address internal constant PROXY_REGISTRY_ADDR = 0x4678f0a6958e4D2Bc4F1BAF7Bc52E8F3564f3fE4;

    address internal constant CDP_REGISTRY = 0xBe0274664Ca7A68d6b5dF826FB3CcB7c620bADF3;
    address internal constant CROPPER = 0x8377CD01a5834a6EaD3b7efb482f678f2092b77e;
    address internal constant MCD_MANAGER_ADDR = 0x5ef30b9986345249bc32d8928B7ee64DE9435E39;
    address internal constant DAI_ADDRESS = 0x6B175474E89094C44Da98b954EedeAC495271d0F;

}







abstract contract IGem {
    function dec() virtual public returns (uint);
    function gem() virtual public returns (IGem);
    function join(address, uint) virtual public payable;
    function exit(address, uint) virtual public;

    function approve(address, uint) virtual public;
    function transfer(address, uint) virtual public returns (bool);
    function transferFrom(address, address, uint) virtual public returns (bool);
    function deposit() virtual public payable;
    function withdraw(uint) virtual public;
    function allowance(address, address) virtual public returns (uint);
}







abstract contract IVat {

    struct Urn {
        uint256 ink;   // Locked Collateral  [wad]
        uint256 art;   // Normalised Debt    [wad]
    }

    struct Ilk {
        uint256 Art;   // Total Normalised Debt     [wad]
        uint256 rate;  // Accumulated Rates         [ray]
        uint256 spot;  // Price with Safety Margin  [ray]
        uint256 line;  // Debt Ceiling              [rad]
        uint256 dust;  // Urn Debt Floor            [rad]
    }

    mapping (bytes32 => mapping (address => Urn )) public urns;
    mapping (bytes32 => Ilk)                       public ilks;
    mapping (bytes32 => mapping (address => uint)) public gem;  // [wad]

    function can(address, address) virtual public view returns (uint);
    function dai(address) virtual public view returns (uint);
    function frob(bytes32, address, address, address, int, int) virtual public;
    function hope(address) virtual public;
    function nope(address) virtual public;
    function move(address, address, uint) virtual public;
    function fork(bytes32, address, address, int, int) virtual public;
}








abstract contract ICdpRegistry {
    function open(
        bytes32 ilk,
        address usr
    ) public virtual returns (uint256);

    function cdps(bytes32, address) virtual public view returns (uint256);
    function owns(uint) virtual public view returns (address);
    function ilks(uint) virtual public view returns (bytes32);

}







interface ICropper {
    function proxy(address) view external returns (address);
    function getOrCreateProxy(address) external returns (address);
    function join(address, address, uint256) external;
    function exit(address, address, uint256) external;
    function flee(address, address, uint256) external;
    function frob(bytes32, address, address, address, int256, int256) external;
    function quit(bytes32, address, address) external;
}







abstract contract IJoin {
    bytes32 public ilk;

    function dec() virtual public view returns (uint);
    function gem() virtual public view returns (IGem);
    function join(address, uint) virtual public payable;
    function exit(address, uint) virtual public;
}







abstract contract IManager {
    function last(address) virtual public returns (uint);
    function cdpCan(address, uint, address) virtual public view returns (uint);
    function ilks(uint) virtual public view returns (bytes32);
    function owns(uint) virtual public view returns (address);
    function urns(uint) virtual public view returns (address);
    function vat() virtual public view returns (address);
    function open(bytes32, address) virtual public returns (uint);
    function give(uint, address) virtual public;
    function cdpAllow(uint, address, uint) virtual public;
    function urnAllow(address, uint) virtual public;
    function frob(uint, int, int) virtual public;
    function flux(uint, address, uint) virtual public;
    function move(uint, address, uint) virtual public;
    function exit(address, uint, address, uint) virtual public;
    function quit(uint, address) virtual public;
    function enter(address, uint) virtual public;
    function shift(uint, uint) virtual public;
}
















contract McdHelper is DSMath, MainnetMcdAddresses {

    IVat public constant vat = IVat(VAT_ADDR);

    error IntOverflow();

    /// @notice Returns a normalized debt _amount based on the current rate
    /// @param _amount Amount of dai to be normalized
    /// @param _rate Current rate of the stability fee
    /// @param _daiVatBalance Balance od Dai in the Vat for that CDP
    function normalizeDrawAmount(uint _amount, uint _rate, uint _daiVatBalance) internal pure returns (int dart) {
        if (_daiVatBalance < _amount * RAY) {
            dart = toPositiveInt((_amount * RAY - _daiVatBalance) / _rate);
            dart = uint(dart) * _rate < _amount * RAY ? dart + 1 : dart;
        }
    }

    /// @notice Converts a number to Rad precision
    /// @param _wad The input number in wad precision
    function toRad(uint _wad) internal pure returns (uint) {
        return _wad * (10 ** 27);
    }

    /// @notice Converts a number to 18 decimal precision
    /// @dev If token decimal is bigger than 18, function reverts
    /// @param _joinAddr Join address of the collateral
    /// @param _amount Number to be converted
    function convertTo18(address _joinAddr, uint256 _amount) internal view returns (uint256) {
        return _amount * (10 ** (18 - IJoin(_joinAddr).dec()));
    }

    /// @notice Converts a uint to int and checks if positive
    /// @param _x Number to be converted
    function toPositiveInt(uint _x) internal pure returns (int y) {
        y = int(_x);
        if (y < 0){
            revert IntOverflow();
        }
    }

    /// @notice Gets Dai amount in Vat which can be added to Cdp
    /// @param _vat Address of Vat contract
    /// @param _daiBalance Amount of dai in vat contract for that urn
    /// @param _urn Urn of the Cdp
    /// @param _ilk Ilk of the Cdp
    function normalizePaybackAmount(address _vat, uint256 _daiBalance, address _urn, bytes32 _ilk) internal view returns (int amount) {

        (, uint rate,,,) = IVat(_vat).ilks(_ilk);
        (, uint art) = IVat(_vat).urns(_ilk, _urn);

        amount = toPositiveInt(_daiBalance / rate);
        amount = uint(amount) <= art ? - amount : - toPositiveInt(art);
    }

    /// @notice Gets the whole debt of the CDP
    /// @param _vat Address of Vat contract
    /// @param _usr Address of the Dai holder
    /// @param _urn Urn of the Cdp
    /// @param _ilk Ilk of the Cdp
    function getAllDebt(address _vat, address _usr, address _urn, bytes32 _ilk) internal view returns (uint daiAmount) {
        (, uint rate,,,) = IVat(_vat).ilks(_ilk);
        (, uint art) = IVat(_vat).urns(_ilk, _urn);
        uint dai = IVat(_vat).dai(_usr);

        uint rad = art * rate - dai;
        daiAmount = rad / RAY;

        // handles precision error (off by 1 wei)
        daiAmount = daiAmount * RAY < rad ? daiAmount + 1 : daiAmount;
    }

    /// @notice Checks if the join address is one of the Ether coll. types
    /// @param _joinAddr Join address to check
    function isEthJoinAddr(address _joinAddr) internal view returns (bool) {
        // if it's dai_join_addr don't check gem() it will fail
        if (_joinAddr == DAI_JOIN_ADDR) return false;

        // if coll is weth it's and eth type coll
        if (address(IJoin(_joinAddr).gem()) == TokenUtils.WETH_ADDR) {
            return true;
        }

        return false;
    }

    /// @notice Returns the underlying token address from the joinAddr
    /// @dev For eth based collateral returns 0xEee... not weth addr
    /// @param _joinAddr Join address to check
    function getTokenFromJoin(address _joinAddr) internal view returns (address) {
        // if it's dai_join_addr don't check gem() it will fail, return dai addr
        if (_joinAddr == DAI_JOIN_ADDR) {
            return DAI_ADDRESS;
        }

        return address(IJoin(_joinAddr).gem());
    }

    function getUrnAndIlk(address _mcdManager, uint256 _vaultId) public view returns (address urn, bytes32 ilk) {
        if (_mcdManager == CROPPER) {
            address owner = ICdpRegistry(CDP_REGISTRY).owns(_vaultId);
            urn = ICropper(CROPPER).proxy(owner);
            ilk = ICdpRegistry(CDP_REGISTRY).ilks(_vaultId);
        } else {
            urn = IManager(_mcdManager).urns(_vaultId);
            ilk = IManager(_mcdManager).ilks(_vaultId);
        }
    }

    /// @notice Gets CDP info (collateral, debt)
    /// @param _manager Manager contract
    /// @param _cdpId Id of the CDP
    /// @param _ilk Ilk of the CDP
    function getCdpInfo(IManager _manager, uint _cdpId, bytes32 _ilk) public view returns (uint, uint) {
        address urn;

        if (address(_manager) == CROPPER) {
            address owner = ICdpRegistry(CDP_REGISTRY).owns(_cdpId);
            urn = ICropper(CROPPER).proxy(owner);
        } else {
            urn = _manager.urns(_cdpId);
        }

        (uint collateral, uint debt) = vat.urns(_ilk, urn);
        (,uint rate,,,) = vat.ilks(_ilk);

        return (collateral, rmul(debt, rate));
    }

    /// @notice Returns all the collateral of the vault, formatted in the correct decimal
    /// @dev Will fail if token is over 18 decimals
    function getAllColl(IManager _mcdManager, address _joinAddr, uint _vaultId) internal view returns (uint amount) {
        bytes32 ilk;

        if (address(_mcdManager) == CROPPER) {
            ilk = ICdpRegistry(CDP_REGISTRY).ilks(_vaultId);
        } else {
            ilk = _mcdManager.ilks(_vaultId);
        }

        (amount, ) = getCdpInfo(
            _mcdManager,
            _vaultId,
            ilk
        );

        if (IJoin(_joinAddr).dec() != 18) {
            return div(amount, 10 ** sub(18, IJoin(_joinAddr).dec()));
        }
    }
}







abstract contract IPipInterface {
    function read() public virtual returns (bytes32);
    function poke() external virtual;
}







abstract contract ISpotter {
    struct Ilk {
        IPipInterface pip;
        uint256 mat;
    }

    mapping (bytes32 => Ilk) public ilks;

    uint256 public par;

}














contract McdRatioHelper is DSMath {

    IVat public constant Vat = IVat(0x35D1b3F3D7966A1DFe207aa4514C12a259A0492B);
    ISpotter public constant spotter = ISpotter(0x65C79fcB50Ca1594B025960e539eD7A9a6D434A3);
    IManager public constant manager = IManager(0x5ef30b9986345249bc32d8928B7ee64DE9435E39);

    /// @notice Gets CDP ratio
    /// @param _vaultId Id of the CDP
    /// @param _nextPrice Next price for user
    function getRatio(uint256 _vaultId, uint256 _nextPrice) public view returns (uint256) {
        bytes32 ilk = manager.ilks(_vaultId);
        uint256 price = (_nextPrice == 0) ? getPrice(ilk) : _nextPrice;

        (uint256 collateral, uint256 debt) = getCdpInfo(_vaultId, ilk);

        if (debt == 0) return 0;

        return rdiv(wmul(collateral, price), debt) / (10**18);
    }

    /// @notice Gets CDP info (collateral, debt)
    /// @param _vaultId Id of the CDP
    /// @param _ilk Ilk of the CDP
    function getCdpInfo(uint256 _vaultId, bytes32 _ilk) public view returns (uint256, uint256) {
        address urn = manager.urns(_vaultId);

        (uint256 collateral, uint256 debt) = Vat.urns(_ilk, urn);
        (, uint256 rate, , , ) = Vat.ilks(_ilk);

        return (collateral, rmul(debt, rate));
    }

    /// @notice Gets a price of the asset
    /// @param _ilk Ilk of the CDP
    function getPrice(bytes32 _ilk) public view returns (uint256) {
        (, uint256 mat) = spotter.ilks(_ilk);
        (, , uint256 spot, , ) = Vat.ilks(_ilk);

        return rmul(rmul(spot, spotter.par()), mat);
    }
}







abstract contract IDaiJoin {
    function vat() public virtual returns (IVat);
    function dai() public virtual returns (IGem);
    function join(address, uint) public virtual payable;
    function exit(address, uint) public virtual;
}







abstract contract IJug {
    struct Ilk {
        uint256 duty;
        uint256  rho;
    }

    mapping (bytes32 => Ilk) public ilks;

    function drip(bytes32) public virtual returns (uint);
}











contract McdBoostComposite is ActionBase, DFSSell, GasFeeTaker, McdHelper, McdRatioHelper {
    using TokenUtils for address;

    error RatioNotLowerThanBefore(uint256, uint256);
    error WrongAsset(address);
    error TargetRatioMiss(uint256, uint256);

    /// @dev 2% offset acceptable
    uint256 internal constant RATIO_OFFSET = 20000000000000000;

    /// @param vaultId Id of the vault
    /// @param joinAddr Collateral join address
    /// @param gasUsed Gas amount to charge in strategies
    /// @param flAddr Flashloan address 0x0 if we're not using flashloan
    /// @param flAmount Amount that the flashloan actions returns if used (must have it because of fee)
    /// @param nextPrice Maker OSM next price if 0 we're using current price (used for ratio check)
    /// @param targetRatio Target ratio to repay if 0 we are not checking the ratio
    /// @param exchangeData Data needed for swap
    struct BoostParams {
        uint256 vaultId;
        address joinAddr;
        uint256 gasUsed;
        address flAddr;
        uint256 flAmount;
        uint256 nextPrice;
        uint256 targetRatio;
        ExchangeData exchangeData;
    }

    /// @inheritdoc ActionBase
    function executeAction(
        bytes calldata _callData,
        bytes32[] memory _subData,
        uint8[] memory _paramMapping,
        bytes32[] memory _returnValues
    ) public payable virtual override(ActionBase, DFSSell, GasFeeTaker) returns (bytes32) {
        BoostParams memory boostParams = _parseCompositeParams(_callData);

        boostParams.vaultId = _parseParamUint(
            boostParams.vaultId,
            _paramMapping[0],
            _subData,
            _returnValues
        );

        boostParams.joinAddr = _parseParamAddr(
            boostParams.joinAddr,
            _paramMapping[1],
            _subData,
            _returnValues
        );

        boostParams.flAmount = _parseParamUint(
            boostParams.flAmount,
            _paramMapping[2],
            _subData,
            _returnValues
        );

        boostParams.exchangeData.srcAddr = _parseParamAddr(
            boostParams.exchangeData.srcAddr,
            _paramMapping[3],
            _subData,
            _returnValues
        );
        boostParams.exchangeData.destAddr = _parseParamAddr(
            boostParams.exchangeData.destAddr,
            _paramMapping[4],
            _subData,
            _returnValues
        );

        boostParams.exchangeData.srcAmount = _parseParamUint(
            boostParams.exchangeData.srcAmount,
            _paramMapping[5],
            _subData,
            _returnValues
        );

        (bytes memory logData, uint256 suppliedAmount) = _boost(boostParams);
        emit ActionEvent("McdBoostComposite", logData);

        return bytes32(suppliedAmount);
    }

    /// @inheritdoc ActionBase
    function executeActionDirect(bytes memory _callData)
        public
        payable
        virtual
        override(ActionBase, DFSSell, GasFeeTaker)
    {
        BoostParams memory boostParams = _parseCompositeParams(_callData);
        (bytes memory logData, ) = _boost(boostParams);
        logger.logActionDirectEvent("McdBoostComposite", logData);
    }

    /// @notice Executes boost logic
    function _boost(BoostParams memory _boostParams)
        internal
        returns (bytes memory logData, uint256 supplyAmount)
    {
        if (_boostParams.exchangeData.srcAddr != DAI_ADDR) {
            revert WrongAsset(_boostParams.exchangeData.srcAddr);
        }

        (address urn, bytes32 ilk) = getUrnAndIlk(MCD_MANAGER_ADDR, _boostParams.vaultId);

        uint256 ratioBefore;
        if (_boostParams.gasUsed != 0) {
             ratioBefore = getRatio(_boostParams.vaultId, _boostParams.nextPrice);
        }

        address collateralAsset = _boostParams.exchangeData.destAddr;
        uint256 boostAmount = _boostParams.exchangeData.srcAmount;

        if (_boostParams.flAddr == address(0)) {
            _drawDebt(boostAmount, _boostParams.vaultId, urn, ilk);
        }

        // Sell debt asset for collateral asset
        (uint256 exchangedAmount, ) = _dfsSell(
            _boostParams.exchangeData,
            address(this),
            address(this),
            false
        );

        // Take gas fee if part of strategy
        if (_boostParams.gasUsed != 0) {
            supplyAmount = _takeFee(
                GasFeeTakerParams(
                    _boostParams.gasUsed,
                    collateralAsset,
                    exchangedAmount,
                    MAX_DFS_FEE
                )
            );
        } else {
            supplyAmount = exchangedAmount;
        }

        // Supply collateral
        {
            int256 vatSupplyAmount = toPositiveInt(
                convertTo18(_boostParams.joinAddr, supplyAmount)
            );
            collateralAsset.approveToken(_boostParams.joinAddr, supplyAmount);
            IJoin(_boostParams.joinAddr).join(urn, supplyAmount);

            IManager(MCD_MANAGER_ADDR).frob(_boostParams.vaultId, vatSupplyAmount, 0);
        }

        // if we're using flashloan draw debt and repay fl
        if (_boostParams.flAddr != address(0)) {
            uint256 daiAmount = _drawDebt(_boostParams.flAmount, _boostParams.vaultId, urn, ilk);
            DAI_ADDR.withdrawTokens(_boostParams.flAddr, daiAmount);
        }

        // check if collateral is higher, only if part of strategy
        if (_boostParams.gasUsed != 0) {
            uint256 ratioAfter = getRatio(_boostParams.vaultId, _boostParams.nextPrice);

            // ratio worst off than before
            if (ratioAfter >= ratioBefore) {
                revert RatioNotLowerThanBefore(ratioBefore, ratioAfter);
            }

            // check if ratio is in the target range
            if (_boostParams.targetRatio != 0 && ratioAfter < (_boostParams.targetRatio - RATIO_OFFSET)) {
                revert TargetRatioMiss(ratioAfter, _boostParams.targetRatio);
            }
        }

        logData = abi.encode(boostAmount, exchangedAmount, supplyAmount, _boostParams.flAddr);
    }

    function _drawDebt(
        uint256 _drawAmount,
        uint256 _vaultId,
        address _urn,
        bytes32 _ilk
    ) internal returns (uint256) {
        uint256 daiVatBalance = vat.dai(_urn);
        uint256 rate = IJug(JUG_ADDRESS).drip(_ilk);
        int256 drawAmountNormalized = normalizeDrawAmount(_drawAmount, rate, daiVatBalance);

        IManager(MCD_MANAGER_ADDR).frob(_vaultId, 0, drawAmountNormalized);
        IManager(MCD_MANAGER_ADDR).move(_vaultId, address(this), toRad(_drawAmount));
        vat.hope(DAI_JOIN_ADDR);
        IDaiJoin(DAI_JOIN_ADDR).exit(address(this), _drawAmount);
        vat.nope(DAI_JOIN_ADDR);

        return _drawAmount;
    }

    /// @inheritdoc ActionBase
    function actionType()
        public
        pure
        virtual
        override(ActionBase, DFSSell, GasFeeTaker)
        returns (uint8)
    {
        return uint8(ActionType.CUSTOM_ACTION);
    }

    function _parseCompositeParams(bytes memory _calldata)
        internal
        pure
        returns (BoostParams memory params)
    {
        params = abi.decode(_calldata, (BoostParams));
    }
}
