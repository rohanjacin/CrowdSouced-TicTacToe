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
		<div className="game">
			<h1>
				<div>
				<Board quad={0} cells={cells} onCellClick={handleCellClick}/>
				</div>
			</h1>
			<h1>
				<div>
				<Board quad={1} cells={cells} onCellClick={handleCellClick}/>
				</div>
			</h1>
			<h1>
				<div>
				<Board quad={2} cells={cells} onCellClick={handleCellClick}/>
				</div>
			</h1>
			<h1>
				<div>
				<Board quad={3} cells={cells} onCellClick={handleCellClick}/>
				</div>
			</h1>
			<h1>
				<div>
				<Board quad={4} cells={cells} onCellClick={handleCellClick}/>
				</div>
			</h1>
			<h1>
				<div>
				<Board quad={5} cells={cells} onCellClick={handleCellClick}/>
				</div>
			</h1>
			<h1>
				<div>
				<Board quad={6} cells={cells} onCellClick={handleCellClick}/>
				</div>
			</h1>
			<h1>
				<div>
				<Board quad={7} cells={cells} onCellClick={handleCellClick}/>
				</div>
			</h1>
			<h1>
				<div>
				<Board quad={8} cells={cells} onCellClick={handleCellClick}/>
				</div>
			</h1>
		</div>

	);
}
			//<Board cells={cells} onCellClick={handleCellClick}/>

export default Game;