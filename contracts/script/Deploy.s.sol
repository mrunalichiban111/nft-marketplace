// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Script.sol";
import "../src/PlatformToken.sol";
import "../src/NFT.sol";
import "../src/Marketplace.sol";

contract Deploy is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Deploy Platform Token
        PlatformToken token = new PlatformToken();

        // Deploy NFT
        NFT nft = new NFT();

        // Deploy Marketplace (pass addresses)
        Marketplace marketplace = new Marketplace(
            address(nft),
            address(token)
        );

        vm.stopBroadcast();
    }
}
