// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import "./interfaces/IERC20.sol";
import "./libs/SafeMath.sol";


contract ERC20 is IERC20{
    using SafeMath for uint;
    
    mapping (address => uint256) public balances;
    mapping (address => mapping(address => uint256)) public allowed;

    string public override name;
    uint8 public override decimals;
    string public override symbol;

    uint256 public override totalSupply;

    constructor(
        uint256 _totalSupply,
        string memory _name,
        uint8 _decimal,
        string memory _symbol
    ) {

        balances[msg.sender] = _totalSupply;
        totalSupply = _totalSupply;
        name = _name;
        decimals = _decimal;
        symbol = _symbol;

    }

    function _transferFrom(
        address from,
        address to,
        uint256 value
    ) internal returns(bool success) {
        balances[from] = balances[from].sub(value);
        balances[to] = balances[to].add(value);
        emit Transfer(from, to, value);
        return true;
    }

    function transfer(address to, uint256 value) external override returns(bool) {
        
        return _transferFrom(msg.sender, to, value);

    }

    function transferFrom(
        address from, 
        address to, 
        uint256 value
        ) external override returns (bool) {

        allowed[from][msg.sender] = allowed[from][msg.sender].sub(value);
        return _transferFrom(from, to, value);
    }

    function balanceOf(address _owner) external override view returns(uint) {

        return balances[_owner];

    }

    function _approve(
        address owner,
        address _spender,
        uint _value
    ) internal returns(bool) {
        allowed[owner][_spender] = _value;
        emit Approval(owner, _spender, _value); 
        return true;     
    }

    function approve(address _spender, uint _value) external override returns(bool) {

        return _approve(msg.sender, _spender, _value);   
    }

    function allowance(address _owner, address _spender) external override view returns(uint256) {

        return allowed[_owner][_spender];

    }

}