// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
import {console} from 'forge-std/console.sol';

contract Reentrance {
    mapping(address => uint256) public balances;

    function donate(address _to) public payable {
        balances[_to] = balances[_to] + msg.value;
    }

    function balanceOf(address _who) public view returns (uint256 balance) {
        return balances[_who];
    }

    function withdraw(uint256 _amount) public {
        if (balances[msg.sender] >= _amount) {
            (bool result,) = msg.sender.call{value: _amount}("");
            if (result) {
                _amount;
            }
            console.log("[Target-withdraw()] Balance:",balances[msg.sender]);
            balances[msg.sender] -= _amount;
        }
    }

    receive() external payable {}
}