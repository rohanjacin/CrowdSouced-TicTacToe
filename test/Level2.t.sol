// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.27;

import "forge-std/Test.sol";
import "src/Level2.sol";
import { BaseState } from "src/BaseState.sol";
import { BaseSymbol } from "src/BaseSymbol.sol";

contract TestLevel2 is Test {

    function setUp() public {
        //level = new Level2();
    }

    // Internal function to set levelnum
    function _setLevelNum(uint8 _num) internal returns (uint8 levelnum) {
        // Level num = _num
        levelnum = _num;
    }

    // Internal function to set state
    function _setState(uint8 _num) internal returns (Level2.State memory state) {

        if (_num == 1) {
            // Set state of level 1 i.e 3x3 matrix
            state = BaseState.State({v: new uint256[][](3)});
            state.v[0] = new uint256[](3);
            state.v[1] = new uint256[](3);
            state.v[2] = new uint256[](3);

            // [1, 2, 3] R0
            state.v[0][0] = uint256(1);
            state.v[0][1] = uint256(2);
            state.v[0][2] = uint256(3);

            // [4, 5, 7] R1
            state.v[1][0] = uint256(4);
            state.v[1][1] = uint256(5);
            state.v[1][2] = uint256(6);

            // [7, 8, 9] R2
            state.v[2][0] = uint256(7);
            state.v[2][1] = uint256(8);
            state.v[2][2] = uint256(9);        

            // C0  C1 C2
            // [1, 2, 3] R0
            // [4, 5, 7] R1
            // [7, 8, 9] R2
        }
        else if (_num == 2) {

            // Set state of level 2 i.e 9x9 matrix
            state = BaseState.State({v: new uint256[][](9)});
            state.v[0] = new uint256[](9);
            state.v[1] = new uint256[](9);
            state.v[2] = new uint256[](9);
            state.v[3] = new uint256[](9);
            state.v[4] = new uint256[](9);
            state.v[5] = new uint256[](9);
            state.v[6] = new uint256[](9);
            state.v[7] = new uint256[](9);
            state.v[8] = new uint256[](9);

            // [1, 2, 3, 4, 5, 6, 7, 8, 9] R0
            state.v[0][0] = uint256(1);
            state.v[0][1] = uint256(2);
            state.v[0][2] = uint256(3);
            state.v[0][3] = uint256(4);
            state.v[0][4] = uint256(5);
            state.v[0][5] = uint256(6);
            state.v[0][6] = uint256(7);
            state.v[0][7] = uint256(8);
            state.v[0][8] = uint256(9);

            // [10, 11, 12, 13, 14, 15, 16, 17, 18] R1
            state.v[1][0] = uint256(10);
            state.v[1][1] = uint256(11);
            state.v[1][2] = uint256(12);
            state.v[1][3] = uint256(13);
            state.v[1][4] = uint256(14);
            state.v[1][5] = uint256(15);
            state.v[1][6] = uint256(16);
            state.v[1][7] = uint256(17);
            state.v[1][8] = uint256(18);

            // [19, 20, 21, 22, 23, 24, 25, 26, 27] R2
            state.v[2][0] = uint256(19);
            state.v[2][1] = uint256(20);
            state.v[2][2] = uint256(21);
            state.v[2][3] = uint256(22);
            state.v[2][4] = uint256(23);
            state.v[2][5] = uint256(24);
            state.v[2][6] = uint256(25);
            state.v[2][7] = uint256(26);
            state.v[2][8] = uint256(27);

            // [28, 29, 30, 31, 32, 33, 34, 35, 36] R3
            state.v[3][0] = uint256(28);
            state.v[3][1] = uint256(29);
            state.v[3][2] = uint256(30);
            state.v[3][3] = uint256(31);
            state.v[3][4] = uint256(32);
            state.v[3][5] = uint256(33);
            state.v[3][6] = uint256(34);
            state.v[3][7] = uint256(35);
            state.v[3][8] = uint256(36);

            // [37, 38, 39, 40, 41, 42, 43, 44, 45] R4
            state.v[4][0] = uint256(37);
            state.v[4][1] = uint256(38);
            state.v[4][2] = uint256(39);
            state.v[4][3] = uint256(40);
            state.v[4][4] = uint256(41);
            state.v[4][5] = uint256(42);
            state.v[4][6] = uint256(43);
            state.v[4][7] = uint256(44);
            state.v[4][8] = uint256(45); 

            // [46, 47, 48, 49, 50, 51, 52, 53, 54] R5
            state.v[5][0] = uint256(46);
            state.v[5][1] = uint256(47);
            state.v[5][2] = uint256(48);
            state.v[5][3] = uint256(49);
            state.v[5][4] = uint256(50);
            state.v[5][5] = uint256(51);
            state.v[5][6] = uint256(52);
            state.v[5][7] = uint256(53);
            state.v[5][8] = uint256(54); 

            // [55, 56, 57, 58, 59, 60, 61, 62, 63] R6
            state.v[6][0] = uint256(55);
            state.v[6][1] = uint256(56);
            state.v[6][2] = uint256(57);
            state.v[6][3] = uint256(58);
            state.v[6][4] = uint256(59);
            state.v[6][5] = uint256(60);
            state.v[6][6] = uint256(61);
            state.v[6][7] = uint256(62);
            state.v[6][8] = uint256(63); 

            // [64, 65, 66, 67, 68, 69, 70, 71, 72] R7
            state.v[7][0] = uint256(64);
            state.v[7][1] = uint256(65);
            state.v[7][2] = uint256(66);
            state.v[7][3] = uint256(67);
            state.v[7][4] = uint256(68);
            state.v[7][5] = uint256(69);
            state.v[7][6] = uint256(70);
            state.v[7][7] = uint256(71);
            state.v[7][8] = uint256(72); 

            // [73, 74, 75, 76, 77, 78, 79, 80, 81] R8
            state.v[8][0] = uint256(73);
            state.v[8][1] = uint256(74);
            state.v[8][2] = uint256(75);
            state.v[8][3] = uint256(76);
            state.v[8][4] = uint256(77);
            state.v[8][5] = uint256(78);
            state.v[8][6] = uint256(79);
            state.v[8][7] = uint256(80);
            state.v[8][8] = uint256(81); 

            //  C0  C1  C2  C3  C4  C5  C6  C7  C8
            // [01, 02, 03, 04, 05, 06, 07, 08, 09] R0
            // [10, 11, 12, 13, 14, 15, 16, 17, 18] R1
            // [19, 20, 21, 22, 23, 24, 25, 26, 27] R2
            // [28, 29, 30, 31, 32, 33, 34, 35, 36] R3
            // [37, 38, 39, 40, 41, 42, 43, 44, 45] R4
            // [46, 47, 48, 49, 50, 51, 52, 53, 54] R5
            // [55, 56, 57, 58, 59, 60, 61, 62, 63] R6
            // [64, 65, 66, 67, 68, 69, 70, 71, 72] R7
            // [73, 74, 75, 76, 77, 78, 79, 80, 81] R8
        }
    }

    // Internal function to set symbols
    function _setSymbol(uint8 num) internal returns (Level2.Symbols memory symbols) {

        if (num == 1) {
            // Set if length of symbols is 2
            symbols = BaseSymbol.Symbols({v: new bytes32[](2)});
            symbols.v[0] = bytes32(hex"274C");
            symbols.v[1] = bytes32(hex"2B55");
            
            // C0
            // [0x274c000000000000000000000000000000000000000000000000000000000000] R0
            // [0x2b55000000000000000000000000000000000000000000000000000000000000] R1
        }
        else if (num == 2) {

            // Set if length of symbols is 4
            symbols = BaseSymbol.Symbols({v: new bytes32[](4)});
            symbols.v[0] = bytes32(hex"274C");
            symbols.v[1] = bytes32(hex"2B55");
            symbols.v[2] = bytes32(hex"2B50");
            symbols.v[3] = bytes32(hex"01F4A3");

            // C0
            // [0x274c000000000000000000000000000000000000000000000000000000000000] R0
            // [0x2b55000000000000000000000000000000000000000000000000000000000000] R1
            // [0x2b50000000000000000000000000000000000000000000000000000000000000] R2
            // [0x01f4a300000000000000000000000000000000000000000000000000000000000] R3
        }
    }

    // Test Level 2 contract creation
    function test_level2() external {

        // Should pass for levelnum = 2, state = 9x9 and symbols = 4
        Level2 levelA = new Level2(_setLevelNum(2), _setState(2), _setSymbol(2));


        // Should fail for levelnum = 2, state = 3x3 and symbols = 2
        vm.expectRevert();
        Level2 levelB = new Level2(_setLevelNum(2), _setState(1), _setSymbol(1));
        

        // Should fail for levelnum = 1, state = 3x3 and symbols = 2
        vm.expectRevert();
        Level2 levelC = new Level2(_setLevelNum(1), _setState(1), _setSymbol(1));
    }
}