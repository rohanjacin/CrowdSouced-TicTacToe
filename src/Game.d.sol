// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.27;

import "./BaseLevel.d.sol";
import "./BaseState.d.sol";
import "./BaseSymbol.d.sol";
import "./BaseData.sol";
import "./LevelConfigurator.sol";
import "./ILevelConfigurator.sol";
import "./RuleEngine.sol";
import "semaphore/packages/contracts/contracts/interfaces/ISemaphore.sol";
import "openzeppelin-contracts/contracts/utils/Strings.sol";

// Players
enum Player { None, Player1, Player2 }
// Possible cell values
enum CellValueL { Empty , X, O}

// Errors
error LevelInvalid();
error LevelNotDeployed();
error LevelCopyFailed();
error PlayerAddressInvalid();

contract GameHouse {
	address public goV;
	address public levelConfigurator;
	address public ruleEngine;

	constructor(address _admin) {
		//goV = new goV();
		levelConfigurator = address(new LevelConfigurator(_admin, 
								ISemaphore(address(0x02))));
		console.log("levelConfigurator:", levelConfigurator);
		//ruleEngine = new RuleEngine();
	}
}

// Game info
struct GameInfo {
	GameHouse house;
	address player1;
	address player2;
	address levelAddress;
	Player winner;
	Player turn;
	string message;	
}

// Players move
struct Move {
	uint8 row;
	uint8 col;
}

