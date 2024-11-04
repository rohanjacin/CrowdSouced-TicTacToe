// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.27;

import "./BaseLevel.d.sol";
import "./BaseState.d.sol";
import "./BaseSymbol.d.sol";
import {console} from "forge-std/console.sol";

// Level defination and implementation
contract Level1D is BaseLevelD, BaseStateD, BaseSymbolD {

	// Inhertied from ILevel Loads Level 1
/*	function copyLevelData() public returns(bool success){
		
		// Update Data Snapshot to caller's context
		(bool ret, bytes memory data) = dataSnapAddr.call("");
		ret = ret;
		data = data;
		id = abi.encodePacked(
					super.copyLevel(),
					super.copyState(),
					super.copySymbol());

		success = true;
	}
*/
	// ❌
	function setCellue29d8c00() external view {

	}
	
	// ⭕  
	function setCellue2ad9500() external view {

	}

	// Inherited from BaseState - all implemented and supported states in level
    function supportedStates() public view override returns (bytes memory) {

    	return abi.encodePacked(bytes4(this.setCellue29d8c00.selector),  // ❌
    							bytes4(this.setCellue2ad9500.selector)); // ⭕
    }

}
