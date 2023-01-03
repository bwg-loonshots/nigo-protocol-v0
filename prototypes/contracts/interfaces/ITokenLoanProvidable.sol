// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 < 0.9.0;

interface ITokenLoanProvidable {

    function loan(
        address tokenOut, 
        uint256 amountOut, 
        address to
        ) external returns (uint256 amountIn);

}