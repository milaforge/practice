// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {GK} from "./GK.sol";
import {Test, console} from "forge-std/Test.sol";

contract GKCaller {
    GK private target;

    constructor(address _target) {
        assert(_target != address(0));
        target = GK(_target);
    }

    function proxy(uint256 gasToSend, bytes8 key) public {
        require(target.enter{gas: gasToSend}(key), "failed");
    }
}
