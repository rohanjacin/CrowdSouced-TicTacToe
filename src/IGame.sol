// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.27;

interface IGame {

	function loadLevel(address bidder) external
		returns(bool success, string memory message);

    function level() external view returns (uint256);
}