// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 < 0.9.0;

import "./ERC20TokenPairTestable.sol";


contract ERC20TokenPairTWAPTest is ERC20TokenPairTestable{

    uint256 private constant DEX18 = 10 ** 18;

    uint256 loanAmountParameterSnapshot;

    function testAll() external {

        // token pair creation test
        createTokenAndPair();

        // first add liquidity test
        addLiquidity(10 * DEX18, 500 * DEX18);

        (uint r0, uint r1) = getReserves();

        require(r0 == 10 * DEX18 && r1 == 500 * DEX18, "first add liquidity fail");


        
    }

    function swapAtoB_1() public {
        // swap A B test
        swapAtoB(1 * DEX18);
    }

    function twap() public view returns(uint256, uint256, uint256){
        return pair.getTWAP();
    }

}
