// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 < 0.9.0;

import "./ERC20Token.sol";

contract MintableToken is ERC20Token {

    event Mint(address indexed to, uint256 amount);
    event Burn(address indexed from, uint256 amount);
    
    constructor(string memory _name, string memory _symbol) 
    ERC20Token(0, _name, 18, _symbol) {
    }

    function mint(address to, uint256 value) internal{
        totalSupply += value;
        balances[to] = balances[to] + value;
        emit Mint(to, value);
    }

    function burn(address from, uint value) internal {
        balances[from] = balances[from] - value;
        totalSupply -= value;
        emit Burn(address(0), value);
    }

}