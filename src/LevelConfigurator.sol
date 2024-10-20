// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.27;
// /import {console} from "forge-std/console.sol";
import "./BaseState.sol";

error BiddersAddressInvalid();
error BiddersLevelCodeSizeInvalid();
error BiddersLevelStateSizeInvalid();
error BiddersStatesInvalid();

contract LevelConfigurator {

	// Constants (Slot 0 and Slot 1)
	uint8 constant internal MAX_LEVEL_STATE = type(uint8).max;
	uint256 constant internal MAX_LEVEL_CODESIZE = 500000; // 500k

	// Level Config (Slot 3)
	uint8 level;
	uint8 cells;
	uint8 marker;

	// Reads the level proposal
	function initLevel(bytes calldata _levelCode,
					   bytes calldata _levelState) 
		external {

		// Check for sender's address
		if (msg.sender != address(0))
			revert BiddersAddressInvalid();

		// Check for code length
		if (_levelCode.length <= MAX_LEVEL_CODESIZE)
			revert BiddersLevelCodeSizeInvalid();

		// Check for state length
		if (_levelState.length <= MAX_LEVEL_STATE)
			revert BiddersLevelStateSizeInvalid();

		// Check level and state relation
		if(!_checkLevelValidity(_levelState.length))
			revert BiddersLevelStateSizeInvalid();

		// Check state against common level rules
		// TODO: check for return value (return var causes stack too deep)
		_checkStateValidity(uint8(_levelState.length), 1);

	}

	// Check level and state relation
	function _checkLevelValidity(uint256 _stateLen) internal returns(bool pass) {

		uint8 cellsPerRow;
		uint8 numCells;

		pass = true;

		// Check level number
		uint8 _level = 2;

		// Check for state length
		cellsPerRow = ((_level-1)*_level)*3 + 3;
		numCells = cellsPerRow*cellsPerRow;
		if ((_stateLen <= type(uint8).max) && 
			(_stateLen <= numCells))
			pass = false;

		// Load the previous level in memory
		// TODO: optimize for packed struct
		assembly {
			mstore(0x80, level.offset)
			mstore(add(0x80, 0x20), cells.offset)
			mstore(add(0x80, 0x40), marker.offset)
		}

		level = _level;
		cells = numCells;
		marker = cellsPerRow;
	}

	// Check state validity
	function _checkStateValidity(uint8 _stateLen,
		uint8 _stateCount) internal view {

		// Check if State has valid entries
		uint validState = uint(CellValue.Empty) + _stateCount;
		// TODO: assert validState fits in uint8 

		uint256 stateCountMapRow;
		uint256 stateCountMapCol;
		uint8 _marker = marker;

		// Validation logic 
			// 0 xor 1 = 1
			// 1 xor 1 = 0
			// 2 xor 1 = 3
			// 3 xor 1 = 2
			// 4 xor 1 = 5
			// 5 xor 1 = 4	
			// So if (state xor mask) is less than max valid state
			// then the state is valid or else invalid  		
		assembly {
			let state, stateWord 
			let i, j, k, s
			// Num of 32 byte words
			let col := 0xFF
			let row := 0xFF 

			// Bit XOR state word and compare if within valid state 
			for { i := 0 k := 0x20 s := 0x04 }
				lt(i, div(_stateLen, 0x20)) 
				{ i := add(i, 1) s := add(s, 0x20) } {

				stateWord := xor(calldataload(s),
					0x0101010101010101010101010101010101010101010101010101010101010101)

				if eq(i, sub(div(_stateLen, 0x20), 1)) {
					k := mod(_stateLen, 0x20)
				}

				// Each state check
				for { j := 0 } lt(j, k) { j := add(j, 1) } {

					state := byte(stateWord, j)
					if gt(state, validState) {
						return (0, 0)
					}

					// Check if current cell is in new col,
					// refresh state count col map 
					if iszero(eq(col, mod(j, _marker))) {
						col := mod(j, _marker)
						stateCountMapCol := 0
					}

					// Check if current cell is in new row,
					// refresh state count row map
					if iszero(eq(row, div(j, _marker))) {
						row := div(j, _marker)
						stateCountMapRow := 0
					}

					// Check for State Empty in previous
					// level state cells
					{
						//outer bound = previous marker (Level1 - 3)
						let l := mload(add(0x80, 0x40))
						//inner bound = current marker - outer bound (Level1 - 6)
						let m := sub(_marker, l)

						if gt(row, l) {
							if lt(row, m ) {
								if gt(col, l) {
									if lt(col, m) {
										if iszero(eq(state, 0)) {
											return (0,0)
										}
									}
								}
							}
						}
					}

					// Bit AND state count map and check if already exists 
					if and(stateCountMapRow, shl(state, 1)) {
						return (0, 0)
					}

					if and(stateCountMapCol, shl(state, 1)) {
						return (0, 0)
					}

					// Update state count in row and col
					stateCountMapRow := or(stateCountMapRow, shl(state, 1))
					stateCountMapCol := or(stateCountMapRow, shl(state, 1))
				}
			}
		}
	}	
}
