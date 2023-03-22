// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import "./interfaces/IERC1155.sol";
import "./interfaces/IERC1155MetadataURI.sol";
import "./interfaces/IERC1155Receiver.sol";
import "../nft721/libs/Address.sol";
import "../nft721/libs/Strings.sol";
import "../nft721/libs/Counters.sol";

contract ERC1155 is IERC1155, IERC1155MetadataURI {
    using Address for address;
    using Strings for uint256;
    using Counters for Counters.Counter;

    // tokenId => address => amount
    mapping(uint256 => mapping(address => uint256)) private _balances;

    // owner => operator => approvable
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
    * 수량을 정해서 approve하는 로직 없음
    */

    // baseUri
    string private _uri;

    Counters.Counter private _tokenIdCounter;

    address _manager;


    constructor(string memory uri_) {
        _uri = uri_;
        _manager = msg.sender;
    }

    //ERC-165
    function supportsInterface(bytes4 interfaceId) external pure override returns (bool) {
        return interfaceId == type(IERC1155).interfaceId ||
            interfaceId == type(IERC1155MetadataURI).interfaceId;
    }

    /**
    * token의 metadata를 호출하는 uri
    * 별도의 mapping(id => uri)을 선언하는 등 contract마다 다양한 처리방식 가능
    * 여기서는 간단하게 tokenId를 받아서 기본 url과 함께 제공
    */
    function uri(uint256 tokenId) external view override returns (string memory) {
        string memory baseURI = _uri;
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    // account 주소의 id 토큰의 량을 조회
    function balanceOf(address account, uint256 id) public view override returns (uint256) {
        require(account != address(0), "ERC1155: address zero is not a valid owner");
        return _balances[id][account];
    }

    //account와 id 목록을 받아 다건 조회
    function balanceOfBatch( address[] memory accounts, uint256[] memory ids) public view override returns (uint256[] memory) {
        require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch"); // accounts 길이는 ids 길이와 같아야함

        uint256[] memory batchBalances = new uint256[](accounts.length); // output을 위한 빈 배열

        for (uint256 i = 0; i < accounts.length; ++i) { //balanceOf(···)를 반복 실행
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

    function setApprovalForAll(address operator, bool approved) external override {
        _setApprovalForAll(msg.sender, operator, approved);
    }

    // approve 등록
    function _setApprovalForAll(address owner, address operator, bool approved) internal {
        //approve 대상 소유주와 관리자가 동일(무의미한 approve)인지 확인
        require(owner != operator, "ERC1155: setting approval status for self"); 

        _operatorApprovals[owner][operator] = approved; //approve mapping에 저장
        emit ApprovalForAll(owner, operator, approved); //이벤트 호출
    }
    
    function isApprovedForAll(address account, address operator) public view override returns (bool) {
        return _operatorApprovals[account][operator]; // approve mapping 조회
    }

    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes memory data) external override {
        //contract호출자가 소유주이거나 관리자(approved)인 경우만 송신 가능
        require( from == msg.sender || isApprovedForAll(from, msg.sender), "ERC1155: caller is not token owner or approved");
        _safeTransferFrom(from, to, id, amount, data);
    }

    function safeBatchTransferFrom(address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) public override {
        //contract호출자가 소유주이거나 관리자(approved)인 경우만 송신 가능
        require(from == msg.sender || isApprovedForAll(from, msg.sender), "ERC1155: caller is not token owner or approved");
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    function _safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes memory data) internal {
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = msg.sender;

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
        unchecked {
            _balances[id][from] = fromBalance - amount; // 송신자에서 전송량만큼 차감
        }
        _balances[id][to] += amount; // 수신자에게 전송량만큼 합산

        emit TransferSingle(operator, from, to, id, amount);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

    function _safeBatchTransferFrom(address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) internal {
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = msg.sender;

        for (uint256 i = 0; i < ids.length; ++i) {//입력받은 ids 배열 길이만큼 반복
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
            _balances[id][to] += amount;
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
    }

    function _mint(address to, uint256 id, uint256 amount, bytes memory data) internal {
        require(to != address(0), "ERC1155: mint to the zero address");

        address operator = msg.sender;

        _balances[id][to] += amount;

        emit TransferSingle(operator, address(0), to, id, amount);

        _doSafeTransferAcceptanceCheck(operator, address(0), to, id, amount, data);
    }

    function _mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) internal {
        require(to != address(0), "ERC1155: mint to the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = msg.sender;

        for (uint256 i = 0; i < ids.length; i++) {//입력받은 ids 배열 길이만큼 반복
            _balances[ids[i]][to] += amounts[i];
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }

    function _burn(address from, uint256 id, uint256 amount) internal {
        require(from != address(0), "ERC1155: burn from the zero address");

        address operator = msg.sender;

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }

        emit TransferSingle(operator, from, address(0), id, amount);
    }

    function _burnBatch(address from, uint256[] memory ids, uint256[] memory amounts) internal {
        require(from != address(0), "ERC1155: burn from the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = msg.sender;

        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
        }

        emit TransferBatch(operator, from, address(0), ids, amounts);
    }

    

    function _doSafeTransferAcceptanceCheck(address operator, address from, address to, uint256 id, uint256 amount, bytes memory data) private {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                if (response != IERC1155Receiver.onERC1155Received.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non-ERC1155Receiver implementer");
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) private {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (
                bytes4 response
            ) {
                if (response != IERC1155Receiver.onERC1155BatchReceived.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non-ERC1155Receiver implementer");
            }
        }
    }

    function mint(address to, uint256 amount, bytes memory data) public virtual {
        //constructor를 실행시킨 msg.sender만 mint 가능
        require(_manager==msg.sender,"ERC1155: msg sender is not manager");
        uint256 id = _tokenIdCounter.current();
        _tokenIdCounter.increment();

        _mint(to, id, amount, data);
    }

    function mintBatch(address to, uint256[] memory amounts, bytes memory data) public virtual {
        //constructor를 실행시킨 msg.sender만 mint 가능
        require(_manager==msg.sender,"ERC1155: msg sender is not manager");
        uint256[] memory ids = new uint256[](amounts.length); 

        for (uint256 i = 0; i < amounts.length; i++) {
            ids[i] = _tokenIdCounter.current();
            _tokenIdCounter.increment();
        }

        _mintBatch(to, ids, amounts, data);
    }

    function burn(address account, uint256 id, uint256 value) external {
        //contract호출자가 자신의 소유를 burn하거나 자신이 해당 주소의 관리자로 있는 경우 실행가능
        require(account == msg.sender || isApprovedForAll(account, msg.sender), "ERC1155: caller is not token owner or approved");
        _burn(account, id, value);
    }

    function burnBatch(address account, uint256[] memory ids, uint256[] memory values) external {
        //contract호출자가 자신의 소유를 burn하거나 자신이 해당 주소의 관리자로 있는 경우 실행가능
        require(account == msg.sender || isApprovedForAll(account, msg.sender),"ERC1155: caller is not token owner or approved");

        _burnBatch(account, ids, values);
    }

}