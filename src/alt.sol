/*		// Check for code length
		if (_levelCode.length <= MAX_LEVEL_CODESIZE)
			revert BiddersLevelCodeSizeInvalid();
		levelCodeLen = _levelCode.length;

		// Check for state length
		if (_levelState.length <= MAX_LEVEL_STATE)
			revert BiddersLevelStateSizeInvalid();
		levelStateLen = uint8(_levelState.length);
*/
/*	// Level Config (Slot 2, 3 and 4)
	uint8 levelStateLen;
	uint256 levelCodeLen;
	bytes32 levelCodePtr;
*/
		// Store level code and state to memory
/*		uint256 _levelCodeLen = levelCodeLen;
		uint8 _levelStateLen = levelStateLen;
		bytes32 _levelCodePtr;

		assembly {
			// Copy level code to memory
			_levelCodePtr := 0x80
			//_levelCodePtr := msize() //cannot use msize() if yul optimizer is enabled
			calldatacopy(_levelCodePtr, 0x04, _levelCodeLen)

			// Copy state to memory
			calldatacopy(add(_levelCodePtr, _levelCodeLen),
				add(0x04, _levelCodeLen) , _levelStateLen)
		}

		levelCodePtr = _levelCodePtr;
*/

/*	// Check state validity
	function checkStateValidity(uint256 _codeLen, uint8 _stateLen,
		uint8 _stateCount) external view returns(bool pass) {

		pass = true;
		bytes32 _offset = levelCodePtr;
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

			// Num of 32 byte words
			let num := div(_stateLen, 0x20)

			// Bit XOR state word and compare if within valid state 
			for { let i := 0 let k := 0x20 let s := _offset}
				lt(i, num) //(i,mload(mload(0x40))) 
				{ i := add(i, 1) s := add(s, 0x20) } {

				word := mload(s)
				stateWord := xor(word, 0x0101010101010101010101010101010101010101010101010101010101010101)
				mstore(s, stateWord)	
			}
		}
	}

	// Check Level rules
	function checkStateRules(uint8 _stateCount) external returns(bool pass) {

		// Check if State has valid entries
		uint validState = uint(CellValue.Empty) + _stateCount;
		// TODO: assert validState fits in uint8 

		bytes32 _offset = levelCodePtr;
		uint256 stateCountMapRow;
		uint256 stateCountMapCol;
		//uint8 _cells = cells;
		uint8 _marker = marker;
		bytes32 stateWord; 

		assembly {
		
//			if eq(i, sub(num, 1)) {
//				k := mod(_stateLen, 0x20)
//			}

			let k := 0x20
			let col := 0xFF
			let row := 0xFF
			let state		
			stateWord := mload(_offset)

			// Each state check
			for { let j := 0 } lt(j, k) { j := add(j, 1) } {

				state := byte(stateWord, j)
				if gt(state, validState) { //stateWord
					pass := 0
					return (0, 0)
				}

				// Check if current cell is in new col,
				// refresh state count col map 
				// compare col with new col
				if iszero(eq(col, mod(j, _marker))) {
					col := mod(j, _marker)
					stateCountMapCol := 0
				}

				// Check if current cell is in new row,
				// refresh state count row map
				// compare row with new row
				if iszero(eq(row, div(j, _marker))) {
					row := div(j, _marker)
					stateCountMapRow := 0
				}

				// Bit AND state count map and check if already exists 
				if and(stateCountMapRow, shl(byte(stateWord, j), 1)) {
					pass := 0
					return (0, 0)
				}

				if and(stateCountMapCol, shl(byte(stateWord, j), 1)) {
					pass := 0
					return (0, 0)
				}

				// Update state count in row and col
				stateCountMapRow := or(stateCountMapRow, shl(state, 1))
				stateCountMapCol := or(stateCountMapRow, shl(state, 1))
			}
		}
	}*/
