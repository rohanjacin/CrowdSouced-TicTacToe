// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.27;

import "./BaseLevel.d.sol";
import "./BaseState.d.sol";
import "./BaseSymbol.d.sol";
import "./BaseData.sol";
import "./LevelConfigurator.sol";
import "./ILevelConfigurator.sol";
import "./RuleEngine.sol";

// Players
enum Player { None, Player1, Player2 }
// Possible cell values
enum CellValueL { Empty , X, O}

// Errors
error LevelInvalid();
error LevelNotDeployed();
error LevelCopyFailed();
error PlayerAddressInvalid();

contract GameHouse {
	address public goV;
	address public levelConfigurator;
	address public ruleEngine;

	constructor() {
		//goV = new goV();
		//levelConfigurator = new LevelConfigurator();
		//ruleEngine = new RuleEngine();
	}
}

// Game info
struct GameInfo {
	GameHouse house;
	address player1;
	address player2;
	address levelAddress;
	Player winner;
	Player turn;
}

// Players move
struct Move {
	uint8 row;
	uint8 col;
}

// Game
contract Game is BaseLevelD, BaseStateD, BaseSymbolD, BaseData, RuleEngine {

	// SLOT 0 is from BaseLevel (Do NOT use SLOT 0)
	//uint8 level;

	// SLOT 1 is from BaseState (Do NOT use SLOT 1)
	//State board;

	// SLOT 2 is from BaseSymbols (Do NOT use SLOT 2)
	//Symbols symbols;

	// SLOT 3 is from BaseData (Do NOT use SLOT 3)
	//address data;

	// SLOT 4 is from RuleEngine (Do NOT use SLOT 4)
    //bytes16 private constant HEX_DIGITS = "0123456789abcdef";

	// SLOT 5 is from RuleEngine (Do NOT use SLOT 5)
	//mapping(uint8 => bytes4) rules;

	// SLOT 6 is for Game Admin
	address admin;

	// SLOT 7 is Game instance (id = level number)
	mapping(uint8 => GameInfo) public games;

	// Load the default state in Base State
	constructor(address _admin) 
		BaseLevelD()
		BaseStateD()
		BaseSymbolD()
		BaseData() {

		admin = _admin;
		// Game House components
		games[1].house = new GameHouse();
	}

	// Loads the level
	function loadLevel(address bidder) external onlyAdmin
		returns(bool success, string memory message) {

		LevelConfig memory config = LevelConfig(0, 0, 0, 0, 0, 0,
									address(0), address(0)); 
/*		(config.num, config.codeLen, config.levelNumLen, config.stateLen,
		 config.symbolLen, config.hash, config.codeAddress, config.dataAddress)
		 = ILevelConfigurator(games[1].house.levelConfigurator()).proposals(bidder);
*/
		// Level check for L1 or L2
		if (!(config.num == level+1)) {
			revert LevelInvalid();
		}

		// Copy Level via delegatecall
		(success, ) = config.codeAddress
			.delegatecall(abi.encodeWithSignature("copyData()returns(bool)"));

		if (success == false) {
			revert LevelCopyFailed();
		}

		// Store level address
		games[1].levelAddress = config.codeAddress;

		// Add level rules
		Symbols memory _symbols = Symbols({v: new bytes4[](config.symbolLen)});
		for (uint8 i = 0; i < config.symbolLen; i++) {
			_symbols.v[i] = bytes4(symbols.v[i]);
		}
		addRules(games[1].levelAddress, _symbols);

		return (true, "Level loaded");
	}

	// Starts a new game
	function newGame(uint8 _level) external onlyAdmin {

		// Check if game requested is 
		// for configured level
		if (level != _level) {
			revert LevelInvalid();
		}

		// Game instance is 1 for now
		// Iinitalize game
		games[1].winner = Player.None;
		games[1].turn = Player.Player1;
	}

	// Join the game
	function joinGame() external returns(bool success,
		string memory message) {

		// Check players address
		if (msg.sender == address(0)) {
			revert PlayerAddressInvalid();
		}

		if (games[1].player1 == address(0)) {
			
			// Store player 1
			games[1].player1 = msg.sender;
			return (true, "You are Player1 - X");
		}

		if (games[1].player2 == address(0)) {
			
			// Store player 2
			games[1].player2 = msg.sender;
			return (true, "You are Player2 - O");			
		}

		return (false, "Players already joined");
	}

	// Make a move
	function makeMove(Move memory move) external onlyPlayers
		returns(bool success, string memory message) {

		// Check if already winner exists
		if (games[1].winner != Player.None) {
			return (false, "The game has aready ended!");
		}

		// Only player who's turn it is can make a move
		if (msg.sender != _getCurrentPlayer()) {
			return (false, "Not your turn");
		}

		// Check cell initial value
		uint8 value = uint8(getState(move.row, move.col));
		console.log("value:", value);

		if (!((value == uint8(CellValueL.Empty)) ||
		     (value > 128))) {
			revert();
		}

		if (games[1].turn == Player.Player1) {
			value = uint8(CellValueL.X);
		}
		else if (games[1].turn == Player.Player2) {
			value = uint8(CellValueL.O);
		}

		// Execute for move as per rule
		(success) = setCell(games[1].levelAddress, 
								move.row, move.col, value);
		assert(success);
		assert(getState(move.row, move.col) == value);

		// Calculator Winner
		Player winner = _calculateWinner();
		// There is a winner
		if (winner != Player.None) {

			// Game ended 
			games[1].winner = winner;
			return (true, "You Won!"); 
		}

		// Next player's turn
		if (games[1].turn == Player.Player1) {
			games[1].turn = Player.Player2;
		}
		else if (games[1].turn == Player.Player2) {
			games[1].turn = Player.Player1;
		}

		return (true, "Next player's turn");
	}

	// Gets current players who's turn it is
	function _getCurrentPlayer() internal view returns(address player) {

		if (games[1].turn == Player.Player1) {
			return games[1].player1;
		}
		
		if (games[1].turn == Player.Player2) {
			return games[1].player2;
		}
	
		return address(0);
	}

	// Finds the winner 
	function _calculateWinner() internal view returns (Player winner) {

		// Winner in rows
		winner = _winnerInRows();
		if (winner != Player.None)
			return winner;

		// Winner in columns
		winner = _winnerInColumns();
		if (winner != Player.None)
			return winner;

		// Winers in both diagonals
		winner = _winnerInDiagonals();
		if (winner != Player.None)
			return winner;


		if (true == _isBoardFull()) {
			winner = Player.None;
		}

		console.log("Final winner:", uint(winner));
	}

	// Check if there are no empty cells on the board
	function _isBoardFull() internal view returns (bool ret) {

		uint8 _marker;

		ret = true;

		if (level == 1) {
			_marker = 3;
		}
		else if (level == 2) {
			_marker = 9;
		}

		for (uint8 r = 0; r < _marker; r++) {

			for (uint8 c = 0; c < _marker; c++) {

				if (getState(r, c) == uint8(CellValueL.Empty)) {
					ret = false;
					break;
				}
			}
		}
	}

	// Check longest X or O sequence in all rows
	function _winnerInRows() internal view returns (Player winner){

		uint8 countX;
		uint8 countO;
		uint8 _marker;
		uint8 _tuples;

		if (level == 1) {
			_marker = 3;
			_tuples = 1;
		}
		else if (level == 2) {
			_marker = 9;
			_tuples = 6;
		}

		console.log("In Rows..");
		// Rows
		for (uint8 r = 0; r < _marker; r++) {

			console.log("r:", r);

			for (uint8 c = 0; c < _tuples; c++) {
				console.log(" c:", c);

				if (level == 1) {
					if ((getState(r, c) == getState(r, c+1)) &&
					    (getState(r, c+1) == getState(r, c+2))) {

						if (getState(r, c) == uint8(CellValueL.X)) {
						   	countX = 1;
							console.log(" countX:", countX);
						   	winner = Player.Player1;							
						}
						else if (getState(r, c) == uint8(CellValueL.O)) {
						   	countO = 1;
							console.log(" countO:", countO);
						   	winner = Player.Player2;							
						} 
					}
				}
				else if (level == 2) {
					if ((getState(r, c) == getState(r, c+1)) &&
					   (getState(r, c+1) == getState(r, c+2)) &&
					   (getState(r, c+2) == getState(r, c+3))) {

					   	if (getState(r, c) == uint8(CellValueL.X)) {
						   	countX = 1;
							console.log(" countX:", countX);
						   	winner = Player.Player1;
					   	}
					   	if (getState(r, c) == uint8(CellValueL.O)) {
						   	countO = 1;
							console.log(" countO:", countO);
						   	winner = Player.Player2;
					   	}
					}
				}
			}

			if (countX == countO) {
				winner = Player.None;
			}
			else {
				break;
			}
		}

		console.log("winner:", uint(winner));
	}

	// Check longest X or O sequence in all columns
	// Check longest X or O sequence in all rows
	function _winnerInColumns() internal view returns (Player winner){

		uint8 countX;
		uint8 countO;
		uint8 _marker;
		uint8 _tuples;

		if (level == 1) {
			_marker = 3;
			_tuples = 1;
		}
		else if (level == 2) {
			_marker = 9;
			_tuples = 6;
		}

		console.log("In Columns..");

		// Columns
		for (uint8 c = 0; c < _marker; c++) {

			console.log("c:", c);

			for (uint8 r = 0; r < _tuples; r++) {
				console.log(" r:", r);

				if (level == 1) {
					if ((getState(r, c) == getState(r+1, c)) &&
					    (getState(r+1, c) == getState(r+2, c))) {

						if (getState(r, c) == uint8(CellValueL.X)) {
						   	countX = 1;
							console.log(" countX:", countX);
						   	winner = Player.Player1;							
						}
						else if (getState(r, c) == uint8(CellValueL.O)) {
						   	countO = 1;
							console.log(" countO:", countO);
						   	winner = Player.Player2;							
						} 
					}
				}
				else if (level == 2) {
					if ((getState(r, c) == getState(r+1, c)) &&
					   (getState(r+1, c) == getState(r+2, c)) &&
					   (getState(r+2, c) == getState(r+3, c))) {

					   	if (getState(r, c) == uint8(CellValueL.X)) {
						   	countX = 1;
							console.log(" countX:", countX);
						   	winner = Player.Player1;
					   	}
					   	if (getState(r, c) == uint8(CellValueL.O)) {
						   	countO = 1;
							console.log(" countO:", countO);
						   	winner = Player.Player2;
					   	}
					}
				}
			}

			if (countX == countO) {
				winner = Player.None;
			}
			else {
				break;
			}
		}

		console.log("winner:", uint(winner));
	}

	function _winnerInDiagonals() internal view returns (Player winner) {

		uint8 countX;
		uint8 countO;
		uint8 _marker;
		uint8 _tuples;

		if (level == 1) {
			_marker = 3;
			_tuples = 1;
		}
		else if (level == 2) {
			_marker = 9;
			_tuples = 6;
		}

		console.log("In Diagonals..");

		if (level == 1) {

			if ((getState(0, 0) == getState(1, 1)) &&
			    (getState(1, 1) == getState(2, 2))) {

				if (getState(0, 0) == uint8(CellValueL.X)) {
				   	countX = 1;
					console.log(" countX:", countX);
				   	winner = Player.Player1;
			   	}
			   	if (getState(0, 0) == uint8(CellValueL.O)) {
				   	countO = 1;
					console.log(" countO:", countO);
				   	winner = Player.Player2;
			   	}		
			}
			else if ((getState(0, 2) == getState(1, 1)) &&
			    (getState(1, 1) == getState(2, 0))) {

				if (getState(0, 2) == uint8(CellValueL.X)) {
				   	countX = 1;
					console.log(" countX:", countX);
				   	winner = Player.Player1;
			   	}
			   	if (getState(0, 2) == uint8(CellValueL.O)) {
				   	countO = 1;
					console.log(" countO:", countO);
				   	winner = Player.Player2;
			   	}
			}	
		}
		else if (level == 2) {

			uint8 e = 0;
			uint8 d = 0;

			for (d = 0; d < _tuples; d++) {
				console.log("backward:");
				console.log(" d:", d);
			
				if ((getState(d, d) == getState(d+1, d+1)) &&
					(getState(d+1, d+1) == getState(d+2, d+2)) &&
					(getState(d+2, d+2) == getState(d+3, d+3))) {

				   	if (getState(d, d) == uint8(CellValueL.X)) {
					   	countX = 1;
						console.log(" countX:", countX);
					   	winner = Player.Player1;
				   	}
				   	if (getState(d, d) == uint8(CellValueL.O)) {
					   	countO = 1;
						console.log(" countO:", countO);
					   	winner = Player.Player2;
				   	}
				}			
			}

			if (countX == countO) {
				d = 0;
				for ( ; (d < _tuples && e < _tuples); ) {
					console.log("forward:");
					console.log(" d:", d);
					console.log(" e:", e);
				
					if ((getState(e, 8-d) == getState(e+1, 7-d)) &&
						(getState(e+1, 7-d) == getState(e+2, 6-d)) &&
						(getState(e+2, 6-d) == getState(3+e, 5-d))) {

					   	if (getState(e, 8-d) == uint8(CellValueL.X)) {
						   	countX = 1;
							console.log(" countX:", countX);
						   	winner = Player.Player1;
					   	}
					   	if (getState(e, 8-d) == uint8(CellValueL.O)) {
						   	countO = 1;
							console.log(" countO:", countO);
						   	winner = Player.Player2;
					   	}
					}

					d++;
					e++;			
				}
			}
		}

		if (countX == countO) {
			winner = Player.None;
		}

		console.log("winner:", uint(winner));
	}

    modifier onlyAdmin {
        if (msg.sender != admin) revert("Not Admin");
        _;
    }

    modifier onlyPlayers {
        if ((msg.sender != games[1].player1) &&
        	(msg.sender != games[1].player2)) revert("Not Player");
        _;
    }
}
