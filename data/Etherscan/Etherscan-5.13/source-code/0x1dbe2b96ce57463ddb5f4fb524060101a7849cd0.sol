// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;
// https://remix.ethereum.org/#lang=en&optimize=true&runs=200&evmVersion=cancun&version=soljson-v0.8.25+commit.b61c2a91.js

// The codes from 3rd-parties
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}
interface IERC20Errors {
    /**
     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC20InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC20InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `spender`’s `allowance`. Used in transfers.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     * @param allowance Amount of tokens a `spender` is allowed to operate with.
     * @param needed Minimum amount required to perform a transfer.
     */
    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC20InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `spender` to be approved. Used in approvals.
     * @param spender Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC20InvalidSpender(address spender);
}
interface IERC721Errors {
    /**
     * @dev Indicates that an address can't be an owner. For example, `address(0)` is a forbidden owner in EIP-20.
     * Used in balance queries.
     * @param owner Address of the current owner of a token.
     */
    error ERC721InvalidOwner(address owner);

    /**
     * @dev Indicates a `tokenId` whose `owner` is the zero address.
     * @param tokenId Identifier number of a token.
     */
    error ERC721NonexistentToken(uint256 tokenId);

    /**
     * @dev Indicates an error related to the ownership over a particular token. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param tokenId Identifier number of a token.
     * @param owner Address of the current owner of a token.
     */
    error ERC721IncorrectOwner(address sender, uint256 tokenId, address owner);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC721InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC721InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `operator`’s approval. Used in transfers.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     * @param tokenId Identifier number of a token.
     */
    error ERC721InsufficientApproval(address operator, uint256 tokenId);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC721InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `operator` to be approved. Used in approvals.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC721InvalidOperator(address operator);
}
interface IERC1155Errors {
    /**
     * @dev Indicates an error related to the current `balance` of a `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     * @param balance Current balance for the interacting account.
     * @param needed Minimum amount required to perform a transfer.
     * @param tokenId Identifier number of a token.
     */
    error ERC1155InsufficientBalance(address sender, uint256 balance, uint256 needed, uint256 tokenId);

    /**
     * @dev Indicates a failure with the token `sender`. Used in transfers.
     * @param sender Address whose tokens are being transferred.
     */
    error ERC1155InvalidSender(address sender);

    /**
     * @dev Indicates a failure with the token `receiver`. Used in transfers.
     * @param receiver Address to which tokens are being transferred.
     */
    error ERC1155InvalidReceiver(address receiver);

    /**
     * @dev Indicates a failure with the `operator`’s approval. Used in transfers.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     * @param owner Address of the current owner of a token.
     */
    error ERC1155MissingApprovalForAll(address operator, address owner);

    /**
     * @dev Indicates a failure with the `approver` of a token to be approved. Used in approvals.
     * @param approver Address initiating an approval operation.
     */
    error ERC1155InvalidApprover(address approver);

    /**
     * @dev Indicates a failure with the `operator` to be approved. Used in approvals.
     * @param operator Address that may be allowed to operate on tokens without being their owner.
     */
    error ERC1155InvalidOperator(address operator);

