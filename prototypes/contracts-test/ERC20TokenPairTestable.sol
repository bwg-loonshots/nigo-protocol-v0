// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 < 0.9.0;

import "../contracts/ERC20Token.sol";
import "../contracts/ERC20TokenPair.sol";



contract ERC20TokenPairTestable {

    ERC20TokenPair public pair;
    ERC20Token public tokenA;
    ERC20Token public tokenB;

    function createTokenAndPair() public {

        pair = new ERC20TokenPair(
            address(new ERC20Token(10000 * 10 ** 18, "Test token 01", 18, "T01")), 
            address(new ERC20Token(10000 * 10 ** 18, "Test token 02", 18, "T02")));

        tokenA = ERC20Token(pair.tokenA());
        tokenB = ERC20Token(pair.tokenB());

    }

    function addLiquidity(uint amountA, uint amountB) public {
        tokenA.approve(address(pair), amountA);
        tokenB.approve(address(pair), amountB);

        pair.addLiquidity(amountA, amountB);
    }

    function swapAtoB(uint amount) public {
        tokenA.approve(address(pair), amount);
        pair.swap(address(tokenA), amount, address(this));
    }

    function loanA(uint amount) public {
        pair.loan(address(tokenA), amount, address(this));
    }

    

    function removeLiquidity(uint liquidity) public {
        pair.removeLiquidity(liquidity);
    }


    function k() public view returns(uint256) {
        return pair.k();
    }

    function ownedLiquidity() public view returns(uint256) {
        return pair.balanceOf(address(this));
    }

    function totlaLiquidity() public view returns(uint256) {
        return pair.totalSupply();
    }

    function getReserves() public view returns(uint256, uint256) {
        return pair.getReserves();
    }


}