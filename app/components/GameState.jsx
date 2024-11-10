import React from "react";
import { useState, useEffect } from "react";
import { web3, signer, GameContract, Connected, Connect } from "./Connect.jsx";

const GState = {
	levelInProgress: 0,
	player1Wins: 1,
	player2Wins: 2,
	draw: 3,
}

const Player = {
	PLAYER_NONE: 0,
	PLAYER_1: 1,
	PLAYER_2: 2,
}

function GameState({ gameState }) {
	switch(gameState.state) {
		case 0/*Gstate.levelInProgress*/:
			return <div className='game-state'>Level {gameState.level}</div>;
		break;
		case 1/*Gstate.player1Wins*/:
			return <div className='game-state'>Player 1 wins</div>;
		break;
		case 2/*Gstate.player2Win*/:
			return <div className='game-state'>Player 2 wins</div>;
		break;
		case 3/*Gstate.draw*/:
			return <div className='game-state'>Draw</div>;
		break;
		default:
			return <></>;
		break;					
	}
}

function JoinGame() {

	//console.log("Gstate.levelInProgress:", Gstate.levelInProgress);
	const defaultJoinState = {joined: false, asPlayer :Player.PLAYER_NONE};
	const [joinState, setJoined] = useState(defaultJoinState);

	useEffect(() => {
	}, [joinState.joined]);

	async function requestToJoin() {
		let ret = { joined : false,  asPlayer: Player.PLAYER_NONE };
		await GameContract.methods.joinGame()
			.call({from: signer, gas: 100000})
			.then((result) => {
				console.log("success:", result.success);
				console.log("message:", result.message);
				let player = ((result.message == "You are Player1 - X")? Player.PLAYER_1 :
					((result.message == "You are Player1 - O")?
						Player.PLAYER_2 : Player.PLAYER_NONE));
				ret = {joined : result.success, asPlayer: player};
				setJoined({...joinState, joined: true, asPlayer: player });
			});
	}

	async function requestLevelData() {
		// Call "copyLevelData()returns(bytes memory)" in Level 1
		const copyLevelData = web3.eth.abi.encodeFunctionCall({
		    name: 'copyLevelData',
		    type: 'function',
		    inputs: [],
			outputs:[{"name":"_data","type":"bytes"}]    
		}, []);

		console.log("requestLevelData:", copyLevelData);
		// Level Contract address + Encoded Function
		const callData = web3.eth.abi.encodeParameters(['address','bytes'], 
			["0x356bc565e99C763a1Ad74819D413A6D58E565Cf2", copyLevelData]);

		console.log("callData:", callData);
		
		await GameContract.methods.callLevel(callData)
			.call({from: signer, gas: 100000})
			.then((data) => {
				console.log("data:", data);
			});
	}

	return <button className='join-button'
			disabled={joinState.joined}
			onClick={async () => { await requestToJoin(); await requestLevelData(); }}
			>{(joinState.joined == true)?`Joined as: Player${joinState.asPlayer}`:"Join"}</button>
}

export {
	GState,
	Player,
	GameState,
	JoinGame,
};