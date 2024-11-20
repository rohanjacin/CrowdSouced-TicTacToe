// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.27;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {BaseLevelD} from "../src/BaseLevel.d.sol";
import {BaseStateD} from "../src/BaseState.d.sol";
import {BaseSymbolD} from "../src/BaseSymbol.d.sol";
import {BaseDataD} from "../src/BaseData.d.sol";
import {LevelConfigurator} from "../src/LevelConfigurator.sol";
import {ILevelConfigurator} from "../src/ILevelConfigurator.sol";
import {ILevelD} from "../src/ILevel.d.sol";
import {Level1D} from "../src/Level1.d.sol";
import {Level2D} from "../src/Level2.d.sol";
import { ECDSA } from "openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";
import "openzeppelin-contracts/contracts/utils/cryptography/MessageHashUtils.sol";
import "semaphore/packages/contracts/contracts/interfaces/ISemaphore.sol";
import "../src/ILevelConfigurator.sol";
import {IGame} from "../src/IGame.sol";

enum CellValue { Empty , X, O}

contract ProposeLevel1 is Script {

	function run() external {

		bytes memory _levelNum = _setLevelNum(1);
		bytes memory _state = _setState(1);
		bytes memory _symbols = _setSymbol(1);

        uint256 privKey = vm.envUint("PRIVATE_KEY");
        address signer = vm.addr(privKey);

        vm.startBroadcast(signer);

        address levelConfigurator = IGame(
            address(0xAe387934b3632477F4B0299F5E4d65c8c2D2b7f1))
            .getLevelConfigurator();
        ILevelConfigurator(levelConfigurator)
		  .initLevel(type(Level1D).creationCode, _levelNum, _state, _symbols);

        bytes32 _msghash = keccak256(abi.encodePacked(type(Level1D).creationCode,
                            _levelNum, _state, _symbols));

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privKey,
            MessageHashUtils.toEthSignedMessageHash(_msghash));

        ILevelConfigurator(levelConfigurator)
            .deployLevel(type(Level1D).creationCode,
                          _levelNum, _state, _symbols, _msghash, 0x19, 
                          abi.encodePacked(r, s, v));

		vm.stopBroadcast();
	}

    // Generates level number
    function _generateLevelNum() internal pure
        returns (bytes memory _levelNum) {

        _levelNum = abi.encodePacked(uint8(1));
    }

    // Generates state for a level
    function _generateState() internal pure
        returns (bytes memory _levelState) {

        _levelState = hex"010000000000000000";
    }

    // Generates symbols for a level
    function _generateSymbols() internal pure
        returns (bytes memory _levelSymbols) {
        bytes4 X = hex"e29d8c00"; //unicode"❌";
        bytes4 O = hex"e2ad9500"; //unicode"⭕";            

        _levelSymbols = abi.encodePacked(X, O);
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
            _state[1] = bytes1(uint8(0)); 
            _state[2] = bytes1(uint8(0)); 

            // [ ,  , O] R1
            _state[3] = bytes1(uint8(0)); 
            _state[4] = bytes1(uint8(0)); 
            _state[5] = bytes1(uint8(0)); 

            // [O,  X,  ] R2
            _state[6] = bytes1(uint8(0)); 
            _state[7] = bytes1(uint8(0)); 
            _state[8] = bytes1(uint8(0)); 

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
        }
    }   

}

contract ProposeLevel2 is Script {

    function run() external {

        bytes memory _levelNum = _generateLevelNum();
        bytes memory _state = _generateState();
        bytes memory _symbols = _generateSymbols();

        uint256 privKey = vm.envUint("PRIVATE_KEY_BIDDER2");
        address signer = vm.addr(privKey);
        vm.startBroadcast(signer);

        address levelConfigurator = IGame(
            address(0xAe387934b3632477F4B0299F5E4d65c8c2D2b7f1))
            .getLevelConfigurator();

        ILevelConfigurator(levelConfigurator)
          .initLevel(type(Level2D).creationCode, _levelNum, _state, _symbols);

        bytes32 _msghash = keccak256(abi.encodePacked(type(Level2D).creationCode,
                            _levelNum, _state, _symbols));

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privKey,
            MessageHashUtils.toEthSignedMessageHash(_msghash));

        ILevelConfigurator(levelConfigurator)
            .deployLevel(type(Level2D).creationCode,
                          _levelNum, _state, _symbols, _msghash, 0x19, 
                          abi.encodePacked(r, s, v));

        vm.stopBroadcast();
    }

    // Generates level number
    function _generateLevelNum() internal pure
        returns (bytes memory _levelNum) {

        _levelNum = abi.encodePacked(uint8(2));
    }

    // Generates state for a level
    function _generateState() internal pure
        returns (bytes memory _levelState) {

        _levelState = hex"020000000000000000"
                      hex"000000000000000001"
                      hex"000200000000000000"
                      hex"000000000000000000"
                      hex"000000000000000000"            
                      hex"000000000000000000"
                      hex"000000000000000000"
                      hex"000000010002000000"
                      hex"000000000000020100";
    }

    // Generates symbols for a level
    function _generateSymbols() internal pure
        returns (bytes memory _levelSymbols) {
        bytes4 X = hex"e29d8c00"; //unicode"❌";
        bytes4 O = hex"e2ad9500"; //unicode"⭕";            
        bytes4 Star = hex"e2ad9000"; //unicode"⭐";
        bytes4 Bomb = hex"f09f92a3"; //unicode"💣";

        _levelSymbols = abi.encodePacked(X, O, Star, Bomb);
    }   
}