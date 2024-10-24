// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.27;
import {console} from "forge-std/console.sol";
import "./BaseState.sol";
import "./IGoV.sol";
import "./IRuleEngine.sol";

error ContractAddressesInvalid();
error DeployLevelInvalid();
error BiddersAddressInvalid();
error BiddersLevelNumberInvalid();
error BiddersLevelCodeSizeInvalid();
error BiddersLevelStateSizeInvalid();
error BiddersStatesInvalid();
error BiddersStatesSymbolsInvalid();

contract LevelConfigurator {

	// Contract addresses (Slot 0, 1, 2)
	address internal govAddress;
	address internal ruleengineAddress;
	address internal gameAddress;

	// Constants (Slot 3)
	uint8 constant internal MAX_LEVEL_STATE = type(uint8).max;
	uint8 constant internal MAX_LEVELS = 2; 
	uint8 constant internal MAX_CELLS_L1 = 9;
	uint8 constant internal MAX_CELLS_L2 = 81;
	uint32 constant internal MAX_LEVEL_CODESIZE = 500000; // 500k

	struct LevelConfig {
		uint256 level;
		uint256 cells;
		uint256 marker;
	}

	constructor (address _govAddress,
		address _gameAddress,
		address _ruleengineAddress) {

		if ((_govAddress == address(0)) ||
			(_gameAddress == address(0)) ||
			(_ruleengineAddress == address(0))) {

			revert ContractAddressesInvalid();
		}

		govAddress =_govAddress;
		gameAddress =_gameAddress;
		ruleengineAddress = _ruleengineAddress;
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

		success = false;
		// Check for sender's address
		if (msg.sender != address(0))
			revert BiddersAddressInvalid();

		// Check for level number
		uint8 levelNum = abi.decode(_levelNumber, (uint8));
		if (levelNum <= MAX_LEVELS)
			revert BiddersLevelNumberInvalid();

		// Check for code length
		if (_levelCode.length <= MAX_LEVEL_CODESIZE)
			revert BiddersLevelCodeSizeInvalid();

		// Check for state length
		if (_levelState.length <= MAX_LEVEL_STATE)
			revert BiddersLevelStateSizeInvalid();

		// Check for number of state cells 
		if (_levelState.length < MAX_CELLS_L2)
			revert BiddersLevelStateSizeInvalid();

		// Check for state symbols length
		if (_levelSymbols.length < MAX_LEVEL_STATE)
			revert BiddersStatesSymbolsInvalid();

		// Check state against common level rules
		// TODO: check for return value (return var causes stack too deep)
		_checkStateValidity(uint8(_levelState.length), 
							uint8(_levelSymbols.length));

		// Store level code and state
		uint256 levelLoc = _loadLevel(_levelCode.length, 
							uint8(_levelState.length),
							uint8(_levelSymbols.length));

		// Call GoV contract to approve level
		// with level memory location
		IGoV(govAddress).approveValidLevelProposal(levelLoc);

		success = true;
	}

	// Deploys the level
	function deployLevel(uint8 level, uint256 salt) 
		external payable returns(address target) {

		if (!(level == 1) || (level == 2)) {
			revert DeployLevelInvalid();
		}

		// Load level from memory
		// TODO: Partition memory
		bytes32 levelLoc;

		// Deploy using create2
		assembly {

			if eq(level, 1) { levelLoc := 0x80 }
			if eq(level, 2) { levelLoc := 0x580 }

			// level code length is at 0xD0,
			// state length is at 0xE0 
			target := create2(0, levelLoc, 
				add(mload(levelLoc), mload(add(levelLoc, 0x20))), salt)
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
		IRuleEngine(ruleengineAddress).addRules(
			levelAddress, states, symbols);

		success = true;
	}

	// Load level code and state in memory 
	function _loadLevel(uint256 codeLen, uint8 stateLen, uint8 symbolLen)
		internal pure returns (uint256 location) {

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
		location = uint256(0xD0);
		assembly {
			calldatacopy(location, 0x04, codeLen)
			calldatacopy(add(location, codeLen), 
				add(0x04, codeLen), stateLen)
			calldatacopy(add(location, add(codeLen, stateLen)), 
				add(0x04, stateLen), symbolLen)			
		}
	}

	// Check state validity
	function _checkStateValidity(uint8 _stateLen,
		uint8 _stateCount) internal pure {

		// Check if State has valid entries
		uint validState = uint(CellValue.Empty) + _stateCount;
		// TODO: assert validState fits in uint8 

		uint256 stateCountMapRow;
		uint256 stateCountMapCol;
		uint8 _marker = MAX_CELLS_L1;
		//bytes32 _prevLevel = levelConfigLoc;

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
