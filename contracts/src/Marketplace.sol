// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface INFT {
    function ownerOf(uint256 tokenId) external view returns (address);
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
}

interface IPlatformToken {
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract Marketplace {
    INFT private immutable nft;
    IPlatformToken private immutable token;
    constructor(address _nftAddress, address _tokenAddress) {
        require(_nftAddress != address(0), "NFT address cannot be zero");
        require(_tokenAddress != address(0), "Token address cannot be zero");
        nft = INFT(_nftAddress);
        token = IPlatformToken(_tokenAddress);
    }

    struct Listing {
        uint256 tokenId;
        address seller;
        uint256 price;
        bool isSold;
    }

    mapping(uint256 => Listing) public listings;
    uint256[] public listedTokenIds;

    function listNFT(uint256 tokenId, uint256 price) public {
        require(
            nft.ownerOf(tokenId) == msg.sender,
            "You are not the owner of this NFT"
        );

        require(price > 0, "Price must be greater than zero");

        require(
            listings[tokenId].seller == address(0),
            "NFT is already listed"
        );

        nft.safeTransferFrom(msg.sender, address(this), tokenId);

        listings[tokenId] = Listing({
            tokenId: tokenId,
            seller: msg.sender,
            price: price,
            isSold: false
        });

        listedTokenIds.push(tokenId);
    }
    mapping(address => uint256[]) private purchasedNFTs;

    function buyNFT(uint256 tokenId) public {
        Listing storage listing = listings[tokenId];

        require(listing.seller != address(0), "NFT is not listed for sale");
        require(
            msg.sender != listing.seller,
            "Seller cannot buy their own NFT"
        );
        require(!listing.isSold, "NFT is already sold");
        require(
            token.balanceOf(msg.sender) >= listing.price,
            "Insufficient token balance"
        );

        bool success = token.transferFrom(
            msg.sender,
            listing.seller,
            listing.price
        );
        require(success, "Token transfer failed");

        nft.safeTransferFrom(address(this), msg.sender, tokenId);

        listing.isSold = true;
        purchasedNFTs[msg.sender].push(tokenId);
    }

    function getListing(uint256 tokenId) public view returns (Listing memory) {
        require(listings[tokenId].seller != address(0), "NFT not listed");
        return listings[tokenId];
    }

    function getActiveListings() public view returns (Listing[] memory) {
        uint256 count = 0;

        // First count active listings
        for (uint256 i = 0; i < listedTokenIds.length; i++) {
            if (!listings[listedTokenIds[i]].isSold) {
                count++;
            }
        }

        Listing[] memory active = new Listing[](count);
        uint256 index = 0;

        // Populate array
        for (uint256 i = 0; i < listedTokenIds.length; i++) {
            uint256 id = listedTokenIds[i];
            if (!listings[id].isSold) {
                active[index] = listings[id];
                index++;
            }
        }

        return active;
    }

    function getSoldListings() public view returns (Listing[] memory) {
        uint256 count = 0;

        for (uint256 i = 0; i < listedTokenIds.length; i++) {
            if (listings[listedTokenIds[i]].isSold) {
                count++;
            }
        }

        Listing[] memory sold = new Listing[](count);
        uint256 index = 0;

        for (uint256 i = 0; i < listedTokenIds.length; i++) {
            uint256 id = listedTokenIds[i];
            if (listings[id].isSold) {
                sold[index] = listings[id];
                index++;
            }
        }

        return sold;
    }

    function getPurchasedNFTs(
        address user
    ) public view returns (uint256[] memory) {
        return purchasedNFTs[user];
    }
}
