// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 < 0.9.0;

import "./ERC20TokenPairTestable.sol";
import "../contracts/ERC20Token.sol";



contract ERC20TokenPairSwapTest is ERC20TokenPairTestable{

    uint256 private constant DEX18 = 10 ** 18;

    uint256 loanAmountParameterSnapshot;

    function testAll() external {

        // token pair creation test
        createTokenAndPair();

        tokenA.transfer(msg.sender, 1000 * DEX18);
        tokenB.transfer(msg.sender, 1000 * DEX18);

        // first add liquidity test
        addLiquidity(10 * DEX18, 500 * DEX18);

        (uint r0, uint r1) = getReserves();

        require(r0 == 10 * DEX18 && r1 == 500 * DEX18, "first add liquidity fail");

        // swap A B test
        swapAtoB(1 * DEX18);

        (r0, r1) = getReserves();

        require(r0 == 11 * DEX18 && r1 < 500 * DEX18, "swap A B fail");

        // 2nd add liquidity test
        addLiquidity(10 * DEX18, 500 * DEX18);

        (r0, r1) = getReserves();

        require(r0 == 21 * DEX18 && r1< (500 * DEX18) * 2, "2nd add liquidity fail");


        removeLiquidity(pair.balanceOf(address(this)));

        (r0, r1) = getReserves();

        require(r0 + r1 == 0 && pair.k() == 0, "remove liquidity fail");


        
    }

}
