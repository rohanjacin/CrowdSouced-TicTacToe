// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.27;

import "./BaseLevel.sol";
import "./BaseState.sol";
import "./BaseSymbol.sol";
import "./Level1.sol";

// Possible cell values
enum CellValueL2 { CellValueL1, Star, Bomb}

// Level defination and implementation
contract Level2 is BaseLevel, BaseState, BaseSymbol {

	constructor(uint8 _levelnum, State memory _state, 
		Symbols memory _symbols)
		BaseLevel(_levelnum)
		BaseState(_state)
		BaseSymbol(_symbols) {
	}

	// Inhertied from ILevel Loads Level 2
	function copyLevel() public override returns(bytes memory id){
		
		// Update Base Level
		// Update Base State
		// Update Base Symbol
		id = abi.encodePacked(
					super.copyLevel(),
					super.copyState(),
					super.copySymbol());

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