    /**
     * @dev Indicates an array length mismatch between ids and values in a safeBatchTransferFrom operation.
     * Used in batch transfers.
     * @param idsLength Length of the array of token identifiers
     * @param valuesLength Length of the array of token amounts
     */
    error ERC1155InvalidArrayLength(uint256 idsLength, uint256 valuesLength);
}
abstract contract ERC20 is Context, IERC20, IERC20Metadata, IERC20Errors {
    mapping(address account => uint256) private _balances;

    mapping(address account => mapping(address spender => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the default value returned by this function, unless
     * it's overridden.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `value`.
     */
    function transfer(address to, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, value);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `value` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, value);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `value`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `value`.
     */
    function transferFrom(address from, address to, uint256 value) public virtual returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _transfer(address from, address to, uint256 value) internal {
        if (from == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (to == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(from, to, value);
    }

    /**
     * @dev Transfers a `value` amount of tokens from `from` to `to`, or alternatively mints (or burns) if `from`
     * (or `to`) is the zero address. All customizations to transfers, mints, and burns should be done by overriding
     * this function.
     *
     * Emits a {Transfer} event.
     */
    function _update(address from, address to, uint256 value) internal virtual {
        if (from == address(0)) {
            // Overflow check required: The rest of the code assumes that totalSupply never overflows
            _totalSupply += value;
        } else {
            uint256 fromBalance = _balances[from];
            if (fromBalance < value) {
                revert ERC20InsufficientBalance(from, fromBalance, value);
            }
            unchecked {
                // Overflow not possible: value <= fromBalance <= totalSupply.
                _balances[from] = fromBalance - value;
            }
        }

        if (to == address(0)) {
            unchecked {
                // Overflow not possible: value <= totalSupply or value <= fromBalance <= totalSupply.
                _totalSupply -= value;
            }
        } else {
            unchecked {
                // Overflow not possible: balance + value is at most totalSupply, which we know fits into a uint256.
                _balances[to] += value;
            }
        }

        emit Transfer(from, to, value);
    }

    /**
     * @dev Creates a `value` amount of tokens and assigns them to `account`, by transferring it from address(0).
     * Relies on the `_update` mechanism
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead.
     */
    function _mint(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(address(0), account, value);
    }

    /**
     * @dev Destroys a `value` amount of tokens from `account`, lowering the total supply.
     * Relies on the `_update` mechanism.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * NOTE: This function is not virtual, {_update} should be overridden instead
     */
    function _burn(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        _update(account, address(0), value);
    }

    /**
     * @dev Sets `value` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     *
     * Overrides to this logic should be done to the variant with an additional `bool emitEvent` argument.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        _approve(owner, spender, value, true);
    }

    /**
     * @dev Variant of {_approve} with an optional flag to enable or disable the {Approval} event.
     *
     * By default (when calling {_approve}) the flag is set to true. On the other hand, approval changes made by
     * `_spendAllowance` during the `transferFrom` operation set the flag to false. This saves gas by not emitting any
     * `Approval` event during `transferFrom` operations.
     *
     * Anyone who wishes to continue emitting `Approval` events on the`transferFrom` operation can force the flag to
     * true using the following override:
     * ```
     * function _approve(address owner, address spender, uint256 value, bool) internal virtual override {
     *     super._approve(owner, spender, value, true);
     * }
     * ```
     *
     * Requirements are the same as {_approve}.
     */
    function _approve(address owner, address spender, uint256 value, bool emitEvent) internal virtual {
        if (owner == address(0)) {
            revert ERC20InvalidApprover(address(0));
        }
        if (spender == address(0)) {
            revert ERC20InvalidSpender(address(0));
        }
        _allowances[owner][spender] = value;
        if (emitEvent) {
            emit Approval(owner, spender, value);
        }
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `value`.
     *
     * Does not update the allowance value in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Does not emit an {Approval} event.
     */
    function _spendAllowance(address owner, address spender, uint256 value) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < value) {
                revert ERC20InsufficientAllowance(spender, currentAllowance, value);
            }
            unchecked {
                _approve(owner, spender, currentAllowance - value, false);
            }
        }
    }
}
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}
contract TokenNew is ERC20 {
    constructor(
        uint256 initialSupply,
        address owner,
        string memory name,
        string memory symbol
    ) ERC20(name, symbol) {
        _mint(owner, initialSupply);
    }
}

// The contract for ICO coded by myself
contract ICO {
    IERC20 public token; // ERC20 Interface
    address public admin; // Administrator address, has the authority to trigger token distribution after the private sale, without independent control over funds
    uint256 public startTime; // Private sale start time
    uint256 public constant DURATION = 7 days; // Duration of the private sale
    uint256 public constant REFUND_DURATION = 8 days; // Deadline for refunds
    bool public icoEnded;
    mapping(address => uint256) public investments; // Mapping of investor addresses to investment amounts
    address[] public investors; // Array of investor addresses
    uint256 public totalInvestment; // Total investment amount
    bool public tokenDistributed = false; // Whether tokens have been distributed
    TokenNew public tokenNew;

    // Events
    event InvestmentReceived(address investor, uint256 amount);
    event ReceivedEter(address sender, uint256 amount);
    event TokensDistributed();

    constructor() {
        admin = msg.sender;
        startTime = block.timestamp;
    }

    // Function for investors to participate in the sale
    receive() external payable {
        if (!icoEnded) {
            if (block.timestamp <= startTime + DURATION) {
                if (investments[msg.sender] == 0) {
                    investors.push(msg.sender);
                }
                investments[msg.sender] += msg.value;
                totalInvestment += msg.value;
                emit InvestmentReceived(msg.sender, msg.value);
            } else {
                payable(msg.sender).transfer(msg.value);
                icoEnded = true;
            }
        } else {
            require(
                tokenDistributed,
                "After the ICO ends, token distribution must be completed before external funds are allowed to be transferred in."
            );
            emit ReceivedEter(msg.sender, msg.value);
        }
    }


    // This function is the exclusive authority of the administrator. If the private placement meets expectations, the administrator can use this function to trigger the issuance of tokens and distribute them to every user except the first investor according to the investment ratio.
    function distributeTokens(
        uint256 totalSupply,
        string memory name,
        string memory symbol
    ) external {
        require(msg.sender == admin, "Not admin");
        require(
            block.timestamp > startTime + DURATION,
            "Private sale not ended"
        );
        if (!icoEnded) {
            icoEnded = true;
        }
        tokenNew = new TokenNew(totalSupply, address(this), name, symbol); // Depoly a new ERC20 token;
        token = IERC20(address(tokenNew)); // ICO token is also the DAO token
        require(!tokenDistributed, "Tokens already distributed");
        uint256 tokenBalance = token.balanceOf(address(this));
        
        // In accordance with the agreement, the first investor is a gratuitous investor and does not require the distribution of tokens to the first investor.
        for (uint256 i = 1; i < investors.length; i++) {
            uint256 amount = (investments[investors[i]] * tokenBalance) /
                totalInvestment;
            token.transfer(investors[i], amount);
        }
        tokenDistributed = true;
        emit TokensDistributed();
    }

    // To avoid loss of user funds, if 8 days have passed since the start of the private placement (1 day after the private placement ends), users can use this function to retrieve their invested funds.
    function refund() external {
        require(
            block.timestamp > startTime + REFUND_DURATION && !tokenDistributed,
            "Refund not available"
        );
        if (!icoEnded) {
            icoEnded = true;
        }
        uint256 investment = investments[msg.sender];
        require(investment > 0, "No investment to refund");

        payable(msg.sender).transfer(investment);
        investments[msg.sender] = 0;
    }
}

