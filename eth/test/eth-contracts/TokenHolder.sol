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