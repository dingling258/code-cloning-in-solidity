// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

interface ILERC20 {
    function name() external view returns (string memory);

    function admin() external view returns (address);

    function getAdmin() external view returns (address);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address _account) external view returns (uint256);

    function transfer(
        address _recipient,
        uint256 _amount
    ) external returns (bool);

    function allowance(
        address _owner,
        address _spender
    ) external view returns (uint256);

    function approve(address _spender, uint256 _amount) external returns (bool);

    function transferFrom(
        address _sender,
        address _recipient,
        uint256 _amount
    ) external returns (bool);

    function increaseAllowance(
        address _spender,
        uint256 _addedValue
    ) external returns (bool);

    function decreaseAllowance(
        address _spender,
        uint256 _subtractedValue
    ) external returns (bool);

    function transferOutBlacklistedFunds(address[] calldata _from) external;

    function setLosslessAdmin(address _newAdmin) external;

    function transferRecoveryAdminOwnership(
        address _candidate,
        bytes32 _keyHash
    ) external;

    function acceptRecoveryAdminOwnership(bytes memory _key) external;

    function proposeLosslessTurnOff() external;

    function executeLosslessTurnOff() external;

    function executeLosslessTurnOn() external;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );
    event NewAdmin(address indexed _newAdmin);
    event NewRecoveryAdminProposal(address indexed _candidate);
    event NewRecoveryAdmin(address indexed _newAdmin);
    event LosslessTurnOffProposal(uint256 _turnOffDate);
    event LosslessOff();
    event LosslessOn();
}

interface ILssGovernance {
    function LSS_TEAM_INDEX() external view returns (uint256);

    function TOKEN_OWNER_INDEX() external view returns (uint256);

    function COMMITEE_INDEX() external view returns (uint256);

    function committeeMembersCount() external view returns (uint256);

    function walletDisputePeriod() external view returns (uint256);

    function losslessStaking() external view returns (ILssStaking);

    function losslessReporting() external view returns (ILssReporting);

    function losslessController() external view returns (ILssController);

    function isCommitteeMember(address _account) external view returns (bool);

    function getIsVoted(
        uint256 _reportId,
        uint256 _voterIndex
    ) external view returns (bool);

    function getVote(
        uint256 _reportId,
        uint256 _voterIndex
    ) external view returns (bool);

    function isReportSolved(uint256 _reportId) external view returns (bool);

    function reportResolution(uint256 _reportId) external view returns (bool);

    function getAmountReported(
        uint256 _reportId
    ) external view returns (uint256);

    function setDisputePeriod(uint256 _timeFrame) external;

    function addCommitteeMembers(address[] memory _members) external;

    function removeCommitteeMembers(address[] memory _members) external;

    function losslessVote(uint256 _reportId, bool _vote) external;

    function tokenOwnersVote(uint256 _reportId, bool _vote) external;

    function committeeMemberVote(uint256 _reportId, bool _vote) external;

    function resolveReport(uint256 _reportId) external;

    function proposeWallet(uint256 _reportId, address wallet) external;

    function rejectWallet(uint256 _reportId) external;

    function retrieveFunds(uint256 _reportId) external;

    function retrieveCompensation() external;

    function claimCommitteeReward(uint256 _reportId) external;

    function setCompensationAmount(uint256 _amount) external;

    function losslessClaim(uint256 _reportId) external;

    function extaordinaryRetrieval(
        address[] calldata _address,
        ILERC20 _token
    ) external;

    event NewCommitteeMembers(address[] _members);
    event CommitteeMembersRemoval(address[] _members);
    event LosslessTeamPositiveVote(uint256 indexed _reportId);
    event LosslessTeamNegativeVote(uint256 indexed _reportId);
    event TokenOwnersPositiveVote(uint256 indexed _reportId);
    event TokenOwnersNegativeVote(uint256 indexed _reportId);
    event CommitteeMemberPositiveVote(
        uint256 indexed _reportId,
        address indexed _member
    );
    event CommitteeMemberNegativeVote(
        uint256 indexed _reportId,
        address indexed _member
    );
    event ReportResolve(uint256 indexed _reportId, bool indexed _resolution);
    event WalletProposal(uint256 indexed _reportId, address indexed _wallet);
    event CommitteeMemberClaim(
        uint256 indexed _reportId,
        address indexed _member,
        uint256 indexed _amount
    );
    event CommitteeMajorityReach(
        uint256 indexed _reportId,
        bool indexed _result
    );
    event NewDisputePeriod(uint256 indexed _newPeriod);
    event WalletRejection(uint256 indexed _reportId);
    event FundsRetrieval(uint256 indexed _reportId, uint256 indexed _amount);
    event CompensationRetrieval(
        address indexed _wallet,
        uint256 indexed _amount
    );
    event LosslessClaim(
        ILERC20 indexed _token,
        uint256 indexed _reportID,
        uint256 indexed _amount
    );
    event ExtraordinaryProposalAccept(ILERC20 indexed _token);
}

interface ILssStaking {
    function stakingToken() external returns (ILERC20);

