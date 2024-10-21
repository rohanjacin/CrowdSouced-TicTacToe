// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.27;

interface IRuleEngine {

	// Add a rule
	function addRules(address levelAddress,
		uint8[] memory state, bytes calldata symbols)
		external returns(bool success);
}