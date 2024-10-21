// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.27;

// Basic level layout
contract BaseLevel {

	// Cells
	struct Cells {
		uint8[] row;
		uint8[] col;
	}
}
