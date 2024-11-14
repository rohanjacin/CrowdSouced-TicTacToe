// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.27;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {BaseLevel} from "../src/BaseLevel.sol";
import {BaseState} from "../src/BaseState.sol";
import {BaseSymbol} from "../src/BaseSymbol.sol";
import {BaseData} from "../src/BaseData.sol";
import {GameD} from "../src/Game.d.sol";
import {IGame} from "../src/IGame.sol";

enum CellValue { Empty , X, O}

contract DeployGame is Script {

	function run() external {

		bytes memory _levelNum = _setLevelNum(2);
		BaseState.State memory _state = _setState(2);
		BaseSymbol.Symbols memory _symbols = _setSymbol(2);

        uint256 privKey = vm.envUint("PRIVATE_KEY");
        address signer = vm.addr(privKey);
        vm.startBroadcast(signer);

		GameD game1 = new GameD(signer);
        game1.newGame(1);
        
        vm.stopBroadcast();
	}

    // Internal function to set levelnum
    function _setLevelNum(uint8 _num) internal pure 
        returns (bytes memory _levelNum) {

        _levelNum = abi.encodePacked(_num);
    }

    // Internal function to set state
    function _setStateBytes(uint8 _num) internal pure 
        returns (bytes memory _state) {

        if (_num == 1) {
            // Set state of level 1 i.e 3x3 matrix
            _state = new bytes(9);

            // [X,  ,  ] R0
            _state[0] = bytes1(uint8(CellValue.Empty)); 
            _state[1] = bytes1(uint8(CellValue.Empty)); 
            _state[2] = bytes1(uint8(CellValue.Empty)); 

            // [ ,  , O] R1
            _state[3] = bytes1(uint8(CellValue.Empty)); 
            _state[4] = bytes1(uint8(CellValue.Empty)); 
            _state[5] = bytes1(uint8(CellValue.Empty)); 

            // [O,  X,  ] R2
            _state[6] = bytes1(uint8(CellValue.Empty)); 
            _state[7] = bytes1(uint8(CellValue.Empty)); 
            _state[8] = bytes1(uint8(CellValue.Empty)); 

            // C0  C1 C2
            // [X,  ,  ] R0
            // [ ,  , O] R1
            // [O, X,  ] R2
        }
	}

    // Internal function to set symbols
    function _setSymbolBytes(uint8 num) internal pure 
        returns (bytes memory _symbols) {

        if (num == 1) {

            _symbols = new bytes(8);

            // ❌ hex"e29d8c00"
            _symbols[0] = hex"e2";
            _symbols[1] = hex"9d";
            _symbols[2] = hex"8c";
            _symbols[3] = hex"00";

            // ⭕ hex"e2ad9500"
            _symbols[4] = hex"e2";
            _symbols[5] = hex"ad";
            _symbols[6] = hex"95";
            _symbols[7] = hex"00";

            // ⭐ hex"e2ad9000"
            _symbols[8] = hex"e2";
            _symbols[9] = hex"ad";
            _symbols[10] = hex"90";
            _symbols[11] = hex"00";

            // 💣 hex"f09f92a3"
            _symbols[8] = hex"f0";
            _symbols[9] = hex"9f";
            _symbols[10] = hex"92";
            _symbols[11] = hex"a3";                        
        }
	}

    // Internal function to set state
    function _setState(uint8 _num) internal pure 
        returns (BaseState.State memory state) {

        if (_num == 1) {
            // Set state of level 1 i.e 3x3 matrix
            state = BaseState.State({v: new uint256[][](3)});
            state.v[0] = new uint256[](3);
            state.v[1] = new uint256[](3);
            state.v[2] = new uint256[](3);

            // [1, 2, 3] R0
            state.v[0][0] = uint256(CellValue.X);
            state.v[0][1] = uint256(CellValue.Empty);
            state.v[0][2] = uint256(CellValue.Empty);

            // [4, 5, 7] R1
            state.v[1][0] = uint256(CellValue.Empty);
            state.v[1][1] = uint256(CellValue.Empty);
            state.v[1][2] = uint256(CellValue.Empty);

            // [7, 8, 9] R2
            state.v[2][0] = uint256(CellValue.Empty);
            state.v[2][1] = uint256(CellValue.Empty);
            state.v[2][2] = uint256(CellValue.O);        

            // C0  C1 C2
            // [1, 2, 3] R0
            // [4, 5, 7] R1
            // [7, 8, 9] R2
        }
        else if (_num == 2) {

            // Set state of level 2 i.e 9x9 matrix
            state = BaseState.State({v: new uint256[][](9)});
            state.v[0] = new uint256[](9);
            state.v[1] = new uint256[](9);
            state.v[2] = new uint256[](9);
            state.v[3] = new uint256[](9);
            state.v[4] = new uint256[](9);
            state.v[5] = new uint256[](9);
            state.v[6] = new uint256[](9);
            state.v[7] = new uint256[](9);
            state.v[8] = new uint256[](9);

            // [1, 2, 3, 4, 5, 6, 7, 8, 9] R0
            state.v[0][0] = uint(CellValue.X);
            state.v[0][1] = uint(CellValue.O);
            state.v[0][2] = uint(CellValue.X);
            state.v[0][3] = uint(CellValue.O);
            state.v[0][4] = uint(CellValue.X);
            state.v[0][5] = uint(CellValue.X);
            state.v[0][6] = uint(CellValue.O);
            state.v[0][7] = uint(CellValue.O);
            state.v[0][8] = uint(CellValue.X);

            // [10, 11, 12, 13, 14, 15, 16, 17, 18] R1
            state.v[1][0] = uint(CellValue.X);
            state.v[1][1] = uint(CellValue.O);
            state.v[1][2] = uint(CellValue.X);
            state.v[1][3] = uint(CellValue.X);
            state.v[1][4] = uint(CellValue.X);
            state.v[1][5] = uint(CellValue.O);
            state.v[1][6] = uint(CellValue.O);
            state.v[1][7] = uint(CellValue.X);
            state.v[1][8] = uint(CellValue.O);

            // [19, 20, 21, 22, 23, 24, 25, 26, 27] R2
            state.v[2][0] = uint(CellValue.X);
            state.v[2][1] = uint(CellValue.O);
            state.v[2][2] = uint(CellValue.X);
            state.v[2][3] = uint(CellValue.O);
            state.v[2][4] = uint(CellValue.X);
            state.v[2][5] = uint(CellValue.O);
            state.v[2][6] = uint(CellValue.O);
            state.v[2][7] = uint(CellValue.O);
            state.v[2][8] = uint(CellValue.X);

            // [28, 29, 30, 31, 32, 33, 34, 35, 36] R3
            state.v[3][0] = uint(CellValue.O);
            state.v[3][1] = uint(CellValue.X);
            state.v[3][2] = uint(CellValue.O);
            state.v[3][3] = uint(CellValue.X);
            state.v[3][4] = uint(CellValue.O);
            state.v[3][5] = uint(CellValue.X);
            state.v[3][6] = uint(CellValue.X);
            state.v[3][7] = uint(CellValue.O);
            state.v[3][8] = uint(CellValue.X);

            // [37, 38, 39, 40, 41, 42, 43, 44, 45] R4
            state.v[4][0] = uint(CellValue.O);
            state.v[4][1] = uint(CellValue.O);
            state.v[4][2] = uint(CellValue.X);
            state.v[4][3] = uint(CellValue.O);
            state.v[4][4] = uint(CellValue.X);
            state.v[4][5] = uint(CellValue.O);
            state.v[4][6] = uint(CellValue.X);
            state.v[4][7] = uint(CellValue.X);
            state.v[4][8] = uint(CellValue.O); 

            // [46, 47, 48, 49, 50, 51, 52, 53, 54] R5
            state.v[5][0] = uint(CellValue.O);
            state.v[5][1] = uint(CellValue.X);
            state.v[5][2] = uint(CellValue.X);
            state.v[5][3] = uint(CellValue.O);
            state.v[5][4] = uint(CellValue.X);
            state.v[5][5] = uint(CellValue.O);
            state.v[5][6] = uint(CellValue.O);
            state.v[5][7] = uint(CellValue.O);
            state.v[5][8] = uint(CellValue.X);

            // [55, 56, 57, 58, 59, 60, 61, 62, 63] R6
            state.v[6][0] = uint(CellValue.X);
            state.v[6][1] = uint(CellValue.O);
            state.v[6][2] = uint(CellValue.X);
            state.v[6][3] = uint(CellValue.X);
            state.v[6][4] = uint(CellValue.O);
            state.v[6][5] = uint(CellValue.X);
            state.v[6][6] = uint(CellValue.O);
            state.v[6][7] = uint(CellValue.O);
            state.v[6][8] = uint(CellValue.X);

            // [64, 65, 66, 67, 68, 69, 70, 71, 72] R7
            state.v[7][0] = uint(CellValue.X);
            state.v[7][1] = uint(CellValue.O);
            state.v[7][2] = uint(CellValue.O);
            state.v[7][3] = uint(CellValue.Empty);
            state.v[7][4] = uint(CellValue.X);
            state.v[7][5] = uint(CellValue.O);
            state.v[7][6] = uint(CellValue.X);
            state.v[7][7] = uint(CellValue.X);
            state.v[7][8] = uint(CellValue.X);

            // [73, 74, 75, 76, 77, 78, 79, 80, 81] R8
            state.v[8][0] = uint(CellValue.X);
            state.v[8][1] = uint(CellValue.O);
            state.v[8][2] = uint(CellValue.X);
            state.v[8][3] = uint(CellValue.O);
            state.v[8][4] = uint(CellValue.X);
            state.v[8][5] = uint(CellValue.O);
            state.v[8][6] = uint(CellValue.X);
            state.v[8][7] = uint(CellValue.O);
            state.v[8][8] = uint(CellValue.O);

            //  C0  C1  C2  C3  C4  C5  C6  C7  C8
            // [01, 02, 03, 04, 05, 06, 07, 08, 09] R0
            // [10, 11, 12, 13, 14, 15, 16, 17, 18] R1
            // [19, 20, 21, 22, 23, 24, 25, 26, 27] R2
            // [28, 29, 30, 31, 32, 33, 34, 35, 36] R3
            // [37, 38, 39, 40, 41, 42, 43, 44, 45] R4
            // [46, 47, 48, 49, 50, 51, 52, 53, 54] R5
            // [55, 56, 57, 58, 59, 60, 61, 62, 63] R6
            // [64, 65, 66, 67, 68, 69, 70, 71, 72] R7
            // [73, 74, 75, 76, 77, 78, 79, 80, 81] R8
         }
    }

    // Internal function to set symbols
    function _setSymbol(uint8 num) internal pure 
        returns (BaseSymbol.Symbols memory symbols) {

        if (num == 1) {
            // Set if length of symbols is 2
            symbols = BaseSymbol.Symbols({v: new bytes4[](2)});
            symbols.v[0] = bytes4(hex"e29d8c00");
            symbols.v[1] = bytes4(hex"e2ad9500");            
        }
        else if (num == 2) {

            // Set if length of symbols is 4
            symbols = BaseSymbol.Symbols({v: new bytes4[](4)});
            symbols.v[0] = bytes4(hex"e29d8c00");
            symbols.v[1] = bytes4(hex"e2ad9500");
            symbols.v[2] = bytes4(hex"e2ad9000");
            symbols.v[3] = bytes4(hex"f09f92a3");
        }
    }    	
}

contract NewGame is Script {

    function run() external {

        uint256 privKey = vm.envUint("PRIVATE_KEY");
        address signer = vm.addr(privKey);
        vm.startBroadcast(signer);
        
        //IGame(address(0x8464135c8F25Da09e49BC8782676a84730C318bC))
        //    .newGame(2)(address(0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC));

        vm.stopBroadcast();
    }
}