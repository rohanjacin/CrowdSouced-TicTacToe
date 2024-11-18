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

enum CellValue { Empty , X, O}

contract ProposeLevel1 is Script {

	function run() external {

		bytes memory _levelNum = _generateLevelNum();
		bytes memory _state = _generateState();
		bytes memory _symbols = _generateSymbols();

        uint256 privKey = vm.envUint("PRIVATE_KEY_BIDDER1");
        address signer = vm.addr(privKey);
		vm.startBroadcast(signer);

/*		LevelConfigurator levelConfigurator = new LevelConfigurator(
                                signer, ISemaphore(address(0x02)));
*/
        address levelConfigurator = address(0x356bc565e99C763a1Ad74819D413A6D58E565Cf2);
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

/*        ILevelConfigurator.LevelConfig memory config = ILevelConfigurator(
            levelConfigurator).getProposal(signer);           

        (bool success) = ILevelD(config.codeAddress).copyLevelData(_levelNum, _state, _symbols);
        console.log("Success:", success);
*/
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
}

contract ProposeLevel2 is Script {

    function run() external {

        bytes memory _levelNum = _generateLevelNum();
        bytes memory _state = _generateState();
        bytes memory _symbols = _generateSymbols();

        uint256 privKey = vm.envUint("PRIVATE_KEY_BIDDER2");
        address signer = vm.addr(privKey);
        vm.startBroadcast(signer);

/*      LevelConfigurator levelConfigurator = new LevelConfigurator(
                                signer, ISemaphore(address(0x02)));
*/
        address levelConfigurator = address(0x356bc565e99C763a1Ad74819D413A6D58E565Cf2);
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

/*        ILevelConfigurator.LevelConfig memory config = ILevelConfigurator(
            levelConfigurator).getProposal(signer);           

        (bool success) = ILevelD(config.codeAddress).copyLevelData(_levelNum, _state, _symbols);
        console.log("Success:", success);
*/        vm.stopBroadcast();
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