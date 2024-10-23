// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.27;

interface LevelConfigurator {

	// Deploys the level
	function deployLevel(uint8 level, uint256 salt) 
		external payable returns(address target);	
}