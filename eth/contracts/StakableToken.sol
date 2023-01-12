// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import "./MintableToken.sol";
import "./libs/SafeTransfer.sol";

contract StakableToken is MintableToken {
    using SafeMath for uint;
    using SafeTransfer for address;

    address public token;

    uint public reserved;

    constructor(address _token)
    MintableToken(
        string(abi.encodePacked("Nigo Staked", StakableToken(token).name())),
        string(abi.encodePacked("ng", StakableToken(token).symbol()))) {
        token = _token;
    }

    function stake(address from) external returns(uint staked){

        uint balance = IERC20(token).balanceOf(address(this));
        uint amount = balance.sub(reserved);

        require(amount > 0, "not found staked value");

        if(totalSupply == 0) {
            staked = amount;
        } else {
            staked = amount.mul(totalSupply) / reserved;
        }

        _mint(from, staked);

        reserved = balance;

    }

    function unstake(address from, uint staked) external returns(uint amount) {

        amount = IERC20(token).balanceOf(address(this)).mul(staked) / totalSupply;

        _burn(from, staked);

        token._transfer( from, amount);

        reserved = IERC20(token).balanceOf(address(this));

    }

}