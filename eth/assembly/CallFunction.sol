// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import "./ListenerFunction.sol";

contract CallFunction {
    uint a = 10;
    uint b = 20;

    ListenerFunction Listener = new ListenerFunction();
 
    //delegatecall test를 위한 함수
    function callA(bool action) public view returns (uint) {
        if(action){
            return a;
        }else{
            return a+b;
        }
    }

    //assembly내에서 contract 호출자 확인
    function getCaller() public view returns (address sender, bool same) {
        assembly { 
            sender := caller() //msg.sender
        }
        same = msg.sender == sender;
    }

    //Opcode CAll
    function execExFuncByCall() public returns (uint output){    
        address listener = address(Listener);
        
        bytes4 callSig = bytes4(keccak256("callA(bool)")); //함수 시그니처

        assembly{
            let callMemory := mload(0x40)  //msg.data로 사용할 데이터를 저장할 주소를 변수로 설정
            mstore(callMemory,callSig)  //해당 주소에 함수 시그니처 저장
            mstore(add(callMemory,0x04),true)  //함수 시그니처 뒤에 parameter 저장

            let success := call(
                gas(), //1. gas limit
                listener, //2. address
                0, //3. msg.value
                callMemory, //4. msg.data로 사용할 memory 주소
                0x24, //5. msg.data의 길이
                callMemory, //6. return 값을 받아올 memory 주소 (msg.data용 주소 더이상 필요하지 않음)
                0x20 //7. output의 길이
            )
            output := mload(callMemory) //output : 230
        }
    }

    //call, callcode, delegatecall 비교
    function compareExFunc() public returns (uint callOut, address callAddr, uint codeOut, address codeAddr, uint deleOut, address deleAddr){
        address listener = address(Listener);
        bytes4 callSig = bytes4(keccak256("callA(bool)"));
        bytes4 getSig = bytes4(keccak256("getCaller()"));

        assembly{
            let callMemory := mload(0x40) 
            mstore(callMemory,callSig)
            mstore(add(callMemory,0x04),true)
            
            let getMemory := mload(0x100)
            mstore(getMemory,getSig)

            //Call
            let success := call(gas(), listener, 0, callMemory, 0x24, 0x200, 0x20)
            callOut := mload(0x200) //230
            success := call(gas(), listener, 0, getMemory, 0x4, 0x240, 0x40)
            callAddr := mload(0x240) //contract address

            //CallCode
            success := callcode(gas(), listener, 0, callMemory, 0x24, 0x300, 0x20)
            codeOut := mload(0x300) // 30
            success := callcode(gas(), listener, 0, getMemory, 0x4, 0x340, 0x40)
            codeAddr := mload(0x340) //contract address

            //DelecateCall
            success := delegatecall(gas(), listener, callMemory, 0x24, 0x400, 0x20)
            deleOut := mload(0x400) // 30
            success := delegatecall(gas(), listener, getMemory, 0x4, 0x440, 0x40)
            deleAddr := mload(0x440) //wallet address
        }
    }

    //non tx fee로 contract 외부 함수의 view 함수 call 가능
    function getExViewFunc() public view returns (uint statOut){
        address listener = address(Listener);
        bytes4 callSig = bytes4(keccak256("callA(bool)"));

        assembly{
            let callMemory := mload(0x40) 
            mstore(callMemory,callSig)
            mstore(add(callMemory,0x04),true)

            //StaticCall
            let success := staticcall(gas(), listener, callMemory, 0x24, callMemory, 0x20)
            statOut := mload(callMemory) // 230
        }
    }
}