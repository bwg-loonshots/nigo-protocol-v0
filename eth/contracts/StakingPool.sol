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

    // staked real token list
    function stakedTokens() external view returns(address[] memory) {
        return tokens;
    }

    // staked pair list
    function stakedPairs() external view returns(address[] memory) {
        return pairs;
    }

    // token balances => staking tokens total supply, reserved token balance
    function mintedByReserved(address token) external view returns(uint minted, uint reserved) {
        minted = IERC20(stakedOf[token]).totalSupply();
        reserved = IERC20Stakeable(stakedOf[token]).reserved();
    }

    // delegate instantiation of staking token to token recipe contract(factory)
    function newStakingToken(address token) private returns(address stToken){
        (bool success, bytes memory data) = tokenRecipe.delegatecall(
            abi.encodeWithSignature("newStakingToken(address)", token)
        );
        require(success, "nigo: staking token creation failed");
        stToken = address(abi.decode(data, (IERC20Stakeable)));
    }

    // delegate instantiation of staking pair to token pair recipe contract(factory)
    function newStakingTokenPair(address tokenA, address tokenB) private returns(address pair){
        (bool success, bytes memory data) = tokenPairRecipe.delegatecall(
            abi.encodeWithSignature("newStakingTokenPair(address,address)", tokenA, tokenB)
        );
        require(success, "nigo: staking token creation failed");
        pair = address(abi.decode(data, (IERC20PairStakeable)));
    }

    // token staking : reserve real token and minting staking token
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

    // token unstaking : burn staking token, withdraw real token for staker
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

    // ** staking token supports flashloan for real token and flashmint for staking token
    // returns available amount for loan or minting
    function maxFlashLoan(address token) external override view returns (uint256){

        if(isStToken[token]) {
            return type(uint256).max - IERC20(token).totalSupply();
        }

        require(stakedOf[token] != address(0), "nigo: unsupported token");
        return IERC20Stakeable(stakedOf[token]).reserved();
        
    }

    // flash fee : amount * fee rate that staking token contract setted fee( 1 = 0.01%, 30 = 0.3%)
    function flashFee(address token, uint256 amount) external override view returns (uint256) {

        if(isStToken[token]) {
            return IERC20Stakeable(token).flashFee(amount);
        }

        require(stakedOf[token] != address(0), "nigo: unsupported token");
        
        return IERC20Stakeable(stakedOf[token]).flashFee(amount);

    }

    // flashloan by ERC3156
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

    // tokens orderd by address hash value (ex : 0x01, 0x02)
    function tokenOrder(address tokenA, address tokenB) private pure returns(address, address) {
        return tokenA < tokenB ? 
            (tokenA, tokenB) : (tokenB, tokenA);
    }

    // add liquidity for AMM protocol. pair token will be dropped to LP(liquidity provider)
    // tokan A * token B = K
    function _addPairLiquidity(
        address from,
        address _tokenA,
        address _tokenB,
        uint _amountA,
        uint _amountB,
        uint _minA,
        uint _minB,
        address to
    ) internal returns(address pair, uint liquidity) {
        
        (
            address tokenA, address tokenB, 
            uint amountA,uint amountB,
            uint minA, uint minB) =
             _tokenA < _tokenB ? 
            (_tokenA, _tokenB, _amountA, _amountB, _minA, _minB) : 
            (_tokenB, _tokenA, _amountB, _amountA, _minB, _minA);

        pair = pairOf[tokenA][tokenB];

        if(pair == address(0)) {
            require(tokenA != tokenB, "nigo: identical addresses");
            pair = newStakingTokenPair(tokenA, tokenB);
            pairOf[tokenA][tokenB] = pair;
            isPair[pair] = true;
            pairs.push(pair);
        }

        (amountA, amountB) = _optimizePairAmounts(amountA, amountB, minA, minB, pair);

        tokenA._transferFrom(from, pair, amountA);
        tokenB._transferFrom(from, pair, amountB);

        liquidity = IERC20PairStakeable(pair).stake(to);

    }

    function _optimizePairAmounts(
        uint _amountA, 
        uint _amountB, 
        uint minA, 
        uint minB, 
        address pair
    ) internal view returns(uint amountA, uint amountB) {

        (uint reservedA, uint reservedB) = IERC20PairStakeable(pair).getReserves();
        
        if(reservedA == 0 && reservedB == 0) {
            amountA = _amountA;
            amountB = _amountB;
        } else {
            amountB = _amountA * reservedB / reservedA;
            if( amountB <= _amountB) {
                require(amountB >= minB, "nigo: insufficient amount b");
                amountA = _amountA;
            } else {
                amountA = reservedA * _amountB / reservedB;
                assert(amountA <= _amountA);
                require(amountA >= minA, "nigo: insufficient amount a");
                amountB = _amountB;
            }
        }        
    }

    // approve pair token from staker to contract, reserved token A, B will be withdrawed for staker 
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

    // swap tokenIn to other side token of pair
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
        uint amountB,
        uint minA,
        uint minB
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
            minA,
            minB,
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