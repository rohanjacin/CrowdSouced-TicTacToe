import React from "react";

function Cell({ className, playerVal, value, onClick }) {
	let hoverClass = null;
	if (value == null && playerVal != null) {
		hoverClass = `${playerVal}-hover`;
	}

	return <div onClick={onClick} 
				className={`cell ${className} ${hoverClass}` }>
				{value}
		   </div>;
}

export default Cell;