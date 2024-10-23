// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.27;

import "./Level1.sol";

// Possible cell values
enum CellValueL2 { CellValueL1, Star, Bomb}

// Level defination and implementation
contract Level2 is Level1 {

	constructor(uint8 _levelnum, State memory _state, 
		Symbols memory _symbols)
		Level1(_levelnum, _state, _symbols) {
	}

	// ⭐
	function setCellu2B50() external view {

	}
	
	// 💣
	function setCellu1F4A3() external view {

	}

	// Inherited from BaseState - all implemented and supported states in level
    function supportedStates() 
    	public view virtual override returns (bytes memory) {

    	return abi.encode(this.setCellu2B50.selector); 
    }

}