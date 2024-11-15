// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.27;

interface IGame {

    function level() external view returns (uint256);

	// Starts a new game
	function newGame(uint8 _level, address _bidder) external
		returns (bool success, string memory message);
}