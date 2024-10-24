// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.27;

// Possible cell values
enum CellValue { Empty }

// Base State
abstract contract BaseState {

	//		C0  C1  ..  Cn
	// R0 | _ | _ | _ | _ | 
	// R1 | _ | _ | _ | _ |
	// .. |   |   |   |	  |
	// Rn | _ | _ | _ | _ |

	struct State {
		//uint8 v;
		uint8[][] v;
	}

	// State
	State state;

	constructor(State memory _state) {
	
		state = _state;
	}

	// Updates the base state data to the callers
	// context when delegated
	function copyState() public virtual returns(bytes memory id) {
		state = state;

		assembly {
			id := state.slot
		}		
	}

	// To be overriden by level
    function supportedStates() 
    	public view virtual returns (bytes memory) {
	}
}
