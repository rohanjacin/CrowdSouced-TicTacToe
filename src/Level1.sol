// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.27;

import "./BaseLevel.sol";
import "./BaseState.sol";
import "./BaseSymbol.sol";
import "./BaseSnap.sol";

// Possible cell values
enum CellValueL1 { CellValue , X, O}

// Level defination and implementation
contract Level1 is BaseLevel, BaseState, BaseSymbol, BaseSnap {

	constructor(uint8 _levelnum, State memory _state, 
		Symbols memory _symbols)
		BaseLevel(_levelnum)
		BaseState(_state)
		BaseSymbol(_symbols)
		BaseSnap() {
	}

	// Inhertied from ILevel Loads Level 1
	function copyLevelData() public returns(bool success){
		
		// Update Data Snapshot to caller's context
		(bool ret, bytes memory data) = dataSnapAddr.call("");
		ret = ret;
		data = data;
/*		id = abi.encodePacked(
					super.copyLevel(),
					super.copyState(),
					super.copySymbol());
*/
		success = true;
	}

	// ❌ ⍰
	function setCellu274C() external view {

	}
	
	// ⭕
	function setCellu2B55() external view {

	}

	// Inherited from BaseState - all implemented and supported states in level
/*    function supportedStates() 
    	public view virtual override returns (bytes memory) {

    	return abi.encode(this.setCellu274C.selector); 
    }*/

}
