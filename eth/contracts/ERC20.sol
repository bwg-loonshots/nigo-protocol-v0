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

    function transfer(address to, uint256 value) external override returns(bool success) {
        
        balances[msg.sender] = balances[msg.sender].sub(value);
        balances[to] = balances[to].add(value);
        emit Transfer(msg.sender, to, value);
        return true;

    }

    function transferFrom(
        address from, 
        address to, 
        uint256 value
        ) external override returns (bool success) {

        allowed[from][msg.sender] = allowed[from][msg.sender].sub(value);
        balances[to] = balances[to].add(value);
        balances[from] = balances[from].sub(value);
        emit Transfer(from, to, value);
        return true;

    }

    function balanceOf(address _owner) external override view returns(uint balance) {

        return balances[_owner];

    }

    function approve(address _spender, uint _value) external override returns(bool success) {

        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;

    }

    function allowance(address _owner, address _spender) external override view returns(uint256 remaining) {

        return allowed[_owner][_spender];

    }

}