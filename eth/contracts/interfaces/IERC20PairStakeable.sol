// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

interface IERC20PairStakeable {

    function stake(address from) external returns(uint liquidity);

    function unstake(address from, uint256 liquidity) external returns(uint amountA, uint amountB);

    function swap(address tokenIn, address to) external returns(uint256 amountIn,uint256 amountOut);
}