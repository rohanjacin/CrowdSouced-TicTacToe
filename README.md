# CrowdSouced-TicTacToe
The main idea is that of a crowdsourced contract upgrade, the usecase of which is a simple tic-tac-toe game. The usecase can be extended to other complex defi strategies and socialmedia recommendation algorithm

![TicTacToe](./TicTacToe.jpg?raw=true "TicTacToe")

**Participants**

1. Players - Who play the game (Player 1 & Player 2)
2. Bidders - Who bid for levels (Bidder A, B & C)
3. Governance - Who run the game

**Game Rules**

1. Player 1 is assigned “**X**”
2. Player 2 is assigned “**O**”
3. Default level is **Level 1**  - it contains **empty** **3x3** cells
4. The next level is **Level 2** - it contains **9x9** partially filled cells
5. The next level is **Level 3** - it contains **15x15** partially filled cells
6. A partially filled cell is show as below - It contains pre-filled cells

      with “**X**” and “**O**” and can also contain pre-filled special cells that contain 

     ⭐ or 💣. Only the **special pre-filled cells are covered** so that the players 

don’t know what’s underneath.

![Level2](./Level2-0.jpg?raw=true "Level2")
   
![Level2](./Level2-1.jpg?raw=true "Level2")

1. Each Player makes one move at a time, **Player 1 get the first move**
2. A move is defined by either player placing an “**X**” or “**O**” ****in an empty cell
3. A move is also defined by **pressing the** **special covered cell,** in this case the **cell is uncovered** and is revealed.
4. If the revealed cell is a ⭐ then the **player gets the ⭐** and gets to player **another move**.
5. If the revealed cell is a 💣 then the **player loses** and the **game ends** with the other player as the winner.
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

**Voting Rules**

1. Voting for Level 2 starts after Level 1 is complete.
2. Bidders submit one proposal each for a Level.
3. The Governace does voting and based on the result the winning 
    
    Bidder’s Level configuration is selected to be the next Level.
    

**Staking Rules**

1. Each bidder has to stake a fixed amount of tokens along with their bids.
2. Bidder’s who have not won get their stakes refunded before the game begins.
3. If a bidder submits a proposal with an invalid Level configuration (as per level rules) then that bidder’s stake is slashed.
4. If there are only two bidders, then winner is decided on a coin toss. The bidder who submits the proposal earlier get to call the toss.