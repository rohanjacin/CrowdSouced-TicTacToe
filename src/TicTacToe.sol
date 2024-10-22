// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.27;

import "./BaseState.sol";

// Players
enum Player { None, Player1, Player2 }

error PlayerAddressInvalid();

// Game
contract TicTacToe {

	// Game info
	struct Game {
		address player1;
		address player2;
		Player winner;
		Player turn;		
	}

	// Players move
	struct Move {
		uint8 row;	
		uint8 col;
	}

	// Game instance
	Game game;

	// Starts a new game
	function newGame() external {

		// Iinitalize game
		game.winner = Player.None;
		game.turn = Player.Player1;
	}

	// Join the game
	function joinGame() external returns(bool success,
		string memory message) {

		// Check players address
		if (msg.sender == address(0)) {
			revert PlayerAddressInvalid();
		}

		if (game.player1 == address(0)) {
			
			// Store player 1
			game.player1 = msg.sender;
			return (true, "You are Player1 - X");
		}

		if (game.player2 == address(0)) {
			
			// Store player 2
			game.player2 = msg.sender;
			return (true, "You are Player2 - X");			
		}

		return (false, "Players already joined");
	}

	// Make a move
	function makeMove(Move memory move) external returns(bool success,
		string memory message) {

		// Check if already winner exists
		if (game.winner != Player.None) {
			return (true, "The game has aready ended!");
		}

		// Only player who's turn it is can make a move
	}

}
