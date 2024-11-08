import React from "react";

function Strike({ level, strikeClass, strikeStyle }) {
	console.log("strikeClass:", strikeClass);

	const rowStyle = (c) => ({
		left: `${c*12}%`
	})
	const colStyle = (r) => ({
		top: `${r*12}%`
	})

	function getStrikeStyle(r, c, combo) {

		switch (combo) {
			case "winnerInRow": {
				return rowStyle(c);
			}
			break;
			case "winnerInCol": {
				return colStyle(r);
			}
			break;
			case "winnerInFwdDiag": {
				return colStyle(c);
			}
			break;
			case "winnerInBckwdDiag": {
				return colStyle(c);
			}
			break;			
		}
	}

	return(
		<div className={`strike ${strikeClass}`} 
			 style={(level == 2) ? getStrikeStyle(strikeStyle.row,
			 	strikeStyle.col, strikeStyle.combo) : {}} ></div>
	);

}

export default Strike;