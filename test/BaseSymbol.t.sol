// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.27;

import "forge-std/Test.sol";
import { BaseSymbol } from "src/BaseSymbol.sol";

contract TestBaseSymbol is Test {

    function setUp() public {
        //BaseSymbol.Symbols memory _symbol;
        //baseSymbol = new BaseSymbol(_symbol);
    }

    // Test state
    function test_symbols() external {

        // Should pass if length of symbols is 1
        BaseSymbol.Symbols memory s1 = BaseSymbol.Symbols({v: new bytes32[](1)});

        // [0x274c000000000000000000000000000000000000000000000000000000000000] R0
        s1.v[0] = bytes32(hex"274C");

        // C0  
        // [0x274c000000000000000000000000000000000000000000000000000000000000] R0
        BaseSymbol symbol1 = new BaseSymbol(s1);
        symbol1=symbol1;


        // Should pass if length of symbols is 255
        BaseSymbol.Symbols memory s2 = BaseSymbol.Symbols({v: new bytes32[](255)});

        // [0x274c000000000000000000000000000000000000000000000000000000000000] R254
        s2.v[254] = bytes32(hex"274C");

        // C0  
        // [0x274c000000000000000000000000000000000000000000000000000000000000] R254
        BaseSymbol symbol2 = new BaseSymbol(s2);
        symbol2=symbol2;


        // Should fail if length of symbols > 255
        BaseSymbol.Symbols memory s3 = BaseSymbol.Symbols({v: new bytes32[](256)});

        // [0x274c000000000000000000000000000000000000000000000000000000000000] R255
        s3.v[255] = bytes32(hex"274C");

        // C0  
        // [0x274c000000000000000000000000000000000000000000000000000000000000] R255
        vm.expectRevert();
        BaseSymbol symbol3 = new BaseSymbol(s3);
        symbol3=symbol3;
    }

    // Test copy symbols 
    function test_copySymbol() external {

        // Should pass if length of symbols is 4
        BaseSymbol.Symbols memory s1;
        s1 = BaseSymbol.Symbols({v: new bytes32[](4)});
        s1.v[0] = bytes32(hex"274C");
        s1.v[1] = bytes32(hex"2B55");
        s1.v[2] = bytes32(hex"2B50");
        s1.v[3] = bytes32(hex"01F4A3");

        // C0
        // [0x274c000000000000000000000000000000000000000000000000000000000000] R0
        // [0x2b55000000000000000000000000000000000000000000000000000000000000] R1
        // [0x2b50000000000000000000000000000000000000000000000000000000000000] R2
        // [0x01f4a300000000000000000000000000000000000000000000000000000000000] R3

        BaseSymbol S1 = new BaseSymbol(s1);        
        S1.copySymbol(s1);


        // Should fail if length of symbols is 256
        BaseSymbol.Symbols memory s2;
        s2 = BaseSymbol.Symbols({v: new bytes32[](256)});
        s2.v[252] = bytes32(hex"274C");
        s2.v[253] = bytes32(hex"2B55");
        s2.v[254] = bytes32(hex"2B50");
        s2.v[255] = bytes32(hex"01F4A3");

        // C0
        // [0x274c000000000000000000000000000000000000000000000000000000000000] R252
        // [0x2b55000000000000000000000000000000000000000000000000000000000000] R253
        // [0x2b50000000000000000000000000000000000000000000000000000000000000] R254
        // [0x01f4a300000000000000000000000000000000000000000000000000000000000] R255

        //BaseSymbol S2 = new BaseSymbol(s2);
        vm.expectRevert();
        S1.copySymbol(s2);
    }   
}