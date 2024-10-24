// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.27;

import "./BaseLevel.sol";
import "./BaseState.sol";
import "./BaseSymbol.sol";
import "./LevelConfigurator.sol";
import "./ILevelConfigurator.sol";
import "./RuleEngine.sol";

// Players
enum Player { None, Player1, Player2 }

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

// Game
contract Game is BaseLevel, BaseState, BaseSymbol {

	// Game info
	struct GameInfo {
		GameHouse house;
		address player1;
		address player2;
		Player winner;
		Player turn;
		mapping (uint8 => uint8[]) cellValues;
	}

	// Players move
	struct Move {
		uint8 row;
		uint8 col;
	}

	// SLOT 0 is from BaseLevel (Do NOT use SLOT 0)
	uint8 level;

	// SLOT 1 is from BaseState (Do NOT use SLOT 1)
	State board;

	// SLOT 2 is from BaseSymbols (Do NOT use SLOT 2)
	Symbols meta;

	// Game instance (id = level number)
	mapping(uint8 => GameInfo) games;

	// Load the default state in Base State
	constructor(uint8 _levelnum, State memory _state,
		Symbols memory _symbols) 
		BaseLevel(_levelnum)
		BaseState(_state)
		BaseSymbol(_symbols) {

		// Game House components
		games[1].house = new GameHouse();
	}

	// Loads the level
	function loadLevel() external returns(bool success,
		string memory message) {

		// Level check for L1 or L2
		if (!((level == 0) || (level == 1))) {
			revert LevelInvalid();
		}

		address addr = games[1].house.levelConfigurator();
		// Load Level
		(address target) = ILevelConfigurator(addr)
			.deployLevel(level, 0x1234);

		// Check Level exists
		if (target == address(0)) {
			revert LevelNotDeployed();
		}

		assembly {
			if iszero(extcodesize(target)) {
				revert (0, 0)
			}
		}

		// Copy Level via delegatecall
		(bool levelSuccess, bytes memory ids) = target.delegatecall(
			abi.encodeWithSignature("copyLevel1()returns(bytes memory)"));

		if (levelSuccess == false) {
			revert LevelCopyFailed();
		}

		// TODO: check ids for slot numbers updated by Level contract
		ids = ids;
		
		return (true, "Level loaded");
	}

	// Starts a new game
	function newGame(uint8 _level) external {

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
	function makeMove(Move memory move) external view returns(bool success,
		string memory message) {

		move = move;
		// Check if already winner exists
		if (games[1].winner != Player.None) {
			return (true, "The game has aready ended!");
		}

		// Only player who's turn it is can make a move
		if (msg.sender != _getCurrentPlayer()) {
			return (false, "Not your turn");
		}

		// Check for move agains rule
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
	function _calculateWinner() internal view returns (Player winner, uint8 count) {

		winner = Player.None;

		// Winner in rows
		(Player _winnerRow, uint8 _countRow) = _winnerInRows();

		// Winner in columns
		(Player _winnerCol, uint8 _countCol) = _winnerInColumns();

		// Winers in both diagonals
		(Player _winnerDiag, uint8 _countDiag) = _winnerInDiagonals();

		// Compare winning row and winning column
		if (_winnerRow == _winnerCol) {
			winner = _winnerRow;
			if (_countRow > _countCol) {
				count = _countRow;
			}
		}
		else if (_winnerRow != _winnerCol) {
			if (_countRow > _countCol) {
				winner = _winnerRow;
				count = _countRow;
			}
			else if (_countRow < _countCol) {
				winner = _winnerCol;
				count = _countCol;
			}
			else {
				count = _countRow;
			}
		}

		// Compare winning row or column to 
		// winning diagonal
		if (winner == _winnerDiag) {

			if (_countDiag > count) {
				count = _countDiag;
			}
		}
		else if (winner != _winnerDiag) {

			if (_countDiag > count) {
				winner = _winnerDiag;
			}
			else if (count == _countDiag) {
			}
		}
	}

	// Check longest X or O sequence in all rows
	function _winnerInRows() internal view returns (Player winner, uint8 count){

		uint8 countX;
		uint8 countO;
		winner = Player.None;

		// Rows
		for (uint8 r = 0; r < 9; r++) {

			// Columns
			for (uint8 c; c < 9; c++) {
				
				if (board.v[r][c] == uint8(1/*CellValue.X*/)) {
					countX++;
					countO = 0;
				}

				if (board.v[r][c] == uint8(2/*CellValue.O*/)) {
					countO++;
					countX = 0;
				}
			}

			if (countX > countO) {
				if (count < countX) {
					count = countX;
				}
				winner = Player.Player1;	
			}
			if (countX < countO) {
				if (count < countO) {
					count = countO;
				}
				winner = Player.Player2;
			}
			if (countX == countO) {
				if (count < countX) {
					count = countX;
				}
				winner = Player.None;
			}
		}
	}

	// Check longest X or O sequence in all columns
	function _winnerInColumns() internal view returns (Player winner, uint8 count){

		uint8 countX;
		uint8 countO;
		winner = Player.None;
		count = 0;

		// Columns
		for (uint8 c = 0; c < 9; c++) {

			// Rows
			for (uint8 r; r < 9; r++) {
				
				if (board.v[r][c] == uint8(1/*CellValue.X*/)) {
					countX++;
					countO = 0;
				}

				if (board.v[r][c] == uint8(2/*CellValue.O*/)) {
					countO++;
					countX = 0;
				}
			}

			if (countX > countO) {
				if (count < countX) {
					count = countX;
				}
				winner = Player.Player1;	
			}
			if (countX < countO) {
				if (count < countO) {
					count = countO;
				}
				winner = Player.Player2;
			}
			if (countX == countO) {
				if (count < countX) {
					count = countX;
				}
				winner = Player.None;
			}
		}
	}

	// Check longest X or O sequence in all diagonals
	function _winnerInDiagonals() internal view returns (Player, uint8){

		uint8 countX;
		uint8 countO;
		uint8 r;
		uint8 c;
		uint8 countForwardDiag;
		uint8 countBackwardDiag;

		Player winner = Player.None;
		uint8 count;

		//     C0  C1  C2  C3  C4  C5  C6  C7  C8  
		// R0 |   |   |   |   | * |   |   |   |   |
		// R1 |   |   |   | * |   |   |   |   |   |
		// R2 |   |   | * |   |   |   |   |   |   |
		// R3 |   | * |   |   |   |   |   |   |   |
		// R4 | * |   |   |   |   |   |   |   |   |
		// R5 |   |   |   |   |   |   |   |   |   |
		// R6 |   |   |   |   |   |   |   |   |   |
		// R7 |   |   |   |   |   |   |   |   |   |
		// R8 |   |   |   |   |   |   |   |   |   |

		// Forward leaning Diagonal loop (d)
		for (uint8 d = 1; d < 8; d++) {
			// Per diagonal loop (p)
			r = d; c = 0;
			
			for (uint8 p = 1; p <= d; p++ ) {
				// All pairs loop				
				if (board.v[r][c] == board.v[r-1][c+1]) {

					if (board.v[r][c] == uint8(1/*CellValue.X*/)) {
						countX = countX + 2;
					}
					if (board.v[r][c] == uint8(2/*CellValue.O*/)) {
						countO = countO + 2;
					}
				}

				r = r-1;
				c = c+1;				
			}
		}

		if (countX > 2)
			countX--;

		if (countO > 2)
			countO--;

		if (countX > countO) {
			countForwardDiag = countX;
			winner = Player.Player1;
		} else if (countX < countO) {
			countForwardDiag = countO;
			winner = Player.Player2;
		} else {
			countForwardDiag = countX;
		}

		countX = 0;
		countO = 0;


		//     C0  C1  C2  C3  C4  C5  C6  C7  C8  
		// R0 |   |   |   |   |   |   |   |   |   |
		// R1 |   |   |   |   |   |   |   |   |   |
		// R2 |   |   |   |   |   |   |   |   |   |
		// R3 |   |   |   |   |   |   |   |   |   |
		// R4 | * |   |   |   |   |   |   |   |   |
		// R5 |   | * |   |   |   |   |   |   |   |
		// R6 |   |   | * |   |   |   |   |   |   |
		// R7 |   |   |   | * |   |   |   |   |   |
		// R8 |   |   |   |   | * |   |   |   |   |

		// Backward leaning Diagonal loop (d)
		for (uint8 d = 7; d >= 0; d--) {
			// Per diagonal loop (p)
			r = d; c = 0;
			
			for (uint8 p = 1; p <= d; p++ ) {
				// All pairs loop				
				if (board.v[r][c] == board.v[r-1][c+1]) {

					if (board.v[r][c] == uint8(1/*CellValue.X*/)) {
						countX = countX + 2;
					}
					if (board.v[r][c] == uint8(2/*CellValue.O*/)) {
						countO = countO + 2;
					}
				}

				r = r+1;
				c = c+1;				
			}
		}

		if (countX > 2)
			countX--;

		if (countO > 2)
			countO--;

		// Player1 won backward diagonal
		if (countX > countO) {
			// Player1 won forward diagonal
			if (winner == Player.Player1) {
				countBackwardDiag = countX;
				if (countForwardDiag > countBackwardDiag)
					count = countForwardDiag;
				if (countForwardDiag < countBackwardDiag)
					count = countBackwardDiag;
				else
					count = countForwardDiag;
				return (Player.Player1, count);
			}
		}
		// Player2 won backward diagonal
		else if (countX < countO) {
			// Player2 won forward diagonal
			if (winner == Player.Player2) {
				countBackwardDiag = countO;

				if (countForwardDiag > countBackwardDiag)
					count = countForwardDiag;
				if (countForwardDiag < countBackwardDiag)
					count = countBackwardDiag;
				else
					count = countForwardDiag;
				return (Player.Player2, count);				
			}
		} 
		// If Player1 won forward diagonal
		// then check if Player2 won backward diagonal 
		// by bigger margin
		if (winner == Player.Player1) {

			// Player2 won backward diagonal
			if (countX < countO) {

				if (countForwardDiag < countO) {
					count = countO;
					winner = Player.Player2;
				}
			}
		}
		// If Player2 won forward diagonal
		// then check if Player1 won backward diagonal 
		// by bigger margin
		else if (winner == Player.Player2) {

			// Player1 won backward diagonal
			if (countO < countX) {

				if (countForwardDiag < countX) {
					count = countX;
					winner = Player.Player1;
				}
			}
		}
		// Draw in forward diagonal
		// and draw in backward diagonal
		else {
		}

		return (winner, count);
	}
}
