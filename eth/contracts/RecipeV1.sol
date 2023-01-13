// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import "./interfaces/IRecipe.sol";
import "./StakingToken.sol";

contract RecipeV1 is IRecipe {

    function newStakingToken(address token) external returns(IERC20Stakeable) {
        return new StakingToken(token);
    }

}