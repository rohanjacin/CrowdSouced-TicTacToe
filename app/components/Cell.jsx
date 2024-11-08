import React from "react";

function Cell({ className, playerTurn, value, onClick }) {
	let hoverClass = null;
	if (value == null && playerTurn != null) {
		hoverClass = `${playerTurn}-hover`;
	}

	return <div onClick={onClick} 
				className={`cell ${className} ${hoverClass}` }>
				{value}
		   </div>;
}

export default Cell;