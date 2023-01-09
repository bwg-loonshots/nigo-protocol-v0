// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import "./StakableToken.sol";

contract StakingPool {
    using SafeMath for uint;

    // real token => stToken
    mapping(address => address) public tokens;

    uint fee = 3; // 1 == 0.01%

    function _transfer(
        address token, 
        address to, 
        uint256 value) private {
        (bool success,) = token.call(
            abi.encodeWithSignature("transfer(address,uint256)", to, value)
        );
        require(success, "nigo:transfer Failed");
    }

    function _transferFrom(
        address token, 
        address from, 
        address to, 
        uint256 value) private {
        (bool success,) = token.call(
            abi.encodeWithSignature("transferFrom(address,address,uint256)", from, to, value)
        );
        require(success, "nigo:transfer from Failed");
    }

    function stake(address token, uint amount) external returns(address stToken) {

        _transferFrom(token, msg.sender, address(this), amount);

        stToken = tokens[token];

        if(stToken == address(0)) {
            stToken = address(new StakableToken(
                string(abi.encodePacked("Nigo Staked", StakableToken(token).name())),
                string(abi.encodePacked("nst", StakableToken(token).symbol()))));
            tokens[token] = stToken;
        }

        StakableToken(stToken).mint(msg.sender, amount);

    }

    function unstake(address token, uint staked) external returns(uint amount){

        address stToken = tokens[token];
        require(stToken != address(0), "Nigo : not staked token");

        StakableToken(stToken).burn(msg.sender, staked);

        amount = IERC20(token).balanceOf(address(this)) * staked / IERC20(tokens[token]).totalSupply();
        _transfer(token, msg.sender, amount);

    }


}