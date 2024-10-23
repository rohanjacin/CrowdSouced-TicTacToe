// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.27;

// Basic level layout
abstract contract BaseLevel {

	// Level value
	uint8 public levelnum;

	constructor(uint8 _levelnum) {
		levelnum = _levelnum;
	}

	// Should be overridden by Level implementation
	function copyLevel() external virtual returns(bool success) {
	}

}
