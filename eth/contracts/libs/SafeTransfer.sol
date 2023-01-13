// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

library SafeTransfer {

    function _transfer(
        address token, 
        address to, 
        uint256 value) internal returns(bool) {
        (bool success,) = token.call(
            abi.encodeWithSignature("transfer(address,uint256)", to, value)
        );
        require(success, "nigo:transfer failed");

        return true;
    }

    function _transferFrom(
        address token, 
        address from, 
        address to, 
        uint256 value) internal returns(bool) {
        (bool success,) = token.call(
            abi.encodeWithSignature("transferFrom(address,address,uint256)", from, to, value)
        );
        require(success, "nigo:transfer from failed");

        return true;
    }
}