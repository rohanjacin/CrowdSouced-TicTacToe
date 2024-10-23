// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.27;

import "./BaseLevel.sol";
import "./BaseState.sol";
import "./BaseSymbol.sol";

// Possible cell values
enum CellValueL1 { CellValue , X, O}

// Level defination and implementation
contract Level1 is BaseLevel, BaseState, BaseSymbol {

	constructor(uint8 _levelnum, State memory _state, 
		Symbols memory _symbols)
		BaseLevel(_levelnum)
		BaseState(_state)
		BaseSymbol(_symbols) {
	}

	// Inhertied from ILevel Loads Level 1
	function copyLevel() external override returns(bool success) {
		
		//BaseLevel(levelnum);
	}

	// ❌
	function setCellu274C() external view {

	}
	
	// ⭕
	function setCellu2B55() external view {

	}

	// Inherited from BaseState - all implemented and supported states in level
    function supportedStates() 
    	public view virtual override returns (bytes memory) {

    	return abi.encode(this.setCellu274C.selector); 
    }

}
