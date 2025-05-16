// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Privacy} from "../src/Privacy.sol";

contract PrivacyTest is Test {
    Privacy public privacy;
    bytes32 private key = bytes32(uint256(3));

    function setUp() public {
        bytes32[3] memory data;
        data[0] = bytes32(uint256(1));
        data[1] = bytes32(uint256(2));
        data[2] = key;
        privacy = new Privacy(data);
        assert(privacy.locked() == true);
    }

    function test_unlock() public {
        privacy.unlock(bytes16(key));
        assert(privacy.locked() == false);
    }
}
