// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.27;
import "forge-std/console.sol";

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
	State board;

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
			let off

			// Revert if length is not 9 for Level 1
			// Revert if length is not 81 for Level 2
			switch len
			case 3 { d := 3 }
			case 9 { d := 9 }
			default {
				revert(0, 0)
			}

			// Find length of next 3 arrays
			// and compare with dimension,
			// all should be 3 
			for { let i := 0 off := add(ptr, 0x20) }
				lt(i, d) 
				{ i := add(i, 1) off := add(off, 0x20) } {

				ptr := mload(off)			
				len := mload(ptr)
				if iszero(eq(len, d)) {
					revert (0, 0)
				}

				ptr := add(ptr, 0x20)

				for { let j := 0 let v := 0 let s := 0 let p := 0 let q := 0 } 
					lt(j, len) { j := add(j, 1) } {

					 // Calculate the slot and store					
					 v := mload(add(ptr, mul(j, 0x20)))
					 p := mload(0x40)
					 mstore(p, board.slot)
					 q := mload(0x40)
					 mstore(q, add(keccak256(p, 0x20), i))
					 s := add(keccak256(q, 0x20), j)
					 sstore(s, v)
				}
			}
		}
	}

	// Updates the base state data to the callers
	// context when delegated
	function copyState(State memory _state) public virtual returns(bool success) {
		uint256 len;
		uint256 v;
		uint256 s;
		assembly {
			let d
			// Fetch dimension
			let ptr := add(_state, 0x20)
			len := mload(ptr)

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
			for { let i := 0 let ptr1} lt(i, d) { i := add(i, 1) } {

				ptr1 := mload(add(ptr, mul(i, 0x20)))
				len := mload(ptr1)			

				if iszero(eq(len, d)) {
					revert (0, 0)
				}

				ptr1 := add(ptr1, 0x20)

				// TODO: Check if all state are present in memory

				for { let j := 0 v := 0 s := 0 let p := 0 let q := 0 } 
					lt(j, d) { j := add(j, 1) } {

					 // Calculate the slot and store					
					 v := mload(add(ptr1, mul(j, 0x20)))
					 p := mload(0x40)
					 mstore(p, board.slot)
					 mstore(0x40, add(p, 0x20))

					 q := mload(0x40)
					 mstore(q, add(keccak256(p, 0x20), i))
					 mstore(0x40, add(q, 0x20))

					 s := add(keccak256(q, 0x20), j)
					 sstore(s, v)
				}
			}
		}
		success = true;
	}


    function getState(uint8 row, uint8 col) internal view returns (uint256 val) {

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, board.slot)
            mstore(0x40, add(ptr, 0x20))
            let ptr1 := mload(0x40)
            mstore(ptr1, add(keccak256(ptr, 0x20), row))
            mstore(0x40, add(ptr1, 0x20))
            let s := add(keccak256(ptr1, 0x20), col)
			val := sload(s)
        }
    }

    function setState(uint8 row, uint8 col, uint8 val) public virtual {

        assembly {
			 // Calculate the slot and store					
			 let p := mload(0x40)
			 mstore(p, board.slot)
			 mstore(0x40, add(p, 0x20))

			 let q := mload(0x40)
			 mstore(q, add(keccak256(p, 0x20), row))
			 mstore(0x40, add(q, 0x20))

			 let s := add(keccak256(q, 0x20), col)
			 sstore(s, val)
        }
    }
	// To be overriden by level
    function supportedStates() public view virtual returns (bytes memory) {
	}
}
