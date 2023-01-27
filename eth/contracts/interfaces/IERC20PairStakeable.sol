// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

interface IERC20PairStakeable {

    function getReserves() external view returns(uint256, uint256);

    function stake(address from) external returns(uint liquidity);

    function unstake(address from) external returns(uint amountA, uint amountB);

    function swap(address tokenIn, address to) external returns(uint256 amountOut);

    function approveFrom(
        address owner, 
        address spender, 
        uint amount
        ) external returns(bool);
        
}