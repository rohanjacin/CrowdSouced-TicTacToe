import React from "react";
import Gstate from "./GameState.js";

function GameState({ gameState }) {

	switch(gameState.state) {
		case Gstate.levelInProgress:
			return <div className='game-state'>Level {gameState.level}</div>;
		break;
		case Gstate.player1Wins:
			return <div className='game-state'>Player 1 wins</div>;
		break;
		case Gstate.player2Win:
			return <div className='game-state'>Player 2 wins</div>;
		break;
		case Gstate.draw:
			return <div className='game-state'>Draw</div>;
		break;
		default:
			return <></>;
		break;					
	}
}

function JoinGame() {
	return <button className='join-button'>Join</button>
}

export {
	GameState,
	JoinGame,
};