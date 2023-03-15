// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import "../../nft721/ERC721.sol";
import "./NFTHolder.sol";

contract ERC721_test {

    ERC721 collaction = new ERC721("nigoNFT","nigoNFT","http://localhost:8080/nft/metadata/");
    NFTHolder Alice = new NFTHolder();
    NFTHolder Bob = new NFTHolder();
    NFTHolder Charlie = new NFTHolder();
    
    uint256 firstTokenId = 0;
    uint256 secondTokenId = 1;
    uint256 thirdTokenId = 2;

    function test() external{

        testMint();

        testTransferByOwner();

        testTransferByApproved();

        testOperator();

        testBurn();
    }

    function testMint() internal{

        collaction.mint(msg.sender);

        assert(collaction.balanceOf(msg.sender) == 1);
        assert(collaction.ownerOf(firstTokenId) == msg.sender);
    }

    function testTransferByOwner() internal{

        collaction.mint(address(Alice));

        assert(collaction.balanceOf(address(Alice)) == 1);
        assert(collaction.ownerOf(secondTokenId) == address(Alice));

        Alice.transferTo(address(collaction),address(Bob),secondTokenId);

        assert(collaction.balanceOf(address(Alice)) == 0);
        assert(collaction.balanceOf(address(Bob)) == 1);
        assert(collaction.ownerOf(secondTokenId) == address(Bob));
    }

    function testTransferByApproved() internal{

        collaction.mint(address(Bob));

        assert(collaction.balanceOf(address(Bob)) == 2);
        assert(collaction.ownerOf(thirdTokenId) == address(Bob));

        Bob.approveTo(address(collaction),address(Alice),thirdTokenId);

        assert(collaction.getApproved(thirdTokenId) == address(Alice));

        Alice.transferFrom(address(collaction),address(Bob),thirdTokenId);

        assert(collaction.balanceOf(address(Bob)) == 1);
        assert(collaction.balanceOf(address(Alice)) == 1);
        assert(collaction.ownerOf(thirdTokenId) == address(Alice));
    }

    function testOperator() internal{

        Alice.operatorTo(address(collaction),address(Charlie),true);
        
        assert(collaction.isApprovedForAll(address(Alice),address(Charlie)) == true);

        Charlie.transferFrom(address(collaction),address(Alice),thirdTokenId);

        assert(collaction.balanceOf(address(Alice)) == 0);
        assert(collaction.balanceOf(address(Charlie)) == 1);
        assert(collaction.ownerOf(thirdTokenId) == address(Charlie));
    }

    function testBurn() internal{

        Charlie.operatorTo(address(collaction),address(this),true);
        collaction.burn(thirdTokenId);

        assert(collaction.balanceOf(address(Charlie)) == 0);   
    }
}