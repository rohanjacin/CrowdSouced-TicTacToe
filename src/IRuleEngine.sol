// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.27;

interface IRuleEngine {

	// Add a rule
	function addRules(address codeAddress, bytes calldata symbols) external;

	// Setting a cell value as per the rule
	function setCell(address levelAddress, uint8 row, uint8 col,
		uint8 input) external returns(bool success);
}