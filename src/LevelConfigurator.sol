// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.27;
import {console} from "forge-std/console.sol";
import "./BaseState.sol";
import "./IGoV.sol";
import "./IRuleEngine.sol";

error ContractAddressesInvalid();
error BiddersAddressInvalid();
error BiddersLevelNumberInvalid();
error BiddersLevelCodeSizeInvalid();
error BiddersLevelStateSizeInvalid();
error BiddersStatesInvalid();
error BiddersStatesSymbolsInvalid();

contract LevelConfigurator {

	// Contract addresses (Slot 0, 1, 2)
/*	address internal govAddress;
	address internal ruleengineAddress;
	address internal gameAddress;
*/
	// Constants (Slot 3)
	uint8 constant internal MAX_LEVEL_STATE = type(uint8).max;
	uint8 constant internal MAX_LEVELS = 2; 
	uint8 constant internal MAX_CELLS_L1 = 9;
	uint8 constant internal MAX_CELLS_L2 = 81 - MAX_CELLS_L1;
	uint32 constant internal MAX_LEVEL_CODESIZE = 500000; // 500k

	struct LevelConfig {
		uint256 level;
		uint256 cells;
		uint256 marker;
	}

	constructor (/*address _govAddress,
		address _gameAddress,
		address _ruleengineAddress*/) {

/*		if ((_govAddress == address(0)) ||
			(_gameAddress == address(0)) ||
			(_ruleengineAddress == address(0))) {

			revert ContractAddressesInvalid();
		}

		govAddress =_govAddress;
		gameAddress =_gameAddress;
		ruleengineAddress = _ruleengineAddress;*/
	}

	// Enables Level configuration
	function start() external pure {

		// Store the previous level in memory
		// TODO: optimize for packed struct
		assembly {

			calldatacopy(0x80, 0x04, 0x60)
			// 0x80  |-----level------|
			// 0x100 |-----cells------|
			// 0x120 |-----marker-----|
		}
	}

	// Reads the level proposal
	function initLevel(bytes calldata _levelCode,
					   bytes calldata _levelNumber,
					   bytes calldata _levelState,
					   bytes calldata _levelSymbols) 
		external returns(bool success) {

		// Check for sender's address
		if (msg.sender == address(0))
			revert BiddersAddressInvalid();

		// Check for code length
		if ((_levelCode.length > MAX_LEVEL_CODESIZE) || 
			(_levelCode.length == 0))
			revert BiddersLevelCodeSizeInvalid();

		// Check for level number
		(uint8 levelNum) = abi.decode(_levelNumber, (uint8));

		if ((levelNum > MAX_LEVELS) || 
			(levelNum == 0))
			revert BiddersLevelNumberInvalid();

		// Check for state length
		if ((_levelState.length >= MAX_LEVEL_STATE) ||
		    (_levelState.length == 0))
			revert BiddersLevelStateSizeInvalid();

		// Check for number of state cells 
		if (levelNum == 1) {
			if (_levelState.length > MAX_CELLS_L1)
				revert BiddersLevelStateSizeInvalid();
		}
		else if (levelNum == 2) {
			if (_levelState.length > MAX_CELLS_L2)
				revert BiddersLevelStateSizeInvalid();
		}
		
		// Check for state symbols length
		if ((_levelSymbols.length >= MAX_LEVEL_STATE) ||
		    (_levelSymbols.length == 0))
			revert BiddersStatesSymbolsInvalid();

		// Check for number of symbols in level 
		if (levelNum == 1) {
			if (_levelSymbols.length > 8) // ❌ and ⭕
				revert BiddersStatesSymbolsInvalid();
		}
		else if (levelNum == 2) {
			if (_levelSymbols.length > 16) // ❌, ⭕, ⭐ and 💣
				revert BiddersStatesSymbolsInvalid();
		}


		// Check state against common level rules
		// TODO: check for return value (return var causes stack too deep)
/*		_checkStateValidity(_levelState, uint8(_levelState.length), 
							uint8(_levelSymbols.length));

		// Store level code and state
		(bytes32 levelLoc, address stateSnap) = _storeLevel();

		// Deploy level contract
		bytes32 salt = keccak256(abi.encodePacked(msg.sender));
		address levelAddr = _deployLevel(levelLoc, salt);

		// Call GoV contract to approve level
		// with level memory location
		//IGoV(govAddress).approveValidLevelProposal(levelAddr, stateSnap);
*/
		success = true;
	}

	// Deploys the level
	function _deployLevel(bytes32 levelLoc, bytes32 salt) 
		internal returns(address target) {

		// Deploy using create
		assembly {

			target := create2(0, add(levelLoc, 0x20), 
				mload(levelLoc), salt)
		}

		//_addLevelRules(target, levelLoc);
	}

	// Add level rules to rule base
	function _addLevelRules(address levelAddress, uint256 levelLoc)
		internal returns(bool success) {

		// Iterate over state symbols
		uint8 numSymbols; 
		uint256 symbolsLen;
		assembly {
			symbolsLen := mload(add(levelLoc, 0x40))

			if iszero(symbolsLen) { return(0, 0) }

			// Symbol location
			let loc := add(mload(levelLoc), mload(add(levelLoc, 0x20)))

			// Number of symbol words
			let l := 0x20
			let k := div(symbolsLen, 0x20)
			if iszero(k) { k := 1 l := mod(symbolsLen, 0x20) }

			// Minimum 4 bytes represent a symbol, so min 1 symbol check
			if lt(l, 4) { return(0, 0) }


			// Each symbol word
			let j
			for { let i := 0 } lt(i, k) { i := add(i, 1) } {

				// Each symbol for each state (inclusive of prev level state symbols)
				for { j := 0 } lt(j, div(l, 0x04)) { j := add(j, 1) } {
					//shr(32, mload(add(loc, i)))
				}
			}

			// Store symbol count, useful in verifying level contract
			// actually store same symbol when deployed
			tstore(j, symbolsLen)
			numSymbols := j
		}

		// Make sure symbol len is in bounds
		assert(numSymbols <= (type(uint8).max-1));

		// Prepare default getter of public "symbols" storage
		// to later verify
		string memory returnType;
		uint8[] memory states;
		for (uint8 i = 1; i <= numSymbols; i++) {

			returnType = string(abi.encodePacked(returnType, "uint"));
			states[i] = i;
		}

		string memory symbolsGetter = string(abi.encodePacked(
			"symbols()returns(", returnType, ")")); 
		
		// Call default getter for storage
		(bool symbolSuccess, bytes memory symbols) = 
			levelAddress.call{
				value: msg.value
			}(abi.encodeWithSignature(symbolsGetter));

		// Assert call was successful
		assert(symbolSuccess == true);

		// Get local copy of symbols from memory
		bytes memory sloc;
		assembly {
			// Symbol location
			sloc := add(mload(levelLoc), mload(add(levelLoc, 0x20)))
		}

		// Check if loacl symbols and level contract symbols are the same
		assert(sloc.length == symbolsLen);
		assert(keccak256(abi.encodePacked(symbols)) == 
			keccak256(abi.encodePacked(sloc)));

		// Add rules to rule engine		
		//IRuleEngine(ruleengineAddress).addRules(
		//	levelAddress, states, symbols);

		success = true;
	}

	// Store level code and state in memory 
	function _storeLevel() internal returns (
		bytes32 _location, address _stateSnap) {

		// 0x80 |-----level------|
		// 0xA0 |-----cells------|
		// 0xC0 |-----marker-----|
		// 0xD0 |----levellen----|
		// 0xE0 |----statelen----|
		// 0xF0 |---symbollen----|
		// 0x100|---levelcode----|
		// 0x__ |---levelstate---|
		// 0x__ |--levelsymbols--|

		// Store level code and state
		assembly {

			// Copy level code 
			let loc := mload(0x40)
			let off := calldataload(0x04)
			let len := sub(off, 0x20)
			calldatacopy(loc, off, len)
			_location := loc

			// Copy level state 
			loc := mload(0x40)
			off := add(off, 0x20)
			len := sub(off, 0x20)
			let stateOff := off 
			let stateLen := len 
			calldatacopy(loc, off, len)

			// Copy level symbols 
			loc := mload(0x40)
			off := add(off, 0x20)
			len := sub(off, 0x20)
			calldatacopy(loc, off, len)

			// Copy level state to new memory 
			loc := mload(0x40)
			calldatacopy(loc, stateOff, stateLen)
			// Take snapshot of state
			loc := mload(0x40)
			mstore(loc, 0x60005260206000F3) // Constructor 
			_stateSnap := create(0, loc, stateLen)
		}
	}

	// Check state validity
	function _checkStateValidity(uint8 _levelNum,
		bytes memory _state, bytes memory _symbols) external pure {

		uint8 _symbolLen;
		assembly {
			_symbolLen := div(mload(_symbols), 4)
		}

		// Check if State has valid entries
		uint validState = uint(CellValue.Empty) + _symbolLen;

		//uint256 rowBitMap;
		//uint256 row;
		//uint256 state;
     	assembly {
			let state
			let colBitMap := 0
			let rowBitMap := 0
			let s, ptr
			let col := 0
			let row := 0 
			let _marker
			//let len := mload(_state)

			ptr := add(_state, 0x20)
			s := add(div(mload(_state), 32), 1)

/*				if eq(s, 2)
				{
					revert (0,0)
				}
*/
			switch _levelNum
			case 1 { _marker := 0 }
			case 2 { _marker := 9 }
			default { _marker := 0 }

			//  Compare state word if within valid state 
			for { let i := 0 let k := 0
				  switch lt(mload(_state), 32)
				  case 0 { k := 32 }
				  case 1 { k := mod(mload(_state), 32) }
			    }
				lt(i, s) 
				{ i := add(i, 1) ptr := add(ptr, 0x20)
				  switch sub(s, i)
				  case 1 { k := mload(_state) }
				  default { k := mul(add(i, 1), 32) }
				} {
				
				// Each state check
				for { let j := mul(i, 32) } lt(j, k) { j := add(j, 1) } {

/*					if eq(j, 34) {
						revert(0, 0)
					}*/
					state := byte(mod(j, 32), mload(ptr))

					if iszero(state) {
						continue
					}

					if lt(validState, state) {
						//revert (0, 0)
					}

					//if eq(state, 2) {
					//	revert(0, 0)
					//}
					//  0   1   2   3   4   5   6   7   8
		            //  C0  C1  C2  C3  C4  C5  C6  C7  C8
		            // [ X ,   , O ,   ,   ,   ,   ,   ,   ] R0
		            // [   ,   ,   ,   ,   ,   ,   ,   ,   ] R1
		            // [   ,   ,   ,   ,   ,   ,   ,   ,   ] R2
		            // [   ,   ,   , X , O ,   ,   ,   ,   ] R3
		            // [   ,   ,   ,   ,   ,   ,   ,   ,   ] R4
		            // [ X , O ,   ,   ,   ,   ,   ,   ,   ] R5
		            // [   ,   ,   ,   ,   ,   ,   ,   ,   ] R6
		            // [   ,   ,   ,   ,   ,   ,   ,   ,   ] R7
		            // [   ,   ,   ,   ,   ,   ,   ,   ,   ] R8

		            // [ X ,   , O ,   ,   ,   ,   ,   ,   ] R0
		            if iszero(_marker) {
		            	//revert (0, 0)
		            }

					// Check if current cell is in new col,
					// refresh state count col map 
					row := div(j, _marker)
					col := mod(j, _marker)	

					if eq(and(rowBitMap, shl(mul(row, 8), 0xFF)), 
						  shl(mul(row, 8), 0xFF)) {
						revert (0, 0)
					}

					let m := byte(sub(31, row), xor(rowBitMap, shl(mul(row, 8), state)))
					
					// State already present
					if iszero(m) {
						revert(0, 0)
					}
					// Empty
					if eq(m, state) {
						rowBitMap := or(rowBitMap, shl(mul(row, 8), state))

					}

					if iszero(eq(m, state)) {
						rowBitMap := or(rowBitMap, shl(mul(row, 8), 0xFF))
					}


					if eq(and(colBitMap, shl(mul(col, 8), 0xFF)), 
						  shl(mul(col, 8), 0xFF)) {
						revert (0, 0)
					}

					let n := byte(sub(31, col), xor(colBitMap, shl(mul(col, 8), state)))
					
					// State already present
					if iszero(n) {
						revert(0, 0)
					}
					// Empty
					if eq(n, state) {
						colBitMap := or(colBitMap, shl(mul(col, 8), state))

					}

					if iszero(eq(n, state)) {
						colBitMap := or(colBitMap, shl(mul(col, 8), 0xFF))
					}					
				}
			}
		}
		//console.log("row:", row);
		//console.log("state:", state);
		//console.log("rowBitMap:", rowBitMap);
	}	
}

/*					if iszero(col) {
						symbolBitMap := 0	
					}

					let m := shl(state, 1)
					if and(symbolBitMap, m) {
						//revert (0, 0)
				 	}

					symbolBitMap := or(symbolBitMap, m)
*/

/*


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
		

*/