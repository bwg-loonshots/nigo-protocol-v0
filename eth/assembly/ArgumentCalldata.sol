// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

contract ArgumentCalldataload {
    /*
    * calldataload(p)는 msg.data를 지정한 위치에서부터 1word씩 읽어오는 기능
    * 1 word = 32 bytes = hash 64자리 = hex 0x20
    *
    * msg.data의 구조 = call function hash + arguments
    * msg.data의 첫 4bytes(8자리)는 function hash이므로 
    * calldataload로 argument를 읽어올 시, 0x4를 더 고려해야함
    *
    * argument는 선언 순서대로 1 word씩 기본 공간을 할당하고 
    * 그 뒤로 reference type을 위한 추가 공간 사용
    */

    /*
    * bool의 경우, primitive type으로 각 인수에 할당된 1 word의 기본 공간에 true일 경우 1, false일 경우 0 값 저장
    */
    function catchBoolArgs(bool,bool) external view returns (bytes memory r0, bool r1, bool r2){
        r0 = msg.data;
        assembly{
            r1 := calldataload(0x4) 
            r2 := calldataload( add(0x4,0x20) )
        }
    }

    /*
    * uint의 경우, primitive type으로 각 인수에 할당된 1 word의 기본 공간에 값 저장
    */
    function catchUintArgs(uint, uint, uint) external view returns (bytes memory r0, uint r1, uint r2, uint r3){
        r0 = msg.data;
        assembly{
            r1 := calldataload(0x4) 
            r2 := calldataload( add(0x4,0x20) )
            r3 := calldataload( add(0x4,0x40) )
        }
    }

    /*
    * address 경우, primitive type으로 각 인수에 할당된 1 word의 기본 공간에 값 저장
    */
    function catchAddressArgs(address) external view returns (bytes memory r0, address r1){
        r0 = msg.data;
        assembly{
            r1 := calldataload(0x4)
        }
    }

    /*
    * string의 경우, reference type으로 각 인수에 할당된 1 word의 기본 공간에 순서대로 할당된 추가 공간의 주소 저장
    * 추가공간은 2 word로 이루어져 있으며 
    * 앞쪽 word은 string의 길이를 나타내고 
    * 뒤쪽 word은 실제 string값(UTF-8)을 bytes hex로 나타냄
    */
    function catchStringArgs(string memory, uint, string memory) external view returns (bytes memory r0, string memory r1_str, uint r2, string memory r3_str ){
        r0 = msg.data;
        bytes32 r1_byte;
        bytes32 r3_byte;
        assembly{
            let r1 := calldataload(0x4)
            r2 := calldataload( add(0x4,0x20) )
            let r3 := calldataload( add(0x4,0x40) )
            r1_byte := calldataload( add(r1,0x20) )
            r3_byte := calldataload( add(r3,0x20) )
        }
        r1_str = string( abi.encodePacked( r1_byte ) );
        r3_str = string( abi.encodePacked( r3_byte ) );
    }

    /*
    * array의 경우, reference type으로 각 인수에 할당된 1 word의 기본 공간에 순서대로 할당된 추가 공간의 주소 저장
    * 추가공간은 (1 + array의 길이) word로 이루어져 있으며 
    * 첫번째 word은 array의 길이를 나타내고, 이후 word은 각 elements를 1 word씩 나타냄
    */
    function catchArrayArgs(uint[] memory) external view returns (bytes memory r0, uint len, uint sum){
        r0 = msg.data;
        assembly{
            let root := add(0x4,calldataload(0x4))
            len := calldataload(root)
            for {let i := 1} lt(i, add(len,1)) {i := add(i, 1)} {
                sum := add( sum, calldataload( add(root, mul(0x20, i) ) ) )
            }
        }
    }

    /*
    * 2D array의 경우, reference type으로 각 인수에 할당된 1 word의 기본 공간에 순서대로 할당된 추가 공간의 주소 저장
    * 추가공간은 (1 + array의 길이) word로 이루어져 있으며 
    * 첫번째 word은 array의 길이를 나타내고, 이후 word은 각 sub array에 할당된 추가 공간 주소를 1 word씩 나타냄
    */
    function catch2DArrayArgs(uint[][] memory) external view returns (bytes memory r0, uint len, uint sum){
        r0 = msg.data;
        assembly{
            let root := add(0x4,calldataload(0x4))
            len := calldataload(root)
            for {let i := 1} lt(i, add(len,1)) {i := add(i, 1)} {
                sum := add( sum, calldataload( add(root, mul(0x20, i) ) ) )
            }
        }
    }
}