// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.27;

interface IRuleEngine {

	// Add a rule
	function addRules(address codeAddress, bytes calldata symbols) external;
}