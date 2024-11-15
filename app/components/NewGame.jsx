import React from "react";
import { useState, useEffect } from "react";
import { Link } from 'react-router-dom';
import { web3, signer, GameContract, Connected, Connect } from "./Connect.jsx";
import BN from "bn.js";
import Popup from 'reactjs-popup';

function NewGame({ onData, gameState }) {

	const [newGame, setNewGame] = useState({"set":false, "level": null,
											"code": null, "data": null});

	useEffect(() => {
		if (Connected == true) {

			if (gameState.context.level) {
				setNewGame({...newGame, "set": true, 
							"level": parseInt(gameState.context.level),
							"code": gameState.context.levelCode, 
							"data": gameState.context.levelData});
			}	
		}
	}, [gameState.context.level,
		gameState.context.levelCode,
		gameState.context.levelData]);	

	async function startNewGame() {
		await GameContract.methods.newGame(1)
			.send({from: signer, gas: 200000})
			.then((result) => {
				console.log("result:", result);
			});
	}

    function displayLevel() {
        window.open("https://remix.ethereum.org/");
    }

    function loadLevel() {
        console.log("loadLevel");
    }

	return (<div>
				<button className='newgame-button'
				onClick={newGame.code ? displayLevel :
				async () => { if (Connected == true) { await startNewGame();}}}>
				{(newGame.set == true)? `Level ${newGame.level}`:"NewGame"}
		    	</button>
			    <Popup open={newGame.set} modal>
			    	{() => (<h1><input className='loadlevel-popup' type="text"
			    		placeholder="Level 2 proposer's address" onChange={loadLevel}/></h1>)}
			    </Popup>
		    </div>
	);
}

export default NewGame;
