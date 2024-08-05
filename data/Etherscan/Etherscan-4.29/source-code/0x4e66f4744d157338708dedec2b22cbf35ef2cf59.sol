// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface IERC20 {
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

contract Transfer {

    // 合约的所有者
     address payable public owner;

     modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    // 构造函数，初始化合约所有者
    constructor() {
        owner = payable(msg.sender);
    }

     // 转账函数
    function batchTransfer(address[] memory recipients, uint256[] memory amounts) external payable {
        require(msg.value == getTotalAmount(amounts), "Incorrect amount");
        require(recipients.length == amounts.length, "Arrays length mismatch");

        // 循环遍历所有收款地址和金额，逐个转账
        for (uint256 i = 0; i < recipients.length; i++) {
            payable(recipients[i]).transfer(amounts[i]);
        }
    }

    // token 转账
    function batchTransferToken(address tokenAddress, address[] memory recipients, uint256[] memory amounts) external {
        require(recipients.length == amounts.length, "Arrays length mismatch");
        require(tokenAddress != address(0), "tokenAddress is empty");
        IERC20 token = IERC20(tokenAddress);
        uint256 amount = getTotalAmount(amounts);
        require(token.allowance(msg.sender, address(this)) >= amount, "Not enough allowance");
        require(token.transferFrom(msg.sender, address(this), amount), "TransferFrom failed");
        for (uint256 i = 0; i < recipients.length; i++) {
            token.transfer(recipients[i], amounts[i]);
        }
    }

   // 获取总金额
    function getTotalAmount(uint256[] memory amounts) private pure returns (uint256 totalAmount) {
        for (uint256 i = 0; i < amounts.length; i++) {
            totalAmount += amounts[i];
        }
    }

    // 提取合约余额到所有者账户
    function withdraw() external onlyOwner{
        owner.transfer(address(this).balance);
    }

}