// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.27;

import "forge-std/Test.sol";
import { console } from "forge-std/console.sol";
import "src/LevelConfigurator.sol";
import { ECDSA } from "openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";
import "openzeppelin-contracts/contracts/utils/cryptography/MessageHashUtils.sol";
import {Level1D} from "../src/Level1.d.sol";
import {Level2D} from "../src/Level2.d.sol";

contract TestLevelConfigurator is Test {
    using ECDSA for bytes32;

    function setUp() public {
        //levelConfig = new LevelConfigurator();
    }

    // Test if the contract was created properly
    function test_levelCofigurator() external {

    }

    // Generates sample level code
    function _generateLevelCode(uint8 _num) internal pure
        returns (bytes memory _levelCode) {

        // Level 1 contract init code (w/o constructore arguments)
        if (_num == 1) {
            _levelCode = type(Level1D).creationCode; 
        }
        else if (_num == 2) {
            _levelCode = type(Level2D).creationCode; 
        }        
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
            _levelState = hex"020000000000000003"
                          hex"000300000000000001"
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
        bytes4 X = unicode"❌";
        bytes4 O = unicode"⭕";            
        bytes4 Star = unicode"⭐";
        bytes4 Bomb = unicode"💣";

        if (_num == 1) {
            _levelSymbols = abi.encodePacked(X, O);
        }
        else if (_num == 2) {
            _levelSymbols = abi.encodePacked(X, O, Star, Bomb);
        }
    }

    // Test the level proposal submitted by Bidder
    function test_initLevel() external {

        // Should clears initial checks for code, level number, 
        // state length and state symbol length for Level 1
        LevelConfigurator levelConfig1 = new LevelConfigurator(vm.addr(1));
        bytes memory code1 = _generateLevelCode(1);
        bytes memory levelNum1 = _generateLevelNum(1);
        bytes memory levelState1 = _generateState(1);
        bytes memory levelSymbols1 = _generateSymbols(1);
        bytes32 levelCodeHash = keccak256(abi.encodePacked(code1));
        levelConfig1.initLevel(levelNum1, levelState1, levelSymbols1, levelCodeHash);


/*        // Should clears initial checks for code, level number, 
        // state length and state symbol length for Level 2
        LevelConfigurator levelConfig2 = new LevelConfigurator(address(0x1));
        bytes memory code2 = _generateLevelCode(2);
        bytes memory levelNum2 = _generateLevelNum(2);
        bytes memory levelState2 = _generateState(2);
        bytes memory levelSymbols2 = _generateSymbols(2);

        levelConfig2.initLevel(code2, levelNum2, levelState2, levelSymbols2);

*/
       // Should fail initial checks for code, level number, 
        // state length and state symbol length for Level 1 if
        // state length is wrong
/*        LevelConfigurator levelConfig3 = new LevelConfigurator();
        bytes memory code3 = _generateLevelCode(1);
        bytes memory levelNum3 = _generateLevelNum(1);
        bytes memory levelState3 = _generateState(2);
        bytes memory levelSymbols3 = _generateSymbols(1);

        vm.expectRevert();
        levelConfig3.initLevel(code3, levelNum3, levelState3, levelSymbols3);


        // Should fail initial checks for code, level number, 
        // state length and state symbol length for Level 2 if
        // state symbols is wrong
        LevelConfigurator levelConfig4 = new LevelConfigurator();
        bytes memory code4 = _generateLevelCode(2);
        bytes memory levelNum4 = _generateLevelNum(2);
        bytes memory levelState4 = _generateState(2);
        bytes memory levelSymbols4 = _generateSymbols(3);

        vm.expectRevert();
        levelConfig4.initLevel(code4, levelNum4, levelState4, levelSymbols4);
*/
    }

    // Test State contents
    function test__checkStateValidity() external {

        // Should clear check for level 1 with X and O
/*        bytes memory levelnum1 = _generateLevelNum(1);
        bytes memory state1 = _generateState(1);
        bytes memory symbols1 = _generateSymbols(1);

        LevelConfigurator levelConfig1 = new LevelConfigurator(vm.addr(1));
        levelConfig1._checkStateValidity(levelnum1, state1, symbols1);


*/        // Should clear check for level 2 with X and O
/*        bytes memory state2 = _generateState(2);
        bytes memory symbols2 = _generateSymbols(1);

        LevelConfigurator levelConfig2 = new LevelConfigurator();
        levelConfig2._checkStateValidity(2, state2, symbols2);
*/
        // Should clear check for level 2 with X and O
/*        bytes memory levelNum2 = _generateLevelNum(2);
        bytes memory state2 = _generateState(2);
        bytes memory symbols2 = _generateSymbols(2);

        LevelConfigurator levelConfig2 = new LevelConfigurator();
        assertEq(levelConfig2._checkStateValidity(
                            levelNum2, state2, symbols2), 0);
*/    }


    // Test cache reference of Level code, number, state and symbols
    function test__cacheLevel() external {

/*        LevelConfigurator levelConfig2 = new LevelConfigurator(address(0x01));
        bytes memory code2 = _generateLevelCode(1);
        bytes memory levelNum2 = _generateLevelNum(1);
        bytes memory levelState2 = _generateState(1);
        bytes memory levelSymbols2 = _generateSymbols(1);
        bytes32 code2Hash = keccak256(abi.encodePacked(code2));

        // Should cache the hash of the level config
        uint256 privKey = 0xabc123;
        address signer = vm.addr(privKey);

        vm.prank(signer);
        levelConfig2._cacheLevel(levelNum2, levelState2, levelSymbols2, code2Hash);
        LevelConfig memory config = levelConfig2.getProposal(signer);

        assertEq(config.codeHash, code2Hash);
        assertEq(config.levelNumLen, 1);
        assertEq(config.stateLen, 9);
        assertEq(config.symbolLen, 8);
        assertEq(config.hash, keccak256(abi.encodePacked(levelNum2,
                        levelState2, levelSymbols2, code2Hash)));*/
    }

    // Test storage of Level number, state and symbols as datasnapshot (code)
    function test__storeLevel() external {

/*        LevelConfigurator levelConfig2 = new LevelConfigurator(address(0x01));
        bytes memory code2 = _generateLevelCode(1);
        bytes memory levelNum2 = _generateLevelNum(1);
        bytes memory levelState2 = _generateState(1);
        bytes memory levelSymbols2 = _generateSymbols(1);

        // Should return a non zero address
        //address loc = levelConfig2._storeLevel(levelNum2, levelState2, levelSymbols2);
        //assertTrue(loc != address(0));

        // Should return non zero size memory bytes pointer 
        //bytes memory d = levelConfig2._retrieveLevel(loc);
*/
    }

    // Test deploy of Level code
    function test__deployLevel() external {

/*        LevelConfigurator levelConfig2 = new LevelConfigurator(address(0x01));
        bytes memory code2 = _generateLevelCode(1);
        bytes memory levelNum2 = _generateLevelNum(1);
        bytes memory levelState2 = _generateState(1);
        bytes memory levelSymbols2 = _generateSymbols(1);
        bytes32 code2Hash = keccak256(abi.encodePacked(code2));

        // Should return a non zero address
        uint256 privKey = 0xabc123;
        address signer = vm.addr(privKey);
        bytes32 msghash = keccak256(abi.encodePacked(levelNum2,
            levelState2, levelSymbols2, code2Hash));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privKey,
            MessageHashUtils.toEthSignedMessageHash(msghash));

        vm.prank(signer);
        levelConfig2._cacheLevel(levelNum2, levelState2, levelSymbols2, code2Hash);

        vm.prank(signer);
        assertTrue(levelConfig2.deployLevel(code2, levelNum2,
                                levelState2, levelSymbols2, msghash, 
                                0x01, abi.encodePacked(r, s, v)));*/
    }
}