    function losslessReporting() external returns (ILssReporting);

    function losslessController() external returns (ILssController);

    function losslessGovernance() external returns (ILssGovernance);

    function stakingAmount() external returns (uint256);

    function getVersion() external pure returns (uint256);

    function getIsAccountStaked(
        uint256 _reportId,
        address _account
    ) external view returns (bool);

    function getStakerCoefficient(
        uint256 _reportId,
        address _address
    ) external view returns (uint256);

    function stakerClaimableAmount(
        uint256 _reportId
    ) external view returns (uint256);

    function reportCoefficient(
        uint256 _reportId
    ) external view returns (uint256);

    function pause() external;

    function unpause() external;

    function setLssReporting(ILssReporting _losslessReporting) external;

    function setStakingToken(ILERC20 _stakingToken) external;

    function setLosslessGovernance(ILssGovernance _losslessGovernance) external;

    function setStakingAmount(uint256 _stakingAmount) external;

    function stake(uint256 _reportId) external;

    function stakerClaim(uint256 _reportId) external;

    event NewStake(
        ILERC20 indexed _token,
        address indexed _account,
        uint256 indexed _reportId
    );
    event StakerClaim(
        address indexed _staker,
        ILERC20 indexed _token,
        uint256 indexed _reportID,
        uint256 _amount
    );
    event NewStakingAmount(uint256 indexed _newAmount);
    event NewStakingToken(ILERC20 indexed _newToken);
    event NewReportingContract(ILssReporting indexed _newContract);
    event NewGovernanceContract(ILssGovernance indexed _newContract);
}

interface ILssReporting {
    function reporterReward() external returns (uint256);

    function losslessReward() external returns (uint256);

    function stakersReward() external returns (uint256);

    function committeeReward() external returns (uint256);

    function reportLifetime() external view returns (uint256);

    function reportingAmount() external returns (uint256);

    function reportCount() external returns (uint256);

    function stakingToken() external returns (ILERC20);

    function losslessController() external returns (ILssController);

    function losslessGovernance() external returns (ILssGovernance);

    function getVersion() external pure returns (uint256);

    function getRewards()
        external
        view
        returns (
            uint256 _reporter,
            uint256 _lossless,
            uint256 _committee,
            uint256 _stakers
        );

    function report(
        ILERC20 _token,
        address _account
    ) external returns (uint256);

    function reporterClaimableAmount(
        uint256 _reportId
    ) external view returns (uint256);

    function getReportInfo(
        uint256 _reportId
    )
        external
        view
        returns (
            address _reporter,
            address _reportedAddress,
            address _secondReportedAddress,
            uint256 _reportTimestamps,
            ILERC20 _reportTokens,
            bool _secondReports,
            bool _reporterClaimStatus
        );

    function pause() external;

    function unpause() external;

    function setStakingToken(ILERC20 _stakingToken) external;

    function setLosslessGovernance(ILssGovernance _losslessGovernance) external;

    function setReportingAmount(uint256 _reportingAmount) external;

    function setReporterReward(uint256 _reward) external;

    function setLosslessReward(uint256 _reward) external;

    function setStakersReward(uint256 _reward) external;

    function setCommitteeReward(uint256 _reward) external;

    function setReportLifetime(uint256 _lifetime) external;

    function secondReport(uint256 _reportId, address _account) external;

    function reporterClaim(uint256 _reportId) external;

    function retrieveCompensation(address _adr, uint256 _amount) external;

    event ReportSubmission(
        ILERC20 indexed _token,
        address indexed _account,
        uint256 indexed _reportId
    );
    event SecondReportSubmission(
        ILERC20 indexed _token,
        address indexed _account,
        uint256 indexed _reportId
    );
    event NewReportingAmount(uint256 indexed _newAmount);
    event NewStakingToken(ILERC20 indexed _token);
    event NewGovernanceContract(ILssGovernance indexed _adr);
    event NewReporterReward(uint256 indexed _newValue);
    event NewLosslessReward(uint256 indexed _newValue);
    event NewStakersReward(uint256 indexed _newValue);
    event NewCommitteeReward(uint256 indexed _newValue);
    event NewReportLifetime(uint256 indexed _newValue);
    event ReporterClaim(
        address indexed _reporter,
        uint256 indexed _reportId,
        uint256 indexed _amount
    );
    event CompensationRetrieve(address indexed _adr, uint256 indexed _amount);
}

interface ProtectionStrategy {
    function isTransferAllowed(
        address token,
        address sender,
        address recipient,
        uint256 amount
    ) external;
}

interface ILssController {
    // function getLockedAmount(ILERC20 _token, address _account)  returns (uint256);
    // function getAvailableAmount(ILERC20 _token, address _account) external view returns (uint256 amount);
    function retrieveBlacklistedFunds(
        address[] calldata _addresses,
        ILERC20 _token,
        uint256 _reportId
    ) external returns (uint256);

    function whitelist(address _adr) external view returns (bool);

    function dexList(address _dexAddress) external returns (bool);

    function blacklist(address _adr) external view returns (bool);

