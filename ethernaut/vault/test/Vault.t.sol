// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Vault} from "../src/Vault.sol";

contract VaultTest is Test {
    mapping(address => uint256) private map;
    bytes32 private password = "123";
    Vault public vault;

    function setUp() public {
        vault = new Vault(password);
    }

    function test_read_storage() public view {
        bytes32 slot = bytes32(uint(1));
        bytes32 read = vm.load(address(vault), slot);
        assertEq(read, password);
    }
}
