// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.27;
import {console} from "forge-std/console.sol";
import "./BaseLevel.sol";
import "./BaseState.sol";

type LevelState is uint8;

error StateCountInvalid();
error RuleInvalid();

// Applies rules across all levels
contract RuleEngine {
    bytes16 private constant HEX_DIGITS = "0123456789abcdef";

	// Rules (cell value vs 
	// hash of function sel of rule in level)
	mapping(uint8 => bytes4) rules;

	// Add a rule
	function addRules(address codeAddress, bytes calldata symbols) external {

		// Check if level contract exists
		assembly {
			if iszero(extcodesize(codeAddress)) {
				revert(0, 0)
			}
		}

		(bool ret, bytes memory selectors) = codeAddress.call(
			abi.encodeWithSignature("supportedStates()"));

		if (ret == false) {
			revert RuleInvalid();
		}

		// Check for number of symbols, it should be
		// equal to number of states
		uint8 numSelectors;
		assembly {
			numSelectors := div(mload(add(selectors, 0x40)), 4) 
		}

		uint8 numSymbols = uint8(symbols.length/4);
		assert(numSymbols == numSelectors);

		for (uint8 i = numSymbols; i > 0; i--) {

			// Append state symbol to default set cell call
			string memory symbolString = toSymbolString(
				uint256(bytes32(symbols[(i-1)*4:
					((i-1)*4 + 3)])), 4);

			bytes memory func = abi.encodePacked("setCellu",
				abi.encodePacked(symbolString), "()");

			// Calulate the signature for set call function
			bytes4 sel = bytes4(keccak256(abi.encodePacked(func)));

			// Check if rule exists in the level contract
			bytes4 levelSel;
			assembly {
				let word := mload(add(selectors, 0x60))
				let shift := shr(sub(256, mul(i, 32)), word)
				levelSel := shl(224, and(shift, 0xFFFFFFFFFFFFFFFF))
			}

			assert(levelSel == sel);

			// Add the rule
			rules[i] = levelSel;
		}
	}

	// Setting a cell value as per the rule
	function setCell(uint8 input) external returns(uint8 output) {

		//
	}

	// 
	function toSymbolString(uint256 value, uint256 length) internal pure returns (string memory) {
	    uint256 localValue = value>>(28*8);

	    bytes memory buffer = new bytes(2 * length);
	    for (uint256 i = 0; i < (2 * length); i++) {
	        buffer[(2 * length) - 1 - i] = HEX_DIGITS[localValue & 0xf];
	        localValue >>= 4;
	    }
	    if (localValue != 0) {
	        revert ();
	    }
	    return string(buffer);
	}
}

