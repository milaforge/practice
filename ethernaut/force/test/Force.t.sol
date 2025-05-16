// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Force} from "../src/Force.sol";
import {ForceExploit} from "../src/Force.e.sol";

contract ForceTest is Test {
    Force public force;

    function setUp() public {
        force = new Force();
    }

    function test_Transfer() public {
        vm.deal(address(this), 1 ether);
        assert(address(this).balance == 1 ether);
        
        assert(address(force).balance == 0);

        new ForceExploit{value: 1 ether}(payable(address(force)));

        assertEq(address(force).balance , 1 ether);

    }
}
