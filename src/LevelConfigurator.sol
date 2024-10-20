// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.27;
import {console} from "forge-std/console.sol";
import "./BaseState.sol";
import "./IGoV.sol";

error BiddersAddressInvalid();
error BiddersLevelCodeSizeInvalid();
error BiddersLevelStateSizeInvalid();
error BiddersStatesInvalid();

contract LevelConfigurator {

	// Constants (Slot 0, 1 and 2)
	address constant internal GOV_ADDRESS = address(
		0x5FbDB2315678afecb367f032d93F642f64180aa3);
	uint8 constant internal MAX_LEVEL_STATE = type(uint8).max;
	uint256 constant internal MAX_LEVEL_CODESIZE = 500000; // 500k

	// Level Config (Slot 3)
	uint8 level;
	uint8 cells;
	uint8 marker;

	// Reads the level proposal
	function initLevel(bytes calldata _levelCode,
					   bytes calldata _levelState) 
		external returns(bool success) {

		success = false;
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

		// Store level code and state
		uint256 levelLoc = _loadLevel(_levelCode.length, 
							uint8(_levelState.length));

		// Call GoV contract to approve level
		// with level memory location
		address addr = GOV_ADDRESS;
		assembly {
			if iszero(extcodesize(addr)) {
				revert(0, 0)
			}
		}

		IGoV(addr).approveValidLevelProposal(levelLoc);
		success = true;
	}

	// Deploys the level
	function deployLevel(uint256 levelLoc, uint256 salt) 
		external payable returns(address target) {

		// Deploy using create2
		assembly {

			// level code length is 2 memory location 
			target := create2(0, levelLoc, mload(
				add(levelLoc, 0x20)), salt)
		}
	}

	// Add level rules to rule base
	function _addLevelRules() internal returns(bool success) {

		//
	}

	// Load level code and state in memory 
	function _loadLevel(uint256 codeLen, uint8 stateLen)
		internal pure returns (uint256 location) {

		// 0x80 |-----level------|
		// 0xA0 |-----cells------|
		// 0xC0 |-----marker-----|
		// 0xD0 |---levelcode----|
		// 0x__ |---levelstate---|

		// Store level code and state
		location = uint256(0xD0);
		assembly {
			calldatacopy(location, 0x04, codeLen)
			calldatacopy(add(location, codeLen), 
				add(0x04, codeLen), stateLen)
		}
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
			mstore(0x80, level.offset)					// 0x80 |-----level------|
			mstore(add(0x80, 0x20), cells.offset)		// 0xA0 |-----cells------|
			mstore(add(0x80, 0x40), marker.offset)		// 0xC0 |-----marker-----|
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
