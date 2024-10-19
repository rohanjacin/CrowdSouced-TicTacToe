// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.27;

import "forge-std/Test.sol";

import "src/LevelConfigurator.sol";

contract TestLevelConfigurator is Test {
    LevelConfigurator levelConfig;

    function setUp() public {
        levelConfig = new LevelConfigurator();
    }

    function test_initLevel() external view {
        console.log("Test init level");


        uint32[1] memory sample = 
                [0xe7783a66];

        assertEq(levelConfig.initLevel(sample), 
            0x00000000000000000000000000000000000000000000000000000000e7783a66, "value mistmatch");
    }
}

//0x00000000000000000000000000000000000000000000000000000000e7783a66