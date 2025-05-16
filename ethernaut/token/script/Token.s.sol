// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.2;

import {Script, console} from "forge-std/Script.sol";
import {Token} from "../src/Token.sol";

contract TokenScript is Script {
    Token public token;
    address player = vm.envAddress("PLAYER_ADDRESS");
    address targetContract = vm.envAddress("TARGET_CONTRACT_ADDRESS");
    Token private t;

    function setUp() public {
        t = Token(targetContract);
    }

    function run() public {
        vm.startBroadcast(vm.envUint("PK"));

        t.transfer(player, 1000 ether);

        console.log(t.balanceOf(player) / 1e18);
        vm.stopBroadcast();
    }
}
