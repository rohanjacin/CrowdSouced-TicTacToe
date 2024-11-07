import React from "react";

function Cell({ className, value, onClick }) {
	return <div onClick={onClick} 
				className={`cell ${className}` }>
				{value}
		   </div>;
}

export default Cell;