import React from "react";
import { useState } from "react";
import Admin from "./components/Admin.jsx";
import "./AppAdmin.css";

const App = () => {

    const [initalLevel, SetInitialLevel] = useState(parseInt(sessionStorage.getItem('level')) || 0);

    function onGameOver () {
      console.log("In onGameOver");
      sessionStorage.setItem('level', 2);
      SetInitialLevel(2);
    }

   return (
      <Admin initalLevel={initalLevel} onGameOver={onGameOver}/>
   );
}

export default App