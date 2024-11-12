// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.27;

interface IGame {

	function loadLevel(address bidder) external
		returns(bool success, string memory message);

	// Setting a cell value as per the rule
	function setCell(address levelAddress, uint8 row, uint8 col,
		uint8 input) external returns(bool success);

    function getCell(uint8 row, uint8 col) external view returns (uint256 val);

    function setState(uint8 row, uint8 col, uint8 val) external;

    function level() external view returns (uint256);
}