// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.27;
import "forge-std/console.sol";

// Possible cell values
enum CellValue { Empty }

// Base State
contract BaseState {

	//		C0  C1  ..  Cn
	// R0 | _ | _ | _ | _ | 
	// R1 | _ | _ | _ | _ |
	// .. |   |   |   |	  |
	// Rn | _ | _ | _ | _ |

	struct State {
		uint256[][] v;
	}

	// State (Slot1)
	State state;

	constructor(State memory _state) {

		// Check if length is as expected, assuming
		// _state is unpacked as follow
		// dimension=3, offsets=120,1a0,220
		// lenghts=3@0x120,3@1a0,3@220
		// values=1@0x140, 2@0x160, 3@0x180
		//        4@0x1c0, 5@0x1e0, 6@0x200
		//        7@0x240, 8@0x260, 9@0x280 
/*
[0x80:0xa0]: 0x00000000000000000000000000000000000000000000000000000000000000a0
[0xa0:0xc0]: 0x0000000000000000000000000000000000000000000000000000000000000003
[0xc0:0xe0]: 0x0000000000000000000000000000000000000000000000000000000000000120
[0xe0:0x100]: 0x00000000000000000000000000000000000000000000000000000000000001a0
[0x100:0x120]: 0x0000000000000000000000000000000000000000000000000000000000000220
[0x120:0x140]: 0x0000000000000000000000000000000000000000000000000000000000000003
[0x140:0x160]: 0x0000000000000000000000000000000000000000000000000000000000000001
[0x160:0x180]: 0x0000000000000000000000000000000000000000000000000000000000000002
[0x180:0x1a0]: 0x0000000000000000000000000000000000000000000000000000000000000003
[0x1a0:0x1c0]: 0x0000000000000000000000000000000000000000000000000000000000000003
[0x1c0:0x1e0]: 0x0000000000000000000000000000000000000000000000000000000000000004
[0x1e0:0x200]: 0x0000000000000000000000000000000000000000000000000000000000000005
[0x200:0x220]: 0x0000000000000000000000000000000000000000000000000000000000000006
[0x220:0x240]: 0x0000000000000000000000000000000000000000000000000000000000000003
[0x240:0x260]: 0x0000000000000000000000000000000000000000000000000000000000000007
[0x260:0x280]: 0x0000000000000000000000000000000000000000000000000000000000000008
[0x280:0x2a0]: 0x0000000000000000000000000000000000000000000000000000000000000009
*/		
		assembly {
			let d
			// Fetch dimension
			let ptr := mload(_state)
			let len := mload(ptr)

			// Revert if length is not 9 for Level 1
			// Revert if length is not 81 for Level 2
			switch len
			case 3 { d := 3 }
			case 9 { d := 9 }
			default {
				revert(0, 0)
			}

			ptr := add(ptr, 0x20)

			// Find length of next 3 arrays
			// and compare with dimension,
			// all should be 3 
			for { let i := 0 } lt(i, 1) { i := add(i, 1) } {

				ptr := mload(add(ptr, mul(i, 0x20)))			
				len := mload(ptr)
				if iszero(eq(len, d)) {
					revert (0, 0)
				}
			}
		}
	}

	// Updates the base state data to the callers
	// context when delegated
	function copyState(State memory _state) public virtual returns(bool success) {
		//state = state; 

		assembly {
			let d
			// Fetch dimension
			let ptr := mload(_state)
			let len := mload(ptr)

			// Revert if length is not 9 for Level 1
			// Revert if length is not 81 for Level 2
			switch len
			case 3 { d := 3 }
			case 9 { d := 9 }
			default {
				revert(0, 0)
			}

			ptr := add(ptr, 0x20)

			// Find length of next 3 arrays
			// and compare with dimension,
			// all should be 3 
			for { let i := 0 } lt(i, 1) { i := add(i, 1) } {

				ptr := mload(add(ptr, mul(i, 0x20)))			
				len := mload(ptr)
				if iszero(eq(len, d)) {
					revert (0, 0)
				}

				ptr := add(ptr, 0x20)

				for { let j := 0 let v := 0 let s := 0 let p := 0 } 
					lt(j, len) { j := add(j, 1) } {

					 // Calculate the slot and store					
					 v := mload(add(ptr, mul(j, 0x20)))
					 p := mload(0x40)
					 mstore(p, state.slot)
					 mstore(mload(0x40), add(keccak256(p, add(p, 0x20)), i))
					 p := mload(0x40)
					 s := add(keccak256(p, add(p, 0x20)), j)
					 sstore(s, v)
				}
			}
		}
	}

	function getstate() public view {

	}

	// To be overriden by level
    function supportedStates() 
    	public view virtual returns (bytes memory) {
	}
}
