// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.27;

interface ILevelD {

	function copyLevelData(bytes calldata _levelNumData,
		bytes calldata _stateData, bytes calldata _symbolsData)
		external returns(bool success);
}