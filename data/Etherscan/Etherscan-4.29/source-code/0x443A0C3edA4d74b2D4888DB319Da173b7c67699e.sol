// Sources flattened with hardhat v2.22.2 https://hardhat.org

// SPDX-License-Identifier: MIT

// File @openzeppelin/contracts/utils/Context.sol@v4.9.6

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.4) (utils/Context.sol)

pragma solidity ^0.8.17;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
  function _msgSender() internal view virtual returns (address) {
    return msg.sender;
  }

  function _msgData() internal view virtual returns (bytes calldata) {
    return msg.data;
  }

  function _contextSuffixLength() internal view virtual returns (uint256) {
    return 0;
  }
}

// File @openzeppelin/contracts/access/Ownable.sol@v4.9.6

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

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
    require(owner() == _msgSender(), 'Ownable: caller is not the owner');
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
    require(newOwner != address(0), 'Ownable: new owner is the zero address');
    _transferOwnership(newOwner);
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   * Internal function without access restriction.
   */
  function _transferOwnership(address newOwner) internal virtual {
    address oldOwner = _owner;
    _owner = newOwner;
    emit OwnershipTransferred(oldOwner, newOwner);
  }
}

// File contracts/interfaces/Enum.sol

// Original license: SPDX_License_Identifier: MIT

/// @title Enum - Collection of enums
/// @author Richard Meissner - <richard@gnosis.pm>
interface Enum {
  enum Operation {
    Call,
    DelegateCall
  }
}

// File contracts/interfaces/GnosisSafe.sol

// Original license: SPDX_License_Identifier: MIT

interface GnosisSafe {
  /// @dev Allows a Module to execute a Safe transaction without any further confirmations.
  /// @param to Destination address of module transaction.
  /// @param value Ether value of module transaction.
  /// @param data Data payload of module transaction.
  /// @param operation Operation type of module transaction.
  function execTransactionFromModule(
    address to,
    uint256 value,
    bytes calldata data,
    Enum.Operation operation
  ) external returns (bool success);
}

// File @openzeppelin/contracts/security/ReentrancyGuard.sol@v4.9.6

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
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
    require(_status != _ENTERED, 'ReentrancyGuard: reentrant call');

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

// File @openzeppelin/contracts/token/ERC20/IERC20.sol@v4.9.6

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
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
   * @dev Returns the amount of tokens in existence.
   */
  function totalSupply() external view returns (uint256);

  /**
   * @dev Returns the amount of tokens owned by `account`.
   */
  function balanceOf(address account) external view returns (uint256);

  /**
   * @dev Moves `amount` tokens from the caller's account to `to`.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transfer(address to, uint256 amount) external returns (bool);

  /**
   * @dev Returns the remaining number of tokens that `spender` will be
   * allowed to spend on behalf of `owner` through {transferFrom}. This is
   * zero by default.
   *
   * This value changes when {approve} or {transferFrom} are called.
   */
  function allowance(address owner, address spender) external view returns (uint256);

  /**
   * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
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
  function approve(address spender, uint256 amount) external returns (bool);

  /**
   * @dev Moves `amount` tokens from `from` to `to` using the
   * allowance mechanism. `amount` is then deducted from the caller's
   * allowance.
   *
   * Returns a boolean value indicating whether the operation succeeded.
   *
   * Emits a {Transfer} event.
   */
  function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

// File contracts/interfaces/AddressResolver.sol

// Original license: SPDX_License_Identifier: MIT

interface AddressResolver {
  function requireAndGetAddress(
    bytes32 name,
    string calldata reason
  ) external view returns (address);
}

// File contracts/interfaces/ICollateralEthReduced.sol

// Original license: SPDX_License_Identifier: MIT

interface ICollateralEthReduced {
  function minCratio() external view returns (uint256);

  function setMinCratio(uint256 _minCratio) external;

  function liquidate(address borrower, uint256 id, uint256 amount) external;

  function pendingWithdrawals(address account) external view returns (uint256);

  function claim(uint256 amount) external;
}

// File contracts/UnwindLoansModule.sol

// Original license: SPDX_License_Identifier: MIT