// The contract for DAO coded by myself
contract DAO is ReentrancyGuard, ICO {
    IERC20 public DAOToken = token; // ERC20 Interface
    uint256 public VOTING_PERIOD = 1 days; // Fixed duration for proposals is 1 day
    uint256 public PROPOSAL_THRESHOLD_PERCENTAGE = 5; // Required governance token percentage to create a proposal
    string public daoName;
    string public daoDescription;


    struct Proposal {
        address proposer;
        address target;
        bytes data;
        uint256 startTime;
        uint256 endTime;
        uint256 forVotes;
        uint256 againstVotes;
        bool executed;
        uint256 value;
    }

    Proposal[] public proposals; // Array of proposals

    struct VoteRecord {
        bool support; // Voting direction: true for support, false for oppose
        uint256 amount; // Voting amount
    }

    // Voting records for each proposal: user address => proposal ID => voting record
    mapping(address => mapping(uint256 => VoteRecord)) public voteRecords;

    // Array of user addresses that voted on each proposal
    mapping(uint256 => address[]) private proposalVoters;

    struct ContractInfo {
        address contractAddress;
        bool isActive;
    }

    ContractInfo[] public deployedContracts;

    // Events
    event ContractDeployed(address indexed contractAddress);
    event ContractRevoked(address indexed contractAddress);
    event DAODetailsUpdated(string newName, string newDescription);
    event ProposalCreated(
        uint256 indexed proposalId,
        address proposer,
        address target,
        uint256 value,
        bytes data,
        uint256 startTime,
        uint256 endTime
    );
    event VoteCasted(
        uint256 indexed proposalId,
        address voter,
        bool support,
        uint256 amount
    );
    event ProposalExecuted(
        uint256 indexed proposalId,
        bool success,
        uint256 value
    );
    event VotesRefunded(
        uint256 indexed proposalId,
        address voter,
        uint256 amount
    );

    function createProposal(
        address _target,
        bytes memory _data,
        uint256 _value
    ) public {
        // Check if the user holds enough governance DAOTokens to create a proposal
        uint256 requiredDAOTokens = (DAOToken.totalSupply() *
            PROPOSAL_THRESHOLD_PERCENTAGE) / 100;
        require(
            DAOToken.balanceOf(msg.sender) >= requiredDAOTokens,
            "Insufficient DAOTokens to create proposal"
        );

        uint256 startTime = block.timestamp;
        uint256 endTime = block.timestamp + VOTING_PERIOD;

        proposals.push(
            Proposal({
                proposer: msg.sender,
                target: _target,
                data: _data,
                startTime: startTime,
                endTime: endTime,
                forVotes: 0,
                againstVotes: 0,
                executed: false,
                value: _value
            })
        );

        uint256 proposalId = proposals.length - 1;
        emit ProposalCreated(
            proposalId,
            msg.sender,
            _target,
            _value,
            _data,
            startTime,
            endTime
        );
    }

    function vote(
        uint256 _proposalId,
        bool _support,
        uint256 _amount
    ) public {
        require(_proposalId < proposals.length, "Proposal does not exist.");
        Proposal storage proposal = proposals[_proposalId];
        require(
            block.timestamp >= proposal.startTime &&
                block.timestamp <= proposal.endTime,
            "Voting is not active."
        );
        require(
            DAOToken.transferFrom(msg.sender, address(this), _amount),
            "Failed to transfer DAOTokens for voting"
        );

        VoteRecord storage record = voteRecords[msg.sender][_proposalId];
        // If it's the first time voting
        if (record.amount == 0) {
            proposalVoters[_proposalId].push(msg.sender);
        }
        record.amount += _amount;
        if (_support) {
            proposal.forVotes += _amount;
        } else {
            proposal.againstVotes += _amount;
        }
        emit VoteCasted(_proposalId, msg.sender, _support, _amount);
    }

    function cancelVote(uint256 _proposalId) public {
        require(_proposalId < proposals.length, "Proposal does not exist.");
        Proposal storage proposal = proposals[_proposalId];
        // Ensure current time is within the proposal's voting period
        require(
            block.timestamp >= proposal.startTime &&
                block.timestamp <= proposal.endTime,
            "Voting is not active."
        );
        VoteRecord storage record = voteRecords[msg.sender][_proposalId];
        require(record.amount > 0, "You have not voted on this proposal.");

        uint256 votedAmount = record.amount;
        if (record.support) {
            proposal.forVotes -= votedAmount; // Reduce the number of support votes for the proposal
        } else {
            proposal.againstVotes -= votedAmount; // Reduce the number of against votes for the proposal
        }

        // Reset the voting record
        record.amount = 0;
        record.support = false;

        // Refund the governance DAOTokens previously staked by the user
        DAOToken.transfer(msg.sender, votedAmount);

        emit VotesRefunded(_proposalId, msg.sender, votedAmount);
    }

    function executeProposal(uint256 _proposalId) public {
        require(_proposalId < proposals.length, "Proposal does not exist.");
        Proposal storage proposal = proposals[_proposalId];
        // Ensure the proposal's active period has ended
        require(
            block.timestamp > proposal.endTime,
            "Voting period has not ended."
        );
        require(!proposal.executed, "Proposal has already been executed.");

        proposal.executed = true; // Mark the proposal as executed

        // Refund all staked DAOTokens to the participants
        _refundAllVotes(_proposalId);

        // Determine if the proposal passed: no opposition or more support votes than against votes
        bool proposalPassed = proposal.againstVotes == 0 ||
            proposal.forVotes > proposal.againstVotes;

        if (proposalPassed && address(this).balance >= proposal.value) {
            // If the proposal passes and the contract has sufficient balance, attempt to execute the proposal call
            (bool success, ) = proposal.target.call{value: proposal.value}(
                proposal.data
            );
            require(success, "Proposal call failed");
        }

        emit ProposalExecuted(_proposalId, proposalPassed, proposal.value);
    }

    function _refundAllVotes(uint256 _proposalId) private {
        address[] storage voters = proposalVoters[_proposalId];
        for (uint256 i = 0; i < voters.length; i++) {
            address voter = voters[i];
            VoteRecord storage record = voteRecords[voter][_proposalId];
            uint256 amount = record.amount;
            if (amount > 0) {
                DAOToken.transfer(voter, amount);
                // Note: We keep the voting record for historical reference
            }
        }
    }

    function changeVotingPeriod(uint256 newVotingPeriod) external {
        require(
            msg.sender == address(this),
            "Only the admin can change the voting period."
        );
        VOTING_PERIOD = newVotingPeriod;
    }

    function changeProposalThresholdPercentage(uint256 newPercentage) external {
        require(
            msg.sender == address(this),
            "Only the admin can change the proposal threshold percentage."
        );
        PROPOSAL_THRESHOLD_PERCENTAGE = newPercentage;
    }

    function updateDAODetails(string memory _name, string memory _description)
        public
    {
        require(msg.sender == address(this), "Only the DAO can use");
        daoName = _name;
        daoDescription = _description;
        emit DAODetailsUpdated(_name, _description);
    }

    function deployContract(bytes memory bytecode) public returns (address) {
        require(msg.sender == address(this), "Only the DAO can use");
        address deployedAddress;
        assembly {
            deployedAddress := create(0, add(bytecode, 0x20), mload(bytecode))
        }
        require(deployedAddress != address(0), "Contract deployment failed.");

        deployedContracts.push(
            ContractInfo({contractAddress: deployedAddress, isActive: true})
        );
        emit ContractDeployed(deployedAddress);

        return deployedAddress;
    }

    function revokeContract(address _contractAddress) public {
        require(msg.sender == address(this), "Only the DAO can use");
        for (uint256 i = 0; i < deployedContracts.length; i++) {
            if (deployedContracts[i].contractAddress == _contractAddress) {
                require(
                    deployedContracts[i].isActive,
                    "Contract already revoked."
                );
                deployedContracts[i].isActive = false;
                emit ContractRevoked(_contractAddress);
                return;
            }
        }
        revert("Contract address does not exist.");
    }
}