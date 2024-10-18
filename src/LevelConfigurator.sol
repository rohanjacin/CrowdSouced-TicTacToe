// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.27;
import {console} from "forge-std/console.sol";

contract LevelConfigurator {

	uint256 constant internal MAX_LEVEL_CODESIZE = 500000; // 500k
	uint16 constant internal MAX_LEVEL_STATE = type(uint16).max;

	struct LevelConfig {
		uint8 number;
	}

	mapping (address => LevelConfig) configs;

	// Reads the level proposal
	function initLevel(bytes[] calldata _levelCode,
					   bytes[] calldata _levelState) 
		external view returns (bytes4 word){

		// Check for sender's address
		require(msg.sender != address(0), "E01");

		// Store the level code size and the 
		// level state size in memory		
	}

	// Check level number
	function _checkLevelNumber() internal view returns(bool pass) {
	}
}
