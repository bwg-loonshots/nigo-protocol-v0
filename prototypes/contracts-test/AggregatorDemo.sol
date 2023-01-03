// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 < 0.9.0;

import "../contracts/ERC20Token.sol";
import "../contracts/ERC20TokenPair.sol";
import "../contracts/TokenPairAggregator_prototype.sol";



contract AggregatorDemoPrepare {

    ERC20Token tokenA;
    ERC20Token tokenB;

    ERC20TokenPair pairA;
    ERC20TokenPair pairB;

    ERC20TokenPair loanC;


    function runPrepare(address aggregatorDemo) external {

        tokenA = new ERC20Token(10000 * 10 ** 18, "Test token 01", 18, "T01");
        tokenB = new ERC20Token(10000 * 10 ** 18, "Test token 02", 18, "T02");

        tokenA.transfer(aggregatorDemo, 2 * 10 ** 18);

        pairA = new ERC20TokenPair(address(tokenA), address(tokenB));
        pairB = new ERC20TokenPair(address(tokenA), address(tokenB));
        loanC = new ERC20TokenPair(address(tokenA), address(tokenB));

        addLiquidity(
            10 * 10 ** 18,
            51 * 10 ** 18,
            pairA
        );

        addLiquidity(
            10 * 10 ** 18,
            50 * 10 ** 18,
            pairB
        );

        addLiquidity(
            10 * 10 ** 18,
            50 * 10 ** 18,
            loanC
        );

    }

    function addLiquidity(uint amountA, uint amountB, ERC20TokenPair pair) public {

        tokenA.approve(address(pair), amountA);
        tokenB.approve(address(pair), amountB);
        (uint256 _amountA, uint256 _amountB) = address(tokenA) == pair.tokenA() ?
            (amountA, amountB) : (amountB, amountA);
        pair.addLiquidity(_amountA, _amountB);
    }

    function getAddresses() external view 
    returns(address _tokenA, address _tokenB, address _pairA, address _pairB, address _loanC) {
        _tokenA = address(tokenA);
        _tokenB = address(tokenB);
        _pairA = address(pairA);
        _pairB = address(pairB);
        _loanC = address(loanC);
    }

    
}

contract AggregatorDemo {

    uint public amountOut;
    uint public discounted;

    function runBalancedSwap(address tokenA, address tokenB, address pairA, address pairB, address loanC) external {
        
        TokenPairAggregator aggregator = new TokenPairAggregator(
            tokenA, tokenB,
            pairA, pairB,
            loanC);

        uint256 amountA = 2 * 10 ** 18;

        ERC20Token(tokenA).approve(address(aggregator), amountA);

        (amountOut, discounted) = aggregator.swap(tokenA, amountA, address(this));
        
    }


}