// Game
contract GameD is BaseLevelD, BaseStateD, BaseSymbolD, BaseData, RuleEngine {

	// SLOT 0 is from BaseLevel (Do NOT use SLOT 0)
	//uint8 level;

	// SLOT 1 is from BaseState (Do NOT use SLOT 1)
	//State board;

	// SLOT 2 is from BaseSymbols (Do NOT use SLOT 2)
	//Symbols symbols;

	// SLOT 3 is from BaseData (Do NOT use SLOT 3)
	//address data;

	// SLOT 4 is from RuleEngine (Do NOT use SLOT 4)
    //bytes16 private constant HEX_DIGITS = "0123456789abcdef";

	// SLOT 5 is from RuleEngine (Do NOT use SLOT 5)
	//mapping(uint8 => bytes4) rules;

	// SLOT 6 is for Game Admin
	address admin;

	// SLOT 7 is Game instance (id = level number)
	mapping(uint8 => GameInfo) public games;

	// Load the default state in Base State
	constructor(address _admin) {
		admin = _admin;
		// Game House components
		games[1].house = new GameHouse(admin);
	}

	fallback() external {
		console.log("In Game fallback");
	}

	// Direct calls to valid Level Contract
	function callLevel(bytes calldata levelCall)
		external payable returns(bool success, bytes memory data) {

		console.log("In callLevel");
		// Level Address + encoded Function Data (i.e sel, params)
        (address target, bytes memory callData) = abi.decode(levelCall,
													(address, bytes));
		console.log("target:", target);
		console.log("games[1].levelAddress:", games[1].levelAddress);

		if (target ==  games[1].levelAddress) {
			(success, data) = target.call{value: msg.value}(callData);
			console.log("success:", success);
		}
	}

	function retrieveLevel(uint8 levelnum, address data)
		internal returns (bytes memory _num,
		bytes memory _state, bytes memory _symbol) {

		bytes memory _data = BaseData.copyData(data);
		uint8 _numlen;
		uint8 _statelen;
		uint8 _symbollen;

		if (levelnum == 1) {
			_numlen = 1;
			_statelen = 9;
			_symbollen = 2;
		}
		else if (levelnum == 2) {
			_numlen = 1;
			_statelen = 81;
			_symbollen = 4;
		}

		assembly {
			// Total length and start
			let len := mload(_data)
			let ptr := add(_data, 0x20)

			// Reserve and copy level num 
			_num := mload(0x40)
			mcopy(add(_num, 0x20), ptr, _numlen)
			mstore(_num, _numlen)
			mstore(0x40, add(_num, 0x40))

			// Reserve and copy level state 
			_state := mload(0x40)
			mcopy(add(_state, 0x20), add(ptr, _numlen), _statelen)
			mstore(_state, _statelen)
			mstore(0x40, add(_state, 0x40))

			// Reserve and copy level state 
			_symbol := mload(0x40)
			mcopy(add(_symbol, 0x20), add(ptr, add(_numlen, _statelen)), mul(_symbollen, 4))
			mstore(_symbol, mul(_symbollen, 4))
			mstore(0x40, add(_symbol, 0x40))
		}

	}

	// Loads the level
	function loadLevel(address bidder) external onlyAdmin
		returns(bool success, string memory message) {

		LevelConfig memory config = LevelConfig(0, 0, 0, 0, 0, 0,
									address(0), address(0)); 
		(config.num, config.codeLen, config.levelNumLen, config.stateLen,
		 config.symbolLen, config.hash, config.codeAddress, config.dataAddress)
		 = ILevelConfigurator(games[1].house.levelConfigurator()).proposals(bidder);

		// Level check for L1 or L2
/*		if (!(config.num == level)) {
			revert LevelInvalid();
		}
*/
		(bytes memory _levelnum, 
		 bytes memory _levelstate,
		 bytes memory _levelsymbol) = retrieveLevel(uint8(config.num),
		 								config.dataAddress);

		// Copy Level via delegatecall
		(success, ) = config.codeAddress
			.delegatecall(abi.encodeWithSignature("copyLevelData(bytes,bytes,bytes)",
			 _levelnum, _levelstate, _levelsymbol));

		if (success == false) {
			revert LevelCopyFailed();
		}

		// Store level address
		games[1].levelAddress = config.codeAddress;
		console.log("levelAddress:", games[1].levelAddress);

		// Add level rules
		uint8 _symbolLen = uint8(config.symbolLen/4);
		
		BaseSymbolD.Symbols memory _symbols = BaseSymbolD.Symbols(
			{v: new bytes4[](_symbolLen)});
		
		for (uint8 i = 0; i < _symbolLen; i++) {
			_symbols.v[i] = getSymbol(i);
		}

		addRules(games[1].levelAddress, _symbols);

		return (true, "Level loaded");
	}

	// Starts a new game
	function newGame(uint8 _level) external onlyAdmin {

		// Check if game requested is 
		// for configured level
		if (!((_level == 1) || (_level == 2))) {
			revert LevelInvalid();
		}

		// Game instance is 1 for now
		// Iinitalize game
		games[1].winner = Player.None;
		games[1].turn = Player.Player1;
	}

	function getGame() external returns(GameInfo memory info){
		return games[1];
	}

	// Join the game
	function joinGame() external returns(bool success,
		string memory message) {

		// Check players address
		if (msg.sender == address(0)) {
			revert PlayerAddressInvalid();
		}

		if (games[1].player1 == address(0)) {
			
			// Store player 1
			games[1].player1 = msg.sender;
			return (true, "You are Player1 - X");
		}

		if (games[1].player2 == address(0)) {
			
			// Store player 2
			games[1].player2 = msg.sender;
			return (true, "You are Player2 - O");			
		}

		return (false, "Players already joined");
	}

	// Make a move //onlyPlayers
	function makeMove(Move memory move) external 
		returns(bool success, string memory message) {

		// Check if already winner exists
		if (games[1].winner != Player.None) {
			return (false, "The game has aready ended!");
		}

		// Only player who's turn it is can make a move
		if (msg.sender != _getCurrentPlayer()) {
			//return (false, "Not your turn");
		}

		// Check cell initial value
		uint8 value = uint8(getState(move.row, move.col));

		if (!((value == uint8(CellValueL.Empty)) ||
		     (value > 128))) {
			//revert();
		}

		uint8 setVal;
		if (games[1].turn == Player.Player1) {
			setVal = uint8(CellValueL.X);
		}
		else if (games[1].turn == Player.Player2) {
			setVal = uint8(CellValueL.O);
		}

		// Execute for move as per rule
		(success) = setCell(games[1].levelAddress, 
								move.row, move.col, setVal);
		assert(success == true);
		assert(uint8(getState(move.row, move.col)) == setVal);

		// Calculator Winner
		(Player winner, string memory m) = _calculateWinner();
		// There is a winner
		if (winner != Player.None) {

			// Game ended 
			games[1].winner = winner;
			message = string(abi.encodePacked("You Won!", "@", m));
			games[1].message = message;
			return (true, message); 
		}

		// Next player's turn
		if (games[1].turn == Player.Player1) {
			games[1].turn = Player.Player2;
		}
		else if (games[1].turn == Player.Player2) {
			games[1].turn = Player.Player1;
		}

		return (true, "Next player's turn");
	}

	// Gets current players who's turn it is
	function _getCurrentPlayer() internal view returns(address player) {

		if (games[1].turn == Player.Player1) {
			return games[1].player1;
		}
		
		if (games[1].turn == Player.Player2) {
			return games[1].player2;
		}
	
		return address(0);
	}

	// Finds the winner 
	function _calculateWinner() internal view
		returns (Player winner, string memory message) {

		// Winner in rows
		(winner, message) = _winnerInRows();
		if (winner != Player.None)
			return (winner, message);

		// Winner in columns
		(winner, message) = _winnerInColumns();
		if (winner != Player.None)
			return (winner, message);

		// Winers in both diagonals
		(winner, message) = _winnerInDiagonals();
		if (winner != Player.None)
			return (winner, message);


		if (true == _isBoardFull()) {
			winner = Player.None;
		}

		console.log("Final winner:", uint(winner));
		console.log("Message:", message);
	}

	// Check if there are no empty cells on the board
	function _isBoardFull() internal view returns (bool ret) {

		uint8 _marker;

		ret = true;

		if (level == 1) {
			_marker = 3;
		}
		else if (level == 2) {
			_marker = 9;
		}

		for (uint8 r = 0; r < _marker; r++) {

			for (uint8 c = 0; c < _marker; c++) {

				if (getState(r, c) == uint8(CellValueL.Empty)) {
					ret = false;
					break;
				}
			}
		}
	}

	// Check longest X or O sequence in all rows
	function _winnerInRows() internal view 
		returns (Player winner, string memory message){

		uint8 countX;
		uint8 countO;
		uint8 _marker;
		uint8 _tuples;
		uint8 row;
		uint8 col;

		if (level == 1) {
			_marker = 3;
			_tuples = 1;
		}
		else if (level == 2) {
			_marker = 9;
			_tuples = 6;
		}

		console.log("In Rows..");
		// Rows
		for (uint8 r = 0; r < _marker; r++) {

			console.log("r:", r);

			for (uint8 c = 0; c < _tuples; c++) {
				console.log(" c:", c);

				if (level == 1) {
					if ((getState(r, c) == getState(r, c+1)) &&
					    (getState(r, c+1) == getState(r, c+2))) {

						if (getState(r, c) == uint8(CellValueL.X)) {
						   	countX = 1;
							console.log(" countX:", countX);
						   	winner = Player.Player1;
						   	col = c;							
						}
						else if (getState(r, c) == uint8(CellValueL.O)) {
						   	countO = 1;
							console.log(" countO:", countO);
						   	winner = Player.Player2;
						   	col = c;							
						} 
					}
				}
				else if (level == 2) {
					if ((getState(r, c) == getState(r, c+1)) &&
					   (getState(r, c+1) == getState(r, c+2)) &&
					   (getState(r, c+2) == getState(r, c+3))) {

					   	if (getState(r, c) == uint8(CellValueL.X)) {
						   	countX = 1;
							console.log(" countX:", countX);
						   	winner = Player.Player1;
					   	}
					   	if (getState(r, c) == uint8(CellValueL.O)) {
						   	countO = 1;
							console.log(" countO:", countO);
						   	winner = Player.Player2;
					   	}
					}
				}
			}

			if (countX == countO) {
				winner = Player.None;
			}
			else {
				row = r;
				message = string(abi.encodePacked("combo:", "row",
					",r:", Strings.toString(row), ",c:",
					Strings.toString(col), ",d:", ""));
				break;
			}
		}

		console.log("winner:", uint(winner));
		console.log("message:", message);
	}

	// Check longest X or O sequence in all columns
	// Check longest X or O sequence in all rows
	function _winnerInColumns() internal view
		returns (Player winner, string memory message){

		uint8 countX;
		uint8 countO;
		uint8 _marker;
		uint8 _tuples;
		uint8 row;
		uint8 col;

		if (level == 1) {
			_marker = 3;
			_tuples = 1;
		}
		else if (level == 2) {
			_marker = 9;
			_tuples = 6;
		}

		console.log("In Columns..");

		// Columns
		for (uint8 c = 0; c < _marker; c++) {

			console.log("c:", c);

			for (uint8 r = 0; r < _tuples; r++) {
				console.log(" r:", r);

				if (level == 1) {
					if ((getState(r, c) == getState(r+1, c)) &&
					    (getState(r+1, c) == getState(r+2, c))) {

						if (getState(r, c) == uint8(CellValueL.X)) {
						   	countX = 1;
							console.log(" countX:", countX);
						   	winner = Player.Player1;
						   	row = r;							
						}
						else if (getState(r, c) == uint8(CellValueL.O)) {
						   	countO = 1;
							console.log(" countO:", countO);
						   	winner = Player.Player2;
						   	row = r;							
						} 
					}
				}
				else if (level == 2) {
					if ((getState(r, c) == getState(r+1, c)) &&
					   (getState(r+1, c) == getState(r+2, c)) &&
					   (getState(r+2, c) == getState(r+3, c))) {

					   	if (getState(r, c) == uint8(CellValueL.X)) {
						   	countX = 1;
							console.log(" countX:", countX);
						   	winner = Player.Player1;
					   	}
					   	if (getState(r, c) == uint8(CellValueL.O)) {
						   	countO = 1;
							console.log(" countO:", countO);
						   	winner = Player.Player2;
					   	}
					}
				}
			}

			if (countX == countO) {
				winner = Player.None;
			}
			else {
				col = c;
				message = string(abi.encodePacked("combo:", "col",
					",r:", Strings.toString(row), ",c:",
					Strings.toString(col), ",d:", ""));				
				break;
			}
		}

		console.log("winner:", uint(winner));
		console.log("message:", message);
	}

	function _winnerInDiagonals() internal view
		returns (Player winner, string memory message) {

		uint8 countX;
		uint8 countO;
		uint8 _marker;
		uint8 _tuples;
		uint8 combo;
		uint8 diag;

		if (level == 1) {
			_marker = 3;
			_tuples = 1;
		}
		else if (level == 2) {
			_marker = 9;
			_tuples = 6;
		}

		console.log("In Diagonals..");

		if (level == 1) {

			if ((getState(0, 0) == getState(1, 1)) &&
			    (getState(1, 1) == getState(2, 2))) {

				if (getState(0, 0) == uint8(CellValueL.X)) {
				   	countX = 1;
					console.log(" countX:", countX);
				   	winner = Player.Player1;
			   	}
			   	if (getState(0, 0) == uint8(CellValueL.O)) {
				   	countO = 1;
					console.log(" countO:", countO);
				   	winner = Player.Player2;
			   	}
			   	combo = 1;	
			}
			else if ((getState(0, 2) == getState(1, 1)) &&
			    (getState(1, 1) == getState(2, 0))) {

				if (getState(0, 2) == uint8(CellValueL.X)) {
				   	countX = 1;
					console.log(" countX:", countX);
				   	winner = Player.Player1;
			   	}
			   	if (getState(0, 2) == uint8(CellValueL.O)) {
				   	countO = 1;
					console.log(" countO:", countO);
				   	winner = Player.Player2;
			   	}
			   	combo = 2;
			}
		}
		else if (level == 2) {

			uint8 e = 0;
			uint8 d = 0;

			for (d = 0; d < _tuples; d++) {
				console.log("forward:");
				console.log(" d:", d);
			
				if ((getState(d, d) == getState(d+1, d+1)) &&
					(getState(d+1, d+1) == getState(d+2, d+2)) &&
					(getState(d+2, d+2) == getState(d+3, d+3))) {

				   	if (getState(d, d) == uint8(CellValueL.X)) {
					   	countX = 1;
						console.log(" countX:", countX);
					   	winner = Player.Player1;
				   	}
				   	if (getState(d, d) == uint8(CellValueL.O)) {
					   	countO = 1;
						console.log(" countO:", countO);
					   	winner = Player.Player2;
				   	}
			   		combo = 1;
			   		diag = d;
				}			
			}

			if (countX == countO) {
				d = 0;
				for ( ; (d < _tuples && e < _tuples); ) {
					console.log("backward:");
					console.log(" d:", d);
					console.log(" e:", e);
				
					if ((getState(e, 8-d) == getState(e+1, 7-d)) &&
						(getState(e+1, 7-d) == getState(e+2, 6-d)) &&
						(getState(e+2, 6-d) == getState(3+e, 5-d))) {

					   	if (getState(e, 8-d) == uint8(CellValueL.X)) {
						   	countX = 1;
							console.log(" countX:", countX);
						   	winner = Player.Player1;
					   	}
					   	if (getState(e, 8-d) == uint8(CellValueL.O)) {
						   	countO = 1;
							console.log(" countO:", countO);
						   	winner = Player.Player2;
					   	}

					   	combo = 2;
					   	diag = d;
					}

					d++;
					e++;
				}
			}
		}

		if (countX == countO) {
			winner = Player.None;
		}
		else {
			message = string(abi.encodePacked("combo:", ((combo == 1) ? "fwddiag" :
				combo == 2 ? "bckwddiag" : ""), ",r:", " ", ",c:", " ",
				",d:", Strings.toString(diag)));
		}

		console.log("winner:", uint(winner));
	}

    modifier onlyAdmin {
        if (msg.sender != admin) revert("Not Admin");
        _;
    }

    modifier onlyPlayers {
        if ((msg.sender != games[1].player1) &&
        	(msg.sender != games[1].player2)) revert("Not Player");
        _;
    }
}
