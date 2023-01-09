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

    function transfer(address _to, uint256 _value) external override returns(bool success) {

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;

    }

    function transferFrom(
        address _from, 
        address _to, 
        uint256 _value
        ) external override returns (bool success) {

        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        balances[_from] = balances[_from].sub(_value);
        emit Transfer(_from, _to, _value);
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