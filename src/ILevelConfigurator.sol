// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.27;

interface ILevelConfigurator {
	
	function proposals(address) external returns(
		uint256 num,
		uint256 codeLen, 
		uint256 levelNumLen, 
		uint256 stateLen,
		uint256 symbolLen, 
		bytes32 hash,
		address codeAddress, 
		address dataAddress 
	);
}