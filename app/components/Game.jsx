import React from "react";
import Board from "./Board.jsx";
import Strike from "./Strike.jsx";
import { GameState, JoinGame } from "./GameState.jsx";
import Connect from "./Connect.jsx";
import Gstate from "./GameState.js";
import { useState } from "react";

const PLAYER_X = "❌";
const PLAYER_O = "⭕";

// Main Tictactoe game component
// contains dynamic board and cells
// for level 1 and level 2
function Game() {
	// Level
	const [level, setLevel] = useState(1);
	// Level cell count
	const numCells = (level == 2)? 81 : 9;
	const marker = (level == 2)? 9 : 3;
	
	// Cell array formats
	const [cells, setCells] = useState((level == 2) ? 
							  (Array.from({ length: 9 }, 
							  () => new Array(9).fill(null))) :
							  (Array.from({ length: 3 }, 
							  () => new Array(3).fill(null))));
	// Linearized cells in order to fill board quadrants
	const [quadCells, setQuadCells] = useState(Array(numCells).fill(null));

	// Player turn
	const [playerTurn, setPlayer] = useState(PLAYER_O);

	// Game state
	const [gameState, setGameState] = useState(Gstate.levelInProgress);

	const row = "2";
	const col = "2";
	// Strike
	const colS = 2;
	const rowS = 0;
	const diagS = 0;
	const winningPattern = "bckwddiag";

	const [strikeClass, setStrikeClass] = useState(`strike-${winningPattern}-${level}`); 

	// On move send row and col of cell to Game.sol
	const handleCellClick = (index) => {

		let row = Math.floor(index/numCells);
		let col = index%numCells;
		
		const newCells = [...cells];
		newCells[row, col] = playerTurn;
		setCells(newCells);

		let idx = row*marker+col;
		const newQuadCells = [...quadCells];
		newQuadCells[idx] = playerTurn;
		setQuadCells(newQuadCells);
	}

	return(
		<div className="game">
			<h1>
				<div>
				{(level == 2)? <div> <Board level={level} playerTurn={playerTurn}
				quad={0} off={0*marker+3*0} cells={quadCells} 
				onCellClick={handleCellClick}/></div> : <div> </div>}	
				</div>
			</h1>
			<h1>
				<div>
				{(level == 2)? <div> <Board level={level} playerTurn={playerTurn}
				quad={1} off={0*marker+3*1} cells={quadCells} 
				onCellClick={handleCellClick}/></div> : <div> </div>}	
				</div>
			</h1>
			<h1>
				<div>
				{(level == 2)? <div> <Board level={level} playerTurn={playerTurn}
				quad={2} off={0*marker+3*2} cells={quadCells} 
				onCellClick={handleCellClick}/></div> : <div> </div>}	
				</div>
			</h1>
			<h1>
				<div>
				{(level == 2)? <div> <Board level={level} playerTurn={playerTurn}
				quad={3} off={3*marker+3*0} cells={quadCells} 
				onCellClick={handleCellClick}/></div> : <div> </div>}	
				</div>
			</h1>
			<h1>
				<div>
				{(level == 2)? <div> <Board level={level} playerTurn={playerTurn}
				quad={4} off={3*marker+3*1} cells={quadCells}
				onCellClick={handleCellClick}/></div> 
				: <div> <Board level={level} playerTurn={playerTurn}
				quad={0} off={0*marker+3*0} cells={quadCells}
				strikeClass={strikeClass} 
				onCellClick={handleCellClick}/> </div>}	
				</div>
			</h1>
			<h1>
				<div>
				{(level == 2)? <div> <Board level={level} playerTurn={playerTurn}
				quad={5} off={3*marker+3*2} cells={quadCells} 
				onCellClick={handleCellClick}/></div> : <div> </div>}	
				</div>
			</h1>
			<h1>
				<div>
				{(level == 2)? <div> <Board level={level} playerTurn={playerTurn}
				quad={6} off={6*marker+3*0} cells={quadCells} 
				onCellClick={handleCellClick}/></div> : <div> </div>}	
				</div>
			</h1>
			<h1>
				<div>
				{(level == 2)? <div> <Board level={level} playerTurn={playerTurn}
				quad={7} off={6*marker+3*1} cells={quadCells} 
				onCellClick={handleCellClick}/></div> : <div> </div>}	
				</div>
			</h1>
			<h1>
				<div>
				{(level == 2)? <div> <Board level={level} playerTurn={playerTurn}
				quad={8} off={6*marker+3*2} cells={quadCells} 
				onCellClick={handleCellClick}/></div> : <div> </div>}	
				</div>
			</h1>
		{(level == 2)? <Strike level={level} strikeClass={strikeClass}
		strikeStyle={{row: rowS, col: colS, diag: diagS, combo: winningPattern}}/> :  <div> </div>}
		<GameState  className='game-state' gameState={{level: level, state: gameState}}/>
		<JoinGame />
		<Connect />
		</div>
	);
}

export default Game;