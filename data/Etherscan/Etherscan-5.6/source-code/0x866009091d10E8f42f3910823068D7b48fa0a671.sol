// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function mint(uint256 amount) external returns (bool);

    function burn(uint256 amount) external returns (bool);
}

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
}

interface IRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function getAmountsOut(
        uint amountIn, 
        address[] memory path
        ) external view returns (uint[] memory amounts);
    
    function getAmountsIn(uint amountOut, address[] memory path) external view returns (uint[] memory amounts);

}

library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

library Address {

    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }

    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.

    function _msgSender() internal view returns (address) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface ISeedRouter {
    function seedChecker(bytes calldata _data) external returns (uint256, string memory);
}

contract BongocatFairlaunch is Ownable {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    struct AffiliateAmounts {
        uint256 eth;
        uint256 usdt;
    }

    address constant marketingWallet = 0x0ff73122Bba6BD27EbbB0df188AbC53Af2E3CA6e;
    ISeedRouter seedRouter;
    address public tokenAddress;
    uint256 public totalFairlaunchTokenAmount = 30000000000000000000;
    uint256 public totalUsdRaised;
    address private USDT;
    bool public isFairlauchEnabled; 
    bool public isClaimableEnabled;
    IRouter private router;
    address private WETH;
    uint256 public affiliateRaito = 10;
    mapping(address => uint256) public investedUsdtAmount;
    mapping(address => uint256) public claimedTokenAmount;
    mapping(address => address) public affiliateAddress;
    mapping(address => AffiliateAmounts) public affiliateAmount;

    event Fairlaunch(address account, uint256 amount);
    event Claim(address investor, uint256 amount);
    event Affiliate(address from, address to, uint256 amount, bool isEth);
    event PromoCode(address from, string code, uint256 amount);

    constructor(address _router,address _USDT, address _seedRouter) {        
        USDT = _USDT;
        router = IRouter(_router);
        WETH = router.WETH();
        seedRouter = ISeedRouter(_seedRouter);
    }

    function fairlaunch(address _affiliateAddress, bytes calldata _data) public payable {
        require(msg.value > 0, "Need to send value");
        require(!!isFairlauchEnabled, "Fairlaunch is not enabled.");
        uint256 usdtAmount = fetchEthToUsdPrice(msg.value);
        require(usdtAmount > 0, "USD amount must be greater than zero.");
        ( uint256 bonusRatio, string memory code ) = seedRouter.seedChecker(_data);
        uint256 affiliateBonus;
        if(affiliateAddress[msg.sender] == address(0) && _affiliateAddress != address(0) && affiliateAddress[msg.sender] != msg.sender){
            affiliateAddress[msg.sender] = _affiliateAddress;
            affiliateBonus = usdtAmount.mul(affiliateRaito).div(100);
        }
        if(affiliateAddress[msg.sender] != address(0)){
            uint256 _affiliateAmount = (msg.value).mul(affiliateRaito).div(100);
            affiliateAmount[affiliateAddress[msg.sender]].eth += _affiliateAmount;
            _transferEth(affiliateAddress[msg.sender], _affiliateAmount);
            emit Affiliate(msg.sender, affiliateAddress[msg.sender], _affiliateAmount, true);
        }
        uint256 bonusUsdtAmount = usdtAmount.mul(bonusRatio).div(100);
        uint256 finalUsdtAmount = usdtAmount + bonusUsdtAmount + affiliateBonus;
        investedUsdtAmount[msg.sender] += finalUsdtAmount;
        totalUsdRaised += finalUsdtAmount;
        emit PromoCode(msg.sender, code, bonusUsdtAmount);
        emit Fairlaunch(msg.sender, finalUsdtAmount);
    }

    function fairlaunch(uint256 usdtAmount,address _affiliateAddress,bytes calldata _data) public {
        require(!!isFairlauchEnabled, "Fairlaunch is not enabled.");
        require(usdtAmount > 0, "USD amount must be greater than zero.");
        ( uint256 bonusRatio, string memory code ) = seedRouter.seedChecker(_data);
        IERC20(USDT).safeTransferFrom(msg.sender, address(this), usdtAmount);
        uint256 affiliateBonus;
        if(affiliateAddress[msg.sender] == address(0) && _affiliateAddress != address(0) && affiliateAddress[msg.sender] != msg.sender){
            affiliateAddress[msg.sender] = _affiliateAddress;
            affiliateBonus = usdtAmount.mul(affiliateRaito).div(100);
        }
        if(affiliateAddress[msg.sender] != address(0)){
            uint256 _affiliateAmount = (usdtAmount).mul(affiliateRaito).div(100);
            affiliateAmount[affiliateAddress[msg.sender]].usdt += _affiliateAmount;
            IERC20(USDT).safeTransfer(affiliateAddress[msg.sender], _affiliateAmount);
            emit Affiliate(msg.sender, affiliateAddress[msg.sender], _affiliateAmount, false);
        }
        uint256 bonusUsdtAmount = usdtAmount.mul(bonusRatio).div(100);
        uint256 finalUsdtAmount = usdtAmount + bonusUsdtAmount + affiliateBonus;
        investedUsdtAmount[msg.sender] += finalUsdtAmount;
        totalUsdRaised += finalUsdtAmount;
        emit PromoCode(msg.sender, code, bonusUsdtAmount);
        emit Fairlaunch(msg.sender, finalUsdtAmount);
    }

    function fairlaunch(address _affiliateAddress) public payable {
        require(msg.value > 0, "Need to send value");
        require(!!isFairlauchEnabled, "Fairlaunch is not enabled.");
        uint256 usdtAmount = fetchEthToUsdPrice(msg.value);
        require(usdtAmount > 0, "USD amount must be greater than zero.");
        uint256 affiliateBonus;
        if(affiliateAddress[msg.sender] == address(0) && _affiliateAddress != address(0) && affiliateAddress[msg.sender] != msg.sender){
            affiliateAddress[msg.sender] = _affiliateAddress;
            affiliateBonus = usdtAmount.mul(affiliateRaito).div(100);
        }
        if(affiliateAddress[msg.sender] != address(0)){
            uint256 _affiliateAmount = (msg.value).mul(affiliateRaito).div(100);
            affiliateAmount[affiliateAddress[msg.sender]].eth += _affiliateAmount;
            _transferEth(affiliateAddress[msg.sender], _affiliateAmount);
            emit Affiliate(msg.sender, affiliateAddress[msg.sender], _affiliateAmount, true);
        }
        uint256 finalUsdtAmount = usdtAmount + affiliateBonus;
        investedUsdtAmount[msg.sender] += finalUsdtAmount;
        totalUsdRaised += finalUsdtAmount;
        emit Fairlaunch(msg.sender, finalUsdtAmount);
    }

    function fairlaunch(uint256 usdtAmount,address _affiliateAddress) public {
        require(!!isFairlauchEnabled, "Fairlaunch is not enabled.");
        require(usdtAmount > 0, "USD amount must be greater than zero.");
        IERC20(USDT).safeTransferFrom(msg.sender, address(this), usdtAmount);
        uint256 affiliateBonus;
        if(affiliateAddress[msg.sender] == address(0) && _affiliateAddress != address(0) && affiliateAddress[msg.sender] != msg.sender){
            affiliateAddress[msg.sender] = _affiliateAddress;
            affiliateBonus = usdtAmount.mul(affiliateRaito).div(100);
        }
        if(affiliateAddress[msg.sender] != address(0)){
            uint256 _affiliateAmount = (usdtAmount).mul(affiliateRaito).div(100);
            affiliateAmount[affiliateAddress[msg.sender]].usdt += _affiliateAmount;
            IERC20(USDT).safeTransfer(affiliateAddress[msg.sender], _affiliateAmount);
            emit Affiliate(msg.sender, affiliateAddress[msg.sender], _affiliateAmount, false);
        }
        uint256 finalUsdtAmount = usdtAmount + affiliateBonus;
        investedUsdtAmount[msg.sender] += finalUsdtAmount;
        totalUsdRaised += finalUsdtAmount;
        emit Fairlaunch(msg.sender, finalUsdtAmount);
    }

    function claim() public {
        require(!!isClaimableEnabled,"Claimable is not enabled.");
        uint256 _claimableAmount = claimableAmount(msg.sender);
        require(_claimableAmount > 0,"There is no claimable amount.");
        claimedTokenAmount[msg.sender] += _claimableAmount;
        IERC20(tokenAddress).safeTransfer(msg.sender, _claimableAmount);
        emit Claim(msg.sender, _claimableAmount);
    }

    function claimableAmount(address account) public view returns(uint256) {
        if(totalUsdRaised > 0){
            return (totalFairlaunchTokenAmount.mul(investedUsdtAmount[account]).div(totalUsdRaised)).sub(claimedTokenAmount[account]);
        } else {
            return 0;
        }
    } 

    function updateTotalFairlaunchTokenAmount(uint256 _amount) external onlyOwner {
        totalFairlaunchTokenAmount = _amount;
    }

     function setToken(address _token) external onlyOwner {
        tokenAddress = _token;
    }

    function setSeedRouter(address _seedRouter) external onlyOwner {
        seedRouter = ISeedRouter(_seedRouter);
    }

    function updateAffiliateRatio(uint256 _newRatio) external onlyOwner{
        affiliateRaito = _newRatio;
    }
    
        // only use in case of emergency or after presale is over
    function withdrawTokens(address _tokenAddress, uint256 _amount) external onlyOwner {
        IERC20(_tokenAddress).safeTransfer(marketingWallet, _amount);
    }

        // owner can withdraw ETH after people get tokens
    function withdrawETH(uint256 _amount) external onlyOwner {
        _transferEth(marketingWallet, _amount);
    }

    function _transferEth(address _account,uint256 _amount) internal {
        (bool sent, bytes memory data) = _account.call{value: _amount}("");
        require(sent, "Failed to send Ether");
    }

    function updateFairlaunchStatus(bool _flag) external onlyOwner {
        isFairlauchEnabled = _flag;
    }

    function updateClaimableStatus(bool _flag) external onlyOwner {
        isClaimableEnabled = _flag;
    }

    function fetchEthToUsdPrice(uint256 _amount) public view returns(uint256) {
        address[] memory path = new address[](2);

        path[0] = USDT;
        path[1] = WETH;
        
        try router.getAmountsIn(1 ether,path) {
            uint256[] memory amounts = router.getAmountsIn(1 ether,path); 
            return amounts[0].mul(_amount).div(1 ether);

        } catch {
            return 0;
        }
    }

    receive() external payable {
        fairlaunch(address(0));
    }

}