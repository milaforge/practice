// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Telephone} from "../src/Telephone.sol";
import {Exploit} from "../src/Telephone.e.sol";

contract TelephoneTest is Test {
    Telephone private telephoneContract;
    Exploit private exploitContract;
    address player = vm.envAddress("PLAYER_ADDRESS");

    function setUp() public {
        telephoneContract = new Telephone();
        assertEq(telephoneContract.owner(), address(this));

        exploitContract = new Exploit(address(telephoneContract));
    }

    function test_Owner() public {
        console.log("Test Caller: ", address(this));
        exploitContract.exploit(player);
        assertEq(telephoneContract.owner(), player);
    }
}
