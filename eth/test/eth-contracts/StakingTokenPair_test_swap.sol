// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import "./TokenTestable.sol";
import "../../contracts/StakingTokenPair.sol";

contract StakingTokenPair_test_swap is TokenTestable {
    using SafeMath for uint;

    uint public reservedA;
    uint public reservedB;

    uint public totalSupply;

    function test() public {

        ERC20 tokenA = newToken("T01", 100_000_000 * DEX18);
        ERC20 tokenB = newToken("T02", 100_000_000 * DEX18);

        StakingTokenPair pair = new StakingTokenPair(address(tokenA), address(tokenB));

        uint amountA = 10 * DEX18;
        uint amountB = 500 * DEX18;

        tokenA.transfer(address(pair), amountA);
        tokenB.transfer(address(pair), amountB);

        pair.stake(address(this));

        (uint rA, uint rB) = pair.getReserves();


        assert(pair.totalSupply() == pair.balanceOf(address(this)));
        assert(tokenA.balanceOf(address(pair)) == amountA);
        assert(tokenB.balanceOf(address(pair)) == amountB);
        assert(rA == amountA && rB == amountB);

        uint k = pair.k();
        tokenA.transfer(address(pair), 1 * DEX18);
        pair.swap(address(tokenA), address(this));
        (reservedA, reservedB) = pair.getReserves();
        assert(reservedA > amountA);
        assert(reservedB < amountB);
        assert(k < pair.k());

        pair.transfer(address(pair), pair.balanceOf(address(this)));
        pair.unstake(address(this));
        (reservedA, reservedB) = pair.getReserves();
        assert(reservedA == 0 && reservedB == 0);
        assert(pair.totalSupply() == 0);

        assert(tokenA.balanceOf(address(this)) == 100_000_000 * DEX18);
        assert(tokenB.balanceOf(address(this)) == 100_000_000 * DEX18);


    }

}