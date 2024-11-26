// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.27;
import "forge-std/console.sol";

// Basic level layout
contract BaseLevelD {

	// Level value
	uint8 public level;

	// Updates the base level data to the callers
	// context when delegated
	function copyLevel(bytes memory data) internal returns(bool success) {

		// Copy the 1 byte level number assuming data is packed
		// Level 1 and Level 2 only currently!!
		assembly {

			let len := mload(data)
			let _num := byte(0, mload(add(data, 0x20)))

			switch _num
			case 1 { sstore(level.slot, _num) }
			case 2 { sstore(level.slot, _num) }
			default { revert(0, 0) }
		}

		success = true;
	}

}