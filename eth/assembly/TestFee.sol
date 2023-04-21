// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import "../contracts/libs/SafeMath.sol";

contract TestFee {
    using SafeMath for uint;

    mapping(address => uint256) public balances;

    constructor() {
        balances[msg.sender] = 1000;
        balances[address(this)] = 1000;
    }

    function arithmeticTest() public view returns (uint first, uint secon, uint third){
        uint a = 24;
        uint b = 6;
        uint slot;

        assembly{
            first := gas()
        }
        slot = a + b;
        slot = a - b;
        slot = a * b;
        slot = a / b;
        
        assembly{
            secon := gas()
        }

        assembly {
            slot := add(a, b)
            slot := sub(a, b)
            slot := mul(a, b)
            slot := div(a, b)
        }

        assembly{
            third := gas()
        }
    }
    
    function transferTest(address from, address to, uint value) public returns (uint first, uint secon, uint third){
        
        assembly{
            first := gas()
        }

        balances[from] = balances[from] - value;
        balances[to] = balances[to] + value;

        assembly{
            secon := gas()
        }

        assembly{
            mstore (32, balances.slot)

            mstore (0, to)
            let hash := keccak256(0, 64)
            let toVal := sload(hash)
            sstore(hash, sub(toVal,value))

            mstore (0, from)
            hash := keccak256(0, 64)
            let fromVal := sload(hash)
            sstore(hash, add(fromVal,value))
        }

        assembly{
            third := gas()
        }

    }

}