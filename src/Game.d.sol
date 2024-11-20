// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.27;

import "./BaseLevel.d.sol";
import "./BaseState.d.sol";
import "./BaseSymbol.d.sol";
import "./BaseData.sol";
import "./LevelConfigurator.sol";
import "./ILevelConfigurator.sol";
import { ILevelD } from "./ILevel.d.sol";
import "./RuleEngine.d.sol";
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
error BidderAddressInvalid();
error PlayerAddressInvalid();

contract GameHouse {
	address public levelConfigurator;

	constructor(address _admin) {
		levelConfigurator = address(new LevelConfigurator(_admin));
	}
}

// Game info
struct GameInfo {
	address player1;
	address player2;
	address levelCode;
	address levelData;
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
	GameHouse public house;

	// SLOT 7 is Game instance (id = level number)
	mapping(uint8 => GameInfo) public games;

	// When a new game is started	
	event NewGame (uint8 level, address levelCode,
		address levelData);

	// When player joins the game	
	event PlayerJoined (address player, uint8 id);

	// When player makes a move	
	event PlayerMove (Player id, Move move,
		Player winner, string message);

	// Load the default state in Base State
	constructor(address _admin) {
		admin = _admin;
		// Game House components
		house = new GameHouse(admin);
	}

	fallback() external {
	}

	function getLevelConfigurator() external view returns(address) {
		return house.levelConfigurator();
	}

