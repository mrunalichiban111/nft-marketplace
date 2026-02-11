// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract PlatformToken is ERC20{
    constructor() ERC20("WillyCoin","WILL"){
    }

    function buyTokens() public payable{
        require(msg.value>0,"You need to send some ether to buy tokens");
        _mint(msg.sender,(msg.value*100000)/1 ether);
    }
}

