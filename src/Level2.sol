// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.27;

import "./BaseLevel.sol";
import "./BaseState.sol";
import "./BaseSymbol.sol";
import "./Level1.sol";

// Level defination and implementation
contract Level2 is BaseLevel, BaseState, BaseSymbol {

	constructor(bytes memory _levelnum, State memory _state, 
		Symbols memory _symbols)
		BaseLevel(_levelnum)
		BaseState(_state)
		BaseSymbol(_symbols) {

		assembly {
			// Fetch dimension of state
			let ptr := mload(_state)
			let len := mload(ptr)
			let d, s

			switch _levelnum
			case 2 { d := 9 s := 4 }
			default {
				revert(0, 0)
			}

			// Check state length for level
			if iszero(eq(len, d)) {
				revert (0, 0)
			}

			ptr := mload(_symbols)
			len := mload(ptr)

			// Check symbol length for level
			if iszero(eq(len, s)) {
				revert (0, 0)
			}
		}
	}

	// Inhertied from ILevel Loads Level 2
	function copyLevelData() public returns(bytes memory id){
		
		// Update Base Level
		// Update Base State
		// Update Base Symbol
/*		id = abi.encodePacked(
					super.copyLevel(),
					super.copyState(),
					super.copySymbol());

*/	}

	// ⭐
	function setCellue2ad9000(uint8 row, uint8 col, uint8 value) external {
		board.v[row][col] = value;
	}
	
	// 💣
	function setCelluf09f92a3(uint8 row, uint8 col, uint8 value) external {
		board.v[row][col] = value;
	}

	// Inherited from BaseState - all implemented and supported states in level
    function supportedStates() public view override returns (bytes memory) {

    	return abi.encodePacked(bytes4(this.setCellue2ad9000.selector),  // ⭐
    							bytes4(this.setCelluf09f92a3.selector)); // 💣
    }
}