    function admin() external view returns (address);

    function pauseAdmin() external view returns (address);

    function recoveryAdmin() external view returns (address);

    function guardian() external view returns (address);

    function losslessStaking() external view returns (ILssStaking);

    function losslessReporting() external view returns (ILssReporting);

    function losslessGovernance() external view returns (ILssGovernance);

    function dexTranferThreshold() external view returns (uint256);

    function settlementTimeLock() external view returns (uint256);

    function extraordinaryRetrievalProposalPeriod()
        external
        view
        returns (uint256);

    function pause() external;

    function unpause() external;

    function setAdmin(address _newAdmin) external;

    function setRecoveryAdmin(address _newRecoveryAdmin) external;

    function setPauseAdmin(address _newPauseAdmin) external;

    function setSettlementTimeLock(uint256 _newTimelock) external;

    function setDexTransferThreshold(uint256 _newThreshold) external;

    function setDexList(address[] calldata _dexList, bool _value) external;

    function setWhitelist(address[] calldata _addrList, bool _value) external;

    function addToBlacklist(address _adr) external;

    function resolvedNegatively(address _adr) external;

    function setStakingContractAddress(ILssStaking _adr) external;

    function setReportingContractAddress(ILssReporting _adr) external;

    function setGovernanceContractAddress(ILssGovernance _adr) external;

    function setTokenMintLimit(ILERC20 _token, uint256 limit) external;

    function setTokenMintPeriod(ILERC20 _token, uint256 _period) external;

    function setTokenBurnLimit(ILERC20 _token, uint256 _limit) external;

    function setTokenBurnPeriod(ILERC20 _token, uint256 _period) external;

    function proposeNewSettlementPeriod(
        ILERC20 _token,
        uint256 _seconds
    ) external;

    function executeNewSettlementPeriod(ILERC20 _token) external;

    function activateEmergency(ILERC20 _token) external;

    function deactivateEmergency(ILERC20 _token) external;

    function setGuardian(address _newGuardian) external;

    function removeProtectedAddress(
        ILERC20 _token,
        address _protectedAddresss
    ) external;

    function beforeTransfer(
        address _sender,
        address _recipient,
        uint256 _amount
    ) external;

    function beforeTransferFrom(
        address _msgSender,
        address _sender,
        address _recipient,
        uint256 _amount
    ) external;

    function beforeApprove(
        address _sender,
        address _spender,
        uint256 _amount
    ) external;

    function beforeIncreaseAllowance(
        address _msgSender,
        address _spender,
        uint256 _addedValue
    ) external;

    function beforeDecreaseAllowance(
        address _msgSender,
        address _spender,
        uint256 _subtractedValue
    ) external;

    function beforeMint(address _to, uint256 _amount) external;

    function beforeBurn(address _account, uint256 _amount) external;

    function afterTransfer(
        address _sender,
        address _recipient,
        uint256 _amount
    ) external;

    function setProtectedAddress(
        ILERC20 _token,
        address _protectedAddress,
        ProtectionStrategy _strategy
    ) external;

    function setExtraordinaryRetrievalPeriod(uint256 _newPEriod) external;

    function extraordinaryRetrieval(
        ILERC20 _token,
        address[] calldata addresses,
        uint256 fundsToRetrieve
    ) external;

    event AdminChange(address indexed _newAdmin);
    event RecoveryAdminChange(address indexed _newAdmin);
    event PauseAdminChange(address indexed _newAdmin);
    event GuardianSet(
        address indexed _oldGuardian,
        address indexed _newGuardian
    );
    event NewProtectedAddress(
        ILERC20 indexed _token,
        address indexed _protectedAddress,
        address indexed _strategy
    );
    event RemovedProtectedAddress(
        ILERC20 indexed _token,
        address indexed _protectedAddress
    );
    event NewSettlementPeriodProposal(ILERC20 indexed _token, uint256 _seconds);
    event SettlementPeriodChange(
        ILERC20 indexed _token,
        uint256 _proposedTokenLockTimeframe
    );
    event NewSettlementTimelock(uint256 indexed _timelock);
    event NewDexThreshold(uint256 indexed _newThreshold);
    event NewDex(address indexed _dexAddress);
    event DexRemoval(address indexed _dexAddress);
    event NewWhitelistedAddress(address indexed _whitelistAdr);
    event WhitelistedAddressRemoval(address indexed _whitelistAdr);
    event NewBlacklistedAddress(address indexed _blacklistedAddres);
    event AccountBlacklistRemoval(address indexed _adr);
    event NewStakingContract(ILssStaking indexed _newAdr);
    event NewReportingContract(ILssReporting indexed _newAdr);
    event NewGovernanceContract(ILssGovernance indexed _newAdr);
    event EmergencyActive(ILERC20 indexed _token);
    event EmergencyDeactivation(ILERC20 indexed _token);
    event NewMint(
        ILERC20 indexed token,
        address indexed account,
        uint256 indexed amount
    );
    event NewMintLimit(ILERC20 indexed token, uint256 indexed limit);
    event NewMintPeriod(ILERC20 indexed token, uint256 indexed period);
    event NewBurn(
        ILERC20 indexed token,
        address indexed account,
        uint256 indexed amount
    );
    event NewBurnLimit(ILERC20 indexed token, uint256 indexed limit);
    event NewBurnPeriod(ILERC20 indexed token, uint256 indexed period);
    event NewExtraordinaryPeriod(
        uint256 indexed extraordinaryRetrievalProposalPeriod
    );
}

