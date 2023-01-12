// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import "./StakableToken.sol";
import "./libs/SafeTransfer.sol";
import "./interfaces/IERC3156FlashLender.sol";

contract StakingPool is IERC3156FlashLender{
    using SafeMath for uint;
    using SafeTransfer for address;

    // real token => stToken(a.k.a stToken)
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

    function maxFlashLoan(address token) external view returns (uint256){

        require(tokens[token] != address(0), "nigo: unsupported token");
        return StakableToken(tokens[token]).reserved();
        
    }

    function flashFee(address token, uint256 amount) external view returns (uint256) {

        require(tokens[token] != address(0), "nigo: unsupported token");
        return StakableToken(tokens[token]).flashFee(amount);

    }

    function flashLoan(
        IERC3156FlashBorrower receiver,
        address token,
        uint256 amount,
        bytes calldata data
    ) external returns (bool) {

        require(tokens[token] != address(0), "nigo: unsupported token");
        return StakableToken(tokens[token]).erc3156(receiver, amount, data);

    }
    


}