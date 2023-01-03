// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 < 0.9.0;

interface IERC20LoanConsumer {

    function perform(address sender, address token, uint256 amount) external;

}