# CrowdSouced-TicTacToe
The main idea is that of a crowdsourced contract upgrade, the usecase of which is a simple tic-tac-toe game. The usecase can be extended to other complex defi strategies and socialmedia recommendation algorithm

![TicTacToe](./TicTacToe.jpg?raw=true "TicTacToe")

**Participants**

1. Players - Who play the game (Player 1 & Player 2)
2. Bidders - Who bid for levels (Bidder A, B & C)

**Game Rules**

1. Player 1 is assigned “**X**”
2. Player 2 is assigned “**O**”
3. Default level is **Level 1**  - it contains **empty** **3x3** cells
4. The next level is **Level 2** - it contains **9x9** partially filled cells
5. A partially filled cell is show as below - It contains pre-filled cells
   with “**X**” and “**O**” and can also contain pre-filled special cells that contain 
   ⭐ or 💣. Only the **special pre-filled cells are covered** so that the players don’t know what’s underneath.

![Level2](./Level2-0.jpg?raw=true "Level2")
   
![Level2](./Level2-1.jpg?raw=true "Level2")

6. Each Player makes one move at a time, **Player 1 get the first move**
7. A move is defined by either player placing an “**X**” or “**O**” ****in an empty cell
8. A move is also defined by **pressing the** **special covered cell,**
   in this case the **cell is uncovered** and is revealed.
4. If the revealed cell is a ⭐ then the **player gets the ⭐** and
   gets to player **another move**.
5. If the revealed cell is a 💣 then the **player loses** and the **game ends**
   with the other player as the winner.
6. The game is over when all the cells are filled or uncovered.

**Level Rules**

1. The default level is starts when the game loads (by the Governance).
2. A level 2 has to be a **Eight** **3x3 cell grid** with the level 1 cells absent
   as shown below. Note that even the **cells directly adjoining level 1 cells**
   **are to be absent** for fair game play.  
    

[]()

![Level2](./Level2-2.jpg?raw=true "Level2")

1. There should be equal “X” and “O” placed strategically by the Bidder.
2. There cannot be adjoining “X”s or “O”s
3. There can be only one “X” or “O” in a given row or column.
4. There can be only 3 special cells with either ⭐ or 💣

**Deploy Game**
forge script --chain sepolia script/Game.s.sol:DeployGame --rpc-url $SEPOLIA_RPC_URL --broadcast --verify -vvvv -i 1

**Deploy Level 1**
forge script --chain sepolia script/LevelConfigurator.s.sol:ProposeLevel1 --rpc-url $SEPOLIA_RPC_URL --broadcast --verify -vvvv -i 1

**Deploy Level 2**
forge script --chain sepolia script/LevelConfigurator.s.sol:ProposeLevel2 --rpc-url $SEPOLIA_RPC_URL --broadcast --verify -vvvv -i 1

**Game deployed on Sepolia Testnet**
GAMECONTRACT="0x4AE85136760964B0A2d87fF8CAB53014AE458237"
LEVELCONFIGURATOR="0xda36288642f7e7859865154d6500711E062B529D"

**Level 1**
BIDDER1="0x483a0D0dF404515975CCFE1c5Aa910d653Ca70e8"

**Level 2**
BIDDER2="0x4B4C0050cA76A572a13546073186122B353d5BBF"

**Install Steps**
1. npm install
2. npm run start-player

**More Details**

The Dapp upgraded version can be provided by a bidder, on winning the bid the version 1 of the Dapp is extended to version 2 with the option of retaining the previous state or re-configuring or re-purposing the previous state. 
For. e.g A Dapp can change the prerequisites for airdrop based the following
1. In version 1 the requirement for claiming an airdrop could be an NFT token
2. In version 2 the requirement could extend to certain amount of and ERC20 token.
3. In version 3 the requirement could extend to proof of a social media handle
In case of version 3 the level could integrate oracles or commitment proofs to extend the scope of actions. 

The template for creating a level can be explicitly implied to the developer by mandatory use of certain fixed base contracts For. e.g In case of a Tictactoe game the base contracts BaseLevel, BaseState, BaseSymbols could govern how the level info, Initial state of cells, Symbols used; are set or get. 

"contract Level1D is BaseLevelD, BaseStateD, BaseSymbolD, BaseDataD {
    constructor (bytes memory levelNum, bytes memory state, 
                                 bytes memory symbols)
        BaseDataD(levelNum, state, symbols) {}
"
The Dapp caches the hash of the level proposal (code, levelinfo, state, symbols) until the governance decides which bidder's proposals wins (currently out of scope).  
The Data for the level is stored as contract code so that other bidders can easily access it while proposing the next level so as to not create duplicate configurations (level info, pre-filled cells, symbols).

Essentially the Dapp should follow the same template as of the Level either implicitly or explicitly by using the Base contracts (the same used by the bidders). In this way the whole Dapp can be made modular and easily extendable.   

We had to reduce the scope of the project, hence we decide to not include the governance, voting and rewards parts of the game. 

We tried to implement the special symbols like ⭐ and 💣 as follows
1. Bidder provides masked values of these symbols as part of the level 
   pre-filled cells and a commitment for each symbol (at each location) 
2. We used semaphore protocol's merkle group identities and proofs and
   successfully tested its working as a standalone module.
3. But due to time restrictions we were not able to integrate it into 
   the main game contract.
4. We will do this post bootcamp. 

We also thought of integrating ERC-4337 for better UX but due to time restrictions were not able to do it. We will do it in the future. 

We have tested successfully on Sepolia Testnet, but will continue to optimise for deployment and running cost in version 2  