// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.27;

import "forge-std/Test.sol";

import "src/LevelConfigurator.sol";

contract TestLevelConfigurator is Test {
    LevelConfigurator levelConfig;

    function setUp() public {
        //levelConfig = new LevelConfigurator();
    }

/*    function test_initLevel() external {

        uint8[4] memory _levelcode = [0xe7, 0x78, 0x3a, 0x66];
        uint8[4] memory _levelstate = [0x01, 0x01, 0x01, 0x01];

        bytes memory data = abi.encode(_levelcode);
        bytes memory data1 = abi.encode(_levelstate);

        //levelConfig.initLevel(data, data1);
    }*/
}