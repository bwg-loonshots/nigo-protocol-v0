// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import "./interfaces/ITokenPairRecipe.sol";
import "./StakingTokenPair.sol";

contract TokenPairRecipeV1 is ITokenPairRecipe {

    function newStakingTokenPair(address tokenA, address tokenB) external override returns(IERC20PairStakeable) {
        return new StakingTokenPair(tokenA, tokenB);
    }


}