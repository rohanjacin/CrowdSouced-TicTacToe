// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.27;

import "forge-std/console.sol";

// Basic symbol layout
contract BaseSymbol {

	// Symbols (unicode 4 bytes max)
	struct Symbols {
		bytes32[] v;
	}

	// Unicode mapping
	Symbols symbols;

	constructor(Symbols memory _symbols) {

		// dimension=1, offset=0xa0
		// length=4@0xa0
		// values=1@0xc0, 2@0xe0, 3@0x100, 4@0x120 
/*
[0x80:0xa0]: 0x00000000000000000000000000000000000000000000000000000000000000a0
[0xa0:0xc0]: 0x0000000000000000000000000000000000000000000000000000000000000004
[0xc0:0xe0]: 0x01f4a30000000000000000000000000000000000000000000000000000000000
[0xe0:0x100]: 0x274c000000000000000000000000000000000000000000000000000000000000
[0x100:0x120]: 0x2b50000000000000000000000000000000000000000000000000000000000000
[0x120:0x140]: 0x2b55000000000000000000000000000000000000000000000000000000000000
*/	

		// Check if number of symbols is as expected, assuming
		// _symbols is unpacked as follow
		// i.e number of symbols < 255
		assembly {
/*			// Fetch dimension
			let ptr := mload(_symbols)
			let len := mload(ptr)

			// Revert if length is greater than 255 or is 0
			if iszero(len) {
				revert (0, 0)
			}

			if gt(len, 255) {
				revert (0, 0)
			}

			// Check if all symbols are present in memory
			let end := add(ptr, mul(len, 0x20))
			if lt(mload(0x40), end) {
				revert (0, 0)
			}
*/		}
	}

	// Updates the base symbol data to the callers
	// context when delegated
	function copySymbol(Symbols memory _symbols) public virtual returns(bool success) {
		//symbols = symbols; 

		assembly {
			// Fetch dimension
			let ptr := mload(_symbols)
			let len := mload(ptr)

			// Revert if length is greater than 255 or is 0
			if iszero(len) {
				revert (0, 0)
			}

			if gt(len, 255) {
				revert (0, 0)
			}

			// Check if all symbols are present in memory
			let end := add(ptr, mul(len, 0x20))
			if lt(mload(0x40), end) {
				revert (0, 0)
			}

			ptr := add(ptr, 0x20)

			for { let i := 0 let v := 0 let s := 0 let p := 0 } 
				lt(i, len) { i := add(i, 1) } {
				
				 // Calculate the slot and store
				 v := mload(add(ptr, mul(i, 0x20)))
				 p := mload(0x40)
				 mstore(p, symbols.slot)
				 s := add(keccak256(p, add(p, 0x20)), i)
				 sstore(s, v)
			}
		}
	}
}
