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
import {Level1D} from "../src/Level1.d.sol";
import {Level2D} from "../src/Level2.d.sol";
import { ECDSA } from "openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";
import "openzeppelin-contracts/contracts/utils/cryptography/MessageHashUtils.sol";
import "semaphore/packages/contracts/contracts/interfaces/ISemaphore.sol";

enum CellValue { Empty , X, O}

contract DeployLevelConfigurator is Script {

	function run() external {

		bytes memory _levelNum = _generateLevelNum(2);
		bytes memory _state = _generateState(2);
		bytes memory _symbols = _generateSymbols(2);

        uint256 privKey = vm.envUint("PRIVATE_KEY_BIDDER");
        address signer = vm.addr(privKey);
		vm.startBroadcast(signer);

/*		LevelConfigurator levelConfigurator = new LevelConfigurator(
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
		vm.stopBroadcast();
	}

    // Generates level number
    function _generateLevelNum(uint8 _num) internal pure
        returns (bytes memory _levelNum) {

        if (_num == 1)
            _levelNum = abi.encodePacked(_num);
        else if (_num == 2) 
            _levelNum = abi.encodePacked(_num);
    }

    // Generates state for a level
    function _generateState(uint8 _num) internal pure
        returns (bytes memory _levelState) {

        if (_num == 1)
            _levelState = hex"010000000000000002";
        else if (_num == 2)
            _levelState = hex"020000000000000000"
                          hex"000000000000000001"
                          hex"010200000000000000"
                          hex"000001000000000200"
                          hex"000000000200010000"            
                          hex"000000020001000000"
                          hex"000002000100000000"
                          hex"000000010002000000"
                          hex"000000000000020100";
    }

    // Generates symbols for a level
    function _generateSymbols(uint8 _num) internal pure
        returns (bytes memory _levelSymbols) {
        bytes4 X = hex"e29d8c00"; //unicode"❌";
        bytes4 O = hex"e2ad9500"; //unicode"⭕";            
        bytes4 Star = unicode"⭐";
        bytes4 Bomb = unicode"💣";

        if (_num == 1) {
            _levelSymbols = abi.encodePacked(X, O);
        }
        else if (_num == 2) {
            _levelSymbols = abi.encodePacked(X, O, Star, Bomb);
        }
    }	
}