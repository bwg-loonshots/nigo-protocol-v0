// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import "../../contracts/ERC20.sol";

contract TokenTestable {
    
    uint internal constant DEX18 = 10 ** 18;

    function newToken(string memory symbol, uint totalSupply) internal returns(ERC20) {
        return new ERC20(
            totalSupply,
            "test token",
            18,
            symbol
        );
    }
}