// UnwindLoansModule is a module, which is able to ...
//
// @see: https://sips.synthetix.io/sips/sip-2095/
contract UnwindLoansModule is Ownable, ReentrancyGuard {
  // address public constant SNX_PDAO_MULTISIG_ADDRESS = 0x6cd3f878852769e04A723A5f66CA7DD4d9E38A6C; // Optimism
  address public constant SNX_PDAO_MULTISIG_ADDRESS = 0xEb3107117FEAd7de89Cd14D463D340A2E6917769; // Ethereum
  address public constant SNX_TC_MULTISIG_ADDRESS = 0x99F4176EE457afedFfCB1839c7aB7A030a5e4A92; // TC Multisig
  // address public constant SNX_ADDRESS_RESOLVER = 0x95A6a3f44a70172E7d50a9e28c85Dfd712756B8C;
  address public constant SNX_COLLATERAL_ETH = 0x5c8344bcdC38F1aB5EB5C1d4a35DdEeA522B5DfA; // https://etherscan.io/address/0x5c8344bcdC38F1aB5EB5C1d4a35DdEeA522B5DfA

  GnosisSafe private _pDAOSafe;
  // AddressResolver private _addressResolver;

  bool public isPaused;
  address public endorsedAccount;

  constructor(address _owner, address _endorsedAccount) {
    // Do not call Ownable constructor which sets the owner to the msg.sender and set it to _owner.
    _transferOwnership(_owner);

    // _addressResolver = AddressResolver(SNX_ADDRESS_RESOLVER);
    _pDAOSafe = GnosisSafe(SNX_PDAO_MULTISIG_ADDRESS);

    // endorsedAccount
    endorsedAccount = _endorsedAccount;

    // start as paused
    isPaused = true;
  }

  // --- External/Public --- //

  // @dev set MMV to zero on the corresponding market.
  function unwind(
    uint minCratioUpdatedValue,
    address liquidatedUserAddress,
    uint loanId,
    uint liquidationAmount,
    uint pendingWithdrawalAmount
  ) external returns (bool success) {
    require(!isPaused, 'Module paused');
    require(msg.sender == endorsedAccount, 'Not endorsed');

    ICollateralEthReduced collateralEth = ICollateralEthReduced(SNX_COLLATERAL_ETH);

    // 0- check initial eth balance
    uint256 initialEthBalance = address(this).balance;
    // 1- read the inicial minCRatio
    uint256 previousMinCratio = collateralEth.minCratio();
    // 2- set the new minCRatio
    success = _executeSafeTransaction_UpdateMinCratio(minCratioUpdatedValue);
    require(success, 'Failed to update minCratio to updated value');
    // 3- call liquidate
    collateralEth.liquidate(liquidatedUserAddress, loanId, liquidationAmount);
    // 4- set the minCRatio back to the original value
    success = _executeSafeTransaction_UpdateMinCratio(previousMinCratio);
    require(success, 'Failed to update minCratio to previous value');
    // 5- read pendingWithdrawals and compare value with pendingWithdrawalAmount. Must be higher
    uint256 pendingWithdrawal = collateralEth.pendingWithdrawals(address(this));
    // 6- call claim
    collateralEth.claim(pendingWithdrawal);
    // 7- confirm that the eth balance is higher than the initial balance by at least pendingWithdrawalAmount
    uint256 currentEthBalance = address(this).balance;
    require(currentEthBalance >= initialEthBalance, 'Eth balance is lower than initial balance');
    require(
      address(this).balance - initialEthBalance >= pendingWithdrawalAmount,
      'Not enough eth withdrawn'
    );
  }

  // @dev sets the paused state
  function setPaused(bool _isPaused) external onlyOwner {
    isPaused = _isPaused;
  }

  // @dev sets the endorsed account
  function setEndorsedAccount(address _endorsedAccount) external onlyOwner {
    endorsedAccount = _endorsedAccount;
  }

  function withdrawErc20(uint256 amount, address underlyingContract) external nonReentrant {
    require(
      msg.sender == endorsedAccount || msg.sender == SNX_TC_MULTISIG_ADDRESS,
      'Not endorsed or TC'
    );
    bool success = IERC20(underlyingContract).transfer(SNX_TC_MULTISIG_ADDRESS, amount);
    require(success, 'Transfer failed');
  }

  function withdrawEth(uint256 amount) external nonReentrant {
    require(
      msg.sender == endorsedAccount || msg.sender == SNX_TC_MULTISIG_ADDRESS,
      'Not endorsed or TC'
    );
    // solhint-disable avoid-low-level-calls
    (bool success, ) = SNX_TC_MULTISIG_ADDRESS.call{value: amount}('');
    require(success, 'Transfer failed');
  }

  // --- Fallback and receive functions --- //
  fallback() external payable {}

  receive() external payable {}

  // --- Internal --- //

  function _executeSafeTransaction_UpdateMinCratio(
    uint256 minCratio
  ) internal returns (bool success) {
    bytes memory payload = abi.encodeWithSignature('setMinCratio(uint256)', minCratio);

    success = _pDAOSafe.execTransactionFromModule(
      SNX_COLLATERAL_ETH,
      0,
      payload,
      Enum.Operation.Call
    );
  }

  // --- Events --- //
}