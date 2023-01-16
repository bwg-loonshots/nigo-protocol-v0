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

    // tokan A => token B => tokenPair
    mapping(address => mapping(address => address)) public pairs;

    // for checking token is staked pair
    mapping(address => bool) public isPair;

    constructor(address _tokenRecipe, address _tokenPairRecipe) {
        tokenRecipe = ITokenRecipe(_tokenRecipe);
        tokenPairRecipe = ITokenPairRecipe(_tokenPairRecipe);
    }

    function _stake(
        address from,
        address token, 
        uint amount, 
        address owner
        ) private returns(address) {

        if(tokens[token] == address(0)) {
            tokens[token] = address(tokenRecipe.newStakingToken(token));
            isStToken[tokens[token]] = true;
        }

        token._transferFrom(from, tokens[token], amount);

        IERC20Stakeable(tokens[token]).stake(owner);

        return tokens[token];

    }
    
    function stake(address token, uint amount) external returns(address stToken) {
        return _stake(msg.sender, token, amount, msg.sender);
    }

    function _unstake(
        address from, 
        address token, 
        uint amount,
        address to
        ) private returns(uint unstaked) {

        require(isStToken[token], "not statked token");
        
        token._transferFrom(from, token, amount);
        unstaked = IERC20Stakeable(token).unstake(to);

    }

    function unstake(address token, uint staked) external returns(uint amount) {
        return _unstake(msg.sender, token, staked, msg.sender);
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

    function tokenOrder(address tokenA, address tokenB) private pure returns(address, address) {
        return tokenA < tokenB ? 
            (tokenA, tokenB) : (tokenB, tokenA);
    }

    function _addPairLiquidity(
        address from,
        address _tokenA,
        address _tokenB,
        uint _amountA,
        uint _amountB,
        address to
    ) internal returns(address pair, uint liquidity) {
        
        (address tokenA, address tokenB, uint amountA,uint amountB) =
             _tokenA < _tokenB ? 
            (_tokenA, _tokenB, _amountA, _amountB) : 
            (_tokenB, _tokenA, _amountB, _amountA);

        pair = pairs[tokenA][tokenB];

        if(pair == address(0)) {
            require(tokenA != tokenB, "nigo: identical addresses");
            pair = address(tokenPairRecipe.newStakingTokenPair(tokenA, tokenB));
            pairs[tokenA][tokenB] = pair;
            isPair[pair] = true;
        }

        tokenA._transferFrom(from, pair, amountA);
        tokenB._transferFrom(from, pair, amountB);

        liquidity = IERC20PairStakeable(pair).stake(to);

    }

    function _removePairLiquidity(
        address from,
        address _tokenA,
        address _tokenB,
        uint liquidity,
        address to
    ) internal returns(uint amountA, uint amountB) {

        (address tokenA, address tokenB) = tokenOrder(_tokenA, _tokenB);
        address pair = pairs[tokenA][tokenB];
        require(pair != address(0), "nigo: not supported pair");
        pair._transferFrom(from, pair, liquidity);
        (amountA, amountB) = IERC20PairStakeable(pair).unstake(to);

    }

    function _swap(
        address from,
        address tokenIn,
        address tokenOut,
        uint amountIn,
        address to
    ) internal returns(uint amountOut) {

        (address tokenA, address tokenB) = tokenOrder(tokenIn, tokenOut);
        address pair = pairs[tokenA][tokenB];
        require(pair != address(0), "nigo: not supported pair"); 

        tokenA._transferFrom(from, pair, amountIn); 
        amountOut = IERC20PairStakeable(pair).swap(tokenIn, to);

    }

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountA,
        uint amountB
    ) external returns(address pair, uint liquidity) {
        return _addPairLiquidity(
            msg.sender,
            tokenA, 
            tokenB, 
            amountA, 
            amountB, 
            msg.sender);
    }

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity
    ) external returns(uint amountA, uint amountB) {
        return _removePairLiquidity(
            msg.sender, 
            tokenA, 
            tokenB, 
            liquidity, 
            msg.sender);
    }

    function swap(
        address tokenIn,
        address tokenOut,
        uint amountIn
    ) external returns(uint amountOut) {
        return _swap(
            msg.sender, 
            tokenIn, 
            tokenOut, 
            amountIn, 
            msg.sender);
    }

}