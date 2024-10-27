// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.27;
import "forge-std/console.sol";

error InvalidLevelNumber();

// Basic level layout
contract BaseLevel {

	// Level value
	uint8 public levelnum;

	constructor(uint8 _levelnum) {

		// Level 1 and Level 2 only currently!!
		if (!((_levelnum == 1) ||
		    (_levelnum == 2))) {
			revert InvalidLevelNumber();
		}
	}

	// Updates the base level data to the callers
	// context when delegated
	function copyLevel(bytes memory data) external returns(bool success) {

		// Copy the 1 byte level number assuming data is packed
		// with only level number 
		assembly {
			let len := mload(data)
			let value := byte(0, mload(add(data, 0x20)))

			// Level 1 and Level 2 only currently!!

			if iszero(value) {
				revert (0, 0)
			}

			if gt(value, 2) {
				revert (0, 0)
			}

			// Store one byte in slot of levelnum
			if eq(len, 1) {
				sstore(levelnum.slot, value)
			}
		}

		success = true;
	}

}
