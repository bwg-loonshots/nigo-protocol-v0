// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 < 0.9.0;

interface ITokenPairAggregatable {

    function getReservesOrderedBy(address tokenA) external 
        returns(
            uint256 reservedA, 
            uint256 reservedB, 
            uint32 fee, 
            uint8 feeDecimal);

    function swap(
        address tokenIn, 
        uint256 amountIn,
        address to
        ) external 
        returns(uint256 amountOut);

}