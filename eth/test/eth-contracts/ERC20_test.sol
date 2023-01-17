// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import "./TokenTestable.sol";
contract ERC20_test is TokenTestable {

    

    function test() public {
        
        uint totalSupply = 100000000 * DEX18;

        uint test_var = 1000_000;

        ERC20 token = newToken("T01", totalSupply);

        TokenHolder holder = new TokenHolder();

        token.transfer(address(holder), test_var);

        assert(token.balanceOf(address(holder)) == test_var);
        assert(token.balanceOf(address(this)) == totalSupply - (test_var));

        holder.approveTo(address(token), address(this), test_var);
        token.transferFrom(address(holder), address(this), test_var);

        assert(token.balanceOf(address(holder)) == 0);
        assert(token.balanceOf(address(this)) == totalSupply);

        emit Success();

    }
}