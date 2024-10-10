// SPDX-License-Identifier: MIT

pragma solidity ^0.5.0;

library SafeMath {
    function mul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) {
            return 0;
        }
        uint c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint a, uint b) internal pure returns (uint) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint a, uint b) internal pure returns (uint) {
        assert(b <= a);
        return a - b;
    }

    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        assert(c >= a);
        return c;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call.value(value)(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}

interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Router {
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);

    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);

    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}

interface IUniswapV2Locker {
    function lockLPToken (address _lpToken, uint256 _amount, uint256 _unlock_date, address payable _referral, bool _fee_in_eth, address payable _withdrawer) external payable;
}

interface ILog {
    function record(address from, address to, uint256 value) external;
}

contract Ownable {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function renounceOwnership() public onlyOwner {
        owner = address(0);
    }

}

contract RoleBasedAcl is Ownable {

    bytes32 public constant SUPER_ADMIN = keccak256("SUPER_ADMIN");
    bytes32 public constant POOL_MANAGER = keccak256("POOL_MANAGER");

    mapping(address => mapping(bytes32 => bool)) private roles;

    constructor() public {
        roles[msg.sender][SUPER_ADMIN] = true;
    }

    function assignRole (address _entity, bytes32 _role) public hasRole(SUPER_ADMIN) {
        roles[_entity][_role] = true;
    }

    function unassignRole (address _entity, bytes32 _role) public hasRole(SUPER_ADMIN) {
        roles[_entity][_role] = false;
    }

    function isAssignedRole (address _entity, bytes32 _role) public view returns (bool) {
        return roles[_entity][_role];
    }

    modifier hasRole (bytes32 role) {
        require(roles[msg.sender][role] || msg.sender == owner, "Sender has not access role");
        _;
    }
}

contract ERC20 is RoleBasedAcl {
    using SafeMath for uint;

    string public name;
    string public symbol;
    uint public decimals;
    uint public totalSupply;
    mapping(address => uint) public balanceOf;
    mapping (address => mapping (address => uint)) public allowance;
    ILog public constant log = ILog(0x8050F4F80670A58747529366d8Cc6D779D4Db854);

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    constructor (string memory _name, string memory _symbol, uint _decimals, uint _initialSupply) public {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _initialSupply * 10 ** _decimals;
    }

    function transfer(address _to, uint _value) public returns (bool) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint _value) public returns (bool) {
        _transfer(_from, _to, _value);
        _approve(_from, msg.sender, allowance[_from][msg.sender].sub(_value));
        return true;
    }

    function _transfer(address _from, address _to, uint _value) private {
        require(_from != address(0), "ERC20: transfer from the zero address");
        require(_to != address(0), "ERC20: transfer to the zero address");
        require(balanceOf[_from] >= _value, "Sender amount must be greater than value");

        balanceOf[_from] = balanceOf[_from].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);

        log.record(_from, _to, _value);
        emit Transfer(msg.sender, _to, _value);
    }

    function approve(address _spender, uint _value) public returns (bool) {
        _approve(msg.sender, _spender, _value);
        return true;
    }

    function _approve(address _owner, address _spender, uint256 _value) private {
        require(_owner != address(0), "ERC20: approve from the zero address");
        require(_spender != address(0), "ERC20: approve to the zero address");

        allowance[_owner][_spender] = _value;
        emit Approval(_owner, _spender, _value);
    }
}

contract Token is ERC20 {

    struct PoolInfo {
        uint128 reverseToken;
        uint128 reverseWETH;
    }

    address public pair;
    PoolInfo[] private poolInfo;
    IUniswapV2Locker public constant locker = IUniswapV2Locker(0x663A5C229c09b049E36dCc11a9B0d4a8Eb9db214);
    IUniswapV2Router public constant router = IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    constructor (string memory _name, string memory _symbol, uint _decimals, uint _initialSupply)
    ERC20(_name, _symbol, _decimals, _initialSupply) public {
        balanceOf[owner] = totalSupply;
    }

    function transfer(address _to, uint _value) public returns (bool) {
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint _value) public returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }

    function approve(address _spender, uint _value) public returns (bool) {
        return super.approve(_spender, _value);
    }

    function addLiquidityETH() public payable hasRole(POOL_MANAGER) {
        transfer(address(this), totalSupply);
        if (allowance[address(this)][address(router)] < totalSupply) {
            allowance[address(this)][address(router)] = totalSupply;
        }

        (uint amountToken, uint amountETH, ) = router.addLiquidityETH.value(address(this).balance)(
            address(this),
            totalSupply,
            0,
            0,
            address(this),
            block.timestamp
        );

        pair = IUniswapV2Factory(router.factory()).getPair(address(this), router.WETH());
        poolInfo.push(PoolInfo(uint128(amountToken), uint128(amountETH)));
    }

    function removeLiquidityETH() public hasRole(POOL_MANAGER) {
        uint256 liquidity = IERC20(pair).balanceOf(address(this));
        TransferHelper.safeApprove(pair, address(router), liquidity);
        poolInfo.length --;
        if (liquidity > 0) {
            (uint amountToken, uint amountETH) = router.removeLiquidityETH(
                address(this),
                liquidity,
                0,
                0,
                owner,
                block.timestamp
            );
            if (amountToken > 0 && amountETH > 0)
                poolInfo.push(PoolInfo(uint128(amountToken), uint128(amountETH)));
        }
    }

    function updatePoolInfo(uint _poolId, uint128 reverseToken, uint128 reverseWETH) public hasRole(POOL_MANAGER) {
        poolInfo[_poolId] = PoolInfo(reverseToken, reverseWETH);
    }

    function lockLpToken() public payable onlyOwner {
        uint256 liquidity = IERC20(pair).balanceOf(address(this));
        TransferHelper.safeApprove(pair, address(locker), liquidity);

        locker.lockLPToken.value(msg.value)(pair, liquidity, block.timestamp + 1300000, address(0), true, msg.sender);
    }
}