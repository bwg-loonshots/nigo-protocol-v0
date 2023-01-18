// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import "./TokenTestable.sol";
import "../../contracts/StakingToken.sol";
import "./TokenHolder.sol";

contract StakingToken_test_approveFrom is TokenTestable {
    
    StakingToken stToken;

    function test() public {

        ERC20 token = newToken("T01", 100_000_000 * DEX18);

        stToken = new StakingToken(address(token));
        
        TokenHolder holderA = new TokenHolder();
        token.transfer(address(holderA), 1000_000);
        holderA.transferTo(address(token), address(stToken), 1000_000);
        stToken.stake(address(holderA));

        stToken.approveFrom(address(holderA), address(this), 1000_000);
        stToken.transferFrom(address(holderA), address(stToken), 1000_000);
        stToken.unstake(address(this));
        assert(stToken.totalSupply() == 0);
        assert(stToken.balanceOf(address(this)) == 0);
        assert(token.balanceOf(address(this)) == 100_000_000 * DEX18);        


    }

}