// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import "../../nft721/interfaces/IERC721.sol";
import "../../nft721/interfaces/IERC721Receiver.sol";

contract NFTHolder is IERC721Receiver {

    function transferTo(address collection, address to, uint256 tokenId) external{
        IERC721(collection).safeTransferFrom(address(this),to,tokenId);
    }

    function transferFrom(address collection, address from, uint256 tokenId) external{
        IERC721(collection).safeTransferFrom(from,address(this),tokenId);
    }

    function approveTo(address collection, address to, uint256 tokenId) external {
        IERC721(collection).approve(to, tokenId);
    }

    function operatorTo(address collection, address to, bool approved) external{
        IERC721(collection).setApprovalForAll(to,approved);
    }

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external view override returns (bytes4){
        return IERC721Receiver.onERC721Received.selector;
    }
}