contract LERC20 is Context, ILERC20 {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;

    address public recoveryAdmin;
    address private recoveryAdminCandidate;
    bytes32 private recoveryAdminKeyHash;
    address public override admin;
    uint256 public timelockPeriod;
    uint256 public losslessTurnOffTimestamp;
    bool public isLosslessOn = true;
    ILssController public lossless;

    constructor(
        string memory name_,
        string memory symbol_,
        address admin_,
        address recoveryAdmin_,
        uint256 timelockPeriod_,
        address lossless_
    ) {
        _name = name_;
        _symbol = symbol_;
        admin = admin_;
        recoveryAdmin = recoveryAdmin_;
        recoveryAdminCandidate = address(0);
        recoveryAdminKeyHash = "";
        timelockPeriod = timelockPeriod_;
        losslessTurnOffTimestamp = 0;
        lossless = ILssController(lossless_);
    }

    // --- LOSSLESS modifiers ---

    modifier lssAprove(address spender, uint256 amount) {
        if (isLosslessOn) {
            lossless.beforeApprove(_msgSender(), spender, amount);
        }
        _;
    }

    modifier lssTransfer(address recipient, uint256 amount) {
        if (isLosslessOn) {
            lossless.beforeTransfer(_msgSender(), recipient, amount);
        }
        _;
    }

    modifier lssTransferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) {
        if (isLosslessOn) {
            lossless.beforeTransferFrom(
                _msgSender(),
                sender,
                recipient,
                amount
            );
        }
        _;
    }

    modifier lssIncreaseAllowance(address spender, uint256 addedValue) {
        if (isLosslessOn) {
            lossless.beforeIncreaseAllowance(_msgSender(), spender, addedValue);
        }
        _;
    }

    modifier lssDecreaseAllowance(address spender, uint256 subtractedValue) {
        if (isLosslessOn) {
            lossless.beforeDecreaseAllowance(
                _msgSender(),
                spender,
                subtractedValue
            );
        }
        _;
    }

    modifier onlyRecoveryAdmin() {
        require(
            _msgSender() == recoveryAdmin,
            "LERC20: Must be recovery admin"
        );
        _;
    }

    // --- LOSSLESS management ---
    function transferOutBlacklistedFunds(
        address[] calldata from
    ) external override {
        require(
            _msgSender() == address(lossless),
            "LERC20: Only lossless contract"
        );
        require(isLosslessOn, "LERC20: Lossless is off");

        uint256 fromLength = from.length;
        uint256 totalAmount = 0;

        for (uint256 i = 0; i < fromLength; i++) {
            address fromAddress = from[i];
            uint256 fromBalance = _balances[fromAddress];
            _balances[fromAddress] = 0;
            totalAmount += fromBalance;
            emit Transfer(fromAddress, address(lossless), fromBalance);
        }

        _balances[address(lossless)] += totalAmount;
    }

    function setLosslessAdmin(
        address newAdmin
    ) external override onlyRecoveryAdmin {
        require(newAdmin != admin, "LERC20: Cannot set same address");
        emit NewAdmin(newAdmin);
        admin = newAdmin;
    }

    function transferRecoveryAdminOwnership(
        address candidate,
        bytes32 keyHash
    ) external override onlyRecoveryAdmin {
        recoveryAdminCandidate = candidate;
        recoveryAdminKeyHash = keyHash;
        emit NewRecoveryAdminProposal(candidate);
    }

    function acceptRecoveryAdminOwnership(bytes memory key) external override {
        require(
            _msgSender() == recoveryAdminCandidate,
            "LERC20: Must be canditate"
        );
        require(keccak256(key) == recoveryAdminKeyHash, "LERC20: Invalid key");
        emit NewRecoveryAdmin(recoveryAdminCandidate);
        recoveryAdmin = recoveryAdminCandidate;
        recoveryAdminCandidate = address(0);
    }

    function proposeLosslessTurnOff() external override onlyRecoveryAdmin {
        require(
            losslessTurnOffTimestamp == 0,
            "LERC20: TurnOff already proposed"
        );
        require(isLosslessOn, "LERC20: Lossless already off");
        losslessTurnOffTimestamp = block.timestamp + timelockPeriod;
        emit LosslessTurnOffProposal(losslessTurnOffTimestamp);
    }

    function executeLosslessTurnOff() external override onlyRecoveryAdmin {
        require(losslessTurnOffTimestamp != 0, "LERC20: TurnOff not proposed");
        require(
            losslessTurnOffTimestamp <= block.timestamp,
            "LERC20: Time lock in progress"
        );
        isLosslessOn = false;
        losslessTurnOffTimestamp = 0;
        emit LosslessOff();
    }

    function executeLosslessTurnOn() external override onlyRecoveryAdmin {
        require(!isLosslessOn, "LERC20: Lossless already on");
        losslessTurnOffTimestamp = 0;
        isLosslessOn = true;
        emit LosslessOn();
    }

    function getAdmin() public view virtual override returns (address) {
        return admin;
    }

    // --- ERC20 methods ---

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(
        address account
    ) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(
        address recipient,
        uint256 amount
    ) public virtual override lssTransfer(recipient, amount) returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) public virtual override lssAprove(spender, amount) returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    )
        public
        virtual
        override
        lssTransferFrom(sender, recipient, amount)
        returns (bool)
    {
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(
            currentAllowance >= amount,
            "LERC20: transfer amount exceeds allowance"
        );
        _transfer(sender, recipient, amount);

        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    function increaseAllowance(
        address spender,
        uint256 addedValue
    )
        public
        virtual
        override
        lssIncreaseAllowance(spender, addedValue)
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
        return true;
    }

    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    )
        public
        virtual
        override
        lssDecreaseAllowance(spender, subtractedValue)
        returns (bool)
    {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(
            currentAllowance >= subtractedValue,
            "LERC20: decreased allowance below zero"
        );
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "LERC20: transfer from the zero address");

        uint256 senderBalance = _balances[sender];
        require(
            senderBalance >= amount,
            "LERC20: transfer amount exceeds balance"
        );
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "LERC20: mint to the zero address");

        _totalSupply += amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    )
        external
        payable
        returns (uint amountToken, uint amountETH, uint liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint amountA, uint amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint amountToken, uint amountETH);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);

    function swapTokensForExactETH(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapExactTokensForETH(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);

    function swapETHForExactTokens(
        uint amountOut,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);

    function quote(
        uint amountA,
        uint reserveA,
        uint reserveB
    ) external pure returns (uint amountB);

    function getAmountOut(
        uint amountIn,
        uint reserveIn,
        uint reserveOut
    ) external pure returns (uint amountOut);

    function getAmountIn(
        uint amountOut,
        uint reserveIn,
        uint reserveOut
    ) external pure returns (uint amountIn);

    function getAmountsOut(
        uint amountIn,
        address[] calldata path
    ) external view returns (uint[] memory amounts);

    function getAmountsIn(
        uint amountOut,
        address[] calldata path
    ) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(
        address tokenA,
        address tokenB
    ) external view returns (address pair);

    function allPairs(uint) external view returns (address pair);

    function allPairsLength() external view returns (uint);

    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint);

    function permit(
        address owner,
        address spender,
        uint value,
        uint deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Cast(address indexed sender, uint amount0, uint amount1);
    event Burn(
        address indexed sender,
        uint amount0,
        uint amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function price0CumulativeLast() external view returns (uint);

    function price1CumulativeLast() external view returns (uint);

    function kLast() external view returns (uint);

    function burn(address to) external returns (uint amount0, uint amount1);

    function swap(
        uint amount0Out,
        uint amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

error FUXION__MaxWalletReached(address wallet, uint triedBalance);
error FUXION__Blacklisted();
error FUXION__InvalidThreshold();
error FUXION__TradingNotEnabled();
error FUXION__NotAllowed();
error FUXION__InvalidTaxAmount();
error FUXION__InvalidMaxWallet();

contract FuxionLabs is Ownable, LERC20 {
    //---------------------------------------------------------------------------------
    // Structs
    //---------------------------------------------------------------------------------

    struct SnapshotInfo {
        uint tier1Total; // Tier 1 eligible balance
        uint tier2Total; // Tier 2 eligible balance
        uint snapshotTakenTimestamp; // Timestamp of the snapshot
    }
    //---------------------------------------------------------------------------------
    // State Variables
    //---------------------------------------------------------------------------------

    mapping(address user => mapping(uint snapId => uint amount))
        public snapshotInfo;
    mapping(address user => uint lastSnapshotId) public lastSnapshotId;
    mapping(uint snapId => SnapshotInfo) public snapshots;
    mapping(address wallet => bool excludedStatus) public isExcludedFromTax;
    mapping(address wallet => bool excludedStatus)
        public isExcludedFromMaxWallet;
    mapping(address wallet => bool dividendExcepmtionStatus)
        public isDividendExempt;
    mapping(address lpAddress => bool) public isLpAddress;
    mapping(address executor => bool isExecutor) public isSnapshotter;

    uint private constant MAX_SUPPLY = 5_000_000 ether;
    uint private constant TIER_1 = 50_000 ether; // TIER 1 is top TIER
    uint private constant TIER_2 = 1_000 ether; // TIER 2 is middle TIER
    uint private constant TAX_PERCENT = 100;
    IUniswapV2Router02 public router;

    address public mainPair;
    address private immutable WETH;
    address payable public immutable ADMIN_WALLET;
    uint public currentSnapId = 0;
    uint public taxThreshold;

    uint public maxWallet;
    uint public buyTax = 5;
    uint public sellTax = 5;

    bool private isSwapping = false;
    bool public tradingEnabled = false;

    //---------------------------------------------------------------------------------
    // Events
    //---------------------------------------------------------------------------------

    event WalletExcludedFromTax(address indexed _user, bool excluded);
    event WalletExcludedFromMax(address indexed _user, bool excluded);
    event BlacklistWalletsUpdate(address[] _users, bool blacklisted);
    event SetAddressAsLp(address indexed _lpAddress, bool isLpAddress);
    event SnapshotTaken(uint indexed snapId, uint timestamp);
    event TradingEnabled(bool isEnabled);
    event UpdateBlacklister(address indexed _blacklister);
    event SetSnapshotterStatus(address indexed _snapshotter, bool status);
    event EditMaxWalletAmount(uint newAmount);
    event EditTax(uint newTax, bool buyTax, bool sellTax);

    //---------------------------------------------------------------------------------
    // Modifiers
    //---------------------------------------------------------------------------------

    modifier onlySnapshotter() {
        if (!isSnapshotter[msg.sender]) revert FUXION__NotAllowed();
        _;
    }

    //---------------------------------------------------------------------------------
    // Constructor
    //---------------------------------------------------------------------------------

    constructor(
        address _admin,
        address _newOwner,
        address _recoveryAdmin,
        address lossless_,
        uint256 timeLockPeriod_
    )
        LERC20(
            "Fuxion Labs",
            "FUXE",
            address(_admin),
            address(_recoveryAdmin),
            timeLockPeriod_,
            address(lossless_)
        )
    {
        require(_newOwner != address(0), "FUXION__InvalidAddress");
        _transferOwnership(_newOwner);
        _mint(_newOwner, MAX_SUPPLY);

        maxWallet = (MAX_SUPPLY * 10) / 100_0; // 1% of total supply
        taxThreshold = MAX_SUPPLY / 100_00; // 0.01% of total supply

        // Ethereum Mainnet UniswapV2 Router
        router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        WETH = router.WETH();
        // Create the Pair for this token with WETH
        mainPair = IUniswapV2Factory(router.factory()).createPair(
            address(this),
            WETH
        );
        isLpAddress[mainPair] = true;

        isExcludedFromMaxWallet[address(this)] = true;
        isExcludedFromMaxWallet[owner()] = true;
        isExcludedFromMaxWallet[address(router)] = true;
        isExcludedFromMaxWallet[address(mainPair)] = true;

        isExcludedFromTax[owner()] = true;
        isExcludedFromTax[address(this)] = true;
        isExcludedFromTax[address(router)] = true;

        isDividendExempt[owner()] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[address(router)] = true;
        isDividendExempt[address(mainPair)] = true;

        isSnapshotter[owner()] = true;
        ADMIN_WALLET = payable(_admin);
        _approve(address(this), address(router), type(uint).max);
    }

    //---------------------------------------------------------------------------------
    // External & Public Functions
    //---------------------------------------------------------------------------------

    /**
     * Set wether an address is excluded from taxes or NOT.
     * @param _user User which status will be updated
     * @param _excluded The new excluded status. True is Excluded, False is NOT excluded
     */
    function setExcludeFromTax(
        address _user,
        bool _excluded
    ) external onlyOwner {
        require(_user != address(0), "FUXION__InvalidAddress");
        require(
            isExcludedFromTax[_user] != _excluded,
            "FUXION__AlreadyExcluded"
        );
        isExcludedFromTax[_user] = _excluded;
        emit WalletExcludedFromTax(_user, _excluded);
    }

    /**
     * Exclude or include a wallet of MAX wallet limit (AntiWhale)
     * @param _user Address which status will be updated
     * @param _excluded The new excluded status. True is Excluded, False is NOT excluded
     */
    function setExcludedFromMaxWallet(
        address _user,
        bool _excluded
    ) external onlyOwner {
        require(_user != address(0), "FUXION__InvalidAddress");
        require(
            isExcludedFromMaxWallet[_user] != _excluded,
            "FUXION__AlreadyExcluded"
        );
        isExcludedFromMaxWallet[_user] = _excluded;
        emit WalletExcludedFromMax(_user, _excluded);
    }

    /**
     * @notice Set an Address as LP
     * @param _lpAddress Address to set as LP
     * @param _isLpAddress enable or disable address as an LP
     */
    function setLpAddress(
        address _lpAddress,
        bool _isLpAddress
    ) external onlyOwner {
        require(_lpAddress != address(0), "FUXION__InvalidAddress");
        require(isLpAddress[_lpAddress] != _isLpAddress, "FUXION__AlreadySet");
        require(
            isDividendExempt[_lpAddress] != _isLpAddress,
            "FUXION__Invalid"
        );
        isLpAddress[_lpAddress] = _isLpAddress;
        isDividendExempt[_lpAddress] = _isLpAddress;
        emit SetAddressAsLp(_lpAddress, _isLpAddress);
    }

    /**
     * @notice Create a snapshot of the current balances
     */
    function takeSnapshot() external onlySnapshotter {
        uint currentSnap = currentSnapId;
        currentSnapId++;

        SnapshotInfo storage snap = snapshots[currentSnap];
        snap.snapshotTakenTimestamp = block.timestamp;
        // roll over total amounts
        snapshots[currentSnapId] = SnapshotInfo({
            tier1Total: snap.tier1Total,
            tier2Total: snap.tier2Total,
            snapshotTakenTimestamp: 0
        });

        emit SnapshotTaken(currentSnap, block.timestamp);
    }

    /**
     * @notice Set the new Tax swap threshold
     * @param _taxThreshold New tax threshold
     */
    function setTaxThreshold(uint _taxThreshold) external onlyOwner {
        require(_taxThreshold > 0, "FUXION__InvalidThreshold");

        if (_taxThreshold > MAX_SUPPLY) revert FUXION__InvalidThreshold();
        taxThreshold = _taxThreshold;
    }

    function setMaxWallet(uint _maxWallet) external onlyOwner {
        require(_maxWallet > 0, "FUXION__InvalidMaxWallet");
        if (_maxWallet < MAX_SUPPLY / 100_00) revert FUXION__InvalidMaxWallet();
        maxWallet = _maxWallet;
        emit EditMaxWalletAmount(_maxWallet);
    }

    /**
     * @notice set trading as enabled
     */
    function enableTrading() external onlyOwner {
        tradingEnabled = true;
        emit TradingEnabled(true);
    }

    /**
     * @notice set trading as disabled
     */
    function pauseTrading() external onlyOwner {
        tradingEnabled = false;
        emit TradingEnabled(false);
    }

    /**
     * @notice Set the Snapshotter status to an address. These addresses can take snapshots at any time
     * @param _snapshotter Address to set snapshotter status
     * @param _isSnapshotter True to set as snapshotter, false to remove
     */
    function setSnapshotterAddress(
        address _snapshotter,
        bool _isSnapshotter
    ) external onlyOwner {
        require(_snapshotter != address(0), "FUXION__InvalidAddress");
        require(
            isSnapshotter[_snapshotter] != _isSnapshotter,
            "FUXION__AlreadySet"
        );
        isSnapshotter[_snapshotter] = _isSnapshotter;
        emit SetSnapshotterStatus(_snapshotter, _isSnapshotter);
    }

    /**
     * @notice set the Buy tax to a new value
     * @param _buyTax New buy tax
     * @dev buyTax is a maximimum of 10% so the max acceptable _buyTax is 10
     */
    function setBuyTax(uint _buyTax) external onlyOwner {
        require(_buyTax > 0, "FUXION__InvalidTaxAmount");
        if (_buyTax > 10) revert FUXION__InvalidTaxAmount();
        buyTax = _buyTax;
        emit EditTax(_buyTax, true, false);
    }

    /**
     * @notice set the Sell tax to a new value
     * @param _sellTax New sell tax
     * @dev sellTax is a maximimum of 10% so the max acceptable _sellTax is 10
     */
    function setSellTax(uint _sellTax) external onlyOwner {
        require(_sellTax > 0, "FUXION__InvalidTaxAmount");
        if (_sellTax > 10) revert FUXION__InvalidTaxAmount();
        sellTax = _sellTax;
        emit EditTax(_sellTax, false, true);
    }

    //---------------------------------------------------------------------------------
    // Internal & Private Functions
    //---------------------------------------------------------------------------------

    /**
     * @notice Underlying transfer of tokens used by `transfer` and `transferFrom` in ERC20 which are public
     * @param from Address that holds the funds
     * @param to Address that receives the funds
     * @param amount Amount of funds to send
     */
    function _transfer(
        address from,
        address to,
        uint amount
    ) internal override {
        bool taxExclusion = isExcludedFromTax[from] || isExcludedFromTax[to];

        if (!tradingEnabled && !taxExclusion) {
            revert FUXION__TradingNotEnabled();
        }

        _updateSnapDecrease(from, amount);

        uint currentBalance = balanceOf(address(this));

        if (
            !isSwapping &&
            currentBalance >= taxThreshold &&
            !taxExclusion &&
            !isLpAddress[from] // Cant do this on buys
        ) {
            _swapTokens();
        }

        // Check that sender is free of tax or receiver is free of tax
        if (!taxExclusion) {
            uint tax;
            // if not free of tax, check if is buy or sell
            if (isLpAddress[to]) {
                // IS SELL
                tax = (amount * sellTax) / TAX_PERCENT;
            } else if (isLpAddress[from]) {
                // IS BUY
                tax = (amount * buyTax) / TAX_PERCENT;
            }
            if (tax > 0) {
                super._transfer(from, address(this), tax);
                amount -= tax;
            }
        }

        // check if receiver is free of max wallet
        uint toNEWBalance = balanceOf(to) + amount;
        if (!isExcludedFromMaxWallet[to] && toNEWBalance > maxWallet) {
            revert FUXION__MaxWalletReached(to, toNEWBalance);
        }
        _updateSnapIncrease(to, amount);
        super._transfer(from, to, amount);
    }

    /**
     * @notice Swap any tokens the contract has for ETH and send the ETH directly to the Admin Wallet
     */
    function _swapTokens() private {
        isSwapping = true;
        // Get the current amount of tokens stored in the contract
        uint256 contractTokenBalance = balanceOf(address(this));
        // If the contract has tokens
        if (contractTokenBalance > 0) {
            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = WETH;
            // Swap all for ETH and send to Admin Wallet
            router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                contractTokenBalance,
                0, // Accept any amount of ETH
                path,
                ADMIN_WALLET,
                block.timestamp
            );
        }
        isSwapping = false;
    }

    /**
     * @notice Decrease a wallet's current snapshot balance
     * @param user Wallet to update snapshot info
     * @param amount the difference amount in snapshot
     */
    function _updateSnapDecrease(address user, uint amount) private {
        uint currentSnap = currentSnapId;
        uint currentSnapBalance = snapshotInfo[user][currentSnap];
        uint currentBalance = balanceOf(user);
        uint newBalance = currentBalance - amount;
        SnapshotInfo storage snap = snapshots[currentSnap];
        lastSnapshotId[user] = currentSnap;
        // If user is exempt from dividends, we need to set the snapshot value to 0
        if (isDividendExempt[user]) {
            delete snapshotInfo[user][currentSnap];
            // if user is now exempt but used to have funds, we need to decrease the total
            if (currentSnapBalance > 0) {
                if (currentSnapBalance >= TIER_1)
                    snap.tier1Total -= currentSnapBalance;
                else if (currentSnapBalance >= TIER_2)
                    snap.tier2Total -= currentSnapBalance;
            }
        } else {
            snapshotInfo[user][currentSnap] = newBalance;

            /// FROM TIER 1
            if (currentBalance >= TIER_1) {
                // Decrease TIER 1
                snap.tier1Total -= currentBalance;
                // TO SAME TIER
                if (newBalance >= TIER_1) snap.tier1Total += newBalance;
                // TO TIER 2
                if (newBalance < TIER_1 && newBalance >= TIER_2)
                    snap.tier2Total += newBalance;
                // if to NO tier, just decrease is fine
            }
            // FROM TIER 2
            else if (currentBalance >= TIER_2) {
                snap.tier2Total -= currentBalance;
                // TO SAME TIER
                if (newBalance >= TIER_2) snap.tier2Total += newBalance;
                // TO NO TIER JUST DO NOTHING
            }
        }
    }

    /**
     * @notice Increase a wallet's current snapshot balance
     * @param user Wallet to update snapshot info
     * @param amount Difference amount
     */
    function _updateSnapIncrease(address user, uint amount) private {
        uint currentSnap = currentSnapId;
        uint currentBalance = balanceOf(user);
        uint currentSnapBalance = snapshotInfo[user][currentSnap];
        SnapshotInfo storage snap = snapshots[currentSnap];
        lastSnapshotId[user] = currentSnap;
        // If user is exempt from dividends, we need to set the snapshot value to 0
        if (isDividendExempt[user]) {
            delete snapshotInfo[user][currentSnap];
            // if user is now exempt but used to have funds, we need to decrease the total
            if (currentSnapBalance > 0) {
                if (currentSnapBalance >= TIER_1)
                    snap.tier1Total -= currentSnapBalance;
                else if (currentSnapBalance >= TIER_2)
                    snap.tier2Total -= currentSnapBalance;
            }
        } else {
            snapshotInfo[user][currentSnap] = currentBalance + amount;
            uint newBalance = currentBalance + amount;
            // Check if there is any tier advancement

            // FROM NO TIER
            if (currentBalance < TIER_2) {
                // TO TIER 1
                if (newBalance >= TIER_1)
                    snap.tier1Total += newBalance;
                    // TO TIER 2
                else if (newBalance >= TIER_2) snap.tier2Total += newBalance;
                // TO NO TIER DO NOTHING
            }
            // FROM TIER 2
            else if (currentBalance >= TIER_2 && currentBalance < TIER_1) {
                // TO TIER 1
                if (newBalance >= TIER_1)
                    snap.tier1Total += newBalance;

                    // TO SAME TIER
                else if (newBalance >= TIER_2) snap.tier2Total += newBalance;
                snap.tier2Total -= currentBalance;
            }
            // FROM TIER 1
            else if (currentBalance >= TIER_1) {
                // Stay in same tier
                snap.tier1Total += newBalance;
                snap.tier1Total -= currentBalance;
            }
        }
    }

    //---------------------------------------------------------------------------------
    // External & Public VIEW | PURE Functions
    //---------------------------------------------------------------------------------

    function getUserSnapshotAt(
        address user,
        uint snapId
    ) external view returns (uint) {
        // If snapshot ID hasn't been taken, return 0
        if (snapId > currentSnapId) return 0;
        uint lastUserSnap = lastSnapshotId[user];
        // if last snapshot is before the requested snapshot, return current balance of the user
        if (snapId > lastUserSnap) return balanceOf(user);
        // else return the snapshot balance
        return snapshotInfo[user][snapId];
    }
}