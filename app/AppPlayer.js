import React from "react";
import { useState } from "react";
import Game from "./components/Game.jsx";
import "./AppPlayer.css";

const App = () =>{
    const [initalLevel, SetInitialLevel] = useState(sessionStorage.getItem('level') || 1);

    function onGameOver () {
      console.log("In onGameOver");
      sessionStorage.setItem('level', 2);
      SetInitialLevel(2);
    }

   return (
      <Game initalLevel={initalLevel} onGameOver={onGameOver}/>
   );
}

export default App

