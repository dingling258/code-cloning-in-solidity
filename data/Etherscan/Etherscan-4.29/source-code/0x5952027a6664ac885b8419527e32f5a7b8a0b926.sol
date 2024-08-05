// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

contract MarginTrading is Ownable {

    using SafeMath for uint256;
    address public poolTokenAddress;
    address public operatorWallet;

    struct Order {
        uint256 margin; // token amount in wei
        uint64 leverage; // leverage ex: 5x, 10x 
        uint256 totalFund; // fund with leverage
        address orderOwner;
        address poolTokenAddress_;
        uint256 liquidationUnderlyingAssest;
        bool isActive;
        bool isliquidated;
        uint256 amountunderlineAssest;
        Side side;
        ORDERTYPE orderType; // market , limit 
        uint256 createdAt;
    }

    mapping(uint256 => Order) public orders; // orderId => Order
    mapping(address => uint256[]) private userOrderIds;

    enum Side {
        LONG,
        SHORT
    }
    enum ORDERTYPE {
        MARKET,
        LIMIT
    }

    enum UpdateTicker {
        GREATER,
        LESS
    }
    
    event OrderCreatedEvent(
        uint256  margin,
        uint64  leverage,
        uint256  totalFund,
        address  orderOwner,    
        uint256 liquidationUnderlyingAssest,
        bool isActive, 
        Side side,      
        uint256 createdAt,
        uint256 amountunderlineAssest
    );

    event cancelOrderEvent(
        address user,
        uint256 orderId,
        uint256 canceledAt,
        uint256 returnAmount

    );
    
    event liquidateUserEvent(
        uint256 orderId,
        uint256 liquidatedAt

    );

    modifier onlyOperator() {
        require(msg.sender == operatorWallet ," Invalid operator wallet");
        _;
    }

    constructor(address _poolTokenAddress, address _operatorWallet) {
        poolTokenAddress=_poolTokenAddress;
        operatorWallet = _operatorWallet;
    }

    function createOrder(
        uint256 newOrderId,
        uint256 marginAmount, // in USDT wei
        uint256 underlyingAssets,           // underline assest
        uint8 leverage, // In USDT
        uint256 liquidationUnderlyingAssest,
        Side side,
        ORDERTYPE orderType
    ) 

    external returns(Order memory) {
        userOrderIds[msg.sender].push(newOrderId); // we are assuming the order id will be unique from backend....
        Order storage userDetails = orders[newOrderId];
        require(IERC20(poolTokenAddress).balanceOf(msg.sender) >= marginAmount,"Insufficient token balance");
        IERC20(poolTokenAddress).transferFrom(msg.sender, address(this), marginAmount);
        userDetails.margin= marginAmount;
        userDetails.leverage = leverage;
        userDetails.totalFund = (marginAmount.mul(leverage));
        userDetails.orderOwner = msg.sender;
        userDetails.poolTokenAddress_ = poolTokenAddress;
        userDetails.liquidationUnderlyingAssest = liquidationUnderlyingAssest;
        userDetails.createdAt = block.timestamp;
        userDetails.side = side;
        userDetails.isActive= true;
        userDetails.amountunderlineAssest= underlyingAssets;
        userDetails.orderType = orderType;
        emit OrderCreatedEvent(marginAmount,leverage,(marginAmount.mul(leverage)), msg.sender,liquidationUnderlyingAssest,true,side,block.timestamp,underlyingAssets);
        return(userDetails);
    }

    function createOrderForUser(
        address userAddress,
        uint256 newOrderId,
        uint256 marginAmount, // in USDT wei
        uint256 underlyingAssets,           // underline assest
        uint8 leverage, // In USDT
        uint256 liquidationUnderlyingAssest,
        Side side,
        ORDERTYPE orderType
    )

    external onlyOperator() returns(Order memory) {
        userOrderIds[msg.sender].push(newOrderId); // we are assuming the order id will be unique from backend....
        Order storage userDetails = orders[newOrderId];
        require(IERC20(poolTokenAddress).balanceOf(userAddress) >= marginAmount,"Insufficient token balance");
        IERC20(poolTokenAddress).transferFrom(userAddress, address(this), marginAmount);
        userDetails.margin= marginAmount;
        userDetails.leverage = leverage;
        userDetails.totalFund = (marginAmount.mul(leverage));
        userDetails.orderOwner = userAddress;
        userDetails.poolTokenAddress_ = poolTokenAddress;
        userDetails.liquidationUnderlyingAssest = liquidationUnderlyingAssest;
        userDetails.createdAt = block.timestamp;
        userDetails.side = side;
        userDetails.isActive= true;
        userDetails.amountunderlineAssest= underlyingAssets;
        userDetails.orderType = orderType;
        emit OrderCreatedEvent(marginAmount,leverage,(marginAmount.mul(leverage)), userAddress,liquidationUnderlyingAssest,true,side,block.timestamp,underlyingAssets);
        return(userDetails);
    }
    
    function cancelOrder(uint256 _orderId, uint256 returnAmount,address userAdress) external onlyOperator() returns (bool){
        require(orders[_orderId].isActive,"this order already deactivated");
        require(!(orders[_orderId].isliquidated),"this order is  liquidated");
        require(orders[_orderId].orderOwner==userAdress,"owner mismatch");
        require(IERC20(poolTokenAddress).balanceOf(address(this))>=returnAmount,"insufficent amount in contract");
        orders[_orderId].isActive=false;
        IERC20(poolTokenAddress).transfer(userAdress,returnAmount);
        emit cancelOrderEvent(userAdress,_orderId,block.timestamp,returnAmount);
        return true;
    }
     
    function liquidateUser(uint256 _orderId) external onlyOperator() returns (bool){
        require(orders[_orderId].isActive,"this order already deactivated");
        require(!(orders[_orderId].isliquidated),"this order is liquidated");
        orders[_orderId].isActive=false;
        orders[_orderId].isliquidated=true;
        emit liquidateUserEvent(_orderId,block.timestamp);
        return true;
   }

    /// @notice Function to get user order ids 
    /// @param userAddress The user address 
    function getUserOrderIds(address userAddress) external view returns(uint256[] memory){
        return userOrderIds[userAddress];
    }
    
    /// @notice Function to set the operator wallet
    /// @param _newOperator The new operator wallet
    function setOperatorWallet(address _newOperator) external onlyOwner {
        require(_newOperator != address(0), "Invalid wallet");
        operatorWallet = _newOperator;
    }
     
    /**
    * @dev Allows the owner to drain the remaining ERC20 tokens held by this contract.
    * @notice Transfers all tokens held by this contract to the owner's address.
    * @dev Requires that there are tokens available to drain.
    */ 
    function drainToken() external onlyOwner() {
        uint256 balance = IERC20(poolTokenAddress).balanceOf(address(this));
        require(balance > 0, "No tokens to drain");
        IERC20(poolTokenAddress).transfer(owner(), balance);
    }

    /**
    * @dev Allows the owner to drain the remaining Ether (ETH) held by this contract.
    * @notice Transfers all Ether held by this contract to the owner's address.
    */
    function drainETH() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

     receive() external payable {}
}