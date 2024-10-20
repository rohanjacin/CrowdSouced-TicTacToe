// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.27;

import "./BaseLevel.sol";
import "./BaseState.sol";

// Possible cell values
enum CellValueL1 { CellValue, X, O}

struct StateL1 {
	CellValueL1[9] v;
}

// Level defination and implementation
contract Level is BaseLevel, BaseState {

	// Level value
	uint8 public levelnum;

	// Unicode mapping
	mapping (CellValueL1 => bytes8) symbols;

	// Board State
	StateL1 board;

	constructor(uint8 _levelnum, StateL1 memory _board) {
		levelnum = _levelnum;
		board = _board;
		symbols[CellValueL1.X] = "u2716"; 
		symbols[CellValueL1.O] = "u0030"; 

		//board.v = uint8[](_board.v.length);
	}

	// readBoard
	function readCell(/*Cell memory c*/) external view returns (uint8 _cellValue) {

		_cellValue = uint8(board.v[1]);
	}

	function setCellu2716 () external view {

	}

}
