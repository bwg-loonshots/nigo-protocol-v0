// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import "../../erc1155/interfaces/IERC1155.sol";
import "../../erc1155/interfaces/IERC1155Receiver.sol";

contract ERC1155Holder is IERC1155Receiver {
    //단건송신
    function transferTo(address collection, address to, uint256 id, uint256 amount) public{
        IERC1155(collection).safeTransferFrom(address(this),to,id,amount,"data");
    }

    //다건송신
    function transferToBatch(address collection, address to, uint256[] memory ids, uint256[] memory amounts) public{
        IERC1155(collection).safeBatchTransferFrom(address(this),to,ids,amounts,"data");
    }

    function approveTo(address collection, address operator) public{
        IERC1155(collection).setApprovalForAll(operator, true);
    }

    //단건수신 approved로 실행
    function transferFrom(address collection, address from, uint256 id, uint256 amount) public{
        IERC1155(collection).safeTransferFrom(from,address(this),id,amount,"data");
    }

    //다건수신 approved로 실행
    function transferFromBatch(address collection, address from, uint256[] memory ids, uint256[] memory amounts) public{
        IERC1155(collection).safeBatchTransferFrom(from,address(this),ids,amounts,"data");
    }

    function onERC1155Received(address, address, uint256, uint256, bytes memory) external pure override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(address, address, uint256[] memory, uint256[] memory, bytes memory) external pure override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
}