import React from "react";
import { useState, useEffect } from "react";
import { web3, signer, GameContract, Connected, Connect } from "./Connect.jsx";
import BN from "bn.js";

function JoinGame({ onData, players }) {

	const defaultJoinState = {joined: false, asPlayer :players.PLAYER_NONE};
	const [joinState, setJoined] = useState(defaultJoinState);

	useEffect(() => {
	}, [joinState.joined]);

	// Register for messages/events from the Game contract
	async function listen () {

		// A Player has joined the game
		const eventPlayerJoined = GameContract.events.PlayerJoined();
		eventPlayerJoined.on("data", async (event) => {
			let data = event.returnValues;
			setJoined({...joinState, joined: true, asPlayer: data.id });
		});
	}

	async function requestToJoin() {
		let ret = { joined : false,  asPlayer: players.PLAYER_NONE };
		await GameContract.methods.joinGame()
			.send({from: signer, gas: 100000})
			.then((result) => {
			});
	}


	async function requestLevelData() {
		// Call "fetchLevelData()returns(bytes memory)" in Level 1
		const fetchLevelData = web3.eth.abi.encodeFunctionCall({
		    name: 'fetchLevelData',
		    type: 'function',
		    inputs: []    
		}, []);

		// Level Contract address + Encoded Function
		const callData = web3.eth.abi.encodeParameters(['address','bytes'], 
			["0x597E1a805f392F5B265831401Ee7B2AfF2cb62c0", fetchLevelData]);
		
		await GameContract.methods.callLevel(callData)
			.call({from: signer, gas: 100000})
			.then((data) => {
				data.data = data.data.split("0x")[1];
				let len = parseInt(data.data.slice(126,128), 16);
				let dataArr = new BN(data.data.slice(128, 128+2*len), 16).toArray();
				let levelNum = parseInt(dataArr.slice(0, 1), 16);
				let state, symbols;
				if (levelNum == 1) {
					state = dataArr.slice(1, 10);
					symbols = [new BN(dataArr.slice(10, 14), 16).toNumber(),
									new BN(dataArr.slice(14, 18), 16).toNumber()];					
					onData({levelNum, state, symbols});
				} else if (levelNum == 2) {
					state = dataArr.slice(1, 82);
					symbols = [new BN(dataArr.slice(82, 86), 16).toNumber(),
									new BN(dataArr.slice(86, 90), 16).toNumber(),
									new BN(dataArr.slice(90, 94), 16).toNumber(),
									new BN(dataArr.slice(94, 100), 16).toNumber()];					
					onData({levelNum, state, symbols});
				}
			});
	}

	return (<button className='join-button'
			disabled={joinState.joined}
			onClick={async () => { listen(); await requestToJoin(); await requestLevelData(); }}
			>{(joinState.joined == true)?`Joined as: Player${joinState.asPlayer}`:"Join"}</button>
	);
}

export default JoinGame;
