// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.27;

// Basic symbol layout
abstract contract BaseSymbol {

	// Symbols (unicode 4 bytes max)
	struct Symbols {
		bytes4[] v;
	}

	// Unicode mapping
	Symbols symbols;

	constructor(Symbols memory _symbols) {
		symbols = _symbols;
	}

	// Updates the base symbol data to the callers
	// context when delegated
	function copySymbol() public virtual returns(bytes memory id) {
		symbols = symbols;

		assembly {
			id := symbols.slot
		}		
	}
}
