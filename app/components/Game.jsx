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
	const [playerTurn, setPlayer] = useState("❌");

	// Game state
	const [gameState, setGameState] = useState({state: 0, context: 0});

	// Strike
	const [strikeClass, setStrikeClass] = useState(`strike- - `); 
	const [strikeStyle, setStrikeSyle] = useState({row: null, col: null, diag: null, combo: null}); 

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
				console.log("gameState.context:", gameState.context);
				handleStrikeData(gameState.context.message);				
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

	const handleStrikeData = (message) => {

		let combo = message.split(":")[1];
		combo = combo.split(",")[0];
		let rowS = message.split(":")[2];
		rowS = rowS.split(",")[0];
		let colS = message.split(":")[3];
		colS = colS.split(",")[0];
		let diagS = message.split(":")[4];
		diagS = diagS.split(",")[0];
		
		let newStrikeClass, newStrikeSyle;

		if ((level == 1) || (level == 2)) {
			switch (combo) {
				case "row": {
		 			newStrikeClass = `strike-${combo}-${level}-${rowS}`;
		 			rowS = parseInt(rowS);
		 		}
				break;
				case "col":
		 			newStrikeClass = `strike-${combo}-${level}-${colS}`;
		 			colS = parseInt(colS);
				break;
				case "fwddiag":
				case "bckwddiag":
		 			newStrikeClass = `strike-${combo}-${level}`;
				break;
			}

			newStrikeSyle = {row:rowS, col:colS, diag:diagS, combo:combo};
		}

		setStrikeClass(newStrikeClass);
		setStrikeSyle(newStrikeSyle)
	}

	async function makeMove(row, col) {
		let ret = { won : false,  player: Player.PLAYER_NONE };
		await GameContract.methods.makeMove({row, col})
			.send({from: signer, gas: 1000000})
			.then((result) => {
				//console.log("result:", result);
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
		await GameContract.methods.getGame()
			.call({from: signer, gas: 100000})
			.then((info) => {
				ret = { winner: info.winner, turn: info.turn, message: info.message };
				let state = ((parseInt(info.winner) == 1) ? 3 : ((parseInt(info.winner) == 2) ? 4 : gameState.state));
				let context = { ...gameState.state, turn: info.turn, message: info.message };
				if (state != gameState.state) {
					setGameState({...gameState, "state": state, 
						"context": context});
				}
				setPlayer(parseInt(info.turn) == 1 ? "❌" : 
					(parseInt(info.turn) == 2) ? "⭕" : Player.PLAYER_NONE);
		});
	}

	return(
		<div className="game">
			<h1>
				<div>
				{(level == 2)? <div> <Board level={level} gameState={gameState} 
				playerTurn={playerTurn} quad={0} off={0*marker+3*0}
				cells={quadCells} onCellClick={handleCellClick}/></div> :
				<div> </div>}	
				</div>
			</h1>
			<h1>
				<div>
				{(level == 2)? <div> <Board level={level} gameState={gameState}
				playerTurn={playerTurn} quad={1} off={0*marker+3*1}
				cells={quadCells} onCellClick={handleCellClick}/></div> :
				<div> </div>}	
				</div>
			</h1>
			<h1>
				<div>
				{(level == 2)? <div> <Board level={level} gameState={gameState}
				playerTurn={playerTurn} quad={2} off={0*marker+3*2}
				cells={quadCells} onCellClick={handleCellClick}/></div> :
				<div> </div>}	
				</div>
			</h1>
			<h1>
				<div>
				{(level == 2)? <div> <Board level={level} gameState={gameState}
				playerTurn={playerTurn} quad={3} off={3*marker+3*0}
				cells={quadCells} onCellClick={handleCellClick}/></div> :
				<div> </div>}	
				</div>
			</h1>
			<h1>
				<div>
				{(level == 2)? <div> <Board level={level} gameState={gameState}
				playerTurn={playerTurn} quad={4} off={3*marker+3*1}
				cells={quadCells} onCellClick={handleCellClick}/></div> 
				: <div> <Board level={level} gameState={gameState}
				playerTurn={playerTurn} quad={0} off={0*marker+3*0}
				cells={quadCells} strikeClass={strikeClass} 
				onCellClick={handleCellClick}/> </div>}	
				</div>
			</h1>
			<h1>
				<div>
				{(level == 2)? <div> <Board level={level} gameState={gameState}
				playerTurn={playerTurn} quad={5} off={3*marker+3*2}
				cells={quadCells} onCellClick={handleCellClick}/></div> :
				<div> </div>}	
				</div>
			</h1>
			<h1>
				<div>
				{(level == 2)? <div> <Board level={level} gameState={gameState}
				playerTurn={playerTurn} quad={6} off={6*marker+3*0}
				cells={quadCells} onCellClick={handleCellClick}/></div> :
				<div> </div>}	
				</div>
			</h1>
			<h1>
				<div>
				{(level == 2)? <div> <Board level={level} gameState={gameState}
				playerTurn={playerTurn} quad={7} off={6*marker+3*1}
				cells={quadCells} onCellClick={handleCellClick}/></div> :
				<div> </div>}	
				</div>
			</h1>
			<h1>
				<div>
				{(level == 2)? <div> <Board level={level} gameState={gameState}
				playerTurn={playerTurn} quad={8} off={6*marker+3*2}
				cells={quadCells} onCellClick={handleCellClick}/></div> :
				<div> </div>}	
				</div>
			</h1>
		{((level == 2) && ((gameState.state == 3) || (gameState.state == 4))) ?
		 <Strike level={level} strikeClass={strikeClass}
		 	strikeStyle={strikeStyle}/> :  <div> </div>}
		<GameState  className='game-state'
			gameState={{level: level, state: gameState}}/>
		<Connect onConnected={handleOnConnected}/>
		<JoinGame onData={handleLevelData}/>
		</div>
	);
}

export default Game;