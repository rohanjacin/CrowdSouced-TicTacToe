// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.27;
import "forge-std/console.sol";

// Basic level layout
abstract contract BaseLevel {

	// Level value
	uint8 public levelnum;

	constructor(uint8 _levelnum) {
		levelnum = _levelnum;
		console.log("BaseLeve: ");
	}

	// Updates the base level data to the callers
	// context when delegated
	function copyLevel() public virtual returns(bytes memory id){
		levelnum = levelnum;

		assembly {
			id := levelnum.slot
		}
	}
}
