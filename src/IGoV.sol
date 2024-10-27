// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.27;

interface IGoV {
	
	// Approve valid level proposal
	function approveValidLevelProposal(address levelAddr,
		address stateSnap) external;
}