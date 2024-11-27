// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.27;

import "forge-std/Test.sol";
import { BaseState } from "src/BaseState.sol";

contract TestBaseState is Test {

    function setUp() public {
    }

    // Test state
    function test_state() external {

        // Should pass if length of state is 9 i.e 3x3 matrix
        BaseState.State memory s1 = BaseState.State({v: new uint256[][](3)});
        s1.v[0] = new uint256[](3);
        s1.v[1] = new uint256[](3);
        s1.v[2] = new uint256[](3);

        // [1, 2, 3] R0
        s1.v[0][0] = uint256(1);
        s1.v[0][1] = uint256(2);
        s1.v[0][2] = uint256(3);

        // [4, 5, 7] R1
        s1.v[1][0] = uint256(4);
        s1.v[1][1] = uint256(5);
        s1.v[1][2] = uint256(6);

        // [7, 8, 9] R2
        s1.v[2][0] = uint256(7);
        s1.v[2][1] = uint256(8);
        s1.v[2][2] = uint256(9);        

        // C0  C1 C2
        // [1, 2, 3] R0
        // [4, 5, 7] R1
        // [7, 8, 9] R2
        BaseState state1 = new BaseState(s1);
        state1=state1;


        // Should pass if length of state is 81 i.e 9x9 matrix
        BaseState.State memory s2 = BaseState.State({v: new uint256[][](9)});
        s2.v[0] = new uint256[](9);
        s2.v[1] = new uint256[](9);
        s2.v[2] = new uint256[](9);
        s2.v[3] = new uint256[](9);
        s2.v[4] = new uint256[](9);
        s2.v[5] = new uint256[](9);
        s2.v[6] = new uint256[](9);
        s2.v[7] = new uint256[](9);
        s2.v[8] = new uint256[](9);

        // [1, 2, 3, 4, 5, 6, 7, 8, 9] R0
        s2.v[0][0] = uint256(1);
        s2.v[0][1] = uint256(2);
        s2.v[0][2] = uint256(3);
        s2.v[0][3] = uint256(4);
        s2.v[0][4] = uint256(5);
        s2.v[0][5] = uint256(6);
        s2.v[0][6] = uint256(7);
        s2.v[0][7] = uint256(8);
        s2.v[0][8] = uint256(9);

        // [10, 11, 12, 13, 14, 15, 16, 17, 18] R1
        s2.v[1][0] = uint256(10);
        s2.v[1][1] = uint256(11);
        s2.v[1][2] = uint256(12);
        s2.v[1][3] = uint256(13);
        s2.v[1][4] = uint256(14);
        s2.v[1][5] = uint256(15);
        s2.v[1][6] = uint256(16);
        s2.v[1][7] = uint256(17);
        s2.v[1][8] = uint256(18);

        // [19, 20, 21, 22, 23, 24, 25, 26, 27] R2
        s2.v[2][0] = uint256(19);
        s2.v[2][1] = uint256(20);
        s2.v[2][2] = uint256(21);
        s2.v[2][3] = uint256(22);
        s2.v[2][4] = uint256(23);
        s2.v[2][5] = uint256(24);
        s2.v[2][6] = uint256(25);
        s2.v[2][7] = uint256(26);
        s2.v[2][8] = uint256(27);

        // [28, 29, 30, 31, 32, 33, 34, 35, 36] R3
        s2.v[3][0] = uint256(28);
        s2.v[3][1] = uint256(29);
        s2.v[3][2] = uint256(30);
        s2.v[3][3] = uint256(31);
        s2.v[3][4] = uint256(32);
        s2.v[3][5] = uint256(33);
        s2.v[3][6] = uint256(34);
        s2.v[3][7] = uint256(35);
        s2.v[3][8] = uint256(36);

        // [37, 38, 39, 40, 41, 42, 43, 44, 45] R4
        s2.v[4][0] = uint256(37);
        s2.v[4][1] = uint256(38);
        s2.v[4][2] = uint256(39);
        s2.v[4][3] = uint256(40);
        s2.v[4][4] = uint256(41);
        s2.v[4][5] = uint256(42);
        s2.v[4][6] = uint256(43);
        s2.v[4][7] = uint256(44);
        s2.v[4][8] = uint256(45); 

        // [46, 47, 48, 49, 50, 51, 52, 53, 54] R5
        s2.v[5][0] = uint256(46);
        s2.v[5][1] = uint256(47);
        s2.v[5][2] = uint256(48);
        s2.v[5][3] = uint256(49);
        s2.v[5][4] = uint256(50);
        s2.v[5][5] = uint256(51);
        s2.v[5][6] = uint256(52);
        s2.v[5][7] = uint256(53);
        s2.v[5][8] = uint256(54); 

        // [55, 56, 57, 58, 59, 60, 61, 62, 63] R6
        s2.v[6][0] = uint256(55);
        s2.v[6][1] = uint256(56);
        s2.v[6][2] = uint256(57);
        s2.v[6][3] = uint256(58);
        s2.v[6][4] = uint256(59);
        s2.v[6][5] = uint256(60);
        s2.v[6][6] = uint256(61);
        s2.v[6][7] = uint256(62);
        s2.v[6][8] = uint256(63); 

        // [64, 65, 66, 67, 68, 69, 70, 71, 72] R7
        s2.v[7][0] = uint256(64);
        s2.v[7][1] = uint256(65);
        s2.v[7][2] = uint256(66);
        s2.v[7][3] = uint256(67);
        s2.v[7][4] = uint256(68);
        s2.v[7][5] = uint256(69);
        s2.v[7][6] = uint256(70);
        s2.v[7][7] = uint256(71);
        s2.v[7][8] = uint256(72); 

        // [73, 74, 75, 76, 77, 78, 79, 80, 81] R8
        s2.v[8][0] = uint256(73);
        s2.v[8][1] = uint256(74);
        s2.v[8][2] = uint256(75);
        s2.v[8][3] = uint256(76);
        s2.v[8][4] = uint256(77);
        s2.v[8][5] = uint256(78);
        s2.v[8][6] = uint256(79);
        s2.v[8][7] = uint256(80);
        s2.v[8][8] = uint256(81); 

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

        BaseState state2 = new BaseState(s2);
        state2=state2;

        // Should fail if length of state is 2 i.e 2x2 matrix
        BaseState.State memory s3 = BaseState.State({v: new uint256[][](2)});
        s3.v[0] = new uint256[](2);
        s3.v[1] = new uint256[](2);

        s3.v[0][0] = uint256(1);
        s3.v[0][1] = uint256(2);
        s3.v[1][0] = uint256(3);
        s3.v[1][1] = uint256(4);
        vm.expectRevert();
        BaseState state3 = new BaseState(s3);
        state3=state3;


        // Should fail if length of state is 10 i.e 10x2 matrix
        BaseState.State memory s4 = BaseState.State({v: new uint256[][](10)});
        s4.v[0] = new uint256[](2);
        s4.v[1] = new uint256[](2);
        s4.v[2] = new uint256[](2);
        s4.v[3] = new uint256[](2);
        s4.v[4] = new uint256[](2);
        s4.v[5] = new uint256[](2);
        s4.v[6] = new uint256[](2);
        s4.v[7] = new uint256[](2);
        s4.v[8] = new uint256[](2);
        s4.v[9] = new uint256[](2);

        vm.expectRevert();
        BaseState state4 = new BaseState(s4);        
        state4=state4;
    }

    // Test copy state 
    function test_copyState() external {

        BaseState.State memory s1;
        // Should pass if length of state is 9 i.e 3x3 matrix
        s1 = BaseState.State({v: new uint256[][](3)});
        s1.v[0] = new uint256[](3);
        s1.v[1] = new uint256[](3);
        s1.v[2] = new uint256[](3);

        // [1, 2, 3] R0
        s1.v[0][0] = uint256(1);
        s1.v[0][1] = uint256(2);
        s1.v[0][2] = uint256(3);

        // [4, 5, 7] R1
        s1.v[1][0] = uint256(4);
        s1.v[1][1] = uint256(5);
        s1.v[1][2] = uint256(6);

        // [7, 8, 9] R2
        s1.v[2][0] = uint256(7);
        s1.v[2][1] = uint256(8);
        s1.v[2][2] = uint256(9);        

        // C0  C1 C2
        // [1, 2, 3] R0
        // [4, 5, 7] R1
        // [7, 8, 9] R2
        BaseState S1 = new BaseState(s1);        
        S1.copyState(s1);
    }

    // Test set state 
    function test_setState() external {

        BaseState.State memory s1;
        // Should pass if length of state is 9 i.e 3x3 matrix
        s1 = BaseState.State({v: new uint256[][](3)});
        s1.v[0] = new uint256[](3);
        s1.v[1] = new uint256[](3);
        s1.v[2] = new uint256[](3);

        // [1, 2, 3] R0
        s1.v[0][0] = uint256(1);
        s1.v[0][1] = uint256(2);
        s1.v[0][2] = uint256(3);

        // [4, 5, 7] R1
        s1.v[1][0] = uint256(4);
        s1.v[1][1] = uint256(5);
        s1.v[1][2] = uint256(6);

        // [7, 8, 9] R2
        s1.v[2][0] = uint256(7);
        s1.v[2][1] = uint256(8);
        s1.v[2][2] = uint256(9);        

        // C0  C1 C2
        // [1, 2, 3] R0
        // [4, 5, 7] R1
        // [7, 8, 9] R2
        BaseState S1 = new BaseState(s1);        
        S1.setState(0, 0, 1);
    }       
}