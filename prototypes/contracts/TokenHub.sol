// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 < 0.9.0;

contract TokenHub {

    // token => owner => balance
    mapping(address => mapping(address => uint256)) balances;

    function deposit(address token, uint256 value) external {
        
    }

    // TODO implements : delegation fund to ERC20TokenSwap


}