// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.27;

import "forge-std/Test.sol";

import "src/TicTacToe.sol";

contract TestTicTacToe is Test {
    TicTacToe c;

    function setUp() public {
        c = new TicTacToe();
    }
}