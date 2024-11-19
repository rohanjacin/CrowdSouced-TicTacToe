import React from "react";
import Board from "./Board.jsx";
import Strike from "./Strike.jsx";
import { web3, signer, GameContract, Connected, Connect } from "./Connect.jsx";
import { PlayerId, JoinGame} from "./Join.jsx";
import { useState, useEffect } from "react";

const GState = {
	idle: 1,
	init: 2,
	newGameStarted: 3,
	playerJoined: 4,
	levelSpwaned: 5,
	levelStarted: 6,
	playerMoveInProgress: 7,
	playerMoveDone: 8,
	player1Wins: 9,
	player2Wins: 10,
	draw: 11,
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

	if (level != initalLevel) {
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
	const lastQuadCells = sessionStorage.getItem("cells");
	console.log("lastQuadCells:", lastQuadCells);

	var defaultQuadCells = null;
	if ((lastQuadCells) && (initalLevel == 2)) {
		let i = 0;
		let prefillCells = JSON.parse(lastQuadCells);
		let tempCells = Array(numCells).fill(null);
		function preFill(value, idx, array) {

			if ((idx == 30) || (idx == 31) || (idx == 32) ||
			    (idx == 39) || (idx == 40) || (idx == 41) ||
			    (idx == 48) || (idx == 49) || (idx == 50)) {

				value = prefillCells[i]; 
				i++;
				return value;
			}
		
		}		
		defaultQuadCells = tempCells.map(preFill);
	}
	else {
		defaultQuadCells = Array(numCells).fill(null);
	}
	const [quadCells, setQuadCells] = useState(defaultQuadCells);

	// Game state
	const [levelCode, setLevelCode] = useState("");
	const [levelData, setLevelData] = useState("");
	var levelInfo = {"levelNum": level, "levelCode": levelCode, "levelData": levelData}
	const [gcell, setGameCell] = useState(null);
	const [gturn, setGameTurn] = useState(Player.PLAYER_1);
	const [gplayers, setGamePlayers] = useState(Array(2).fill(null));
	const [gplayerValue, setGamePlayerValue] = useState("❌");
	const [gwinner, setGameWinner] = useState(Player.PLAYER_NONE);
	const [gmessage, setGameMessage] = useState("");

	var gameInfo = {"cell": gcell, "turn": gturn, "value": gplayerValue,
			"players": gplayers, "winner": gwinner, "message": gmessage};
	const [gameState, setGameState] = useState(0);

	// Strike
	const [strikeClass, setStrikeClass] = useState(`strike- - `); 
	const [strikeStyle, setStrikeSyle] = useState({row: null, col: null, diag: null, combo: null}); 

	useEffect(() => {
		if (Connected == true) {
			console.log("on Level change:", level);
			if (level == 2) {
				console.log("FInally LEVEl2");
			}
		}
	}, [level]);

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
				console.log(`playerJoined`);
			break;
			case GState.levelStarted:
				console.log('levelStarted'); 
			break;
			case GState.playerMoveInProgress:
				console.log('playerMoveInProgress'); 
			break;
			case GState.playerMoveDone:
				console.log('playerMoveDone'); 
			break;			
			case GState.player1Wins:
				console.log(`player1Wins`);
			break;
			case GState.player2Wins:
				console.log(`player2Wins`);
			break;
			case GState.draw:
				console.log(`draw`);
			break;
			default:
				console.log(`unknown`);
			break;					
		}
	}

	useEffect(() => {
		if (Connected == true) {
			console.log("\nState Change::");
			console.log("state:", gameState);
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
				handleGameStarted();
			}
			else if (gameState == GState.playerJoined) {
				handlePlayerJoined();
			}			
			else if (gameState == GState.playerMoveInProgress) {
				fetchCellValue();
			}
			else if (gameState == GState.playerMoveDone) {
				handleCellUpdate();
			}
			else if ((gameState == GState.player1Wins) ||
				     (gameState == GState.player2Wins) ||
				     (gameState == GState.draw)) {
				handleStrikeData();
				handleGameOver();				
			} 
		}
	}, [gameState]);


	const handleOnConnected = () => {
		listen();
		setGameState(GState.idle);		
	}


	const handleIdle = async () => {
		await getLevel();
	}

	const handleInit = async () => {
		await getGame();
	}

	const handlePlayerJoined = async () => {
		await getGame();
	}

	const handleGameOver = async () => {

		sessionStorage.setItem('cells', JSON.stringify(quadCells));
		onGameOver();
	}

	// On move send row and col of cell to Game.sol
	const handleCellClick = async (index) => {

		let row = Math.floor(index/marker);
		let col = index%marker;

		console.log("index:", index);
		console.log("row:", row);
		console.log("col:", col);

		await makeMove(row, col).then(() => {
			setGameCell(index);
			console.log("GameCell:", gameInfo.cell);
			console.log("playerVal:", gameInfo.value);
			setTimeout(() => setGameState(GState.playerMoveInProgress), 500);			
		});
	}

	const fetchCellValue = async () => {

		console.log("fetchCellValue:", gameInfo.cell);
		console.log("fetchCellValue:gameInfo:", gameInfo);

		let row = Math.floor(gameInfo.cell/marker);
		let col = gameInfo.cell%marker;
		console.log("fetchCellValue:row", row);
		console.log("fetchCellValue:col", col);
		await getCell(row, col)
	}

	const handleCellUpdate = async () => {

		console.log("handleCellUpdate:", gameInfo.cell);
		let row = Math.floor(gameInfo.cell/marker);
		let col = gameInfo.cell%marker;
		console.log("handleCellUpdate:row:", row);
		console.log("handleCellUpdate:col", col);

		await getGame();

		let idx = row*marker+col;
		console.log("handleCellUpdate:idx", idx);

		const newQuadCells = [...quadCells];
		newQuadCells[idx] = (gameInfo.value == 1 ? "❌" : (gameInfo.value == 2 ? "⭕": null));
		console.log("newQuadCells:", newQuadCells);
		setQuadCells(newQuadCells);
	}

	// On getting level data from Game
	const handleOnJoin = () => {
		setGameState(GState.newGameStarted);		
	}

	const handleGameStarted = () => {
		getGame();
	}

	// On getting level data from Game
	const handleLevelData = (data) => {

		let newQuadCells;
		let levelCells = data.state.map((id) =>  id == 1 ? id = "❌":
						(id == 2 ? id = "⭕": null));

		if (initalLevel == 2) {
			let i = 0;
			function preFill(value, idx, array) {

				if ((idx == 30) || (idx == 31) || (idx == 32) ||
				    (idx == 39) || (idx == 40) || (idx == 41) ||
				    (idx == 48) || (idx == 49) || (idx == 50)) {
				}
				else {
					value = levelCells[i];
				}
				i++;
				return value;			
			}
			newQuadCells = quadCells.map(preFill);
		}
		else {
			newQuadCells = [levelCells];
		}
		console.log("NnewQuadCells:", newQuadCells);
		setQuadCells(newQuadCells);
	}

	const handleStrikeData = () => {

		let message = gmessage;
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
		await GameContract.methods.makeMove(initalLevel ? initalLevel : 1, {row, col})
			.send({from: signer, gas: 1000000})
			.then((result) => {
				console.log("makemove result:", result);
		});
	}

	async function getLevel() {
		await GameContract.methods.level()
			.call({from: signer, gas: 100000})
			.then((level) => {
				console.log("IN get level:", level);
				if (parseInt(level) == initalLevel) {
					console.log("in IF");
					//levelInfo.levelNum = parseInt(level);
					setGameState(GState.init);
					setLevel(parseInt(level));
				}
			});
	}

	async function getCell(row, col) {
		let ret = { joined : false,  asPlayer: Player.PLAYER_NONE };
		await GameContract.methods.getState(row, col)
			.call({from: signer, gas: 100000})
			.then((value) => {
				console.log("Cell Value:", parseInt(value));
				console.log("row*marker+col:", row*marker+col);
				setGameCell(row*marker+col);
				setGamePlayerValue(parseInt(value))
				setGameState(GState.playerMoveDone);
		});
	}

	async function getGame() {
		let ret = { winner: Player.PLAYER_NONE, turn: Player.PLAYER_NONE, 
					message: ""};
		await GameContract.methods.getGame(initalLevel ? initalLevel : 1)
			.call({from: signer, gas: 100000})
			.then((info) => {
				ret = { winner: info.winner, turn: info.turn, message: info.message };
				let state = ((parseInt(info.winner) == Player.PLAYER_1) ?
							  GState.player1Wins :
							    ((parseInt(info.winner) == Player.PLAYER_2) ?
								 GState.player2Wins : gameState));
				if ((state != gameState) ||
					(info.levelCode !=  levelInfo.levelCode) ||
					(info.levelData !=  levelInfo.levelData)) {

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
				setGamePlayerValue(
					(parseInt(info.turn) == PlayerId) ? 
					((parseInt(info.turn) == Player.PLAYER_1) ? "❌" :
					 ((parseInt(info.turn) == Player.PLAYER_2) ? "⭕" : null)):null);
		});
	}

	// Register for messages/events from the Game contract
	function listen () {

		// A new game has started
		const eventNewGameStarted = GameContract.events.NewGame();
		eventNewGameStarted.on("data", async (event) => {
			let data = event.returnValues;
			levelInfo.levelNum = data.level;
			setGameState(GState.newGameStarted);			
			setLevel(parseInt(data.level));
			setLevelCode(data.levelCode);
			setLevelData(data.levelData);			
		});

		// A Player has joined the game
		const eventPlayerJoined = GameContract.events.PlayerJoined();
		eventPlayerJoined.on("data", async (event) => {
			let data = event.returnValues;
			console.log("PlayerJoined event:", data.player);
			console.log("PlayerJoined signer:", signer);

			if (data.player == signer) {
				console.log("Joined as player:", parseInt(data.id));
				setGameState(GState.playerJoined);
			}
		});

		// A Player has made a move
		const eventOppPlayerMoved = GameContract.events.PlayerMove();
		eventOppPlayerMoved.on("data", async (event) => {
			let data = event.returnValues;
			console.log("PlayerMove id:", data.id);
			console.log("PlayerMove move:", data.move);
			console.log("PlayerMove winner:", data.winner);
			console.log("PlayerMove message:", data.message);

			if (data.id ? (parseInt(data.id) != PlayerId) : false) {
				console.log("Opp player move:");

				let idx = parseInt(data.move.row)*marker+parseInt(data.move.col);
				let value = (parseInt(data.id) == Player.PLAYER_1 ? "❌" :
					 (parseInt(data.id) == Player.PLAYER_2) ? "⭕" : null);
				setGameCell(idx);
				setGamePlayerValue(value);
				console.log("OppGameCell:", idx);
				console.log("OppPlayerVal:", value);
				setTimeout(() => setGameState(GState.playerMoveInProgress), 500);
			}
		});		
	}

	function GameState() {
		switch(gameState) {
			case GState.idle:
				return '';
			break;
			case GState.levelStarted:
				return `Level ${levelInfo.level}`;
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
				gState={GState} playerVal={gplayerValue} quad={0} off={0*marker+3*0}
				cells={quadCells} onCellClick={handleCellClick}/></div> :
				<div> </div>}	
				</div>
			</h1>
			<h1>
				<div>
				{(level == 2)? <div> <Board level={level} gameState={gameState}
				gState={GState} playerVal={gplayerValue} quad={1} off={0*marker+3*1}
				cells={quadCells} onCellClick={handleCellClick}/></div> :
				<div> </div>}	
				</div>
			</h1>
			<h1>
				<div>
				{(level == 2)? <div> <Board level={level} gameState={gameState}
				gState={GState} playerVal={gplayerValue} quad={2} off={0*marker+3*2}
				cells={quadCells} onCellClick={handleCellClick}/></div> :
				<div> </div>}	
				</div>
			</h1>
			<h1>
				<div>
				{(level == 2)? <div> <Board level={level} gameState={gameState}
				gState={GState} playerVal={gplayerValue} quad={3} off={3*marker+3*0}
				cells={quadCells} onCellClick={handleCellClick}/></div> :
				<div> </div>}	
				</div>
			</h1>
			<h1>
				<div>
				{(level == 2)? <div> <Board level={level} gameState={gameState}
				gState={GState} playerVal={gplayerValue} quad={4} off={3*marker+3*1}
				cells={quadCells} onCellClick={handleCellClick}/></div> 
				: <div> <Board level={level} gameState={gameState}
				gState={GState} playerVal={gplayerValue} quad={0} off={0*marker+3*0}
				cells={quadCells} strikeClass={strikeClass} 
				onCellClick={handleCellClick}/> </div>}	
				</div>
			</h1>
			<h1>
				<div>
				{(level == 2)? <div> <Board level={level} gameState={gameState}
				gState={GState} playerVal={gplayerValue} quad={5} off={3*marker+3*2}
				cells={quadCells} onCellClick={handleCellClick}/></div> :
				<div> </div>}	
				</div>
			</h1>
			<h1>
				<div>
				{(level == 2)? <div> <Board level={level} gameState={gameState}
				gState={GState} playerVal={gplayerValue} quad={6} off={6*marker+3*0}
				cells={quadCells} onCellClick={handleCellClick}/></div> :
				<div> </div>}	
				</div>
			</h1>
			<h1>
				<div>
				{(level == 2)? <div> <Board level={level} gameState={gameState}
				gState={GState} playerVal={gplayerValue} quad={7} off={6*marker+3*1}
				cells={quadCells} onCellClick={handleCellClick}/></div> :
				<div> </div>}	
				</div>
			</h1>
			<h1>
				<div>
				{(level == 2)? <div> <Board level={level} gameState={gameState}
				gState={GState} playerVal={gplayerValue} quad={8} off={6*marker+3*2}
				cells={quadCells} onCellClick={handleCellClick}/></div> :
				<div> </div>}	
				</div>
			</h1>
		{((level == 2) && ((gameState == GState.player1Wins) ||
		  (gameState == GState.player2Wins))) ?
		 <Strike level={level} strikeClass={strikeClass}
		 	strikeStyle={strikeStyle}/> :  <div> </div>}
		<div className='game-state'>{GameState()}</div>
		<Connect onConnected={handleOnConnected} account={initialPlayerId}/>
		<JoinGame initalLevel={initalLevel} onData={handleLevelData} levelInfo={levelInfo}
		   		  gameState={gameState} gState={GState} players={Player}/>
		</div>
	);
}

export default Game;