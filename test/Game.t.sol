// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.27;

import "forge-std/Test.sol";
import { console } from "forge-std/console.sol";
import "src/Level1.d.sol";
import "src/Level2.d.sol";
import "src/LevelConfigurator.sol";
import "src/Game.d.sol";

enum CellValueL1 { Empty, X, O }

contract TestGame is Test {
    GameD game;
    address admin;
    address bidder1;
    address bidder2;
    address player1;
    address player2;

    // Generates sample level code
    function _generateLevelCode(uint8 _num) internal pure
        returns (bytes memory _levelCode) {

        // Level 1 contract init code (w/o constructore arguments)
        if (_num == 1) {
            _levelCode = type(Level1D).creationCode; 
        }
        else if (_num == 2) {
            _levelCode = type(Level2D).creationCode; 
        }        
    }

    // Generates level number
    function _generateLevelNum(uint8 _num) internal pure
        returns (bytes memory _levelNum) {

        if (_num == 1)
            _levelNum = abi.encodePacked(_num);
        else if (_num == 2) 
            _levelNum = abi.encodePacked(_num);
    }

    // Generates state for a level
    function _generateState(uint8 _num) internal pure
        returns (bytes memory _levelState) {

    if (_num == 1)
            _levelState = hex"010000000000000002";
        else if (_num == 2)
            _levelState = hex"020000000000000003"
                          hex"000300000000000001"
                          hex"010200000000000000"
                          hex"000001000000000200"
                          hex"000000000200010000"            
                          hex"000000020001000000"
                          hex"000002000100000000"
                          hex"000000010002000000"
                          hex"000000000000020100";
    }

    // Generates symbols for a level
    function _generateSymbols(uint8 _num) internal pure
        returns (bytes memory _levelSymbols) {
        bytes4 X = hex"e29d8c00"; //"❌"
        bytes4 O = hex"e2ad9500"; //"⭕"            
        bytes4 Star = hex"e2ad9000"; //"⭐"
        bytes4 Bomb = hex"f09f92a3"; //"💣"

        if (_num == 1) {
            _levelSymbols = abi.encodePacked(X, O);
        }
        else if (_num == 2) {
            _levelSymbols = abi.encodePacked(X, O, Star, Bomb);
        }
    }

    function setUp() public {
        bytes memory code = _generateLevelCode(1);
        bytes memory levelNum = _generateLevelNum(1);
        bytes memory levelState = _generateState(1);
        bytes memory levelSymbols = _generateSymbols(1);
        bytes32 codeHash = keccak256(abi.encodePacked(code));

        uint256 privKeyAdmin = 0xabc123;
        admin = vm.addr(privKeyAdmin);

        vm.prank(admin);

        // Should initialize game state 
        game = new GameD(admin);
        LevelConfigurator levelConfig = LevelConfigurator(game.getLevelConfigurator());

        vm.stopPrank();

        uint256 privKeyBidder1 = 0xabc124;
        bidder1 = vm.addr(privKeyBidder1);
        
        vm.prank(bidder1);
        levelConfig.initLevel(levelNum, levelState, levelSymbols, codeHash);
        vm.stopPrank();


        bytes32 msghash = keccak256(abi.encodePacked(levelNum,
            levelState, levelSymbols, codeHash));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privKeyBidder1,
            MessageHashUtils.toEthSignedMessageHash(msghash));

        vm.prank(bidder1);
        levelConfig.deployLevel(_generateLevelCode(1), _generateLevelNum(1),
                                _generateState(1), _generateSymbols(1),
                                msghash, 0x01, abi.encodePacked(r, s, v));
        vm.stopPrank();

        player1 = vm.addr(0xabc125);
        player2 = vm.addr(0xabc126);

    }

    // Test the Game contract constructor
    function test_game() external view {

        assertEq(game.admin(), admin);
    }

    function test__winnerInRows() external {
       
        // Should initialize game state for Level 1
        // with all X in first row 
        vm.prank(admin);

        (bool success, string memory message) = game.newGame(1, 1, bidder1);

        vm.stopPrank();

        vm.prank(player1);

        (success, message) = game.joinGame(1);

        vm.stopPrank();

        vm.prank(player2);

        (success, message) = game.joinGame(1);

        vm.stopPrank();

        vm.prank(player1);

        // Should return Player 1 as winner
        Move memory m = Move(0, 1);
        (success, message) = game.makeMove(1, m);

        vm.stopPrank();

        vm.prank(player2);

        m = Move(1, 0);
        (success, message) = game.makeMove(1, m);

        vm.stopPrank();

        vm.prank(player1);

        m = Move(0, 2);
        (success, message) = game.makeMove(1, m);

        vm.stopPrank();

        assertTrue(success);
        assertEq(message, "You Won!@combo:row,r:0,c:0,d:");
    }

    function test__winnerInCols() external {
       
        // Should initialize game state for Level 1
        // with all X in first col 
        vm.prank(admin);

        (bool success, string memory message) = game.newGame(1, 1, bidder1);

        vm.stopPrank();

        vm.prank(player1);

        (success, message) = game.joinGame(1);

        vm.stopPrank();

        vm.prank(player2);

        (success, message) = game.joinGame(1);

        vm.stopPrank();

        vm.prank(player1);

        // Should return Player 1 as winner
        Move memory m = Move(1, 0);
        (success, message) = game.makeMove(1, m);

        vm.stopPrank();

        vm.prank(player2);

        m = Move(1, 1);
        (success, message) = game.makeMove(1, m);

        vm.stopPrank();

        vm.prank(player1);

        m = Move(2, 0);
        (success, message) = game.makeMove(1, m);

        vm.stopPrank();

        assertTrue(success);
        assertEq(message, "You Won!@combo:col,r:0,c:0,d:");
    }

    function test__winnerInFwdDiags() external {
       
        // Should initialize game state for Level 1
        // with all X in forward diagonal 
        vm.prank(admin);

        (bool success, string memory message) = game.newGame(1, 1, bidder1);

        vm.stopPrank();

        vm.prank(player1);

        (success, message) = game.joinGame(1);

        vm.stopPrank();

        vm.prank(player2);

        (success, message) = game.joinGame(1);

        vm.stopPrank();

        vm.prank(player1);

        // Should return Player 1 as winner
        Move memory m = Move(1, 1);
        (success, message) = game.makeMove(1, m);

        vm.stopPrank();

        vm.prank(player2);

        m = Move(0, 1);
        (success, message) = game.makeMove(1, m);

        vm.stopPrank();

        vm.prank(player1);

        m = Move(2, 2);
        (success, message) = game.makeMove(1, m);

        vm.stopPrank();

        assertTrue(success);
        assertEq(message, "You Won!@combo:fwddiag,r: ,c: ,d:0 ");
    }

    function test__winnerInBckwdDiags() external {
       
        // Should initialize game state for Level 1
        // with all X in backward diagonal 
        vm.prank(admin);

        (bool success, string memory message) = game.newGame(1, 1, bidder1);

        vm.stopPrank();

        vm.prank(player1);

        (success, message) = game.joinGame(1);

        vm.stopPrank();

        vm.prank(player2);

        (success, message) = game.joinGame(1);

        vm.stopPrank();

        vm.prank(player1);

        // Should return Player 1 as winner
        Move memory m = Move(1, 1);
        (success, message) = game.makeMove(1, m);

        vm.stopPrank();

        vm.prank(player2);

        m = Move(0, 1);
        (success, message) = game.makeMove(1, m);

        vm.stopPrank();

        vm.prank(player1);

        m = Move(0, 2);
        (success, message) = game.makeMove(1, m);

        vm.stopPrank();

        vm.prank(player2);

        m = Move(2, 2);
        (success, message) = game.makeMove(1, m);

        vm.stopPrank();

        vm.prank(player1);

        m = Move(2, 0);
        (success, message) = game.makeMove(1, m);

        vm.stopPrank();        
        assertTrue(success);
        assertEq(message, "You Won!@combo:fwddiag,r: ,c: ,d:0 ");
    }                   
}