// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

contract UintArrayMload {
    uint[5] staticArr = [1,3,5,7,9];
    uint[] dynamicArr = [2,4,6,8];

    /*
    * array는 reference type이기 때문에 
    * assembly에서 변수 그대로 할당할 경우,
    * 참조 memory 주소(pointer)를 반환
    */
    function getReference() public view returns (uint s, uint d) {

        //assembly에서는 local 변수만 사용가능
        uint[5] memory arrS = staticArr;
        uint[] memory arrD = dynamicArr;

        //free memory pointer 시작 주소 128(=0x80)를 기준으로 
        //uint[] 경우 1칸에 0x20
        assembly {
            s := arrS //128(=0x80)
            d := arrD //288(=0x120) == 128 + 160(=0x20 * 5)
        }
    }

    /*
    * mload(pointer) : 주소(pointer)에 위치한 메모리 값을 가져옴
    * array의 경우, 변수 주소 값에서 + index * 1칸 주소값을 통해 element의 주소
    */

    function getStaticElementByIndex(uint index) public view returns (uint r) {
        //assembly에서는 local 변수만 사용가능
        uint[5] memory arr = staticArr;

        assembly {
            //1칸이 0x20이므로 주소 시작위치에서 index횟수 만큼 0x20을 더한 주소값을 출력
            // 정적 배열은 0번 인덱스부터 element 저장
            r := mload( add( arr, mul( 0x20, index ) ) ) //mload(arr + (0x20 * index) )
        }
    }

    
    function getDynamicElementByIndex(uint index) public view returns (uint r) {

        //assembly에서는 local 변수만 사용가능
        uint[] memory arr = dynamicArr;

        assembly {
            //1칸이 0x20이므로 주소 시작위치에서 index횟수 만큼 0x20을 더한 주소값을 출력
            // 동적 배열은 1번 pointer부터 element 저장(0번에는 배열 길이를 저장)
            r := mload( add( arr, mul( 0x20, add(index,1) ) ) ) //mload(arr + (0x20 * (index+1) ) )
        }
    }

    function getElementByPointer(uint pointer) public view returns (uint r) {

        //assembly에서는 local 변수만 사용가능
        uint[5] memory arrS = staticArr;
        uint[] memory arrD = dynamicArr;

        assembly {
            //변수로 포인터 값을 직접입력 받아서 반환
            r := mload( pointer )
            //0x80,0xA0,0xC0...0x1A0
        }
    }

    /*
    * dynamic array의 pointer memory를 변수에 담아 return할 경우,
    * dynamic array pointer의 첫번째 값인 array의 길이를 반환
    */
    function getDynamicLength() public view returns (uint r) {
        //assembly에서는 local 변수만 사용가능
        uint[] memory arr = dynamicArr;

        assembly {
            r := mload(arr)
        }
    }
    
    
}