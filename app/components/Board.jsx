import React from "react";
import Cell from "./Cell.jsx";
import Strike from "./Strike.jsx";

function Board({ level, quad, off, cells, onCellClick }) {
	let marker = (level == 2)? 9 : 3;
	
	return(
		<div className="board">
			<Cell 
				onClick={()=> onCellClick(off+marker*0+0)}
				value={cells[off+0]}
				className={getBorder(level, quad, 0)}/>
			<Cell 
				onClick={()=> onCellClick(off+marker*0+1)}
				value={cells[off+1]}
				className={getBorder(level, quad, 1)}/>
			<Cell 
				onClick={()=> onCellClick(off+marker*0+2)}
				value={cells[off+2]}
				className={getBorder(level, quad, 2)}/>
			
			<Cell 
				onClick={()=> onCellClick(off+marker*1+0)}
				value={cells[off+marker+0]}
				className={getBorder(level, quad, 3)}/>
			<Cell 
				onClick={()=> onCellClick(off+marker*1+1)}
				value={cells[off+marker+1]}
				className={getBorder(level, quad, 4)}/>
			<Cell 
				onClick={()=> onCellClick(off+marker*1+2)}
				value={cells[off+marker+2]}
				className={getBorder(level, quad, 5)}/>

			<Cell 
				onClick={()=> onCellClick(off+marker*2+0)}
				value={cells[off+2*marker+0]}
				className={getBorder(level, quad, 6)}/>
			<Cell 
				onClick={()=> onCellClick(off+marker*2+1)}
				value={cells[off+2*marker+1]}
				className={getBorder(level, quad, 7)}/>
			<Cell 
				onClick={()=> onCellClick(off+marker*2+2)}
				value={cells[off+2*marker+2]}
				className={getBorder(level, quad, 8)}/>

			<Strike />
		</div>
	);
}

function getBorder(level, qid, cid) {

	switch (qid) {
		case 0: {
			if (level == 2)
				return "right-border bottom-border";
			else {
				switch (cid) {
					case 0:
					case 1:
					case 3:
					case 4:
						return "right-border bottom-border";
					case 2:
					case 5:
						return "bottom-border";
					case 6:
					case 7:
						return "right-border";
					case 8:
						return "";
				}
			}
		}
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