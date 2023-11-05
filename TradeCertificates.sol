//SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract TradeCertificate is ERC721 {
    uint256 private _tokenIdCounter = 0;

    constructor() ERC721("TradeCertificate", "TCT") {}

    function mint(address owner) public returns (uint256) {
        _tokenIdCounter += 1;
        _mint(owner, _tokenIdCounter);
        return _tokenIdCounter;
    }
}
