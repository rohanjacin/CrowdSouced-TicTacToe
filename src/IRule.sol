// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.27;
import {console} from "forge-std/console.sol";

// Rules interface
interface IRules {

	// Setting a cell value as per the rule
	function setCell(uint8 input) external returns(uint8 output);

	// Add a rule
	function addRule(address levelAddress,
		uint8 state, bytes4 symbol)
		external returns(bool success);
}