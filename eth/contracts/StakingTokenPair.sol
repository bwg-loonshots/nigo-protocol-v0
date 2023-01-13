// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import "./MintableToken.sol";
import "./libs/SafeMath.sol";
import "./libs/SafeTransfer.sol";

contract StakingTokenPair is MintableToken{
    using SafeMath for uint;
    using SafeTransfer for address;

    address public tokenA;
    address public tokenB;

    uint private reservedA;
    uint private reservedB;

    uint public k;

    uint public fee = 30; // 1 == 0.01%, 0.3 default

    constructor(address _tokenA, address _tokenB) 
    MintableToken(
        string(abi.encodePacked(IERC20(tokenA).symbol(), "-", IERC20(tokenB).symbol()))
        , "NGLP") {
        (tokenA, tokenB) = _tokenA < _tokenB ? (_tokenA, _tokenB) : (_tokenB, _tokenA);
    }

    function getReserves() public view returns(uint256, uint256) {
        return (reservedA, reservedB);
    }

    function _stakedBalance(address token) private view returns(uint) {
        return IERC20(token).balanceOf(address(this));
    }

    function _stakedBalances() private view returns(uint, uint) {
        return (_stakedBalance(tokenA), _stakedBalance(tokenB));
    }

    function sync() private {
        (reservedA, reservedB) = _stakedBalances();
        k = reservedA * reservedB;
    }

    function stake(address from) external returns(uint liquidity) {

        uint amountA = _stakedBalance(tokenA).sub(reservedA);
        uint amountB = _stakedBalance(tokenB).sub(reservedB);

        if(totalSupply == 0) {
            liquidity = amountA.mul(amountB).sqrt();
        } else {
            liquidity = amountA.mul(totalSupply) / reservedA;
        }

        _mint(from, liquidity);

        sync();

    }

    function unstake(address from, uint256 liquidity) external {

        uint256 amountA = _stakedBalance(tokenA).mul(liquidity) / totalSupply;
        uint256 amountB = _stakedBalance(tokenB).mul(liquidity) / totalSupply;

        _burn(from, liquidity);

        tokenA._transfer(msg.sender, amountA);
        tokenB._transfer(msg.sender, amountB);

        sync();

    }

    function swap(
        address tokenIn, 
        address to
        ) external returns(
            uint256 amountIn,
            uint256 amountOut) {

        (address tokenOut, uint256 reservedIn, uint256 reservedOut) = 
            tokenIn == tokenA ? 
            (tokenB, reservedA, reservedB) : (tokenA, reservedB, reservedA);

        amountIn = _stakedBalance(tokenIn).sub(reservedIn);

        uint256 amountInWithFee = amountIn.mul(10000).sub(fee);
        uint256 numerator = amountInWithFee.mul(reservedOut);
        uint256 denominator = reservedIn.mul(10000).add(amountInWithFee);
        amountOut = numerator / denominator;

        tokenOut._transfer(to, amountOut);

        sync();

    }
    
}