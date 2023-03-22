// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import "./IERC1155.sol";

interface IERC1155MetadataURI {

    function uri(uint256 id) external view returns (string memory);
}