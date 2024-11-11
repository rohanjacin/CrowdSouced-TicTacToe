// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.27;

interface ILevelConfigurator {
	
    // Reads the level proposal
    function initLevel(
        bytes calldata _levelCode,
        bytes calldata _levelNumber,
        bytes calldata _levelState,
        bytes calldata _levelSymbols
    ) external payable returns (bool success);

    // Deploys the level
    function deployLevel(
        bytes calldata _levelCode,
        bytes calldata _levelNumber,
        bytes calldata _levelState,
        bytes calldata _levelSymbols,
        bytes32 msgHash,
        uint8 gameId,
        bytes memory signature
    ) external payable returns (bool success);

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