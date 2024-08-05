// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

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
}

contract Authorized is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Authorized: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(
            newOwner != address(0),
            "Authorized: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract SRB_Marketplace is Context, Authorized {
    uint256 public taxCollect;
    uint256 public totalSelling;
    uint256 public volumeSeller;

    uint256 public taxFee = 10;
    event CheckOut(
        address indexed buyer,
        address indexed seller,
        uint256 price
    );
    event CheckoutFailed(string errormessage);
    event ChangeTax(uint256 _tax);
    event EtherReceived(address indexed from, uint256 amount);
    event ERC20Withdrawn(
        address indexed sender,
        address token,
        uint256 amount,
        address to
    );
    event ETHWitdrawm(address indexed sender, uint256 amount, address to);

    function getEtherBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function setTax(uint256 _tax) external onlyOwner {
        taxFee = _tax;
        emit ChangeTax(_tax);
    }

    function getTokenBalance(address tokenAddress)
        public
        view
        returns (uint256)
    {
        IERC20 token = IERC20(tokenAddress);
        return token.balanceOf(address(this));
    }

    function transferERC20(
        address tokenAddress,
        uint256 amount,
        address recipient
    ) public onlyOwner {
        IERC20 token = IERC20(tokenAddress);
        require(token.transfer(recipient, amount), "Transfer failed");
        emit ERC20Withdrawn(_msgSender(), tokenAddress, amount, recipient);
    }

    function withdrawAllERC20(address tokenAddress, address recipient)
        public
        onlyOwner
    {
        IERC20 token = IERC20(tokenAddress);
        uint256 balance = token.balanceOf(address(this));
        require(token.transfer(recipient, balance), "Transfer failed");
        emit ERC20Withdrawn(_msgSender(), tokenAddress, balance, recipient);
    }

    function withdrawEther(uint256 amount, address recipient) public onlyOwner {
        require(amount <= address(this).balance, "Insufficient balance");
        payable(recipient).transfer(amount);
        emit ETHWitdrawm(_msgSender(), amount, recipient);
    }

    function withdrawAllEther(address recipient) public onlyOwner {
        uint256 amount = address(this).balance;
        payable(recipient).transfer(amount);
        emit ETHWitdrawm(_msgSender(), amount, recipient);
    }

    function checkout(address[] memory seller, uint256[] memory price)
        external
    {
        uint256 i = 0;
        IERC20 token = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);
        while (i < seller.length) {
            uint256 tax = (price[i] * taxFee) / 100;
            token.transferFrom(msg.sender, address(this), price[i]);
            token.transfer(seller[i], price[i] - tax);
            emit CheckOut(msg.sender, seller[i], price[i]);
            totalSelling++;
            i++;
        }
    }

    function checkOutWithToken(
        address addresses,
        address[] memory seller,
        uint256[] memory price
    ) external {
        uint256 i = 0;
        IERC20 token = IERC20(addresses);
        while (i < seller.length) {
            uint256 tax = (price[i] * taxFee) / 100;
            token.transferFrom(msg.sender, address(this), price[i]);
            token.transfer(seller[i], price[i] - tax);
            emit CheckOut(msg.sender, seller[i], price[i]);
            totalSelling++;
            i++;
        }
    }

    receive() external payable {}
}