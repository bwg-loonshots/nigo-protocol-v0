// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import "./IERC3156FlashBorrower.sol";

interface IERC20Stakeable {

    function token() external returns(address);

    function reserved() external view returns(uint);

    function approveFrom(
        address owner, 
        address spender, 
        uint amount
        ) external returns(bool);

    function stake(address from) external returns(uint staked);

    function unstake(address from) external returns(uint amount);

    function flashFee(uint amount) external view returns(uint256);

    function flashLoan(
        IERC3156FlashBorrower receiver,
        uint amount,
        bytes calldata data
    ) external returns(bool);

    function flashMint(
        IERC3156FlashBorrower receiver,
        uint amount,
        bytes calldata data
    ) external returns(bool);

}