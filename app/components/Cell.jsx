import React from "react";

function Cell({ className }) {
	return <div className={`cell ${className}` }>❌</div>;
}

export default Cell;