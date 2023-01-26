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
    address tokenRecipe;
    address tokenPairRecipe;

    // real token => stToken(a.k.a stToken)
    mapping(address => address) public stakedOf;

    address[] public tokens;

    // for checking token is staked
    mapping(address => bool) public isStToken;

    // tokan A => token B => tokenPair
    mapping(address => mapping(address => address)) public pairOf;

    address[] public pairs;

    // for checking token is staked pair
    mapping(address => bool) public isPair;

    constructor(address _tokenRecipe, address _tokenPairRecipe) {
        tokenRecipe = _tokenRecipe;
        tokenPairRecipe = _tokenPairRecipe;
    }

    function stakedTokens() external view returns(address[] memory) {
        return tokens;
    }

    function stakedPairs() external view returns(address[] memory) {
        return pairs;
    }

    function newStakingToken(address token) private returns(address stToken){
        (bool success, bytes memory data) = tokenRecipe.delegatecall(
            abi.encodeWithSignature("newStakingToken(address)", token)
        );
        require(success, "nigo: staking token creation failed");
        stToken = address(abi.decode(data, (IERC20Stakeable)));
    }

    function newStakingTokenPair(address tokenA, address tokenB) private returns(address pair){
        (bool success, bytes memory data) = tokenPairRecipe.delegatecall(
            abi.encodeWithSignature("newStakingTokenPair(address,address)", tokenA, tokenB)
        );
        require(success, "nigo: staking token creation failed");
        pair = address(abi.decode(data, (IERC20PairStakeable)));
    }

    function _stake(
        address from,
        address token, 
        uint amount, 
        address owner
        ) private returns(address) {

        if(stakedOf[token] == address(0)) {
            stakedOf[token] = newStakingToken(token);
            isStToken[stakedOf[token]] = true;
            tokens.push(token);
        }

        token._transferFrom(from, stakedOf[token], amount);

        IERC20Stakeable(stakedOf[token]).stake(owner);

        return stakedOf[token];

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
        
        IERC20Stakeable(token).approveFrom(from, address(this), amount);
        token._transferFrom(from, token, amount);
        unstaked = IERC20Stakeable(token).unstake(to);

    }

    function unstake(address token, uint staked) external returns(uint amount) {
        return _unstake(msg.sender, token, staked, msg.sender);
    }

    function maxFlashLoan(address token) external override view returns (uint256){

        if(isStToken[token]) {
            return type(uint256).max - IERC20(token).totalSupply();
        }

        require(stakedOf[token] != address(0), "nigo: unsupported token");
        return IERC20Stakeable(stakedOf[token]).reserved();
        
    }

    function flashFee(address token, uint256 amount) external override view returns (uint256) {

        if(isStToken[token]) {
            return IERC20Stakeable(token).flashFee(amount);
        }

        require(stakedOf[token] != address(0), "nigo: unsupported token");
        
        return IERC20Stakeable(stakedOf[token]).flashFee(amount);

    }

    function flashLoan(
        IERC3156FlashBorrower receiver,
        address token,
        uint256 amount,
        bytes calldata data
    ) external override returns (bool) {

        if(isStToken[token]) {
            return IERC20Stakeable(token).flashMint(receiver, amount, data);
        }

        require(stakedOf[token] != address(0), "nigo: unsupported token");
        return IERC20Stakeable(stakedOf[token]).flashLoan(receiver, amount, data);

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

        pair = pairOf[tokenA][tokenB];

        if(pair == address(0)) {
            require(tokenA != tokenB, "nigo: identical addresses");
            pair = newStakingTokenPair(tokenA, tokenB);
            pairOf[tokenA][tokenB] = pair;
            isPair[pair] = true;
            pairs.push(pair);
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
        address pair = pairOf[tokenA][tokenB];
        require(pair != address(0), "nigo: not supported pair");
        IERC20PairStakeable(pair).approveFrom(from, address(this), liquidity);
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
        address pair = pairOf[tokenA][tokenB];
        require(pair != address(0), "nigo: not supported pair"); 

        tokenIn._transferFrom(from, pair, amountIn); 
        amountOut = IERC20PairStakeable(pair).swap(tokenIn, to);

    }

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountA,
        uint amountB
    ) external returns(address pair, uint liquidity) {

        if(isStToken[tokenA]) {
            IERC20Stakeable(tokenA).approveFrom(msg.sender, address(this), amountA);
        }

        if(isStToken[tokenB]) {
            IERC20Stakeable(tokenB).approveFrom(msg.sender, address(this), amountB);
        }

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

        if(isStToken[tokenIn]) {
            IERC20Stakeable(tokenIn).approveFrom(msg.sender, address(this), amountIn);
        }

        return _swap(
            msg.sender, 
            tokenIn, 
            tokenOut, 
            amountIn, 
            msg.sender);
    }

}