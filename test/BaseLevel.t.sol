// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.27;

import "forge-std/Test.sol";
import "src/BaseLevel.sol";

contract TestBaseLevel is Test {
    BaseLevel baseLevel;

    function setUp() public {
        baseLevel = new BaseLevel(1);
    }

    // Test level number
    function test_levelnum() external {

        // Should return 1 for Level 1
        BaseLevel level1 = new BaseLevel(1);
        assertEq(level1.levelnum(), 1);

        // Should return 2 for Level 2
        BaseLevel level2 = new BaseLevel(2);
        assertEq(level2.levelnum(), 2);

        // Should revert for Level 2 and above
        vm.expectRevert(InvalidLevelNumber.selector);
        BaseLevel level3 = new BaseLevel(3);
        level3 = level3;
    }

    // Test copy level
    function test_copyLevel() external {

        // Should copy level num "1" to levelnum slot
        BaseLevel level1 = new BaseLevel(1);
        bytes memory data1 = abi.encodePacked(uint8(1));
        assertTrue(level1.copyLevel(data1));
        assertEq(level1.levelnum(), 1);

        // Should copy level num "2" to levelnum slot
        BaseLevel level2 = new BaseLevel(2);
        bytes memory data2 = abi.encodePacked(uint8(2));
        assertTrue(level2.copyLevel(data2));
        assertEq(level2.levelnum(), 2);

        // Should fail to copy level if level is > 2 
        BaseLevel level3 = new BaseLevel(2);
        bytes memory data3 = abi.encodePacked(uint8(3));
        vm.expectRevert();
        level3.copyLevel(data3);
    }
}