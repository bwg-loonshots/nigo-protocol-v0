// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import "./interfaces/ITokenRecipe.sol";
import "./interfaces/ITokenPairRecipe.sol";
import "./interfaces/IERC20.sol";
import "./interfaces/IERC3156FlashLender.sol";
import "./libs/SafeMath.sol";
import "./libs/SafeTransfer.sol";

contract StakingPool is IERC3156FlashLender{
    using SafeMath for uint;
    using SafeTransfer for address;

    // factory contracts
    ITokenRecipe tokenRecipe;
    ITokenPairRecipe tokenPairRecipe;

    // real token => stToken(a.k.a stToken)
    mapping(address => address) public tokens;

    // for checking token is staked
    mapping(address => bool) public isStToken;

    constructor(address _tokenRecipe, address _tokenPairRecipe) {
        tokenRecipe = ITokenRecipe(_tokenRecipe);
        tokenPairRecipe = ITokenPairRecipe(_tokenPairRecipe);
    }

    function _stake(address token, uint amount) private returns(address stToken, uint staked) {

        if(tokens[token] == address(0)) {
            tokens[token] = address(tokenRecipe.newStakingToken(token));
            isStToken[tokens[token]] = true;
        }

        token._transferFrom(msg.sender, tokens[token], amount);

        staked = IERC20Stakeable(tokens[token]).stake(msg.sender);

        stToken = tokens[token];

    }
    
    function stake(address token, uint amount) external returns(address stToken, uint staked) {
        return _stake(token, amount);
    }

    function _unstake(address token, uint staked) private returns(uint amount) {
        amount = IERC20Stakeable(tokens[token]).unstake(msg.sender, staked);
    }

    function unstake(address token, uint staked) external returns(uint amount) {
        return _unstake(token, staked);
    }

    function maxFlashLoan(address token) external view returns (uint256){

        if(isStToken[token]) {
            return type(uint256).max - IERC20(token).totalSupply();
        }

        require(tokens[token] != address(0), "nigo: unsupported token");
        return IERC20Stakeable(tokens[token]).reserved();
        
    }

    function flashFee(address token, uint256 amount) external view returns (uint256) {

        if(isStToken[token]) {
            return IERC20Stakeable(token).flashFee(amount);
        }

        require(tokens[token] != address(0), "nigo: unsupported token");
        
        return IERC20Stakeable(tokens[token]).flashFee(amount);

    }

    function flashLoan(
        IERC3156FlashBorrower receiver,
        address token,
        uint256 amount,
        bytes calldata data
    ) external returns (bool) {

        if(isStToken[token]) {
            return IERC20Stakeable(token).flashMint(receiver, amount, data);
        }

        require(tokens[token] != address(0), "nigo: unsupported token");
        return IERC20Stakeable(tokens[token]).flashLoan(receiver, amount, data);

    }
    


}