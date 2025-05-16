// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Elevator} from "../src/Elevator.sol";
import {ElevatorExploit} from "../src/Elevator.e.sol";

contract ElevatorTest is Test {
    Elevator public elevator;
    ElevatorExploit public elevatorExploit;
    function setUp() public {
        elevator = new Elevator();
        elevatorExploit = new ElevatorExploit(address(elevator));
    }

    function test_Increment() public {
        assert(elevator.floor() == 0);
        assert(elevator.top() == false);
        elevatorExploit.attack();
        assert(elevator.floor() == 10);
        assert(elevator.top() == true);
    }

    function test_NonSmartcontract() public {
        assert(elevator.floor() == 0);
        assert(elevator.top() == false);

        vm.expectRevert();
        elevator.goTo(1);
    }
}
