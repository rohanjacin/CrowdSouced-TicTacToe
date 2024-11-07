import React from "react";
import Cell from "./Cell.jsx";
import Strike from "./Strike.jsx";

function Board({ cells, onCellClick }) {
	return(
		<div className="board">
			<Cell 
				onClick={()=> onCellClick(0)}
				value={cells[0]}
				className="right-border bottom-border"/>
			<Cell 
				onClick={()=> onCellClick(1)}
				value={cells[1]}
				className="right-border bottom-border"/>
			<Cell 
				onClick={()=> onCellClick(2)}
				value={cells[2]}
				className="bottom-border"/>
			
			<Cell 
				onClick={()=> onCellClick(3)}
				value={cells[3]}
				className="right-border bottom-border"/>
			<Cell 
				onClick={()=> onCellClick(4)}
				value={cells[4]} className="right-border bottom-border"/>
			<Cell 
				onClick={()=> onCellClick(5)}
				value={cells[5]}
				className="bottom-border"/>

			<Cell 
				onClick={()=> onCellClick(6)}
				value={cells[6]}
				className="right-border "/>
			<Cell 
				onClick={()=> onCellClick(7)}
				value={cells[7]}
				className="right-border "/>
			<Cell 
				onClick={()=> onCellClick(8)}
				value={cells[8]}
				className=""/>

			<Strike />
		</div>
	);
}

export default Board;