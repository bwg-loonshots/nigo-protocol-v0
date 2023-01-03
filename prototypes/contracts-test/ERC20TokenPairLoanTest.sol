// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 < 0.9.0;

import "./ERC20TokenPairTestable.sol";
import "../contracts/interfaces/IERC20LoanConsumer.sol";



contract ERC20TokenPairLoanTest is ERC20TokenPairTestable, IERC20LoanConsumer{

    uint256 private constant DEX18 = 10 ** 18;

    uint256 loanAmountParameterSnapshot;

    function testAll() external {

        // token pair creation test
        createTokenAndPair();

        // first add liquidity test
        addLiquidity(10 * DEX18, 500 * DEX18);

        (uint r0, uint r1) = getReserves();

        require(r0 == 10 * DEX18 && r1 == 500 * DEX18, "first add liquidity fail");


        // loan A test
        loanA(1 * DEX18);

        (uint r0_1,) = getReserves();

        require(r0_1 > r0, "loan A test");

        require(loanAmountParameterSnapshot == 1 * DEX18, "loan A Amount fail");

        removeLiquidity(pair.balanceOf(address(this)));

        (r0, r1) = getReserves();

        require(r0 + r1 == 0 && pair.k() == 0, "remove liquidity fail");


        
    }

    function perform(address sender, address token, uint256 amount) external override{

        uint dept = amount * 1003 / 1000;

        require(sender == address(this), "invalid loan starter");

        require(address(tokenA) == token, "invalid token loan");

        // do something with amount

        loanAmountParameterSnapshot = amount;

        tokenA.transfer(msg.sender, dept);
    }

}
