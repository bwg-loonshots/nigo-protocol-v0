// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import "./interfaces/IERC721.sol";
import "./interfaces/IERC721Metadata.sol";
import "./interfaces/IERC165.sol";
import "./interfaces/IERC721Receiver.sol";
import "./libs/Address.sol";
import "./libs/Strings.sol";
import "./libs/Counters.sol";
import "../contracts/libs/SafeMath.sol";

contract ERC721 is IERC721, IERC165, IERC721Metadata {
    using Address for address;
    using Strings for uint256;
    using SafeMath for uint256;
    using Counters for Counters.Counter;

    string private _name;

    string private _symbol;

    string private _baseURI;

    Counters.Counter private _tokenIdCounter;

    mapping(uint256 => address) private _owners;

    mapping(address => uint256) private _balances;

    mapping(uint256 => address) private _tokenApprovals;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    modifier requireMinted(uint256 tokenId) {
        _requireMinted(tokenId);
        _;
    }

    constructor(string memory name_, string memory symbol_, string memory baseURI_) {
        _name = name_;
        _symbol = symbol_;
        _baseURI = baseURI_; //nft원본 주소 (ex:https://ipfs.io/ipfs/...)
    }    

    /*
    * information methods
    */

    function name() external view override returns (string memory) {
        return _name;
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function tokenURI(uint256 tokenId) external view requireMinted(tokenId) override returns (string memory) {
        string memory baseURI = _baseURI;
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    function balanceOf(address owner) external view override returns (uint256) {
        require(owner != address(0), "ERC721: address zero is not a valid owner");
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view override returns (address) {
        address owner = _ownerOf(tokenId);
        require(owner != address(0), "ERC721: invalid token ID");
        return owner;
    }

    function _ownerOf(uint256 tokenId) internal view returns (address) {
        return _owners[tokenId];
    }

    /*
    * transfer methods
    */

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public override {
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: caller is not token owner or approved");
        _safeTransfer(from, to, tokenId, data);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) external override {
        safeTransferFrom(from, to, tokenId, "");
    }

    function transferFrom(address from, address to, uint256 tokenId) external override {
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: caller is not token owner or approved");

        _transfer(from, to, tokenId);
    }

    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory data ) internal {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _transfer(address from, address to, uint256 tokenId ) internal {
        require(ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        delete _tokenApprovals[tokenId];
        
        _balances[from] = _balances[from].sub(1);
        _balances[to] = _balances[to].add(1);

        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    /*
    * approve methods
    */

    function approve(address to, uint256 tokenId) external override {
        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            msg.sender == owner || isApprovedForAll(owner, msg.sender),
            "ERC721: approve caller is not token owner or approved for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId) public view requireMinted(tokenId) override returns (address) {
        return _tokenApprovals[tokenId];
    }

    function _approve(address to, uint256 tokenId) internal {
        _tokenApprovals[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        address owner = ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }

    /*
    * operator methods
    */

    function isApprovedForAll(address owner, address operator) public view override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    function setApprovalForAll(address operator, bool approved) public override {
        _setApprovalForAll(msg.sender, operator, approved);
    }

    function _setApprovalForAll(address owner, address operator, bool approved) internal {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /*
    * mint&burn method
    */

    function mint(address to) external {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
    }

    function burn(uint256 tokenId) external {
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: caller is not token owner or approved");
        _burn(tokenId);
    }

    function _safeMint(address to, uint256 tokenId) internal {
        _safeMint(to, tokenId, "");
    }

    function _safeMint(address to, uint256 tokenId, bytes memory data) internal {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    function _mint(address to, uint tokenId) internal {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");
        
        _balances[to] = _balances[to].add(1);

        _owners[tokenId] = to;

        emit Transfer(address(0),to,tokenId);
    }

    function _burn(uint256 tokenId) internal {
        address owner = ERC721.ownerOf(tokenId);

        delete _tokenApprovals[tokenId];

        _balances[owner] = _balances[owner].sub(1);

        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    /*
    * etc methods
    */

    //ERC165
    function supportsInterface(bytes4 interfaceId) external pure override returns (bool) { 
        return interfaceId == type(IERC721).interfaceId || 
            interfaceId == type(IERC721Metadata).interfaceId ||
            interfaceId == type(IERC165).interfaceId;
    }

    function _requireMinted(uint256 tokenId) internal view {
        require(_exists(tokenId), "ERC721: invalid token ID");
    }

    function _exists(uint256 tokenId) internal view returns (bool) {
        return _ownerOf(tokenId) != address(0);
    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory data) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    /// @solidity memory-safe-assembly
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }
}
