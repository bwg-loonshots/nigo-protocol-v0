// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 < 0.9.0;

import "./interfaces/ITokenPairAggregatable.sol";
import "./interfaces/IERC20Token.sol";


contract TokenPairAggregator {

    address[] pairs;

    function _transfer(
        address token, 
        address to, 
        uint256 value) private {
        (bool success,) = token.call(
            abi.encodeWithSignature("transfer(address,uint256)", to, value)
        );
        require(success, "transfer Failed");
    }

    function _transferFrom(
        address token, 
        address from, 
        address to, 
        uint256 value) private {
        (bool success,) = token.call(
            abi.encodeWithSignature("transferFrom(address,address,uint256)", from, to, value)
        );
        require(success, "transfer from Failed");
    }

    function swap(
        address tokenIn, 
        uint256 amountIn,
        address to
        ) external returns(uint256 amountOut) {

        address maxOutPair;
        uint256 maxOut;

        address maxOutPair_2nd;

        address minOutPair;
        uint256 minOut = 2 ** 256 - 1;

        for(uint i = 0; i < pairs.length; i++) {
            
            address pair = pairs[i];
            amountOut = calcAmountOut(tokenIn, amountIn, pair);
            
            if(maxOut < amountOut) {
                maxOutPair_2nd = maxOutPair;
                maxOut = amountOut;
                maxOutPair = pair;
            }

            if(minOut > amountOut) {
                minOut = amountOut;
                minOutPair = pair;
            }
            
        }

        _transferFrom(tokenIn, msg.sender, address(this), amountIn);
        IERC20Token(tokenIn).approve(maxOutPair, amountIn);
        ITokenPairAggregatable(maxOutPair).swap(tokenIn, amountIn, to);





    
    }

    function calcAmountOut(
        address tokenIn, 
        uint256 amountIn, 
        address pair) private returns (uint256 amountOut) {
        
        (uint256 reservedIn, uint256 reservedOut, uint32 fee, uint8 feeDecimal) = 
            ITokenPairAggregatable(pair).getReservesOrderedBy(tokenIn);

        uint256 shift = 10 ** feeDecimal;
        uint256 amountInWithFee = amountIn * (shift - fee);
        uint256 numerator = amountInWithFee * reservedOut;
        uint256 denominator = (reservedIn * shift) + amountInWithFee;
        amountOut = numerator / denominator;
    }

}