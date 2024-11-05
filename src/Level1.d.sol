// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.27;

import "./BaseLevel.d.sol";
import "./BaseState.d.sol";
import "./BaseSymbol.d.sol";
import "./BaseData.d.sol";
import {console} from "forge-std/console.sol";

// Level defination and implementation
contract Level1D is BaseLevelD, BaseStateD, BaseSymbolD, BaseDataD {

	constructor (bytes memory levelNum,
				 bytes memory state,
		         bytes memory symbols)
		BaseDataD(levelNum, state, symbols) {
	}

	// Inhertied from BaseDataD loads Level 1
	function copyLevelData() public override returns(bytes memory _data){

		// Fetches data from snapshot
		_data = BaseDataD.copyLevelData();

		bytes memory _num;
		bytes memory _state;
		bytes memory _symbol;
		uint8 _numlen = 1;
		uint8 _statelen = 9;
		uint8 _symbollen = 2;

		assembly {
			let len := mload(_data)
			let ptr := add(_data, 0x20)
			_num := ptr
			ptr := add(ptr, mul(_numlen, 0x20))
			_state := ptr
			ptr := add(ptr, mul(_statelen, 0x20))
			_symbol := ptr
			ptr := add(ptr, mul(_symbollen, 0x20))

			if gt(ptr, add(add(_data, 0x20), len)) {
				revert(0, 0)
			}
		}

		// Copy level num
		assert(BaseLevelD.copyLevel(_num));
		// Copy level state as per schema
		assert(this._copyState1(_state));
		// Copy level symbols as per schema
		assert(this._copySymbol1(_symbol));
	}

	// Copies state into game storage as per schema
	function _copyState1(bytes calldata cell) public returns (bool success){

		State memory _state = State({v: new uint256[][](3)});
        _state.v[0] = new uint256[](3);
        _state.v[1] = new uint256[](3);
        _state.v[2] = new uint256[](3);

        // [1, 2, 3] R0
        _state.v[0][0] = uint256(uint8(cell[0]));
        _state.v[0][1] = uint256(uint8(cell[1]));
        _state.v[0][2] = uint256(uint8(cell[2]));

        // [4, 5, 7] R1
        _state.v[1][0] = uint256(uint8(cell[3]));
        _state.v[1][1] = uint256(uint8(cell[4]));
        _state.v[1][2] = uint256(uint8(cell[5]));

        // [7, 8, 9] R2
        _state.v[2][0] = uint256(uint8(cell[6]));
        _state.v[2][1] = uint256(uint8(cell[7]));
        _state.v[2][2] = uint256(uint8(cell[8]));       

        // C0  C1 C2
        // [cell[0], cell[1], cell[2]] R0
        // [cell[3], cell[4], cell[5]] R1
        // [cell[6], cell[7], cell[8]] R2
		success = BaseStateD.copyState(_state);
	}	

	// Copies symbols into game storage as per schema
	function _copySymbol1(bytes calldata _symbols) public returns (bool success){

        Symbols memory s = Symbols({v: new bytes4[](2)});
        s.v[0] = bytes4(_symbols[0:4]); //hex"e29d8c00"
        s.v[1] = bytes4(_symbols[4:8]); //hex"e29d8c00"

		success = BaseSymbolD.copySymbol(s);
	}

	// ❌
	function setCellue29d8c00(uint8 row, uint8 col, uint8 value) external {
		board.v[row][col] = value;
	}
	
	// ⭕  
	function setCellue2ad9500(uint8 row, uint8 col, uint8 value) external {
		board.v[row][col] = value;
	}

	// Inherited from BaseState - all implemented and supported states in level
    function supportedStates() public pure override returns (bytes memory) {

    	return abi.encodePacked(bytes4(this.setCellue29d8c00.selector),  // ❌
    							bytes4(this.setCellue2ad9500.selector)); // ⭕
    }

}