	// Direct calls to valid Level Contract
	function callLevel(uint8 id, bytes calldata levelCall)
		external payable returns(bool success, bytes memory data) {

		// Level Address + encoded Function Data (i.e sel, params)
        (address target, bytes memory callData) = abi.decode(levelCall,
													(address, bytes));

		if (target ==  games[id].levelCode) {
			(success, data) = target.call{value: msg.value}(callData);
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
	function _loadLevel(uint8 id, uint8 _level, address bidder)
		internal returns(bool success, string memory message) {

		ILevelConfigurator.LevelConfig memory config;

		config = ILevelConfigurator(house.levelConfigurator())
						.getProposal(bidder);			

		// Level check for L1 or L2
		if (!(config.num == _level)) {
			//revert LevelInvalid();
		}

		(bytes memory _levelnum, 
		 bytes memory _levelstate,
		 bytes memory _levelsymbol) = retrieveLevel(uint8(config.num),
		 								config.dataAddress);

		// Copy Level via delegatecall	
		bytes memory cdata = abi.encodeCall(ILevelD.copyLevelData,
			(_levelnum, _levelstate, _levelsymbol));
		
		(success, ) = config.codeAddress.delegatecall(cdata);

		if (success == false) {
			revert LevelCopyFailed();
		}

		// Store level address
		games[id].levelCode = config.codeAddress;
		games[id].levelData = config.dataAddress;

		// Add level rules
		uint8 _symbolLen = uint8(config.symbolLen/4);
		
		BaseSymbolD.Symbols memory _symbols = BaseSymbolD.Symbols(
			{v: new bytes4[](_symbolLen)});
		
		for (uint8 i = 0; i < _symbolLen; i++) {
			_symbols.v[i] = getSymbol(i);
		}

		addRules(games[id].levelCode, _symbols);

		return (true, "Level loaded");
	}

	// Starts a new game
	function newGame(uint8 id, uint8 _level, address _bidder)
		external onlyAdmin returns (bool success, string memory message) {

		// Check if game requested is 
		// for configured level
		if (!((_level == 1) || (_level == 2))) {
			revert LevelInvalid();
		}

		if (_bidder == address(0)) {
			revert BidderAddressInvalid();
		}

		(success, message) = _loadLevel(id, _level, _bidder);

		if (success == true) {
			// Initalize game
			games[id].winner = Player.None;
			games[id].turn = Player.Player1;
			games[id].player1 = address(0);
			games[id].player2 = address(0);

			emit NewGame(level, games[id].levelCode, games[id].levelData);			
		}
	}

	function getGame(uint8 id) external view returns(GameInfo memory info){
		return games[id];
	}

	// Join the game
	function joinGame(uint8 id) external returns(bool success,
		string memory message) {

		// Check players address
		if (msg.sender == address(0)) {
			revert PlayerAddressInvalid();
		}

		if (games[id].player1 == address(0)) {
			
			// Store player 1
			games[id].player1 = msg.sender;
			emit PlayerJoined(games[id].player1, uint8(Player.Player1)); 
			return (true, "You are Player1 - X");
		}
		else if (games[id].player2 == address(0)) {
			
			// Store player 2
			games[id].player2 = msg.sender;
			emit PlayerJoined(games[id].player2, uint8(Player.Player2)); 
			return (true, "You are Player2 - O");			
		}

		return (false, "Players already joined");
	}

	// Make a move //onlyPlayers
	function makeMove(uint8 id, Move memory move) external onlyPlayers(id)
		returns(bool success, string memory message) {

		// Check if already winner exists
		if (games[id].winner != Player.None) {
			return (false, "The game has aready ended!");
		}

		// Only player who's turn it is can make a move
		if (msg.sender != _getCurrentPlayer(id)) {
			return (false, "Not your turn");
		}

		// Check cell initial value
		uint8 value = uint8(getState(move.row, move.col));

		if (!((value == uint8(CellValueL.Empty)) ||
		     (value > 128))) {
			//revert();
		}

		uint8 setVal;
		if (games[id].turn == Player.Player1) {
			setVal = uint8(CellValueL.X);
		}
		else if (games[id].turn == Player.Player2) {
			setVal = uint8(CellValueL.O);
		}

		// Execute for move as per rule
		(success) = setCell(games[id].levelCode, 
								move.row, move.col, setVal);
		assert(success == true);
		assert(uint8(getState(move.row, move.col)) == setVal);

		// Calculator Winner
		(Player winner, string memory m) = _calculateWinner();
		// There is a winner
		if (winner != Player.None) {

			// Game ended 
			games[id].winner = winner;
			message = string(abi.encodePacked("You Won!", "@", m));
			games[id].message = message;
			emit PlayerMove(games[id].turn, move, winner, message);
			return (true, message);
		}
		else {
			emit PlayerMove(games[id].turn, move, winner, message);			
		}

		// Next player's turn
		if (games[id].turn == Player.Player1) {
			games[id].turn = Player.Player2;
		}
		else if (games[id].turn == Player.Player2) {
			games[id].turn = Player.Player1;
		}

		return (true, "Next player's turn");
	}

	// Gets current players who's turn it is
	function _getCurrentPlayer(uint8 id) internal view returns(address player) {

		if (games[id].turn == Player.Player1) {
			return games[id].player1;
		}
		
		if (games[id].turn == Player.Player2) {
			return games[id].player2;
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

		// Rows
		for (uint8 r = 0; r < _marker; r++) {

			for (uint8 c = 0; c < _tuples; c++) {

				if (level == 1) {
					if ((getState(r, c) == getState(r, c+1)) &&
					    (getState(r, c+1) == getState(r, c+2))) {

						if (getState(r, c) == uint8(CellValueL.X)) {
						   	countX = 1;
						   	winner = Player.Player1;
						   	col = c;							
						}
						else if (getState(r, c) == uint8(CellValueL.O)) {
						   	countO = 1;
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
						   	winner = Player.Player1;
						   	col = c;
					   	}
					   	if (getState(r, c) == uint8(CellValueL.O)) {
						   	countO = 1;
						   	winner = Player.Player2;
						   	col = c;
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

		// Columns
		for (uint8 c = 0; c < _marker; c++) {

			for (uint8 r = 0; r < _tuples; r++) {

				if (level == 1) {
					if ((getState(r, c) == getState(r+1, c)) &&
					    (getState(r+1, c) == getState(r+2, c))) {

						if (getState(r, c) == uint8(CellValueL.X)) {
						   	countX = 1;
						   	winner = Player.Player1;
						   	row = r;							
						}
						else if (getState(r, c) == uint8(CellValueL.O)) {
						   	countO = 1;
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
						   	winner = Player.Player1;
						   	row = r;
					   	}
					   	if (getState(r, c) == uint8(CellValueL.O)) {
						   	countO = 1;
						   	winner = Player.Player2;
						   	row = r;
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

		if (level == 1) {

			if ((getState(0, 0) == getState(1, 1)) &&
			    (getState(1, 1) == getState(2, 2))) {

				if (getState(0, 0) == uint8(CellValueL.X)) {
				   	countX = 1;
				   	winner = Player.Player1;
			   	}
			   	if (getState(0, 0) == uint8(CellValueL.O)) {
				   	countO = 1;
				   	winner = Player.Player2;
			   	}
			   	combo = 1;	
			}
			else if ((getState(0, 2) == getState(1, 1)) &&
			    (getState(1, 1) == getState(2, 0))) {

				if (getState(0, 2) == uint8(CellValueL.X)) {
				   	countX = 1;
				   	winner = Player.Player1;
			   	}
			   	if (getState(0, 2) == uint8(CellValueL.O)) {
				   	countO = 1;
				   	winner = Player.Player2;
			   	}
			   	combo = 2;
			}
		}
		else if (level == 2) {

			uint8 e = 0;
			uint8 d = 0;

			for (d = 0; d < _tuples; d++) {
			
				if ((getState(d, d) == getState(d+1, d+1)) &&
					(getState(d+1, d+1) == getState(d+2, d+2)) &&
					(getState(d+2, d+2) == getState(d+3, d+3))) {

				   	if (getState(d, d) == uint8(CellValueL.X)) {
					   	countX = 1;
					   	winner = Player.Player1;
				   	}
				   	if (getState(d, d) == uint8(CellValueL.O)) {
					   	countO = 1;
					   	winner = Player.Player2;
				   	}
			   		combo = 1;
			   		diag = d;
				}			
			}

			if (countX == countO) {
				d = 0;
				for ( ; (d < _tuples && e < _tuples); ) {
				
					if ((getState(e, 8-d) == getState(e+1, 7-d)) &&
						(getState(e+1, 7-d) == getState(e+2, 6-d)) &&
						(getState(e+2, 6-d) == getState(3+e, 5-d))) {

					   	if (getState(e, 8-d) == uint8(CellValueL.X)) {
						   	countX = 1;
						   	winner = Player.Player1;
					   	}
					   	if (getState(e, 8-d) == uint8(CellValueL.O)) {
						   	countO = 1;
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
	}

    modifier onlyAdmin {
        if (msg.sender != admin) revert("Not Admin");
        _;
    }

    modifier onlyPlayers(uint8 id) {
        if ((msg.sender != games[id].player1) &&
        	(msg.sender != games[id].player2)) revert("Not Player");
        _;
    }
}