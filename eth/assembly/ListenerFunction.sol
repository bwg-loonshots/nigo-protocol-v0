// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

contract ListenerFunction {
    uint a = 110;
    uint b = 120;

    function callA(bool action) public view returns (uint) {
        if(action){
            return a+b;
        }else{
            return a;
        }
    }

    function getCaller() public view returns (address sender, bool same) {
        assembly {
            sender := caller()
        }
        same = msg.sender == sender;
    }

    function getOrigin() public view returns (address sender, bool same) {
        assembly { 
            sender := origin() //msg.sender
        }
        same = msg.sender == sender;
    }
}