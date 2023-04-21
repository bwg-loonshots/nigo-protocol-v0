// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

contract StringMload {
    string testValue = "testValue";
    string storageValue = "storaged text";

    /*
    * array는 reference type이기 때문에 
    * assembly에서 변수 그대로 할당할 경우,
    * 참조 memory 주소(pointer)를 반환
    */
    function getReference() public view returns (uint t, uint m) {

        //assembly에서는 local 변수만 사용가능
        string memory test = testValue;
        string memory mem = storageValue;

        //free memory pointer 시작 주소 128(=0x80)를 기준으로 
        //uint[] 경우 1칸에 0x20
        assembly {
            t := test //128(=0x80)
            m := mem //192(=0xC0) == 128 + 64(=0x20 * 2)
        }
    }

    /*
    * mload(pointer) : 주소(pointer)에 위치한 메모리 값을 가져옴
    * string의 경우, 변수 주소 값에 string의 길이를 저장하고 그 다음 word(0x20)에 string 값을 저장한다.
    */
    function getLenAndString() public view returns (uint len, bytes32 value_byte, string memory value) {
        //assembly에서는 local 변수만 사용가능
        string memory test = testValue;
        //bytes32 value_byte;
        assembly {
            len := mload( test )  //string의 길이
            value_byte := mload( add( test, 0x20 ) ) //string의 값
        }   
        value = string( abi.encodePacked( value_byte ) );
    }
    
    
}