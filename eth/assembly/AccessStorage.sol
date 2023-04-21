// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

contract AccessStorage {
    uint uintValue = 123;
    address addrValue = address(this);
    string strValue = "testStrings";
    uint[5] staticArray = [1,2,3,4,5];
    uint[] dynamicArray = [11,22,33,44,55];
    string strLong = "Test value for long strings greater than 30 characters";
    mapping(address => uint256) public balances;
    mapping(uint256 => mapping(address => uint256)) public idAddrLvl;

    constructor() {
        balances[msg.sender] = 100;
        balances[address(this)] = 200;
        idAddrLvl[10][msg.sender] = 110;
        idAddrLvl[10][address(this)] = 210;
        idAddrLvl[20][msg.sender] = 120;
        idAddrLvl[20][address(this)] = 220;
    }

    function getValues() public view returns (uint uintSlot, uint uintVal, uint addrSlot, address addrVal, uint strSlot, string memory strVal) {
        bytes32 strVal_byte;
        assembly {
            uintSlot := uintValue.slot
            uintVal := sload(uintSlot)
            addrSlot := addrValue.slot
            addrVal := sload(addrSlot)
            strSlot := strValue.slot
            strVal_byte := sload(strSlot) //30바이트 이하의 string일 경우, 1slot(=1word=32bytes)에 
            strVal_byte := and(strVal_byte, not(0xffff)) // value + 0000... + lenght 로  같이 저장
            strVal_byte := or(strVal_byte, and(0x0000,0xffff)) // string으로 사용하기 위해선 뒤의 length byte를 제거 해야함
        }
        strVal = string( abi.encodePacked( strVal_byte ) );
    }

    function getArrays(uint index) public view returns (uint staticSlot, uint staticVal, uint dynamicSlot, uint dynamicLen, bytes32 dynamicValue) {
        assembly {
            staticSlot := staticArray.slot //static array는 길이 만큼 slot을 할당받아 
            staticVal := sload(add(staticSlot, mul(1,index))) //각 slot에 변수 저장
            dynamicSlot := dynamicArray.slot //dynamic array는 
            dynamicLen := sload(dynamicSlot) //slot에 array의 길이를 저장하고
            mstore(0, dynamicSlot)  //인터넷에서 레퍼런스 찾아서 하기는 했는데
            dynamicValue := sload( add( keccak256(0, 32), index ) ) // 왜 되는지는 좀더 분석이 필요함
        }
    }

    function getLongString() public view returns (uint strSlot, uint strLen, string memory strVal ){
        
        bytes32 strVal_byte;
        strVal = "";

        assembly{
            strSlot := strLong.slot
            strLen := sload(strSlot)
            mstore(0, strSlot)  
        }

        uint strWords = strLen/64 + 1;

        for(uint i=0; i < strWords; i++){
            assembly{
                strVal_byte := sload( add( keccak256(0, 32), i ) ) 
            }
            strVal = string( abi.encodePacked( strVal, strVal_byte ) );
        }
    }

    function getBalance(address addr) public view returns (uint mapSlot, uint hash, uint mapVal){
        assembly{
            mapSlot := balances.slot
            mstore (0, addr)
            mstore (32, mapSlot)
            hash := keccak256(0, 64)
            mapVal := sload(hash)
        }
    }

    function getIdAddrLvl(uint id, address addr) public view returns (uint mapSlot, uint mapVal){
        assembly{
            mapSlot := idAddrLvl.slot
            mstore (0, id)
            mstore (32, mapSlot)
            let subMapSlot := keccak256(0, 64)

            mstore (0, addr)
            mstore (32, subMapSlot)
            let hash := keccak256(0, 64)
            mapVal := sload(hash)
        }
    }
}