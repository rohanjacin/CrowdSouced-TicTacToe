// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.27;

import "forge-std/Test.sol";
import "src/Level1.sol";

contract TestLevel1 is Test {
    Level1 level;

    function setUp() public {
        //BaseLevel.Cell memory testCell = BaseLevel.Cell({v: 1});
        //LcellBaseLevel.Cell(1);
/*        level = new Level(1, StateL1({
            v: [CellValueL1.X, CellValueL1.X, CellValueL1.X,
                CellValueL1.X, CellValueL1.CellValue, CellValueL1.X,
                CellValueL1.X, CellValueL1.X, CellValueL1.X]}));
*/    }

/*    function test_readCell() external view {
        console.log("Test read cell");

        //Cell memory testCell = Cell({row:1, col:1});
        assertEq(level.readCell(), uint8(CellValueL1.X), "value mistmatch");

    }*/
}

//0x00000000000000000000000000000000000000000000000000000000e7783a66