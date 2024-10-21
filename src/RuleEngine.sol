// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.27;
import {console} from "forge-std/console.sol";
import "./BaseLevel.sol";
import "./BaseState.sol";

type LevelState is uint8;

error StateCountInvalid();
error RuleInvalid();

// Applies rules across all levels
contract RuleEngine {

	// Rules (Hash of cell value vs 
	// hash of function sel of rule in level)
	mapping(bytes32 => bytes32) rules;


	// Add a rule
	function addRules(address levelAddress,
		uint8[] memory state, bytes calldata symbols)
		external returns(bool success) {

		// Check for valid state count
		if (state.length >= type(uint8).max) {
			revert StateCountInvalid();
		}

		// Check if level contract exists
		assembly {

			if iszero(extcodesize(levelAddress)) {
				revert(0, 0)
			}
		}

		(bool success1, bytes memory selectors) = levelAddress.call(
			abi.encodeWithSignature("supportedStates()returns(bytes)"));

		if (success1 == false) {
			revert RuleInvalid();
		}

		// Check for number of symbols, it should be
		// equal to number of states
		uint8 numSymbols = uint8(symbols.length/32);
		assert(numSymbols == state.length);

		for (uint8 i = 0; i < numSymbols; i++ ) {

			bytes32 symbol = bytes32(symbols[i*32:(i*32 + 31)]);

			// Append state symbol to default set cell call 
			string memory func = string(abi.encodePacked("setCell", symbol));

			// Calulate the signature for set call function
			bytes4 sel = bytes4(keccak256(abi.encodePacked(func,
								"(uint8)returns(uint8)")));

			// Check if rule exists in the level contract
			bytes32 levelSel;
			assembly {
				levelSel := mload(add(selectors, mul(i, 32)))
			}

			assert(levelSel == sel);

			// Add the rule
			bytes32 stateHash = keccak256(abi.encodePacked(uint8(state[i])));
			bytes32 execHash = keccak256(abi.encodePacked(
								abi.encode(levelAddress), sel));
			rules[stateHash] = execHash;
		}
	}

	// Setting a cell value as per the rule
	function setCell(uint8 input) external returns(uint8 output) {

		// 
	}

}