// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 < 0.9.0;

import "./interfaces/IERC20Token.sol";

contract ERC20Token is IERC20Token{
    
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

        require(balances[msg.sender] >= _value);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;

    }

    function transferFrom(
        address _from, 
        address _to, 
        uint256 _value
        ) external override returns (bool success) {

        require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value);
        balances[_to] += _value;
        balances[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
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