// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import "../../nft721/ERC721.sol";
import "./NFTHolder.sol";

contract ERC721_test {

    ERC721 collaction = new ERC721("nigoNFT","nigoNFT","http://localhost:8080/nft/metadata/");

    function test() external{

        testMint();

        testTransferByOwner();

        testTransferByApproved();

        testOperator();

        testBurn();
    }

    function testMint() internal{

        collaction.mint(msg.sender);
        uint256 firstTokenId = 0;

        assert(collaction.balanceOf(msg.sender) == 1);
        assert(collaction.ownerOf(firstTokenId) == msg.sender);
    }

    function testTransferByOwner() internal{

        NFTHolder Alice = new NFTHolder();
        NFTHolder Bob = new NFTHolder();

        collaction.mint(address(Alice));
        uint256 secondTokenId = 1;

        assert(collaction.balanceOf(address(Alice)) == 1);
        assert(collaction.ownerOf(secondTokenId) == address(Alice));

        Alice.transferTo(address(collaction),address(Bob),secondTokenId);

        assert(collaction.balanceOf(address(Alice)) == 0);
        assert(collaction.balanceOf(address(Bob)) == 1);
        assert(collaction.ownerOf(secondTokenId) == address(Bob));
    }

    function testTransferByApproved() internal{
        
        NFTHolder Alice = new NFTHolder();
        NFTHolder Bob = new NFTHolder();

        collaction.mint(address(Alice));
        uint256 thirdTokenId = 2;

        assert(collaction.balanceOf(address(Alice)) == 1);
        assert(collaction.balanceOf(address(Bob)) == 0);
        assert(collaction.ownerOf(thirdTokenId) == address(Alice));

        Alice.approveTo(address(collaction),address(Bob),thirdTokenId);

        assert(collaction.getApproved(thirdTokenId) == address(Bob));

        Bob.transferFrom(address(collaction),address(Alice),thirdTokenId);

        assert(collaction.balanceOf(address(Alice)) == 0);
        assert(collaction.balanceOf(address(Bob)) == 1);
        assert(collaction.ownerOf(thirdTokenId) == address(Bob));
    }

    function testOperator() internal{

        NFTHolder Alice = new NFTHolder();
        NFTHolder Bob = new NFTHolder();

        collaction.mint(address(Alice));
        uint256 fourthTokenId = 3;

        assert(collaction.balanceOf(address(Alice)) == 1);
        assert(collaction.balanceOf(address(Bob)) == 0);
        assert(collaction.ownerOf(fourthTokenId) == address(Alice));

        Alice.operatorTo(address(collaction),address(Bob),true);
        
        assert(collaction.isApprovedForAll(address(Alice),address(Bob)) == true);

        Bob.transferFrom(address(collaction),address(Alice),fourthTokenId);

        assert(collaction.balanceOf(address(Alice)) == 0);
        assert(collaction.balanceOf(address(Bob)) == 1);
        assert(collaction.ownerOf(fourthTokenId) == address(Bob));
    }

    function testBurn() internal{

        NFTHolder Alice = new NFTHolder();

        collaction.mint(address(Alice));
        uint256 fifththTokenId = 4;

        assert(collaction.balanceOf(address(Alice)) == 1); 

        Alice.operatorTo(address(collaction),address(this),true);
        collaction.burn(fifththTokenId);

        assert(collaction.balanceOf(address(Alice)) == 0);   
    }
}