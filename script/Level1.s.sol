// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.27;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {BaseLevelD} from "../src/BaseLevel.d.sol";
import {BaseStateD} from "../src/BaseState.d.sol";
import {BaseSymbolD} from "../src/BaseSymbol.d.sol";
import {BaseDataD} from "../src/BaseData.d.sol";
import {Level1D} from "../src/Level1.d.sol";

contract DeployLevel1 is Script {

	function run() external {

		bytes memory _levelNum = _setLevelNum(1);
		bytes memory _state = _setState(1);
		bytes memory _symbols = _setSymbol(1);
        //Level1D level1 = new Level1D(_levelNum, _state, _symbols);
        bytes memory _levelCode = abi.encodePacked(vm.getCode("Level1.d.sol:Level1D"), 
            abi.encode(_levelNum, _state, _symbols));

        uint256 len1;
        uint256 len2;
        bytes memory coode = type(Level1D).creationCode;
        assembly {
            len1 := mload(add(_levelCode, 0x00))
            len2 := mload(add(coode, 0x00))            
        }
        console.log("len1:", len1);
        console.log("len2:", len2);

		vm.startBroadcast();


        // Deploy using create2
/*        bytes memory code = abi.encodePacked(
            abi.encode(_levelCode),
            abi.encode(_levelNum),
            abi.encode(_state),
            abi.encode(_symbols)
        );
*/
        address target;
        uint256 len;
        assembly {
            len := mload(_levelCode)
            target := create2(0, add(_levelCode, 0x20), mload(_levelCode), 0x18)
        }
        console.log("len:", len);
        console.log("target:", target);
        if (target != address(0)) {
            (bool ret, bytes memory addr) = target.call{value: 0}(
                abi.encodeWithSignature("getState1()")
            );

            if (ret == true) {
                console.log("(ret == true)");
                uint256 test;
                assembly {
                    test := mload(add(addr, 0x20))
                }
                console.log("test:", test);
            }
        }

		//Level1D level1 = new Level1D(_levelNum, _state, _symbols);

		//level1.copyLevelData();

        //uint256 cell = level1.getState(0, 1);
		vm.stopBroadcast();
        //console.log("cell state:", cell);
	}

    // Internal function to set levelnum
    function _setLevelNum(uint8 _num) internal pure 
        returns (bytes memory _levelNum) {

        _levelNum = abi.encodePacked(_num);
    }

    // Internal function to set state
    function _setState(uint8 _num) internal pure 
        returns (bytes memory _state) {

        if (_num == 1) {
            // Set state of level 1 i.e 3x3 matrix
            _state = new bytes(9);

            // [X,  ,  ] R0
            _state[0] = bytes1(uint8(1)); 
            _state[1] = bytes1(uint8(2)); 
            _state[2] = bytes1(uint8(3)); 

            // [ ,  , O] R1
            _state[3] = bytes1(uint8(4)); 
            _state[4] = bytes1(uint8(5)); 
            _state[5] = bytes1(uint8(6)); 

            // [O,  X,  ] R2
            _state[6] = bytes1(uint8(7)); 
            _state[7] = bytes1(uint8(8)); 
            _state[8] = bytes1(uint8(9)); 

            // C0  C1 C2
            // [X,  ,  ] R0
            // [ ,  , O] R1
            // [O, X,  ] R2
        }
	}

    // Internal function to set symbols
    function _setSymbol(uint8 num) internal pure 
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

            // [0xe29d8c00e2ad9500]
        }
	}	
}