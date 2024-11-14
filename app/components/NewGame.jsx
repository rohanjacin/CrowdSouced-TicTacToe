import React from "react";
import { useState, useEffect } from "react";
import { web3, signer, GameContract, Connected, Connect } from "./Connect.jsx";
import BN from "bn.js";

function NewGame({ onData, gameState }) {

	const [newGame, setNewGame] = useState(false);

	useEffect(() => {
		if (Connected == true) {

			if (newGame) {
				
			}	
		}
	}, [newGame]);

	async function startNewGame() {
		await GameContract.methods.newGame(1)
			.send({from: signer, gas: 200000})
			.then((result) => {
				console.log("result:", result);
				setNewGame(true);
/*				(result.message == "Level loaded")?
					setNewGame(true) : setNewGame(false);
*/			});
	}

	return (<button className='newgame-button'
			disabled={newGame}
			onClick={async () => {
				if (Connected == true) {
					await startNewGame();
				}
			}}
			>{(newGame)?"Level 1":"NewGame"}</button>
	);
}

export default NewGame;
