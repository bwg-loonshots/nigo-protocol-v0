// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import "../../nft721/ERC721.sol";
import "./NFTHolder.sol";

contract ERC721_test {

    ERC721 collection = new ERC721("nigoNFT","nigoNFT","http://localhost:8080/nft/metadata/");

    function test() external{

        testMint();

        testTransferByOwner();

        testTransferByApproved();

        testOperator();

        testBurn();
    }

    function testMint() internal{

        collection.mint(msg.sender);
        uint256 firstTokenId = 0;

        assert(collection.balanceOf(msg.sender) == 1);
        assert(collection.ownerOf(firstTokenId) == msg.sender);
    }

    function testTransferByOwner() internal{

        NFTHolder Alice = new NFTHolder();
        NFTHolder Bob = new NFTHolder();

        collection.mint(address(Alice));
        uint256 secondTokenId = 1;

        assert(collection.balanceOf(address(Alice)) == 1);
        assert(collection.ownerOf(secondTokenId) == address(Alice));

        Alice.transferTo(address(collection),address(Bob),secondTokenId);

        assert(collection.balanceOf(address(Alice)) == 0);
        assert(collection.balanceOf(address(Bob)) == 1);
        assert(collection.ownerOf(secondTokenId) == address(Bob));
    }

    function testTransferByApproved() internal{
        
        NFTHolder Alice = new NFTHolder();
        NFTHolder Bob = new NFTHolder();

        collection.mint(address(Alice));
        uint256 thirdTokenId = 2;

        assert(collection.balanceOf(address(Alice)) == 1);
        assert(collection.balanceOf(address(Bob)) == 0);
        assert(collection.ownerOf(thirdTokenId) == address(Alice));

        Alice.approveTo(address(collection),address(Bob),thirdTokenId);

        assert(collection.getApproved(thirdTokenId) == address(Bob));

        Bob.transferFrom(address(collection),address(Alice),thirdTokenId);

        assert(collection.balanceOf(address(Alice)) == 0);
        assert(collection.balanceOf(address(Bob)) == 1);
        assert(collection.ownerOf(thirdTokenId) == address(Bob));
    }

    function testOperator() internal{

        NFTHolder Alice = new NFTHolder();
        NFTHolder Bob = new NFTHolder();

        collection.mint(address(Alice));
        uint256 fourthTokenId = 3;

        assert(collection.balanceOf(address(Alice)) == 1);
        assert(collection.balanceOf(address(Bob)) == 0);
        assert(collection.ownerOf(fourthTokenId) == address(Alice));

        Alice.operatorTo(address(collection),address(Bob),true);
        
        assert(collection.isApprovedForAll(address(Alice),address(Bob)) == true);

        Bob.transferFrom(address(collection),address(Alice),fourthTokenId);

        assert(collection.balanceOf(address(Alice)) == 0);
        assert(collection.balanceOf(address(Bob)) == 1);
        assert(collection.ownerOf(fourthTokenId) == address(Bob));
    }

    function testBurn() internal{

        NFTHolder Alice = new NFTHolder();

        collection.mint(address(Alice));
        uint256 fifththTokenId = 4;

        assert(collection.balanceOf(address(Alice)) == 1); 

        Alice.operatorTo(address(collection),address(this),true);
        collection.burn(fifththTokenId);

        assert(collection.balanceOf(address(Alice)) == 0);   
    }
}