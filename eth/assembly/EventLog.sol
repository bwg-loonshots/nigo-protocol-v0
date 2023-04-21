// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

contract EventLog {
    event TestEvent1(uint value);
    event TestEvent2(uint value1, uint value2, address indexed from);
    event TestEvent3(uint indexed value1, uint value2, address indexed from);

    function assemblyEvent() public {
        bytes32 eventHash1 = keccak256("TestEvent1(uint256)");
        bytes32 eventHash2 = keccak256("TestEvent2(uint256,uint256,address)");
        bytes32 eventHash3 = keccak256("TestEvent3(uint256,uint256,address)");

        assembly {
            mstore(0x40,123)

            mstore(0x80,456)
            mstore(0xA0,789)

            log1(0x40,0x20,eventHash1)
            log2(0x80,0x40,eventHash2,address())
            log3(0x40,0x20,eventHash3,285,address())
        }
    }
}