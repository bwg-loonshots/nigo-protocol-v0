// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import "../../erc1155/ERC1155.sol";
import "./ERC1155Holder.sol";

contract ERC1155_test {
    ERC1155 collection = new ERC1155("http://localhost:8080/nft/metadata/");

    function test() external {
        testMint();
        testMintBatch();
        testTransferByOwner();
        testTransferByOwnerBatch();
        testTransferByApproved();
        testTransferByApprovedBatch();
        testBurn();
        testBurnBatch();
    }

    function testMint() internal {
        collection.mint(msg.sender,1,"data");
        uint256 firstTokenId = 0;

        assert(collection.balanceOf(msg.sender,firstTokenId) == 1);
    }
    
    function testMintBatch() internal {
        uint256[] memory ids = new uint256[](5);
        address[] memory accounts = new address[](5);

        for (uint256 i = 1; i <= 5; i++) {
            ids[i-1] = i;
            accounts[i-1] = msg.sender;
        }

        //id = [1,2,3,4,5]
        //accounts = [msg.sender,msg.sender,msg.sender,msg.sender,msg.sender]

        collection.mintBatch(msg.sender,ids,"data");

        uint256[] memory result = collection.balanceOfBatch(accounts,ids);

        for (uint256 i = 0; i < 5; i++) {
            assert(result[i] == ids[i]);
        }
    }

    function testTransferByOwner() internal {
        ERC1155Holder Alice = new ERC1155Holder();
        ERC1155Holder Bob = new ERC1155Holder();

        collection.mint(address(Alice),1,"data");
        uint256 firstTokenId = 6;

        assert(collection.balanceOf(address(Alice),firstTokenId) == 1);

        Alice.transferTo(address(collection),address(Bob),firstTokenId,1);

        checkTokenTransferOne(address(Alice),address(Bob),firstTokenId);
    }

    function testTransferByOwnerBatch() internal {
        ERC1155Holder Alice = new ERC1155Holder();
        ERC1155Holder Bob = new ERC1155Holder();

        uint256[] memory ids = new uint256[](5);
        uint256[] memory amounts = new uint256[](5);
        address[] memory accountsAlice = new address[](5);
        address[] memory accountsBob = new address[](5);

        for (uint256 i = 0; i < 5; i++) {
            ids[i] = i+7;
            amounts[i] = 1;
            accountsAlice[i] = address(Alice);
            accountsBob[i] = address(Bob);
        }

        collection.mintBatch(address(Alice),amounts,"data");

        uint256[] memory resultMint = collection.balanceOfBatch(accountsAlice,ids);

        for (uint256 i = 0; i < 5; i++) { // 5개 mint 확인
            assert(resultMint[i] == amounts[i]);
        }

        // 3개만 Transfer실행(부분 Transfer)
        uint256[] memory partOfIds = new uint256[](3);
        uint256[] memory partOfAmounts = new uint256[](3);

        for (uint256 i = 0; i < 3; i++) { 
            partOfIds[i] = i+7;
            partOfAmounts[i] = 1;
        }

        Alice.transferToBatch(address(collection), address(Bob), partOfIds, partOfAmounts);

        checkTokenTransferBatch(address(Alice),address(Bob),ids);
    }

    function testTransferByApproved() internal {
        ERC1155Holder Alice = new ERC1155Holder();
        ERC1155Holder Bob = new ERC1155Holder();

        collection.mint(address(Alice),1,"data");
        uint256 firstTokenId = 12;

        assert(collection.balanceOf(address(Alice),firstTokenId) == 1);

        Alice.approveTo(address(collection), address(Bob));

        assert(collection.isApprovedForAll(address(Alice), address(Bob)));
        
        Bob.transferFrom(address(collection), address(Alice), firstTokenId, 1);

        checkTokenTransferOne(address(Alice),address(Bob),firstTokenId);
    }

    function testTransferByApprovedBatch() internal {
        ERC1155Holder Alice = new ERC1155Holder();
        ERC1155Holder Bob = new ERC1155Holder();

        uint256[] memory ids = new uint256[](5);
        uint256[] memory amounts = new uint256[](5);
        address[] memory accountsAlice = new address[](5);
        address[] memory accountsBob = new address[](5);

        for (uint256 i = 0; i < 5; i++) {
            ids[i] = i+13;
            amounts[i] = 1;
            accountsAlice[i] = address(Alice);
            accountsBob[i] = address(Bob);
        }

        collection.mintBatch(address(Alice),amounts,"data");

        uint256[] memory resultMint = collection.balanceOfBatch(accountsAlice,ids);

        for (uint256 i = 0; i < 5; i++) { // 5개 mint 확인
            assert(resultMint[i] == amounts[i]);
        }

        Alice.approveTo(address(collection), address(Bob));

        assert(collection.isApprovedForAll(address(Alice), address(Bob)));

        // 3개만 Transfer실행(부분 Transfer)
        uint256[] memory partOfIds = new uint256[](3);
        uint256[] memory partOfAmounts = new uint256[](3);

        for (uint256 i = 0; i < 3; i++) { 
            partOfIds[i] = i+13;
            partOfAmounts[i] = 1;
        }
        
        Bob.transferFromBatch(address(collection), address(Alice), partOfIds, partOfAmounts);

        checkTokenTransferBatch(address(Alice),address(Bob),ids);
    }

    function testBurn() internal {
        ERC1155Holder Alice = new ERC1155Holder();

        collection.mint(address(Alice),1,"data");
        uint256 firstTokenId = 18;

        assert(collection.balanceOf(address(Alice),firstTokenId) == 1);

        Alice.approveTo(address(collection),address(this));

        assert(collection.isApprovedForAll(address(Alice), address(this)));

        collection.burn(address(Alice),firstTokenId,1);

        assert(collection.balanceOf(address(Alice),firstTokenId) == 0);
    }

    function testBurnBatch() internal {
        ERC1155Holder Alice = new ERC1155Holder();

        uint256[] memory ids = new uint256[](5);
        uint256[] memory amounts = new uint256[](5);
        address[] memory accountsAlice = new address[](5);

        for (uint256 i = 0; i < 5; i++) {
            ids[i] = i+19;
            amounts[i] = 1;
            accountsAlice[i] = address(Alice);
        }

        collection.mintBatch(address(Alice),amounts,"data");

        uint256[] memory resultMint = collection.balanceOfBatch(accountsAlice,ids);

        for (uint256 i = 0; i < 5; i++) { // 5개 mint 확인
            assert(resultMint[i] == amounts[i]);
        }

        Alice.approveTo(address(collection),address(this));

        assert(collection.isApprovedForAll(address(Alice), address(this)));

        // 3개만 burn실행(부분 burn)
        uint256[] memory partOfIds = new uint256[](3);
        uint256[] memory partOfAmounts = new uint256[](3);

        for (uint256 i = 0; i < 3; i++) { 
            partOfIds[i] = i+19;
            partOfAmounts[i] = 1;
        }

        collection.burnBatch(address(Alice),partOfIds,partOfAmounts);
        
        uint256[] memory expect = new uint256[](5);

        // 부분 Tranfer 후 전송 결과 및 비전송 여부 확인
        expect[0] = 0;
        expect[1] = 0;
        expect[2] = 0;
        expect[3] = 1;
        expect[4] = 1;

        uint256[] memory resultTransfer = collection.balanceOfBatch(accountsAlice,ids);

        for (uint256 i = 0; i < 5; i++) {
            assert(resultTransfer[i] == expect[i]);
        }
    }

    function checkTokenTransferOne(address Alice, address Bob, uint256 firstTokenId) internal view{
        address[] memory accounts = new address[](2);
        accounts[0] = Alice;
        accounts[1] = Bob;

        uint256[] memory ids = new uint256[](2);
        ids[0] = firstTokenId;
        ids[1] = firstTokenId;

        uint256[] memory result = collection.balanceOfBatch(accounts,ids);

        assert(result[0] == 0);
        assert(result[1] == 1);
    }

    function checkTokenTransferBatch(address Alice, address Bob, uint256[] memory ids) internal view{
        address[] memory accounts = new address[](5);

        // 부분 Tranfer 후 전송 결과 및 비전송 여부 확인
        accounts[0] = address(Bob);
        accounts[1] = address(Bob);
        accounts[2] = address(Bob);
        accounts[3] = address(Alice);
        accounts[4] = address(Alice);

        uint256[] memory resultTransfer = collection.balanceOfBatch(accounts,ids);

        for (uint256 i = 0; i < 5; i++) {
            assert(resultTransfer[i] == 1);
        }

        // 부분 Tranfer 후 전송후 미보유 및 비전송에 따라 미보유 여부 확인
        accounts[0] = address(Alice);
        accounts[1] = address(Alice);
        accounts[2] = address(Alice);
        accounts[3] = address(Bob);
        accounts[4] = address(Bob);

        resultTransfer = collection.balanceOfBatch(accounts,ids);
        
        for (uint256 i = 0; i < 5; i++) {
            assert(resultTransfer[i] == 0); 
        }
    }
}