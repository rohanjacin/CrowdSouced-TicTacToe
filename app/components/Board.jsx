import React from "react";
import Cell from "./Cell.jsx";
import Strike from "./Strike.jsx";

function Board({ quad, cells, onCellClick }) {
	return(
		<div className="board">
			<Cell 
				onClick={()=> onCellClick(0)}
				value={cells[0]}
				className={getBorder(quad, 0)}/>
			<Cell 
				onClick={()=> onCellClick(1)}
				value={cells[1]}
				className={getBorder(quad, 1)}/>
			<Cell 
				onClick={()=> onCellClick(2)}
				value={cells[2]}
				className={getBorder(quad, 2)}/>
			
			<Cell 
				onClick={()=> onCellClick(3)}
				value={cells[3]}
				className={getBorder(quad, 3)}/>
			<Cell 
				onClick={()=> onCellClick(4)}
				value={cells[4]}
				className={getBorder(quad, 4)}/>
			<Cell 
				onClick={()=> onCellClick(5)}
				value={cells[5]}
				className={getBorder(quad, 5)}/>

			<Cell 
				onClick={()=> onCellClick(6)}
				value={cells[6]}
				className={getBorder(quad, 6)}/>
			<Cell 
				onClick={()=> onCellClick(7)}
				value={cells[7]}
				className={getBorder(quad, 7)}/>
			<Cell 
				onClick={()=> onCellClick(8)}
				value={cells[8]}
				className={getBorder(quad, 8)}/>

			<Strike />
		</div>
	);
}

function getBorder(qid, cid) {

	switch (qid) {
		case 0:
		case 1:
		case 3:
		case 4:			
			return "right-border bottom-border";
		break;
		case 2:
		case 5: {
			switch (cid) {
				case 2:
				case 5:
				case 8:
					return "bottom-border";
				break					
				default:
					return "right-border bottom-border";
				break; 
			}
		}
		break;
		case 6:
		case 7: {
			switch (cid) {
				case 6:
				case 7:
				case 8:
					return "right-border";
				break;					
				default:
					return "right-border bottom-border";
				break; 
			}
		}
		break;
		case 8: {
			switch (cid) {
				case 2:
				case 5:
					return "bottom-border";
				break					
				case 6:
				case 7:
					return "right-border";
				break;
				case 8:
					return "";
				break;				
				default:
					return "right-border bottom-border";
				break; 
			}
		}												
	}
}
export default Board;