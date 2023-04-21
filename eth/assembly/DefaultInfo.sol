// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import "./ListenerFunction.sol";

contract DefaultInfo {
    ListenerFunction Listener = new ListenerFunction();
    
    //assembly내에서 gas잔여량 확인
    function getGas() public view returns (uint limit, uint gasInfo1, uint gasInfo2) {
        assembly{
            limit := gaslimit()
            gasInfo1 := gas() //gas limit - used gas
            gasInfo2 := gas() //gas를 확인하는 함수도 gas 사용함
        }
    }

    //주소의 eth보유량 wei 단위로 확인
    function getBalance(address user)public view returns(uint output){
        assembly{
            output := balance(user)
        }
    }

    //assembly내에서 현재 contract 주소 확인
    function getAddress() public view returns(address output, bool same){
        assembly{
            output := address() //address(this)
        }
        same = address(this) == output;
    }

    //assembly내에서 contract 호출자 확인
    function getCaller() public view returns (address sender, bool same) {
        assembly { 
            sender := caller() //msg.sender
        }
        same = msg.sender == sender;
    }

    //assembly내에서 eth 량 확인
    function getCallValue() public payable returns (uint amount, bool same) {
        assembly { 
            amount := callvalue() //msg.value
        }
        same = msg.value == amount;
    }

    //origin의 경우 caller와 달리 internal transaction이 호출되어도 바뀌지 않음
    function getOrigin() public view returns (address sender, address subSender) {
        address listener = address(Listener);
        bytes4 callSig = bytes4(keccak256("getOrigin()"));

        assembly { 
            sender := origin() 

            let callMemory := mload(0x40) 
            mstore(callMemory,callSig)

            //StaticCall
            let success := staticcall(gas(), listener, callMemory, 0x4, callMemory, 0x20)
            subSender := mload(callMemory)
        }
    }

    //현재 블럭의 높이, 이전 블럭의 hash(-256), 에포크 이후 현재 블록의 타임스탬프(초) 확인
    function getBlock() public view returns (uint height, bytes32 before, uint time){
        assembly {
            height := number()
            before := blockhash( sub(height, 1) ) //현재 블럭은 안됨
            time := timestamp()
        }
    }

}