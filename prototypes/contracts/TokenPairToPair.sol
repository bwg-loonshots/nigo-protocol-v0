// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 < 0.9.0;

import "./ERC20TokenPair.sol";

contract TokenPairToPair {
    address public tokenA;
    address public tokenB;
    address public tokenC;

    address public pairBA;
    address public pairAC;

     constructor(address _pairBA, address _pairAC ) {
        pairBA = _pairBA;
        pairAC = _pairAC;
        
        tokenA = ERC20TokenPair(pairBA).tokenA();
        tokenB = ERC20TokenPair(pairBA).tokenB();

        address targetA = ERC20TokenPair(pairAC).tokenA();
        tokenC = ERC20TokenPair(pairAC).tokenA();

        bool matchA = tokenA == targetA;
        require(matchA,"tokenA no matched");
    }

    function _transferFrom(address token, address from, address to, uint256 value) private {
        (bool success,) = token.call(
            abi.encodeWithSignature("transferFrom(address,address,uint256)", from, to, value)
        );
        require(success, "transfer from Failed");
    }
    
    function _approve(address token, address spender, uint256 value) private {
        (bool success,) = token.call(
            abi.encodeWithSignature("approve(address,uint256)", spender, value)
        );
        require(success, "transfer from Failed");
    }

    function bytesToUint(bytes memory b) internal pure returns (uint256){
        uint256 number;
        for(uint i=0;i<b.length;i++){
            number = number + uint(uint8(b[i]))*(2**(8*(b.length-(i+1))));
        }
        return number;
    }

    function swapBtoC(uint256 amountIn, address to) external returns(uint256 amountOut) {

        _transferFrom(tokenB, msg.sender, address(this), amountIn); //m->s

        _approve(tokenB,pairBA,amountIn);    //s->pairBA

        (bool successBA, bytes memory resultBA) = pairBA.call(
            abi.encodeWithSignature(
                "swap(address,uint256,address)",
                tokenB, amountIn, address(this)
            )
        );

        require(successBA,"pairBA fail");

        uint256 interAmount = bytesToUint(resultBA) * 997 / 1000;

        _approve(tokenA,pairAC,interAmount); //s->pairAC

        (bool successAC, bytes memory resultAC) = pairAC.call(
            abi.encodeWithSignature(
                "swap(address,uint256,address)",
                tokenA, interAmount, to
            )
        );

        require(successAC,"pairAC fail");

        amountOut = bytesToUint(resultAC);
    }
}