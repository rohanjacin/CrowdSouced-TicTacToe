// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.27;

// Possible cell values
enum CellValue { Empty }

// Base State
contract BaseState {
	struct DefaultState {
		CellValue[9] v;
	}
}
