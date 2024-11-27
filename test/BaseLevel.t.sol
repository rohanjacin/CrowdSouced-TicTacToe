// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.27;

import "forge-std/Test.sol";
import "src/BaseLevel.sol";

contract TestBaseLevel is Test {
    BaseLevel baseLevel;

    function setUp() public {
        //baseLevel = new BaseLevel(1);
    }

    function _setLevelNum(uint8 _num) internal pure 
        returns (bytes memory _levelNum) {

        _levelNum = abi.encodePacked(_num);
    }    

    // Test level number
    function test_levelnum() external {

        // Should return 1 for Level 1
        BaseLevel level1 = new BaseLevel(_setLevelNum(1));
        assertEq(level1.level(), 1);

/*        // Should return 2 for Level 2
        BaseLevel level2 = new BaseLevel(_setLevelNum(2));
        assertEq(level2.level(), 2);

        // Should revert for Level 2 and above
        vm.expectRevert();
        BaseLevel level3 = new BaseLevel(_setLevelNum(3));
        level3 = level3;
*/    }

    // Test copy level (change copyLevel in BaseLevel.sol to external for test to run)
    function test_copyLevel() external {

/*        // Should copy level num "1" to levelnum slot
        BaseLevel level1 = new BaseLevel(_setLevelNum(1));
        bytes memory data1 = abi.encodePacked(uint8(2));
        assertTrue(level1.copyLevel(data1));
        assertEq(level1.level(), 2);

        // Should copy level num "2" to levelnum slot
        BaseLevel level2 = new BaseLevel(_setLevelNum(2));
        bytes memory data2 = abi.encodePacked(uint8(1));
        assertTrue(level2.copyLevel(data2));
        assertEq(level2.level(), 1);

        // Should fail to copy level if level is > 2 
        BaseLevel level3 = new BaseLevel(_setLevelNum(1));
        bytes memory data3 = abi.encodePacked(uint8(3));
        vm.expectRevert();
        level3.copyLevel(data3);*/
    }
}