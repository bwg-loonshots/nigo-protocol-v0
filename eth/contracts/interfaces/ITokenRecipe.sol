// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import "./IERC20Stakeable.sol";

interface ITokenRecipe {

    function newStakingToken(address token) external returns(IERC20Stakeable);

}