// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.27;
import "forge-std/console.sol";

// Basic level layout
abstract contract BaseSnap {

	// Data snapshot address
	address public dataSnapAddr;

	constructor() {
		// Create datasnapshot of initial(prefilled cells) state
		// and store the address of at Slot 0 temporarily
		assembly {

			let ptr := mload(0x40)
			let len := sub(calldatasize(), 0x04)
			calldatacopy(ptr, 0x04, len)
			let addr := create(0, add(ptr, 0x20), len)
			sstore(dataSnapAddr.slot, addr)
		}
	}

	// Updates the data snapshot to the callers
	// context when delegated
	function copyData() public virtual returns(bool success){
	}
}
