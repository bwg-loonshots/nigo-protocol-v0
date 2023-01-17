// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import "../../contracts/ERC20.sol";

contract TokenHolder {

    function transferTo(address token, address to, uint amount) public {
        IERC20(token).transfer(to, amount);
    }

    function approveTo(address token, address to, uint amount) public {
        IERC20(token).approve(to, amount);
    }
}

contract TokenTestable {
    
    uint internal constant DEX18 = 18 ** 10;

    event Success();

    function newToken(string memory symbol, uint totalSupply) internal returns(ERC20) {
        return new ERC20(
            totalSupply,
            "test token",
            18,
            symbol
        );
    }
}