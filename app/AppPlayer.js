import React from "react";
import { useState } from "react";
import Game from "./components/Game.jsx";
import "./AppPlayer.css";

const App = ({ initialPlayerId }) =>{
    const [initalLevel, SetInitialLevel] = useState(parseInt(sessionStorage.getItem('level')) || 1);

    function onGameOver () {
      console.log("In onGameOver");
      sessionStorage.setItem('level', 2);
      SetInitialLevel(2);
    }

   return (
      <Game initalLevel={initalLevel} initialPlayerId={initialPlayerId} onGameOver={onGameOver}/>
   );
}

export default App

