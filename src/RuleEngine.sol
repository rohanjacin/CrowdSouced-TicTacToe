// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.27;
import {console} from "forge-std/console.sol";

type LevelState is uint8;

error RuleInvalid();

// Applies rules across all levels
contract RuleEngine {

	// Rules (Hash of cell value vs 
	// hash of function sel of rule in level)
	mapping(bytes32 => bytes32) rules;


	// Add a rule
	function addRule(address levelAddress,
		uint8 state, bytes4 symbol)
		external returns(bool success) {

		// Check if level contract exists
		assembly {

			if iszero(extcodesize(levelAddress)) {
				revert(0, 0)
			}
		}

		// Append state symbol to default set cell call 
		string memory func = string(abi.encodePacked("setCell", symbol));

		// Calulate the signature for set call function
		bytes4 sel = bytes4(keccak256(abi.encodePacked(func,
							"(uint8)returns(uint8)")));

		// Check if rule exists in the level contract
/*		if (true == IERC165(levelAddress).supportsInterface(sel)) {
			revert RuleInvalid();
		}
*/
		// Add the rule
		bytes32 stateHash = keccak256(abi.encodePacked(uint8(state)));
		bytes32 execHash = keccak256(abi.encodePacked(
							abi.encode(levelAddress), sel));
		rules[stateHash] = execHash;
	}

	// Setting a cell value as per the rule
	function setCell(uint8 input) external returns(uint8 output) {

		// 
	}

}