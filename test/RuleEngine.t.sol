// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.27;

import "forge-std/Test.sol";
import { console } from "forge-std/console.sol";
import "src/RuleEngine.sol";
import "src/Level1.d.sol";

contract TestRuleEngine is Test {

    function setUp() public {
        //ruleEngine = new RuleEngine();
    }

    // Generates sample level code
    function _generateLevelCode(uint8 _num) internal 
        returns (bytes memory _levelCode) {

        // Level 1 contract init code (w/o constructore arguments)
        if (_num == 1) {
            _levelCode = hex"600460030160005260206000f3"; 
        }
        else if (_num == 2) {
            _levelCode = hex"600460030160005260206000f3"; 
        }        
    }

    // Generates symbols for a level
    function _generateSymbols(uint8 _num) internal 
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

    // Test if it adds rules properly
    function test_addRules() external {

/*        RuleEngine ruleEngine = new RuleEngine();
        Level1D levelA = new Level1D();

        bytes memory levelSymbols1 = _generateSymbols(1);

        ruleEngine.addRules(address(levelA), levelSymbols1);
*/    }
}