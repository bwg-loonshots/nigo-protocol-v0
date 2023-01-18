// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import "./MintableToken.sol";
import "./interfaces/IERC20PairStakeable.sol";
import "./libs/SafeMath.sol";
import "./libs/SafeTransfer.sol";

contract StakingTokenPair is MintableToken, IERC20PairStakeable {
    using SafeMath for uint;
    using SafeTransfer for address;

    address public creator;

    address public tokenA;
    address public tokenB;

    uint private reservedA;
    uint private reservedB;

    uint public k;

    uint public fee = 30; // 1 == 0.01%, 0.3 default

    constructor(address _tokenA, address _tokenB) 
    MintableToken(
        string(abi.encodePacked(IERC20(_tokenA).symbol(), "-", IERC20(_tokenB).symbol()))
        , "NGLP") {
        (tokenA, tokenB) = (_tokenA, _tokenB);
        creator = msg.sender;
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

    function approveFrom(
        address owner, 
        address spender, 
        uint amount)
        external override returns(bool) {

        require(msg.sender == creator, "nigo: forbidden");
        return _approve(owner, spender, amount);
    }

    function stake(address from) external override returns(uint liquidity) {

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

    // TODO if another one transfered st token to contract before unstake?
    function unstake(address from) external override returns(uint amountA, uint amountB) {

        uint liquidity = balances[address(this)];

        amountA = _stakedBalance(tokenA).mul(liquidity) / totalSupply;
        amountB = _stakedBalance(tokenB).mul(liquidity) / totalSupply;

        _burn(address(this), liquidity);

        tokenA._transfer(from, amountA);
        tokenB._transfer(from, amountB);

        sync();

    }

    function swap(
        address tokenIn, 
        address to
        ) external override returns(uint256 amountOut) {

        (address tokenOut, uint256 reservedIn, uint256 reservedOut) = 
            tokenIn == tokenA ? 
            (tokenB, reservedA, reservedB) : (tokenA, reservedB, reservedA);

        uint amountIn = _stakedBalance(tokenIn).sub(reservedIn);

        uint256 amountInWithFee = amountIn.mul(10000 - fee);
        uint256 numerator = amountInWithFee.mul(reservedOut);
        uint256 denominator = reservedIn.mul(10000).add(amountInWithFee);

        amountOut = numerator / denominator;

        tokenOut._transfer(to, amountOut);

        sync();

    }
    
}