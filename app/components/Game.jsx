import React from "react";
import Board from "./Board.jsx";
import { useState } from "react";

function Game() {
	// Level
	const [level, setLevel] = useState(2);
	// Level cell count
	const numCells = (level == 2)? 81 : 9;
	const marker = (level == 2)? 9 : 3;
	
	// Cell array formats
	const [cells, setCells] = useState((level == 2) ? 
							  (Array.from({ length: 9 }, 
							  () => new Array(9).fill(null))) :
							  (Array.from({ length: 3 }, 
							  () => new Array(3).fill(null))));
	const [quadCells, setQuadCells] = useState(Array(numCells).fill(null));

	// On move send row and col of cell to Game.sol
	const handleCellClick = (index) => {

		let row = Math.floor(index/numCells);
		let col = index%numCells;
		
		const newCells = [...cells];
		newCells[row, col] = index;
		setCells(newCells);

		let idx = row*marker+col;
		const newQuadCells = [...quadCells];
		newQuadCells[idx] = index;
		setQuadCells(newQuadCells);
	}

	return(
		<div className="game">
			<h1>
				<div>
				{(level == 2)? <div> <Board level={level} quad={0} off={0*marker+3*0} cells={quadCells} 
				onCellClick={handleCellClick}/></div> : <div> </div>}	
				</div>
			</h1>
			<h1>
				<div>
				{(level == 2)? <div> <Board level={level} quad={1} off={0*marker+3*1} cells={quadCells} 
				onCellClick={handleCellClick}/></div> : <div> </div>}	
				</div>
			</h1>
			<h1>
				<div>
				{(level == 2)? <div> <Board level={level} quad={2} off={0*marker+3*2} cells={quadCells} 
				onCellClick={handleCellClick}/></div> : <div> </div>}	
				</div>
			</h1>
			<h1>
				<div>
				{(level == 2)? <div> <Board level={level} quad={3} off={3*marker+3*0} cells={quadCells} 
				onCellClick={handleCellClick}/></div> : <div> </div>}	
				</div>
			</h1>
			<h1>
				<div>
				{(level == 2)? <div> <Board level={level} quad={4} off={3*marker+3*1} cells={quadCells} 
				onCellClick={handleCellClick}/></div> 
				: <div> <Board quad={0} cells={quadCells} 
				onCellClick={handleCellClick}/> </div>}	
				</div>
			</h1>
			<h1>
				<div>
				{(level == 2)? <div> <Board level={level} quad={5} off={3*marker+3*2} cells={quadCells} 
				onCellClick={handleCellClick}/></div> : <div> </div>}	
				</div>
			</h1>
			<h1>
				<div>
				{(level == 2)? <div> <Board level={level} quad={6} off={6*marker+3*0} cells={quadCells} 
				onCellClick={handleCellClick}/></div> : <div> </div>}	
				</div>
			</h1>
			<h1>
				<div>
				{(level == 2)? <div> <Board level={level} quad={7} off={6*marker+3*1} cells={quadCells} 
				onCellClick={handleCellClick}/></div> : <div> </div>}	
				</div>
			</h1>
			<h1>
				<div>
				{(level == 2)? <div> <Board level={level} quad={8} off={6*marker+3*2} cells={quadCells} 
				onCellClick={handleCellClick}/></div> : <div> </div>}	
				</div>
			</h1>
		</div>

	);
}

export default Game;