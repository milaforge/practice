// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {console} from "forge-std/console.sol";

contract Delegate {
    address public opa;
    address public owner;

    constructor(address _owner) {
        owner = _owner;
    }

    function pwn() public returns (bool){
        owner = msg.sender;
        return true;
    }
}

contract Delegation {
    address public owner;
    Delegate public delegate;

    constructor(address _delegateAddress) {
        delegate = Delegate(_delegateAddress);
        owner = msg.sender;
    }

    fallback() external {
        (bool result, ) = address(delegate).delegatecall(msg.data);
        if (result) {
            this;
        }
    }
}
