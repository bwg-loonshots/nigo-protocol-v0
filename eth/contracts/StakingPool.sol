// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import "./StakableToken.sol";
import "./libs/SafeTransfer.sol";

contract StakingPool {
    using SafeMath for uint;
    using SafeTransfer for address;

    // real token => stToken(a.k.a ngToken)
    mapping(address => address) public tokens;

    function stake(address token, uint amount) external returns(address stToken, uint staked) {

        if(tokens[token] == address(0)) {
            tokens[token] = address(new StakableToken(token));
        }

        token._transferFrom(msg.sender, tokens[token], amount);

        staked = StakableToken(tokens[token]).stake(msg.sender);

        stToken = tokens[token];

    }

    function unstake(address token, uint staked) external returns(uint amount) {

        amount = StakableToken(tokens[token]).unstake(msg.sender, staked);
        
    }


}