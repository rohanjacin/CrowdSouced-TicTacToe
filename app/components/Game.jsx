import React from "react";
import Board from "./Board.jsx";
import { useState } from "react";

function Game() {
	const [cells, setCells] = useState(Array(9).fill(null));

	const handleCellClick = (index) => {
		const newCells = [...cells];
		newCells[index] = "❌";
		setCells(newCells); 
	}

	return(
		<div>
			<h1>Game</h1>
			<Board cells={cells} onCellClick={handleCellClick}/>
		</div>
	);
}

export default Game;