import React from "react";
import Board from "./Board.jsx";
import Strike from "./Strike.jsx";
import { web3, signer, GameContract, Connected, Connect } from "./Connect.jsx";
import { Gstate, Player, GameState, JoinGame } from "./GameState.jsx";
import { useState, useEffect } from "react";

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
	const [playerTurn, setPlayer] = useState(Player.PLAYER_1);

	// Game state
	const [gameState, setGameState] = useState({state: 0, context: 0});

	const row = "2";
	const col = "2";
	// Strike
	const colS = 2;
	const rowS = 0;
	const diagS = 0;
	const winningPattern = "bckwddiag";

	const [strikeClass, setStrikeClass] = useState(`strike-${winningPattern}-${level}`); 

	useEffect(() => {
		if (Connected == true) {
			console.log("On level change..");
		}
	}, [level]);

	useEffect(() => {
		if (Connected == true) {
			if (gameState.state == 1) {
				fetchCellValue(gameState.context);
			}
			else if (gameState.state == 2) {
				handleCellUpdate(gameState.context);
			}
			else if ((gameState.state == 3) ||
				     (gameState.state == 4) ||
				     (gameState.state == 5)) {
				console.log("Game Over:", gameState.state);
			} 
		}
	}, [gameState]);

	const handleOnConnected = () => {
		console.log("Connected..:", signer);
	}

	// On move send row and col of cell to Game.sol
	const handleCellClick = async (index) => {

		let row = Math.floor(index/marker);
		let col = index%marker;

		await makeMove(row, col)
		.then(() => {
			let state = 1;
			let context = {"cell": index, "value": playerTurn};
			setGameState({...gameState, "state": state, 
				"context": context});			
		});
	}

	const fetchCellValue = async (ctx) => {

		let row = Math.floor(ctx.cell/marker);
		let col = ctx.cell%marker;
		await getCell(row, col)
	}

	const handleCellUpdate = async (ctx) => {

		let row = Math.floor(ctx.cell/marker);
		let col = ctx.cell%marker;

		let state = 0;
		let context = 0;
		setGameState({...gameState, "state": state, 
			"context": context});

		await getGame();

		let idx = row*marker+col;
		const newQuadCells = [...quadCells];
		newQuadCells[idx] = (ctx.value == 1 ? "❌" : (ctx.value == 2 ? "⭕": null));
		setQuadCells(newQuadCells);
	}

	// On getting level data from Game
	const handleLevelData = (data) => {

		let newQuadCells = data.state.map((id) =>  id == 1 ? id = "❌":
							(id == 2 ? id = "⭕": null));
		setQuadCells(newQuadCells);
	}

	async function makeMove(row, col) {
		let ret = { won : false,  player: Player.PLAYER_NONE };
		await GameContract.methods.makeMove({row, col})
			.send({from: signer, gas: 1000000})
			.then((result) => {
				console.log("result:", result);
		});
	}

	async function getCell(row, col) {
		let ret = { joined : false,  asPlayer: Player.PLAYER_NONE };
		await GameContract.methods.getState(row, col)
			.call({from: signer, gas: 100000})
			.then((value) => {
				let state = 2;
				let idx = row*marker+col;
				let context = {"cell": idx, "value": parseInt(value)};
				setGameState({...gameState, "state": state, 
					"context": context});
		});
	}

	async function getGame() {
		let ret = { winner: Player.PLAYER_NONE, turn: Player.PLAYER_NONE, 
					message: ""};
		console.log("getGame..");
		await GameContract.methods.getGame()
			.call({from: signer, gas: 100000})
			.then((info) => {
				console.log("info:", info);
				ret = { winner: info.winner, turn: info.turn, message: info.message };
				let state = (info.winner == 1 ? 3 : info.winner == 2 ? 4 : gameState.state);
				let context = { ...gameState.state, turn: info.turn, message: info.message };
				//setGameState({...gameState, "state": state, 
				//	"context": context});
				console.log("info.winner:", info.winner);
				console.log("info.turn:", info.turn);
				console.log("info.message:", info.message);
		});
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
		{(level == 2) && ((gameState.state == 3) || (gameState.state == 4))?
		 <Strike level={level} strikeClass={strikeClass}
		 strikeStyle={{row: rowS, col: colS, diag: diagS, combo: winningPattern}}/> :  <div> </div>}
		<GameState  className='game-state' gameState={{level: level, state: gameState}}/>
		<Connect onConnected={handleOnConnected}/>
		<JoinGame onData={handleLevelData}/>
		</div>
	);
}

export default Game;