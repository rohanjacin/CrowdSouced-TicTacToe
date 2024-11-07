import React from "react";
import Cell from "./Cell.jsx";
import Strike from "./Strike.jsx";

function Board() {
	return(
		<div className="board">
			<Cell className="right-border bottom-border"/>
			<Cell className="right-border bottom-border"/>
			<Cell className="bottom-border"/>
			
			<Cell className="right-border bottom-border"/>
			<Cell className="right-border bottom-border"/>
			<Cell className="bottom-border"/>

			<Cell className="right-border "/>
			<Cell className="right-border "/>
			<Cell className=""/>

			<Strike />
		</div>
	);
}

export default Board;