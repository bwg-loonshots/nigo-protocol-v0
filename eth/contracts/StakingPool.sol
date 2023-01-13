// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import "./StakingToken.sol";
import "./libs/SafeTransfer.sol";
import "./interfaces/IERC3156FlashLender.sol";

contract StakingPool is IERC3156FlashLender{
    using SafeMath for uint;
    using SafeTransfer for address;

    // real token => stToken(a.k.a stToken)
    mapping(address => address) public tokens;

    mapping(address => bool) public isStToken;
    
    function stake(address token, uint amount) external returns(address stToken, uint staked) {

        if(tokens[token] == address(0)) {
            tokens[token] = address(new StakingToken(token));
            isStToken[tokens[token]] = true;
        }

        token._transferFrom(msg.sender, tokens[token], amount);

        staked = StakingToken(tokens[token]).stake(msg.sender);

        stToken = tokens[token];

    }

    function unstake(address token, uint staked) external returns(uint amount) {

        amount = StakingToken(tokens[token]).unstake(msg.sender, staked);
        
    }

    function maxFlashLoan(address token) external view returns (uint256){

        if(isStToken[token]) {
            return type(uint256).max - StakingToken(token).totalSupply();
        }

        require(tokens[token] != address(0), "nigo: unsupported token");
        return StakingToken(tokens[token]).reserved();
        
    }

    function flashFee(address token, uint256 amount) external view returns (uint256) {

        if(isStToken[token]) {
            return StakingToken(token).flashFee(amount);
        }

        require(tokens[token] != address(0), "nigo: unsupported token");
        return StakingToken(tokens[token]).flashFee(amount);

    }

    function flashLoan(
        IERC3156FlashBorrower receiver,
        address token,
        uint256 amount,
        bytes calldata data
    ) external returns (bool) {

        if(isStToken[token]) {
            return StakingToken(token).flashMint(receiver, amount, data);
        }

        require(tokens[token] != address(0), "nigo: unsupported token");
        return StakingToken(tokens[token]).flashLoan(receiver, amount, data);

    }
    


}