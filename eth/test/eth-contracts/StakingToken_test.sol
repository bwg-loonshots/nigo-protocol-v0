// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import "./TokenTestable.sol";
import "../../contracts/StakingToken.sol";

contract StakingToken_test is TokenTestable {

    function test() public {

        uint totalSupply = 100000000 * DEX18;

        ERC20 token = newToken("T01", totalSupply);

        StakingToken stToken = new StakingToken(address(token));

    }
}