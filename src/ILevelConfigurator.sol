// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.27;

interface ILevelConfigurator {
	
    struct LevelConfig {
        // packed
        uint256 num; // 0x00
        bytes32 codeHash; // 0x20
        uint256 levelNumLen; // 0x40
        uint256 stateLen; // 0x60
        uint256 symbolLen; // 0x80
        bytes32 hash; // 0xA0
        address codeAddress; // 0xC0
        address dataAddress; // 0xE0
    }

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

    function getProposal(address bidder) external
        returns (LevelConfig memory config);
}