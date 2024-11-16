import React from "react";
import Board from "./Board.jsx";
import Strike from "./Strike.jsx";
import { web3, signer, GameContract, Connected, Connect } from "./Connect.jsx";
import NewGame from "./NewGame.jsx";
import { useState, useEffect } from "react";

const GState = {
	idle: 1,
	init: 2,
	newGameStarted: 3,
	levelSpwaned: 4,
	playerJoined: 5,
	levelStarted: 6,
	playerMove: 7,
	player1Wins: 8,
	player2Wins: 9,
	draw: 10,
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
	const initialContext = {"level": null, "levelCode": null, "levelData": null};
	const initialState = {"state": 0, "context": initialContext};
	const [gameState, setGameState] = useState(initialState);

	// Level addresses
	//const [levelAddress, setLevelAddress] = useState({code: null, data: null});

	useEffect(() => {
		if (Connected == true) {
			console.log("On level change..");
		}
	}, [level]);

/*	useEffect(() => {
		if (Connected == true) {
			console.log("On level address change..");
			
			if (gameState.state == GState.newGameStarted) {
				let context = {"level": };				
				setGameState(...gameState, "context": context);
			}
		}
	}, [levelAddress]);*/

	useEffect(() => {
		if (Connected == true) {
			if (gameState.state == GState.idle) {
				console.log("In State Idle");
				handleIdle(gameState.context);
			}
			else if (gameState.state == GState.init) {
				console.log("In State Init");
				handleInit(gameState.context);
			}			
			else if (gameState.state == GState.newGameStarted) {
				handleNewGameStarted(gameState.context);
			}
			else if (gameState.state == GState.levelSpwaned) {
				handleLevelSpwaned(gameState.context);
			}			
			else if (gameState.state == GState.playerJoined) {
				handlePlayerJoined(gameState.context);
			}
			else if (gameState.state == GState.levelStarted) {
			}			
			else if (gameState.state == GState.playerMove) {
				handlePlayerMove(gameState.context);
			}
			else if ((gameState.state == GState.player1Wins) ||
				     (gameState.state == GState.player2Wins) ||
				     (gameState.state == GState.draw)) {
				console.log("Game Over:", gameState.state);
				console.log("gameState.context:", gameState.context);
				handleLevelOver(gameState.context);
			} 
		}
	}, [gameState]);

	const handleOnConnected = () => {
		console.log("Connected..:", signer);
		listen();

		let state = GState.idle;
		let ctx = {...gameState.context};
		setGameState({...gameState, "state": state, "context": ctx});		
		console.log("gameState5:", gameState);
	}

	// On move send row and col of cell to Game.sol
	const handleCellClick = async (index) => {
	}

	const handleIdle = async (ctx) => {
		console.log("Idel state");
		await getLevel();
	}

	const handleInit = async (ctx) => {
		console.log("Init state");
		//await getLevel();
	}

	const handleNewGameStarted = async (ctx) => {
		console.log("New Game started");
		await getGame();
	}

	const handleLevelSpwaned = async (ctx) => {
		console.log("Level spwaned");
	}

	const handlePlayerJoined = async (ctx) => {

		playersJoined.push(ctx.playeraddress);
		setPlayerJoined(playersJoined);

		if ((playersJoined[0] != null) && (playersJoined[1] != null)) {
			console.log("Player 1:", playersJoined[0]);
			console.log("Player 2:", playersJoined[1]);
			let state = GState.levelStarted;
			setGameState({...gameState, "state": state});
			console.log("gameState6:", gameState);
		}
	}

	const handleLevelStarted = async (ctx) => {
	}

	const handlePlayerMove = async (ctx) => {
		console.log("Player move..")
		await getGame();
	}

	const handleLevelOver = async (ctx) => {
		console.log("Level done");
		let state = GState.idle;
		let context = {...ctx, "level" : null};
		setGameState({...gameState, state, "context": context});		
		console.log("gameState7:", gameState);
	}

	// On getting level data from Game
	const handleLevelData = (data) => {

		console.log("handleLevelData");
		if (gameState.state == GState.newGameStarted) {
			let state = GState.levelSpwaned;
			setGameState({...gameState, "state": state});
			console.log("gameState8:", gameState);
		}

		let newQuadCells = data.state.map((id) =>  id == 1 ? id = "❌":
							(id == 2 ? id = "⭕": null));
		setQuadCells(newQuadCells);
	}

	async function getLevel() {
		await GameContract.methods.level()
			.call({from: signer, gas: 100000})
			.then((level) => {
				let lev = parseInt(level);
				console.log("LEVEL:", lev);
				if (lev == 0) {
					let context = {...gameState.context, "level": 0}
					setGameState({...gameState, "state": GState.init, "context": context});
					console.log("gameState9:", gameState);
				}
				setLevel(lev);
			});
	}

	async function getGame() {
		let ret = { winner: Player.PLAYER_NONE, turn: Player.PLAYER_NONE, 
					message: ""};
		await GameContract.methods.getGame()
			.call({from: signer, gas: 100000})
			.then((info) => {
				console.log("info:", info.levelCode);
				ret = { winner: info.winner, turn: info.turn, message: info.message };
				let state = ((parseInt(info.winner) == Player.PLAYER_1) ?
							  GState.player1Wins :
							    ((parseInt(info.winner) == Player.PLAYER_2) ?
								 GState.player2Wins : gameState.state));
				let code = info.levelCode;
				let data = info.levelData;
				let ctx = gameState.context;
				console.log("cts:", ctx);
				if ((state != gameState.state) ||
					(code != ctx.levelCode) ||
				    (data != ctx.levelData)) {

					console.log("In here!!");
					if (state != gameState.state) {
						let context = { ...ctx, turn: info.turn, message: info.message };
						setGameState({...gameState, "state": state, 
							"context": context});						
						console.log("gameState10:", gameState);
					}
					else {
						let context = { ...ctx, turn: info.turn, message: info.message };
						setGameState({...gameState, "state": state, 
							"context": context});						
						console.log("gameState11:", gameState);
					}
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

			let state = GState.newGameStarted;
			let context = {...gameState.context, "level": parseInt(data.level),
							"levelCode": data.levelCode,
						    "levelData": data.levelData};
			setGameState({...gameState, "state": state, "context": context});
			console.log("gameState2:", gameState);

			setLevel(data.level);
		});

		// A Player has joined the game
		const eventPlayerJoined = GameContract.events.PlayerJoined();
		eventPlayerJoined.on("data", async (event) => {
			let data = event.returnValues;
			console.log("Player Joined..");
			console.log("address:" + data.player);
			console.log("id:" + data.id);

			let state = GState.playerJoined;
			let context = {...gameState.context, "playeraddress": data.player};
			setGameState({...gameState, "state": state, "context": context});
			console.log("gameState3:", gameState);
		
		});

		// A move has been made
		const eventPlayerMove = GameContract.events.PlayerMove();
		eventPlayerMove.on("data", async (event) => {
			let data = event.returnValues;
			console.log("Player Move..");
			console.log("player id:" + data.id);
			console.log("player move:", data.move);
			console.log("winner:" + data.winner);
			console.log("message:" + data.message);

			let state = GState.playerMove;
			let cell = (parseInt(data.move.row))*marker+(parseInt(data.move.col));
			let context = {...gameState.context, "id": data.id, "cell": cell, 
							"winner": data.winner, "message": data.message};
			setGameState({...gameState, "state": state, "context": context});
			console.log("gameState4:", gameState);

		});

	}

	function GameState() {
		switch(gameState.state) {
			case GState.idle:
				return ``;
			break;
			case GState.playerJoined:
				return `Player joined`;
			break;
			case GState.newGameStarted:
				return `Game started`;
			break;
			case GState.levelSpwaned:
				return `Level ${gameState.context.level}`;
			break;
			case GState.playerMove:
				return ``;
			break;
			case GState.player1Wins:
				return `Player 1 wins`;
			break;
			case GState.player2Wins:
				return `Player 2 wins`;
			break;
			case GState.draw:
				return `Draw`;
			break;
			default:
				return ``;
			break;					
		}
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
				cells={quadCells} 
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
		<div className='game-state'>{GameState()}</div>
		<Connect onConnected={handleOnConnected} account={1}/>
		<NewGame onData={handleLevelData} gameState={gameState}
				 gState={GState}/>
		</div>
	);
}

export default Game;