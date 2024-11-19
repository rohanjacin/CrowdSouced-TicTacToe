import React from "react";
import Board from "./Board.jsx";
import Strike from "./Strike.jsx";
import { web3, signer, GameContract, Connected, Connect } from "./Connect.jsx";
import NewGame from "./NewGame.jsx";
import { useState, useEffect, useRef } from "react";

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
function Game({ initalLevel, initialPlayerId, onGameOver }) {
	// Level
	console.log("initalLevel:", initalLevel);

	const [level, setLevel] = useState(initalLevel);

	if ((initalLevel == 2) && (level != initalLevel)) {
		console.log("Reload..");
		window.location.reload();
	}

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

	// Game state
	const [levelCode, setLevelCode] = useState("");
	const [levelData, setLevelData] = useState("");
	var levelInfo = {"levelNum": level, "levelCode": levelCode, "levelData": levelData}
	//var gameInfo = {"cell": null, "turn": Player.PLAYER_1,
	//				"players": Array(2).fill(null),
	//				"winner": Player.PLAYER_NONE, "message": ""};

	const [gcell, setGameCell] = useState(null);
	const [gturn, setGameTurn] = useState(Player.PLAYER_1);
	const [gplayers, setGamePlayers] = useState(Array(2).fill(null));
	const [gplayerValue, setGamePlayerValue] = useState("❌");
	const [gwinner, setGameWinner] = useState(Player.PLAYER_NONE);
	const [gmessage, setGameMessage] = useState("");
	var gameInfo = {"cell": gcell, "turn": gturn, "value": gplayerValue,
			"players": gplayers, "winner": gwinner, "message": gmessage};

	const [gameState, setGameState] = useState(0);

	useEffect(() => {
		if (Connected == true) {
			console.log("On level change..:", level);
		}
	}, [level]);

	useEffect(() => {
		if (Connected == true) {
			listen();
		}
	}, [Connected]);

	function gamestateprint() {
		switch(gameState) {
			case GState.idle:
				console.log('Idle'); 
			break;
			case GState.init:
				console.log('Init'); 
			break;
			case GState.newGameStarted:
				console.log('newGameStarted'); 
			break;
			case GState.levelSpwaned:
				console.log('levelSpwaned'); 
			break;
			case GState.playerJoined:
				return `playerJoined`;
			break;
			case GState.playerJoined:
				return `playerJoined`;
			break;			
			case GState.playerMove:
				return `playerMove`;
			break;
			case GState.player1Wins:
				return `player1Wins`;
			break;
			case GState.player2Wins:
				return `player2Wins`;
			break;
			case GState.draw:
				return `draw`;
			break;
			default:
				return `unknown`;
			break;					
		}
	}

	useEffect(() => {
		if (Connected == true) {
			console.log("\nState Change::");
			console.log("state:");
			gamestateprint();			
			console.log("levelNum:", levelInfo.levelNum);
			console.log("levelCode:", levelInfo.levelCode);
			console.log("levelData:", levelInfo.levelData);
			console.log("cell:", gameInfo.cell);
			console.log("turn:", gameInfo.turn);
			console.log("players[0]:", gameInfo.players[0]);
			console.log("players[1]:", gameInfo.players[1]);
			console.log("winner:", gameInfo.winner);
			console.log("message:", gameInfo.message);

			if (gameState == GState.idle) {
				handleIdle();
			}
			else if (gameState == GState.init) {
				handleInit();
			}			
			else if (gameState == GState.newGameStarted) {
				handleNewGameStarted();
			}
			else if (gameState == GState.levelSpwaned) {
				handleLevelSpwaned();
			}			
			else if (gameState == GState.playerJoined) {
				handlePlayerJoined();
			}
			else if (gameState == GState.levelStarted) {
			}			
			else if (gameState == GState.playerMove) {
				handlePlayerMove();
			}
			else if ((gameState == GState.player1Wins) ||
				     (gameState == GState.player2Wins) ||
				     (gameState == GState.draw)) {
				handleGameOver();
			} 
		}
	}, [gameState]);

	useEffect(() => {
		if (Connected == true) {
			if (gameState == GState.playerMove) {
				console.log("Winner found!!");
				getGame();
			}
		}
	}, [gwinner]);

	function handleOnConnected() {
		console.log("Connected..:", signer);
		setGameState(GState.idle);		
	};

	// On move send row and col of cell to Game.sol
	const handleCellClick = async (index) => {
	}

	const handleIdle = async () => {
		getLevel();
	}

	const handleInit = async () => {
		//await getLevel();
	}

	const handleNewGameStarted = () => {
		getGame();
	}

	const handleLevelSpwaned = async () => {
	}

	const handlePlayerJoined = async () => {

		if ((gameInfo.players[0] != null) &&
			(gameInfo.players[1] != null)) {
			console.log("Player 1:", gameInfo.players[0]);
			console.log("Player 2:", gameInfo.players[1]);
			setGameState(GState.levelStarted);
		}
	}

	const handleLevelStarted = async () => {
	}

	const handlePlayerMove = async () => {
		console.log("Player move..")
		await getGame();
	}

	const handleGameOver = async () => {
		console.log("Game Over");
		sessionStorage.setItem('cells', JSON.stringify(quadCells));
		onGameOver();
	}

	// On getting level data from Game
	const handleLevelData = (data) => {

		console.log("handleLevelData");
		if (gameState == GState.newGameStarted) {
			setGameState(GState.levelSpwaned);
		}

		let newQuadCells = data.state.map((id) =>  id == 1 ? id = "❌":
							(id == 2 ? id = "⭕": null));
		setQuadCells(newQuadCells);

	}

	async function getLevel() {
		console.log("LL:", GameContract);
		GameContract.methods.level()
			.call({from: signer, gas: 500000})
			.then((level) => {
				console.log("In then");
				if (level == initalLevel) {
					setLevel(parseInt(level));
				}
		});
	}

	async function getGame() {
		console.log("initalLevel ? initalLevel : 1:::", initalLevel ? initalLevel : 1);
		await GameContract.methods.getGame(initalLevel ? initalLevel : 1)
			.call({from: signer, gas: 100000})
			.then((info) => {
				console.log("info:", info);
				let state = ((parseInt(info.winner) == Player.PLAYER_1) ?
							  GState.player1Wins :
							    ((parseInt(info.winner) == Player.PLAYER_2) ?
								 GState.player2Wins : gameState));
				if ((state != gameState) ||
					(info.levelCode != levelInfo.levelCode) ||
				    (info.levelData != levelInfo.levelData)) {

					if (state != gameState) {
						setGameTurn(parseInt(info.turn))
						setGameMessage(info.message);
						setGameState(state);					
					}
					else {
						console.log("Level code changes:", info.levelCode);
						setLevelCode(info.levelCode);
						setLevelData(info.levelData);
					}
				}
			});
	}

	// Register for messages/events from the Game contract
	function listen () {

		// A new game has started
		const eventNewGameStarted = GameContract.events.NewGame();
		eventNewGameStarted.on("data", (event) => {
			console.log("NEEW Game");
			let data = event.returnValues;
			//levelInfo.levelNum = data.level;
			levelInfo.levelData = data.levelData;
			setGameState(GState.newGameStarted);
			setLevel(parseInt(data.level));
			setLevelCode(data.levelCode);
			setLevelData(data.levelData);
		});

		// A Player has joined the game
		const eventPlayerJoined = GameContract.events.PlayerJoined();
		eventPlayerJoined.on("data", playerJoinedCb);

		function playerJoinedCb (event) {
			let data = event.returnValues;
			console.log("Player Joined..");
			console.log("address:" + data.player);
			console.log("id:" + data.id);

			setGameState(GState.playerJoined);		
		};

		// A move has been made
		const eventPlayerMove = GameContract.events.PlayerMove();
		eventPlayerMove.on("data", (event) => {
			let data = event.returnValues;

			let cell = (parseInt(data.move.row))*marker+(parseInt(data.move.col));			
			setGameCell(cell);
			setGameWinner(parseInt(data.winner));
			setGameMessage(data.message);
			setGameState(GState.playerMove);
		});

	};

	function GameState() {
		switch(gameState) {
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
				return `Level ${levelInfo.levelNum}`;
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

	return (
		<div className="game">
			<h1>
				<div>
				{(level == 2)? <div> <Board level={level} gameState={gameState} 
				gState={GState} quad={0} off={0*marker+3*0}
				cells={quadCells} onCellClick={handleCellClick}/></div> :
				<div> </div>}	
				</div>
			</h1>
			<h1>
				<div>
				{(level == 2)? <div> <Board level={level} gameState={gameState}
				gState={GState} quad={1} off={0*marker+3*1}
				cells={quadCells} onCellClick={handleCellClick}/></div> :
				<div> </div>}	
				</div>
			</h1>
			<h1>
				<div>
				{(level == 2)? <div> <Board level={level} gameState={gameState}
				gState={GState} quad={2} off={0*marker+3*2}
				cells={quadCells} onCellClick={handleCellClick}/></div> :
				<div> </div>}	
				</div>
			</h1>
			<h1>
				<div>
				{(level == 2)? <div> <Board level={level} gameState={gameState}
				gState={GState} quad={3} off={3*marker+3*0}
				cells={quadCells} onCellClick={handleCellClick}/></div> :
				<div> </div>}	
				</div>
			</h1>
			<h1>
				<div>
				{(level == 2)? <div> <Board level={level} gameState={gameState}
				gState={GState} quad={4} off={3*marker+3*1}
				cells={quadCells} onCellClick={handleCellClick}/></div> 
				: <div> <Board level={level} gameState={gameState}
				gState={GState} quad={0} off={0*marker+3*0}
				cells={quadCells} 
				onCellClick={handleCellClick}/> </div>}	
				</div>
			</h1>
			<h1>
				<div>
				{(level == 2)? <div> <Board level={level} gameState={gameState}
				gState={GState} quad={5} off={3*marker+3*2}
				cells={quadCells} onCellClick={handleCellClick}/></div> :
				<div> </div>}	
				</div>
			</h1>
			<h1>
				<div>
				{(level == 2)? <div> <Board level={level} gameState={gameState}
				gState={GState} quad={6} off={6*marker+3*0}
				cells={quadCells} onCellClick={handleCellClick}/></div> :
				<div> </div>}	
				</div>
			</h1>
			<h1>
				<div>
				{(level == 2)? <div> <Board level={level} gameState={gameState}
				gState={GState} quad={7} off={6*marker+3*1}
				cells={quadCells} onCellClick={handleCellClick}/></div> :
				<div> </div>}	
				</div>
			</h1>
			<h1>
				<div>
				{(level == 2)? <div> <Board level={level} gameState={gameState}
				gState={GState} quad={8} off={6*marker+3*2}
				cells={quadCells} onCellClick={handleCellClick}/></div> :
				<div> </div>}	
				</div>
			</h1>
		<div className='game-state'>{GameState()}</div>
		<Connect onConnected={handleOnConnected} account={initialPlayerId}/>
		<NewGame initalLevel={initalLevel} onData={handleLevelData} gameState={gameState}
				 levelInfo={levelInfo} gState={GState}/>
		</div>
	);
}

export default Game;