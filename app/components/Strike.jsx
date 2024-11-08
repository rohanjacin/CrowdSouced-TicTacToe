import React from "react";

function Strike({ level, strikeClass, strikeStyle }) {

	const rowStyle = (c) => ({
		left: `${c*12}%`
	})
	const colStyle = (r) => ({
		top: `${r*12}%`
	})
	const fwddiagStyle = (d) => ({
		top: `${(d==0)?25:(d*10 + 28)}%`,
		left: `${(d==0)?4:(d*10 + 7)}%`

	})
	const bckwddiagStyle = (d) => ({
		top: `${(d==0)?25:(d*11 + 25)}%`,
		left: `${(d==0)?58:(58 - d*11)}%`
	})		

	function getStrikeStyle(r, c, d, combo) {

		switch (combo) {
			case "row": {
				return rowStyle(c);
			}
			break;
			case "col": {
				return colStyle(r);
			}
			break;
			case "fwddiag": {
				return fwddiagStyle(d);
			}
			break;
			case "bckwddiag": {
				return bckwddiagStyle(d);
			}
			break;			
		}
	}

	return(
		<div className={`strike ${strikeClass}`} 
			 style={(level == 2) ? getStrikeStyle(strikeStyle.row,
			 	strikeStyle.col, strikeStyle.diag, strikeStyle.combo) : {}} ></div>
	);

}

export default Strike;