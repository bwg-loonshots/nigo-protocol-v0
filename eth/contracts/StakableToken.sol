// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

import "./MintableToken.sol";

contract StakableToken is MintableToken {

    address public creator;

    constructor(string memory _name, string memory _symbol) 
    MintableToken(_name, _symbol) {
        creator = msg.sender;
    }

    function mint(address to, uint256 value) external{
        require(creator == msg.sender, "Nigo:minting denied");
        _mint(to, value);
    }

    function burn(address from, uint value) external {
        require(creator == msg.sender, "Nigo:burning denied");
        _burn(from, value);
    }

}