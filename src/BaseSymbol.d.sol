// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.27;

import "forge-std/console.sol";

// Basic symbol layout
contract BaseSymbolD {

	// Symbols (unicode 4 bytes max)
	struct Symbols {
		bytes32[] v;
	}

	// Unicode mapping
	Symbols symbols;

	// Updates the base symbol data to the callers
	// context when delegated
	function copySymbol(Symbols memory _symbols) public virtual returns(bool success) {
		//symbols = symbols; 
		success=success;
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
