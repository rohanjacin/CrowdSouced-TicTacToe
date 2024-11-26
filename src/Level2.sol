// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.27;

import "./BaseLevel.sol";
import "./BaseState.sol";
import "./BaseSymbol.sol";
import "./Level1.sol";
import "./BaseData.sol";

// Level defination and implementation
contract Level2 is BaseLevel, BaseState, BaseSymbol, BaseData {

	constructor(bytes memory _levelnum, State memory _state, 
		Symbols memory _symbols)
		BaseLevel(_levelnum)
		BaseState(_state)
		BaseSymbol(_symbols) {
	}

	// Fetched Level 1 pre-filled data
	function fetchLevelData() public returns(bytes memory) {
		return BaseData.copyData(data);
	}

	// Loads Level 2 with pre-filled data
	function copyLevelData(bytes calldata _levelNumData,
		bytes calldata _stateData, bytes calldata _symbolsData)
		public returns(bool success){

		// Copy level num
		success = BaseLevel.copyLevel(_levelNumData);
		// Copy level state as per schema
		success =_copyState(_stateData);
		// Copy level symbols as per schema
		success =_copySymbol(_symbolsData);
	}

	// Copies state into game storage as per schema
	function _copyState(bytes calldata cell) internal returns (bool success){

		State memory _state = State({v: new uint256[][](9)});
            _state.v[0] = new uint256[](9);
            _state.v[1] = new uint256[](9);
            _state.v[2] = new uint256[](9);
            _state.v[3] = new uint256[](9);
            _state.v[4] = new uint256[](9);
            _state.v[5] = new uint256[](9);
            _state.v[6] = new uint256[](9);
            _state.v[7] = new uint256[](9);
            _state.v[8] = new uint256[](9);

            // [1, 2, 3, 4, 5, 6, 7, 8, 9] R0
            _state.v[0][0] = uint8(cell[0]);
            _state.v[0][1] = uint8(cell[1]);
            _state.v[0][2] = uint8(cell[2]);
            _state.v[0][3] = uint8(cell[3]);
            _state.v[0][4] = uint8(cell[4]);
            _state.v[0][5] = uint8(cell[5]);
            _state.v[0][6] = uint8(cell[6]);
            _state.v[0][7] = uint8(cell[7]);
            _state.v[0][8] = uint8(cell[8]);

            // [10, 11, 12, 13, 14, 15, 16, 17, 18] R1
            _state.v[1][0] = uint8(cell[9]);
            _state.v[1][1] = uint8(cell[10]);
            _state.v[1][2] = uint8(cell[11]);
            _state.v[1][3] = uint8(cell[12]);
            _state.v[1][4] = uint8(cell[13]);
            _state.v[1][5] = uint8(cell[14]);
            _state.v[1][6] = uint8(cell[15]);
            _state.v[1][7] = uint8(cell[16]);
            _state.v[1][8] = uint8(cell[17]);

            // [19, 20, 21, 22, 23, 24, 25, 26, 27] R2
            _state.v[2][0] = uint8(cell[18]);
            _state.v[2][1] = uint8(cell[19]);
            _state.v[2][2] = uint8(cell[20]);
            _state.v[2][3] = uint8(cell[21]);
            _state.v[2][4] = uint8(cell[22]);
            _state.v[2][5] = uint8(cell[23]);
            _state.v[2][6] = uint8(cell[24]);
            _state.v[2][7] = uint8(cell[25]);
            _state.v[2][8] = uint8(cell[26]);

            // [28, 29, 30, 31, 32, 33, 34, 35, 36] R3
            _state.v[3][0] = uint8(cell[27]);
            _state.v[3][1] = uint8(cell[28]);
            _state.v[3][2] = uint8(cell[29]);
            _state.v[3][3] = uint8(BaseState.getState(0, 0)); // Level 1       C0 C1 C2 
            _state.v[3][4] = uint8(BaseState.getState(0, 1)); // Level 1   R0 [  ,  ,  ]
            _state.v[3][5] = uint8(BaseState.getState(0, 2)); // Level 1
            _state.v[3][6] = uint8(cell[33]);
            _state.v[3][7] = uint8(cell[34]);
            _state.v[3][8] = uint8(cell[35]);

            // [37, 38, 39, 40, 41, 42, 43, 44, 45] R4
            _state.v[4][0] = uint8(cell[36]);
            _state.v[4][1] = uint8(cell[37]);
            _state.v[4][2] = uint8(cell[38]);
            _state.v[4][3] = uint8(BaseState.getState(1, 0)); // Level 1       C0 C1 C2 
            _state.v[4][4] = uint8(BaseState.getState(1, 1)); // Level 1   R1 [  ,  ,  ]
            _state.v[4][5] = uint8(BaseState.getState(1, 2)); // Level 1
            _state.v[4][6] = uint8(cell[42]);
            _state.v[4][7] = uint8(cell[43]);
            _state.v[4][8] = uint8(cell[44]); 

            // [46, 47, 48, 49, 50, 51, 52, 53, 54] R5
            _state.v[5][0] = uint8(cell[45]);
            _state.v[5][1] = uint8(cell[46]);
            _state.v[5][2] = uint8(cell[47]);
            _state.v[5][3] = uint8(BaseState.getState(2, 0)); // Level 1       C0 C1 C2 
            _state.v[5][4] = uint8(BaseState.getState(2, 1)); // Level 1   R2 [  ,  ,  ]
            _state.v[5][5] = uint8(BaseState.getState(2, 2)); // Level 1
            _state.v[5][6] = uint8(cell[51]);
            _state.v[5][7] = uint8(cell[52]);
            _state.v[5][8] = uint8(cell[53]);

            // [55, 56, 57, 58, 59, 60, 61, 62, 63] R6
            _state.v[6][0] = uint8(cell[54]);
            _state.v[6][1] = uint8(cell[55]);
            _state.v[6][2] = uint8(cell[56]);
            _state.v[6][3] = uint8(cell[57]);
            _state.v[6][4] = uint8(cell[58]);
            _state.v[6][5] = uint8(cell[59]);
            _state.v[6][6] = uint8(cell[60]);
            _state.v[6][7] = uint8(cell[61]);
            _state.v[6][8] = uint8(cell[62]);

            // [64, 65, 66, 67, 68, 69, 70, 71, 72] R7
            _state.v[7][0] = uint8(cell[63]);
            _state.v[7][1] = uint8(cell[64]);
            _state.v[7][2] = uint8(cell[65]);
            _state.v[7][3] = uint8(cell[66]);
            _state.v[7][4] = uint8(cell[67]);
            _state.v[7][5] = uint8(cell[68]);
            _state.v[7][6] = uint8(cell[69]);
            _state.v[7][7] = uint8(cell[70]);
            _state.v[7][8] = uint8(cell[71]);

            // [73, 74, 75, 76, 77, 78, 79, 80, 81] R8
            _state.v[8][0] = uint8(cell[72]);
            _state.v[8][1] = uint8(cell[73]);
            _state.v[8][2] = uint8(cell[74]);
            _state.v[8][3] = uint8(cell[75]);
            _state.v[8][4] = uint8(cell[76]);
            _state.v[8][5] = uint8(cell[77]);
            _state.v[8][6] = uint8(cell[78]);
            _state.v[8][7] = uint8(cell[79]);
            _state.v[8][8] = uint8(cell[80]);
	
		success = BaseState.copyState(_state);
	}	

	// Copies symbols into game storage as per schema
	function _copySymbol(bytes calldata _symbols) public returns (bool success){

        Symbols memory s = Symbols({v: new bytes4[](4)});
        s.v[0] = bytes4(_symbols[0:4]); //hex"e29d8c00"
        s.v[1] = bytes4(_symbols[4:8]); //hex"e2ad9500"
        s.v[2] = bytes4(_symbols[8:12]); //hex"e2ad9000"
        s.v[3] = bytes4(_symbols[12:16]); //hex"f09f92a3"

		success = BaseSymbol.copySymbol(s);
	}

	// ❌
	function setCellue29d8c00(uint8 row, uint8 col, uint8 value) external {
		BaseState.setState(row, col, value);
	}
	
	// ⭕   
	function setCellue2ad9500(uint8 row, uint8 col, uint8 value) external {
		BaseState.setState(row, col, value);
	}

	// ⭐
	function setCellue2ad9000(uint8 row, uint8 col, uint8 value) external {
		BaseState.setState(row, col, value);
	}
	
	// 💣
	function setCelluf09f92a3(uint8 row, uint8 col, uint8 value) external {
		BaseState.setState(row, col, value);
	}

	// Inherited from BaseState - all implemented and supported states in level
    function supportedStates() public pure override returns (bytes memory) {

    	return abi.encodePacked(bytes4(this.setCellue29d8c00.selector),  // ❌
    							bytes4(this.setCellue2ad9500.selector),  // ⭕
    							bytes4(this.setCellue2ad9000.selector),  // ⭐
    							bytes4(this.setCelluf09f92a3.selector)); // 💣
    }
}