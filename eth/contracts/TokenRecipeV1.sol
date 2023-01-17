// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import "./interfaces/ITokenRecipe.sol";
import "./StakingToken.sol";

contract TokenRecipeV1 is ITokenRecipe {

    function newStakingToken(address token) external override returns(IERC20Stakeable) {
        return new StakingToken(token);
    }

}