// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.27;
import {console} from "forge-std/console.sol";
import "./BaseState.sol";

error BiddersAddressInvalid();
error BiddersLevelCodeSizeInvalid();
error BiddersLevelStateSizeInvalid();
error BiddersStatesInvalid();

contract LevelConfigurator {

	// Constants (Slot 0 and Slot 1)
	uint8 constant internal MAX_LEVEL_STATE = type(uint8).max;
	uint256 constant internal MAX_LEVEL_CODESIZE = 500000; // 500k

	// Level Config (Slot 2, 3 and 4)
	uint8 levelStateLen;
	uint256 levelCodeLen;
	bytes32 levelCodePtr;

	// Level Config (Slot 4)
	uint8 level;
	uint8 cells;
	uint8 marker;

	// Reads the level proposal
	function initLevel(bytes[] calldata _levelCode,
					   bytes[] calldata _levelState) 
		external returns (bool status){

		// Check for sender's address
		if (msg.sender != address(0))
			revert BiddersAddressInvalid();

		// Check for code length
		if (_levelCode.length <= MAX_LEVEL_CODESIZE)
			revert BiddersLevelCodeSizeInvalid();
		levelCodeLen = _levelCode.length;

		// Check for state length
		if (_levelState.length <= MAX_LEVEL_STATE)
			revert BiddersLevelStateSizeInvalid();
		levelStateLen = uint8(_levelState.length);

		// Check level and state relation
		if(!_checkLevelValidity(_levelState.length))
			revert BiddersLevelStateSizeInvalid();

		// Store level code and state to memory
		uint256 _levelCodeLen = levelCodeLen;
		bytes32 _levelCodePtr;

		assembly {
			_levelCodePtr := 0x80
			//_levelCodePtr := msize() //cannot use msize() if yul optimizer is enabled
			calldatacopy(_levelCodePtr, 0x04, _levelCodeLen)
		}
	}

	// Performs further validity checks on Level
	function checkLevel() external returns (bool status) {
		// Check state validity and rules
		if (!_checkStateValidity(levelCodeLen,
			levelStateLen, uint8(1)))
			revert BiddersStatesInvalid();

		// Store the level code and the 
		// level state in memory
/*		assembly {
			// Fetch memory pointer
			let ptr := mload(0x40)
			calldatacopy(ptr, 0x04, 
				add(_levelCode.length, _levelState.length))
		}
*/
		// 		
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

		level = _level;
		cells = numCells;
		marker = cellsPerRow;
	}

	// Check state validity
	function _checkStateValidity(uint256 _codeLen, uint8 _stateLen,
		uint8 _stateCount) internal view returns(bool pass) {

		pass = true;
		// Check if State has valid entries
		uint validState = uint(CellValue.Empty) + _stateCount;
		// TODO: assert validState fits in uint8 

		uint256 stateCountMapRow;
		uint256 stateCountMapCol;
		uint8 _cells = cells;
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
			let word, stateWord 
			let mask := 0x0101010101010101010101010101010101010101010101010101010101010101

			let offset := _codeLen
			let size := _stateLen
			
			// Num of 32 byte words
			let num := div(size, 0x20)
			let col := 0xFF
			let row := 0xFF 

			// Bit XOR state word and compare if within valid state 
			for { let i := 0 let k := 0x20 let s := 0x04 }
				lt(i, num) 
				{ i := add(i, 1) s := add(s, 0x20) } {

				word := calldataload(s)
				stateWord := xor(word, mask)

				if eq(i, sub(num, 1)) {
					k := mod(size, 0x20)
				}

				// Each state check
				for { let j := 0 } lt(j, k) { j := add(j, 1) } {

					let state := byte(stateWord, j)
					if gt(state, validState) {
						pass := 0
						return (0, 0)
					}

					// Check if current cell is in new col,
					// refresh state count col map 
					let _newCol := mod(j, _marker)
					if iszero(eq(col, _newCol)) {
						col := mod(j, _marker)
						stateCountMapCol := 0
					}

					// Check if current cell is in new row,
					// refresh state count row map
					let _newRow := div(j, _marker)
					if iszero(eq(row, _newRow)) {
						row := div(j, _marker)
						stateCountMapRow := 0
					}

					// Bit AND state count map and check if already exists 
					if and(stateCountMapRow, shl(state, 1)) {
						pass := 0
						return (0, 0)
					}

					if and(stateCountMapCol, shl(state, 1)) {
						pass := 0
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
