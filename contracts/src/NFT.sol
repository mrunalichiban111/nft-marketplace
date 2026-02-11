// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";


contract NFT is ERC721{
    uint256 private _nextTokenId;

    constructor() ERC721("WillyNFT","WNFT"){
        _nextTokenId = 1;
    }

    struct NFTMetadata {
        string name;
        string description;
    }

    mapping(uint256 => NFTMetadata) private _metadata;

    function mintNFT(string memory name, string memory description) public {
        uint256 _tokenId=_nextTokenId;
        _nextTokenId++;
        _safeMint(msg.sender, _tokenId);
        _metadata[_tokenId] = NFTMetadata(name, description);
    }

    function getNFTMetadata(uint256 tokenId) public view returns (string memory, string memory) {
        ownerOf(tokenId); 
        NFTMetadata memory metadata = _metadata[tokenId];
        return (metadata.name, metadata.description);
    }

    function getAllNFTs() public view returns (NFTMetadata[] memory) {
        NFTMetadata[] memory allNFTs = new NFTMetadata[](_nextTokenId - 1);
        for (uint256 i = 1; i < _nextTokenId; i++) {
            allNFTs[i - 1] = _metadata[i];
        }
        return allNFTs;
    }
}

