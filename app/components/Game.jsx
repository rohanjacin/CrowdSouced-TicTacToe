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
	const [level, setLevel] = useState(2);
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
			console.log("On game state change:", gameState);
			if (gameState.state == 1) {
				console.log("fetch cell state");
				fetchCellValue(gameState.context);
			}
			else if (gameState.state == 2) {
				console.log("update cell state");
				handleCellUpdate(gameState.context);
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

		console.log("row:", row);
		console.log("col:", col);

		await makeMove(row, col)
		.then(() => {
			let state = 1;
			let context = {"cell": index, "value": playerTurn};
			setGameState({...gameState, "state": state, 
				"context": context});			
		});
	}

	const fetchCellValue = async (ctx) => {

		console.log("fcv index:", ctx.cell);
		console.log("fcv value:", ctx.value);

		let row = Math.floor(ctx.cell/marker);
		let col = ctx.cell%marker;

		console.log("row:", row);
		console.log("col:", col);

		await getCell(row, col)
	}

	const handleCellUpdate = async (ctx) => {

		console.log("handleCellUpdate:index:", ctx.cell);
		console.log("handleCellUpdate:value:", ctx.value);

		let row = Math.floor(ctx.cell/marker);
		let col = ctx.cell%marker;

		console.log("row:", row);
		console.log("col:", col);

		let state = 0;
		let context = 0;
		setGameState({...gameState, "state": state, 
			"context": context});

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
			.send({from: signer, gas: 100000})
			.then((result) => {
				console.log("result:", result);
/*				console.log("success:", result.success);
				console.log("message:", result.message);
				if (result.success == true) {
					if (result.message == "Next player's turn") {
						ret = {won : false, player: Player.PLAYER_NONE};
						console.log(result.message);
					}
					else if (result.message == "You Won!") {
						ret = {won : true, player: Player.PLAYER_1};
						console.log(result.message);
					}
				}
*/		});
	}

	async function getCell(row, col) {
		let ret = { joined : false,  asPlayer: Player.PLAYER_NONE };
		await GameContract.methods.getCell(row, col)
			.call({from: signer, gas: 100000})
			.then((value) => {
				let state = 2;
				let idx = row*marker+col;
				let context = {"cell": idx, "value": parseInt(value)};
				setGameState({...gameState, "state": state, 
					"context": context});
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
		{(level == 2)? <Strike level={level} strikeClass={strikeClass}
		strikeStyle={{row: rowS, col: colS, diag: diagS, combo: winningPattern}}/> :  <div> </div>}
		<GameState  className='game-state' gameState={{level: level, state: gameState}}/>
		<Connect onConnected={handleOnConnected}/>
		<JoinGame onData={handleLevelData}/>
		</div>
	);
}

export default Game;