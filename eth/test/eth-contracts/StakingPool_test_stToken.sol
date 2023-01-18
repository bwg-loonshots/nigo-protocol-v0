// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import "../../contracts/TokenRecipeV1.sol";
import "../../contracts/TokenPairRecipeV1.sol";

contract prepair_StakingPool_test_stToken {

    address public tokenRecipe;
    address public tokenPairRecipe;

    function prepair() external {
        tokenRecipe = address(new TokenRecipeV1());
        tokenPairRecipe = address(new TokenPairRecipeV1());
    }

}

import "../../contracts/StakingPool.sol";
import "./TokenTestable.sol";

contract StakingPool_test_stToken is TokenTestable {

    function test(address tokenRecipe, address tokenPairRecipe) external {

        uint totalSupply = 100_000_000 * DEX18;
        uint stAmount = 1000_000 * DEX18;

        ERC20 tokenA = newToken("T01", totalSupply);
        ERC20 tokenB = newToken("T02", totalSupply);


        StakingPool pool = new StakingPool(tokenRecipe, tokenPairRecipe);

        tokenA.approve(address(pool), stAmount);
        address stTokenA = pool.stake(address(tokenA), stAmount);

        tokenB.approve(address(pool), stAmount);
        address stTokenB = pool.stake(address(tokenB), stAmount);  

        (,uint liquidity) = pool.addLiquidity(stTokenA, stTokenB, 10 * DEX18, 500 * DEX18);

        pool.swap(stTokenA, stTokenB, 1 * DEX18);

        pool.removeLiquidity(stTokenA, stTokenB, liquidity);

        pool.unstake(stTokenA, ERC20(stTokenA).balanceOf(address(this)));
        pool.unstake(stTokenB, ERC20(stTokenB).balanceOf(address(this)));

        require(tokenA.balanceOf(address(this)) == totalSupply, "invalid balance");
        require(tokenB.balanceOf(address(this)) == totalSupply, "invalid balance");


    }
}