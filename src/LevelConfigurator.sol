// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.27;
import {console} from "forge-std/console.sol";
import "openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";
import "openzeppelin-contracts/contracts/utils/cryptography/MessageHashUtils.sol";
import "./BaseState.sol";
import "./IGoV.sol";
import "./ILevelConfigurator.sol";

error ContractAddressesInvalid();
error BiddersAddressInvalid();
error BiddersLevelNumberInvalid();
error BiddersLevelCodeSizeInvalid();
error BiddersLevelStateSizeInvalid();
error BiddersStatesInvalid();
error BiddersStatesSymbolsInvalid();
error FailedToCacheLevel();
error FailedToDeployLevel();

// Proposal Level configuration
struct LevelConfig {
	// packed
	uint256 num; // 0x00
	uint256 codeLen; // 0x20
	uint256 levelNumLen; // 0x40
	uint256 stateLen; // 0x60
	uint256 symbolLen; // 0x80
	bytes32 hash; // 0xA0
	address codeAddress; // 0xC0
	address dataAddress; // 0xE0
}

contract LevelConfigurator is ILevelConfigurator{

	// Contract addresses (Slot 0, 1, 2)
/*	address internal govAddress;
	address internal ruleengineAddress;
	address internal gameAddress;
*/
	// Constants (Slot 3)
	uint8 constant internal MAX_LEVEL_STATE = type(uint8).max;
	uint8 constant internal MAX_LEVELS = 2; 
	uint8 constant internal MAX_CELLS_L1 = 9;
	uint8 constant internal MAX_CELLS_L2 = 81;
	uint32 constant internal MAX_LEVEL_CODESIZE = 500000; // 500k

	// Proposals cached
	mapping (address => LevelConfig) public proposals;

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
		uint8 levelNum;
		assembly {
			levelNum := byte(0, calldataload(_levelNumber.offset))
		}

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
		if (1 == _checkStateValidity(_levelNumber, _levelState, _levelSymbols)) {
			revert BiddersStatesInvalid();
		}

		// Cache reference for level (level code, level num, state and symbols)		
		if (false == _cacheLevel(_levelCode, _levelNumber,
						_levelState, _levelSymbols)) {
			revert FailedToCacheLevel();
		}

		// Deploy level contract
/*		bytes32 salt = keccak256(abi.encodePacked(msg.sender));
		address levelAddr = _deployLevel(levelLoc, salt);

		// Call GoV contract to approve level
		// with level memory location
		//IGoV(govAddress).approveValidLevelProposal(levelAddr, stateSnap);
*/
		success = true;
	}

	// Deploys the level
	function _deployLevel(bytes calldata _levelCode,
					      bytes calldata _levelNumber,
					      bytes calldata _levelState,
					      bytes calldata _levelSymbols,
					      bytes32 msgHash, uint8 gameId, 
					      bytes memory signature) 
		external returns (bool success) {

		// Check in cached proposals if hash matches
		LevelConfig memory config = proposals[msg.sender];

		bytes32 hash = keccak256(abi.encodePacked(_levelCode, _levelNumber,
			_levelState, _levelSymbols));

		// Verify level configuration
		if ((config.codeLen != _levelCode.length) ||
		    (config.levelNumLen != _levelNumber.length) ||
		    (config.stateLen != _levelState.length) ||
		    (config.symbolLen != _levelSymbols.length) ||
		    (config.hash != hash) || (config.hash != msgHash)) {
			revert FailedToDeployLevel();
		}

		// Verify signature
		bytes32 sigHash = MessageHashUtils.toEthSignedMessageHash(msgHash);

		if (ECDSA.recover(sigHash, signature) != msg.sender) {
			revert FailedToDeployLevel();
		}

		// Deploy using create
		bytes memory code = _levelCode;
		assembly {
			let target := create2(0, add(code, 0x20), mload(code), gameId)
			mstore(add(config, 0xC0), target)
		}

		// Store level code and state
		config.dataAddress = _storeLevel(_levelNumber, _levelState,
								_levelSymbols);
		proposals[msg.sender] = config;

		success = true;
		//IRuleEngine(address(0x1)/*ruleengineAddress*/).addRules(
		//		config.codeAddress, _levelSymbols);
	}

	// Add level rules to rule base
	function _addLevelRules(address levelAddress, uint256 levelLoc)
		internal returns(bool success) {

		// Iterate over state symbols
/*		uint8 numSymbols; 
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
*/
		success = true;
	}

	// Cache the hash of proposal 
	// i.e level code, number, state and symbols  
	function _cacheLevel(bytes memory _levelCode, bytes memory _levelNum, 
		bytes memory _state, bytes memory _symbols)
		internal returns (bool success) {

		LevelConfig memory config = LevelConfig(uint256(0), uint256(0),
			uint256(0), uint256(0), uint256(0), bytes32(0),
			address(0), address(0));

		// Register the lengths
		assembly {
			// num
			let ptr := config
			mstore(ptr, mload(add(_levelNum, 0x20)))

			// codeLen
			ptr := add(config, 0x20)				
			mstore(ptr, mload(_levelCode))

			// levelNumLen
			ptr := add(config, 0x40)				
			mstore(ptr, mload(_levelNum))

			// stateLen
			ptr := add(config, 0x60)				
			mstore(ptr, mload(_state))

			// symbolLen
			ptr := add(config, 0x80)				
			mstore(ptr, mload(_symbols))
		}

		// Calculate hash
		config.hash = keccak256(abi.encodePacked(_levelCode, _levelNum,
								_state, _symbols));

		proposals[msg.sender] = config;
	}

	// Store level number, state and symbols as code  
	function _storeLevel(bytes memory _levelNum, bytes memory _state,
		bytes memory _symbols) internal returns (address location) {

		// Constructor wrapper to create contract with code
		// eqaul to _levelNum, _state, _symbols
		// Taken from https://github.com/0xsequence/sstore2
	    /*
	      0x00    0x63         0x63XXXXXX  PUSH4 _code.length  size
	      0x01    0x80         0x80        DUP1                size size
	      0x02    0x60         0x600e      PUSH1 14            14 size size
	      0x03    0x60         0x6000      PUSH1 00            0 14 size size
	      0x04    0x39         0x39        CODECOPY            size
	      0x05    0x60         0x6000      PUSH1 00            0 size
	      0x06    0xf3         0xf3        RETURN
	      <CODE>
	    */

	    bytes memory data = abi.encodePacked(
	    	hex"00",
	    	_levelNum,
	    	_state,
	    	_symbols
	    );

		bytes memory code = abi.encodePacked(
			hex"63",
			uint32(data.length),
			hex"80_60_0E_60_00_39_60_00_F3",
			data
		);

		assembly {
			location := create(0, add(code, 32), mload(code))
		}

		if (location == address(0)) {
			revert();
		}
	}

	// Retrieve level number, state and symbols as data  
	function _retrieveLevel(address loc) 
		external returns (bytes memory data) {

		uint256 size;

		if (loc == address(0)) {
			console.log("Address is zero");
			revert();
		}

		assembly {
			size := extcodesize(loc)

			if iszero(size) {
				revert(0, 0)
			}

			// Allocate space for data starting from the free location
			data := mload(0x40)

			// Reserve new memory to fit data size
			mstore(0x40, add(data, and(and(add(size, 0x20), 0x1f), not(0x1f))))

			// Store length
			mstore(data, size)

			// retrieve the code from location
			extcodecopy(loc, add(data, 0x20), 1, sub(size, 1))
		}
	}

	// Check state validity
	function _checkStateValidity(bytes memory _levelNum,
		bytes memory _state, bytes memory _symbols)
		internal pure returns (uint8 ret) {
		
		// Check if State has valid entries
     	assembly {
			let state
			let colBitMap := 0
			let rowBitMap := 0
			let s, ptr
			let col := 0
			let row := 0 
			let _marker

			// Max enumeration for valid symbols
			// including previous levels as well
			//uint validState = uint(CellValue.Empty) + _symbolLen;
			let validState := add(0, div(mload(_symbols), 4))

			// Pointer to state word
			ptr := add(_state, 0x20)
			// Number of words in state
			s := add(div(mload(_state), 32), 1)

			// Previous level marker of row & column
			_marker := byte(0, mload(add(_levelNum, 0x20)))
			switch _marker
			case 1 { _marker := 0 }
			case 2 { _marker := 9 }
			default { _marker := 0 }

			// Compare state word if within valid state 
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

					state := byte(mod(j, 32), mload(ptr))

					if iszero(state) {
						continue
					}

					if lt(validState, state) {
						ret := 1
						break
					}

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
		            	ret := 1
		            	break
		            }

					// Check if current cell is in new col,
					// refresh state count col map 
					row := div(j, _marker)
					col := mod(j, _marker)	

					if eq(and(rowBitMap, shl(mul(row, 8), 0xFF)), 
						  shl(mul(row, 8), 0xFF)) {
						ret := 1
						break
					}

					let m := byte(sub(31, row), xor(rowBitMap, shl(mul(row, 8), state)))
					
					// State already present
					if iszero(m) {
						ret := 1
						break
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
						ret := 1
						break
					}

					let n := byte(sub(31, col), xor(colBitMap, shl(mul(col, 8), state)))
					
					// State already present
					if iszero(n) {
						ret := 1
						break
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
	}
}

