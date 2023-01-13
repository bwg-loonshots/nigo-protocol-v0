// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import "./IERC20PairStakeable.sol";

interface ITokenPairRecipe {

    function newStakingTokenPair(address tokenA, address tokenB) external returns(IERC20PairStakeable);

}