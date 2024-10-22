// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.27;

import "./BaseLevel.sol";
import "./BaseState.sol";

error WrongInterfaceId();

// Possible cell values
enum CellValueL1 { CellValue, X, O}

struct StateL1 {
	CellValueL1[9] v;
}

struct Symbols {
	uint256 u2716;
	uint256 u2717;
}

// Level defination and implementation
contract Level is BaseLevel, BaseState {

	// Unicode mapping
	Symbols public symbols;

	constructor(uint8 _levelnum, State memory _state, 
		bytes memory _symbols)
		BaseLevel(_levelnum)
		BaseState(_state) {

		// Store the symbols
		//symbols.u2716 = _symbols[0:32];
	}

	// readBoard
/*	function readCell(Cell memory c) external view returns (uint8 _cellValue) {

		_cellValue = uint8(board.v[1]);
	}
*/

	function setCellu2716 () external view {


	}

	// Inherited from BaseState - all implemented and supported states in level
    function supportedStates() 
    	public view virtual override returns (bytes memory) {

    	return abi.encode(this.setCellu2716.selector); 
    }

}
