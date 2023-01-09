// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import "./ERC20.sol";
import "./libs/SafeMath.sol";

contract MintableERC20 is ERC20 {
    using SafeMath for uint;

    event Mint(address indexed to, uint256 amount);
    event Burn(address indexed from, uint256 amount);
    
    constructor(string memory _name, string memory _symbol) 
    ERC20(0, _name, 18, _symbol) {
    }

    function mint(address _to, uint256 _value) internal{
        totalSupply = totalSupply.add(_value);
        balances[_to] = balances[_to].add(_value);
        emit Mint(_to, _value);
        emit Transfer(address(0), _to, _value);

    }

    function burn(address _from, uint _value) internal {
        balances[_from] = balances[_from].sub(_value);
        totalSupply = totalSupply.sub(_value);
        emit Burn(address(0), _value);
        emit Transfer(_from, address(0), _value);
    }

}