// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {GK} from "../src/GK.sol";
import {GKCaller} from "../src/GK.e.sol";

contract GKTest is Test {
    GK private gk;
    GKCaller private caller;

    function setUp() public {
        gk = new GK();
        assert(gk.entrant() == address(0));

        caller = new GKCaller(address(gk));
    }

    function test_enter() public {
        uint64 uintKey = uint64(uint160(address(msg.sender)));
        bytes8 key = bytes8(uintKey) & 0xFFFFFFFF0000FFFF;

        uint256 required_gas = 0;
        for (uint256 i = 20; i <= 81910; i++) {
            // Try different gas values, adjusted by i
            try caller.proxy(8191 * 2 + i, key) {
                console.log("Gas required ->", i);
                required_gas = 8191 * 2 + i;
                return; // success
            } catch {}
        }

        caller.proxy(required_gas, key);
        assert(gk.entrant() == msg.sender);
    }

    function test_gates() public {
        uint64 uintKey = uint64(uint160(address(msg.sender)));
        bytes8 key = bytes8(uintKey) & 0xFFFFFFFF0000FFFF;

        require(
            uint32(uint64(key)) == uint16(uint64(key)),
            "GatekeeperOne: invalid gateThree part one"
        );
        require(
            uint32(uint64(key)) != uint64(key),
            "GatekeeperOne: invalid gateThree part two"
        );
        require(
            uint32(uint64(key)) == uint16(uint160(msg.sender)),
            "GatekeeperOne: invalid gateThree part three"
        );
    }
}
