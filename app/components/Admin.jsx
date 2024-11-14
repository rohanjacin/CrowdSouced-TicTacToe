import React from "react";
import Board from "./Board.jsx";
import Strike from "./Strike.jsx";
import { web3, signer, GameContract, Connected, Connect } from "./Connect.jsx";
import NewGame from "./NewGame.jsx";
import { useState, useEffect } from "react";

const GState = {
	idle: 0,
	playerJoined: 1,
	gameStarted: 2,
	playerMove: 3,
	player1Wins: 4,
	player2Wins: 5,
	draw: 6,
}

const Player = {
	PLAYER_NONE: 0,
	PLAYER_1: 1,
	PLAYER_2: 2,
}

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

	// Players Joined
	const [playersJoined, setPlayerJoined] = useState(Array(2).fill(null));

	// Player turn
	const [playerTurn, setPlayerTurn] = useState(Player.PLAYER_1);

	// Game state
	const [gameState, setGameState] = useState({state: GState.levelInProgress,
										context: 0});

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
			if (gameState.state == GState.gameStarted) {
				handleGameStarted(gameState.context);
			}
			else if (gameState.state == GState.playerJoined) {
				handlePlayerJoined(gameState.context);
			}
			else if (gameState.state == GState.playerMoveDone) {
				handlePlayerMove(gameState.context);
			}
			else if ((gameState.state == GState.player1Wins) ||
				     (gameState.state == GState.player2Wins) ||
				     (gameState.state == GState.draw)) {
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
	}

	const handleGameStarted = async (ctx) => {

		if (playersJoined.length == 2) {
			console.log("Player 1:", playersJoined[0]);
			console.log("Player 2:", playersJoined[1]);
			let state = GState.gameStarted;
			let context = {};
			setGameState({...gameState, "state": state, "context": context});
		}
	}

	const handlePlayerJoined = async (ctx) => {

		if (playersJoined.length == 2) {
			console.log("Player 1:", playersJoined[0]);
			console.log("Player 2:", playersJoined[1]);
			let state = GState.gameStarted;
			let context = {};
			setGameState({...gameState, "state": state, "context": context});
		}
	}

	const handlePlayerMove = async (ctx) => {

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

	async function getCell(row, col) {
		let ret = { joined : false,  asPlayer: Player.PLAYER_NONE };
		await GameContract.methods.getState(row, col)
			.call({from: signer, gas: 100000})
			.then((value) => {
				let state = GState.playerMoveDone;
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
				let state = ((parseInt(info.winner) == Player.PLAYER_1) ?
							  GState.player1Wins :
							    ((parseInt(info.winner) == Player.PLAYER_2) ?
								 GState.player2Wins : gameState.state));
				let context = { ...gameState.state, turn: info.turn, message: info.message };
				if (state != gameState.state) {
					setGameState({...gameState, "state": state, 
						"context": context});
				}
		});
	}

	// Register for messages/events from the Game contract
	function listen () {

		// A new game has started
		const eventNewGameStarted = GameContract.events.NewGame();
		eventNewGameStarted.on("data", async (event) => {
			let data = event.returnValues;
			console.log("New Game started..");
			console.log("level:" + data.level);
			console.log("levelCode:" + data.levelCode);
			console.log("levelData:" + data.levelData);

			let state = GState.gameStarted;
			let context = {"level": data.level,
							"levelCode": data.levelCode,
						    "levelData": data.levelData};
			setGameState({...gameState, "state": state, "context": context});
		});

		// A Player has joined the game
		const eventPlayerJoined = GameContract.events.PlayerJoined();
		eventPlayerJoined.on("data", async (event) => {
			let data = event.returnValues;
			console.log("Player Joined..");
			console.log("address:" + data.player);
			console.log("id:" + data.id);

			let state = GState.playerJoined;
			let context = {"playerid": data.id};
			playersJoined.push(data.player);
			setPlayerJoined(playersJoined);
			setGameState({...gameState, "state": state, "context": context});
		});

		// A move has been made
		const eventPlayerMove = GameContract.events.PlayerMove();
		eventPlayerMove.on("data", async (event) => {
			let data = event.returnValues;
			console.log("Player Move..");
			console.log("player id:" + data.id);
			console.log("player move:" + data.move);
			console.log("winner:" + data.winner);
			console.log("message:" + data.message);

			let state = GState.playerMove;
			let cell = (data.move.row)*marker+(data.move.col);
			let context = {"id": data.id, "cell": cell, 
							"winner": data.winner,
							"message": data.message};
			setGameState({...gameState, "state": state, "context": context});
		});

	}

	return(
		<div className="game">
			<h1>
				<div>
				{(level == 2)? <div> <Board level={level} gameState={gameState} 
				quad={0} off={0*marker+3*0}
				cells={quadCells} onCellClick={handleCellClick}/></div> :
				<div> </div>}	
				</div>
			</h1>
			<h1>
				<div>
				{(level == 2)? <div> <Board level={level} gameState={gameState}
				quad={1} off={0*marker+3*1}
				cells={quadCells} onCellClick={handleCellClick}/></div> :
				<div> </div>}	
				</div>
			</h1>
			<h1>
				<div>
				{(level == 2)? <div> <Board level={level} gameState={gameState}
				quad={2} off={0*marker+3*2}
				cells={quadCells} onCellClick={handleCellClick}/></div> :
				<div> </div>}	
				</div>
			</h1>
			<h1>
				<div>
				{(level == 2)? <div> <Board level={level} gameState={gameState}
				quad={3} off={3*marker+3*0}
				cells={quadCells} onCellClick={handleCellClick}/></div> :
				<div> </div>}	
				</div>
			</h1>
			<h1>
				<div>
				{(level == 2)? <div> <Board level={level} gameState={gameState}
				quad={4} off={3*marker+3*1}
				cells={quadCells} onCellClick={handleCellClick}/></div> 
				: <div> <Board level={level} gameState={gameState}
				quad={0} off={0*marker+3*0}
				cells={quadCells} strikeClass={strikeClass} 
				onCellClick={handleCellClick}/> </div>}	
				</div>
			</h1>
			<h1>
				<div>
				{(level == 2)? <div> <Board level={level} gameState={gameState}
				quad={5} off={3*marker+3*2}
				cells={quadCells} onCellClick={handleCellClick}/></div> :
				<div> </div>}	
				</div>
			</h1>
			<h1>
				<div>
				{(level == 2)? <div> <Board level={level} gameState={gameState}
				quad={6} off={6*marker+3*0}
				cells={quadCells} onCellClick={handleCellClick}/></div> :
				<div> </div>}	
				</div>
			</h1>
			<h1>
				<div>
				{(level == 2)? <div> <Board level={level} gameState={gameState}
				quad={7} off={6*marker+3*1}
				cells={quadCells} onCellClick={handleCellClick}/></div> :
				<div> </div>}	
				</div>
			</h1>
			<h1>
				<div>
				{(level == 2)? <div> <Board level={level} gameState={gameState}
				quad={8} off={6*marker+3*2}
				cells={quadCells} onCellClick={handleCellClick}/></div> :
				<div> </div>}	
				</div>
			</h1>
		<Connect onConnected={handleOnConnected} account={1}/>
		<NewGame onData={handleLevelData} gameState={gameState}/>
		</div>
	);
}

/*		{((level == 2) && ((gameState.state == 3) || (gameState.state == 4))) ?
		 <Strike level={level} strikeClass={strikeClass}
		 	strikeStyle={strikeStyle}/> :  <div> </div>}
		<GameState  className='game-state'
			gameState={{level: level, state: gameState}}/>
*/
function GameState({ gameState }) {
	switch(gameState.state) {
		case Gstate.idle:
			return <div className='game-state'>Level {gameState.level}</div>;
		break;
		case Gstate.playerJoined:
			return <div className='game-state'>Player joined</div>;
		break;
		case Gstate.gameStarted:
			return <div className='game-state'>Game started</div>;
		break;
		case Gstate.playerMove:
			return <div className='game-state'>Player moved</div>;
		break;
		case Gstate.player1Win:
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
export default Game;