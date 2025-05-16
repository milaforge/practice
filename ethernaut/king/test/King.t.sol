// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {King} from "../src/King.sol";
import {KingExploit} from "../src/King.e.sol";

contract KingTest is Test {
    King public king;
    address the_owner = makeAddr("the_owner");
    address higher_bidder = makeAddr("higher_bidder");
    KingExploit public kingExploit;

    function setUp() public {
        vm.deal(the_owner, 1 ether);
        vm.startPrank(the_owner);
        king = new King{value: 2 wei}();
        vm.stopPrank();

        // validate
        assertEq(king._king(), the_owner);
        assertEq(king.prize(), 2 wei);
    }

    function test_if_bid_lowr_than_prize() public {
        deal(higher_bidder, 1 ether);
        vm.startPrank(higher_bidder);
        (bool success, ) = payable(king).call{value: 1 wei}("");
        assert(!success);
        assertEq(king._king(), the_owner);
        vm.stopPrank();
    }

    function test_change_the_king_by_bidding_higher() public {
        deal(higher_bidder, 1 ether);
        vm.startPrank(higher_bidder);
        (bool success, ) = payable(king).call{value: king.prize()}("");
        assert(success);
        assertEq(king._king(), higher_bidder);
        vm.stopPrank();
    }

    function test_owner_cheating() public {
        uint256 the_rightful_king_bid = king.prize();
        deal(higher_bidder, 1 ether);
        vm.startPrank(higher_bidder);
        (bool success, ) = payable(king).call{value: the_rightful_king_bid}("");
        assert(success);
        assertEq(king._king(), higher_bidder);

        uint256 the_rightful_king_balance_before_cheating = address(
            higher_bidder
        ).balance;

        vm.startPrank(the_owner);
        (bool successful_cheating, ) = payable(king).call{value: 0}("");
        assert(successful_cheating);
        assertEq(king._king(), the_owner);

        assertEq(king.prize(), 0);

        uint256 the_rightful_king_balance_after_cheating = address(
            higher_bidder
        ).balance;

        //[LOGIC BUG]: the previous king did not receive their bid.
        assert(
            the_rightful_king_balance_after_cheating ==
                the_rightful_king_balance_before_cheating
        );

        vm.stopPrank();
    }

    function test_exploit_the_cheater() public {
        // Exploit Authorization: prevent others re-deploy the Exploit
        address permanent_king = address(
            0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
        );
        // Make permanent_king the ultimate king using the exploit contract
        vm.startPrank(permanent_king);
        vm.deal(permanent_king, 1 ether);
        kingExploit = new KingExploit{value: king.prize()}(king);
        vm.stopPrank();

        // Verify permanent_king is now king
        assertEq(king._king(), address(kingExploit));

        // Owner tries to cheat
        vm.startPrank(the_owner);
        (bool success, ) = payable(king).call{value: 0}("");
        assert(!success);

        assertEq(king.owner(), the_owner);
        assertEq(king._king(), address(kingExploit));
    }
}
